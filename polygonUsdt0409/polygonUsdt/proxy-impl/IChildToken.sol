
// File: contracts/child/ChildToken/IChildToken.sol

pragma solidity 0.6.6;

interface IChildToken {
    function deposit(address user, bytes calldata depositData) external;
}