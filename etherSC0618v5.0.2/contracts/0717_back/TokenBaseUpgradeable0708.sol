// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {AccessManager0708} from "./AccessManager0708.sol";
import {Minterable0708} from "./Minterable0708.sol";

import {FeeV1Interface0708} from "./interfaces/FeeV1Interface0708.sol";
import {FeeAggregator0708} from "./interfaces/FeeAggregator0708.sol";

import {Blacklistable0708} from "./Blacklistable0708.sol";

contract TokenBaseUpgradeable0708 is
    ERC20PausableUpgradeable,
    OwnableUpgradeable,
    ERC20PermitUpgradeable,
    AccessControlUpgradeable,
    Blacklistable0708,
    Minterable0708,
    FeeAggregator0708
{
    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);

    uint8 internal _decimals;
    string public currency;

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

        _grantRole(PAUSER_ROLE, initialOwner);
        _setRoleAdmin(PAUSER_ROLE, ADMIN_ROLE);

        _grantRole(BLACKLISTER_MANAGER_ROLE, initialOwner);

        _setRoleAdmin(BLACKLISTER_ROLE, BLACKLISTER_MANAGER_ROLE);

        _grantRole(WHITELISTER_MANAGER_ROLE, initialOwner);

        _setRoleAdmin(WHITELISTER_ROLE, WHITELISTER_MANAGER_ROLE);

        _grantRole(MASTER_MINTER_ROLE, initialOwner);

        _setRoleAdmin(MINTER_ROLE, MASTER_MINTER_ROLE);

        _grantRole(FEE_MANAGER_ROLE, initialOwner);

        _setRoleAdmin(FEE_HOLDER_ROLE, FEE_MANAGER_ROLE);
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

    function burnFrom(address account, uint256 value) internal virtual whenNotPaused {
        //        super._spendAllowance(account, _msgSender(), value);
        super._burn(account, value);
    }

    function transfer(address to, uint256 amount) public virtual override whenNotPaused returns (bool) {
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
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(from)
        notBlacklisted(to)
        returns (
            // isAddressWhitelisted(_msgSender())
            // isAddressWhitelisted(from)
            // isAddressWhitelisted(to)
            bool
        )
    {
        // layer2 implementation

        // require(
        //     hasRole(OPERATOR_ROLE, _msgSender()),
        //     "TokenBaseUpgradeable: must have OPERATOR_ROLE role to operation"
        // );
        // super.transferFrom(from, to, amount);
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
    )
        public
        virtual
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(spender)
        returns (
            // notBlacklisted(to)
            // isAddressWhitelisted(_msgSender())
            // isAddressWhitelisted(from)
            // isAddressWhitelisted(to)
            bool
        )
    {
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
        _checkRole(MINTER_ROLE, minter);
        super._approveMint(minter, amount);
        return true;
    }

    function addMinter(
        address minter,
        uint256 amount
    ) external virtual override whenNotPaused onlyMasterMinter returns (bool) {
        // ) external virtual override whenNotPaused onlyMasterMinter returns (bool) {
        super._grantRole(MINTER_ROLE, minter);
        super._approveMint(minter, amount);
        //        emit MinterConfigured(minter);
        return true;
    }

    //    function addMinter(address minter) external virtual override whenNotPaused onlyMasterMinter returns (bool) {
    //        super._grantRole(MINTER_ROLE, minter);
    //        emit MinterConfigured(minter);
    //        return true;
    //    }

    function removeMinter(address minter) external override onlyMasterMinter returns (bool) {
        _revokeRole(MINTER_ROLE, minter);
        emit MinterRemoved(minter);
        return true;
    }

    function updateMasterMinter(address _newMasterMinter) public virtual override onlyOwner {
        require(_newMasterMinter != address(0), "TokenUpgradeable: new masterMinter is the zero address");
        // TODO
        //        require(getRoleAdmin(MASTER_MINTER_ROLE) == address(0), "TokenUpgradeable: new masterMinter member zero address");
        _grantRole(MASTER_MINTER_ROLE, _newMasterMinter);
        emit MasterMinterChanged(_newMasterMinter);
    }

    function updateBlacklister(address _newBlacklister) public override onlyOwner {
        require(_newBlacklister != address(0), "TokenUpgradeable: new blacklister is the zero address");
        // TODO
        //        require(getRoleAdmin(MASTER_MINTER_ROLE) == address(0), "TokenUpgradeable: new blacklister member zero address");
        super._grantRole(BLACKLISTER_MANAGER_ROLE, _newBlacklister);
        emit BlacklisterChanged(_newBlacklister);
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

    function _checkOnlyFeeManager() internal view virtual override {
        require(_accessHasRole(FEE_MANAGER_ROLE, msg.sender), "FeeAggregator: caller is not the feeManager");
    }

    function addFeeAccount(address account) public onlyFeeManager returns (bool) {
        _addFeeAccount(account, 0, 0);
        return true;
    }

    function removeFeeAccount(address account) public onlyFeeManager {
        _checkRole(FEE_HOLDER_ROLE, account);
        _removeFeeAccount(account);
    }

    /**
     * @notice setParams the JDSC token contract.
     * @param _feeAccount       the token fee Account.
     * @param newBasisPoints       the token fee ratio.
     * @param newMaxFee     the token handling maximum fees.
     * @param rateDecimals     the token handling fee 'X' percentage.
     */
    function setParams(
        address _feeAccount,
        uint256 newBasisPoints,
        uint256 newMaxFee,
        uint8 rateDecimals
    ) public onlyFeeManager returns (bool) {
        // ) public override onlyFeeManager returns (bool) {
        require(_feeAccount != address(0));

        // TODO
        _checkRole(FEE_HOLDER_ROLE, _feeAccount);
        require(newBasisPoints < MAX_SETTABLE_BASIS_POINTS);
        require(newMaxFee < MAX_SETTABLE_FEE);

        _setCommonParam(_feeAccount, newBasisPoints, newMaxFee, rateDecimals);
        _addFeeAccount(_feeAccount, 0, basisPointsRate);

        return true;
    }

    function calcFee(address account, uint256 _value) public view returns (uint256 _fee) {
        // function calcFee(address account, uint256 _value) public view override returns (uint256 _fee) {
        _checkRole(FEE_HOLDER_ROLE, account);
        return _calcFee(account, _value);
    }
}
