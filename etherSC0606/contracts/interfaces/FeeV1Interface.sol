// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface FeeV1Interface {
    event Params(address _feeAccount, uint256 feeBasisPoints, uint256 maxFee);

    // event TransferFee(address indexed from, address indexed to, uint256 value, bytes orderId);

    // event TransferWithSign(
    //     address indexed from,
    //     address indexed to,
    //     bytes32 indexed nonce,
    //     bytes orderId,
    //     uint256 value,
    //     uint256 validAfter,
    //     uint256 validBefore
    // );

    // event TransferWithRSV(
    //     address indexed from,
    //     address indexed to,
    //     bytes32 indexed nonce,
    //     bytes orderId,
    //     uint256 value,
    //     uint256 validAfter,
    //     uint256 validBefore
    // );

    function setParams(address feeAccount, uint256 newBasisPoints, uint256 newMaxFee, uint8 _decimals) external virtual returns (bool);

    function calcCommonFee(uint256 _value) external view virtual returns (uint256);

    function commonFeeAccount() external view virtual returns (address);

    function calcFee(address account, uint256 _value) external view virtual returns (uint256);

    // function calcSendAmount(uint256 _balance, uint256 _fee, uint256 _value) public virtual pure returns (uint256 amount, uint256 fee);

    function totalFee(address _account) external view virtual returns (uint256);
}
