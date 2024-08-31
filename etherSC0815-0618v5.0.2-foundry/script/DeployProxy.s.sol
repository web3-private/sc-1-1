// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {TokenUpgradeable} from "../src/TokenUpgradeable.sol";
import {TokenBaseUpgradeable} from "../src/TokenBaseUpgradeable.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployProxy is Script {
    function run() external returns (address) {
        address proxy = deployProxy();
        return proxy;
    }

    function deployProxy() public returns (address) {
        vm.startBroadcast();

        address initialOwner = makeAddr("owner");
        // address initialOwner = address(0x1f198BbEf5Dd59f0Ba2963c877F8A05F374d4764);
        string memory name_ = string("tokendd");
        string memory symbol_ = string("token");
        uint8 decimals_ = uint8(8);

        TokenUpgradeable tokenUpgradeable = new TokenUpgradeable();

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(tokenUpgradeable),
            initialOwner,
            abi.encodeWithSelector(TokenBaseUpgradeable.initialize.selector, initialOwner, name_, symbol_, decimals_)
        );
        vm.stopBroadcast();
        return address(proxy);
    }
}
