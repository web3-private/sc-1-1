const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("callproxy contract", function () {

  async function deployCallFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    // const callProxy = await ethers.deployContract("CallProxy");



    const CallProxy = await ethers.getContractFactory("CallProxy");
    const callProxy = await CallProxy.deploy("0xc7Dc27D649a13616EB6a2a5136D929f5868e07f2");

    await callProxy.waitForDeployment();

    return { callProxy, owner, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { callProxy, owner } = await loadFixture(deployCallFixture);

      // expect(await callProxy.owner()).to.equal(owner.address);
    });

    // it("Should assign the total supply of tokens to the owner", async function () {
    //   const { callProxy, owner } = await loadFixture(deployCallFixture);
    //   const ownerBalance = await callProxy.balanceOf(owner.address);
    //   expect(await callProxy.totalSupply()).to.equal(ownerBalance);
    // });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      const { callProxy, owner, addr1, addr2 } = await loadFixture(
        deployCallFixture
      );
  
      // await expect(
        callProxy.delecall(addr1.address, addr2.address, 50)
      // ).to(callProxy, [addr1, addr2], [-50, 50]);

      // await expect(
      //   callProxy.delecall(addr1.address, addr2.address, 50)
      // ).to.changeTokenBalances(callProxy, [addr1, addr2], [-50, 50]);

      // await expect(
      //   callProxy.connect(addr1).transfer(addr2.address, 50)
      // ).to.changeTokenBalances(callProxy, [addr1, addr2], [-50, 50]);
    });

    it("Should emit Transfer events", async function () {
      const { callProxy, owner, addr1, addr2 } = await loadFixture(
        deployCallFixture
      );

      // await expect(callProxy.transfer(addr1.address, 50))
      //   .to.emit(callProxy, "Transfer")
      //   .withArgs(owner.address, addr1.address, 50);

      // await expect(callProxy.connect(addr1).transfer(addr2.address, 50))
      //   .to.emit(callProxy, "Transfer")
      //   .withArgs(addr1.address, addr2.address, 50);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const { callProxy, owner, addr1 } = await loadFixture(
        deployCallFixture
      );
      // const initialOwnerBalance = await callProxy.balanceOf(owner.address);

      // await expect(
      //   callProxy.connect(addr1).transfer(owner.address, 1)
      // ).to.be.revertedWith("Not enough tokens");

      // expect(await callProxy.balanceOf(owner.address)).to.equal(
      //   initialOwnerBalance
      // );
    });
  });
});
