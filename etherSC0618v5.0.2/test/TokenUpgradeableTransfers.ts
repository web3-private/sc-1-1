import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";
import { transferUtil } from "./utils/utils";

describe("TokenUpgradeable contract", function () {
  describe("Transfers", function () {
    describe("Validations", function () {
      it("Should transfer the funds to the owner", async function () {
        const { deployInstance, owner, admin, otherAccount, masterminter, minter1, feemanager, feehold1 } =
          await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        const result = await transferUtil(instance, admin, otherAccount, masterminter, feemanager, minter1, feehold1);

        const feeAccount = result[0];
        const beforeFeeHold1TotalFee = result[1];
        const fee = result[2];
        const amount = result[3];

        // Connect masterminter to the instance
        const adminInstance = instance.connect(admin) as Contract;

        // total feeHolder
        expect(await instance.totalFee(feeAccount)).to.equal(beforeFeeHold1TotalFee.valueOf() + fee.valueOf());

        // const otherBalance = await instance.balanceOf(otherAccount);
        const otherBalance = await adminInstance.balanceOf(otherAccount);
        expect(otherBalance).to.equal(amount.valueOf() - fee.valueOf());

        const amount1 = ethers.toBigInt("20000");
        const fee1 = await adminInstance.calcCommonFee(amount1); // fee1 = amount1 * 15 / 1000
        //erc20 token transfer check
        await expect(() => adminInstance.transfer(otherAccount, amount1)).to.changeTokenBalances(
          adminInstance,
          [admin, otherAccount],
          [-amount1, amount1 - fee1],
        );
      });
    });

    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { deployInstance, owner, admin, otherAccount, masterminter, minter1, feemanager, feehold1 } =
          await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        const result = await transferUtil(instance, admin, otherAccount, masterminter, feemanager, minter1, feehold1);

        const feeAccount = result[0];
        const beforeFeeHold1TotalFee = result[1];
        const fee = result[2];
        const amount = result[3];

        // Connect masterminter to the instance
        const adminInstance = instance.connect(admin) as Contract;

        //erc20 token transfer check
        await expect(() => adminInstance.transfer(otherAccount, amount)).to.changeTokenBalances(
          adminInstance,
          [admin, otherAccount],
          [-amount, amount.valueOf() - fee.valueOf()],
        );

        // emit Transfer(from, feeAccount, fee);
        await expect(adminInstance.transfer(otherAccount.address, amount))
          .to.emit(adminInstance, "Transfer")
          .withArgs(admin, feeAccount, fee);

        // emit Transfer(from, to, value);
        await expect(adminInstance.transfer(otherAccount.address, amount))
          .to.emit(adminInstance, "Transfer")
          .withArgs(admin, otherAccount, amount.valueOf() - fee.valueOf());

        const msgSenderBalance = await adminInstance.balanceOf(admin);

        if (fee.valueOf() > 0) {
          // emit TokenTransfer(_msgSender(), feeAccount, msgSenderBalance, amount, fee);
          await expect(adminInstance.transfer(otherAccount.address, amount))
            .to.emit(adminInstance, "TokenTransfer")
            .withArgs(admin, feeAccount, msgSenderBalance, amount, fee);
        }

        const msgSenderBalance1 = msgSenderBalance - amount.valueOf();
        // emit TokenTransfer(_msgSender(), to, msgSenderBalance, amount, sendAmount);
        await expect(adminInstance.transfer(otherAccount.address, amount))
          .to.emit(adminInstance, "TokenTransfer")
          .withArgs(admin.address, otherAccount.address, msgSenderBalance1, amount, amount.valueOf() - fee.valueOf());
      });
    });
  });
});
