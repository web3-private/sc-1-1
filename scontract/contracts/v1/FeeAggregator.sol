// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {FeeV1Interface} from "../interfaces/FeeV1Interface.sol";

/**
 * @title FeeAggregator
 * @author JD Coinlink
 * @dev Token fees realize contracts.
 */
abstract contract FeeAggregator is FeeV1Interface {
        
    /**
     * @dev Triggered when division overflows
     */
    error DivisionOverflow();
    
    /**
     * @dev Triggered when multiplication overflows
     */
    error MultiplicationOverflow();

    using Math for uint256;

    //common fee rate.
    uint256 public commonRate;
    //1/n , For example: fee per thousand.
    uint256 public constant commonRateDecimal = 1000;
    //common fee account.
    address public feeAccount;
    //Maximum common fee per transaction.
    uint256 public maximumFee;
    uint256 constant MAX_SETTABLE_FEE_RATE = 20;
    uint256 constant MAX_SETTABLE_FEE = 5000 * 1e2;

    uint256 public constant MAX_UINT = 2 ** 256 - 1;

    /**
     * @dev Record the total handling fee per address.
     */
    mapping(address => uint256) public feeAccounts;

    /**
     * @dev Record the processing rate for each address.
     */
    mapping(address => uint256) public feeRateAccounts;
    
    /**
     * @dev Record all fee account addresses.
     */
    address[] public feeAccountKeys;

    /**
     * @notice The restriction function can only be called by the expense manager.
     * @dev The restriction function can only be called by the expense manager.
     * Functions that use this modifier will first execute the _checkOnlyFeeManager() function.
     */
    modifier onlyFeeManager() {
        _checkOnlyFeeManager();
        _;
    }

    /**
     * @dev Check whether the caller is a fee manager.
     */
    function _checkOnlyFeeManager() internal view virtual;

    /**
     * @dev Add a fee account, and set the fee amount, set the procedure rate.
     */
    function _addFeeAccount(address account, uint256 amount, uint256 newBasisPoints) internal {
        feeAccounts[account] = amount;

        feeRateAccounts[account] = newBasisPoints;
        if (!contains(account)) {
            feeAccountKeys.push(account);
        }
    }

    /**
     * @dev Check if the account is already included in the commission account list.
     */
    function contains(address account) internal view returns (bool) {
        for (uint256 i = 0; i < feeAccountKeys.length; i++) {
            if (feeAccountKeys[i] == account) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Update fee manager account address.
     */
    function updateFeeManager(address account) external virtual;

    /**
     * @dev Increase the total fee on the handling account.
     * @param account fee account.
     * @param amount Increase  fee.
     * @return Return to increase state.
     */
    function _increaseAccountAmount(address account, uint256 amount) internal returns (bool) {
        uint256 oldAmount = feeAccounts[account];
        uint256 newAmount = oldAmount + amount;
        feeAccounts[account] = newAmount;

        return true;
    }

    /**
     * @notice Delete fee account.
     * @dev Delete fee account.
     * @param account Address of the fee account to be deleted.
     * @return Return to deleted state.
     */
    function _removeFeeAccount(address account) internal onlyFeeManager returns (bool) {
        delete feeAccounts[account];
        for (uint256 i = 0; i < feeAccountKeys.length; i++) {
            if (feeAccountKeys[i] == account) {
                feeAccountKeys[i] = feeAccountKeys[feeAccountKeys.length - 1];
                feeAccountKeys.pop();

                break;
            }
        }

        return true;
    }

    /**
     * @dev get all fee account.
     */
    function getFeeAccounts() external view returns (address[] memory) {
        return feeAccountKeys;
    }

    /**
     * @notice Set common fee parameters.
     * @dev Set common fee parameters.
     * metamask will be used when calling the transfer function.
     */
    function _setCommonParam(
        address _feeAccount,
        uint256 newCommonRate,
        uint256 newMaxFee,
        uint8 _decimals
    ) internal returns (bool) {
        feeAccount = _feeAccount;
        commonRate = newCommonRate;
        (bool flag, uint256 fee) = newMaxFee.tryMul(uint256(10) ** _decimals);
        if (!flag) {
            revert MultiplicationOverflow();
        }

        maximumFee = fee;
        emit Params(feeAccount, commonRate, maximumFee);
        return true;
    }

    /**
     * @notice Total fee for current account.
     * @dev Total fee for current account.
     * @param _account fee account.
     */
    function totalFee(address _account) public view override returns (uint256) {
        require(_account != address(0), "FeeAggregator: _account is the zero address");
        return feeAccounts[_account];
    }

    /**
     * @notice Set common fee parameters.
     * @dev Set common fee parameters.
     * metamask will be used when calling the transfer function.
     * @param _value Amount entered.
     * @return The calculated fee.
     */
    function calcCommonFee(uint256 _value) public view override returns (uint256) {
        (bool basicFlag, uint256 basicFee) = _value.tryMul(commonRate);
        if (!basicFlag) {
            revert MultiplicationOverflow();
        }

        (bool flag, uint256 fee) = basicFee.tryDiv(commonRateDecimal);
        if (!flag) {
            revert DivisionOverflow();
        }

        if (fee > maximumFee) {
            fee = maximumFee;
        }
        return fee;
    }

    /**
     * @notice Common fee account.
     * @dev Common fee account.
     * @return Common fee account address.
     */
    function commonFeeAccount() public view override returns (address) {
        return feeAccount;
    }

    /**
     * @notice Calculate the fee.
     * @dev Calculate the fee.
     * Based on the account address and amount entered
     * @param _value amount entered
     * @return Return the calculated fee.
     */
    function _calcFee(address account, uint256 _value) internal view returns (uint256) {
        uint256 accountPointsRate = feeRateAccounts[account];
        if (accountPointsRate <= 0) {
            return uint256(0);
        }

        (bool basicFlag, uint256 basicFee) = _value.tryMul(accountPointsRate);
        if (!basicFlag) {
            revert MultiplicationOverflow();
        }

        (bool flag, uint256 fee) = basicFee.tryDiv(commonRateDecimal);
        if (!flag) {
            revert DivisionOverflow();
        }

        if (fee > maximumFee) {
            fee = maximumFee;
        }

        return fee;
    }
}
