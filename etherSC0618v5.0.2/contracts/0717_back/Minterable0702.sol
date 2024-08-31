// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {AccessManager0702} from "./AccessManager0702.sol";

abstract contract Minterable0702 is AccessManager0702 {
    mapping(address account => mapping(address spender => uint256)) minterAllowed;

    event MinterConfigured(address indexed minter);
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

    function isMinter(address account) external view returns (bool) {
        return _accessHasRole(MINTER_ROLE, account);
    }

    function updateAllowance(address owner, address minter, uint256 amount) internal virtual returns (bool);

    function configureMinter(address minter) external virtual returns (bool);

    function removeMinter(address minter) external virtual returns (bool);

    function updateMasterMinter(address _newMasterMinter) public virtual;
}
