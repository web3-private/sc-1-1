import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("TokenUpgradeable contract", function () {
  async function deployTokenUpgradeableFixture() {
    const [deploy, owner, admin, feeAccount, otherAccount] = await ethers.getSigners();
    // const signers = await ethers.getSigners()
    // console.log("signers.length:::::", signers.length);
    // Deploying
    const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deploy);

    const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [
      owner.address,
      // admin.address,
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
      // admin.address,
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
        await instance.configureMinter(owner);
        //approve
        await instance.approve(owner.address, 21_000_000);
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
        await instance.configureMinter(owner);

        //mint owner account(minter 、to => owner)
        //approve
        await instance.approve(owner.address, 21_000_000);
        //mint, MINTER_ROLE
        await instance.mint(owner.address, 21_000_000);

        const ownerBalance = await instance.balanceOf(owner.address);
        expect(ownerBalance).to.equal(ethers.toBigInt("21000000"));

        //mint otherAccount
        //approve
        await instance.approveMint(owner.address, 21_000_000);
        // await instance.approveMint(otherAccount.address, owner.address, 21_000_000);
        //mint, MINTER_ROLE
        await instance.mint(otherAccount.address, 21_000_000);

        const otherAccountBalance = await instance.balanceOf(owner.address);
        expect(otherAccountBalance).to.equal(ethers.toBigInt("21000000"));
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
        await instance.configureMinter(owner);
        //approve
        await instance.approve(owner.address, 21_000_000);
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
        await instance.configureMinter(owner);
        await instance.configureMinter(otherAccount);
        //approve
        await instance.approve(owner.address, 21_000_000);
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

  describe("Roles and Permissions", function () {
    it("Should grant and check ADMIN_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const ADMIN_ROLE = await deployInstance.ADMIN_ROLE();

      const instance = deployInstance.connect(owner) as Contract;

      // Grant ADMIN_ROLE to otherAccount
      await instance.grantRole(ADMIN_ROLE, otherAccount.address);

      // Check if otherAccount has ADMIN_ROLE
      expect(await instance.hasRole(ADMIN_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check PAUSER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const PAUSER_ROLE = await deployInstance.PAUSER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant PAUSER_ROLE to otherAccount
      await instance.grantRole(PAUSER_ROLE, otherAccount.address);

      // Check if otherAccount has PAUSER_ROLE
      expect(await instance.hasRole(PAUSER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check BLACKLISTER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const BLACKLISTER_ROLE = await deployInstance.BLACKLISTER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant BLACKLISTER_ROLE to otherAccount
      await instance.grantRole(BLACKLISTER_ROLE, otherAccount.address);

      // Check if otherAccount has BLACKLISTER_ROLE
      expect(await instance.hasRole(BLACKLISTER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check WHITELISTER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const WHITELISTER_ROLE = await deployInstance.WHITELISTER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant WHITELISTER_ROLE to otherAccount
      await instance.grantRole(WHITELISTER_ROLE, otherAccount.address);

      // Check if otherAccount has WHITELISTER_ROLE
      expect(await instance.hasRole(WHITELISTER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check MASTER_MINTER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const MASTER_MINTER_ROLE = await deployInstance.MASTER_MINTER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant MASTER_MINTER_ROLE to otherAccount
      await instance.grantRole(MASTER_MINTER_ROLE, otherAccount.address);

      // Check if otherAccount has MASTER_MINTER_ROLE
      expect(await instance.hasRole(MASTER_MINTER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check MINTER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const MINTER_ROLE = await deployInstance.MINTER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant MINTER_ROLE to otherAccount
      await instance.grantRole(MINTER_ROLE, otherAccount.address);

      // Check if otherAccount has MINTER_ROLE
      expect(await instance.hasRole(MINTER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check FEE_MANAGER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const FEE_MANAGER_ROLE = await deployInstance.FEE_MANAGER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant FEE_MANAGER_ROLE to otherAccount
      await instance.grantRole(FEE_MANAGER_ROLE, otherAccount.address);

      // Check if otherAccount has FEE_MANAGER_ROLE
      expect(await instance.hasRole(FEE_MANAGER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should grant and check FEE_HOLDER_ROLE", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const FEE_HOLDER_ROLE = await deployInstance.FEE_HOLDER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant FEE_HOLDER_ROLE to otherAccount
      await instance.grantRole(FEE_HOLDER_ROLE, otherAccount.address);

      // Check if otherAccount has FEE_HOLDER_ROLE
      expect(await instance.hasRole(FEE_HOLDER_ROLE, otherAccount.address)).to.be.true;
    });

    it("Should allow only PAUSER_ROLE to pause the contract", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);
      const PAUSER_ROLE = await deployInstance.PAUSER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant PAUSER_ROLE to otherAccount
      await instance.grantRole(PAUSER_ROLE, otherAccount.address);

      // Pause the contract with PAUSER_ROLE
      await instance.pause();
      expect(await instance.paused()).to.be.true;

      // Unpause the contract with PAUSER_ROLE
      await instance.unpause();
      expect(await instance.paused()).to.be.false;
    });

    it("Should allow only BLACKLISTER_ROLE to blacklist accounts", async function () {
      const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

      const BLACKLISTER_ROLE = await deployInstance.BLACKLISTER_ROLE();

      const instance = deployInstance.connect(owner) as Contract;
      // Grant BLACKLISTER_ROLE to otherAccount
      await instance.grantRole(BLACKLISTER_ROLE, otherAccount.address);

      // Blacklist an account with BLACKLISTER_ROLE
      await instance.blacklist(otherAccount.address);
      expect(await instance.isBlacklisted(otherAccount.address)).to.be.true;

      // Unblacklist the account with BLACKLISTER_ROLE
      await instance.unBlacklist(otherAccount.address);
      expect(await instance.isBlacklisted(otherAccount.address)).to.be.false;
    });
  });
});
