// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

// import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {AccessManager} from "./AccessManager.sol";
import {Minterable} from "./Minterable.sol";

// import {FeeV1Interface} from "./interfaces/FeeV1Interface.sol";
import {FeeAggregator} from "./interfaces/FeeAggregator.sol";
import {TimeLock} from "./interfaces/TimeLock.sol";

import {Blacklistable} from "./Blacklistable.sol";

contract TokenBaseUpgradeable is
    ERC20PausableUpgradeable,
    OwnableUpgradeable,
    ERC20PermitUpgradeable,
    AccessControlEnumerableUpgradeable,
    Blacklistable,
    Minterable,
    FeeAggregator,
    TimeLock
{
    uint8 internal _decimals;

    // 初始化函数，替代构造函数
    function initialize(
        address initialOwner,
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) public initializer {
        __ERC20_init(name_, symbol_); // 初始化 ERC20 代币
        __ERC20Permit_init(name_); // 初始化 ERC20Permit
        __ERC20Pausable_init(); // 初始化可暂停功能
        __Ownable_init(initialOwner); // 初始化所有权管理

        __AccessControl_init(); // 初始化访问权限管理

        _decimals = decimals_; //设置精度

        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
        _grantRole(ADMIN_ROLE, initialOwner);
    }

    function setRoleAdmin(bytes32 role, bytes32 admin) public virtual onlyOwner {
        _setRoleAdmin(role, admin);
    }

    function _accessHasRole(bytes32 role, address account) internal view virtual override returns (bool) {
        return super.hasRole(role, account);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function transfer(address to, uint256 amount) public virtual override whenNotPaused returns (bool) {
        super.transfer(to, amount);
        return true;
    }

    function pause() public whenNotPaused {
        require(hasRole(PAUSER_ROLE, _msgSender()), "TokenBaseUpgradeable: must have pauser role to pause");
        super._pause();
    }

    function unpause() public whenPaused {
        require(hasRole(PAUSER_ROLE, _msgSender()), "TokenBaseUpgradeable: must have pauser role to unpause");
        super._unpause();
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._update(from, to, value);
    }

    function approve(
        address spender,
        uint256 value
    ) public virtual override whenNotPaused notBlacklisted(_msgSender()) notBlacklisted(spender) returns (bool) {
        super.approve(spender, value);
        return true;
    }

    /**
     * The ’owner‘ lets ‘spender’ spend its Mintable amount
     */
    function approveMint(
        address minter,
        uint256 amount
    ) external virtual whenNotPaused onlyMasterMinter returns (bool) {
        super._checkRole(MINTER_ROLE, minter);
        super._approveMint(minter, amount);
        return true;
    }

    function addMinter(
        address minter,
        uint256 amount
    ) external virtual override whenNotPaused onlyMasterMinter returns (bool) {
        require(!isContract(minter), "TokenBaseUpgradeable: addMinter is the contract");
        super._grantRole(MINTER_ROLE, minter);
        super._approveMint(minter, amount);
        emit MinterConfigured(minter, amount);
        return true;
    }

    function removeMinter(address minter) external override onlyMasterMinter returns (bool) {
        super._revokeRole(MINTER_ROLE, minter);
        emit MinterRemoved(minter);
        return true;
    }

    function updateMasterMinter(address _newMasterMinter) public virtual override onlyOwner {
        require(_newMasterMinter != address(0), "TokenBaseUpgradeable: new masterMinter is the zero address");
        require(!isContract(_newMasterMinter), "TokenBaseUpgradeable: new masterMinter is the contract");

        if (_newMasterMinter != super.getRoleMember(MASTER_MINTER_ROLE, uint256(0))) {
            _grantRole(MASTER_MINTER_ROLE, _newMasterMinter);
            emit MasterMinterChanged(_newMasterMinter);
        }
    }

    function updateBlacklister(address _newBlacklister) public override onlyOwner {
        require(_newBlacklister != address(0), "TokenBaseUpgradeable: new blacklister is the zero address");
        require(!isContract(_newBlacklister), "TokenBaseUpgradeable: new blacklister is the contract");

        if (_newBlacklister != super.getRoleMember(BLACKLISTER_MANAGER_ROLE, uint256(0))) {
            super._grantRole(BLACKLISTER_MANAGER_ROLE, _newBlacklister);
            emit BlacklisterChanged(_newBlacklister);
        }
    }

    function _blacklist(address _account) internal override {
        super._grantRole(BLACKLISTER_ROLE, _account);
    }

    function _unBlacklist(address _account) internal override {
        super._revokeRole(BLACKLISTER_ROLE, _account);
    }

    function _isBlacklisted(address _account) internal view override returns (bool) {
        return super.hasRole(BLACKLISTER_ROLE, _account);
    }

    function addFeeAccount(address account) public onlyFeeManager returns (bool) {
        super._grantRole(FEE_HOLDER_ROLE, account);
        _addFeeAccount(account, 0, 0);
        return true;
    }
    function removeFeeAccount(address account) public onlyFeeManager returns (bool) {
        // _checkOnlyFeeHolder(account);
        super._checkRole(FEE_HOLDER_ROLE, account);
        super._removeFeeAccount(account);
        super._revokeRole(FEE_HOLDER_ROLE, account);
        return true;
    }

    /**
     * @notice setParams the JDSC token contract.
     * @param newBasisPoints       the token fee ratio.
     * @param newMaxFee     the token handling fees.
     */
    function setParams(
        address _feeAccount,
        uint256 newBasisPoints,
        uint256 newMaxFee,
        uint8 rateDecimals,
        bool commonInit
    ) public onlyFeeManager returns (bool) {
        require(_feeAccount != address(0));
        super._checkRole(FEE_HOLDER_ROLE, _feeAccount);
        require(newBasisPoints < MAX_SETTABLE_BASIS_POINTS);
        require(newMaxFee < MAX_SETTABLE_FEE);

        if (commonInit) {
            super._setCommonParam(_feeAccount, newBasisPoints, newMaxFee, rateDecimals);
        }
        super._addFeeAccount(_feeAccount, 0, newBasisPoints);

        return true;
    }

    function calcFee(address account, uint256 _value) public view returns (uint256) {
        super._checkRole(FEE_HOLDER_ROLE, account);
        return super._calcFee(account, _value);
    }

    function updateFeeManager(address account) external virtual override onlyOwner {
        require(account != address(0), "TokenBaseUpgradeable: new feeManager is the zero address");
        require(!isContract(account), "TokenBaseUpgradeable: new feeManager is the contract");

        if (account != super.getRoleMember(FEE_MANAGER_ROLE, uint256(0))) {
            super._grantRole(FEE_MANAGER_ROLE, account);
        }
    }

    function _checkOnlyFeeManager() internal view virtual override {
        require(_accessHasRole(FEE_MANAGER_ROLE, msg.sender), "FeeAggregator: caller is not the feeManager");
    }

    function _timeLockStatus() internal view override returns (bool) {
        return timeLockStatus;
    }

    function updateTimeLockStatus(bool status) external virtual override returns (bool) {
        super._checkRole(ADMIN_ROLE, _msgSender());
        timeLockStatus = status;
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
