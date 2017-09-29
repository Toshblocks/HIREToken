pragma solidity ^0.4.13;

/*****
    * @title ERC20 Interface
    * @dev see https://github.com/ethereum/EIPs/issues/20
    */
contract ERC20 {
    uint public totalSupply;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function allowance(address owner, address spender) constant returns (uint);
    function approve(address spender, uint value) returns (bool ok);
    function balanceOf(address who) constant returns (uint);
    function totalSupply() constant returns (uint256);
    function transfer(address to, uint value) returns (bool ok);
    function transferFrom(address from, address to, uint value) returns (bool ok);
}
