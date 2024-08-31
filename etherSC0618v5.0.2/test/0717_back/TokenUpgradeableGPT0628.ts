import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
// import { Contract } from "ethers";
import { Contract, BigNumberish } from "ethers";
import { splitSignature } from "@ethersproject/bytes";
import { TypedDataDomain } from "ethers";
import { BigNumber } from "@ethersproject/bignumber";
// import { TypedDataDomain, BigNumber } from "@ethersproject/bignumber";
// import { BigNumberish } from "ethers";

import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("TokenUpgradeable contract", function () {
  async function deployTokenUpgradeableFixture() {
    const [deployer, owner, admin, feeAccount, otherAccount] = await ethers.getSigners();
    
    // 部署 TokenUpgradeable 合约
    const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deployer);
    const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [
      owner.address,
      "jdscToken",
      "jdsc",
    ]);

    await deployInstance.deployed();

    return { TokenUpgradeable, deployInstance, owner, admin, feeAccount, otherAccount };
  }

  async function deployTokenUpgradeableAndWhiteFixture() {
    const [deployer, owner, admin, feeAccount, otherAccount] = await ethers.getSigners();

    // 部署 TokenUpgradeable 合约
    const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deployer);
    const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [
      owner.address,
      "jdscToken",
      "jdsc",
    ]);

    await deployInstance.deployed();

    // Connect owner to the instance
    const instance = deployInstance.connect(owner) as Contract;
    
    // 设置白名单
    await instance.updateWhitelister(owner.address);
    await instance.whitelist(owner.address);
    await instance.whitelist(admin.address);
    await instance.whitelist(otherAccount.address);

    return { TokenUpgradeable, deployInstance, owner, admin, feeAccount, otherAccount };
  }

  describe("Transfers", function () {
    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { deployInstance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        // 设置主铸币者
        await instance.updateMasterMinter(owner.address);
        
        // 配置铸币者
        await instance.configureMinter(owner.address);
        
        // 批准铸币
        await instance.approve(owner.address, 21000000);
        
        // 铸币
        await instance.mint(owner.address, 21000000);

        expect(await instance.isBlacklisted(owner.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);

        expect(await instance.isWhitelisted(owner.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);

        // 转账
        await instance.transfer(otherAccount.address, BigNumber.from("100"));
        const otherBalance = await instance.balanceOf(otherAccount.address);
        expect(otherBalance).to.equal(BigNumber.from("100"));

        // 验证事件
        await expect(instance.transfer(otherAccount.address, BigNumber.from("100")))
          .to.emit(instance, "Transfer")
          .withArgs(owner.address, otherAccount.address, BigNumber.from("100"));
      });
    });

    describe("Mint", function () {
      it("Should mint the funds to the owner", async function () {
        const { deployInstance, owner } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        // 设置主铸币者
        await instance.updateMasterMinter(owner.address);
        
        // 配置铸币者
        await instance.configureMinter(owner.address);
        
        // 批准铸币
        await instance.approve(owner.address, 21000000);
        
        // 铸币
        await instance.mint(owner.address, 21000000);

        const ownerBalance = await instance.balanceOf(owner.address);
        expect(ownerBalance).to.equal(BigNumber.from("21000000"));
      });
    });

    describe("Blacklist", function () {
      it("Should not have blacklisted addresses initially", async function () {
        const { deployInstance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        expect(await instance.isBlacklisted(owner.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);
      });
    });

    describe("Whitelist", function () {
      it("Should whitelist the owner and other accounts", async function () {
        const { deployInstance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        // 更新白名单管理员
        await instance.updateWhitelister(owner.address);
        
        // 添加白名单
        await instance.whitelist(owner.address);
        await instance.whitelist(otherAccount.address);

        expect(await instance.isWhitelisted(owner.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to another account", async function () {
        const { deployInstance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        // 设置主铸币者
        await instance.updateMasterMinter(owner.address);
        
        // 配置铸币者
        await instance.configureMinter(owner.address);
        
        // 批准铸币
        await instance.approve(owner.address, 21000000);
        
        // 铸币
        await instance.mint(owner.address, 21000000);

        const ownerBalance = await instance.balanceOf(owner.address);
        expect(ownerBalance).to.equal(BigNumber.from("21000000"));

        // 转账
        await instance.transfer(otherAccount.address, BigNumber.from("100"));

        const otherBalance = await instance.balanceOf(otherAccount.address);
        expect(otherBalance).to.equal(BigNumber.from("100"));

        // 验证转账
        await expect(() => instance.transfer(otherAccount.address, BigNumber.from("100"))).to.changeTokenBalances(
          instance,
          [owner, otherAccount],
          [BigNumber.from("-100"), BigNumber.from("100")]
        );
      });
    });

    describe("Redeem", function () {
      it("Should redeem the funds to the owner", async function () {
        const { deployInstance, owner, feeAccount, otherAccount } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;

        // 设置主铸币者
        await instance.updateMasterMinter(owner.address);
        
        // 配置铸币者
        await instance.configureMinter(owner.address);
        await instance.configureMinter(otherAccount.address);
        
        // 批准铸币
        await instance.approve(owner.address, 21000000);
        
        // 铸币
        await instance.mint(owner.address, 21000000);

        const provider = owner.provider;
        const network = await provider.getNetwork();
        const chainId: BigNumberish = network.chainId;
        const contractAddress = await instance.getAddress();

        const domain: TypedDataDomain = {
          name: "jdscToken",
          version: "1",
          chainId: chainId,
          verifyingContract: contractAddress,
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
        const value = BigNumber.from("21000000");
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

        // 设置手续费
        await instance.setParams(feeAccount.address, newBasisPoints, newMaxFee, decimals);

        // 连接到其他账户
        const otherInstance = instance.connect(otherAccount) as Contract;

        await otherInstance.redeem(owner.address, otherAccount.address, value, deadline, v, r, s);
        // await otherInstance.redeem(owner.address, otherAccount.address,
        // }
      });
    });
    // }
  });
});