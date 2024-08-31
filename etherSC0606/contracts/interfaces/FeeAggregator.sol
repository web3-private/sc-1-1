// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {SafeMathUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {FeeV1Interface} from "./FeeV1Interface.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract FeeAggregator is FeeV1Interface, OwnableUpgradeable {
    struct TransferAuthStruct {
        address feeAccount;
        address from;
        address to;
        bytes32 nonce;
        uint256 value;
        uint256 validAfter;
        uint256 validBefore;
        bytes signature;
        bytes orderId;
    }

    struct TransferWithAuthStructRSV {
        address feeAccount;
        address from;
        address to;
        bytes32 nonce;
        uint256 value;
        uint256 validAfter;
        uint256 validBefore;
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes orderId;
    }

    struct SendAmountFeeStruct {
        uint256 balance;
        uint256 value;
        uint256 fee;
    }

    using SafeMathUpgradeable for uint256;

    uint256 public basisPointsRate;
    address public feeAccount;
    uint256 public maximumFee;
    uint256 constant MAX_SETTABLE_BASIS_POINTS = 20;
    uint256 constant MAX_SETTABLE_FEE = 5000 * 1e2;

    uint256 public constant MAX_UINT = 2 ** 256 - 1;

    mapping(address => uint256) public feeAccounts;

    mapping(address => uint256) public feeRateAccounts;

    address[] public feeAccountKeys;

    function initialize(address account, uint256 newBasisPoints) public initializer {
        __Ownable_init();
        setAccountBasisPointsRate(account, newBasisPoints);
    }

    function GetInitializeData(address account, uint256 newBasisPoints) public pure returns (bytes memory) {
        return abi.encodeWithSignature("initialize(address,uint256)", account, newBasisPoints);
    }

    function addFeeAccount(address account) public {
        uint256 amount = 0;
        feeAccounts[account] = amount;

        uint256 newBasisPoints = 0;
        feeRateAccounts[account] = newBasisPoints;
        if (!contains(account)) {
            feeAccountKeys.push(account);
        }
    }

    function contains(address account) internal view returns (bool) {
        for (uint256 i = 0; i < feeAccountKeys.length; i++) {
            if (feeAccountKeys[i] == account) {
                return true;
            }
        }
        return false;
    }

    function updateFeeAccountAmount(address account, uint256 amount) public {
        uint256 oldAmount = feeAccounts[account];
        uint256 newAmount = oldAmount + amount;
        feeAccounts[account] = newAmount;
    }

    function removeFeeAccount(address account) public {
        delete feeAccounts[account];
        for (uint256 i = 0; i < feeAccountKeys.length; i++) {
            if (feeAccountKeys[i] == account) {
                delete feeAccountKeys[i];
                break;
            }
        }
    }

    function getFeeAccounts() external view returns (address[] memory) {
        return feeAccountKeys;
    }

    function setAccountBasisPointsRate(address account, uint256 newBasisPoints) internal virtual returns (bool) {
        require(newBasisPoints > 0, "The newBasisPoints must be greater than 0");
        feeRateAccounts[account] = newBasisPoints;
        return true;
    }

    /**
     * @notice setParams the JDSC token contract.
     * @param newBasisPoints       the token fee ratio.
     * @param newMaxFee     the token handling fees.
     */
    function setParams(
        address _feeAccount,
        uint newBasisPoints,
        uint newMaxFee,
        uint8 _decimals
    ) external override onlyOwner returns (bool) {
        require(_feeAccount != address(0));
        require(newBasisPoints < MAX_SETTABLE_BASIS_POINTS);
        require(newMaxFee < MAX_SETTABLE_FEE);

        feeAccount = _feeAccount;
        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee.mul(uint(10) ** _decimals);

        emit Params(feeAccount, basisPointsRate, maximumFee);
        return true;
    }

    /**
     * @notice Adds account to blacklist.
     * @param _account The address to blacklist.
     */
    function totalFee(address _account) external view override returns (uint256) {
        require(_account != address(0), "FeeAggregator: _account is the zero address");
        return feeAccounts[_account];
    }

    function calcCommonFee(uint256 _value) public view override returns (uint256) {
        uint256 fee = (_value.mul(basisPointsRate)).div(1000);

        if (fee > maximumFee) {
            fee = maximumFee;
        }
        return fee;
    }

    function commonFeeAccount() external view override returns (address) {
      
        return feeAccount;
    }

    function calcFee(address account, uint256 _value) public view override returns (uint256 _fee) {
        uint256 accountPointsRate = feeRateAccounts[account];
        if (accountPointsRate <= 0) {
            return uint256(0);
        }
        uint256 fee = (_value.mul(accountPointsRate)).div(1000);

        if (fee > maximumFee) {
            fee = maximumFee;
        }

        return fee;
    }
}
