// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @title AccessManager
 * @author Asan
 * @dev Manage access role control.
 */
abstract contract AccessManager {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE"); //L2 only

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    bytes32 public constant BLACKLIST_MANAGER_ROLE = keccak256("BLACKLIST_MANAGER_ROLE");
    bytes32 public constant BLACKLIST_MEMBER_ROLE = keccak256("BLACKLIST_MEMBER_ROLE");

    bytes32 public constant WHITELIST_MANAGER_ROLE = keccak256("WHITELIST_MANAGER_ROLE");
    bytes32 public constant WHITELIST_MEMBER_ROLE = keccak256("WHITELIST_MEMBER_ROLE");

    bytes32 public constant MASTER_MINTER_ROLE = keccak256("MASTER_MINTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");
    bytes32 public constant FEE_HOLDER_ROLE = keccak256("FEE_HOLDER_ROLE");

    /**
     * @notice Check whether the current account address has a role role.
     * @dev Check whether the current account address has a role role.Implemented in the Base contract.
     * metamask will be used when calling the transfer function.
     * @param role current role.
     * @param account Enter account address.
     * @return Return the verification result of the account address.
     */
    function _accessHasRole(bytes32 role, address account) internal view virtual returns (bool);
}
