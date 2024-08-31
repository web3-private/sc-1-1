import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

import { time, loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

export async function deployTokenUpgradeableFixture() {
  const [deploy, owner, admin, feeAccount, otherAccount] = await ethers.getSigners();
  // Deploying
  const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deploy);

  const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [owner.address, "jdscToken", "jdsc", 3]);

  return { TokenUpgradeable, deployInstance, owner, admin, feeAccount, otherAccount };
}

export async function deployTokenUpgradeableAndWhiteFixture() {
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

  // Deploying
  const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable", deploy);

  const deployInstance = await upgrades.deployProxy(TokenUpgradeable, [
    owner.address,
    // admin.address,
    "jdscToken",
    "jdsc",
    3,
  ]);

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
  await setInitFeeHolderRole(ownerInstance, feemanager, feehold1);

  return {
    TokenUpgradeable,
    deployInstance,
    owner,
    admin,
    feeAccount,
    otherAccount,
    blacklistManager,
    blacklist1,
    whitelistManager,
    masterminter,
    feemanager,
    minter1,
    feehold1,
  };
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
  console.log("whitelistManager address                 :::::", await whitelistManager.getAddress());
  const managerInstance = instance.connect(whitelistManager) as Contract;

  //setup WHITELISTER_ROLE
  await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), await owner.getAddress());
  console.log("grantRole WHITELISTER_ROLE               :::::", await owner.getAddress());

  await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), await admin.getAddress());
  console.log("grantRole WHITELISTER_ROLE               :::::", await admin.getAddress());

  await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), await otherAccount.getAddress());
  console.log("grantRole WHITELISTER_ROLE               :::::", await otherAccount.getAddress());
}

async function setInitMinterRole(instance: Contract, masterminter: Signer, minter: Signer) {
  console.log("masterminter address                     :::::", await masterminter.getAddress());
  const managerInstance = instance.connect(masterminter) as Contract;

  //setup MINTER_ROLE
  await managerInstance.grantRole(await managerInstance.MINTER_ROLE(), await minter.getAddress());
  console.log("grantRole MINTER_ROLE                    :::::", await minter.getAddress());
}

async function setInitFeeHolderRole(instance: Contract, feemanager: Signer, feehold: Signer) {
  console.log("masterminter address                     :::::", await feemanager.getAddress());
  const managerInstance = instance.connect(feemanager) as Contract;

  //setup FEE_HOLDER_ROLE
  await managerInstance.grantRole(await managerInstance.FEE_HOLDER_ROLE(), await feehold.getAddress());
  console.log("grantRole FEE_HOLDER_ROLE                :::::", await feehold.getAddress());
}
