pragma solidity ^0.4.14;
import './SafeMath.sol';
contract HireIco {
    using SafeMath for uint256;
    string public name = "HireMatch Token"; // Token Name
    string public symbol = "HIRE"; // Token Symbol
    address public creatorContract; // Address of the Owner.
    uint256 public decimals = 18; // Number of decimal points to the Token. Make trading easier.
    address public beneficiary; // address where funds will be transferred after the ICO
    uint256 public preSaleStartTimestamp; // preSale start timestamp
    uint256 public preSaleEndTimestamp; // preSale end timestamp
    uint256 public icoStartTimestamp; // ICO start timestamp
    uint256 public icoEndTimestamp; // ICO end timestamp
    uint256 public totalRaisedInPreSale; // total amount of money raised in wei during the Pre Sale
    uint256 public totalRaisedInICO; //total amount of money raised in wei during the ICO
    bool public halted = false; //the owner address can set this to true to halt the crowdsale due to emergency
    bool public ended = false; // the ICO has ended.
    uint256 public constant preSaleEtherMaxCap = 8000 * 1 ether; // should be specified as: 8000 * 1 ether
    uint256 public constant icoEtherMaxCap = 40000 * 1 ether; // should be specified as: 40000 * 1 ether
    uint256 public constant totalTokenSupply = 10 ** 8 * 1 ether; // Total Token Supply
    uint256 public constant totalTokenForSale = 78 ** 7 * 1 ether; // Total Available Supply
    uint256 public constant preSaleRate = 2100; // standard HIRE/ETH rate during the Pre Sale
    uint256 public constant icoRate = 1800; // standard HIRE/ETH rate during the ICO
    mapping(address => uint256) balances; // Keeps track of all the purchases made by different addresses
    event Buy(address indexed recipient, uint256 weiAmount, uint256 tokens);
    // Checks if the caller is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == creatorContract);
        _;
    }
    // Pre-Requisites to ensure that funds are accepted in the right timeslot, i.e., ICO or Pre Sale
    modifier acceptsFunds() {
        require(isPreSalePeriod() || isIcoPeriod());
        if (isPreSalePeriod()){
            require(!isMaxCapReachedPreSale());
        } else{
            require(!isMaxCapReachedICO());
        }
        _;
    }
    // To check that ICO is not halted by the Owner.
    modifier nonHalted() {
        require(!halted);
        _;
    }
    // To check that the ICO is halted
    modifier ishalted() {
        require(halted);
        _;
    }
    // Make sure that the purchase amount != 0
    modifier nonZeroPurchase() {
        require(msg.value > 0);
        _;
    }
    // Constructor to initialize some of the variables
    function HireIco(
            address _owner,
            uint256 _preSaleStartTimestamp,
            address _beneficiary) {
        require(_owner != 0x0);
        require(_beneficiary != 0x0);
        require(_preSaleStartTimestamp > now);
        creatorContract = _owner;
        beneficiary = _beneficiary;
        preSaleStartTimestamp = _preSaleStartTimestamp;
        preSaleEndTimestamp = preSaleStartTimestamp + 7 days;
        icoStartTimestamp = preSaleEndTimestamp + 1 days;
        icoEndTimestamp = icoStartTimestamp + 15 days;
    }
    /// fallback function to buy tokens
    function () nonHalted nonZeroPurchase acceptsFunds payable {
        require(!ended);
        address recipient = msg.sender;
        uint256 weiAmount = msg.value;
        uint256 tokens = calculateTokens(weiAmount); // calculate new tokens amount to be created
        if(isPreSalePeriod()) {
            balances[recipient] = balances[recipient].add(tokens);
            totalRaisedInPreSale = totalRaisedInPreSale.add(weiAmount);
        } else if (isIcoPeriod()) {
            balances[recipient] = balances[recipient].add(tokens);
            totalRaisedInICO = totalRaisedInICO.add(weiAmount);
        }
        Buy(recipient, msg.value, tokens);
    }
    // Auto calculated the number of tokens, based on the WEIs transferred
    // Providing 20% bonus for 1000+ ether value of tokens
    function calculateTokens(uint256 weiAmount) constant returns(uint256) {
        uint256 defaultAllocation = weiAmount.mul(icoRate);
        if (isPreSalePeriod()) {
            defaultAllocation = weiAmount.mul(preSaleRate);
            if(weiAmount == 1000 * 1 ether){
                defaultAllocation = defaultAllocation.mul(120).div(100);
            }
        }
        return defaultAllocation;
    }
    // Check if the Pre Sale is still in Progress
    function isPreSalePeriod() public constant returns(bool preSalePeriod) {
        return now >= preSaleStartTimestamp
            && now <= preSaleEndTimestamp
            && totalRaisedInPreSale <= preSaleEtherMaxCap;
    }
    // Check is the ICO is still in progress.
    function isIcoPeriod() public constant returns(bool icoPeriod) {
        return now >= icoStartTimestamp
            && now <= icoEndTimestamp
            && totalRaisedInICO <= icoEtherMaxCap;
    }
    // If the Maximum Cap is reached in Pre Sale
    function isMaxCapReachedPreSale() public constant returns(bool maxCapReachedPreSale) {
        return totalRaisedInPreSale >= preSaleEtherMaxCap;
    }
    // If the Maximum Cap is reached in ICO
    function isMaxCapReachedICO() public constant returns(bool maxCapReachedICO) {
        return totalRaisedInICO >= icoEtherMaxCap;
    }
    // Ending the fundraising after timestamp is reached or ICO limit has reached
    function endFundRaising() onlyOwner returns (bool){
        require(now >= icoEndTimestamp || isMaxCapReachedICO());
        transferFundsToBeneficiary();
        return true;
    }
    // transfer the funds to the beneficiary, after the ICO
    function transferFundsToBeneficiary() internal {
        beneficiary.transfer(totalRaisedInICO + totalRaisedInPreSale); // immediately send Ether to beneficiary address
    }
    // To halt the ICO incase of any discrepancy, only by Owner.
    function haltFundraising() public onlyOwner {
        halted = true;
    }
    // To resume the ICO incase of any discrepancy, only by Owner.
    function unhaltFundraising() public onlyOwner {
        halted = false;
    }
}