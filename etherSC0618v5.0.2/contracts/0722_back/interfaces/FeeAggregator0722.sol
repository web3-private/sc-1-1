// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {FeeV1Interface0722} from "./FeeV1Interface0722.sol";
import {TokenErrors0722} from "./TokenErrors0722.sol";

abstract contract FeeAggregator0722 is FeeV1Interface0722, TokenErrors0722 {
    using Math for uint256;

    uint256 public basisPointsRate;
    uint256 public constant basisPointsRateDecimal = 1000;
    address public feeAccount;
    uint256 public maximumFee;
    uint256 constant MAX_SETTABLE_BASIS_POINTS = 20;
    uint256 constant MAX_SETTABLE_FEE = 5000 * 1e2;

    uint256 public constant MAX_UINT = 2 ** 256 - 1;

    mapping(address => uint256) public feeAccounts;

    mapping(address => uint256) public feeRateAccounts;

    address[] public feeAccountKeys;

    modifier onlyFeeManager() {
        _checkOnlyFeeManager();
        _;
    }

    function _checkOnlyFeeManager() internal view virtual;

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

    function updateFeeManager(address account) external virtual;

    function _updateFeeAccountAmount(address account, uint256 amount) internal returns (bool) {
        uint256 oldAmount = feeAccounts[account];
        uint256 newAmount = oldAmount + amount;
        feeAccounts[account] = newAmount;

        return true;
    }

    function _removeFeeAccount(address account) internal onlyFeeManager returns (bool) {
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

    function _setCommonParam(
        address _feeAccount,
        uint256 newBasisPoints,
        uint256 newMaxFee,
        uint8 _decimals
    ) internal returns (bool) {
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

        (bool flag, uint256 fee) = basicFee.tryDiv(basisPointsRateDecimal);
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

    function _calcFee(address account, uint256 _value) internal view returns (uint256) {
        uint256 accountPointsRate = feeRateAccounts[account];
        if (accountPointsRate <= 0) {
            return uint256(0);
        }

        (bool basicFlag, uint256 basicFee) = _value.tryMul(accountPointsRate);
        if (!basicFlag) {
            revert MultiplicationOverflow();
        }

        (bool flag, uint256 fee) = basicFee.tryDiv(basisPointsRateDecimal);
        if (!flag) {
            revert DivisionOverflow();
        }

        if (fee > maximumFee) {
            fee = maximumFee;
        }

        return fee;
    }
}
