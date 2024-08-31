import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";
import { Contract } from "ethers";

import { readFileSync } from 'fs';
import { join } from 'path';

async function main() {
  // deployToken2
  // // Deploying
  // const deployer = new ethers.Wallet(process.env.deployerPk as string, ethers.provider);
  // const TokenUpgradeable1 = await ethers.getContractFactory("TokenUpgradeable", deployer);
  // console.log("start TokenUpgradeable...");

  // const instance = await upgrades.deployProxy(TokenUpgradeable1, [
  //   process.env.owner,
  //   process.env.tokenName,
  //   process.env.tokenSymbol,
  //   process.env.tokenDecimals,
  // ]);
  // await instance.waitForDeployment();

  // // console.log("TokenUpgradeable deployer  address:", instance);
  // console.log("TokenUpgradeable proxy  address:", instance.target);

  // //implementation address
  // //Logical contract address of the agency contract
  // const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target as string);
  // console.log("TokenUpgradeable impl   address:", implAddress);
  // console.log("TokenUpgradeable proxy  address:", instance.target);

  // // 使用 getAdminAddress 获取代理管理员地址
  // const adminAddress = await upgrades.erc1967.getAdminAddress(instance.target as string);
  // console.log("Admin address                  :", adminAddress);

  // // 合约 JSON 文件路径
  // const contractJsonPath = join(__dirname, '../artifacts/contracts/TokenUpgradeable.sol/TokenUpgradeable.json');

  // // 读取并解析合约 JSON 文件
  // const contractJson = JSON.parse(readFileSync(contractJsonPath, 'utf-8'));
  // // console.log("contractJson                  :", contractJson);
  // // 获取 ABI
  // const abi = contractJson.abi;
  // console.log("abi                           :", abi);
  // //
  // //0x5370F78c6af2Da9cF6642382A3a75F9D5aEc9cc1
  // //0x1275D096B9DBf2347bD2a131Fb6BDaB0B4882487
  // // TokenUpgradeable proxy  address: 0xF818A7C2AFC45cF4B9DDC48933C9A1edD624e46f
  // // TokenUpgradeable impl   address: 0x1275D096B9DBf2347bD2a131Fb6BDaB0B4882487
  // const CONTRACT_ADDRESS = "0xF818A7C2AFC45cF4B9DDC48933C9A1edD624e46f";
  // const CONTRACT_ABI = abi;
  // const deployer = new ethers.Wallet(process.env.deployerPk as string, ethers.provider);
  // // 创建合约实例
  // const instance = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, deployer);

  const contractJsonPath = join(__dirname, '../artifacts/contracts/TokenUpgradeable.sol/TokenUpgradeable.json');
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
  await instance.setRoleAdmin(await instance.PAUSER_ROLE(), await instance.ADMIN_ROLE());

  //setup BLACKLISTER_MANAGER_ROLE
  await instance.grantRole(await instance.BLACKLISTER_MANAGER_ROLE(), process.env.blacklistManager);
  console.log("grantRole BLACKLISTER_MANAGER_ROLE                 :::::", process.env.blacklistManager);
  //setup BLACKLISTER_MANAGER_ROLE ROLE_ADMIN
  console.log("SET_ROLE_ADMIN BLACKLISTER_MANAGER_ROLE await      :::::", await instance.BLACKLISTER_MANAGER_ROLE());
  await instance.setRoleAdmin(await instance.BLACKLISTER_ROLE(), await instance.BLACKLISTER_MANAGER_ROLE());

  //setup WHITELISTER_MANAGER_ROLE
  await instance.grantRole(await instance.WHITELISTER_MANAGER_ROLE(), process.env.whitelistManager);
  console.log("grantRole WHITELISTER_MANAGER_ROLE                 :::::", process.env.whitelistManager);
  //setup WHITELISTER_MANAGER_ROLE ROLE_ADMIN
  console.log("SET_ROLE_ADMIN WHITELISTER_MANAGER_ROLE await      :::::", await instance.WHITELISTER_MANAGER_ROLE());
  await instance.setRoleAdmin(await instance.WHITELISTER_ROLE(), await instance.WHITELISTER_MANAGER_ROLE());

  //setup MASTER_MINTER_ROLE
  await instance.grantRole(await instance.MASTER_MINTER_ROLE(), process.env.masterminter);
  console.log("grantRole MASTER_MINTER_ROLE                       :::::", process.env.masterminter);
  //setup MASTER_MINTER_ROLE ROLE_ADMIN
  console.log("SET_ROLE_ADMIN MASTER_MINTER_ROLE await            :::::", await instance.MASTER_MINTER_ROLE());
  await instance.setRoleAdmin(await instance.MINTER_ROLE(), await instance.MASTER_MINTER_ROLE());

  //setup FEE_MANAGER_ROLE
  await instance.grantRole(await instance.FEE_MANAGER_ROLE(), process.env.feemanager);
  console.log("grantRole FEE_MANAGER_ROLE                         :::::", process.env.feemanager);
  //setup FEE_MANAGER_ROLE ROLE_ADMIN
  console.log("SET_ROLE_ADMIN FEE_MANAGER_ROLE await              :::::", await instance.FEE_MANAGER_ROLE());
  await instance.setRoleAdmin(await instance.FEE_HOLDER_ROLE(), await instance.FEE_MANAGER_ROLE());
}

async function setInitBlackListerRole(instance: Contract) {
  const blacklistManager = new ethers.Wallet(process.env.blacklistManagerPk as string, ethers.provider);
  console.log("blacklistManager address                 :::::", blacklistManager.address);
  const managerInstance = instance.connect(blacklistManager) as Contract;

  //setup BLACKLISTER_ROLE
  await managerInstance.grantRole(await managerInstance.BLACKLISTER_ROLE(), process.env.blacklist);
  console.log("grantRole BLACKLISTER_ROLE               :::::", process.env.blacklist);
}

async function setInitWhiteListerRole(instance: Contract) {
  const whitelistManager = new ethers.Wallet(process.env.whitelistManagerPk as string, ethers.provider);
  console.log("whitelistManager address                 :::::", whitelistManager.address);
  const managerInstance = instance.connect(whitelistManager) as Contract;

  //setup WHITELISTER_ROLE
  await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), process.env.whitelist);
  console.log("grantRole WHITELISTER_ROLE               :::::", process.env.whitelist);
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
  console.log("masterminter address                     :::::", feemanager.address);
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
