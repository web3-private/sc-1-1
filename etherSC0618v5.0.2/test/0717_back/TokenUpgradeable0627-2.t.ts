import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract } from "ethers";
import { splitSignature } from "@ethersproject/bytes";
import { TypedDataDomain } from "ethers";
import { BigNumberish } from "ethers";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("TokenUpgradeable contract", function () {
  async function deployTokenUpgradeableFixture() {
    const [deploy, owner, admin, feeAccount, otherAccount] = await ethers.getSigners();
    // Deploying
    const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deploy);

    const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [
      owner.address,
      admin.address,
      "jdscToken",
      "jdsc",
    ]);

    return { TokenUpgradeable, deployInstance, owner, admin, feeAccount, otherAccount };
  }

  async function deployTokenUpgradeableAndWhiteFixture() {
    const [deploy, owner, admin, feeAccount, otherAccount] = await ethers.getSigners();
    // Deploying
    const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deploy);

    const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [
      owner.address,
      admin.address,
      "jdscToken",
      "jdsc",
    ]);

    // Connect owner to the instance
    const instance = deployInstance.connect(owner) as Contract;
    //updateWhitelister, onlyOwner
    await instance.updateWhitelister(owner);
    //whitelist onlyWhitelister
    await instance.whitelist(owner);
    await instance.whitelist(admin);
    await instance.whitelist(otherAccount);

    return { TokenUpgradeable, deployInstance, owner, admin, feeAccount, otherAccount };
  }

  describe("Transfers", function () {
    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;
        //setup master minter, onlyOwner
        await instance.updateMasterMinter(owner);
        //setup minter, onlyMasterMinter MINTER_ROLE
        await instance.configureMinter(owner, 21_000_000);
        //mint, MINTER_ROLE
        await instance.mint(owner.address, 21_000_000);

        expect(await instance.isBlacklisted(owner.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);

        expect(await instance.isWhitelisted(owner.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);

        //transfer
        await instance.transfer(otherAccount, ethers.toBigInt("100"));
        const otherBalance = await instance.balanceOf(otherAccount);
        expect(otherBalance).to.equal(ethers.toBigInt("100"));

        //emit Transfer(from, to, value);
        await expect(instance.transfer(otherAccount.address, ethers.toBigInt("100")))
          .to.emit(instance, "Transfer")
          .withArgs(owner, otherAccount, 100);
      });
    });

    describe("Mint", function () {
      it("Should mint the funds to the owner", async function () {
        const { deployInstance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        //setup master minter, onlyOwner
        await instance.updateMasterMinter(owner);
        //setup minter, onlyMasterMinter MINTER_ROLE
        await instance.configureMinter(owner, 21_000_000);
        //mint, MINTER_ROLE
        await instance.mint(owner.address, 21_000_000);

        const ownerBalance = await instance.balanceOf(owner.address);
        expect(ownerBalance).to.equal(ethers.toBigInt("21000000"));
      });
    });

    describe("Blacklist", function () {
      it("Should blacklist the funds to the owner", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        expect(await instance.isBlacklisted(owner.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);
      });
    });

    describe("Whitelist", function () {
      it("Should whitelist the funds to the owner", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

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

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        //setup master minter, onlyOwner
        await instance.updateMasterMinter(owner);
        //setup minter, onlyMasterMinter MINTER_ROLE
        await instance.configureMinter(owner, 21_000_000);
        //mint, MINTER_ROLE
        await instance.mint(owner.address, 21_000_000);

        const ownerBalance = await instance.balanceOf(owner.address);
        expect(ownerBalance).to.equal(ethers.toBigInt("21000000"));

        //transfer
        await instance.transfer(otherAccount, ethers.toBigInt("100"));

        const otherBalance = await instance.balanceOf(otherAccount);
        expect(otherBalance).to.equal(ethers.toBigInt("100"));

        //erc20 token transfer check
        await expect(() => instance.transfer(otherAccount, ethers.toBigInt("100"))).to.changeTokenBalances(
          instance,
          [owner, otherAccount],
          [ethers.parseUnits("-100", 0), ethers.parseUnits("100", 0)],
        );
      });
    });

    describe("Redeem", function () {
      it("Should Redeem the funds to the owner", async function () {
        const { deployInstance, owner, feeAccount, otherAccount } = await loadFixture(
          deployTokenUpgradeableAndWhiteFixture,
        );

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        //setup master minter
        await instance.updateMasterMinter(owner);
        //setup minter
        await instance.configureMinter(owner, 21_000_000);
        await instance.configureMinter(otherAccount, 21_000_000);
        //mint
        await instance.mint(owner.address, 21_000_000);

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

        const ownerAddress = owner.address;
        const otherAccountAddress = otherAccount.address;
        const value = ethers.toBigInt("21000000");
        const nonce = await instance.nonces(otherAccount.address);
        const deadline = Math.floor(Date.now() / 1000) + 3600;

        const message = {
          owner: ownerAddress,
          spender: otherAccountAddress,
          value: value,
          nonce: nonce,
          deadline: deadline,
        };

        const signature = await owner.signTypedData(domain, types, message);
        const { v, r, s } = splitSignature(signature);

        const newBasisPoints = 15;
        const newMaxFee = 60000;
        const decimals = 18;
        //setup fee, onlyOwner
        instance.setParams(feeAccount, newBasisPoints, newMaxFee, decimals);

        // Connect owner to the instance
        const otherInstance = instance.connect(otherAccount) as Contract;

        await otherInstance.redeem(owner.address, otherAccount.address, value, deadline, v, r, s);
        const ownerBalance = await instance.balanceOf(owner.address);

        expect(ownerBalance).to.equal(ethers.toBigInt("0"));
      });
    });
  });
});
