import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("TokenUpgradeable contract", function () {
  async function deployTokenUpgradeableFixture() {
    // const tokenUpgradeable = await ethers.deployContract("TokenUpgradeable");
    // await tokenUpgradeable.initialize("jdscToken", "jdsc");

    // return { tokenUpgradeable };

    // Deploying
    const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable");
    console.log("start TokenUpgradeable...");

    const instance = await upgrades.deployProxy(TokenUpgradeable, [
      process.env.owner,
      process.env.tokenName,
      process.env.tokenSymbol,
    ]);
    // const instance = await upgrades.deployProxy(TokenUpgradeable, ["0xbD8b976650e9A799B0ffE3666E2970F80a9a962f", "jdscToken", "jdsc"]);
    // const instance = await upgrades.deployProxy(TokenUpgradeable, ["jdscToken", "jdsc", "0x58ecf9b3a9cb9984b252e793b6031c84c9ddb4fe3f9adad7a89910bcb626ef8d"]);
    // await instance.deployed();

    const [owner, otherAccount] = await ethers.getSigners();
    //implementation address
    // //Logical contract address of the agency contract
    // const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target as string);
    // console.log("TokenUpgradeable impl   address:", implAddress);
    // console.log("TokenUpgradeable proxy  address:", instance.target);

    // return { TokenUpgradeableTemp, instance, implAddress, owner, otherAccount };
    return { TokenUpgradeable, instance, owner, otherAccount };
  }

  describe("Transfers", function () {
    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { instance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        //updateWhitelister
        instance.updateWhitelister(owner);
        //whitelist
        instance.whitelist(owner);
        instance.whitelist(otherAccount);

        //updateWhitelister
        instance.updateWhitelister(owner);
        //whitelist
        instance.whitelist(owner);

        //setup master minter
        await instance.updateMasterMinter(owner);
        //setup minter
        await instance.configureMinter(owner, 21_000_000);
        //mint
        await instance.mint(owner.address, 21_000_000);

        //transfer
        await instance.transfer(otherAccount, ethers.toBigInt("100"));
        const otherBalance = await instance.balanceOf(otherAccount);
        await expect(otherBalance).to.equal(ethers.toBigInt("100"));

        await expect(instance.transfer(otherAccount.address, ethers.toBigInt("100")))
          .to.emit(instance, "Transfer")
          .withArgs(owner, otherAccount, 100);
      });
    });

    describe("Mint", function () {
      it("Should mint the funds to the owner", async function () {
        const { instance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        //updateWhitelister
        instance.updateWhitelister(owner);
        //whitelist
        instance.whitelist(owner);

        //setup master minter
        await instance.updateMasterMinter(owner);
        //setup minter
        await instance.configureMinter(owner, 21_000_000);
        //mint
        await instance.mint(owner.address, 21_000_000);

        const ownerBalance = await instance.balanceOf(owner.address);
        expect(ownerBalance).to.equal(ethers.toBigInt("21000000"));
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { instance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        //updateWhitelister
        instance.updateWhitelister(owner);
        //whitelist
        instance.whitelist(owner);

        //setup master minter
        await instance.updateMasterMinter(owner);
        //setup minter
        await instance.configureMinter(owner, 21_000_000);
        //mint
        await instance.mint(owner.address, 21_000_000);

        const ownerBalance = await instance.balanceOf(owner.address);
        // console.log("ownerBalance::" + ownerBalance);
        console.log("ownerBalance:", ownerBalance.toString());
        // await expect(ownerBalance).to.equal(ethers.toBigInt(ethers.parseEther("21000000")));
        // await expect(ownerBalance).to.equal(ethers.toBigInt(ethers.toUtf8String("21_000_000")));
        await expect(ownerBalance).to.equal(ethers.toBigInt("21000000"));
        // await expect(ownerBalance).to.equal(ethers.parseEther("21_000_000"));

        console.log("owner:", owner.address);
        console.log("otherAccount:", otherAccount.address);
        console.log("owner balance:", await instance.balanceOf(owner));
        console.log('ethers.parseUnits("100"):', ethers.parseUnits("100"));
        console.log('ethers.parseUnits("100"):', 100);
        console.log('ethers.parseUnits("100"):', ethers.toBigInt("100"));
        //transfer
        await instance.transfer(otherAccount, ethers.toBigInt("100"));

        // await instance.transfer(otherAccount, 100);
        // await instance.transfer(otherAccount, ethers.parseUnits("100"));
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

        // const ownerBalance = instance.balanceOf(owner);
        //eth transfer check
        // await expect(() => instance.transfer(otherAccount, ethers.toBigInt("100"))).to.changeEtherBalances(
        //   [owner, otherAccount],
        //   [-ethers.toBigInt("100"), ethers.toBigInt("100")]
        // );
      });
    });

    describe("Burn", function () {
      it("Should transfer the funds to the owner", async function () {
        const { instance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        //updateWhitelister
        instance.updateWhitelister(owner);
        //whitelist
        instance.whitelist(owner);

        //setup master minter
        await instance.updateMasterMinter(owner);
        //setup minter
        await instance.configureMinter(owner, 21_000_000);
        //mint
        await instance.mint(owner.address, 21_000_000);

        // await instance.connect(otherAccount).mint(owner.address, 21_000_000);

        //burn
        // await instance.burn(owner.address, ethers.toBigInt("21000000"));
        await instance["burn(address,uint256)"](owner.address, ethers.toBigInt("21000000"));

        const ownerBalance = await instance.balanceOf(owner.address);

        console.log("ownerBalance:", ownerBalance.toString());
        expect(ownerBalance).to.equal(ethers.toBigInt("0"));
      });
    });
  });
});
