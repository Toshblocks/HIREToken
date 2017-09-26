pragma solidity ^0.4.15;

import './Ownable.sol';
import './SafeMath.sol';
import './StandardToken.sol';

/// @title Generic Token Contract
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
        * @param _name              string      The name of the Token
        * @param _symbol            string      Defines the Token Symbol
        * @param _initialSupply     uint256     The total number of the tokens available
        * @param _decimals          uint256     Defines the number of decimals places of the token
        */
    function Token() {
        totalSupply = 100 ** 24; // 100 Million Tokens in supply
    }

    /*****
        * @dev Used to remove the balance, when asking for refund
        * @param _recipient address The beneficiary of the refund
        * @return           bool    Returns true, if successful
        */
    function refundedAmount(address _recipient) returns (bool) {
        require(balances[_recipient] != 0);
        balances[_recipient] = 0;
        return true;
    }
}
