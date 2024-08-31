import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Contract, Signer } from "ethers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("TokenBaseUpgradeable", function () {
  // 定义Fixture
  async function deployTokenFixture() {
    const [owner, admin, user1, user2] = await ethers.getSigners();
    const TokenFactory = await ethers.getContractFactory("TokenUpgradeable");
    // const TokenFactory = await ethers.getContractFactory("TokenBaseUpgradeable");
    console.log("await owner.getAddress():::::", await owner.getAddress());
    console.log("await admin.getAddress():::::", await admin.getAddress());
    const Token = await upgrades.deployProxy(TokenFactory, [await owner.getAddress(), "TestToken", "TTK"], {
      initializer: "initialize",
    });
    // const Token = await upgrades.deployProxy(TokenFactory, [await owner.getAddress(), await admin.getAddress(), "TestToken", "TTK"], { initializer: 'initialize' });
    // await Token.deployed();

    await Token.grantRole(await Token.DEFAULT_ADMIN_ROLE(), await admin.getAddress());
    console.log("Token.DEFAULT_ADMIN_ROLE:::::", await Token.DEFAULT_ADMIN_ROLE());
    return { Token, owner, admin, user1, user2 };
  }

  it("初始化测试", async function () {
    const { Token, admin, owner } = await loadFixture(deployTokenFixture);

    console.log("Token.DEFAULT_ADMIN_ROLE():::::", await Token.DEFAULT_ADMIN_ROLE());
    expect(await Token.name()).to.equal("TestToken");
    expect(await Token.symbol()).to.equal("TTK");
    expect(await Token.hasRole(await Token.DEFAULT_ADMIN_ROLE(), await admin.getAddress())).to.be.true;
    expect(await Token.hasRole(await Token.PAUSER_ROLE(), await owner.getAddress())).to.be.true;
  });

  it("测试铸造代币", async function () {
    const { Token, owner, user1 } = await loadFixture(deployTokenFixture);
    const ownerToken = (await Token.connect(owner)) as Contract;

    //updateWhitelister, onlyOwner
    await ownerToken.updateWhitelister(owner);
    //whitelist onlyWhitelister
    await ownerToken.whitelist(owner);
    await ownerToken.whitelist(user1);

    //setup master minter
    await ownerToken.updateMasterMinter(owner);
    //setup minter
    await ownerToken.configureMinter(user1);
    // await ownerToken.configureMinter(otherAccount);
    //approve
    await ownerToken.approveMint(user1.getAddress(), owner.getAddress(), 1000);

    await ownerToken.mint(await user1.getAddress(), 1000);
    expect(await Token.balanceOf(await user1.getAddress())).to.equal(1000);
  });

  it("测试销毁代币", async function () {
    const { Token, owner, user1 } = await loadFixture(deployTokenFixture);
    const ownerToken = (await Token.connect(owner)) as Contract;
    ownerToken.mint(await user1.getAddress(), 1000);
    const user1Token = (await Token.connect(user1)) as Contract;
    user1Token.approve(owner.getAddress(), 500);
    const owner1Token = (await Token.connect(owner)) as Contract;
    owner1Token.burnFrom(await user1.getAddress(), 500);
    expect(await Token.balanceOf(await user1.getAddress())).to.equal(500);
  });

  it("测试暂停和取消暂停", async function () {
    const { Token, owner, user1, user2 } = await loadFixture(deployTokenFixture);
    const ownerToken = (await Token.connect(owner)) as Contract;
    ownerToken.pause();
    const user1token = Token.connect(user1) as Contract;
    await expect(user1token.transfer(await user2.getAddress(), 1000)).to.be.revertedWith("Pausable: paused");

    const owner1Token = (await Token.connect(owner)) as Contract;
    owner1Token.unpause();
    // const owner2Token = await Token.connect(owner) as Contract;
    owner1Token.mint(await user1.getAddress(), 1000);
    const user11token = (await Token.connect(user1)) as Contract;
    user11token.transfer(await user2.getAddress(), 1000);
    expect(await Token.balanceOf(await user2.getAddress())).to.equal(1000);
  });

  it("测试批量转账功能", async function () {
    const { Token, owner, user1, user2 } = await loadFixture(deployTokenFixture);
    const ownerToken = (await Token.connect(owner)) as Contract;
    ownerToken.mint(await user1.getAddress(), 3000);
    const user1Token = (await Token.connect(user1)) as Contract;
    user1Token.batchTransfer([await user2.getAddress(), await owner.getAddress()], [1000, 2000]);

    expect(await Token.balanceOf(await user2.getAddress())).to.equal(1000);
    expect(await Token.balanceOf(await owner.getAddress())).to.equal(2000);
  });

  it("测试配置和移除铸币者", async function () {
    const { Token, owner, user1 } = await loadFixture(deployTokenFixture);
    const ownerToken = (await Token.connect(owner)) as Contract;
    ownerToken.configureMinter(await user1.getAddress(), 1000);
    expect(await Token.hasRole(await Token.MINTER_ROLE(), await user1.getAddress())).to.be.true;

    // const ownerToken = await Token.connect(owner) as Contract;
    ownerToken.removeMinter(await user1.getAddress());
    expect(await Token.hasRole(await Token.MINTER_ROLE(), await user1.getAddress())).to.be.false;
  });

  it("测试更新主铸币者", async function () {
    const { Token, owner, user2 } = await loadFixture(deployTokenFixture);
    const ownerToken = (await Token.connect(owner)) as Contract;
    ownerToken.updateMasterMinter(await user2.getAddress());
    expect(await Token.hasRole(await Token.MASTER_MINTER_ROLE(), await user2.getAddress())).to.be.true;
  });

  it("测试更新币种", async function () {
    const { Token, owner } = await loadFixture(deployTokenFixture);
    const ownerToken = (await Token.connect(owner)) as Contract;
    ownerToken.updateCurrency("USD");
    expect(await Token.currency()).to.equal("USD");
  });

  it("测试更新精度", async function () {
    const { Token, owner } = await loadFixture(deployTokenFixture);
    const ownerToken = (await Token.connect(owner)) as Contract;
    ownerToken.updateDecimals(8);
    expect(await Token.decimals()).to.equal(8);
  });

  it("测试批准并调用", async function () {
    const { Token, owner, user1, user2 } = await loadFixture(deployTokenFixture);
    const data = "0x"; // 这里可以替换为实际的调用数据
    const ownerToken = (await Token.connect(owner)) as Contract;
    ownerToken.mint(await user1.getAddress(), 1000);
    const user1Token = Token.connect(user1) as Contract;
    await expect(user1Token.approveAndCall(await user2.getAddress(), 500, data))
      .to.emit(Token, "Approval")
      .withArgs(await user1.getAddress(), await user2.getAddress(), 500);
  });
});
