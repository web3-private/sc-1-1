import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";

describe("TokenUpgradeable contract", function () {
  describe("Roles and Permissions", function () {
    it("Should grant and check ADMIN_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const ADMIN_ROLE = await deployInstance.ADMIN_ROLE();

      const instance = deployInstance.connect(owner) as Contract;

      // Grant ADMIN_ROLE to otherAccount
      await instance.grantRole(ADMIN_ROLE, otherAccount.address);

      // Check if otherAccount has ADMIN_ROLE
      expect(await instance.hasRole(ADMIN_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check PAUSER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const PAUSER_ROLE = await deployInstance.PAUSER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant PAUSER_ROLE to otherAccount
      await instance.grantRole(PAUSER_ROLE, otherAccount.address);

      // Check if otherAccount has PAUSER_ROLE
      expect(await instance.hasRole(PAUSER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check BLACKLIST_MEMBER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const BLACKLIST_MEMBER_ROLE = await deployInstance.BLACKLIST_MEMBER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant BLACKLIST_MEMBER_ROLE to otherAccount
      await instance.grantRole(BLACKLIST_MEMBER_ROLE, otherAccount.address);

      // Check if otherAccount has BLACKLIST_MEMBER_ROLE
      expect(await instance.hasRole(BLACKLIST_MEMBER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check WHITELIST_MEMBER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const WHITELIST_MEMBER_ROLE = await deployInstance.WHITELIST_MEMBER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant WHITELIST_MEMBER_ROLE to otherAccount
      await instance.grantRole(WHITELIST_MEMBER_ROLE, otherAccount.address);

      // Check if otherAccount has WHITELIST_MEMBER_ROLE
      expect(await instance.hasRole(WHITELIST_MEMBER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check MASTER_MINTER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const MASTER_MINTER_ROLE = await deployInstance.MASTER_MINTER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant MASTER_MINTER_ROLE to otherAccount
      await instance.grantRole(MASTER_MINTER_ROLE, otherAccount.address);

      // Check if otherAccount has MASTER_MINTER_ROLE
      expect(await instance.hasRole(MASTER_MINTER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check MINTER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const MINTER_ROLE = await deployInstance.MINTER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant MINTER_ROLE to otherAccount
      await instance.grantRole(MINTER_ROLE, otherAccount.address);

      // Check if otherAccount has MINTER_ROLE
      expect(await instance.hasRole(MINTER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check FEE_MANAGER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const FEE_MANAGER_ROLE = await deployInstance.FEE_MANAGER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant FEE_MANAGER_ROLE to otherAccount
      await instance.grantRole(FEE_MANAGER_ROLE, otherAccount.address);

      // Check if otherAccount has FEE_MANAGER_ROLE
      expect(await instance.hasRole(FEE_MANAGER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check FEE_HOLDER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const FEE_HOLDER_ROLE = await deployInstance.FEE_HOLDER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant FEE_HOLDER_ROLE to otherAccount
      await instance.grantRole(FEE_HOLDER_ROLE, otherAccount.address);

      // Check if otherAccount has FEE_HOLDER_ROLE
      expect(await instance.hasRole(FEE_HOLDER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should allow only PAUSER_ROLE to pause the contract", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const PAUSER_ROLE = await deployInstance.PAUSER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant PAUSER_ROLE to otherAccount
      await instance.grantRole(PAUSER_ROLE, otherAccount.address);

      //setup PAUSER_ROLE
      await instance.grantRole(await instance.PAUSER_ROLE(), owner.address);
      //setup PAUSER_ROLE ROLE_ADMIN
      await instance.setRoleAdmin(await instance.PAUSER_ROLE(), await instance.ADMIN_ROLE());

      // Pause the contract with PAUSER_ROLE
      await instance.pause();
      expect(await instance.paused()).to.be.true;

      // Unpause the contract with PAUSER_ROLE
      await instance.unpause();
      expect(await instance.paused()).to.be.false;
    });

    it("Should allow only BLACKLIST_MEMBER_ROLE to blacklist accounts", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const BLACKLIST_MEMBER_ROLE = await deployInstance.BLACKLIST_MEMBER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant BLACKLIST_MEMBER_ROLE to otherAccount
      await instance.grantRole(BLACKLIST_MEMBER_ROLE, otherAccount.address);

      //setup BLACKLIST_MANAGER_ROLE
      await instance.grantRole(await instance.BLACKLIST_MANAGER_ROLE(), admin.address);
      //setup BLACKLIST_MANAGER_ROLE ROLE_ADMIN
      await instance.setRoleAdmin(await instance.BLACKLIST_MEMBER_ROLE(), await instance.BLACKLIST_MANAGER_ROLE());

      const managerInstance = deployInstance.connect(admin) as Contract;

      // Blacklist an account with BLACKLIST_MEMBER_ROLE
      await managerInstance.addBlacklist(otherAccount.address);
      expect(await managerInstance.isBlacklisted(otherAccount.address)).to.be.true;

      // Unblacklist the account with BLACKLIST_MEMBER_ROLE
      await managerInstance.removeBlacklist(otherAccount.address);
      expect(await managerInstance.isBlacklisted(otherAccount.address)).to.be.false;
    });
  });
});
