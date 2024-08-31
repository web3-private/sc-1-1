import "./TokenUpgradeableBlacklist";
import "./TokenUpgradeableWhitelist";
import "./TokenUpgradeableCheckRole";
import "./TokenUpgradeableMint";
import "./TokenUpgradeableRedeem";
import "./TokenUpgradeableTransfers";
import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";
import {
  approveUtil,
  removeMinterUtil,
  addFeeAccountUtil,
  removeFeeAccountUtil,
  updateFeeManagerUtil,
  updateWhitestatusUtil,
  transferFromUtil,
} from "./utils/utils";

describe("TokenUpgradeable contract other functions", function () {
  describe("query decimals", function () {
    it("Should query decimals", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const instance = deployInstance.connect(owner) as Contract;
      expect(await instance.decimals()).to.equal(3);
    });
  });

  describe("approve", function () {
    it("Should be approved for the amount", async function () {
      const { deployInstance, owner, admin, otherAccount, masterminter, minter1 } = await loadFixture(
        deployTokenUpgradeableAndWhiteFixture,
      );

      const instance = deployInstance.connect(owner) as Contract;
      await approveUtil(instance, admin, otherAccount, masterminter, minter1);

      expect(await instance.allowance(admin, otherAccount)).to.be.equal(21_000_000);
    });
  });

  describe("removeMinter", function () {
    it("Should be remove minter", async function () {
      const { deployInstance, owner, admin, otherAccount, masterminter, minter1 } = await loadFixture(
        deployTokenUpgradeableAndWhiteFixture,
      );

      const instance = deployInstance.connect(owner) as Contract;
      await removeMinterUtil(instance, masterminter, minter1);

      expect(await instance.hasRole(await instance.MINTER_ROLE(), minter1)).to.equal(false);
    });
  });

  describe("addFeeAccount", function () {
    it("Should be add fee account", async function () {
      const { deployInstance, owner, admin, otherAccount, feemanager } = await loadFixture(
        deployTokenUpgradeableAndWhiteFixture,
      );

      const instance = deployInstance.connect(owner) as Contract;
      await addFeeAccountUtil(instance, otherAccount, feemanager);

      expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), otherAccount)).to.be.true;
    });
  });

  describe("removeFeeAccount", function () {
    it("Should be remove fee account", async function () {
      const { deployInstance, owner, admin, otherAccount, feemanager, feehold1 } = await loadFixture(
        deployTokenUpgradeableAndWhiteFixture,
      );

      const instance = deployInstance.connect(owner) as Contract;
      await removeFeeAccountUtil(instance, feehold1, feemanager);

      expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), feehold1)).to.be.false;
    });
  });

  describe("updateFeeManager", function () {
    it("Should be update fee account", async function () {
      const { deployInstance, owner, admin, otherAccount, feemanager } = await loadFixture(
        deployTokenUpgradeableAndWhiteFixture,
      );

      const instance = deployInstance.connect(owner) as Contract;

      expect(await instance.hasRole(await instance.FEE_MANAGER_ROLE(), otherAccount)).to.be.false;

      await updateFeeManagerUtil(instance, owner, otherAccount);

      expect(await instance.hasRole(await instance.FEE_MANAGER_ROLE(), otherAccount)).to.be.true;
    });
  });

  describe("updateWhitestatus", function () {
    it("Should be update white status", async function () {
      const { deployInstance, owner, admin, otherAccount, whitelistManager } = await loadFixture(
        deployTokenUpgradeableAndWhiteFixture,
      );

      const instance = deployInstance.connect(owner) as Contract;

      expect(await instance.hasRole(await instance.FEE_MANAGER_ROLE(), otherAccount)).to.be.false;

      await updateWhitestatusUtil(instance, whitelistManager, true);

      expect(await instance.whitestatus()).to.be.true;

      await updateWhitestatusUtil(instance, whitelistManager, false);

      expect(await instance.whitestatus()).to.be.false;
    });

    describe("Validations", function () {
      describe("transferFrom", function () {
        it("Should  transfer the 'from' address funds to the 'to' address", async function () {
          const { deployInstance, owner, admin, otherAccount, whitelistManager, masterminter, minter1, feehold1 } =
            await loadFixture(deployTokenUpgradeableAndWhiteFixture);

          const instance = deployInstance.connect(owner) as Contract;

          const [adminBalance, otherBalance, amount] = await transferFromUtil(
            instance,
            admin,
            otherAccount,
            masterminter,
            minter1,
            feehold1,
          );

          expect(await instance.balanceOf(admin)).to.be.equal(adminBalance.valueOf() - amount.valueOf());
          expect(await instance.balanceOf(otherAccount)).to.be.equal(otherBalance.valueOf() + amount.valueOf());
        });
      });
      describe("Events", function () {
        it("Should  transfer the 'from' address funds to the 'to' address", async function () {
          const { deployInstance, owner, admin, otherAccount, whitelistManager, masterminter, minter1, feehold1 } =
            await loadFixture(deployTokenUpgradeableAndWhiteFixture);

          const instance = deployInstance.connect(owner) as Contract;

          const [adminBalance, otherBalance, amount] = await transferFromUtil(
            instance,
            admin,
            otherAccount,
            masterminter,
            minter1,
            feehold1,
          );

          expect(await instance.balanceOf(admin)).to.be.equal(adminBalance.valueOf() - amount.valueOf());
          expect(await instance.balanceOf(otherAccount)).to.be.equal(otherBalance.valueOf() + amount.valueOf());

          const amount1 = ethers.toBigInt("6000000");

          // Connect masterminter to the instance
          const adminInstance = instance.connect(admin) as Contract;

          await adminInstance.approve(masterminter, amount1);

          // Connect masterminter to the instance
          const spenderInstance = instance.connect(masterminter) as Contract;

          // emit TokenTransferFrom(_msgSender(), to, amount);
          await expect(spenderInstance.transferFrom(admin, otherAccount, amount1))
            .to.emit(spenderInstance, "TokenTransferFrom")
            .withArgs(masterminter.address, otherAccount.address, amount1);
        });
      });
    });
  });

  describe("isMinter", function () {
    it("Should be is Minter account", async function () {
      const { deployInstance, owner, admin, otherAccount, feemanager, minter1 } = await loadFixture(
        deployTokenUpgradeableAndWhiteFixture,
      );

      const instance = deployInstance.connect(owner) as Contract;

      expect(await instance.isMinter(feemanager)).to.be.false;
      expect(await instance.isMinter(otherAccount)).to.be.false;

      //setup master minter, onlyOwner
      await instance.updateMasterMinter(admin);

      // Connect admin to the instance
      const adminInstance = instance.connect(admin) as Contract;

      //setup minter, onlyMasterMinter MINTER_ROLE
      await adminInstance.addMinter(await feemanager.getAddress(), 21_000_000);
      await adminInstance.addMinter(await otherAccount.getAddress(), 21_000_000);

      expect(await instance.isMinter(feemanager)).to.be.true;
      expect(await instance.isMinter(otherAccount)).to.be.true;
    });
  });
});
