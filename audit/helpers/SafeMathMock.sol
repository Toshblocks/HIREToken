pragma solidity ^0.4.11;


import '../../contracts/SafeMath.sol';


contract SafeMathMock is SafeMath{
  uint public result;

  function mul(uint a, uint b) {
    result = mul(a, b);
  }


  function add(uint a, uint b) {
    result = add(a, b);
  }

  function sub(uint a, uint b) {
    result = sub(a, b);
  }

  function div(uint a, uint b) {
    result = div(a, b);
  }

  function max64(uint a, uint b) {
    result = max64(a, b);
  }

  function min64(uint a, uint b) {
    result = min64(a, b);
  }

  function max256(uint a, uint b) {
    result = max256(a, b);
  }

  function min256(uint a, uint b) {
    result = min256(a, b);
  }


}
