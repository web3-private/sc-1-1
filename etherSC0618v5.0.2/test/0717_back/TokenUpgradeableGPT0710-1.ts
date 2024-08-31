import { ethers } from "hardhat";
import { expect } from "chai";
import { TokenUpgradeable } from "../../typechain-types";

// import { ethers, upgrades } from "hardhat";
// import { expect } from "chai";
// // import { TokenUpgradeable, TokenUpgradeable__factory } from "../typechain";

describe("TokenUpgradeable", function () {
  async function deployTokenFixture() {
    const [owner, addr1, addr2, feeAccount, otherAccount] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("TokenUpgradeable");
    const token = await Token.deploy();
    await token.deployed();

    await token.initialize(owner.address, "Token", "TKN", 18);

    return { token, owner, addr1, addr2, feeAccount, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { token, owner } = await deployTokenFixture();
      expect(await token.owner()).to.equal(owner.address);
    });

    it("Should have the correct initial supply", async function () {
      const { token } = await deployTokenFixture();
      const totalSupply = await token.totalSupply();
      expect(totalSupply).to.equal(0);
    });
  });

  describe("Minting", function () {
    it("Should mint tokens to the right address", async function () {
      const { token, owner, addr1 } = await deployTokenFixture();
      await token.mint(addr1.address, 1000);
      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(1000);
    });
  });

  describe("Transfer", function () {
    it("Should transfer tokens between accounts", async function () {
      const { token, owner, addr1, addr2 } = await deployTokenFixture();

      await token.mint(owner.address, 1000);
      await token.transfer(addr1.address, 500);
      await token.transfer(addr2.address, 500);

      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(500);

      const addr2Balance = await token.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(500);
    });
  });

  describe("Pausable", function () {
    it("Should pause and unpause the contract", async function () {
      const { token, owner } = await deployTokenFixture();
      await token.pause();
      await expect(token.transfer(owner.address, 1000)).to.be.revertedWith("Pausable: paused");

      await token.unpause();
      await expect(token.transfer(owner.address, 1000)).to.not.be.reverted;
    });
  });

  describe("Blacklisting", function () {
    it("Should blacklist and unblacklist an account", async function () {
      const { token, owner, addr1 } = await deployTokenFixture();
      await token.blacklist(addr1.address);
      await expect(token.transfer(addr1.address, 1000)).to.be.revertedWith("Blacklistable: account is blacklisted");

      await token.unBlacklist(addr1.address);
      await expect(token.transfer(addr1.address, 1000)).to.not.be.reverted;
    });
  });

  describe("Fee Management", function () {
    it("Should correctly set and calculate fees", async function () {
      const { token, owner, feeAccount } = await deployTokenFixture();
      await token.setParams(feeAccount.address, 10, 100, 18);
      await token.mint(owner.address, 1000);
      await token.transfer(feeAccount.address, 100);

      const fee = await token.calcCommonFee(100);
      expect(fee).to.equal(10);

      const feeAccountBalance = await token.balanceOf(feeAccount.address);
      expect(feeAccountBalance).to.equal(110);
    });
  });

  describe("Whitelisting", function () {
    it("Should whitelist and unwhitelist an account", async function () {
      const { token, owner, addr1 } = await deployTokenFixture();
      await token.updateWhitelister(owner.address);
      await token._whitelist(addr1.address);
      const isWhitelisted = await token.isWhitelisted(addr1.address);
      expect(isWhitelisted).to.equal(true);

      await token._unWhitelist(addr1.address);
      const isNotWhitelisted = await token.isWhitelisted(addr1.address);
      expect(isNotWhitelisted).to.equal(false);
    });
  });
});
