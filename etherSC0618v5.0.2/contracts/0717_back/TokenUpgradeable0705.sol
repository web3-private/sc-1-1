// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {TokenBaseUpgradeable0705} from "./TokenBaseUpgradeable0705.sol";
import {Whitelistable0705} from "./Whitelistable0705.sol";

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {TokenErrors0705} from "./interfaces/TokenErrors0705.sol";

contract TokenUpgradeable0705 is TokenBaseUpgradeable0705, Whitelistable0705 {
    using Math for uint256;

    bool public whitestatus;

    function getInitializeData(string memory name_, string memory symbol_) public pure returns (bytes memory) {
        return abi.encodeWithSignature("initialize(string,string,address)", name_, symbol_);
    }

    function updateWhitelister(address _newWhitelister) external override onlyOwner {
        require(_newWhitelister != address(0), "TokenUpgradeable: new whitelister is the zero address");
        super._grantRole(WHITELISTER_MANAGER_ROLE, _newWhitelister);
        emit WhitelisterChanged(_newWhitelister);
    }

    function _isWhitelisted(address _account) internal view override returns (bool) {
        return super.hasRole(WHITELISTER_ROLE, _account);
    }

    function _whitelist(address _account) internal override {
        super._grantRole(WHITELISTER_ROLE, _account);
    }

    function _unWhitelist(address _account) internal override {
        super._revokeRole(WHITELISTER_ROLE, _account);
    }

    function _whitestatus() internal view override returns (bool) {
        return whitestatus;
    }

    function updateWhitestatus(bool status) external onlyWhitelister returns (bool) {
        whitestatus = status;
        return true;
    }

    function mint(
        address to,
        uint256 amount
    )
        public
        whenNotPaused
        notBlacklisted(_msgSender()) //黑名单校验
        notBlacklisted(to) //黑名单校验
        isAddressWhitelisted(_msgSender()) //白名单校验
        isAddressWhitelisted(to) //白名单校验
    {
        if (to != owner()) {
            _checkRole(MINTER_ROLE, _msgSender());
            _spendAllowanceMint(_msgSender(), amount);
        }

        super._mint(to, amount);
    }

    function transfer(
        address to,
        uint256 amount
    )
        public
        virtual
        override
        whenNotPaused //合约暂停校验
        notBlacklisted(msg.sender) //黑名单校验
        notBlacklisted(to) //黑名单校验
        isAddressWhitelisted(msg.sender) //白名单校验
        isAddressWhitelisted(to) //白名单校验
        returns (bool)
    {
        uint256 fee = calcCommonFee(amount);
        address feeAccount = commonFeeAccount();
        (bool flag, uint256 sendAmount) = amount.trySub(fee);
        if (!flag) {
            revert SubtractionOverflow();
        }

        if (fee > 0) {
            super._transfer(msg.sender, feeAccount, fee);
        }

        super._transfer(msg.sender, to, sendAmount);

        return true;
    }

    function redeem(
        address account,
        address feeAccount,
        uint256 amount,
        uint256 validAfter,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        whenNotPaused //合约暂停校验
        notBlacklisted(account) //黑名单校验
        notBlacklisted(feeAccount) //黑名单校验
        isAddressWhitelisted(account) //白名单校验
        isAddressWhitelisted(feeAccount) //白名单校验
    {
        _checkRole(MINTER_ROLE, _msgSender());
        super.permit(account, _msgSender(), amount, validAfter, v, r, s);

        uint256 fee = calcFee(feeAccount, amount);
        (bool flag, uint256 sendAmount) = amount.trySub(fee);
        if (!flag) {
            revert SubtractionOverflow();
        }

        if (fee > 0) {
            super._transfer(account, feeAccount, fee);
            _spendAllowanceMint(_msgSender(), fee);
        }

        super.burnFrom(account, sendAmount);
    }
}
