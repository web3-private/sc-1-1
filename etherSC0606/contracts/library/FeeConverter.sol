// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FeeV1Interface} from "../interfaces/FeeV1Interface.sol";

library FeeConverter {
    function getPrice(FeeV1Interface feeFeed) internal view returns (uint256) {
        // (, int256 answer, , , ) = feeFeed.calcFee();
        // ETH/USD rate in 18 digit
        // return uint256(answer * 10000000000);
        return uint256(0);
    }
}
