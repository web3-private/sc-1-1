import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("TokenUpgradeable contract", function () {
  async function deployTokenUpgradeableFixture() {
    const [deploy, owner, admin, feeAccount, otherAccount] = await ethers.getSigners();
    // const signers = await ethers.getSigners()
    // console.log("signers.length:::::", signers.length);
    // console.log("signers.length:::::", signers.address);
    // Deploying
    const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deploy);

    const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [
      owner.address,
      // admin.address,
      "jdscToken",
      "jdsc",
      3,
    ]);

    // const ownerInstance = deployInstance.connect(owner) as Contract;

    // await setInitRoleAdmin(ownerInstance);

    // await setInitBlackListerRole(ownerInstance);

    // await setInitWhiteListerRole(ownerInstance);

    // await setInitMinterRole(ownerInstance);

    // await setInitFeeHoldRole(ownerInstance);
    return { TokenUpgradeable, deployInstance, owner, admin, feeAccount, otherAccount };
  }

  async function deployTokenUpgradeableAndWhiteFixture() {
    const [
      deploy,
      owner,
      admin,
      feeAccount,
      otherAccount,
      pauser,
      blacklistManager,
      whitelistManager,
      masterminter,
      feemanager,
      blacklist1,
      minter1,
      feehold1,
    ] = await ethers.getSigners();
    // console.log("deploy::",deploy.address+ ": owner:"+ owner.address +":admin:"+admin.address+":feeAccount:"
    //   +feeAccount.address+":otherAccount:"+otherAccount.address+":pauser:"+pauser.address+":blacklistManager:"+blacklistManager.address
    //   +":whitelistManager:"+whitelistManager.address+":masterminter:"+masterminter.address+":feemanager:"+feemanager.address);
    // console.log("deploy::",deploy+ ": owner:"+ owner +":admin:"+admin+":feeAccount:"
    //   +feeAccount+":otherAccount:"+otherAccount+":pauser:"+pauser+":blacklistManager:"+blacklistManager
    //   +":whitelistManager:"+whitelistManager+":masterminter:"+masterminter+":feemanager:"+feemanager);
    // ethers.Signer dd = owner;
    // const [deploy, owner, admin, feeAccount, otherAccount] = await ethers.getSigners();
    // Deploying
    const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deploy);

    const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [
      owner.address,
      // admin.address,
      "jdscToken",
      "jdsc",
      3,
    ]);

    // // Connect owner to the instance
    // const instance = deployInstance.connect(owner) as Contract;
    // //updateWhitelister, onlyOwner
    // console.log("updateWhitelister::::::::");
    // await instance.updateWhitelister(owner);
    // console.log("whitelist::::::::");
    // //whitelist onlyWhitelister
    // await instance.whitelist(owner);
    // await instance.whitelist(admin);
    // await instance.whitelist(otherAccount);

    // const ownerInstance = instance.connect(owner) as Contract;

    const ownerInstance = deployInstance.connect(owner) as Contract;

    console.log("setInitRoleAdmin::::::::");
    await setInitRoleAdmin(ownerInstance, pauser, blacklistManager, whitelistManager, masterminter, feemanager);

    console.log("setInitBlackListerRole::::::::");
    await setInitBlackListerRole(ownerInstance, blacklistManager, blacklist1);

    console.log("setInitWhiteListerRole::::::::");
    await setInitWhiteListerRole(ownerInstance, whitelistManager, owner, admin, otherAccount);

    console.log("setInitMinterRole::::::::");
    await setInitMinterRole(ownerInstance, masterminter, minter1);

    console.log("setInitFeeHoldRole::::::::");
    await setInitFeeHoldRole(ownerInstance, feemanager, feehold1);

    return { TokenUpgradeable, deployInstance, owner, admin, feeAccount, otherAccount };
  }

  async function setInitRoleAdmin(
    instance: Contract,
    pauser: Signer,
    blacklistManager: Signer,
    whitelistManager: Signer,
    masterminter: Signer,
    feemanager: Signer,
  ) {
    //setup PAUSER_ROLE
    await instance.grantRole(await instance.PAUSER_ROLE(), await pauser.getAddress());
    console.log("grantRole PAUSER_ROLE                              :::::", await pauser.getAddress());
    //setup PAUSER_ROLE ROLE_ADMIN
    console.log("SET_ROLE_ADMIN ADMIN_ROLE await                    :::::", await instance.ADMIN_ROLE());
    await instance.setRoleAdmin(await instance.PAUSER_ROLE(), await instance.ADMIN_ROLE());

    //setup BLACKLISTER_MANAGER_ROLE
    await instance.grantRole(await instance.BLACKLISTER_MANAGER_ROLE(), await blacklistManager.getAddress());
    console.log("grantRole BLACKLISTER_MANAGER_ROLE                 :::::", await blacklistManager.getAddress());
    //setup BLACKLISTER_MANAGER_ROLE ROLE_ADMIN
    console.log("SET_ROLE_ADMIN BLACKLISTER_MANAGER_ROLE await      :::::", await instance.BLACKLISTER_MANAGER_ROLE());
    await instance.setRoleAdmin(await instance.BLACKLISTER_ROLE(), await instance.BLACKLISTER_MANAGER_ROLE());

    //setup WHITELISTER_MANAGER_ROLE
    await instance.grantRole(await instance.WHITELISTER_MANAGER_ROLE(), await whitelistManager.getAddress());
    console.log("grantRole WHITELISTER_MANAGER_ROLE                 :::::", await whitelistManager.getAddress());
    //setup WHITELISTER_MANAGER_ROLE ROLE_ADMIN
    console.log("SET_ROLE_ADMIN WHITELISTER_MANAGER_ROLE await      :::::", await instance.WHITELISTER_MANAGER_ROLE());
    await instance.setRoleAdmin(await instance.WHITELISTER_ROLE(), await instance.WHITELISTER_MANAGER_ROLE());

    //setup MASTER_MINTER_ROLE
    await instance.grantRole(await instance.MASTER_MINTER_ROLE(), await masterminter.getAddress());
    console.log("grantRole MASTER_MINTER_ROLE                       :::::", await masterminter.getAddress());
    //setup MASTER_MINTER_ROLE ROLE_ADMIN
    console.log("SET_ROLE_ADMIN MASTER_MINTER_ROLE await            :::::", await instance.MASTER_MINTER_ROLE());
    await instance.setRoleAdmin(await instance.MINTER_ROLE(), await instance.MASTER_MINTER_ROLE());

    //setup FEE_MANAGER_ROLE
    await instance.grantRole(await instance.FEE_MANAGER_ROLE(), await feemanager.getAddress());
    console.log("grantRole FEE_MANAGER_ROLE                         :::::", await feemanager.getAddress());
    //setup FEE_MANAGER_ROLE ROLE_ADMIN
    console.log("SET_ROLE_ADMIN FEE_MANAGER_ROLE await              :::::", await instance.FEE_MANAGER_ROLE());
    await instance.setRoleAdmin(await instance.FEE_HOLDER_ROLE(), await instance.FEE_MANAGER_ROLE());
  }

  async function setInitBlackListerRole(instance: Contract, blacklistManager: Signer, blacklist: Signer) {
    // const blacklistManager = new ethers.Wallet(process.env.blacklistManagerPk as string, ethers.provider);
    // console.log("blacklistManager address                 :::::", blacklistManager.address);
    console.log("blacklistManager address                 :::::", await blacklistManager.getAddress());
    const managerInstance = instance.connect(blacklistManager) as Contract;

    //setup BLACKLISTER_ROLE
    // await managerInstance.grantRole(await managerInstance.BLACKLISTER_ROLE(), process.env.blacklist);
    // console.log("grantRole BLACKLISTER_ROLE               :::::", process.env.blacklist);
    await managerInstance.grantRole(await managerInstance.BLACKLISTER_ROLE(), await blacklist.getAddress());
    console.log("grantRole BLACKLISTER_ROLE               :::::", await blacklist.getAddress());
  }

  async function setInitWhiteListerRole(
    instance: Contract,
    // pauser: Signer,
    // blacklistManager: Signer,
    whitelistManager: Signer,
    owner: Signer,
    admin: Signer,
    otherAccount: Signer,
  ) {
    // const whitelistManager = new ethers.Wallet(process.env.whitelistManagerPk as string, ethers.provider);
    // console.log("whitelistManager address                 :::::", whitelistManager.address);
    console.log("whitelistManager address                 :::::", await whitelistManager.getAddress());
    const managerInstance = instance.connect(whitelistManager) as Contract;

    // await instance.whitelist(owner);
    // await instance.whitelist(admin);
    // await instance.whitelist(otherAccount);

    //setup WHITELISTER_ROLE
    // await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), process.env.whitelist);
    // console.log("grantRole WHITELISTER_ROLE               :::::", process.env.whitelist);
    await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), await owner.getAddress());
    console.log("grantRole WHITELISTER_ROLE               :::::", await owner.getAddress());

    await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), await admin.getAddress());
    console.log("grantRole WHITELISTER_ROLE               :::::", await admin.getAddress());

    await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), await otherAccount.getAddress());
    console.log("grantRole WHITELISTER_ROLE               :::::", await otherAccount.getAddress());
  }

  async function setInitMinterRole(instance: Contract, masterminter: Signer, minter: Signer) {
    // const masterminter = new ethers.Wallet(process.env.masterminterPk as string, ethers.provider);
    // console.log("masterminter address                     :::::", masterminter.address);
    console.log("masterminter address                     :::::", await masterminter.getAddress());
    const managerInstance = instance.connect(masterminter) as Contract;

    //setup MINTER_ROLE
    // await managerInstance.grantRole(await managerInstance.MINTER_ROLE(), process.env.minter);
    // console.log("grantRole MINTER_ROLE                    :::::", process.env.minter);
    await managerInstance.grantRole(await managerInstance.MINTER_ROLE(), await minter.getAddress());
    console.log("grantRole MINTER_ROLE                    :::::", await minter.getAddress());
  }

  async function setInitFeeHoldRole(instance: Contract, feemanager: Signer, feehold: Signer) {
    // const feemanager = new ethers.Wallet(process.env.feemanagerPk as string, ethers.provider);
    // console.log("masterminter address                     :::::", feemanager.address);
    console.log("masterminter address                     :::::", await feemanager.getAddress());
    const managerInstance = instance.connect(feemanager) as Contract;

    //setup FEE_HOLDER_ROLE
    await managerInstance.grantRole(await managerInstance.FEE_HOLDER_ROLE(), await feehold.getAddress());
    console.log("grantRole FEE_HOLDER_ROLE                :::::", await feehold.getAddress());
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
        await instance.addMinter(owner, 21_000_000);
        // //approve
        // await instance.approve(owner.address, 21_000_000);
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
        await instance.addMinter(owner, 21_000_000);

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

        const WHITELISTER_ROLE = await deployInstance.WHITELISTER_ROLE();

        const instance = deployInstance.connect(owner) as Contract;
        // Grant BLACKLISTER_ROLE to otherAccount
        await instance.grantRole(WHITELISTER_ROLE, owner.address);
        await instance.grantRole(WHITELISTER_ROLE, otherAccount.address);

        //setup WHITELISTER_MANAGER_ROLE
        await instance.grantRole(await instance.WHITELISTER_MANAGER_ROLE(), admin.address);
        //setup WHITELISTER_MANAGER_ROLE ROLE_ADMIN
        await instance.setRoleAdmin(await instance.WHITELISTER_ROLE(), await instance.WHITELISTER_MANAGER_ROLE());

        const managerInstance = deployInstance.connect(admin) as Contract;

        // // Connect owner to the instance
        // const instance = deployInstance.connect(owner) as Contract;

        // //updateWhitelister, onlyOwner
        // await instance.updateWhitelister(owner);

        // // instance.updateWhitelister(owner);
        // // whitelist, onlyWhitelister
        // await instance.whitelist(owner);
        // await instance.whitelist(otherAccount);

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
        await instance.addMinter(owner, 21_000_000);
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
        await instance.addMinter(owner, 21_000_000);
        await instance.addMinter(otherAccount, 21_000_000);
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
        const decimals = 3;
        //setup fee, onlyOwner
        instance.setParams(feeAccount, newBasisPoints, newMaxFee, decimals);

        // Connect owner to the instance
        const ownerInstance = instance.connect(owner) as Contract;

        // setup fee manager
        await ownerInstance.updateFeeManager(otherAccount.address);
        // await otherInstance.updateFeeManager(otherAccount.address);

        const otherInstance = instance.connect(otherAccount) as Contract;

        //setup fee account
        await otherInstance.addFeeAccount(otherAccount);

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

      //setup PAUSER_ROLE
      await instance.grantRole(await instance.PAUSER_ROLE(), owner.address);
      //setup PAUSER_ROLE ROLE_ADMIN
      await instance.setRoleAdmin(await instance.PAUSER_ROLE(), await instance.ADMIN_ROLE());

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

      //setup BLACKLISTER_MANAGER_ROLE
      await instance.grantRole(await instance.BLACKLISTER_MANAGER_ROLE(), admin.address);
      //setup BLACKLISTER_MANAGER_ROLE ROLE_ADMIN
      await instance.setRoleAdmin(await instance.BLACKLISTER_ROLE(), await instance.BLACKLISTER_MANAGER_ROLE());

      const managerInstance = deployInstance.connect(admin) as Contract;

      // Blacklist an account with BLACKLISTER_ROLE
      await managerInstance.blacklist(otherAccount.address);
      expect(await managerInstance.isBlacklisted(otherAccount.address)).to.be.true;

      // Unblacklist the account with BLACKLISTER_ROLE
      await managerInstance.unBlacklist(otherAccount.address);
      expect(await managerInstance.isBlacklisted(otherAccount.address)).to.be.false;
    });
  });
});
