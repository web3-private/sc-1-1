// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {SafeMathUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {FeeV1Interface} from "./FeeV1Interface.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

//Deprecated
contract FeeProxy is Initializable, OwnableUpgradeable, TransparentUpgradeableProxy {
    //接口版本，接口地址
    struct Phase {
        uint16 id;
        FeeV1Interface aggregator;
    }
    Phase private currentPhase;
    FeeV1Interface public proposedAggregator;
    mapping(uint16 => FeeV1Interface) public phaseAggregators;

    constructor(
        address _aggregator,
        address _logic,
        address admin_,
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic, admin_, _data) {
        setInterface(_aggregator);
    }

    function setInterface(address _aggregator) internal virtual {
        uint16 id = currentPhase.id + 1;
        currentPhase = Phase(id, FeeV1Interface(_aggregator));
        phaseAggregators[id] = FeeV1Interface(_aggregator);
    }
}
