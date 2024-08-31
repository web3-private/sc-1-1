// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

interface FeeV1Interface0625 {
    event Params(address _feeAccount, uint256 feeBasisPoints, uint256 maxFee);

    function setParams(
        address feeAccount,
        uint256 newBasisPoints,
        uint256 newMaxFee,
        uint8 _decimals
    ) external returns (bool);

    function updateFeeAccountAmount(address account, uint256 amount) external returns (bool);

    function calcCommonFee(uint256 _value) external view returns (uint256);

    function commonFeeAccount() external view returns (address);

    function calcFee(address account, uint256 _value) external view returns (uint256);

    function totalFee(address _account) external view returns (uint256);
}
