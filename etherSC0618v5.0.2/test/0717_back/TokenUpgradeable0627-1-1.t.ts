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
    console.log("owner address:::", owner.address);
    // Deploying
    const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deploy);
    console.log("start TokenUpgradeable...");

    const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [
      owner.address,
      admin.address,
      "jdscToken",
      "jdsc",
    ]);

    return { TokenUpgradeable, deployInstance, owner, admin, feeAccount, otherAccount };
  }

  describe("Transfers", function () {
    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        //updateWhitelister, onlyOwner
        await instance.updateWhitelister(owner);
        //whitelist onlyWhitelister
        await instance.whitelist(owner);
        await instance.whitelist(otherAccount);

        //updateWhitelister, onlyOwner
        await instance.updateWhitelister(owner);
        //whitelist, onlyWhitelister
        await instance.whitelist(owner);

        //setup master minter, onlyOwner
        await instance.updateMasterMinter(owner);
        //setup minter, onlyMasterMinter MINTER_ROLE
        await instance.configureMinter(owner, 21_000_000);
        //mint, MINTER_ROLE
        await instance.mint(owner.address, 21_000_000);

        console.log("owner.address:::", owner.address);
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
        const { deployInstance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        //updateWhitelister, onlyOwner
        await instance.updateWhitelister(owner);
        //whitelist, onlyWhitelister
        await instance.whitelist(owner);

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
        //whitelist, onlyWhitelister
        await instance.whitelist(owner);
        await instance.whitelist(otherAccount);

        expect(await instance.isWhitelisted(owner.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        //updateWhitelister, onlyOwner
        await instance.updateWhitelister(owner);
        // instance.updateWhitelister(owner);
        //whitelist, onlyWhitelister
        await instance.whitelist(owner);
        await instance.whitelist(otherAccount);

        //setup master minter, onlyOwner
        await instance.updateMasterMinter(owner);
        //setup minter, onlyMasterMinter MINTER_ROLE
        await instance.configureMinter(owner, 21_000_000);
        //mint, MINTER_ROLE
        await instance.mint(owner.address, 21_000_000);

        const ownerBalance = await instance.balanceOf(owner.address);
        console.log("ownerBalance:", ownerBalance.toString());
        expect(ownerBalance).to.equal(ethers.toBigInt("21000000"));

        console.log("owner:", owner.address);
        console.log("otherAccount:", otherAccount.address);
        console.log("owner balance:", await instance.balanceOf(owner));
        console.log('ethers.parseUnits("100"):', ethers.parseUnits("100"));
        console.log('ethers.parseUnits("100"):', 100);
        console.log('ethers.parseUnits("100"):', ethers.toBigInt("100"));

        // notBlacklisted(owner) notBlacklisted(otherAccount)
        // isAddressWhitelisted(owner) isAddressWhitelisted(ownotherAccounter)
        expect(await instance.isBlacklisted(owner.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);

        expect(await instance.isWhitelisted(owner.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);

        //transfer
        await instance.transfer(otherAccount, ethers.toBigInt("100"));

        const otherBalance = await instance.balanceOf(otherAccount);
        console.log("otherBalance:", otherBalance);
        expect(otherBalance).to.equal(ethers.toBigInt("100"));

        //erc20 token transfer check
        await expect(() => instance.transfer(otherAccount, ethers.toBigInt("100"))).to.changeTokenBalances(
          instance,
          [owner, otherAccount],
          // [ethers.parseUnits("-100"), ethers.parseUnits("100")]
          [ethers.parseUnits("-100", 0), ethers.parseUnits("100", 0)],
        );
      });
    });

    describe("Redeem", function () {
      it("Should Redeem the funds to the owner", async function () {
        const { deployInstance, owner, feeAccount, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        //updateWhitelister
        await instance.updateWhitelister(owner);
        //whitelist
        await instance.whitelist(owner);
        await instance.whitelist(otherAccount);
        await instance.whitelist(feeAccount);

        //setup master minter
        await instance.updateMasterMinter(owner);
        //setup minter
        await instance.configureMinter(owner, 21_000_000);
        await instance.configureMinter(otherAccount, 21_000_000);
        //mint
        await instance.mint(owner.address, 21_000_000);

        expect(await instance.isBlacklisted(owner.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);

        expect(await instance.isWhitelisted(owner.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);

        const provider = owner.provider;
        const network = await provider.getNetwork();
        const chainId: BigNumberish = network.chainId;

        const contractAddress = instance.target;

        console.log("instance.name::::::::::", await instance.name());
        console.log("instance.nonces::::::::::", await instance.nonces(owner.address));
        // console.log("contractAddress::::::::::",instance.version());

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
        console.log("domain      : ", domain);
        console.log("types      : ", types);
        console.log("message      : ", message);
        console.log("owner      : ", ownerAddress);
        console.log("spender    : ", otherAccountAddress);
        console.log("value      : ", value);
        console.log("nonce      : ", nonce);
        console.log("deadline   : ", deadline);
        console.log("Signature11: ");
        console.log("owner: ", owner);
        const signature = await owner.signTypedData(domain, types, message);

        console.log("signature: ", signature);
        const { v, r, s } = splitSignature(signature);

        console.log("v: ", v);
        console.log("r: ", r);
        console.log("s: ", s);

        // address _feeAccount = ;
        const newBasisPoints = 15;
        const newMaxFee = 60000;
        const decimals = 18;
        //setup fee, onlyOwner
        instance.setParams(feeAccount, newBasisPoints, newMaxFee, decimals);

        // instance.setCommonParam(account, newBasisPoints, newMaxFee, _decimals);
        // instance.addFeeAccount(account, 0, newBasisPoints);

        // Connect owner to the instance
        const otherInstance = instance.connect(otherAccount) as Contract;

        await otherInstance.redeem(owner.address, otherAccount.address, value, deadline, v, r, s);

        // await otherInstance.redeemSign(owner.address, feeAccount.address, value, deadline, v, r, s);
        // await otherInstance.redeem(owner.address, feeAccount.address, value, deadline, v, r, s);
        // await instance.redeem(owner.address, feeAccount.address, value, deadline, v, r, s);
        // await instance.redeem(owner.address, feeAccount.address, ethers.toBigInt("21000000"), deadline, v, r, s);

        const ownerBalance = await instance.balanceOf(owner.address);

        console.log("redeem ownerBalance:", ownerBalance.toString());
        expect(ownerBalance).to.equal(ethers.toBigInt("0"));
      });
    });
  });
});
