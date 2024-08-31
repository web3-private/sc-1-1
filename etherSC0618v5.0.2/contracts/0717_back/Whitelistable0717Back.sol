// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {AccessManager0717Back} from "./AccessManager0717Back.sol";

/**
 * @title Whitelistable Token
 * @dev Allows accounts to be whitelisted by a "whitelister" role
 */
abstract contract Whitelistable0717Back is AccessManager0717Back {
    event Whitelisted(address indexed _account);
    event UnWhitelisted(address indexed _account);
    event WhitelisterChanged(address indexed newWhitelister);

    /**
     * @dev Throws if called by any account other than the whitelister.
     */
    modifier onlyWhitelister() {
        _checkOnlyWhitelister();
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
     * @dev Throws if argument account is whitelister.
     * @param _account The address to check.
     */
    modifier isAddressWhitelisted(address _account) {
        if (_whitestatus()) {
            require(_isWhitelisted(_account), "Whitelistable: account is not the whitelisted");
        }

        _;
    }

    function _checkOnlyWhitelister() internal view virtual {
        require(_accessHasRole(WHITELISTER_MANAGER_ROLE, msg.sender), "Whitelistable: caller is not the whitelister");
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
    function whitelist(address _account) external onlyWhitelister {
        _whitelist(_account);
        emit Whitelisted(_account);
    }

    /**
     * @notice Adds account to batchWhitelist.
     * @param _account  The list of address to whitelist.
     */
    function batchWhitelist(address[] calldata _account) external onlyWhitelister {
        require(_account.length >= 1, "_account and amounts length mismatch");
        for (uint256 i = 0; i < _account.length; i++) {
            _whitelist(_account[i]);
        }
    }

    /**
     * @notice Removes account from whitelist.
     * @param _account The address to remove from the whitelist.
     */
    function unWhitelist(address _account) external onlyWhitelister {
        _unWhitelist(_account);
        emit UnWhitelisted(_account);
    }

    /**
     * @notice Updates the whitelister address.
     * @param _newWhitelister The address of the new whitelister.
     */
    function updateWhitelister(address _newWhitelister) external virtual;

    /**
     * @dev Checks if account is whitelisted.
     * @param _account The address to check.
     * @return true if the account is whitelisted, false otherwise.
     */
    function _isWhitelisted(address _account) internal view virtual returns (bool);

    /**
     * @dev Helper method that whitelists an account.
     * @param _account The address to whitelist.
     */
    function _whitelist(address _account) internal virtual;

    /**
     * @dev Helper method that unwhitelists an account.
     * @param _account The address to unwhitelist.
     */
    function _unWhitelist(address _account) internal virtual;

    function _whitestatus() internal view virtual returns (bool);
}
