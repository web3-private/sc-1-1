// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

abstract contract AccessManager0717Back {
    // bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE"); //L2 only

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    bytes32 public constant BLACKLISTER_MANAGER_ROLE = keccak256("BLACKLISTER_MANAGER_ROLE");
    bytes32 public constant BLACKLISTER_ROLE = keccak256("BLACKLISTER_ROLE");

    bytes32 public constant WHITELISTER_MANAGER_ROLE = keccak256("WHITELISTER_MANAGER_ROLE");
    bytes32 public constant WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");

    bytes32 public constant MASTER_MINTER_ROLE = keccak256("MASTER_MINTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");
    bytes32 public constant FEE_HOLDER_ROLE = keccak256("FEE_HOLDER_ROLE");

    function _accessHasRole(bytes32 role, address account) internal view virtual returns (bool);
}
