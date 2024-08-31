// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


/**
 * @title Blacklistable Token
 * @dev Allows accounts to be blacklisted by a "blacklister" role
 */
abstract contract Accessable {
    // address public blacklister;
    address public accesslister;

    event Accesslisted(address indexed _account);
    event UnAccesslisted(address indexed _account);
    event AccesslisterChanged(address indexed newBlacklister);

    /**
     * @dev Throws if called by any account other than the blacklister.
     */
    modifier onlyAccesslister() {
        require(
            msg.sender == accesslister,
            "Accessable: caller is not the accesslister"
        );
        _;
    }

    /**
     * @dev Throws if argument account is blacklisted.
     * @param _account The address to check.
     */
    modifier notAccesslisted(address _account) {
        require(
            !_isAccesslisted(_account),
            "Blacklistable: account is accesslisted"
        );
        _;
    }

    /**
     * @notice Checks if account is accesslisted.
     * @param _account The address to check.
     * @return True if the account is accesslisted, false if the account is not accesslisted.
     */
    function isAccesslisted(address _account) external view returns (bool) {
        return _isAccesslisted(_account);
    }

    /**
     * @notice Adds account to accesslist.
     * @param _account The address to accesslist.
     */
    function accesslist(address _account) external onlyAccesslister {
        _accesslist(_account);
        emit Accesslisted(_account);
    }

    /**
     * @notice Removes account from accesslist.
     * @param _account The address to remove from the accesslist.
     */
    function unAccesslist(address _account) external onlyAccesslister {
        _unAccesslist(_account);
        emit UnAccesslisted(_account);
    }

    /**
     * @notice Updates the accesslister address.
     * @param _newAccesslister The address of the new accesslister.
     */
    function updateAccesslister(address _newAccesslister) external virtual {
        require(
            _newAccesslister != address(0),
            "Blacklistable: new accesslister is the zero address"
        );
        accesslister = _newAccesslister;
        emit AccesslisterChanged(accesslister);
    }

    /**
     * @dev Checks if account is blacklisted.
     * @param _account The address to check.
     * @return true if the account is blacklisted, false otherwise.
     */
    function _isAccesslisted(address _account)
        internal
        virtual
        view
        returns (bool);

    /**
     * @dev Helper method that blacklists an account.
     * @param _account The address to blacklist.
     */
    function _accesslist(address _account) internal virtual;

    /**
     * @dev Helper method that unblacklists an account.
     * @param _account The address to unblacklist.
     */
    function _unAccesslist(address _account) internal virtual;
}
