// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {AccessManager} from "./AccessManager.sol";

/**
 * @title Blacklistable
 * @author JD Coinlink
 * @dev Allows accounts to be blacklisted by a "blacklister" role.
 */
abstract contract BlacklistManager is AccessManager {
    /**
     * @dev Defines blacklist events.
     * @param _account Account address.
     */
    event AddBlacklist(address indexed _account);
    /**
     * @dev Defines the de-blacklist event.
     * @param _account Account address.
     */
    event RemoveBlacklist(address indexed _account);
    /**
     * @dev Defines the blacklist manager modification event
     * @param newManager New blacklist manager address
     */
    event UpdateBlacklistManager(address indexed newManager);

    /**
     * @dev Throws if called by any account other than the blacklister.
     */
    modifier onlyBlacklistManager() {
        _checkOnlyBlacklistManager();
        _;
    }

    /**
     * @dev Throws if argument account is blacklisted.
     * @param _account The address to check.
     */
    modifier notBlacklisted(address _account) {
        require(!_isBlacklisted(_account), "Blacklistable: account is blacklisted");
        _;
    }

    /**
     * @dev Verify that the current caller role is BLACKLIST_MANAGER_ROLE.
     */
    function _checkOnlyBlacklistManager() internal view virtual {
        require(_accessHasRole(BLACKLIST_MANAGER_ROLE, msg.sender), "Blacklistable: caller is not the blacklister");
    }

    /**
     * @notice Checks if account is blacklisted.
     * @param _account The address to check.
     * @return True if the account is blacklisted, false if the account is not blacklisted.
     */
    function isBlacklisted(address _account) external view returns (bool) {
        return _isBlacklisted(_account);
    }

    /**
     * @notice Adds account to blacklist.
     * @param _account The address to blacklist.
     */
    function addBlacklist(address _account) external onlyBlacklistManager {
        _addBlacklist(_account);
        emit AddBlacklist(_account);
    }

    /**
     * @notice Adds account to batchAddBlacklist.
     * @param _account The list of addresses to blacklist.
     */
    function batchAddBlacklist(address[] calldata _account) external onlyBlacklistManager {
        require(_account.length >= 1, "_account and amounts length mismatch");
        for (uint256 i = 0; i < _account.length; i++) {
            _addBlacklist(_account[i]);
        }
    }

    /**
     * @notice Removes account from blacklist.
     * @param _account The address to remove from the blacklist.
     */
    function removeBlacklist(address _account) external onlyBlacklistManager {
        _removeBlacklist(_account);
        emit RemoveBlacklist(_account);
    }

    /**
     * @notice Updates the blacklistManager address.
     * @param _newManager The address of the new blacklistManager.
     */
    function updateBlacklistManager(address _newManager) external virtual;

    /**
     * @dev Checks if account is blacklisted.
     * @param _account The address to check.
     * @return true if the account is blacklisted, false otherwise.
     */
    function _isBlacklisted(address _account) internal view virtual returns (bool);

    /**
     * @dev Helper method that addBlacklist an account.
     * @param _account The address to blacklist.
     */
    function _addBlacklist(address _account) internal virtual;

    /**
     * @dev Helper method that removeBlacklist an account.
     * @param _account The address to unblacklist.
     */
    function _removeBlacklist(address _account) internal virtual;
}
