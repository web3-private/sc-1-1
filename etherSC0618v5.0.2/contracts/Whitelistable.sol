// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {AccessManager} from "./AccessManager.sol";

/**
 * @title Whitelistable
 * @author Asan
 * @dev Allows accounts to be whitelisted by a "whitelister" role.
 */
abstract contract Whitelistable is AccessManager {
    /**
     * @dev Defines whitelist events.
     * @param _account Account address.
     */
    event AddWhitelist(address indexed _account);
    /**
     * @dev Defines the de-whitelist event.
     * @param _account Account address.
     */
    event RemoveWhitelist(address indexed _account);
    /**
     * @dev Defines the whitelist manager modification event
     * @param newManager New whitelist manager address
     */
    event UpdateWhitelistManager(address indexed newManager);

    /**
     * @dev Throws if called by any account other than the whitelister.
     */
    modifier onlyWhitelistManager() {
        _checkOnlyWhitelistManager();
        _;
    }

    /**
     * @dev Throws if argument account is whitelister.
     * @param _account The address to check.
     */
    modifier notWhitelisted(address _account) {
        if (_whitestatus()) {
            require(!_isWhitelisted(_account), "Whitelistable: account is whitelisted");
        }
        _;
    }

    /**
     * @dev Throws if argument account is whitelist.
     * @param _account The address to check.
     */
    modifier isAddressWhitelisted(address _account) {
        if (_whitestatus()) {
            require(_isWhitelisted(_account), "Whitelistable: account is not the whitelist");
        }
        _;
    }

    /**
     * @dev Verify that the current caller role is WHITELIST_MANAGER_ROLE.
     */
    function _checkOnlyWhitelistManager() internal view virtual {
        require(_accessHasRole(WHITELIST_MANAGER_ROLE, msg.sender), "Whitelistable: caller is not the whitelist");
    }

    /**
     * @notice Checks if account is whitelisted.
     * @param _account The address to check.
     * @return True if the account is whitelisted, false if the account is not whitelisted.
     */
    function isWhitelisted(address _account) external view returns (bool) {
        return _isWhitelisted(_account);
    }

    /**
     * @notice Adds account to whitelist.
     * @param _account The address to whitelist.
     */
    function addWhitelist(address _account) external onlyWhitelistManager {
        _addWhitelist(_account);
        emit AddWhitelist(_account);
    }

    /**
     * @notice Adds account to batchAddWhitelist.
     * @param _account  The list of address to whitelist.
     */
    function batchAddWhitelist(address[] calldata _account) external onlyWhitelistManager {
        require(_account.length >= 1, "_account and amounts length mismatch");
        for (uint256 i = 0; i < _account.length; i++) {
            _addWhitelist(_account[i]);
        }
    }

    /**
     * @notice Removes account from whitelist.
     * @param _account The address to remove from the whitelist.
     */
    function removeWhitelist(address _account) external onlyWhitelistManager {
        _removeWhitelist(_account);
        emit RemoveWhitelist(_account);
    }

    /**
     * @notice Updates the whitelist manager address.
     * @param _newManager The address of the new whitelist manager.
     */
    function updateWhitelistManager(address _newManager) external virtual;

    /**
     * @dev Checks if account is whitelisted.
     * @param _account The address to check.
     * @return true if the account is whitelisted, false otherwise.
     */
    function _isWhitelisted(address _account) internal view virtual returns (bool);

    /**
     * @dev Helper method that addwhitelist an account.
     * @param _account The address to whitelist.
     */
    function _addWhitelist(address _account) internal virtual;

    /**
     * @dev Helper method that removeWhitelist an account.
     * @param _account The address to unwhitelist.
     */
    function _removeWhitelist(address _account) internal virtual;

    /**
     * @dev Querying whitelist status.
     */
    function _whitestatus() internal view virtual returns (bool);
}
