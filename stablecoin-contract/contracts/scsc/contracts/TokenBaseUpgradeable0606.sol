// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { ERC20PermitUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import { ERC20PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import { TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TokenBaseUpgradeable0606 is ERC20Upgradeable, ERC20PermitUpgradeable, ERC20PausableUpgradeable, OwnableUpgradeable,AccessControlUpgradeable {
    
    uint8 internal _decimals;
    string public currency;

    // address public pauser;

    // 初始化函数，替代构造函数
    function initialize(string memory name, string memory symbol) public initializer {
        __ERC20_init(name, symbol); // 初始化 ERC20 代币
        __ERC20Permit_init(name); // 初始化 ERC20Permit
        __ERC20Pausable_init(); // 初始化可暂停功能
        __Ownable_init(); // 初始化所有权管理
        __AccessControl_init();
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
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // // 只有所有者可以暂停合约
    // function pause() public onlyOwner {
    //     _pause();
    // }

    // // 只有所有者可以取消暂停合约
    // function unpause() public onlyOwner {
    //     _unpause();
    // }

    // 在代币转移之前调用，用于检查是否处于暂停状态等
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
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

    // // 更新合约名称和符号
    // function updateNameAndSymbol(string memory newName, string memory newSymbol) public onlyOwner {
    //     _name = newName;
    //     _symbol = newSymbol;
    // }


    // /**
    //  * @dev called by the owner to pause, triggers stopped state
    //  */
    // function pause() internal override {
    //     _pause();
    // }

    // /**
    //  * @dev called by the owner to unpause, returns to normal state
    //  */
    // function unpause() internal override {
    //     _unpause();
    // }


    // /**
    //  * @notice Updates the pauser address.
    //  * @param _newPauser The address of the new pauser.
    //  */
    // function updatePauser(address _newPauser) external override onlyOwner {
    //     require(
    //         _newPauser != address(0),
    //         "JDSCPausable: new pauser is the zero address"
    //     );
    //     pauser = _newPauser;
    //     emit PauserChanged(pauser);
    // }

    // // 更新暂停者地址
    // function updatePauser(address _newPauser) external onlyOwner {
    //     require(_newPauser != address(0), "JDSCTokenBaseUpgradeable: new pauser is the zero address");
    //     pauser = _newPauser;
    // }

}
