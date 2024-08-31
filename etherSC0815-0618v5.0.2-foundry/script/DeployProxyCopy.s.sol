// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {TokenUpgradeable} from "../src/TokenUpgradeable.sol";
import {TokenBaseUpgradeable} from "../src/TokenBaseUpgradeable.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployProxyCopy is Script {
    function run() external returns (address) {
        address proxy = deployProxy();
        return proxy;
    }

    function deployProxy() public returns (address) {
        // address sdsd = makeAddr("user");
        // vm.prank(address(uint160(uint256(keccak256(bytes("dsdsd"))))));
        // vm.prank(0x2B9e98CAca46AFdD561B5C73f71541BC05d19f7D);
        vm.startBroadcast();

        address initialOwner = makeAddr("owner");
        // address initialOwner = address(0x1f198BbEf5Dd59f0Ba2963c877F8A05F374d4764);
        string memory name_ = string("tokendd");
        string memory symbol_ = string("token");
        uint8 decimals_ = uint8(8);

        TokenUpgradeable tokenUpgradeable = new TokenUpgradeable();
        // // 部署透明代理合约并初始化
        // TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
        //     address(0),
        //     address(0), // 设置ProxyAdmin为代理管理员
        //     abi.encodeWithSelector(TokenBaseUpgradeable.initialize.selector) // 调用initialize函数

        // TransparentUpgradeableProxy proxy =
        //     new TransparentUpgradeableProxy(address(tokenUpgradeable), initialOwner, "0x");

        // TokenUpgradeable(address(proxy)).initialize(initialOwner, name_, symbol_, decimals_);

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(tokenUpgradeable),
            initialOwner,
            abi.encodeWithSelector(TokenBaseUpgradeable.initialize.selector, initialOwner, name_, symbol_, decimals_)
        );
        vm.stopBroadcast();
        return address(proxy);
    }
}
