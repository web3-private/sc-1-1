// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/**
 * @title Whitelistable Token
 * @dev Allows accounts to be whitelisted by a "whitelister" role
 */
abstract contract Whitelistable {
    address public whitelister;

    event Whitelisted(address indexed _account);
    event UnWhitelisted(address indexed _account);
    event WhitelisterChanged(address indexed newWhitelister);

    /**
     * @dev Throws if called by any account other than the whitelister.
     */
    modifier onlyWhitelister() {
        require(
            msg.sender == whitelister,
            "Whitelistable: caller is not the whitelister"
        );
        _;
    }

    /**
     * @dev Throws if argument account is whitelister.
     * @param _account The address to check.
     */
    modifier notWhitelisted(address _account) {
        require(
            !_isWhitelisted(_account),
            "Whitelistable: account is whitelisted"
        );
        _;
    }

    /**
     * @dev Throws if argument account is whitelister.
     * @param _account The address to check.
     */
    modifier isAddressWhitelisted(address _account) {
        require(
            _isWhitelisted(_account),
            "Whitelistable: account is not the whitelisted"
        );
        _;
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
    function updateWhitelister(address _newWhitelister) external virtual {
        require(
            _newWhitelister != address(0),
            "Whitelistable: new whitelister is the zero address"
        );
        whitelister = _newWhitelister;
        emit WhitelisterChanged(whitelister);
    }

    /**
     * @dev Checks if account is whitelisted.
     * @param _account The address to check.
     * @return true if the account is whitelisted, false otherwise.
     */
    function _isWhitelisted(address _account)
        internal
        virtual
        view
        returns (bool);

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
}
