// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

/**
 * @title FeeV1Interface
 * @author Asan
 * @dev Token fee interface.
 */
interface FeeV1Interface {
    /**
     * @dev Defines an event that is triggered when the fee manager is changed.
     * @param newManager New feeManager address.
     */
    event UpdateFeeManager(address indexed newManager);
    /**
     * @dev Defines an event that is triggered when setting a handling parameter.
     * @param _feeAccount fee account address.
     * @param feeBasisPoints Fee The processing rate set by the account address.
     * @param maxFee The maximum fee charged for a single transaction.
     */
    event Params(address _feeAccount, uint256 feeBasisPoints, uint256 maxFee);
    /**
     * @notice Set common fee parameters.
     * @dev Set common fee parameters.
     * metamask will be used when calling the transfer function.
     * @param _value Amount entered.
     * @return The calculated fee.
     */

    function calcCommonFee(uint256 _value) external view returns (uint256);

    /**
     * @notice Common fee account.
     * @dev Common fee account.
     * @return Common fee account address.
     */
    function commonFeeAccount() external view returns (address);
    /**
     * @notice Total fee for current account.
     * @dev Total fee for current account.
     * @param _account fee account.
     */
    function totalFee(address _account) external view returns (uint256);
}
