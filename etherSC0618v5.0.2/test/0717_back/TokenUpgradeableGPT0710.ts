import { expect } from "chai";
// import { upgrades } from "hardhat";
import { ethers, upgrades } from "hardhat";
// import { ethers } from "ethers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
// const eth = require('ethers');
// import { Contract, TypedDataDomain, Numeric, BigNumberish } from "ethers";

async function deployTokenUpgradeableFixture() {
  const [owner, addr1, addr2, feeAccount] = await ethers.getSigners();

  const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable");
  const token = (await upgrades.deployProxy(TokenUpgradeable, [owner.address, "Token", "TKN", 18], {
    initializer: "initialize",
  })) as any;
  //   const token = await upgrades.deployProxy(TokenUpgradeable, [owner.address, "Token", "TKN", 18], { initializer: 'initialize' });
  //   await token.deployed();
  return { token, owner, addr1, addr2, feeAccount };
}

describe("TokenUpgradeable", function () {
  it("should initialize correctly", async function () {
    const { token, owner } = await loadFixture(deployTokenUpgradeableFixture);
    expect(await token.name()).to.equal("Token");
    expect(await token.symbol()).to.equal("TKN");
    expect(await token.decimals()).to.equal(18);
  });

  it("should mint tokens", async function () {
    const { token, owner, addr1 } = await loadFixture(deployTokenUpgradeableFixture);
    await token.updateMasterMinter(owner.address);
    await token.addMinter(owner.address, ethers.parseUnits("1000", 18));

    await token.mint(addr1.address, ethers.parseUnits("100", 18));
    expect(await token.balanceOf(addr1.address)).to.equal(ethers.parseUnits("100", 18));
  });

  it("should transfer tokens with fee", async function () {
    const { token, owner, addr1, addr2, feeAccount } = await loadFixture(deployTokenUpgradeableFixture);
    await token.updateMasterMinter(owner.address);
    await token.addMinter(owner.address, ethers.parseUnits("1000", 3));
    await token.mint(addr1.address, ethers.parseUnits("100", 3));

    await token.updateFeeManager(owner.address);
    await token.addFeeAccount(feeAccount.address);

    await token.setParams(feeAccount, 1, ethers.parseUnits("60", 3), 3);

    await token.connect(addr1).transfer(addr2.address, ethers.parseUnits("50", 3));

    const fee = ethers.parseUnits("0.05", 3); // 1/1000

    const netAmount = ethers.parseUnits("50", 3) - fee;

    expect(await token.balanceOf(addr2.address)).to.equal(netAmount);
    expect(await token.balanceOf(feeAccount.address)).to.equal(fee);
  });

  it("should blacklist and whitelist accounts", async function () {
    const { token, owner, addr1 } = await loadFixture(deployTokenUpgradeableFixture);
    await token.updateBlacklister(owner.address);

    await token.blacklist(addr1.address);
    expect(await token.isBlacklisted(addr1.address)).to.equal(true);

    await token.unBlacklist(addr1.address);
    expect(await token.isBlacklisted(addr1.address)).to.equal(false);
  });

  it("should pause and unpause the contract", async function () {
    const { token, owner, addr1, addr2 } = await loadFixture(deployTokenUpgradeableFixture);

    await token.updateMasterMinter(owner.address);
    await token.addMinter(owner.address, ethers.parseUnits("1000", 3));
    await token.mint(owner.address, ethers.parseUnits("100", 3));
    await token.mint(addr1.address, ethers.parseUnits("100", 3));

    expect(await token.isBlacklisted(owner.address)).to.equal(false);
    expect(await token.isBlacklisted(addr1.address)).to.equal(false);
    expect(await token.isBlacklisted(addr2.address)).to.equal(false);

    await token.updateWhitelister(owner);
    await token.whitelist(owner);
    await token.whitelist(addr1);
    await token.whitelist(addr2);

    expect(await token.isWhitelisted(owner.address)).to.equal(true);
    expect(await token.isWhitelisted(addr1.address)).to.equal(true);
    expect(await token.isWhitelisted(addr2.address)).to.equal(true);

    await token.updateFeeManager(owner.address);
    await token.addFeeAccount(addr1.address);

    await token.grantRole(await token.PAUSER_ROLE(), owner);
    await token.grantRole(await token.PAUSER_ROLE(), addr1);

    // const pausedState1 = await token.paused();
    // console.log("Paused state after unpause1:", pausedState1); // Should be false
    await token.pause();

    // const pausedState2 = await token.paused();
    // console.log("Paused state after unpause2:", pausedState2); // Should be false
    await expect(token.transfer(addr1.address, ethers.parseUnits("50", 3))).to.be.revertedWithCustomError(
      token,
      "EnforcedPause",
    );
    // await expect(token.transfer(addr1.address, 1)).to.be.revertedWith("Pausable: paused");

    await token.unpause();

    const pausedState = await token.paused();
    expect(pausedState).to.be.false;

    await token.transfer(addr1.address, ethers.parseUnits("1", 3));

    console.log("token.balanceOf(addr1.address) sss:", await token.balanceOf(addr1.address));
    // await expect(token.transfer(addr1.address, ethers.parseUnits("50", 3))).to.not.be.reverted;
    await expect(token.transfer(addr1.address, ethers.parseUnits("50", 3))).not.to.be.reverted;
  });

  // More test cases can be added similarly for other functions
});
