// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PermitUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20PausableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import {AccessManager} from "./AccessManager.sol";
import {Minterable} from "./Minterable.sol";

import {FeeV1Interface} from "./interfaces/FeeV1Interface.sol";
import {FeeAggregator} from "./interfaces/FeeAggregator.sol";

import {Blacklistable} from "./Blacklistable.sol";

/**
 * @title The base contract.
 * @author Asan
 * @notice This is an ERC20-compliant JDSC stablecoin base contract.
 * @dev It implements some basic token functions and is upgradable.
 */
contract TokenBaseUpgradeable is
    ERC20PausableUpgradeable,
    OwnableUpgradeable,
    ERC20PermitUpgradeable,
    AccessControlUpgradeable,
    Blacklistable,
    Minterable,
    FeeAggregator
{
    //token decimals.
    uint8 internal _decimals;

    /**
     * @dev The initialization function is called for the first time after the contract is deployed.
     * @param initialOwner initialize the address of the owner account.
     * @param name_ Token name.
     * @param symbol_ Token symbol.
     * @param decimals_ Token decimals.
     */
    function initialize(address initialOwner, string memory name_, string memory symbol_, uint8 decimals_)
        public
        initializer
    {
        __ERC20_init(name_, symbol_);
        __ERC20Permit_init(name_);
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);

        __AccessControl_init();

        _decimals = decimals_;

        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
        _grantRole(ADMIN_ROLE, initialOwner);
    }

    /**
     * @notice Set role manager.
     * @dev Set role manager, only the owner role is invoked.
     * @param role Managed role.
     * @param admin Manager role.
     */
    function setRoleAdmin(bytes32 role, bytes32 admin) public virtual onlyOwner {
        _setRoleAdmin(role, admin);
    }

    /**
     * @notice Check whether the current account address has a role role.
     * @dev Check whether the current account address has a role role.
     * metamask will be used when calling the transfer function.
     * @param role current role.
     * @param account Enter account address.
     * @return Return the verification result of the account address.
     */
    function _accessHasRole(bytes32 role, address account) internal view virtual override returns (bool) {
        return super.hasRole(role, account);
    }

    /**
     * @notice Query token accuracy.
     * @dev Query token accuracy.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @notice The contract pause function needs to have the pause role.
     * @dev The contract pause function needs to have the pause role.
     */
    function pause() public whenNotPaused {
        require(hasRole(PAUSER_ROLE, _msgSender()), "TokenBaseUpgradeable: must have pauser role to pause");
        super._pause();
    }

    /**
     * @notice The contract unsuspend function needs to have the suspend role
     * @dev The contract unsuspend function needs to have the suspend role
     */
    function unpause() public whenPaused {
        require(hasRole(PAUSER_ROLE, _msgSender()), "TokenBaseUpgradeable: must have pauser role to unpause");
        super._unpause();
    }

    /**
     * @notice This function inherits from ERC20Upgradeable and ERC20PausableUpgradeable
     */
    function _update(address from, address to, uint256 value)
        internal
        virtual
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        super._update(from, to, value);
    }

    /**
     * @inheritdoc ERC20Upgradeable
     */
    function approve(address spender, uint256 value)
        public
        virtual
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(spender)
        returns (bool)
    {
        super.approve(spender, value);
        return true;
    }

    /**
     * @notice The ’owner‘ lets ‘spender’ spend its Mintable amount.
     * @dev The ’owner‘ lets ‘spender’ spend its Mintable amount.
     * @param minter minter address;
     * @param amount minter can mint the amount;
     */
    function approveMint(address minter, uint256 amount)
        external
        virtual
        whenNotPaused
        onlyMasterMinter
        returns (bool)
    {
        super._checkRole(MINTER_ROLE, minter);
        super._approveMint(minter, amount);
        return true;
    }

    /**
     * @notice Add the input address to the minter role and configure the Mintable amount.
     * @dev Add the input address to the minter role and configure the Mintable amount.Only called by the person who has the master minter role.
     * @param minter  minter address.
     * @param amount  configure the Mintable amount.
     * @inheritdoc Minterable
     * @dev Emits a {ConfigureMinter} event.
     */
    function addMinter(address minter, uint256 amount)
        external
        virtual
        override
        whenNotPaused
        onlyMasterMinter
        returns (bool)
    {
        require(minter != address(0), "TokenBaseUpgradeable: new addMinter is the zero address");

        super._grantRole(MINTER_ROLE, minter);
        super._approveMint(minter, amount);
        emit ConfigureMinter(minter, amount);
        return true;
    }

    /**
     * @notice Remove the minter address from the minter role.
     * @dev Remove the minter address from the minter role.Only called by the person who has the master minter role.
     * @param minter  minter address.
     * @return Return removal result.
     * @inheritdoc Minterable
     * @dev Emits a {RemoveMinter} event.
     */
    function removeMinter(address minter) external override onlyMasterMinter returns (bool) {
        super._revokeRole(MINTER_ROLE, minter);
        emit RemoveMinter(minter);
        return true;
    }

    /**
     * @notice Update the master minter account address.
     * @dev Update the master minter account address. Only called by the person who has the master minter role.
     * @param _newManager entered master minter address.
     * @inheritdoc Minterable
     * @dev Emits a {UpdateMasterMinter} event.
     */
    function updateMasterMinter(address _newManager) public virtual override onlyOwner {
        require(_newManager != address(0), "TokenBaseUpgradeable: new masterMinter is the zero address");

        bool result = super._grantRole(MASTER_MINTER_ROLE, _newManager);
        if (result) {
            emit UpdateMasterMinter(_newManager);
        }
    }

    /**
     * @notice Updates the blacklistManager address.
     * @param _newManager The address of the new blacklistManager.
     * @inheritdoc Blacklistable
     */
    function updateBlacklistManager(address _newManager) public override onlyOwner {
        require(_newManager != address(0), "TokenBaseUpgradeable: new blacklist manager is the zero address");

        bool result = super._grantRole(BLACKLIST_MANAGER_ROLE, _newManager);
        if (result) {
            emit UpdateBlacklistManager(_newManager);
        }
    }

    /**
     * @dev Helper method that blacklists an account.
     * @param _account The address to blacklist.
     * @inheritdoc Blacklistable
     */
    function _addBlacklist(address _account) internal override {
        super._grantRole(BLACKLIST_MEMBER_ROLE, _account);
    }

    /**
     * @dev Helper method that unblacklists an account.
     * @param _account The address to unblacklist.
     * @inheritdoc Blacklistable
     */
    function _removeBlacklist(address _account) internal override {
        super._revokeRole(BLACKLIST_MEMBER_ROLE, _account);
    }

    /**
     * @dev Checks if account is blacklisted.
     * @param _account The address to check.
     * @return true if the account is blacklisted, false otherwise.
     * @inheritdoc Blacklistable
     */
    function _isBlacklisted(address _account) internal view override returns (bool) {
        return super.hasRole(BLACKLIST_MEMBER_ROLE, _account);
    }

    /**
     * @dev Add a fee account.
     * @param account fee account.
     * @return Return add result.
     */
    function addFeeAccount(address account) public onlyFeeManager returns (bool) {
        super._grantRole(FEE_HOLDER_ROLE, account);
        super._addFeeAccount(account, 0, 0);
        return true;
    }

    /**
     * @dev Remove a fee account.
     * @param account fee account.
     * @return Return remove result.
     */
    function removeFeeAccount(address account) public onlyFeeManager returns (bool) {
        super._checkRole(FEE_HOLDER_ROLE, account);
        super._removeFeeAccount(account);
        super._revokeRole(FEE_HOLDER_ROLE, account);
        return true;
    }

    /**
     * @notice Set common fee parameters.
     * @dev Set common fee parameters.
     * @param _feeAccount  fee account.
     * @param newBasisPoints Common fee rate.
     * @param newMaxFee Maximum processing rate for a single tx.
     * @param rateDecimals 1/n , For example: fee per thousand.
     * @return Set result return.
     */
    function setCommonParams(address _feeAccount, uint256 newBasisPoints, uint256 newMaxFee, uint8 rateDecimals)
        public
        onlyFeeManager
        returns (bool)
    {
        require(_feeAccount != address(0));
        super._checkRole(FEE_HOLDER_ROLE, _feeAccount);
        require(newBasisPoints < MAX_SETTABLE_FEE_RATE);
        require(newMaxFee < MAX_SETTABLE_FEE);

        super._setCommonParam(_feeAccount, newBasisPoints, newMaxFee, rateDecimals);
        super._addFeeAccount(_feeAccount, 0, newBasisPoints);

        return true;
    }

    /**
     * @notice setParams the JDSC token contract.
     * @param _feeAccount the token fee account.
     * @param newCommonRate the token fee ratio.
     * @param newMaxFee he token handling fees.
     * @return Set result return.
     */
    function setParams(address _feeAccount, uint256 newCommonRate, uint256 newMaxFee)
        public
        onlyFeeManager
        returns (bool)
    {
        require(_feeAccount != address(0));
        super._checkRole(FEE_HOLDER_ROLE, _feeAccount);
        require(newCommonRate < MAX_SETTABLE_FEE_RATE);
        require(newMaxFee < MAX_SETTABLE_FEE);

        super._addFeeAccount(_feeAccount, 0, newCommonRate);
        return true;
    }

    /**
     * @notice Calculate the fee.
     * @dev Calculate the fee.
     * Based on the account address and amount entered
     * @param _value amount entered
     * @return Return the calculated fee.
     */
    function calcFee(address account, uint256 _value) public view returns (uint256) {
        super._checkRole(FEE_HOLDER_ROLE, account);
        return super._calcFee(account, _value);
    }

    /**
     * @notice Update fee manager account address. Only called by the person who has the fee  manager role.
     * @dev Update fee manager account address. Only called by the person who has the fee  manager role.
     * @param account fee manager account.
     * @inheritdoc FeeAggregator
     * @dev Emits a {UpdateFeeManager} event.
     */
    function updateFeeManager(address account) external virtual override onlyOwner {
        require(account != address(0), "TokenBaseUpgradeable: new feeManager is the zero address");

        bool result = super._grantRole(FEE_MANAGER_ROLE, account);
        if (result) {
            emit UpdateFeeManager(account);
        }
    }

    /**
     * @notice Check whether the caller is a fee manager.
     * @dev Check whether the caller is a fee manager.
     */
    function _checkOnlyFeeManager() internal view virtual override {
        require(_accessHasRole(FEE_MANAGER_ROLE, msg.sender), "FeeAggregator: caller is not the feeManager");
    }

    /**
     * @notice Input address is contract address check.
     * @dev Input address is contract address check.
     */
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
