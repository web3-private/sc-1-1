// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {SafeMathUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import {TokenBaseUpgradeableTemp} from "./TokenBaseUpgradeableTemp.sol";
import {AbstractTokenFee} from "./extensions/AbstractTokenFee.sol";
import {Blacklistable} from "./Blacklistable.sol";

import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IERC1967} from "@openzeppelin/contracts/interfaces/IERC1967.sol";
import {ERC1967Upgrade} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";

// import { AccessManagedERC20MintUpgradeable } from "@openzeppelin/contracts-upgradeable@5.0.2/mocks/docs/access-control/AccessManagedERC20MintBaseUpgradeable.sol";

contract TokenUpgradeableTempCopy1 is ERC1967Upgrade, TokenBaseUpgradeableTemp, Blacklistable {
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) internal balanceAndBlacklistStates;

    event Mint(address indexed minter, address indexed to, uint256 amount);
    event Burn(address indexed burner, uint256 amount);

    function GetInitializeData() public pure returns (bytes memory) {
        return abi.encodeWithSignature("initialize(string,string)", "jdscToken", "jdsc");
    }

    /**
     * @notice Updates the blacklister address.
     * @param _newBlacklister The address of the new blacklister.
     */
    function updateBlacklister(address _newBlacklister) public override onlyOwner {
        require(_newBlacklister != address(0), "TokenUpgradeable: new blacklister is the zero address");
        blacklister = _newBlacklister;
        emit BlacklisterChanged(blacklister);
    }

    /**
     * @inheritdoc Blacklistable
     */
    function _blacklist(address _account) internal override {
        _setBlacklistState(_account, true);
    }

    /**
     * @inheritdoc Blacklistable
     */
    function _unBlacklist(address _account) internal override {
        _setBlacklistState(_account, false);
    }

    /**
     * @dev Helper method that sets the blacklist state of an account on balanceAndBlacklistStates.
     * If _shouldBlacklist is true, we apply a (1 << 255) bitmask with an OR operation on the
     * account's balanceAndBlacklistState. This flips the high bit for the account to 1,
     * indicating that the account is blacklisted.
     *
     * If _shouldBlacklist if false, we reset the account's balanceAndBlacklistStates to their
     * balances. This clears the high bit for the account, indicating that the account is unblacklisted.
     * @param _account         The address of the account.
     * @param _shouldBlacklist True if the account should be blacklisted, false if the account should be unblacklisted.
     */
    function _setBlacklistState(address _account, bool _shouldBlacklist) internal {
        balanceAndBlacklistStates[_account] = _shouldBlacklist
            ? balanceAndBlacklistStates[_account] | (1 << 255)
            : balanceOf(_account);
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
        onlyOwner //权限设置
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
        notBlacklisted(from) //黑名单校验
        notBlacklisted(to) //黑名单校验
        onlyOwner //权限设置
        returns (bool)
    {
        super.transferFrom(from, to, amount);
        return true;
    }

    function redeem(address account, uint256 amount) external {
        super.burn(account, amount);
        // coin.transfer(msg.sender, bond.debt);
    }

    // function withdraw(uint256 amount) external {
    //     require(msg.sender == admin, "not authorized");
    //     coin.transfer(msg.sender, amount);
    // }

    /**
     * @dev Helper method that sets the balance of an account on balanceAndBlacklistStates.
     * Since balances are stored in the last 255 bits of the balanceAndBlacklistStates value,
     * we need to ensure that the updated balance does not exceed (2^255 - 1).
     * Since blacklisted accounts' balances cannot be updated, the method will also
     * revert if the account is blacklisted
     * @param _account The address of the account.
     * @param _balance The new JDSC token balance of the account (max: (2^255 - 1)).
     */
    function _setBalance(address _account, uint256 _balance) internal {
        require(_balance <= ((1 << 255) - 1), "TokenUpgradeable: Balance exceeds (2^255 - 1)");
        require(!_isBlacklisted(_account), "TokenUpgradeable: Account is blacklisted");

        balanceAndBlacklistStates[_account] = _balance;
    }

    /**
     * @inheritdoc Blacklistable
     */
    function _isBlacklisted(address _account) internal view override returns (bool) {
        return balanceAndBlacklistStates[_account] >> 255 == 1;
    }

    /**
     * @notice Adds account to blacklist.
     * @param _account The address to blacklist.
     */
    function totalFee(address _account) external view returns (uint256) {}

    function calcCommonFee(uint256 _value) public view returns (uint256) {
        return uint256(0);
    }

    function calcFee(address account, uint256 _value) public view returns (uint256 _fee) {
        return uint256(0);
    }

    /**
     * @notice Transfer the token from the caller and deduct the handling fee
     * @param feeAccount    Commission address.
     * @param to    Payee's address.
     * @param value Transfer amount.
     */
    function transferFee(
        address feeAccount,
        address to,
        uint256 value,
        bytes memory orderId
    ) public whenNotPaused onlyOwner returns (bool) {
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
        bytes memory signature,
        bytes memory orderId
    ) external whenNotPaused onlyOwner {}

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
    ) external whenNotPaused onlyOwner {}
}
