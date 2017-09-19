pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/PausableToken.sol';

contract HireIco is PausableToken {
    using SafeMath for uint256;

    string public name = "HireMatch Token";
    string public symbol = "HIRE";
    uint256 public decimals = 18;

    address public wallet; // address where funds are collected

    uint256 public preSaleStartTimestamp; // preSale start timestamp
    uint256 public preSaleEndTimestamp; // preSale end timestamp

    uint256 public icoStartTimestamp; // ICO start timestamp
    uint256 public icoEndTimestamp; // ICO end timestamp

    uint256 public totalRaised; // total amount of money raised in wei

    bool public halted = false; //the owner address can set this to true to halt the crowdsale due to emergency

    uint256 public preSaleEtherMaxCap; // should be specified as: 8000 * 1 ether
    uint256 public icoEtherMinCap; // should be specified as: 8000 * 1 ether
    uint256 public icoEtherMaxCap; // should be specified as: 40000 * 1 ether
    uint256 public rate = 1800; // standard HIRE/ETH rate

    event Buy(address indexed recipient, uint256 weiAmount, uint256 tokens);
    
    // Unit tested
    function HireIco(
            address newOwner, 
            uint256 newPreSaleStartTimestamp, 
            address newWallet,
            uint256 newPreSaleEtherMaxCap, 
            uint256 newIcoEtherMinCap, 
            uint256 newIcoEtherMaxCap) {
        require(newOwner != 0x0);
        require(newWallet != 0x0);
        require(newPreSaleStartTimestamp > 0);
        require(newIcoEtherMinCap <= newIcoEtherMaxCap);
        require(newPreSaleEtherMaxCap > 0);
        require(newIcoEtherMinCap > 0);
        require(newIcoEtherMaxCap > 0);
        pause();
        totalSupply = 0; // pre-sale and ICO will generate tokens
        preSaleStartTimestamp = newPreSaleStartTimestamp;
        preSaleEndTimestamp = preSaleStartTimestamp + 7 days;
        preSaleEtherMaxCap = newPreSaleEtherMaxCap;
        icoEtherMinCap = newIcoEtherMinCap;
        icoEtherMaxCap = newIcoEtherMaxCap;
        wallet = newWallet;
        transferOwnership(newOwner);
    }

    /// fallback function to buy tokens
    function () nonHalted nonZeroPurchase acceptsFunds payable {
        address recipient = msg.sender;
        uint256 weiAmount = msg.value;

        uint256 tokens = calculateTokens(weiAmount); // calculate new tokens amount to be created

        balances[recipient] = balances[recipient].add(tokens);
        totalSupply = totalSupply.add(tokens);
        totalRaised = totalRaised.add(weiAmount);

        forwardFundsToWallet();
        Buy(recipient, msg.value, tokens);
    }
    
    /// PreSale Bonuses:
    /// - 1-7 day 20%
    // Unit tested
    function calculateTokens(uint256 weiAmount) constant returns(uint) {
        uint256 defaultAllocation = weiAmount.mul(rate);
        if (isPreSalePeriod()) {
            if (now <= preSaleStartTimestamp + 7 days) {
                return defaultAllocation.mul(120).div(100);
            }
        }
        return defaultAllocation;
    }

    // Unit tested
    modifier acceptsFunds() {
        require(isPreSalePeriod() || isIcoPeriod());
        require(!isMaxCapReached());
        require(!isMinCapReachedAfterIcoEnd());
        _;
    }

    function isPreSalePeriod() public constant returns(bool isPreSalePeriod) {
        return now >= preSaleStartTimestamp
            && now <= preSaleEndTimestamp
            && totalRaised < preSaleEtherMaxCap;
    }

    function isIcoPeriod() public constant returns(bool isIcoPeriod) {
        return icoStartTimestamp != 0 // after preSale but still before ICO
                && now >= icoStartTimestamp
                && now <= icoEndTimestamp;
    }

    function isMaxCapReached() public constant returns(bool isMaxCapReached) {
        return totalRaised >= icoEtherMaxCap;
    }

    function isMinCapReachedAfterIcoEnd() public constant returns(bool isMinCapReachedAfterIcoEnd) {
        return totalRaised >= icoEtherMinCap
                && now > icoEndTimestamp;
    }

    // Unit tested
    modifier nonHalted() {
        require(!halted);
        _;
    }

    // Unit tested
    modifier nonZeroPurchase() {
        require(msg.value > 0);
        _;
    }

    function forwardFundsToWallet() internal {
        wallet.transfer(msg.value); // immediately send Ether to wallet address, propagates exception if execution fails
    }

    // Unit tested
    function setIcoDates(uint256 newIcoStartTimestamp, uint256 newIcoEndTimestamp) public onlyOwner {
        require(newIcoStartTimestamp <= newIcoEndTimestamp);
        if (0 == icoStartTimestamp) {
            icoStartTimestamp = newIcoStartTimestamp;
        }
        if (0 == icoEndTimestamp) {
            icoEndTimestamp = newIcoEndTimestamp;
        }
    }

    // Unit tested
    function haltFundraising() public onlyOwner {
        halted = true;
    }

    // Unit tested
    function unhaltFundraising() public onlyOwner {
        halted = false;
    }
    
}
