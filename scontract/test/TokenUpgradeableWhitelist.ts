import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";

describe("TokenUpgradeable contract", function () {
  describe("Whitelist", function () {
    it("Should whitelist the  address", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const WHITELIST_MEMBER_ROLE = await deployInstance.WHITELIST_MEMBER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;

      await instance.grantRole(WHITELIST_MEMBER_ROLE, owner.address);
      await instance.grantRole(WHITELIST_MEMBER_ROLE, otherAccount.address);

      await instance.grantRole(await instance.WHITELIST_MANAGER_ROLE(), admin.address);

      await instance.setRoleAdmin(await instance.WHITELIST_MEMBER_ROLE(), await instance.WHITELIST_MANAGER_ROLE());

      //updateWhitelistManager, onlyOwner
      await instance.updateWhitelistManager(owner);

      // instance.updateWhitelistManager(owner);
      // addWhitelist, onlyWhitelister
      await instance.addWhitelist(owner);
      await instance.addWhitelist(otherAccount);

      expect(await instance.isWhitelisted(owner.address)).to.equal(true);
      expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);

      await instance.removeWhitelist(owner);
      await instance.removeWhitelist(otherAccount);

      expect(await instance.isWhitelisted(owner.address)).to.equal(false);
      expect(await instance.isWhitelisted(otherAccount.address)).to.equal(false);
    });

    it("Should whitelist the  address list", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const WHITELIST_MEMBER_ROLE = await deployInstance.WHITELIST_MEMBER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;

      await instance.grantRole(WHITELIST_MEMBER_ROLE, owner.address);
      await instance.grantRole(WHITELIST_MEMBER_ROLE, otherAccount.address);

      await instance.grantRole(await instance.WHITELIST_MANAGER_ROLE(), admin.address);

      await instance.setRoleAdmin(await instance.WHITELIST_MEMBER_ROLE(), await instance.WHITELIST_MANAGER_ROLE());

      //updateWhitelistManager, onlyOwner
      await instance.updateWhitelistManager(owner);

      // instance.updateWhitelistManager(owner);
      // addWhitelist, onlyWhitelister
      const beforeList = [owner, otherAccount];
      await instance.batchAddWhitelist(beforeList);

      expect(await instance.isWhitelisted(owner.address)).to.equal(true);
      expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);
    });
  });
});
