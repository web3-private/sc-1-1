// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {DeployToken} from "../script/DeployToken.s.sol";
import {TokenUpgradeable} from "../src/TokenUpgradeable.sol";

contract TokenUpgradeableTest is StdCheats, Test {
    TokenUpgradeable public tokenUpgrade;
    address public depolyer;
    address public owner;
    // address public newOwner;

    function setUp() public {
        depolyer = makeAddr("depolyer");
        // owner = makeAddr("owner");
        vm.prank(depolyer);

        // vm.startPrank(owner);
        tokenUpgrade = new TokenUpgradeable();
        // vm.stopPrank();
        address initialOwner = address(0x1f198BbEf5Dd59f0Ba2963c877F8A05F374d4764);
        owner = initialOwner;
        string memory name_ = string("tokendd");
        string memory symbol_ = string("token");
        uint8 decimals_ = uint8(8);

        tokenUpgrade.initialize(initialOwner, name_, symbol_, decimals_);
    }

    function testUpdateMasterMinter() public {
        address admin = makeAddr("admin");

        vm.prank(owner);
        tokenUpgrade.updateMasterMinter(admin);

        // 验证更新是否成功
        // assertEq(tokenUpgrade.masterMinter(), admin, "Master Minter update failed");
    }

    function testAddMinterAndApprove() public {
        address admin = makeAddr("admin");
        address minter = makeAddr("minter");

        vm.prank(owner);
        tokenUpgrade.updateMasterMinter(admin);

        vm.prank(admin);
        tokenUpgrade.addMinter(minter, 21_000_000);

        vm.prank(admin);
        tokenUpgrade.approveMint(minter, 21_000_000);

        // 验证 Minter 是否成功添加
        // assertEq(tokenUpgrade.isMinter(minter), true, "Minter addition failed");
    }

    function testAddMinterAndApproveTwo() public {
        address admin = makeAddr("admin");
        address minter = makeAddr("minter");

        vm.startPrank(owner);
        tokenUpgrade.updateMasterMinter(admin);
        vm.stopPrank();

        vm.startPrank(admin);
        tokenUpgrade.addMinter(minter, 21_000_000);
        // vm.stopPrank();

        // vm.startPrank(admin);
        tokenUpgrade.approveMint(minter, 21_000_000);
        vm.stopPrank();

        // 验证 Minter 是否成功添加
        // assertEq(tokenUpgrade.isMinter(minter), true, "Minter addition failed");
    }

    function testTokenMint() public {
        address admin = makeAddr("admin");
        address minter = makeAddr("minter");
        // hoax(admin, 10 ether);
        // hoax(minter, 10 ether);

        vm.deal(admin, 10 ether);
        vm.deal(minter, 10 ether);

        vm.startPrank(owner);
        // vm.prank(owner);
        tokenUpgrade.updateMasterMinter(admin);

        vm.stopPrank();

        vm.startPrank(admin);
        // vm.prank(admin);

        // tokenUpgrade.updateMasterMinter(admin);
        tokenUpgrade.addMinter(minter, 21_000_000);
        tokenUpgrade.approveMint(minter, 21_000_000);

        vm.stopPrank();

        // vm.startPrank(minter);
        // vm.prank(minter);

        address recipient = makeAddr("user");
        // vm.prank(recipient);
        vm.deal(recipient, 10 ether);

        vm.startPrank(minter);
        // vm.hoax(res , 1 ether);
        // address recipient = address(0x123);
        uint256 amount = 1000;
        tokenUpgrade.mint(recipient, amount);

        vm.stopPrank();
        assertEq(tokenUpgrade.balanceOf(recipient), amount, "Mint failed");
    }
}
