// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20BurnableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

// import {IAccessManager} from "@openzeppelin/contracts/contracts/access/manager/IAccessManager.sol";
// import {IAccessManaged} from "@openzeppelin/contracts/contracts/access/manager/IAccessManaged.sol";
// // import { AccessControlDefaultAdminRulesUpgradeable } from "@openzeppelin/contracts-upgradeable@5.0.2/access/extensions/AccessControlDefaultAdminRulesUpgradeable.sol";
// import {AccessManagerUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagerUpgradeable.sol";
// import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {StringsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import {AccessManager} from "./AccessManager.sol";
import {MinterableTemp} from "./MinterableTemp.sol";
// import {FeeProxy} from "./interfaces/FeeProxy.sol";
import {FeeV1Interface} from "./interfaces/FeeV1Interface.sol";
// import { Blacklistable } from "./Blacklistable.sol";

contract TokenBaseUpgradeableTemp is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    OwnableUpgradeable,
    ERC20PermitUpgradeable,
    AccessControlUpgradeable,
    AccessManager,
    MinterableTemp
{
    uint8 internal _decimals;
    string public currency;

    FeeV1Interface private feeInterface;

    // 初始化函数，替代构造函数
    function initialize(string memory name_, string memory symbol_) public initializer {
        // function initialize(string memory name_, string memory symbol_, address feeContract) public initializer {
        __ERC20_init(name_, symbol_); // 初始化 ERC20 代币
        __ERC20Permit_init(name_); // 初始化 ERC20Permit
        __ERC20Burnable_init(); //初始化  ERC20Burn
        __ERC20Pausable_init(); // 初始化可暂停功能
        __Ownable_init(); // 初始化所有权管理

        __AccessControl_init(); // 初始化访问权限管理
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setRoleAdmin(ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(BLACKLISTER_MANAGER_ROLE, _msgSender());
        _setupRole(WHITELISTER_MANAGER_ROLE, _msgSender());
        _setupRole(MASTER_MINTER_ROLE, _msgSender());
        _setupRole(FEE_MANAFER_ROLE, _msgSender());

        // //初始化手续费合约地址
        // feeInterface = FeeV1Interface(feeContract);
    }

    function updateFeeContract(address feeContract) public virtual returns (bool) {
        feeInterface = FeeV1Interface(feeContract);
        return true;
    }

    function totalFee(address _account) external view returns (uint256) {
        return feeInterface.totalFee(_account);
    }

    function calcCommonFee(uint256 _value) public view returns (uint256) {
        return feeInterface.calcCommonFee(_value);
    }

    function commonFeeAccount() public view returns (address) {
        return feeInterface.commonFeeAccount();
    }

    function calcFee(address account, uint256 _value) public view returns (uint256 _fee) {
        return feeInterface.calcFee(account, _value);
    }

    function _accessHasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return hasRole(role, account);
    }

    function _checkNotRole(bytes32 role, address account) internal view virtual {
        if (hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(account),
                        " is role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    //币种
    function updateCurrency(string memory _currency) public virtual {
        currency = _currency;
    }

    //精度
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    //重写精度
    function updateDecimals(uint8 upDecimals) public virtual returns (bool) {
        _decimals = upDecimals;
        return true;
    }

    // 只有所有者可以铸造代币
    function mint(address to, uint256 amount) public whenNotPaused {
        _checkRole(MINTER_ROLE, _msgSender());
        super._mint(to, amount);
    }

    function burn(address account, uint256 amount) public whenNotPaused {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to burn from account");
        super._burn(account, amount);
    }

    function burn(uint256 amount) public virtual override whenNotPaused {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to burn from account");
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public virtual override whenNotPaused {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to burn from account");
        super.burnFrom(account, amount);
    }

    function transfer(
        address to,
        uint256 amount
    )
        public
        virtual
        override
        whenNotPaused //合约暂停校验
        returns (
            // notBlacklisted(from) //黑名单校验
            // notBlacklisted(to) //黑名单校验
            // whitelisted(from) //白名单校验
            // whitelisted(to) //白名单校验
            bool
        )
    {
        // _checkRole(WHITELISTER_ROLE, _msgSender());
        // _checkRole(WHITELISTER_ROLE, to);

        // _checkNotRole(BLACKLISTER_ROLE, _msgSender());
        // _checkNotRole(BLACKLISTER_ROLE, to);

        super.transfer(to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        virtual
        override
        whenNotPaused //合约暂停校验
        returns (
            // notBlacklisted(from) //黑名单校验
            // notBlacklisted(to) //黑名单校验
            // whitelisted(from) //白名单校验
            // whitelisted(to) //白名单校验
            bool
        )
    {
        // _checkRole(WHITELISTER_ROLE, _msgSender());
        // _checkRole(WHITELISTER_ROLE, to);

        // _checkNotRole(BLACKLISTER_ROLE, _msgSender());
        // _checkNotRole(BLACKLISTER_ROLE, to);

        super.transferFrom(from, to, amount);
        return true;
    }

    // 只有所有者可以暂停合约，并且调用者拥有暂停者角色
    function pause()
        public
        whenNotPaused // onlyOwner
    {
        require(hasRole(PAUSER_ROLE, _msgSender()), "TokenBaseUpgradeableTemp: must have pauser role to pause");
        _pause();
    }

    // 只有所有者可以取消暂停合约，并且调用者拥有暂停者角色
    function unpause()
        public
        whenPaused // onlyOwner
    {
        require(hasRole(PAUSER_ROLE, _msgSender()), "TokenBaseUpgradeableTemp: must have pauser role to unpause");
        _unpause();
    }

    // 在代币转移之前调用，用于检查是否处于暂停状态等
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    // 显式覆盖 _disableInitializers 方法
    function _disableInitializers() internal override {
        super._disableInitializers();
    }

    // 扩展 ERC20 功能，支持批准和调用功能
    function approveAndCall(address spender, uint256 amount, bytes memory data) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        (bool success, ) = spender.call(data);
        require(success, "Call to spender failed");
        return true;
    }

    // 批量转账功能
    function batchTransfer(address[] memory recipients, uint256[] memory amounts) public {
        require(recipients.length == amounts.length, "Recipients and amounts length mismatch");
        for (uint256 i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
    }

    function configureMinter(
        address minter,
        uint256 minterAllowedAmount
    ) external virtual override onlyMasterMinter returns (bool) {
        _setupRole(MINTER_ROLE, minter);
        minterAllowed[minter] = minterAllowedAmount;
        emit MinterConfigured(minter, minterAllowedAmount);
        return true;
    }

    function removeMinter(address minter) external override onlyMasterMinter returns (bool) {
        _revokeRole(MINTER_ROLE, minter);
        minterAllowed[minter] = 0;
        emit MinterRemoved(minter);
        return true;
    }

    function updateMasterMinter(address _newMasterMinter) public virtual override {
        require(_newMasterMinter != address(0), "Minterable: new masterMinter is the zero address");
        _setupRole(MASTER_MINTER_ROLE, _newMasterMinter);
        emit MasterMinterChanged(_newMasterMinter);
    }
}
