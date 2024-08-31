import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";

describe("TokenUpgradeable contract", function () {
  describe("Blacklist", function () {
    it("Should blacklist the funds to the owner", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const instance = deployInstance.connect(owner) as Contract;

      await instance.grantRole(await instance.BLACKLISTER_MANAGER_ROLE(), admin.address);
      await instance.setRoleAdmin(await instance.BLACKLISTER_ROLE(), await instance.BLACKLISTER_MANAGER_ROLE());

      await instance.updateBlacklister(admin);
      expect(await instance.hasRole(await instance.BLACKLISTER_MANAGER_ROLE(), admin.address)).to.equal(true);

      const managerInstance = instance.connect(admin) as Contract;

      await managerInstance.blacklist(owner);
      await managerInstance.blacklist(otherAccount);

      expect(await instance.isBlacklisted(owner.address)).to.equal(true);
      expect(await instance.isBlacklisted(otherAccount.address)).to.equal(true);

      await managerInstance.unBlacklist(owner);
      await managerInstance.unBlacklist(otherAccount);

      expect(await managerInstance.isBlacklisted(owner.address)).to.equal(false);
      expect(await managerInstance.isBlacklisted(otherAccount.address)).to.equal(false);
    });
  });
});
