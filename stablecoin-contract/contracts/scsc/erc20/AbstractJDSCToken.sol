//SPDX-License-Identifier: Apache-2.0


pragma solidity ^0.8.0;

import { ERC20Approve } from "./extensions/ERC20Approve.sol";
import { ERC20Transferable } from "./extensions/ERC20Transferable.sol";
import { ERC20Allowable } from "./extensions/ERC20Allowable.sol";

abstract contract AbstractJDSCToken is ERC20Allowable, ERC20Approve, ERC20Transferable {
    
}
