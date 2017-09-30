pragma solidity ^0.4.13;

/*****
    * Orginally from https://github.com/OpenZeppelin/zeppelin-solidity
    * Modified by https://github.com/agarwalakarsh
    */
import './SafeMath.sol';

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
        balances[msg.sender] = balances[msg.sender].sub(_value);
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
