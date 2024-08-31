// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// import {TokenBaseUpgradeable} from "./TokenBaseUpgradeable.sol";
// import {Blacklistable} from "./Blacklistable.sol";
// import {Whitelistable} from "./Whitelistable.sol";

// import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
// import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
// import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
// import {TokenErrors} from "./interfaces/TokenErrors.sol";

// import "hardhat/console.sol";

// import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// contract TokenUpgradeable0626 is TokenBaseUpgradeable, Blacklistable, Whitelistable {

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {TokenBaseUpgradeable0625} from "./TokenBaseUpgradeable0625.sol";
import {Blacklistable0625} from "./Blacklistable0625.sol";
import {Whitelistable0625} from "./Whitelistable0625.sol";

import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TokenUpgradeable0626 is TokenBaseUpgradeable0625, Blacklistable0625, Whitelistable0625 {
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
            // revert SubtractionOverflow();
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
        super.permit(account, _msgSender(), amount, validAfter, v, r, s);

        uint256 fee = calcFee(feeAccount, amount);
        (bool flag, uint256 sendAmount) = amount.trySub(fee);
        if (!flag) {
            // revert SubtractionOverflow();
        }

        if (fee > 0) {
            super._transfer(account, feeAccount, fee);
        }

        super.burnFrom(account, sendAmount);
    }

    // function redeemSign(
    //     address account,
    //     address feeAccount,
    //     uint256 amount,
    //     uint256 validAfter,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s
    // )
    //     external
    //     // whenNotPaused //合约暂停校验
    //     // notBlacklisted(account) //黑名单校验
    //     // notBlacklisted(feeAccount) //黑名单校验
    //     // isAddressWhitelisted(account) //白名单校验
    //     // isAddressWhitelisted(feeAccount) //白名单校验
    // {

    //     uint256 nonce = nonces(_msgSender());
    //     console.log("nonces( account):::::%s", nonce);
    //     console.log("_msgSender():::::%s", _msgSender());
    //     // console.logUint(block.chainid);
    //     // console.log("account:::::%s", account);
    //     // console.log("feeAccount:::::%s", feeAccount);
    //     // console.log("amount:::::%s", amount);
    //     // console.log("validAfter:::::%s",validAfter);
    //     // console.log("v:::::%s",v);
    //     // console.logBytes32(r);
    //     // console.logBytes32(s);

    //     address _account = account;
    //     uint256 _validAfter = validAfter;
    //     bytes32 PERMIT_TYPEHASH =
    //             keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    //     //spender   msg.sender
    //     bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, _account, _msgSender(), amount, _useNonce(_msgSender()), _validAfter));
    //     // bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, account, _msgSender(), amount, _useNonce(_msgSender()), validAfter));

    //     bytes32 shash = _hashTypedDataV4(structHash);

    //     console.logBytes32(shash);

    //     address signer = ECDSA.recover(shash, v, r, s);
    //     console.log("signer:::::::",signer);
    //     console.log("_account:::::",_account);

    //     if (signer != _account) {
    //         revert ERC2612InvalidSigner(signer, _account);
    //     }

    //     // super.permit(account, _msgSender(), amount, validAfter, v, r, s);

    //     // uint256 fee = calcFee(feeAccount, amount);
    //     // (bool flag, uint256 sendAmount) = amount.trySub(fee);
    //     // if (!flag) {
    //     //     revert SubtractionOverflow();
    //     // }

    //     // if (fee > 0) {
    //     //     super._transfer(account, feeAccount, fee);
    //     // }

    //     // super.burnFrom(account, sendAmount);
    // }
}
