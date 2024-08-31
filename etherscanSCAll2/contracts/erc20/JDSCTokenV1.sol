/**
 * SPDX-License-Identifier: Apache-2.0
 *
 * Copyright (c) 2023, Circle Internet Financial, LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity ^0.8.0;

import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { AbstractJDSCToken } from "./AbstractJDSCToken.sol";
import { JDSCOwnable } from "../access/JDSCOwnable.sol";
import { JDSCPausable } from "../security/JDSCPausable.sol";
import { Rescuable } from "../rescue/Rescuable.sol";
import { EIP3009 } from "../eip/EIP3009.sol";
import { EIP2612 } from "../eip/EIP2612.sol";
import { EIP712 } from "../eip/EIP712.sol";
import { EIP712Domain } from "../eip/EIP712Domain.sol"; 

import { Blacklistable } from "../access/blacklist/Blacklistable.sol";
import { Whitelistable } from "../access/whitelist/Whitelistable.sol";


/**
 * @title JDSCToken
 * @dev ERC20 Token backed by JDSC reserves
 */
contract JDSCTokenV1 is AbstractJDSCToken, EIP3009, EIP2612, JDSCPausable, Rescuable, Blacklistable, Whitelistable {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    string public currency;
    address public masterMinter;
    bool internal initialized;

    /// @dev A mapping that stores the balance and blacklist states for a given address.
    /// The first bit defines whether the address is blacklisted (1 if blacklisted, 0 otherwise).
    /// The last 255 bits define the balance for the address.
    mapping(address => uint256) internal balanceAndBlacklistStates;
    mapping(address => uint256) internal balanceAndWhitelistStates;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint256 internal totalSupply_ = 0;
    mapping(address => bool) internal minters;
    mapping(address => uint256) internal minterAllowed;

    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);
    event MinterConfigured(address indexed minter, uint256 minterAllowedAmount);
    event MinterRemoved(address indexed oldMinter);
    event MasterMinterChanged(address indexed newMasterMinter);

    uint8 internal _initializedVersion;
    
    /**
     * @notice Initializes the JDSC token contract.
     * @param tokenName       The name of the JDSC token.
     * @param tokenSymbol     The symbol of the JDSC token.
     * @param tokenCurrency   The JDSC currency that the token represents.
     * @param tokenDecimals   The number of decimals that the token uses.
     * @param newMasterMinter The masterMinter address for the JDSC token.
     * @param newPauser       The pauser address for the JDSC token.
     * @param newBlacklister  The blacklister address for the JDSC token.
     * @param newOwner        The owner of the JDSC token.
     */
    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        string memory tokenCurrency,
        uint8 tokenDecimals,
        uint256 tokenSupply,
        address newMasterMinter,
        address newPauser,
        address newBlacklister,
        address newOwner
    ) public {
        require(!initialized, "JDSCToken: contract is already initialized");
        require(
            newMasterMinter != address(0),
            "JDSCToken: new masterMinter is the zero address"
        );
        require(
            newPauser != address(0),
            "JDSCToken: new pauser is the zero address"
        );
        require(
            newBlacklister != address(0),
            "JDSCToken: new blacklister is the zero address"
        );
        require(
            newOwner != address(0),
            "JDSCToken: new owner is the zero address"
        );

        name = tokenName;
        symbol = tokenSymbol;
        currency = tokenCurrency;
        decimals = tokenDecimals;
        masterMinter = newMasterMinter;
        pauser = newPauser;
        blacklister = newBlacklister;
        setOwner(newOwner);
        initialized = true;
        initializeV1_1(tokenName);
        
        _mint(newOwner, tokenSupply);

    }

    function initializeV1_1(string memory newName) internal {
        require(initialized && _initializedVersion == 0);
        _DEPRECATED_CACHED_DOMAIN_SEPARATOR = EIP712.makeDomainSeparator(
            newName,
            "1"
        );
        _initializedVersion = 1;
    }

    /**
     * @notice Version string for the EIP712 domain separator
     * @return Version string
     */
    function version() external pure returns (string memory) {
        return "1";
    }

    /**
     * @dev Internal function to get the current chain id.
     * @return The current chain id.
     */
    function _chainId() internal virtual view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    /**
     * @inheritdoc EIP712Domain
     */
    function _domainSeparator() internal override view returns (bytes32) {
        return EIP712.makeDomainSeparator(name, "2", _chainId());
    }

    /**
     * @dev Throws if called by any account other than a minter.
     */
    modifier onlyMinters() {
        require(minters[msg.sender], "JDSCToken: caller is not a minter");
        _;
    }

    // /**
    //  * @notice Mints JDSC tokens to an address.
    //  * @param _to The address that will receive the minted tokens.
    //  * @param _amount The amount of tokens to mint. Must be less than or equal
    //  * to the minterAllowance of the caller.
    //  * @return True if the operation was successful.
    //  */
    // function mint(address _to, uint256 _amount)
    //     external
    //     whenNotPaused
    //     onlyMinters
    //     notBlacklisted(msg.sender)
    //     notBlacklisted(_to)
    //     returns (bool)
    // {
    //     // require(_to != address(0), "JDSCToken: mint to the zero address");
    //     // require(_amount > 0, "JDSCToken: mint amount not greater than 0");

    //     // uint256 mintingAllowedAmount = minterAllowed[msg.sender];
    //     // require(
    //     //     _amount <= mintingAllowedAmount,
    //     //     "JDSCToken: mint amount exceeds minterAllowance"
    //     // );

    //     // totalSupply_ = totalSupply_.add(_amount);
    //     // _setBalance(_to, _balanceOf(_to).add(_amount));
    //     // minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
    //     // emit Mint(msg.sender, _to, _amount);
    //     // emit Transfer(address(0), _to, _amount);
    //     // return true;
    //     require(_to != address(0), "JDSCToken: mint to the zero address");
    //     require(_amount > 0, "JDSCToken: mint amount not greater than 0");

    //     uint256 mintingAllowedAmount = minterAllowed[msg.sender];
    //     require(
    //         _amount <= mintingAllowedAmount,
    //         "JDSCToken: mint amount exceeds minterAllowance"
    //     );

    //     _mint(_to, _amount);
    //     minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
    // }

    function _mint(address _to, uint256 _amount)
        internal
        returns (bool)
    {
        totalSupply_ = totalSupply_.add(_amount);
        _setBalance(_to, _balanceOf(_to).add(_amount));
        // minterAllowed[msg.sender] = mintingAllowedAmount.sub(_amount);
        emit Mint(msg.sender, _to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Throws if called by any account other than the masterMinter
     */
    modifier onlyMasterMinter() {
        require(
            msg.sender == masterMinter,
            "JDSCToken: caller is not the masterMinter"
        );
        _;
    }

    /**
     * @notice Gets the minter allowance for an account.
     * @param minter The address to check.
     * @return The remaining minter allowance for the account.
     */
    function minterAllowance(address minter) external view returns (uint256) {
        return minterAllowed[minter];
    }

    /**
     * @notice Checks if an account is a minter.
     * @param account The address to check.
     * @return True if the account is a minter, false if the account is not a minter.
     */
    function isMinter(address account) external view returns (bool) {
        return minters[account];
    }

    /**
     * @notice Gets the remaining amount of JDSC tokens a spender is allowed to transfer on
     * behalf of the token owner.
     * @param owner   The token owner's address.
     * @param spender The spender's address.
     * @return The remaining allowance.
     */
    function allowance(address owner, address spender)
        external
        override
        view
        returns (uint256)
    {
        return allowed[owner][spender];
    }

    /**
     * @notice Gets the totalSupply of the JDSC token.
     * @return The totalSupply of the JDSC token.
     */
    function totalSupply() external override view returns (uint256) {
        return totalSupply_;
    }

    /**
     * @notice Gets the JDSC token balance of an account.
     * @param account  The address to check.
     * @return balance The JDSC token balance of the account.
     */
    function balanceOf(address account)
        external
        override
        view
        returns (uint256)
    {
        return _balanceOf(account);
    }

    /**
     * @notice Sets a JDSC token allowance for a spender to spend on behalf of the caller.
     * @param spender The spender's address.
     * @param value   The allowance amount.
     * @return True if the operation was successful.
     */
    function approve(address spender, uint256 value)
        external
        virtual
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(spender)
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Internal function to set allowance.
     * @param owner     Token owner's address.
     * @param spender   Spender's address.
     * @param value     Allowance amount.
     */
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal override {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @notice Transfers tokens from an address to another by spending the caller's allowance.
     * @dev The caller must have some JDSC token allowance on the payer's tokens.
     * @param from  Payer's address.
     * @param to    Payee's address.
     * @param value Transfer amount.
     * @return True if the operation was successful.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(from)
        notBlacklisted(to)
        returns (bool)
    {
        require(
            value <= allowed[from][msg.sender],
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(from, to, value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        return true;
    }

    /**
     * @notice Transfers tokens from the caller.
     * @param to    Payee's address.
     * @param value Transfer amount.
     * @return True if the operation was successful.
     */
    function transfer(address to, uint256 value)
        external
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Internal function to process transfers.
     * @param from  Payer's address.
     * @param to    Payee's address.
     * @param value Transfer amount.
     */
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            value <= _balanceOf(from),
            "ERC20: transfer amount exceeds balance"
        );

        _setBalance(from, _balanceOf(from).sub(value));
        _setBalance(to, _balanceOf(to).add(value));
        emit Transfer(from, to, value);
    }

    /**
     * @notice Adds or updates a new minter with a mint allowance.
     * @param minter The address of the minter.
     * @param minterAllowedAmount The minting amount allowed for the minter.
     * @return True if the operation was successful.
     */
    function configureMinter(address minter, uint256 minterAllowedAmount)
        external
        whenNotPaused
        onlyMasterMinter
        returns (bool)
    {
        minters[minter] = true;
        minterAllowed[minter] = minterAllowedAmount;
        emit MinterConfigured(minter, minterAllowedAmount);
        return true;
    }

    /**
     * @notice Removes a minter.
     * @param minter The address of the minter to remove.
     * @return True if the operation was successful.
     */
    function removeMinter(address minter)
        external
        onlyMasterMinter
        returns (bool)
    {
        minters[minter] = false;
        minterAllowed[minter] = 0;
        emit MinterRemoved(minter);
        return true;
    }

    /**
     * @notice Allows a minter to burn some of its own tokens.
     * @dev The caller must be a minter, must not be blacklisted, and the amount to burn
     * should be less than or equal to the account's balance.
     * @param _amount the amount of tokens to be burned.
     */
    function burn(uint256 _amount)
        external
        whenNotPaused
        onlyMinters
        notBlacklisted(msg.sender)
    {
        uint256 balance = _balanceOf(msg.sender);
        require(_amount > 0, "JDSCToken: burn amount not greater than 0");
        require(balance >= _amount, "JDSCToken: burn amount exceeds balance");

        totalSupply_ = totalSupply_.sub(_amount);
        _setBalance(msg.sender, balance.sub(_amount));
        emit Burn(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
    }

    /**
     * @notice Updates the master minter address.
     * @param _newMasterMinter The address of the new master minter.
     */
    function updateMasterMinter(address _newMasterMinter) external onlyOwner {
        require(
            _newMasterMinter != address(0),
            "JDSCToken: new masterMinter is the zero address"
        );
        masterMinter = _newMasterMinter;
        emit MasterMinterChanged(masterMinter);
    }

    /**
     * @inheritdoc Blacklistable
     */
    function _blacklist(address _account) internal override {
        _setBlacklistState(_account, true);
    }

    /**
     * @inheritdoc Blacklistable
     */
    function _unBlacklist(address _account) internal override {
        _setBlacklistState(_account, false);
    }

    /**
     * @dev Helper method that sets the blacklist state of an account on balanceAndBlacklistStates.
     * If _shouldBlacklist is true, we apply a (1 << 255) bitmask with an OR operation on the
     * account's balanceAndBlacklistState. This flips the high bit for the account to 1,
     * indicating that the account is blacklisted.
     *
     * If _shouldBlacklist if false, we reset the account's balanceAndBlacklistStates to their
     * balances. This clears the high bit for the account, indicating that the account is unblacklisted.
     * @param _account         The address of the account.
     * @param _shouldBlacklist True if the account should be blacklisted, false if the account should be unblacklisted.
     */
    function _setBlacklistState(address _account, bool _shouldBlacklist)
        internal
    {
        balanceAndBlacklistStates[_account] = _shouldBlacklist
            ? balanceAndBlacklistStates[_account] | (1 << 255)
            : _balanceOf(_account);
    }

    /**
     * @dev Helper method that sets the balance of an account on balanceAndBlacklistStates.
     * Since balances are stored in the last 255 bits of the balanceAndBlacklistStates value,
     * we need to ensure that the updated balance does not exceed (2^255 - 1).
     * Since blacklisted accounts' balances cannot be updated, the method will also
     * revert if the account is blacklisted
     * @param _account The address of the account.
     * @param _balance The new JDSC token balance of the account (max: (2^255 - 1)).
     */
    function _setBalance(address _account, uint256 _balance) internal {
        require(
            _balance <= ((1 << 255) - 1),
            "JDSCTokenV1: Balance exceeds (2^255 - 1)"
        );
        require(
            !_isBlacklisted(_account),
            "JDSCToken1: Account is blacklisted"
        );

        balanceAndBlacklistStates[_account] = _balance;
    }

    /**
     * @inheritdoc Blacklistable
     */
    function _isBlacklisted(address _account)
        internal
        override
        view
        returns (bool)
    {
        return balanceAndBlacklistStates[_account] >> 255 == 1;
    }

    // /**
    //  * @dev Helper method to obtain the balance of an account.
    //  * @param _account  The address of the account.
    //  * @return          The JDSC token balance of the account.
    //  */
    // function _balanceOf(address _account)
    //     internal
    //     virtual
    //     view
    //     returns (uint256)
    // {
    //     return balanceAndBlacklistStates[_account];
    // }

   /**
     * @dev Helper method to obtain the balance of an account. Since balances
     * are stored in the last 255 bits of the balanceAndBlacklistStates value,
     * we apply a ((1 << 255) - 1) bit bitmask with an AND operation on the
     * balanceAndBlacklistState to obtain the balance.
     * @param _account  The address of the account.
     * @return          The JDSC token balance of the account.
     */
    function _balanceOf(address _account)
        internal
        view
        returns (uint256)
    {
        return balanceAndBlacklistStates[_account] & ((1 << 255) - 1);
    }
 
    /** JDSCTokenV2
     * @notice Increase the allowance by a given increment
     * @param spender   Spender's address
     * @param increment Amount of increase in allowance
     * @return True if successful
     */
    function increaseAllowance(address spender, uint256 increment)
        external
        virtual
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(spender)
        returns (bool)
    {
        _increaseAllowance(msg.sender, spender, increment);
        return true;
    }

    /**
     * @dev Internal function to increase the allowance by a given increment
     * @param owner     Token owner's address
     * @param spender   Spender's address
     * @param increment Amount of increase
     */
    function _increaseAllowance(
        address owner,
        address spender,
        uint256 increment
    ) internal override {
        _approve(owner, spender, allowed[owner][spender].add(increment));
    }


    /** JDSCTokenV2
     * @notice Decrease the allowance by a given decrement
     * @param spender   Spender's address
     * @param decrement Amount of decrease in allowance
     * @return True if successful
     */
    function decreaseAllowance(address spender, uint256 decrement)
        external
        virtual
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(spender)
        returns (bool)
    {
        _decreaseAllowance(msg.sender, spender, decrement);
        return true;
    }

    
    // /**JDSCTokenV2
    //  * @notice Execute a transfer with a signed authorization
    //  * @param from          Payer's address (Authorizer)
    //  * @param to            Payee's address
    //  * @param value         Amount to be transferred
    //  * @param validAfter    The time after which this is valid (unix time)
    //  * @param validBefore   The time before which this is valid (unix time)
    //  * @param nonce         Unique nonce
    //  * @param v             v of the signature
    //  * @param r             r of the signature
    //  * @param s             s of the signature
    //  */
    // function transferWithAuthorization(
    //     address from,
    //     address to,
    //     uint256 value,
    //     uint256 validAfter,
    //     uint256 validBefore,
    //     bytes32 nonce,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // ) 
    //     public 
    //     // external  
    //     whenNotPaused 
    //     notBlacklisted(from) 
    //     notBlacklisted(to) 
    // {
    //     _transferWithAuthorization(
    //         from,
    //         to,
    //         value,
    //         validAfter,
    //         validBefore,
    //         nonce,
    //         v,
    //         r,
    //         s
    //     );
    // }

    // /**
    //  * @notice Execute a transfer with a signed authorization
    //  * @dev EOA wallet signatures should be packed in the order of r, s, v.
    //  * @param from          Payer's address (Authorizer)
    //  * @param to            Payee's address
    //  * @param value         Amount to be transferred
    //  * @param validAfter    The time after which this is valid (unix time)
    //  * @param validBefore   The time before which this is valid (unix time)
    //  * @param nonce         Unique nonce
    //  * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
    //  */
    // function transferWithAuthorization(
    //     address from,
    //     address to,
    //     uint256 value,
    //     uint256 validAfter,
    //     uint256 validBefore,
    //     bytes32 nonce,
    //     bytes memory signature
    // ) 
    //     public
    //     // external 
    //     whenNotPaused 
    //     notBlacklisted(from) 
    //     notBlacklisted(to) 
    // {
    //     _transferWithAuthorization(
    //         from,
    //         to,
    //         value,
    //         validAfter,
    //         validBefore,
    //         nonce,
    //         signature
    //     );
    // }


    /**
     * @notice Receive a transfer with a signed authorization from the payer
     * @dev This has an additional check to ensure that the payee's address
     * matches the caller of this function to prevent front-running attacks.
     * @param from          Payer's address (Authorizer)
     * @param to            Payee's address
     * @param value         Amount to be transferred
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param v             v of the signature
     * @param r             r of the signature
     * @param s             s of the signature
     */
    function receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) 
        external 
        whenNotPaused 
        notBlacklisted(from)
        notBlacklisted(to) 
    {
        _receiveWithAuthorization(
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    /**
     * @notice Receive a transfer with a signed authorization from the payer
     * @dev This has an additional check to ensure that the payee's address
     * matches the caller of this function to prevent front-running attacks.
     * EOA wallet signatures should be packed in the order of r, s, v.
     * @param from          Payer's address (Authorizer)
     * @param to            Payee's address
     * @param value         Amount to be transferred
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
     */
    function receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes memory signature
    ) 
        external 
        whenNotPaused 
        notBlacklisted(from) 
        notBlacklisted(to) 
    {
        _receiveWithAuthorization(
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            signature
        );
    }

    /**
     * @notice Attempt to cancel an authorization
     * @dev Works only if the authorization is not yet used.
     * @param authorizer    Authorizer's address
     * @param nonce         Nonce of the authorization
     * @param v             v of the signature
     * @param r             r of the signature
     * @param s             s of the signature
     */
    function cancelAuthorization(
        address authorizer,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) 
        external 
        whenNotPaused 
    {
        _cancelAuthorization(authorizer, nonce, v, r, s);
    }

    /**
     * @notice Attempt to cancel an authorization
     * @dev Works only if the authorization is not yet used.
     * EOA wallet signatures should be packed in the order of r, s, v.
     * @param authorizer    Authorizer's address
     * @param nonce         Nonce of the authorization
     * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
     */
    function cancelAuthorization(
        address authorizer,
        bytes32 nonce,
        bytes memory signature
    ) 
        external 
        whenNotPaused 
    {
        _cancelAuthorization(authorizer, nonce, signature);
    }

    /**
     * @notice Update allowance with a signed permit
     * @dev EOA wallet signatures should be packed in the order of r, s, v.
     * @param owner       Token owner's address (Authorizer)
     * @param spender     Spender's address
     * @param value       Amount of allowance
     * @param deadline    The time at which the signature expires (unix time), or max uint256 value to signal no expiration
     * @param signature   Signature bytes signed by an EOA wallet or a contract wallet
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        bytes memory signature
    ) 
        external 
        virtual
        whenNotPaused
        notBlacklisted(owner)
        notBlacklisted(spender)
    {
        _permit(owner, spender, value, deadline, signature);
    }


    /**
     * @notice Update allowance with a signed permit
     * @param owner       Token owner's address (Authorizer)
     * @param spender     Spender's address
     * @param value       Amount of allowance
     * @param deadline    The time at which the signature expires (unix time), or max uint256 value to signal no expiration
     * @param v           v of the signature
     * @param r           r of the signature
     * @param s           s of the signature
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        virtual
        whenNotPaused
        notBlacklisted(owner)
        notBlacklisted(spender)
    {
        _permit(owner, spender, value, deadline, v, r, s);
    }

    /**
     * @dev Internal function to decrease the allowance by a given decrement
     * @param owner     Token owner's address
     * @param spender   Spender's address
     * @param decrement Amount of decrease
     */
    function _decreaseAllowance(
        address owner,
        address spender,
        uint256 decrement
    ) internal override {
        _approve(
            owner,
            spender,
            allowed[owner][spender].sub(
                decrement,
                "ERC20: decreased allowance below zero"
            )
        );
    }

    /**
     * @inheritdoc Whitelistable
     */
    function _isWhitelisted(address _account)
        internal
        override
        view
        returns (bool)
    {
        return balanceAndWhitelistStates[_account] >> 255 == 1;
    }

    /**
     * @inheritdoc Whitelistable
     */
    function _whitelist(address _account) internal override {
        _setWhitelistState(_account, true);
    }

    /**
     * @inheritdoc Whitelistable
     */
    function _unWhitelist(address _account) internal override {
        _setWhitelistState(_account, false);
    }

    function _setWhitelistState(address _account, bool _shouldWhitelist)
        internal
    {
        balanceAndWhitelistStates[_account] = _shouldWhitelist
            ? balanceAndWhitelistStates[_account] | (1 << 255)
            : _balanceOf(_account);
    }
}
