const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("JDSCTokenV1WithFees contract", function () {
  // async function deployV1FeesFixture() {

  //   // Contracts are deployed using the first signer/account by default
  //   const [owner, otherAccount] = await ethers.getSigners();

  //   console.log("owener:{}",owner);
  //   console.log("otherAccount:{}",otherAccount);
  //   const JDSCTokenV1WithFees = await ethers.getContractFactory("JDSCTokenV1WithFees");
  //   const jdscTokenV1WithFees = await JDSCTokenV1WithFees.deploy();

  //   return jdscTokenV1WithFees.target;
  // }

  async function deployV1FeesFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const jdscTokenV1WithFees = await ethers.deployContract("JDSCTokenV1WithFees");

    await jdscTokenV1WithFees.waitForDeployment();

    return { jdscTokenV1WithFees, owner, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { jdscTokenV1WithFees, owner } = await loadFixture(deployV1FeesFixture);

      expect(await jdscTokenV1WithFees.owner()).to.equal(owner.address);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const { jdscTokenV1WithFees, owner } = await loadFixture(deployV1FeesFixture);
      const ownerBalance = await jdscTokenV1WithFees.balanceOf(owner.address);
      expect(await jdscTokenV1WithFees.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("init", function () {


  });
  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      const { jdscTokenV1WithFees, owner, addr1, addr2 } = await loadFixture(
        deployV1FeesFixture
      );
  
      await expect(
        jdscTokenV1WithFees.transfer(addr1.address, 50)
      ).to.changeTokenBalances(jdscTokenV1WithFees, [owner, addr1], [-50, 50]);

      await expect(
        jdscTokenV1WithFees.connect(addr1).transfer(addr2.address, 50)
      ).to.changeTokenBalances(jdscTokenV1WithFees, [addr1, addr2], [-50, 50]);
    });

    it("Should emit Transfer events", async function () {
      const { jdscTokenV1WithFees, owner, addr1, addr2 } = await loadFixture(
        deployV1FeesFixture
      );

      await expect(jdscTokenV1WithFees.transfer(addr1.address, 50))
        .to.emit(jdscTokenV1WithFees, "Transfer")
        .withArgs(owner.address, addr1.address, 50);

      await expect(jdscTokenV1WithFees.connect(addr1).transfer(addr2.address, 50))
        .to.emit(jdscTokenV1WithFees, "Transfer")
        .withArgs(addr1.address, addr2.address, 50);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const { jdscTokenV1WithFees, owner, addr1 } = await loadFixture(
        deployV1FeesFixture
      );
      const initialOwnerBalance = await jdscTokenV1WithFees.balanceOf(owner.address);

      await expect(
        jdscTokenV1WithFees.connect(addr1).transfer(owner.address, 1)
      ).to.be.revertedWith("Not enough tokens");

      expect(await jdscTokenV1WithFees.balanceOf(owner.address)).to.equal(
        initialOwnerBalance
      );
    });
  });
});
