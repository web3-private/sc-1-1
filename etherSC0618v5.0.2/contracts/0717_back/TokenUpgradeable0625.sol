// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
// import {SafeMathUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import {TokenBaseUpgradeable0625} from "./TokenBaseUpgradeable0625.sol";
import {Blacklistable0625} from "./Blacklistable0625.sol";
import {Whitelistable0625} from "./Whitelistable0625.sol";

import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
// import {IERC1967} from "@openzeppelin/contracts/interfaces/IERC1967.sol";
// import {ERC1967Upgrade} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";

contract TokenUpgradeable0625 is TokenBaseUpgradeable0625, Blacklistable0625, Whitelistable0625 {
    using Math for uint256;
    address public blacklister;
    address public whitelister;

    mapping(address => uint256) internal balanceAndBlacklistStates;
    mapping(address => uint256) internal balanceAndWhitelistStates;

    struct TransferWithAuthStructRSV {
        address feeAccount;
        address from;
        address to;
        uint256 value;
        uint256 validAfter;
        uint256 validBefore;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    event TransferWithRSV(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore
    );

    function getInitializeData(string memory name_, string memory symbol_) public pure returns (bytes memory) {
        return abi.encodeWithSignature("initialize(string,string,address)", name_, symbol_);
    }

    function updateBlacklister(address _newBlacklister) public override onlyOwner {
        require(_newBlacklister != address(0), "TokenUpgradeable: new blacklister is the zero address");
        _grantRole(BLACKLISTER_MANAGER_ROLE, _newBlacklister);
        emit BlacklisterChanged(_newBlacklister);
    }

    function _blacklist(address _account) internal override {
        _grantRole(BLACKLISTER_ROLE, _account);
    }

    function _unBlacklist(address _account) internal override {
        _revokeRole(BLACKLISTER_ROLE, _account);
    }

    function _isBlacklisted(address _account) internal view override returns (bool) {
        return hasRole(BLACKLISTER_ROLE, _account);
    }

    function updateWhitelister(address _newWhitelister) external override onlyOwner {
        require(_newWhitelister != address(0), "TokenUpgradeable: new whitelister is the zero address");
        _grantRole(WHITELISTER_MANAGER_ROLE, _newWhitelister);
        emit WhitelisterChanged(_newWhitelister);
    }

    function _isWhitelisted(address _account) internal view override returns (bool) {
        return hasRole(WHITELISTER_ROLE, _account);
    }

    function _whitelist(address _account) internal override {
        _grantRole(WHITELISTER_ROLE, _account);
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
        returns (bool)
    {
        uint256 fee = super.calcCommonFee(amount);
        address feeAccount = super.commonFeeAccount();
        (, uint256 sendAmount) = amount.trySub(fee);

        super._transfer(msg.sender, to, sendAmount);

        if (fee > 0) {
            super._transfer(msg.sender, feeAccount, fee);
        }

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
        notBlacklisted(from) //黑名单校验
        notBlacklisted(to) //黑名单校验
        isAddressWhitelisted(from) //白名单校验
        isAddressWhitelisted(to) //白名单校验
        returns (bool)
    {
        uint256 fee = super.calcCommonFee(amount);
        address feeAccount = super.commonFeeAccount();
        (, uint256 sendAmount) = amount.trySub(fee);

        super.transferFrom(msg.sender, to, sendAmount);

        if (fee > 0) {
            super.transferFrom(msg.sender, feeAccount, fee);
        }
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
        super.permit(account, feeAccount, amount, validAfter, v, r, s);

        super.burnFrom(account, amount);
    }

    /**
     * @notice Execute a transfer with a signed authorization.And deduct the caller fee.
     * @param feeAccount    Commission address.
     * @param from          Payer's address (Authorizer)
     * @param to            Payee's address
     * @param value         Amount to be transferred
     * @param validAfter    The time after which this is valid (unix time)
     * @param validBefore   The time before which this is valid (unix time)
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
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        whenNotPaused
        returns (
            // notBlacklisted(feeAccount) //黑名单校验
            // notBlacklisted(from) //黑名单校验
            // notBlacklisted(to) //黑名单校验
            // isAddressWhitelisted(feeAccount) //白名单校验
            // isAddressWhitelisted(from) //白名单校验
            // isAddressWhitelisted(to) //白名单校验
            bool
        )
    {
        require(block.timestamp > validBefore, "authorization is not yet valid");
        require(block.timestamp < validAfter, "authorization is expired");
        _checkRole(WHITELISTER_ROLE, feeAccount);
        _checkRole(WHITELISTER_ROLE, from);
        _checkRole(WHITELISTER_ROLE, to);
        _checkNotRole(BLACKLISTER_ROLE, feeAccount);
        _checkNotRole(BLACKLISTER_ROLE, from);
        _checkNotRole(BLACKLISTER_ROLE, to);
        TransferWithAuthStructRSV memory dataInput = TransferWithAuthStructRSV(
            feeAccount,
            from,
            to,
            value,
            validAfter,
            validBefore,
            v,
            r,
            s
        );

        super.permit(
            dataInput.from,
            dataInput.feeAccount,
            dataInput.value,
            dataInput.validAfter,
            dataInput.v,
            dataInput.r,
            dataInput.s
        );

        uint256 fee = super.calcFee(dataInput.feeAccount, dataInput.value);
        (, uint256 sendAmount) = dataInput.value.trySub(fee);

        _transfer(dataInput.from, dataInput.to, sendAmount);

        if (fee > 0) {
            _transfer(dataInput.from, dataInput.feeAccount, fee);
            emit TransferWithRSV(
                dataInput.from,
                dataInput.feeAccount,
                fee,
                dataInput.validAfter,
                dataInput.validBefore
            );
        }

        emit TransferWithRSV(dataInput.from, dataInput.to, sendAmount, dataInput.validAfter, dataInput.validBefore);
        return true;
    }
}
