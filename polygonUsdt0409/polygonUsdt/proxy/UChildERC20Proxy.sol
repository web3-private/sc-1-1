// SPDX-License-Identifier: MIT

// File: contracts/child/ChildToken/UpgradeableChildERC20/UChildERC20Proxy.sol

import "./UpgradableProxy.sol";
pragma solidity 0.6.6;


contract UChildERC20Proxy is UpgradableProxy {
    constructor(address _proxyTo)
        public
        UpgradableProxy(_proxyTo)
    {}
}