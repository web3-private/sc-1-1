// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {SafeMathUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import {TokenBaseUpgradeableTemp} from "./TokenBaseUpgradeableTemp.sol";
import {AbstractTokenFee} from "./extensions/AbstractTokenFee.sol";
import {BlacklistableTemp} from "./BlacklistableTemp.sol";
import {WhitelistableTemp} from "./WhitelistableTemp.sol";

import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IERC1967} from "@openzeppelin/contracts/interfaces/IERC1967.sol";
import {ERC1967Upgrade} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";

// import { AccessManagedERC20MintUpgradeable } from "@openzeppelin/contracts-upgradeable@5.0.2/mocks/docs/access-control/AccessManagedERC20MintBaseUpgradeable.sol";

contract TokenUpgradeableTemp is TokenBaseUpgradeableTemp, BlacklistableTemp, WhitelistableTemp {
    using SafeMathUpgradeable for uint256;

    function GetInitializeData(string memory name_, string memory symbol_) public pure returns (bytes memory) {
        return abi.encodeWithSignature("initialize(string,string,address)", name_, symbol_);
    }

    // function GetInitializeData(string memory name_,string memory symbol_, address feeContract_) public pure returns (bytes memory) {
    //     return abi.encodeWithSignature("initialize(string,string,address)", name_, symbol_, feeContract_);
    // }

    function updateBlacklister(address _newBlacklister) public override onlyOwner {
        require(_newBlacklister != address(0), "TokenUpgradeable: new blacklister is the zero address");
        _setupRole(BLACKLISTER_MANAGER_ROLE, _newBlacklister);
        emit BlacklisterChanged(_newBlacklister);
    }

    function _blacklist(address _account) internal override {
        _setupRole(BLACKLISTER_ROLE, _account);
    }

    function _unBlacklist(address _account) internal override {
        _revokeRole(BLACKLISTER_ROLE, _account);
    }

    function _isBlacklisted(address _account) internal view override returns (bool) {
        return hasRole(BLACKLISTER_ROLE, _account);
    }

    function updateWhitelister(address _newWhitelister) external override onlyOwner {
        require(_newWhitelister != address(0), "TokenUpgradeable: new whitelister is the zero address");
        _setupRole(WHITELISTER_MANAGER_ROLE, _newWhitelister);
        emit WhitelisterChanged(_newWhitelister);
    }

    function _isWhitelisted(address _account) internal view override returns (bool) {
        return hasRole(WHITELISTER_ROLE, _account);
    }

    function _whitelist(address _account) internal override {
        _setupRole(WHITELISTER_ROLE, _account);
    }

    function _unWhitelist(address _account) internal override {
        _revokeRole(WHITELISTER_ROLE, _account);
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
        returns (
            // onlyOwner //权限设置
            bool
        )
    {
        // _checkRole(WHITELISTER_ROLE, _msgSender());
        // _checkRole(WHITELISTER_ROLE, to);

        // _checkNotRole(BLACKLISTER_ROLE, _msgSender());
        // _checkNotRole(BLACKLISTER_ROLE, to);

        // require(feeAccount != address(0), "TokenUpgradeable: _feeAccount is the zero address");

        // //deposit
        // if (feeAccount == to) {
        //     _transfer(msg.sender, to, value);
        //     emit TransferFee(msg.sender, to, value, orderId);
        //     return true;
        // }

        // address _feeAccount = feeAccount;
        // address _to = to;
        // uint256 _value = value;

        // uint fee = calcFee(_feeAccount, _value);
        // uint sendAmount = _value.sub(fee);

        // _transfer(msg.sender, _to, sendAmount);
        // emit TransferFee(msg.sender, _to, sendAmount, orderId);

        // if (fee > 0) {
        //     _transfer(msg.sender, _feeAccount, fee);
        //     emit TransferFee(msg.sender, _feeAccount, fee, orderId);
        // }

        uint fee = super.calcCommonFee(amount);
        address feeAccount = super.commonFeeAccount();
        // uint fee = calcFee(_feeAccount, _value);
        uint sendAmount = amount.sub(fee);

        super._transfer(msg.sender, to, sendAmount);
        // emit TransferFee(msg.sender, _to, sendAmount, orderId);

        if (fee > 0) {
            super._transfer(msg.sender, feeAccount, fee);
            // emit TransferFee(msg.sender, _feeAccount, fee, orderId);
        }

        // super.transfer(to, amount);
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
        // onlyRole();
        notBlacklisted(from) //黑名单校验
        notBlacklisted(to) //黑名单校验
        isAddressWhitelisted(from) //白名单校验
        isAddressWhitelisted(to) //白名单校验
        returns (
            // onlyOwner //权限设置
            bool
        )
    {
        // _checkRole();
        // _checkRole(WHITELISTER_ROLE, _msgSender());
        // _checkRole(WHITELISTER_ROLE, to);

        // _checkNotRole(BLACKLISTER_ROLE, _msgSender());
        // _checkNotRole(BLACKLISTER_ROLE, to);

        uint fee = super.calcCommonFee(amount);
        address feeAccount = super.commonFeeAccount();
        uint sendAmount = amount.sub(fee);

        super.transferFrom(msg.sender, to, sendAmount);

        if (fee > 0) {
            super.transferFrom(msg.sender, feeAccount, fee);
        }

        // super.transferFrom(from, to, amount);
        return true;
    }

    function redeem(address account, uint256 amount) external {
        super.burn(account, amount);
    }

    // /**
    //  * @notice Adds account to blacklist.
    //  * @param _account The address to blacklist.
    //  */
    // function totalFee(address _account) external view returns (uint256) {}

    // function calcCommonFee(uint256 _value) public view returns (uint256) {
    //     return uint256(0);
    // }

    // function calcFee(address account, uint256 _value) public view returns (uint256 _fee) {
    //     return uint256(0);
    // }

    /**
     * @notice Transfer the token from the caller and deduct the handling fee
     * @param feeAccount    Commission address.
     * @param to    Payee's address.
     * @param value Transfer amount.
     */
    function transferFee(
        address feeAccount,
        address to,
        uint256 value
    )
        public
        // ,
        // bytes memory orderId
        whenNotPaused
        notBlacklisted(feeAccount) //黑名单校验
        notBlacklisted(to) //黑名单校验
        isAddressWhitelisted(feeAccount) //白名单校验
        isAddressWhitelisted(to) //白名单校验
        returns (
            // onlyOwner
            bool
        )
    {
        // _checkRole(WHITELISTER_ROLE, _msgSender());
        // _checkRole(WHITELISTER_ROLE, to);

        // _checkNotRole(BLACKLISTER_ROLE, _msgSender());
        // _checkNotRole(BLACKLISTER_ROLE, to);

        require(feeAccount != address(0), "TokenUpgradeable: _feeAccount is the zero address");

        //deposit
        if (feeAccount == to) {
            _transfer(msg.sender, to, value);
            return true;
        }

        address _feeAccount = feeAccount;
        address _to = to;
        uint256 _value = value;

        uint256 fee = calcFee(_feeAccount, _value);
        uint256 sendAmount = _value.sub(fee);

        return true;
    }

    /**
     * @notice Execute a transfer with a signed authorization.And deduct the caller fee.
     * @dev EOA wallet signatures should be packed in the order of r, s, v.
     * @param feeAccount    Commission address.
     * @param from          Payer's address (Authorizer)
     * @param to            Payee's address
     * @param value         Amount to be transferred
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
     * @param nonce         Unique nonce
     * @param signature     Signature bytes signed by an EOA wallet or a contract wallet
     */
    function transferWithAuthorizationFee(
        address feeAccount,
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes memory signature
    )
        external
        // ,
        // bytes memory orderId
        whenNotPaused
        notBlacklisted(feeAccount) //黑名单校验
        notBlacklisted(to) //黑名单校验
        isAddressWhitelisted(feeAccount) //白名单校验
        isAddressWhitelisted(to) //白名单校验
    {
        // _checkRole(WHITELISTER_ROLE, _msgSender());
        // _checkRole(WHITELISTER_ROLE, to);
        // _checkNotRole(BLACKLISTER_ROLE, _msgSender());
        // _checkNotRole(BLACKLISTER_ROLE, to);
    }

    /**
     * @notice Execute a transfer with a signed authorization.And deduct the caller fee.
     * @param feeAccount    Commission address.
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
    function transferWithAuthorizationFee(
        address feeAccount,
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes memory orderId
    )
        external
        whenNotPaused
        notWhitelisted(feeAccount) //白名单校验
        isAddressWhitelisted(from) //白名单校验
        isAddressWhitelisted(to) //白名单校验
    {
        //     _checkRole(WHITELISTER_ROLE, _msgSender());
        //     _checkRole(WHITELISTER_ROLE, to);
        //     _checkNotRole(BLACKLISTER_ROLE, _msgSender());
        //     _checkNotRole(BLACKLISTER_ROLE, to);
    }
}
