// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {TokenBaseUpgradeable0702} from "./TokenBaseUpgradeable0702.sol";
import {Blacklistable0702} from "./Blacklistable0702.sol";
import {Whitelistable0702} from "./Whitelistable0702.sol";

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {TokenErrors0702} from "./interfaces/TokenErrors0702.sol";

contract TokenUpgradeable0702 is TokenBaseUpgradeable0702, Blacklistable0702, Whitelistable0702 {
    using Math for uint256;

    address public blacklister;
    address public whitelister;

    mapping(address => bool) internal blacklistStates;
    mapping(address => bool) internal whitelistStates;

    function getInitializeData(string memory name_, string memory symbol_) public pure returns (bytes memory) {
        return abi.encodeWithSignature("initialize(string,string,address)", name_, symbol_);
    }

    function updateBlacklister(address _newBlacklister) public override onlyOwner {
        require(_newBlacklister != address(0), "TokenUpgradeable: new blacklister is the zero address");
        blacklister = _newBlacklister;
        emit BlacklisterChanged(_newBlacklister);
    }

    function _blacklist(address _account) internal override {
        blacklistStates[_account] = true;
    }

    function _unBlacklist(address _account) internal override {
        blacklistStates[_account] = false;
    }

    function _isBlacklisted(address _account) internal view override returns (bool) {
        return blacklistStates[_account];
    }

    function updateWhitelister(address _newWhitelister) external override onlyOwner {
        require(_newWhitelister != address(0), "TokenUpgradeable: new whitelister is the zero address");
        whitelister = _newWhitelister;
        emit WhitelisterChanged(_newWhitelister);
    }

    function _isWhitelisted(address _account) internal view override returns (bool) {
        return whitelistStates[_account];
    }

    function _whitelist(address _account) internal override {
        whitelistStates[_account] = true;
    }

    function _unWhitelist(address _account) internal override {
        whitelistStates[_account] = false;
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
            updateAllowance(to, _msgSender(), amount);
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
            _spendAllowance(account, _msgSender(), fee);
        }

        super.burnFrom(account, sendAmount);
    }
}
