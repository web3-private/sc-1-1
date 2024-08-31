import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";
import { Contract } from "ethers";

import { readFileSync } from 'fs';
import { join } from 'path';

async function main() {

  const contractJsonPath = join(__dirname, '../artifacts/contracts/v1/TokenUpgradeable.sol/TokenUpgradeable.json');
  const contractJson = JSON.parse(readFileSync(contractJsonPath, 'utf-8'));
  const abi = contractJson.abi;
  // console.log("abi                           :", abi);

  const proxyAddress = process.env.proxyAddress
  console.log("TokenUpgradeable2 proxyAddress :", proxyAddress);

  if (!proxyAddress) {
    throw new Error("Proxy address is undefined. Please set the proxyAddress in your .env file.");
  }

  const deployer = new ethers.Wallet(process.env.deployerPk as string, ethers.provider);
  // 创建合约实例
  const instance = new ethers.Contract(proxyAddress, abi, deployer);

  const adminAddress = await upgrades.erc1967.getAdminAddress(instance.target as string);
  console.log("Admin address                  :", adminAddress);

  const owner = new ethers.Wallet(process.env.ownerPk as string, ethers.provider);
  console.log("owner address                  :", owner.address);
  const ownerInstance = instance.connect(owner) as Contract;

  // await setInitRoleAdmin(ownerInstance);

  await setInitBlackListerRole(ownerInstance);

  await setInitWhiteListerRole(ownerInstance);

  await setInitMinterRole(ownerInstance);

  await setInitFeeHoldRole(ownerInstance);

  console.log("end TokenUpgradeable");
}

async function setInitRoleAdmin(instance: Contract) {
  //setup PAUSER_ROLE
  await instance.grantRole(await instance.PAUSER_ROLE(), process.env.pauser);
  console.log("grantRole PAUSER_ROLE                              :::::", process.env.pauser);
  //setup PAUSER_ROLE ROLE_ADMIN
  console.log("SET_ROLE_ADMIN ADMIN_ROLE await                    :::::", await instance.ADMIN_ROLE());
  console.log("SET_ROLE_ADMIN PAUSER_ROLE await                   :::::", await instance.PAUSER_ROLE());
  await instance.setRoleAdmin(await instance.PAUSER_ROLE(), await instance.ADMIN_ROLE());

  //setup BLACKLIST_MANAGER_ROLE
  await instance.grantRole(await instance.BLACKLIST_MANAGER_ROLE(), process.env.blacklistManager);
  console.log("grantRole BLACKLIST_MANAGER_ROLE                 :::::", process.env.blacklistManager);
  //setup BLACKLIST_MANAGER_ROLE ROLE_ADMIN
  console.log("SET_ROLE_ADMIN BLACKLIST_MANAGER_ROLE await      :::::", await instance.BLACKLIST_MANAGER_ROLE());
  console.log("SET_ROLE_ADMIN BLACKLIST_MEMBER_ROLE await       :::::", await instance.BLACKLIST_MEMBER_ROLE());
  await instance.setRoleAdmin(await instance.BLACKLIST_MEMBER_ROLE(), await instance.BLACKLIST_MANAGER_ROLE());

  //setup WHITELIST_MANAGER_ROLE
  await instance.grantRole(await instance.WHITELIST_MANAGER_ROLE(), process.env.whitelistManager);
  console.log("grantRole WHITELIST_MANAGER_ROLE                 :::::", process.env.whitelistManager);
  //setup WHITELIST_MANAGER_ROLE ROLE_ADMIN
  console.log("SET_ROLE_ADMIN WHITELIST_MANAGER_ROLE await      :::::", await instance.WHITELIST_MANAGER_ROLE());
  console.log("SET_ROLE_ADMIN WHITELIST_MEMBER_ROLE await       :::::", await instance.WHITELIST_MEMBER_ROLE());
  await instance.setRoleAdmin(await instance.WHITELIST_MEMBER_ROLE(), await instance.WHITELIST_MANAGER_ROLE());

  //setup MASTER_MINTER_ROLE
  await instance.grantRole(await instance.MASTER_MINTER_ROLE(), process.env.masterminter);
  console.log("grantRole MASTER_MINTER_ROLE                       :::::", process.env.masterminter);
  //setup MASTER_MINTER_ROLE ROLE_ADMIN
  console.log("SET_ROLE_ADMIN MASTER_MINTER_ROLE await            :::::", await instance.MASTER_MINTER_ROLE());
  console.log("SET_ROLE_ADMIN MINTER_ROLE await                   :::::", await instance.MINTER_ROLE());
  await instance.setRoleAdmin(await instance.MINTER_ROLE(), await instance.MASTER_MINTER_ROLE());

  //setup FEE_MANAGER_ROLE
  await instance.grantRole(await instance.FEE_MANAGER_ROLE(), process.env.feemanager);
  console.log("grantRole FEE_MANAGER_ROLE                         :::::", process.env.feemanager);
  //setup FEE_MANAGER_ROLE ROLE_ADMIN
  console.log("SET_ROLE_ADMIN FEE_MANAGER_ROLE await              :::::", await instance.FEE_MANAGER_ROLE());
  console.log("SET_ROLE_ADMIN FEE_HOLDER_ROLE await               :::::", await instance.FEE_HOLDER_ROLE());
  await instance.setRoleAdmin(await instance.FEE_HOLDER_ROLE(), await instance.FEE_MANAGER_ROLE());
}

async function setInitBlackListerRole(instance: Contract) {
  const blacklistManager = new ethers.Wallet(process.env.blacklistManagerPk as string, ethers.provider);
  console.log("blacklistManager address                 :::::", blacklistManager.address);
  const managerInstance = instance.connect(blacklistManager) as Contract;

  //setup BLACKLIST_MEMBER_ROLE
  await managerInstance.grantRole(await managerInstance.BLACKLIST_MEMBER_ROLE(), process.env.blacklist);
  console.log("grantRole BLACKLIST_MEMBER_ROLE               :::::", process.env.blacklist);
}

async function setInitWhiteListerRole(instance: Contract) {
  const whitelistManager = new ethers.Wallet(process.env.whitelistManagerPk as string, ethers.provider);
  console.log("whitelistManager address                 :::::", whitelistManager.address);
  const managerInstance = instance.connect(whitelistManager) as Contract;

  //setup WHITELIST_MEMBER_ROLE
  await managerInstance.grantRole(await managerInstance.WHITELIST_MEMBER_ROLE(), process.env.whitelist);
  console.log("grantRole WHITELIST_MEMBER_ROLE               :::::", process.env.whitelist);
}

async function setInitMinterRole(instance: Contract) {
  const masterminter = new ethers.Wallet(process.env.masterminterPk as string, ethers.provider);
  console.log("masterminter address                     :::::", masterminter.address);
  const managerInstance = instance.connect(masterminter) as Contract;

  //setup MINTER_ROLE
  await managerInstance.grantRole(await managerInstance.MINTER_ROLE(), process.env.minter);
  console.log("grantRole MINTER_ROLE                    :::::", process.env.minter);
}

async function setInitFeeHoldRole(instance: Contract) {
  const feemanager = new ethers.Wallet(process.env.feemanagerPk as string, ethers.provider);
  console.log("feemanager address                     :::::", feemanager.address);
  const managerInstance = instance.connect(feemanager) as Contract;

  //setup FEE_HOLDER_ROLE
  await managerInstance.grantRole(await managerInstance.FEE_HOLDER_ROLE(), process.env.feehold);
  console.log("grantRole FEE_HOLDER_ROLE                :::::", process.env.feehold);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
