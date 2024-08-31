import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";
import { mintUtil } from "./utils/utils";

describe("TokenUpgradeable contract", function () {
  describe("Mint", function () {
    describe("Validations", function () {
      it("Should mint the funds to the to", async function () {
        const { deployInstance, owner, admin, otherAccount, minter1 } = await loadFixture(
          deployTokenUpgradeableAndWhiteFixture,
        );

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        const beforeTotalSupply = await instance.totalSupply();
        await mintUtil(instance, admin, otherAccount, minter1);

        expect(await instance.balanceOf(otherAccount.address)).to.equal(ethers.toBigInt("21000000"));

        // totalSupply
        expect(await instance.totalSupply()).to.equal(beforeTotalSupply + ethers.toBigInt("21000000"));
      });

      it("Should mint the funds to the owner", async function () {
        const { deployInstance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        const beforeTotalSupply = await instance.totalSupply();

        await instance.incrementalMint(21_000_000);

        const ownerBalance = await instance.balanceOf(owner.address);
        expect(ownerBalance).to.equal(ethers.toBigInt("21000000"));

        // totalSupply
        expect(await instance.totalSupply()).to.equal(beforeTotalSupply + ethers.toBigInt("21000000"));
      });
    });

    describe("Events", function () {
      it("Should emit an event on mint", async function () {
        const { deployInstance, owner, admin, otherAccount, minter1 } = await loadFixture(
          deployTokenUpgradeableAndWhiteFixture,
        );

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;
        //setup master minter, onlyOwner
        await instance.updateMasterMinter(admin);

        // Connect admin to the instance
        const adminInstance = instance.connect(admin) as Contract;

        //setup minter, onlyMasterMinter MINTER_ROLE
        await adminInstance.addMinter(minter1, 21_000_000);

        //approve Mint amount
        await adminInstance.approveMint(minter1, 21_000_000);

        // Connect minter1 to the instance
        const minterInstance = adminInstance.connect(minter1) as Contract;

        // //mint, MINTER_ROLE
        // await minterInstance.mint(otherAccount.address, 21_000_000);

        //emit TokenMint(address(0), to, amount);
        await expect(await minterInstance.mint(otherAccount.address, 21_000_000))
          .to.emit(minterInstance, "TokenMint")
          .withArgs(ethers.ZeroAddress, otherAccount.address, 21_000_000);
      });
    });
  });
});
