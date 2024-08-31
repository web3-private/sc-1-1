// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {TokenUpgradeable0716} from "./TokenUpgradeable0716.sol";

contract TokenUpgradeableUp is TokenUpgradeable0716 {
    uint8 internal _decimals1;
    uint8 internal _decimals2;
}
