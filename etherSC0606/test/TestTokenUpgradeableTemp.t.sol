// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/TokenUpgradeableTemp.sol";

contract TestTokenUpgradeableTemp is Test {
    TokenUpgradeableTemp tokenTemp;

    function setUp() external {
        tokenTemp = new TokenUpgradeableTemp();
        tokenTemp.initialize("jdscToken", "jdsc");
    }

    function testInitializeName() external {
        assertEq(tokenTemp.name(), "jdscToken");
    }

    function testInitializeSymbol() external {
        assertEq(tokenTemp.symbol(), "jdsc");
    }

    //     function testInitialBalance() external {
    //         assertEq(tokenTemp.balanceOf(address(this)), 1000000 * 10**uint256(18));
    //     }
}
