pragma solidity ^0.4.15;

/// @title Ownable
/// @dev The Ownable contract specifies the owner of the contract and can be used
/// to trasnfer the ownership
contract Ownable {
    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed _by, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    /// @dev The constructor sets the original owner of the contract
    function Ownable() {
        owner = msg.sender;
    }

    /// @dev To check the caller is owner itself
    modifier onlyOnwer() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyNewOwnerCandidate() {
        require(msg.sender == newOwnerCandidate);
        _;
    }

    /// @dev Proposes to transfer the ownership of the contract
    /// @param _newOwnerCandidate address The new Owner address
    function requestOwnerrshipTransfer(address _newOwnerCandidate) external onlyOwner {
        require (_newOwnerCandidate != address(0));
        newOwnerCandidate = _newOwnerCandidate;
        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /// @dev Accept the Ownership Transfer. Can only be called by the new Owner
    function acceptOwnership() external onlyOwnerCandidate {
        address previousOwner = owner;
        owner = newOwnerCandidate;
        newOwnerCandidate = address(0);
        OwnershipTransferred(previousOwner, owner);
    }
}
