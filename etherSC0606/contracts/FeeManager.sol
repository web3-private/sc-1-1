// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract FeeManager {
    mapping(address => bool) internal feeHolders;
    address public feeMannger;
    mapping(address => uint256) internal minterAllowed;

    event FeeManagerConfigured(address indexed feeMannger, uint256 basisPointsRate);
    event FeeManagerRemoved(address indexed oldMinter);
    event FeeManagerChanged(address indexed newFeeMannger);

    modifier onlyFeeManager() {
        _;
    }
}
