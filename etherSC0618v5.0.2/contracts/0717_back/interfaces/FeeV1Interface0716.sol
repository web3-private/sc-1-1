// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

interface FeeV1Interface0716 {
    event Params(address _feeAccount, uint256 feeBasisPoints, uint256 maxFee);

    function calcCommonFee(uint256 _value) external view returns (uint256);

    function commonFeeAccount() external view returns (address);

    function totalFee(address _account) external view returns (uint256);
}
