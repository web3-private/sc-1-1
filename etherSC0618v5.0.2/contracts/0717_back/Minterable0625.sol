// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import {AccessManager0625} from "./AccessManager0625.sol";

abstract contract Minterable0625 is AccessManager0625 {
    mapping(address => uint256) internal minterAllowed;

    event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);
    event MinterRemoved(address indexed oldMinter);
    event MasterMinterChanged(address indexed newMasterMinter);

    modifier onlyMinters() {
        require(_accessHasRole(BLACKLISTER_MANAGER_ROLE, msg.sender), "Minterable: caller is not a minter");
        _;
    }

    modifier onlyMasterMinter() {
        require(_accessHasRole(MASTER_MINTER_ROLE, msg.sender), "Minterable: caller is not the masterMinter");
        _;
    }

    function minterAllowance(address minter) external view returns (uint256) {
        return minterAllowed[minter];
    }

    function isMinter(address account) external view returns (bool) {
        return _accessHasRole(MINTER_ROLE, account);
        // return hasRole(MINTER_ROLE, account);
    }

    function configureMinter(address minter, uint256 minterAllowedAmount) external virtual returns (bool);

    function removeMinter(address minter) external virtual returns (bool);

    function updateMasterMinter(address _newMasterMinter) public virtual;
}
