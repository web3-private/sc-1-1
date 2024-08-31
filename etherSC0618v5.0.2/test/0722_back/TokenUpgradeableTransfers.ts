import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";

describe("TokenUpgradeable contract", function () {
  describe("Transfers", function () {
    describe("Validations", function () {
      it("Should transfer the funds to the owner", async function () {
        const { deployInstance, owner, admin, otherAccount, masterminter, minter1, feemanager, feehold1 } =
          await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        expect(await instance.hasRole(await instance.MASTER_MINTER_ROLE(), masterminter)).to.equal(true);
        expect(await instance.hasRole(await instance.MINTER_ROLE(), minter1)).to.equal(true);
        expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), feehold1)).to.equal(true);

        // Connect masterminter to the instance
        const masterminterInstance = deployInstance.connect(masterminter) as Contract;

        //approveMint
        await masterminterInstance.approveMint(minter1.address, 21_000_000);

        // Connect minter1 to the instance
        const minter1Instance = instance.connect(minter1) as Contract;

        //mint, MINTER_ROLE
        await minter1Instance.mint(admin.address, 21_000_000);

        // Connect masterminter to the instance
        const adminInstance = instance.connect(admin) as Contract;

        const adminBalance = await adminInstance.balanceOf(admin.address);
        expect(adminBalance).to.equal(ethers.toBigInt("21000000"));

        // Connect feemanager to the instance
        const feemanagerInstance = instance.connect(feemanager) as Contract;

        const newBasisPoints = 15; //MAX_SETTABLE_BASIS_POINTS=20
        const newMaxFee = 60000;
        const decimals = 3;
        const amount = ethers.toBigInt("1000000");

        //setup fee, onlyOwner, init common params
        await feemanagerInstance.setParams(feehold1, newBasisPoints, newMaxFee, decimals, true);

        const fee = await adminInstance.calcCommonFee(amount); // fee = amount * 15 / 1000

        const feeAccount = await adminInstance.commonFeeAccount();

        // console.log("fee::::::::::::::::", fee);
        // console.log("feeAccount:::::::::", feeAccount);
        // console.log("adminInstance.basisPointsRate()):::::::::", BigInt(await adminInstance.basisPointsRate()));
        // console.log("adminInstance.basisPointsRateDecimal()):::::::::", BigInt(await adminInstance.basisPointsRateDecimal()));
        // console.log("ssss:::::::::", (ethers.toBigInt("21000000") * BigInt(await adminInstance.basisPointsRate())) /
        // BigInt(await adminInstance.basisPointsRateDecimal()));
        // fee = value * 15 / 1000
        expect(fee).to.equal(
          (amount * BigInt(await adminInstance.basisPointsRate())) /
            BigInt(await adminInstance.basisPointsRateDecimal()),
        );

        expect(await instance.isBlacklisted(admin.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);

        expect(await instance.isWhitelisted(admin.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);

        //transfer
        await adminInstance.transfer(otherAccount, amount);

        const otherBalance = await adminInstance.balanceOf(otherAccount);
        expect(otherBalance).to.equal(amount - fee);

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

        expect(await instance.hasRole(await instance.MASTER_MINTER_ROLE(), masterminter)).to.equal(true);
        expect(await instance.hasRole(await instance.MINTER_ROLE(), minter1)).to.equal(true);
        expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), feehold1)).to.equal(true);

        // Connect masterminter to the instance
        const masterminterInstance = deployInstance.connect(masterminter) as Contract;

        //approveMint
        await masterminterInstance.approveMint(minter1.address, 21_000_000);

        // Connect minter1 to the instance
        const minter1Instance = instance.connect(minter1) as Contract;

        //mint, MINTER_ROLE
        await minter1Instance.mint(admin.address, 21_000_000);

        // Connect masterminter to the instance
        const adminInstance = instance.connect(admin) as Contract;

        const adminBalance = await adminInstance.balanceOf(admin.address);
        expect(adminBalance).to.equal(ethers.toBigInt("21000000"));

        // Connect feemanager to the instance
        const feemanagerInstance = instance.connect(feemanager) as Contract;

        const newBasisPoints = 15; //MAX_SETTABLE_BASIS_POINTS=20
        const newMaxFee = 60000;
        const decimals = 3;
        const amount = ethers.toBigInt("2000000");

        //setup fee, onlyOwner, init common params
        await feemanagerInstance.setParams(feehold1, newBasisPoints, newMaxFee, decimals, true);

        const fee = await adminInstance.calcCommonFee(amount); // fee = amount * 15 / 1000

        const feeAccount = await adminInstance.commonFeeAccount();

        // console.log("fee::::::::::::::::", fee);
        // console.log("feeAccount:::::::::", feeAccount);
        // console.log("adminInstance.basisPointsRate()):::::::::", BigInt(await adminInstance.basisPointsRate()));
        // console.log("adminInstance.basisPointsRateDecimal()):::::::::", BigInt(await adminInstance.basisPointsRateDecimal()));
        // console.log("ssss:::::::::", (ethers.toBigInt("21000000") * BigInt(await adminInstance.basisPointsRate())) /
        // BigInt(await adminInstance.basisPointsRateDecimal()));
        // fee = value * 15 / 1000
        expect(fee).to.equal(
          (amount * BigInt(await adminInstance.basisPointsRate())) /
            BigInt(await adminInstance.basisPointsRateDecimal()),
        );

        expect(await instance.isBlacklisted(admin.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);

        expect(await instance.isWhitelisted(admin.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);

        // //transfer
        // await adminInstance.transfer(otherAccount, amount);

        // const otherBalance = await adminInstance.balanceOf(otherAccount);
        // expect(otherBalance).to.equal(amount - fee);

        // const amount1 = ethers.toBigInt("20000");
        // const fee1 = await adminInstance.calcCommonFee(amount1); // fee1 = amount1 * 15 / 1000
        // //erc20 token transfer check
        // await expect(() => adminInstance.transfer(otherAccount, amount1)).to.changeTokenBalances(
        //   adminInstance,
        //   [admin, otherAccount],
        //   [-amount1, amount1 - fee1],
        // );

        // // const amount1 = ethers.toBigInt("20000");
        // const fee1 = await adminInstance.calcCommonFee(amount); // fee1 = amount1 * 15 / 1000
        //erc20 token transfer check
        await expect(() => adminInstance.transfer(otherAccount, amount)).to.changeTokenBalances(
          adminInstance,
          [admin, otherAccount],
          [-amount, amount - fee],
        );

        // // emit Transfer(from, to, value);
        // await expect(instance.transfer(otherAccount.address, ethers.toBigInt("100")))
        // .to.emit(instance, "Transfer")
        // .withArgs(owner, otherAccount, 100);

        // emit Transfer(from, feeAccount, fee);
        await expect(adminInstance.transfer(otherAccount.address, amount))
          .to.emit(adminInstance, "Transfer")
          .withArgs(admin, feeAccount, fee);

        // emit Transfer(from, to, value);
        await expect(adminInstance.transfer(otherAccount.address, amount))
          .to.emit(adminInstance, "Transfer")
          .withArgs(admin, otherAccount, amount - fee);

        // emit TokenTransfer(_msgSender(), feeAccount, amount, fee);
        await expect(adminInstance.transfer(otherAccount.address, amount))
          .to.emit(adminInstance, "TokenTransfer")
          .withArgs(admin, feeAccount, amount, fee);

        // emit TokenTransfer(_msgSender(), to, amount, sendAmount);
        await expect(adminInstance.transfer(otherAccount.address, amount))
          .to.emit(adminInstance, "TokenTransfer")
          .withArgs(admin, otherAccount, amount, amount - fee);
      });
    });
  });
});
