// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

interface TokenErrors0705 {
    error SubtractionOverflow();
    error DivisionOverflow();
    error MultiplicationOverflow();
    event ApprovalMint(address indexed spender, uint256 value);
    // error InvalidApprover(address approver);
    error InvalidSpender(address spender);
    error InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
}
