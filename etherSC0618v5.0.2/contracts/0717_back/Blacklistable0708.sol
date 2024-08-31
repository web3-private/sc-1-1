// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {AccessManager0708} from "./AccessManager0708.sol";

/**
 * @title Blacklistable Token
 * @dev Allows accounts to be blacklisted by a "blacklister" role
 */
abstract contract Blacklistable0708 is AccessManager0708 {
    event Blacklisted(address indexed _account);
    event UnBlacklisted(address indexed _account);
    event BlacklisterChanged(address indexed newBlacklister);

    /**
     * @dev Throws if called by any account other than the blacklister.
     */
    modifier onlyBlacklister() {
        _checkOnlyBlacklister();
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

    function _checkOnlyBlacklister() internal view virtual {
        require(_accessHasRole(BLACKLISTER_MANAGER_ROLE, msg.sender), "Blacklistable: caller is not the blacklister");
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
    function blacklist(address _account) external onlyBlacklister {
        _blacklist(_account);
        emit Blacklisted(_account);
    }

    /**
     * @notice Adds account to batchBlacklist.
     * @param _account The list of addresses to blacklist.
     */
    function batchBlacklist(address[] calldata _account) external onlyBlacklister {
        require(_account.length >= 1, "_account and amounts length mismatch");
        for (uint256 i = 0; i < _account.length; i++) {
            _blacklist(_account[i]);
        }
    }

    /**
     * @notice Removes account from blacklist.
     * @param _account The address to remove from the blacklist.
     */
    function unBlacklist(address _account) external onlyBlacklister {
        _unBlacklist(_account);
        emit UnBlacklisted(_account);
    }

    /**
     * @notice Updates the blacklister address.
     * @param _newBlacklister The address of the new blacklister.
     */
    function updateBlacklister(address _newBlacklister) external virtual;

    /**
     * @dev Checks if account is blacklisted.
     * @param _account The address to check.
     * @return true if the account is blacklisted, false otherwise.
     */
    function _isBlacklisted(address _account) internal view virtual returns (bool);

    /**
     * @dev Helper method that blacklists an account.
     * @param _account The address to blacklist.
     */
    function _blacklist(address _account) internal virtual;

    /**
     * @dev Helper method that unblacklists an account.
     * @param _account The address to unblacklist.
     */
    function _unBlacklist(address _account) internal virtual;
}
