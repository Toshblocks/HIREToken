pragma solidity ^0.4.13;

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }
}


/*****
    * @title Basic Token
    * @dev Basic Version of a Generic Token
    */
contract BasicToken {
    using SafeMath for uint;

    uint public totalSupply;

    mapping(address => uint) balances;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    /*****
        * @dev Tranfer the token balance to a specified address
        * @param _to The address to transfer to
        * @param _value The value to be transferred
        */
    function transfer(address _to, uint _value) returns (bool success) {
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /*****
        * @dev Tranfer the token balance to a specified address
        * @param _from      address     The address from where to transfer from
        * @param _to        address     The address to transfer to
        * @param _value     uint256     The value to be transferred
        * @return           bool        Returns True if successful
        */
    function tranferFrom(address _from, address _to, uint256 _value) returns (bool) {
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /*****
        * @dev Gets the balances of the specified address
        * @param _owner The address to query the balance of
        * @return An uint representing the amount owned by the passed address
        */
    function balanceOf(address _owner) constant returns (uint balance){
        return balances[_owner];
    }

    /*****
        * @dev Gets the totalSupply of the tokens.
        */
    function totalSupply() constant returns (uint256) {
        return totalSupply;
    }
}


/*****
    * @title Standard ERC20 token
    *
    * @dev Implementation of the basic standard token.
    * @dev https://github.com/ethereum/EIPs/issues/20
    * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
    */
contract StandardToken is BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    /*****
        * @dev Transfer tokens from one address to another
        * @param _from      address     The address which you want to send tokens from
        * @param _to        address     The address which you want to transfer to
        * @param _value     uint256     The amount of tokens to be transferred
        */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        uint256 _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /*****
        * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
        *
        * Beware that changing an allowance with this method brings the risk that someone may use both the old
        * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
        * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
        * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        * @param _spender   address     The address which will spend the funds.
        * @param _value     uint256     The amount of tokens to be spent.
        */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = 0;
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*****
        * @dev Function to check the amount of tokens that an owner allowed to a spender.
        * @param _owner     address     The address which owns the funds.
        * @param _spender   address     The address which will spend the funds.
        * @return           uint256     Specifying the amount of tokens still available for the spender.
        */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

    /*****
        * approve should be called when allowed[_spender] == 0. To increment
        * allowed value is better to use this function to avoid 2 calls (and wait until
        * the first transaction is mined)
        * From MonolithDAO Token.sol
        */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


// @title Generic Token Contract
contract Token is StandardToken {
    using SafeMath for uint256;

    // Defines the name of the token.
    string public constant TOKEN_NAME = "HIRE Token";

    // Defines the symbol of the token.
    string public constant TOKEN_SYMBOL = "HIRE";

    // Number of decimal places for the token.
    uint256 public constant DECIMALS = 18;

    /*****
        * @dev Sets the variables related to the Token
        */
    function Token() {
        totalSupply = 100 ** 24; // 100 Million Tokens in supply
    }
}


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

    // Total Tokens Sold in Pre Sale Period
    uint256 public presaleTokenRaised;

    // Total Tokens Sold in ICO Period
    uint256 public icoTokenRaised;

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

    function getTokenAddress() returns (address){
        return tokenAddress;
    }

    function getStartTimestamp() returns(uint256) {
        return presaleStartTimestamp;
    }

    function getEndTimestamp() returns(uint256) {
        return presaleEndTimestamp;
    }

    function getICOState() constant returns (State) {
        return crowdSaleState;
    }

    /*****
        * @dev Trigger the starting of the ICO
        */
    function startICO() onlyOwner {
        isPreSalePeriod();
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
            presaleTokenRaised = presaleTokenRaised.add(_value);
            TokensBought(_recipient, boughtTokens);
            return true;
        } else if (isCrowdSaleStateICO()) {
            token.transfer(_recipient, _value);
            icoTokenRaised = icoTokenRaised.add(_value);
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
        require(remainingTokens >= 0);

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
        if(isCrowdSaleStatePreSale() || isPreSalePeriod()) {
            return PRESALE_TOKEN_LIMIT.sub(presaleTokenRaised);
        } else if (isCrowdSaleStateICO() || isICOPeriod()) {
            return ICO_TOKEN_LIMIT.sub(icoTokenRaised);
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
    function isPreSalePeriod() internal constant returns (bool) {
        if(presaleTokenRaised >= PRESALE_TOKEN_LIMIT || now >= presaleEndTimestamp) {
            crowdSaleState = State.PresaleFinalized;
            StateChanged("Pre Sale Concluded.");
            icoTokenRaised = presaleTokenRaised;
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
    function isICOPeriod() internal constant returns (bool) {
        if (icoTokenRaised >= ICO_TOKEN_LIMIT || now >= icoEndTimestamp) {
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
        require(now >= icoEndTimestamp || icoTokenRaised >= ICO_TOKEN_LIMIT || crowdSaleState == State.Halt);

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
    function getPresaleRaisedTokens() external constant returns (uint256) {
        return presaleTokenRaised;
    }

    /*****
        * @dev Fetch the amount raised in ICO
        * @return   uint256     Returns the amount of money raised in ICO
        */
    function getICORaisedTokens() external constant returns (uint256) {
        return icoTokenRaised;
    }
}
