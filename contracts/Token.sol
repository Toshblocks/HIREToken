pragma solidity ^0.4.13;

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
        */
    function Token() {
        totalSupply = 100 ** 24; // 100 Million Tokens in supply
    }
}
