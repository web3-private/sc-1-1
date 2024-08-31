// import { expect } from "chai";
// import { ethers, upgrades } from "hardhat";
// import { Contract, TypedDataDomain, BigNumberish, Signer, Provider } from "ethers";
// import { splitSignature } from "@ethersproject/bytes";

// import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
// import { deployTokenUpgradeableFixture, deployTokenUpgradeableAndWhiteFixture } from "./TokenUpgradeableFixture";

// describe("TokenUpgradeable contract", function () {
//   describe("TimeLock", function () {
//     describe("Validations", function () {
//       it("Should TimeLock status changed to true", async function () {
//         const {
//           deployInstance,
//           owner,
//           admin,
//           otherAccount,
//           whitelistManager,
//           masterminter,
//           feemanager,
//           minter1,
//           feehold1,
//         } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);

//         // Connect owner to the instance
//         const instance = deployInstance.connect(owner) as Contract;

//         // updateTimeLockStatus
//         await instance.updateTimeLockStatus(false);

//         expect(await instance.timeLockStatus()).to.be.false;

//         // updateTimeLockStatus
//         await instance.updateTimeLockStatus(true);
//         expect(await instance.timeLockStatus()).to.be.true;

//         // await mint(instance, admin, otherAccount, minter1);
//         await mint1(deployInstance, owner, admin, masterminter, minter1, feehold1);

//         await expect(mint1(deployInstance, owner, admin, masterminter, minter1, feehold1)).to.be.revertedWith(
//           "TimeLock: Operation not allowed yet",
//         );

//         await expect(
//           transfer(deployInstance, owner, admin, otherAccount, masterminter, minter1, feemanager, feehold1),
//         ).to.be.revertedWith("TimeLock: Operation not allowed yet");

//         // revisit redeem
//         await expect(
//           redeem(
//             deployInstance,
//             owner.provider,
//             owner,
//             admin,
//             whitelistManager,
//             masterminter,
//             feemanager,
//             minter1,
//             feehold1,
//           ),
//         ).to.be.revertedWith("TimeLock: Operation not allowed yet");
//       });

//       it("Should TimeLock status changed to false by 'mint' function", async function () {
//         const { deployInstance, owner, admin, otherAccount, minter1 } = await loadFixture(
//           deployTokenUpgradeableAndWhiteFixture,
//         );

//         // Connect owner to the instance
//         const instance = deployInstance.connect(owner) as Contract;

//         // updateTimeLockStatus
//         await instance.updateTimeLockStatus(true);
//         expect(await instance.timeLockStatus()).to.be.true;

//         await mint(instance, admin, otherAccount, minter1);

//         // Increase time by 12 seconds
//         await ethers.provider.send("evm_increaseTime", [12]);
//         await ethers.provider.send("evm_mine", []);

//         // revisit mint
//         expect(await mint(instance, admin, otherAccount, minter1)).to.be.true;
//       });

//       it("Should TimeLock status changed to false by 'transfer' function", async function () {
//         // const { deployInstance, owner, otherAccount } = await loadFixture(deployTokenUpgradeableAndWhiteFixture);
//         const { deployInstance, owner, admin, otherAccount, masterminter, feemanager, minter1, feehold1 } =
//           await loadFixture(deployTokenUpgradeableAndWhiteFixture);

//         // Connect owner to the instance
//         const instance = deployInstance.connect(owner) as Contract;

//         // updateTimeLockStatus
//         await instance.updateTimeLockStatus(true);
//         expect(await instance.timeLockStatus()).to.be.true;

//         // transfer
//         await transfer(deployInstance, owner, admin, otherAccount, masterminter, minter1, feemanager, feehold1);

//         // Increase time by 12 seconds
//         await ethers.provider.send("evm_increaseTime", [12]);
//         await ethers.provider.send("evm_mine", []);

//         // revisit transfer
//         expect(await transfer(deployInstance, owner, admin, otherAccount, masterminter, minter1, feemanager, feehold1))
//           .to.be.true;
//       });

//       it("Should TimeLock status changed to false by 'redeem' function", async function () {
//         const { deployInstance, owner, admin, whitelistManager, masterminter, feemanager, minter1, feehold1 } =
//           await loadFixture(deployTokenUpgradeableAndWhiteFixture);

//         // Connect owner to the instance
//         const instance = deployInstance.connect(owner) as Contract;

//         // updateTimeLockStatus
//         await instance.updateTimeLockStatus(true);
//         expect(await instance.timeLockStatus()).to.be.true;

//         // redeem
//         await redeem(
//           deployInstance,
//           owner.provider,
//           owner,
//           admin,
//           whitelistManager,
//           masterminter,
//           feemanager,
//           minter1,
//           feehold1,
//         );

//         // Increase time by 12 seconds
//         await ethers.provider.send("evm_increaseTime", [12]);
//         await ethers.provider.send("evm_mine", []);

//         // revisit redeem
//         expect(
//           await redeem(
//             deployInstance,
//             owner.provider,
//             owner,
//             admin,
//             whitelistManager,
//             masterminter,
//             feemanager,
//             minter1,
//             feehold1,
//           ),
//         ).to.be.true;
//       });
//     });
//   });
// });

// async function mint(instance: Contract, admin: Signer, otherAccount: Signer, minter1: Signer): Promise<Boolean> {
//   //setup master minter, onlyOwner
//   await instance.updateMasterMinter(admin);

//   // Connect admin to the instance
//   const adminInstance = instance.connect(admin) as Contract;

//   minter1.getAddress;
//   //setup minter, onlyMasterMinter MINTER_ROLE
//   await adminInstance.addMinter(minter1.getAddress(), 21_000_000);

//   //approveMint
//   await adminInstance.approveMint(minter1.getAddress(), 21_000_000);

//   // Connect minter1 to the instance
//   const minterInstance = adminInstance.connect(minter1) as Contract;

//   //mint, MINTER_ROLE
//   await minterInstance.mint(otherAccount.getAddress(), 21_000_000);
//   return true;
// }

// async function mint1(
//   deployInstance: Contract,
//   owner: Signer,
//   admin: Signer,
//   masterminter: Signer,
//   minter1: Signer,
//   feehold1: Signer,
// ): Promise<Boolean> {
//   // Connect owner to the instance
//   const instance = deployInstance.connect(owner) as Contract;

//   expect(await instance.hasRole(await instance.MASTER_MINTER_ROLE(), masterminter)).to.equal(true);
//   expect(await instance.hasRole(await instance.MINTER_ROLE(), minter1)).to.equal(true);
//   expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), feehold1)).to.equal(true);

//   // Connect masterminter to the instance
//   const masterminterInstance = deployInstance.connect(masterminter) as Contract;

//   //approveMint
//   await masterminterInstance.approveMint(minter1.getAddress(), 21_000_000);

//   // Connect minter1 to the instance
//   const minter1Instance = instance.connect(minter1) as Contract;

//   //mint, MINTER_ROLE
//   await minter1Instance.mint(admin.getAddress(), 21_000_000);

//   // Connect masterminter to the instance
//   const adminInstance = instance.connect(admin) as Contract;

//   const adminBalance = await adminInstance.balanceOf(admin.getAddress());
//   expect(adminBalance).to.equal(ethers.toBigInt("21000000"));

//   return true;
// }

// async function transfer(
//   deployInstance: Contract,
//   owner: Signer,
//   admin: Signer,
//   otherAccount: Signer,
//   masterminter: Signer,
//   minter1: Signer,
//   feemanager: Signer,
//   feehold1: Signer,
// ): Promise<Boolean> {
//   // Connect owner to the instance
//   const instance = deployInstance.connect(owner) as Contract;

//   expect(await instance.hasRole(await instance.MASTER_MINTER_ROLE(), masterminter)).to.equal(true);
//   expect(await instance.hasRole(await instance.MINTER_ROLE(), minter1)).to.equal(true);
//   expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), feehold1)).to.equal(true);

//   // Connect masterminter to the instance
//   const masterminterInstance = deployInstance.connect(masterminter) as Contract;

//   //approveMint
//   await masterminterInstance.approveMint(minter1.getAddress(), 21_000_000);

//   // Connect minter1 to the instance
//   const minter1Instance = instance.connect(minter1) as Contract;

//   //mint, MINTER_ROLE
//   await minter1Instance.mint(admin.getAddress(), 21_000_000);

//   await ethers.provider.send("evm_increaseTime", [12]);

//   // Connect masterminter to the instance
//   const adminInstance = instance.connect(admin) as Contract;

//   // Connect feemanager to the instance
//   const feemanagerInstance = instance.connect(feemanager) as Contract;

//   const newBasisPoints = 15; //MAX_SETTABLE_BASIS_POINTS=20
//   const newMaxFee = 60000;
//   const decimals = 3;
//   const amount = ethers.toBigInt("1000000");

//   //setup fee, onlyOwner, init common params
//   await feemanagerInstance.setParams(feehold1, newBasisPoints, newMaxFee, decimals, true);

//   const fee = await adminInstance.calcCommonFee(amount); // fee = amount * 15 / 1000

//   // fee = value * 15 / 1000
//   expect(fee).to.equal(
//     (amount * BigInt(await adminInstance.commonRate())) / BigInt(await adminInstance.commonRateDecimal()),
//   );

//   expect(await instance.isBlacklisted(admin.getAddress())).to.equal(false);
//   expect(await instance.isBlacklisted(otherAccount.getAddress())).to.equal(false);

//   expect(await instance.isWhitelisted(admin.getAddress())).to.equal(true);
//   expect(await instance.isWhitelisted(otherAccount.getAddress())).to.equal(true);

//   //transfer
//   await adminInstance.transfer(otherAccount, amount);
//   return true;
// }

// async function redeem(
//   deployInstance: Contract,
//   provider: Provider,
//   owner: Signer,
//   admin: Signer,
//   whitelistManager: Signer,
//   masterminter: Signer,
//   feemanager: Signer,
//   minter1: Signer,
//   feehold1: Signer,
// ): Promise<Boolean> {
//   // Connect owner to the instance
//   const instance = deployInstance.connect(owner) as Contract;

//   expect(await instance.hasRole(await instance.MASTER_MINTER_ROLE(), masterminter)).to.equal(true);
//   expect(await instance.hasRole(await instance.MINTER_ROLE(), minter1)).to.equal(true);
//   expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), feehold1)).to.equal(true);

//   // Connect masterminter to the instance
//   const masterminterInstance = instance.connect(masterminter) as Contract;

//   //approveMint
//   await masterminterInstance.approveMint(minter1.getAddress(), 21_000_000);

//   // Connect masterminter to the instance
//   const minterInstance = instance.connect(minter1) as Contract;

//   //mint
//   await minterInstance.mint(admin.getAddress(), 21_000_000);

//   expect(await minterInstance.balanceOf(admin.getAddress())).to.equal(21_000_000);

//   // Connect feemanager to the instance
//   const feemanagerInstance = instance.connect(feemanager) as Contract;

//   const newBasisPoints = 15; //MAX_SETTABLE_BASIS_POINTS=20
//   const newMaxFee = 60000;
//   const decimals = 3;

//   //setup fee, onlyOwner, init common params
//   await feemanagerInstance.setParams(feehold1, newBasisPoints, newMaxFee, decimals, true);
//   //setup fee, onlyOwner
//   await feemanagerInstance.setParams(feehold1, newBasisPoints, newMaxFee, decimals, false);

//   const MAX_SETTABLE_BASIS_POINTS = 20;
//   const points = newBasisPoints > MAX_SETTABLE_BASIS_POINTS ? MAX_SETTABLE_BASIS_POINTS : newBasisPoints;
//   expect(await feemanagerInstance.feeRateAccounts(feehold1)).to.equal(points);

//   const network = await provider.getNetwork();
//   const chainId: BigNumberish = network.chainId;
//   const contractAddress = instance.target;

//   const domain: TypedDataDomain = {
//     name: "jdscToken",
//     version: "1",
//     chainId: chainId,
//     verifyingContract: contractAddress as string,
//   };

//   const types = {
//     Permit: [
//       { name: "owner", type: "address" },
//       { name: "spender", type: "address" },
//       { name: "value", type: "uint256" },
//       { name: "nonce", type: "uint256" },
//       { name: "deadline", type: "uint256" },
//     ],
//   };

//   const adminAddress = await admin.getAddress(); //token owner
//   const minter1AccountAddress = await minter1.getAddress(); //token spender  _msgSender()
//   const value = ethers.toBigInt("21000000"); //amount
//   const nonce = await instance.nonces(admin.getAddress()); // token owner nonce
//   const deadline = Math.floor(Date.now() / 1000) + 3600;

//   const message = {
//     owner: adminAddress,
//     spender: minter1AccountAddress,
//     value: value,
//     nonce: nonce,
//     deadline: deadline,
//   };

//   const signature = await admin.signTypedData(domain, types, message);
//   const { v, r, s } = splitSignature(signature);

//   const fee = await minterInstance.calcFee(feehold1, value); // fee = value * 15 / 1000

//   // fee = value * 15 / 1000
//   expect(fee).to.equal((value * BigInt(newBasisPoints)) / BigInt(1000));

//   expect(await minterInstance.isBlacklisted(minter1.getAddress())).to.be.false;
//   expect(await minterInstance.isBlacklisted(admin.getAddress())).to.be.false;
//   expect(await minterInstance.isBlacklisted(feehold1.getAddress())).to.be.false;

//   // Connect masterminter to the instance
//   const managerInstance = instance.connect(whitelistManager) as Contract;

//   // setup WHITELIST_MEMBER_ROLE
//   await managerInstance.grantRole(await managerInstance.WHITELIST_MEMBER_ROLE(), await feehold1.getAddress());

//   expect(await managerInstance.isWhitelisted(admin.getAddress())).to.be.true;
//   expect(await managerInstance.isWhitelisted(feehold1.getAddress())).to.be.true;

//   await ethers.provider.send("evm_increaseTime", [12]);
//   await ethers.provider.send("evm_mine", []);

//   // redeem
//   await minterInstance.redeem(admin.getAddress(), feehold1.getAddress(), value, deadline, v, r, s);
//   const ownerBalance = await minterInstance.balanceOf(admin.getAddress());

//   expect(ownerBalance).to.equal(ethers.toBigInt("0"));
//   return true;
// }
