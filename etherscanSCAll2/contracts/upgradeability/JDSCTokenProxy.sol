// SPDX-License-Identifier: MIT

/**
 * @title JDSCTokenProxy
 * @dev This contract proxies JDSCToken calls and enables JDSCToken upgrades
*/ 

pragma solidity ^0.8.0;

import { AdminUpgradeabilityProxy } from "./AdminUpgradeabilityProxy.sol";

contract JDSCTokenProxy is AdminUpgradeabilityProxy {
    constructor(address _implementation) 
    public
    AdminUpgradeabilityProxy(_implementation) {
        
    }
}