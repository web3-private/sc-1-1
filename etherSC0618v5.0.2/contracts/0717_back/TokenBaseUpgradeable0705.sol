// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {AccessManager0705} from "./AccessManager0705.sol";
import {Minterable0705} from "./Minterable0705.sol";

import {FeeV1Interface0705} from "./interfaces/FeeV1Interface0705.sol";
import {FeeAggregator0705} from "./interfaces/FeeAggregator0705.sol";

import {Blacklistable0705} from "./Blacklistable0705.sol";

contract TokenBaseUpgradeable0705 is
    Initializable,
    ERC20Upgradeable,
    ERC20PausableUpgradeable,
    OwnableUpgradeable,
    ERC20PermitUpgradeable,
    AccessControlUpgradeable,
    Blacklistable0705,
    // AccessManager,
    Minterable0705,
    FeeAggregator0705
{
    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);

    uint8 internal _decimals;
    string public currency;

    // 初始化函数，替代构造函数
    function initialize(address initialOwner, string memory name_, string memory symbol_) public initializer {
        __ERC20_init(name_, symbol_); // 初始化 ERC20 代币
        __ERC20Permit_init(name_); // 初始化 ERC20Permit
        __ERC20Pausable_init(); // 初始化可暂停功能
        __Ownable_init(initialOwner); // 初始化所有权管理

        __AccessControl_init(); // 初始化访问权限管理

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

    function _accessHasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return super.hasRole(role, account);
    }

    function _checkNotRole(bytes32 role, address account) internal view virtual {
        if (hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    //币种
    function updateCurrency(string memory _currency) public virtual onlyOwner {
        currency = _currency;
    }

    //精度
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    //重写精度
    function updateDecimals(uint8 upDecimals) public virtual onlyOwner returns (bool) {
        _decimals = upDecimals;
        return true;
    }

    // // 只有所有者可以铸造代币
    // function mint(address to, uint256 amount) public virtual whenNotPaused {
    //     _checkRole(MINTER_ROLE, _msgSender());
    //     super._mint(to, amount);
    //     emit Mint(_msgSender(), to, amount);
    // }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, deducting from
     * the caller's allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value) internal virtual whenNotPaused {
        super._spendAllowance(account, _msgSender(), value);
        super._burn(account, value);
    }

    function transfer(
        address to,
        uint256 amount
    )
        public
        virtual
        override
        whenNotPaused //合约暂停校验
        returns (bool)
    {
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
        returns (bool)
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
        _pause();
    }

    function unpause() public whenPaused {
        require(hasRole(PAUSER_ROLE, _msgSender()), "TokenBaseUpgradeable: must have pauser role to unpause");
        _unpause();
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20Upgradeable, ERC20PausableUpgradeable) {
        super._update(from, to, value);
    }

    // 显式覆盖 _disableInitializers 方法
    function _disableInitializers() internal override {
        super._disableInitializers();
    }

    function approve(address spender, uint256 value) public virtual override onlyMasterMinter returns (bool) {
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
        super._approveMint(minter, amount);
        return true;
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

    // function updateAllowance(address minter, uint256 amount) internal override returns (bool) {
    //     super._spendAllowanceMint(minter, amount);
    //     return true;
    // }

    function configureMinter(address minter) external virtual override whenNotPaused onlyMasterMinter returns (bool) {
        super._grantRole(MINTER_ROLE, minter);
        emit MinterConfigured(minter);
        return true;
    }

    function removeMinter(address minter) external override onlyMasterMinter returns (bool) {
        _revokeRole(MINTER_ROLE, minter);
        emit MinterRemoved(minter);
        return true;
    }

    function updateMasterMinter(address _newMasterMinter) public virtual override onlyOwner {
        require(_newMasterMinter != address(0), "Minterable: new masterMinter is the zero address");
        _grantRole(MASTER_MINTER_ROLE, _newMasterMinter);
        emit MasterMinterChanged(_newMasterMinter);
    }

    function updateBlacklister(address _newBlacklister) public override onlyOwner {
        require(_newBlacklister != address(0), "TokenUpgradeable: new blacklister is the zero address");

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
}
