import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";

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

        expect(await instance.hasRole(await instance.MASTER_MINTER_ROLE(), masterminter)).to.equal(true);
        expect(await instance.hasRole(await instance.MINTER_ROLE(), minter1)).to.equal(true);
        expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), feehold1)).to.equal(true);

        // Connect masterminter to the instance
        const masterminterInstance = instance.connect(masterminter) as Contract;

        //approveMint
        await masterminterInstance.approveMint(minter1.address, 21_000_000);

        // Connect masterminter to the instance
        const minterInstance = instance.connect(minter1) as Contract;

        //mint
        await minterInstance.mint(admin.address, 21_000_000);
        expect(await minterInstance.balanceOf(admin.address)).to.equal(21_000_000);

        // Connect feemanager to the instance
        const feemanagerInstance = instance.connect(feemanager) as Contract;

        const newBasisPoints = 15; //MAX_SETTABLE_BASIS_POINTS=20
        const newMaxFee = 60000;
        const decimals = 3;

        //setup fee, onlyOwner, init common params
        await feemanagerInstance.setParams(feehold1, newBasisPoints, newMaxFee, decimals, true);
        //setup fee, onlyOwner
        await feemanagerInstance.setParams(feehold1, newBasisPoints, newMaxFee, decimals, false);

        const MAX_SETTABLE_BASIS_POINTS = 20;
        const points = newBasisPoints > MAX_SETTABLE_BASIS_POINTS ? MAX_SETTABLE_BASIS_POINTS : newBasisPoints;

        expect(await feemanagerInstance.feeRateAccounts(feehold1)).to.equal(points);
        const provider = owner.provider;

        const network = await provider.getNetwork();
        const chainId: BigNumberish = network.chainId;
        const contractAddress = instance.target;

        const domain: TypedDataDomain = {
          name: "jdscToken",
          version: "1",
          chainId: chainId,
          verifyingContract: contractAddress as string,
        };

        const types = {
          Permit: [
            { name: "owner", type: "address" },
            { name: "spender", type: "address" },
            { name: "value", type: "uint256" },
            { name: "nonce", type: "uint256" },
            { name: "deadline", type: "uint256" },
          ],
        };

        const adminAddress = admin.address; //token owner
        const minter1AccountAddress = minter1.address; //token spender  _msgSender()
        const value = ethers.toBigInt("21000000"); //amount
        const nonce = await instance.nonces(admin.address); // token owner nonce
        const deadline = Math.floor(Date.now() / 1000) + 3600;

        const message = {
          owner: adminAddress,
          spender: minter1AccountAddress,
          value: value,
          nonce: nonce,
          deadline: deadline,
        };

        const signature = await admin.signTypedData(domain, types, message);
        const { v, r, s } = splitSignature(signature);

        const fee = await minterInstance.calcFee(feehold1, value); // fee = value * 15 / 1000

        // await new Promise(resolve => setTimeout(resolve, 2000));

        // fee = value * 15 / 1000
        expect(fee).to.equal((value * BigInt(newBasisPoints)) / BigInt(1000));

        expect(await minterInstance.isBlacklisted(minter1.address)).to.be.false;
        expect(await minterInstance.isBlacklisted(admin.address)).to.be.false;
        expect(await minterInstance.isBlacklisted(feehold1.address)).to.be.false;

        // Connect masterminter to the instance
        const managerInstance = instance.connect(whitelistManager) as Contract;

        // setup WHITELISTER_ROLE
        await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), await feehold1.getAddress());

        expect(await managerInstance.isWhitelisted(admin.address)).to.be.true;
        expect(await managerInstance.isWhitelisted(feehold1.address)).to.be.true;

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
        expect(await instance.totalFee(feehold1)).to.equal(beforeFeeHold1TotalFee + fee);
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

        expect(await instance.hasRole(await instance.MASTER_MINTER_ROLE(), masterminter)).to.equal(true);
        expect(await instance.hasRole(await instance.MINTER_ROLE(), minter1)).to.equal(true);
        expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), feehold1)).to.equal(true);

        // Connect masterminter to the instance
        const masterminterInstance = instance.connect(masterminter) as Contract;

        //approveMint
        await masterminterInstance.approveMint(minter1.address, 21_000_000);

        // Connect masterminter to the instance
        const minterInstance = instance.connect(minter1) as Contract;

        //mint
        await minterInstance.mint(admin.address, 21_000_000);
        expect(await minterInstance.balanceOf(admin.address)).to.equal(21_000_000);

        // Connect feemanager to the instance
        const feemanagerInstance = instance.connect(feemanager) as Contract;

        const newBasisPoints = 15; //MAX_SETTABLE_BASIS_POINTS=20
        const newMaxFee = 60000;
        const decimals = 3;

        //setup fee, onlyOwner, init common params
        await feemanagerInstance.setParams(feehold1, newBasisPoints, newMaxFee, decimals, true);

        //setup fee, onlyOwner
        await feemanagerInstance.setParams(feehold1, newBasisPoints, newMaxFee, decimals, false);

        const MAX_SETTABLE_BASIS_POINTS = 20;
        const points = newBasisPoints > MAX_SETTABLE_BASIS_POINTS ? MAX_SETTABLE_BASIS_POINTS : newBasisPoints;

        expect(await feemanagerInstance.feeRateAccounts(feehold1)).to.equal(points);

        const provider = owner.provider;

        const network = await provider.getNetwork();
        const chainId: BigNumberish = network.chainId;
        const contractAddress = instance.target;

        const domain: TypedDataDomain = {
          name: "jdscToken",
          version: "1",
          chainId: chainId,
          verifyingContract: contractAddress as string,
        };

        const types = {
          Permit: [
            { name: "owner", type: "address" },
            { name: "spender", type: "address" },
            { name: "value", type: "uint256" },
            { name: "nonce", type: "uint256" },
            { name: "deadline", type: "uint256" },
          ],
        };

        const adminAddress = admin.address; //token owner
        const minter1AccountAddress = minter1.address; //token spender  _msgSender()
        const value = ethers.toBigInt("21000000"); //amount
        const nonce = await instance.nonces(admin.address); // token owner nonce
        const deadline = Math.floor(Date.now() / 1000) + 3600;

        const message = {
          owner: adminAddress,
          spender: minter1AccountAddress,
          value: value,
          nonce: nonce,
          deadline: deadline,
        };

        const signature = await admin.signTypedData(domain, types, message);
        const { v, r, s } = splitSignature(signature);

        const fee = await minterInstance.calcFee(feehold1, value); // fee = value * 15 / 1000

        // fee = value * 15 / 1000
        expect(fee).to.equal((value * BigInt(newBasisPoints)) / BigInt(1000));

        expect(await minterInstance.isBlacklisted(minter1.address)).to.be.false;
        expect(await minterInstance.isBlacklisted(admin.address)).to.be.false;
        expect(await minterInstance.isBlacklisted(feehold1.address)).to.be.false;

        // Connect masterminter to the instance
        const managerInstance = instance.connect(whitelistManager) as Contract;

        // setup WHITELISTER_ROLE
        await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), await feehold1.getAddress());

        expect(await managerInstance.isWhitelisted(admin.address)).to.be.true;
        expect(await managerInstance.isWhitelisted(feehold1.address)).to.be.true;

        // emit TokenRedeem(account, feeAccount, amount, fee);
        await expect(minterInstance.redeem(admin.address, feehold1.address, value, deadline, v, r, s))
          .to.emit(minterInstance, "TokenRedeem")
          .withArgs(admin, feehold1, value, fee);
      });
    });
  });
});
