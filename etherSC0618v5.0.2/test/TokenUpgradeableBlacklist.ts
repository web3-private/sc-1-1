import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";

describe("TokenUpgradeable contract", function () {
  describe("Blacklist", function () {
    describe("Validations", function () {
      it("Should blacklist the  address", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        const instance = deployInstance.connect(owner) as Contract;

        await instance.grantRole(await instance.BLACKLIST_MANAGER_ROLE(), admin.address);
        await instance.setRoleAdmin(await instance.BLACKLIST_MEMBER_ROLE(), await instance.BLACKLIST_MANAGER_ROLE());

        await instance.updateBlacklistManager(admin);
        expect(await instance.hasRole(await instance.BLACKLIST_MANAGER_ROLE(), admin.address)).to.equal(true);

        const managerInstance = instance.connect(admin) as Contract;

        await managerInstance.addBlacklist(owner);
        await managerInstance.addBlacklist(otherAccount);

        expect(await instance.isBlacklisted(owner.address)).to.equal(true);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(true);

        await managerInstance.removeBlacklist(owner);
        await managerInstance.removeBlacklist(otherAccount);

        expect(await managerInstance.isBlacklisted(owner.address)).to.equal(false);
        expect(await managerInstance.isBlacklisted(otherAccount.address)).to.equal(false);
      });

      it("Should blacklist the address list", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        const instance = deployInstance.connect(owner) as Contract;

        await instance.grantRole(await instance.BLACKLIST_MANAGER_ROLE(), admin.address);
        await instance.setRoleAdmin(await instance.BLACKLIST_MEMBER_ROLE(), await instance.BLACKLIST_MANAGER_ROLE());

        await instance.updateBlacklistManager(admin);
        expect(await instance.hasRole(await instance.BLACKLIST_MANAGER_ROLE(), admin.address)).to.equal(true);

        const managerInstance = instance.connect(admin) as Contract;

        const beforeList = [owner, otherAccount];
        await managerInstance.batchAddBlacklist(beforeList);

        expect(await instance.isBlacklisted(owner.address)).to.equal(true);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(true);

        await managerInstance.removeBlacklist(owner);
        await managerInstance.removeBlacklist(otherAccount);

        expect(await managerInstance.isBlacklisted(owner.address)).to.equal(false);
        expect(await managerInstance.isBlacklisted(otherAccount.address)).to.equal(false);
      });
    });

    describe("Events", function () {
      it("Should emit an event on UpdateBlacklistManager", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        const instance = deployInstance.connect(owner) as Contract;

        // await instance.grantRole(await instance.BLACKLIST_MANAGER_ROLE(), admin.address);
        await instance.setRoleAdmin(await instance.BLACKLIST_MEMBER_ROLE(), await instance.BLACKLIST_MANAGER_ROLE());

        expect(await instance.hasRole(await instance.BLACKLIST_MANAGER_ROLE(), admin.address)).to.equal(false);

        //emit RoleGranted(role, account, _msgSender());
        await expect(await instance.updateBlacklistManager(admin))
          .to.emit(instance, "RoleGranted")
          .withArgs(await instance.BLACKLIST_MANAGER_ROLE(), admin, owner);

        //emit event UpdateBlacklistManager(address indexed newManager);
        await expect(await instance.updateBlacklistManager(otherAccount.address))
          .to.emit(instance, "UpdateBlacklistManager")
          .withArgs(otherAccount.address);
      });
    });
  });
});
