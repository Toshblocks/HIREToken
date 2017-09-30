pragma solidity ^0.4.13;

import './SafeMath.sol';
import './Token.sol';

/*****
    * @title The Crowd Sale Contract
    */
contract TokenSale {
    using SafeMath for uint256;

    // The address of the owner of the contract.
    address public creatorAdmin;

    // Instance of the Token Contract deployed
    Token public token;

    // Address of the Token Contract already deployed
    address public tokenAddress;

    // Received funds are transferred to the beneficiary
    address public beneficiary;

    // Number of Tokens/ETH in PreSale
    uint256 public constant TOKEN_PER_ETH_PRESALE = 2100;

    // Number of Tokens/ETH in ICO
    uint256 public constant TOKEN_PER_ETH_ICOSALE = 1800;

    // Start Timestamp of Pre Sale
    uint256 public presaleStartTimestamp;

    // End Timestamp of Pre Sale
    uint256 public presaleEndTimestamp;

    // Start Timestamp for the ICO
    uint256 public icoStartTimestamp;

    // End Timestamp for the ICO
    uint256 public icoEndTimestamp;

    // Amount of tokens available for sale in Pre Sale Period
    uint256 public constant PRESALE_TOKEN_LIMIT = 168 * 10 ** 23;

    // Amount of tokens available for sale in ICO Period
    uint256 public constant ICO_TOKEN_LIMIT = 72 * 10 ** 24;

    // Total Ethers Raised in Pre Sale Period
    uint256 public presaleEtherRaised;

    // Total tokens issued in the Pre Sale Period
    uint256 public presaleTokensIssued;

    // Total Ethers Raised in the Entire ICO
    uint256 public totalEtherRaised;

    // Total tokens issued in the entire ICO
    uint256 public totalTokensIssued;

    // Max Cap for Pre Sale
    uint256 public constant PRESALE_MAX_ETH_CAP = 8000 * 1 ether;

    // Max Cap for ICO
    uint256 public constant ICO_MAX_ETH_CAP = 40000 * 1 ether;

    // Different number of Investors
    uint256 public investorCount;

    /*****
        * State machine
        *   - Unknown:      Default Initial State of the Contract
        *   - Preparing:    All contract initialization calls
        *   - PreSale:      We are into PreSale Period
        *   - ICO:          The real Sale of Tokens, after Pre Sale
        *   - Success:      Minimum funding goal reached
        *   - Failure:      Minimum funding goal not reached
        *   - Finalized:    The ICO has been concluded
        *   - Refunding:    Refunds are loaded on the contract for reclaim.
        */
    enum State{Unknown, Preparing, PreSale, ICO, Success, Aborted, PresaleFinalized, ICOFinalized, Halt}
    State public crowdSaleState;
    State savedState;

    event TokensBought(address _recipient, uint256 _number);
    event StateChanged(string _message);

    /*****
        * @dev Modifier to check that amount transferred is not 0
        */
    modifier nonZero() {
        require(msg.value > 0);
        _;
    }

    /*****
        * @dev Modifier to check if the ICO is halted or not.
        */
    modifier isHalted() {
        require(crowdSaleState == State.Halt);
        _;
    }

    modifier isUnHalted() {
        require(crowdSaleState != State.Halt);
        _;
    }

    /*****
        * @dev Modifier to check if the caller of the function is
        * the owner of the contract.
        */
    modifier onlyOwner() {
        require(creatorAdmin == msg.sender);
        _;
    }

    /*****
        * @dev The constructor function to initialize the token related properties
        * @param _token             address     Specifies the address of the Token Contract
        * @param _presaleStartTime  uint256     Specifies the Start Date of the Pre Sale
        * @param _presaleDays       uint256     Specifies the duration of the Pre Sale
        * @param _icoStartTime      uint256     Specifies the Start Date for the ICO
        * @param _icoDays           uint256     Specifies the duration of the ICO
        */
    function TokenSale(
        address _token,
        address _beneficiary,
        uint256 _presaleStartTime,
        uint256 _presaleDays,
        uint256 _icoStartTime,
        uint256 _icoDays){
            require(_token != address(0));
            require(_beneficiary != address(0));
            require(_presaleStartTime > now);
            require(_icoStartTime > _presaleStartTime);

            token = Token(_token);

            creatorAdmin = msg.sender;
            tokenAddress = _token;
            beneficiary = _beneficiary;

            presaleStartTimestamp = _presaleStartTime;
            presaleEndTimestamp = presaleStartTimestamp + _presaleDays * 1 days;

            require(_icoStartTime > presaleEndTimestamp);
            icoStartTimestamp = _icoStartTime;
            icoEndTimestamp = _icoStartTime + _icoDays * 1 days;

            crowdSaleState = State.Preparing;
    }

    /*****
        * @dev Trigger the starting of the ICO
        */
    function startICO() onlyOwner returns (bool) {
        isPreSalePeriod();
        return true;
    }

    /*****
        * @dev Fallback Function to buy the tokens
        */
    function () payable {
        revert();
    }

    /*****
        * @dev Internal function to execute the token transfer to the Recipient
        * @param _recipient     address     The address who will receives the tokens
        * @return success       bool        Returns true if executed successfully
        */
    function buyTokens(address _recipient) isUnHalted nonZero payable returns (bool success) {
        uint256 _value = msg.value;
        uint256 boughtTokens = calculateTokens(_value);

        if(token.balanceOf(_recipient) == 0) {
            investorCount++;
        }

        if(isCrowdSaleStatePreSale()) {
            token.transfer(_recipient, _value);
            presaleEtherRaised = presaleEtherRaised.add(_value);
            presaleTokensIssued = presaleTokensIssued.add(boughtTokens);
            TokensBought(_recipient, boughtTokens);
            return true;
        } else if (isCrowdSaleStateICO()) {
            token.transfer(_recipient, _value);
            totalEtherRaised = totalEtherRaised.add(_value);
            totalTokensIssued = totalTokensIssued.add(boughtTokens);
            TokensBought(_recipient, boughtTokens);
            return true;
        } else {
            revert();
        }
    }

    /*****
        * @dev Calculates the number of tokens that can be bought for the amount of WEIs transferred
        * If the investor invests more than 1000 Ethers, they should recieve 20% bonus.
        * @param _amount    uint256     The amount of money invested by the investor
        * @return tokens    uint256     The number of tokens
        */
    function calculateTokens(uint256 _amount) internal constant returns (uint256 tokens){
        uint256 remainingTokens = checkBalanceTokens();
        require(remainingTokens > 0);

        uint256 rate;

        if(isCrowdSaleStatePreSale()) {
            rate = TOKEN_PER_ETH_PRESALE;
            if(_amount >= 1000 * 1 ether){
                rate = rate.mul(120).div(100);
            }
        } else if (isCrowdSaleStateICO()) {
            rate = TOKEN_PER_ETH_ICOSALE;
        } else {
            revert();
        }

        tokens = _amount.mul(rate);
        require(remainingTokens >= tokens);
    }

    /*****
        * @dev Checks the token balance and returns according to the state ICO is in.
        * @return balanceTokens     uint256     The remaining tokens for sale
        */
    function checkBalanceTokens() internal returns (uint256 balanceTokens) {
        if(isPreSalePeriod()) {
            return PRESALE_TOKEN_LIMIT.sub(presaleEtherRaised);
        } else if (isICOPeriod()) {
            return ICO_TOKEN_LIMIT.sub(totalEtherRaised);
        } else {
            return 0;
        }
    }

    /*****
        * @dev Check the state of the Contract, if in Pre Sale
        * @return bool  Return true if the contract is in Pre Sale
        */
    function isCrowdSaleStatePreSale() internal constant returns (bool) {
        return crowdSaleState == State.PreSale;
    }

    /*****
        * @dev Check the state of the Contract, if in ICO
        * @return bool  Return true if the contract is in ICO
        */
    function isCrowdSaleStateICO() internal constant returns (bool) {
        return crowdSaleState == State.ICO;
    }

    /*****
        * @dev Check if the Pre Sale Period is still ON
        * @return bool  Return true if the contract is in Pre Sale Period
        */
    function isPreSalePeriod() internal returns (bool) {
        if(presaleTokensIssued >= PRESALE_TOKEN_LIMIT || now >= presaleEndTimestamp) {
            crowdSaleState = State.PresaleFinalized;
            StateChanged("Pre Sale Concluded.");
            totalEtherRaised = presaleEtherRaised;
            totalTokensIssued = presaleTokensIssued;
            return false;
        } else if (now >= presaleStartTimestamp) {
            if(crowdSaleState == State.Preparing) {
                crowdSaleState = State.PreSale;
                StateChanged("Pre Sale Started.");
            }
            return true;
        } else {
            return false;
        }
    }

    /*****
        * @dev Check if the ICO is in the Sale period or not
        * @return bool  Return true if the contract is in ICO Period
        */
    function isICOPeriod() internal returns (bool) {
        if (totalTokensIssued >= ICO_TOKEN_LIMIT || now >= icoEndTimestamp) {
            crowdSaleState = State.ICOFinalized;
            StateChanged("ICO Concluded.");
            return false;
        } else if(now >= icoStartTimestamp) {
            if (crowdSaleState == State.PresaleFinalized) {
                crowdSaleState = State.ICO;
                StateChanged("ICO Started.");
            }
        } else {
            return false;
        }
    }

    /*****
        * @dev Called by the owner of the contract to close the Sale
        */
    function endCrowdSale() external onlyOwner {
        require(now >= icoEndTimestamp || totalTokensIssued >= ICO_TOKEN_LIMIT || crowdSaleState == State.Halt);

        if(crowdSaleState == State.Halt) {
            crowdSaleState = State.Aborted;
            StateChanged("ICO Aborted.");
        } else {
            crowdSaleState = State.Success;
            StateChanged("ICO Successful.");
        }
        beneficiary.transfer(this.balance);
    }

    /*****
        * @dev To halt the ICO
        */
    function haltICO() external isUnHalted onlyOwner {
        savedState = crowdSaleState;
        crowdSaleState = State.Halt;
        StateChanged("ICO Halted.");
    }

    /*****
        * @dev To un-halt the ICO
        */
    function resumeICO() external isHalted onlyOwner {
        crowdSaleState = savedState;
        StateChanged("ICO Resumed.");
    }

    /*****
        * Fetch some statistics about the ICO
        */

    /*****
        * @dev Fetch the count of different Investors
        * @return   bool    Returns the total number of different investors
        */
    function getInvestorCount() external constant returns (uint256) {
        return investorCount;
    }

    /*****
        * @dev Fetch the amount raised in Pre Sale
        * @return   uint256     Returns the amount of money raised in Pre Sale
        */
    function getPresaleEthersRaised() external constant returns (uint256) {
        return presaleEtherRaised;
    }

    /*****
        * @dev Fetch the amount raised in ICO
        * @return   uint256     Returns the amount of money raised in ICO
        */
    function getTotalEthersRaised() external constant returns (uint256) {
        return totalEtherRaised;
    }
}
