// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
// import {SafeMathUpgradeable} from "@openzeppelin/contracts-upgradeable@4.9.6/utils/math/SafeMathUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {FeeV1Interface0705} from "./FeeV1Interface0705.sol";
import {TokenErrors0705} from "./TokenErrors0705.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract FeeAggregator0705 is FeeV1Interface0705, OwnableUpgradeable, TokenErrors0705 {
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

    // using SafeMathUpgradeable for uint256;
    using Math for uint256;

    uint256 public basisPointsRate;
    address public feeAccount;
    uint256 public maximumFee;
    uint256 constant MAX_SETTABLE_BASIS_POINTS = 20;
    uint256 constant MAX_SETTABLE_FEE = 5000 * 1e2;

    uint256 public constant MAX_UINT = 2 ** 256 - 1;

    mapping(address => uint256) public feeAccounts;

    mapping(address => uint256) public feeRateAccounts;

    address[] public feeAccountKeys;

    // function initialize(
    //     address initialOwner,
    //     address account,
    //     uint256 newBasisPoints,
    //     uint256 newMaxFee,
    //     uint8 _decimals
    // ) public initializer {
    //     __Ownable_init(initialOwner);
    //     _setCommonParam(account, newBasisPoints, newMaxFee, _decimals);
    //     _addFeeAccount(account, 0, newBasisPoints);
    // }

    // function getInitializeData(
    //     address account,
    //     uint256 newBasisPoints,
    //     uint256 newMaxFee,
    //     uint8 _decimals
    // ) public pure returns (bytes memory) {
    //     return
    //         abi.encodeWithSignature(
    //             "initialize(address,uint256,uint256,uint8)",
    //             account,
    //             newBasisPoints,
    //             newMaxFee,
    //             _decimals
    //         );
    // }

    function addFeeAccount(address account) public onlyOwner returns (bool) {
        _addFeeAccount(account, 0, 0);
        return true;
    }

    function _addFeeAccount(address account, uint256 amount, uint256 newBasisPoints) internal {
        feeAccounts[account] = amount;

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

    function updateFeeAccountAmount(address account, uint256 amount) public override onlyOwner returns (bool) {
        uint256 oldAmount = feeAccounts[account];
        uint256 newAmount = oldAmount + amount;
        feeAccounts[account] = newAmount;

        return true;
    }

    function removeFeeAccount(address account) public onlyOwner returns (bool) {
        delete feeAccounts[account];
        for (uint256 i = 0; i < feeAccountKeys.length; i++) {
            if (feeAccountKeys[i] == account) {
                delete feeAccountKeys[i];
                break;
            }
        }

        return true;
    }

    function getFeeAccounts() external view returns (address[] memory) {
        return feeAccountKeys;
    }

    /**
     * @notice setParams the JDSC token contract.
     * @param newBasisPoints       the token fee ratio.
     * @param newMaxFee     the token handling fees.
     */
    function setParams(
        address _feeAccount,
        uint256 newBasisPoints,
        uint256 newMaxFee,
        uint8 _decimals
    ) public override onlyOwner returns (bool) {
        require(_feeAccount != address(0));
        require(newBasisPoints < MAX_SETTABLE_BASIS_POINTS);
        require(newMaxFee < MAX_SETTABLE_FEE);

        _setCommonParam(_feeAccount, newBasisPoints, newMaxFee, _decimals);
        _addFeeAccount(_feeAccount, 0, basisPointsRate);

        return true;
    }
    function _setCommonParam(
        address _feeAccount,
        uint256 newBasisPoints,
        uint256 newMaxFee,
        uint8 _decimals
    ) internal onlyOwner returns (bool) {
        feeAccount = _feeAccount;
        basisPointsRate = newBasisPoints;
        (bool flag, uint256 fee) = newMaxFee.tryMul(uint256(10) ** _decimals);
        if (!flag) {
            revert MultiplicationOverflow();
        }

        maximumFee = fee;
        emit Params(feeAccount, basisPointsRate, maximumFee);
        return true;
    }

    /**
     * @notice Adds account to blacklist.
     * @param _account The address to blacklist.
     */
    function totalFee(address _account) public view override returns (uint256) {
        require(_account != address(0), "FeeAggregator: _account is the zero address");
        return feeAccounts[_account];
    }

    function calcCommonFee(uint256 _value) public view override returns (uint256) {
        (bool basicFlag, uint256 basicFee) = _value.tryMul(basisPointsRate);
        if (!basicFlag) {
            revert MultiplicationOverflow();
        }

        (bool flag, uint256 fee) = basicFee.tryDiv(1000);
        if (!flag) {
            revert DivisionOverflow();
        }

        if (fee > maximumFee) {
            fee = maximumFee;
        }
        return fee;
    }

    function commonFeeAccount() public view override returns (address) {
        return feeAccount;
    }

    function calcFee(address account, uint256 _value) public view override returns (uint256 _fee) {
        uint256 accountPointsRate = feeRateAccounts[account];
        if (accountPointsRate <= 0) {
            return uint256(0);
        }

        (bool basicFlag, uint256 basicFee) = _value.tryMul(basisPointsRate);
        if (!basicFlag) {
            revert MultiplicationOverflow();
        }

        (bool flag, uint256 fee) = basicFee.tryDiv(1000);
        if (!flag) {
            revert DivisionOverflow();
        }

        if (fee > maximumFee) {
            fee = maximumFee;
        }

        return fee;
    }
}
