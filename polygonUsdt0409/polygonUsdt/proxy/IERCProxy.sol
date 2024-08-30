/**
 *Submitted for verification at polygonscan.com on 2021-06-29
*/

// File: contracts/common/Proxy/IERCProxy.sol

pragma solidity 0.6.6;

interface IERCProxy {
    function proxyType() external pure returns (uint256 proxyTypeId);

    function implementation() external view returns (address codeAddr);
}