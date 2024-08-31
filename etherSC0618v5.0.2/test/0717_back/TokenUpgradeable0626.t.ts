import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract } from "ethers";
import { splitSignature } from "@ethersproject/bytes";
// import { TypedDataDomain } from "@ethersproject/abstract-signer";
// import { BigNumberish } from "@ethersproject/bignumber";
import { TypedDataDomain } from "ethers";
import { BigNumberish } from "ethers";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("TokenUpgradeable contract", function () {
  async function deployTokenUpgradeableFixture() {
    // const tokenUpgradeable = await ethers.deployContract("TokenUpgradeable");
    // await tokenUpgradeable.initialize("jdscToken", "jdsc");

    // return { tokenUpgradeable };

    const [deploy, owner, admin, feeAccount, otherAccount] = await ethers.getSigners();
    // console.log("owner:::", owner);
    console.log("owner address:::", owner.address);
    // console.log("owner getAddress:::", owner.getAddress);
    // Deploying
    const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deploy);
    // const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable");
    console.log("start TokenUpgradeable...");

    const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [
      owner.address,
      admin.address,
      "jdscToken",
      "jdsc",
    ]);
    // const instance = await upgrades.deployProxy(TokenUpgradeable, [owner, admin, process.env.tokenName, process.env.tokenSymbol], {
    //   initializer: 'initialize'
    // });
    // const instance = await upgrades.deployProxy(TokenUpgradeable, ["0xbD8b976650e9A799B0ffE3666E2970F80a9a962f", "jdscToken", "jdsc"]);
    // const instance = await upgrades.deployProxy(TokenUpgradeable, ["jdscToken", "jdsc", "0x58ecf9b3a9cb9984b252e793b6031c84c9ddb4fe3f9adad7a89910bcb626ef8d"]);
    // await instance.deployed();

    // const [owner, otherAccount] = await ethers.getSigners();
    //implementation address
    // //Logical contract address of the agency contract
    // const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target as string);
    // console.log("TokenUpgradeable impl   address:", implAddress);
    // console.log("TokenUpgradeable proxy  address:", instance.target);

    // return { TokenUpgradeableTemp, instance, implAddress, owner, otherAccount };
    return { TokenUpgradeable, deployInstance, owner, admin, feeAccount, otherAccount };
  }

  describe("Transfers", function () {
    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // console.log("instance1 runner:::",instance.runner);

        // console.log("owner  ownerInstance:::",owner);
        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;
        // const ownerInstance = instance.connect(owner) as unknown as Contract;
        // console.log("ownerInstance:::",ownerInstance);
        // console.log("ownerInstance runner:::",instance.runner);

        // console.log("instance2 runner:::",instance.runner);

        // const adminInstance = instance.connect(admin)  as Contract;
        // console.log("adminInstance runner:::",adminInstance.runner);

        // console.log("adminInstance instance runner:::",instance.runner);

        //updateWhitelister, onlyOwner
        instance.updateWhitelister(owner);
        //whitelist onlyWhitelister
        instance.whitelist(owner);
        instance.whitelist(otherAccount);

        //updateWhitelister, onlyOwner
        instance.updateWhitelister(owner);
        //whitelist, onlyWhitelister
        instance.whitelist(owner);

        //setup master minter, onlyOwner
        await instance.updateMasterMinter(owner);
        //setup minter, onlyMasterMinter MINTER_ROLE
        await instance.configureMinter(owner, 21_000_000);
        //mint, MINTER_ROLE
        await instance.mint(owner.address, 21_000_000);

        // notBlacklisted(owner) notBlacklisted(otherAccount)
        // isAddressWhitelisted(owner) isAddressWhitelisted(ownotherAccounter)
        console.log("owner.address:::", owner.address);
        expect(await instance.isBlacklisted(owner.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);

        expect(await instance.isWhitelisted(owner.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);

        //transfer
        await instance.transfer(otherAccount, ethers.toBigInt("100"));
        const otherBalance = await instance.balanceOf(otherAccount);
        await expect(otherBalance).to.equal(ethers.toBigInt("100"));

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
        // const ownerInstance = instance.connect(owner) as unknown as Contract;
        // console.log("ownerInstance:::",ownerInstance);

        //updateWhitelister, onlyOwner
        instance.updateWhitelister(owner);
        //whitelist, onlyWhitelister
        instance.whitelist(owner);

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

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { deployInstance, owner, admin, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;
        // const ownerInstance = instance.connect(owner) as unknown as Contract;
        // console.log("ownerInstance:::",ownerInstance);
        // const ownerInstance = instance.connect(owner);
        //updateWhitelister, onlyOwner
        instance.updateWhitelister(owner);
        // instance.updateWhitelister(owner);
        //whitelist, onlyWhitelister
        instance.whitelist(owner);
        instance.whitelist(otherAccount);

        //setup master minter, onlyOwner
        await instance.updateMasterMinter(owner);
        //setup minter, onlyMasterMinter MINTER_ROLE
        await instance.configureMinter(owner, 21_000_000);
        //mint, MINTER_ROLE
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

        // notBlacklisted(owner) notBlacklisted(otherAccount)
        // isAddressWhitelisted(owner) isAddressWhitelisted(ownotherAccounter)
        expect(await instance.isBlacklisted(owner.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);

        expect(await instance.isWhitelisted(owner.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);

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

    // describe("Burn", function () {
    //   it("Should transfer the funds to the owner", async function () {
    //     const { deployInstance, owner, otherAccount } = await loadFixture(
    //       deployTokenUpgradeableFixture
    //     );

    //     // Connect owner to the instance
    //     const instance = deployInstance.connect(owner)  as Contract;
    //     // const ownerInstance = instance.connect(owner) as unknown as Contract;
    //     // console.log("ownerInstance:::",ownerInstance);

    //     // // instance.attach(owner);
    //     // instance.connect(owner);
    //     //updateWhitelister
    //     instance.updateWhitelister(owner);
    //     //whitelist
    //     instance.whitelist(owner);

    //     //setup master minter
    //     await instance.updateMasterMinter(owner);
    //     //setup minter
    //     await instance.configureMinter(owner, 21_000_000);
    //     //mint
    //     await instance.mint(owner.address, 21_000_000);

    //     // await instance.connect(otherAccount).mint(owner.address, 21_000_000);

    //     // await instance.approve(otherAccount.address, ethers.toBigInt("21000000"));

    //     // const instance = deployInstance.connect(owner)  as Contract;
    //     //burn
    //     // await instance.burn(owner.address, ethers.toBigInt("21000000"));
    //     await instance["burn(address,uint256)"](owner.address, ethers.toBigInt("21000000"));
    //     // await instance["burnFrom(address,uint256)"](owner.address, ethers.toBigInt("21000000"));

    //     const ownerBalance = await instance.balanceOf(owner.address);

    //     console.log("ownerBalance:", ownerBalance.toString());
    //     expect(ownerBalance).to.equal(ethers.toBigInt("0"));

    //   });

    describe("Redeem", function () {
      it("Should Redeem the funds to the owner", async function () {
        const { deployInstance, owner, feeAccount, otherAccount } = await loadFixture(deployTokenUpgradeableFixture);

        // Connect owner to the instance
        const instance = deployInstance.connect(owner) as Contract;
        // const ownerInstance = instance.connect(owner) as unknown as Contract;
        // console.log("ownerInstance:::",ownerInstance);

        // // instance.attach(owner);
        // instance.connect(owner);
        //updateWhitelister
        instance.updateWhitelister(owner);
        //whitelist
        instance.whitelist(owner);
        instance.whitelist(otherAccount);
        instance.whitelist(feeAccount);

        //setup master minter
        await instance.updateMasterMinter(owner);
        //setup minter
        await instance.configureMinter(owner, 21_000_000);
        //mint
        await instance.mint(owner.address, 21_000_000);

        // await instance.connect(otherAccount).mint(owner.address, 21_000_000);

        // notBlacklisted(owner) notBlacklisted(otherAccount)
        // isAddressWhitelisted(owner) isAddressWhitelisted(ownotherAccounter)
        expect(await instance.isBlacklisted(owner.address)).to.equal(false);
        expect(await instance.isBlacklisted(otherAccount.address)).to.equal(false);

        expect(await instance.isWhitelisted(owner.address)).to.equal(true);
        expect(await instance.isWhitelisted(otherAccount.address)).to.equal(true);

        const provider = owner.provider;
        const network = await provider.getNetwork();
        // const chainId = network.chainId;
        const chainId: BigNumberish = network.chainId;

        const contractAddress = instance.target;

        console.log("contractAddress::::::::::", contractAddress);

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
            { name: "nonce", type: "bytes32" },
            { name: "deadline", type: "uint256" },
          ],
        };

        const ownerAddress = owner.address;
        const otherAccountAddress = otherAccount.address;
        const value = "100000";

        const noncew = (await provider.getTransactionCount(ownerAddress)).toString();
        console.log("noncew: ", noncew);

        const deadline = Math.floor(Date.now() / 1000) + 3600;
        // const deadline = "1718429248";
        const message = {
          owner: ownerAddress,
          spender: otherAccountAddress,
          value: value,
          nonce: noncew,
          deadline: deadline,
        };

        console.log("domain      : ", domain);
        console.log("types      : ", types);
        console.log("message      : ", message);
        console.log("owner      : ", ownerAddress);
        console.log("spender    : ", otherAccountAddress);
        console.log("value      : ", value);
        console.log("nonce      : ", noncew);
        console.log("deadline   : ", deadline);
        // Math.floor(Date.now() / 1000) + 3600 // 1 hour from now
        console.log("Signature11: ");
        const signature = await owner.signTypedData(domain, types, message);
        const { v, r, s } = splitSignature(signature);

        console.log("v: ", v);
        console.log("r: ", r);
        console.log("s: ", s);

        //setup fee
        await instance.redeem(owner.address, otherAccount.address, ethers.toBigInt("21000000"), deadline, v, r, s);

        // const instance = deployInstance.connect(owner)  as Contract;
        //burn
        // await instance.burn(owner.address, ethers.toBigInt("21000000"));
        // await instance["burn(address,uint256)"](owner.address, ethers.toBigInt("21000000"));
        // await instance["burnFrom(address,uint256)"](owner.address, ethers.toBigInt("21000000"));

        const ownerBalance = await instance.balanceOf(owner.address);

        console.log("redeem ownerBalance:", ownerBalance.toString());
        expect(ownerBalance).to.equal(ethers.toBigInt("0"));
      });
    });
  });
});
