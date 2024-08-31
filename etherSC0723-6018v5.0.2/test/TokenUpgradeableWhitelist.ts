import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";

describe("TokenUpgradeable contract", function () {
  describe("Whitelist", function () {
    it("Should whitelist the funds to the owner", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const WHITELISTER_ROLE = await deployInstance.WHITELISTER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;

      await instance.grantRole(WHITELISTER_ROLE, owner.address);
      await instance.grantRole(WHITELISTER_ROLE, otherAccount.address);

      await instance.grantRole(await instance.WHITELISTER_MANAGER_ROLE(), admin.address);

      await instance.setRoleAdmin(await instance.WHITELISTER_ROLE(), await instance.WHITELISTER_MANAGER_ROLE());

      //updateWhitelister, onlyOwner
      await instance.updateWhitelister(owner);

      // instance.updateWhitelister(owner);
      // whitelist, onlyWhitelister
      await instance.whitelist(owner);
      await instance.whitelist(otherAccount);

      expect(await instance.isWhitelisted(owner.address)).to.equal(true);
      expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);
    });
  });
});
