// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {DeployProxy} from "../script/DeployProxy.s.sol";
import {TokenUpgradeable} from "../src/TokenUpgradeable.sol";

contract TokenUpgradeableProxyTest is StdCheats, Test {
    DeployProxy public deployProxy;
    address public depolyer;

    function setUp() public {
        deployProxy = new DeployProxy();
    }

    function testUpdateMasterMinter() public {
        address proxyToken = deployProxy.deployProxy();

        address owner = TokenUpgradeable(proxyToken).owner();
        address admin = makeAddr("admin");
        vm.prank(owner);

        TokenUpgradeable(proxyToken).updateMasterMinter(admin);

        // 验证更新是否成功
        // assertEq(deployProxy.masterMinter(), admin, "Master Minter update failed");
    }

    function testAddMinterAndApprove() public {
        address proxyToken = deployProxy.deployProxy();
        address owner = TokenUpgradeable(proxyToken).owner();

        address admin = makeAddr("admin");
        address minter = makeAddr("minter");

        vm.prank(owner);
        TokenUpgradeable(proxyToken).updateMasterMinter(admin);

        vm.prank(admin);
        TokenUpgradeable(proxyToken).addMinter(minter, 21_000_000);

        vm.prank(admin);
        TokenUpgradeable(proxyToken).approveMint(minter, 21_000_000);

        // 验证 Minter 是否成功添加
        // assertEq(deployProxy.isMinter(minter), true, "Minter addition failed");
    }

    function testTokenMint() public {
        address proxyToken = deployProxy.deployProxy();
        address owner = TokenUpgradeable(proxyToken).owner();

        address admin = makeAddr("admin");
        address minter = makeAddr("minter");

        vm.deal(admin, 10 ether);
        vm.deal(minter, 10 ether);

        vm.startPrank(owner);
        TokenUpgradeable(proxyToken).updateMasterMinter(admin);

        vm.stopPrank();

        vm.startPrank(admin);

        TokenUpgradeable(proxyToken).addMinter(minter, 21_000_000);
        TokenUpgradeable(proxyToken).approveMint(minter, 21_000_000);

        vm.stopPrank();

        address recipient = makeAddr("user");
        vm.deal(recipient, 10 ether);

        vm.startPrank(minter);
        uint256 amount = 1000;
        TokenUpgradeable(proxyToken).mint(recipient, amount);

        vm.stopPrank();
        assertEq(TokenUpgradeable(proxyToken).balanceOf(recipient), amount, "Mint failed");
    }
}
