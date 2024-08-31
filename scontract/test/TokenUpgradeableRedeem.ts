import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer, Provider } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

import { deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";
import { redeemUtil } from "./utils/utils";

describe("TokenUpgradeable contract", function () {
  describe("Redeem", function () {
    describe("Validations", function () {
      it("Should Redeem the funds to the owner", async function () {
        const {
          deployInstance,
          owner,
          admin,
          otherAccount,
          feeAccount,
          whitelistManager,
          masterminter,
          feemanager,
          minter1,
          feehold1,
        } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        const result = await redeemUtil(
          deployInstance,
          owner.provider,
          admin,
          whitelistManager,
          masterminter,
          feemanager,
          minter1,
          feehold1,
        );

        const fee = result[0];
        const value = result[1];
        const deadline = result[2];
        const v = result[3];
        const r = result[4];
        const s = result[5];

        // Connect masterminter to the instance
        const minterInstance = instance.connect(minter1) as Contract;

        //account, _msgSender()
        const beforeAllowance = await instance.allowance(admin.address, minter1);

        const beforeFeeHold1TotalFee = await instance.totalFee(feehold1);
        // redeem
        await minterInstance.redeem(admin.address, feehold1.address, value, deadline, v, r, s);
        const ownerBalance = await minterInstance.balanceOf(admin.address);

        expect(ownerBalance).to.equal(ethers.toBigInt("0"));

        // allowance
        expect(await instance.allowance(admin.address, minter1)).to.equal(beforeAllowance);

        // total feeHolder
        expect(await instance.totalFee(feehold1)).to.equal(beforeFeeHold1TotalFee.valueOf() + fee.valueOf());
      });
    });

    describe("Events", function () {
      it("Should emit an event on redeem", async function () {
        const {
          deployInstance,
          owner,
          admin,
          otherAccount,
          feeAccount,
          whitelistManager,
          masterminter,
          feemanager,
          minter1,
          feehold1,
        } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        const result = await redeemUtil(
          deployInstance,
          owner.provider,
          admin,
          whitelistManager,
          masterminter,
          feemanager,
          minter1,
          feehold1,
        );

        const fee = result[0];
        const value = result[1];
        const deadline = result[2];
        const v = result[3];
        const r = result[4];
        const s = result[5];

        // Connect masterminter to the instance
        const minterInstance = instance.connect(minter1) as Contract;

        // emit TokenRedeem(account, feeAccount, amount, fee);
        await expect(await minterInstance.redeem(admin.address, feehold1.address, value, deadline, v, r, s))
          .to.emit(minterInstance, "TokenRedeem")
          .withArgs(admin, feehold1, value, fee);
      });
    });
  });
});
