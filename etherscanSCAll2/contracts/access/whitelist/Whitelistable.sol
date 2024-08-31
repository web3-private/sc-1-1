/**
 * SPDX-License-Identifier: MIT
 *
 * Copyright (c) 2018 zOS Global Limited.
 * Copyright (c) 2018-2020 CENTRE SECZ
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


pragma solidity ^0.8.0;

import { JDSCOwnable } from "../JDSCOwnable.sol";

/**
 * @title Whitelistable Token
 * @dev Allows accounts to be whitelisted by a "whitelister" role
 */
abstract contract Whitelistable is JDSCOwnable {
    address public whitelister;
    // mapping(address => bool) internal _deprecatedWhitelisted;

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
    function updateWhitelister(address _newWhitelister) external onlyOwner {
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
