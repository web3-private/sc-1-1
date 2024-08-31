import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";
import { Contract } from "ethers";
async function main() {
  // Deploying
  const TokenUpgradeable1 = await ethers.getContractFactory("TokenUpgradeable");
  console.log("start TokenUpgradeable...");

  const instance = await upgrades.deployProxy(TokenUpgradeable1, [
    process.env.owner,
    process.env.tokenName,
    process.env.tokenSymbol,
    process.env.tokenDecimals,
  ]);

  // const instance = await upgrades.deployProxy(TokenUpgradeable1, [process.env.owner, process.env.admin, process.env.tokenName, process.env.tokenSymbol]);

  console.log("TokenUpgradeable proxy  address:", instance.target);

  //implementation address
  //Logical contract address of the agency contract
  const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target as string);
  console.log("TokenUpgradeable impl   address:", implAddress);
  console.log("TokenUpgradeable proxy  address:", instance.target);

  // 使用 getAdminAddress 获取代理管理员地址
  const adminAddress = await upgrades.erc1967.getAdminAddress(instance.target as string);
  console.log("Admin address                  :", adminAddress);

  //setup WHITELISTER_MANAGER_ROLE
  // console.log("WHITELISTER_MANAGER_ROLE await:::::",  instance.WHITELISTER_MANAGER_ROLE);
  console.log("WHITELISTER_MANAGER_ROLE await:::::", await instance.WHITELISTER_MANAGER_ROLE());
  // const WHITELISTER_MANAGER_ROLE = await instance.WHITELISTER_MANAGER_ROLE();
  // console.log("WHITELISTER_MANAGER_ROLE await:::::", WHITELISTER_MANAGER_ROLE);

  // const owner = process.env.owner as string;
  const owner = new ethers.Wallet(process.env.ownerPk as string, ethers.provider);
  const ownerInstance = instance.connect(owner) as Contract;

  await setInitRoleAdmin(ownerInstance);
  await setInitRole(ownerInstance);

  // //setup PAUSER_ROLE
  // instance.grantRole(instance.PAUSER_ROLE, process.env.owner);
  // console.log("grantRole PAUSER_ROLE      :::::", process.env.owner);

  // //setup BLACKLISTER_ROLE
  // instance.grantRole(instance.BLACKLISTER_ROLE, process.env.owner);
  // console.log("grantRole BLACKLISTER_ROLE :::::", process.env.owner);

  // //setup WHITELISTER_ROLE
  // instance.grantRole(instance.WHITELISTER_ROLE, process.env.owner);
  // console.log("grantRole WHITELISTER_ROLE :::::", process.env.owner);

  // //setup MINTER_ROLE
  // instance.grantRole(instance.MINTER_ROLE, process.env.owner);
  // console.log("grantRole MINTER_ROLE      :::::", process.env.owner);

  // //setup FEE_HOLDER_ROLE
  // instance.grantRole(instance.FEE_HOLDER_ROLE, process.env.owner);
  // console.log("grantRole FEE_HOLDER_ROLE  :::::", process.env.owner);

  // // instance.grantRole(instance.DEFAULT_ADMIN_ROLE, process.env.owner);
  // // _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
  // //       _grantRole(ADMIN_ROLE, initialOwner);

  // //       _grantRole(PAUSER_ROLE, initialOwner);
  // //       _setRoleAdmin(PAUSER_ROLE, ADMIN_ROLE);

  // //       _grantRole(BLACKLISTER_MANAGER_ROLE, initialOwner);

  // //       _setRoleAdmin(BLACKLISTER_ROLE, BLACKLISTER_MANAGER_ROLE);

  // //       _grantRole(WHITELISTER_MANAGER_ROLE, initialOwner);

  // //       _setRoleAdmin(WHITELISTER_ROLE, WHITELISTER_MANAGER_ROLE);

  // //       _grantRole(MASTER_MINTER_ROLE, initialOwner);

  // //       _setRoleAdmin(MINTER_ROLE, MASTER_MINTER_ROLE);

  // //       _grantRole(FEE_MANAGER_ROLE, initialOwner);

  // //       _setRoleAdmin(FEE_HOLDER_ROLE, FEE_MANAGER_ROLE);

  // // console.log("WHITELISTER_ROLE await:::::", await instance.getWhitelisterRole());
  // // const WHITELISTER_ROLE = await instance.WHITELISTER_ROLE();

  // // console.log("WHITELISTER_ROLE:::::", WHITELISTER_ROLE);
  // // const owner = process.env.owner as string;

  // // console.log("owner:::::", owner);
}

async function setInitRoleAdmin(instance: Contract) {
  // _grantRole(PAUSER_ROLE, initialOwner);
  // _setRoleAdmin(PAUSER_ROLE, ADMIN_ROLE);

  // _grantRole(BLACKLISTER_MANAGER_ROLE, initialOwner);

  // _setRoleAdmin(BLACKLISTER_ROLE, BLACKLISTER_MANAGER_ROLE);

  // _grantRole(WHITELISTER_MANAGER_ROLE, initialOwner);

  // _setRoleAdmin(WHITELISTER_ROLE, WHITELISTER_MANAGER_ROLE);

  // _grantRole(MASTER_MINTER_ROLE, initialOwner);

  // _setRoleAdmin(MINTER_ROLE, MASTER_MINTER_ROLE);

  // _grantRole(FEE_MANAGER_ROLE, initialOwner);

  // _setRoleAdmin(FEE_HOLDER_ROLE, FEE_MANAGER_ROLE);

  //setup PAUSER_ROLE
  // console.log("grantRole PAUSER_ROLE      start :::::", process.env.owner);
  // console.log("grantRole setInitRoleAdmin      start instance :::::", instance);
  // console.log("grantRole setInitRoleAdmin      start process.env.owner :::::", process.env.owner);
  await instance.grantRole(await instance.PAUSER_ROLE(), process.env.owner);
  console.log("grantRole PAUSER_ROLE                              :::::", process.env.owner);
  //setup PAUSER_ROLE
  console.log("SET_ROLE_ADMIN ADMIN_ROLE await                    :::::", await instance.ADMIN_ROLE());
  await instance.setRoleAdmin(await instance.PAUSER_ROLE(), await instance.ADMIN_ROLE());

  //setup BLACKLISTER_MANAGER_ROLE
  await instance.grantRole(await instance.BLACKLISTER_MANAGER_ROLE(), process.env.owner);
  console.log("grantRole BLACKLISTER_MANAGER_ROLE                 :::::", process.env.owner);
  //setup BLACKLISTER_MANAGER_ROLE
  console.log("SET_ROLE_ADMIN BLACKLISTER_MANAGER_ROLE await      :::::", await instance.BLACKLISTER_MANAGER_ROLE());
  await instance.setRoleAdmin(await instance.BLACKLISTER_ROLE(), await instance.BLACKLISTER_MANAGER_ROLE());

  //setup WHITELISTER_MANAGER_ROLE
  await instance.grantRole(await instance.WHITELISTER_MANAGER_ROLE(), process.env.owner);
  console.log("grantRole WHITELISTER_MANAGER_ROLE                 :::::", process.env.owner);
  //setup WHITELISTER_MANAGER_ROLE
  console.log("SET_ROLE_ADMIN WHITELISTER_MANAGER_ROLE await      :::::", await instance.WHITELISTER_MANAGER_ROLE());
  await instance.setRoleAdmin(await instance.WHITELISTER_ROLE(), await instance.WHITELISTER_MANAGER_ROLE());

  //setup MASTER_MINTER_ROLE
  await instance.grantRole(await instance.MASTER_MINTER_ROLE(), process.env.owner);
  console.log("grantRole MASTER_MINTER_ROLE                       :::::", process.env.owner);
  //setup MASTER_MINTER_ROLE
  console.log("SET_ROLE_ADMIN MASTER_MINTER_ROLE await            :::::", await instance.MASTER_MINTER_ROLE());
  await instance.setRoleAdmin(await instance.MINTER_ROLE(), await instance.MASTER_MINTER_ROLE());

  //setup FEE_MANAGER_ROLE
  await instance.grantRole(await instance.FEE_MANAGER_ROLE(), process.env.owner);
  console.log("grantRole FEE_MANAGER_ROLE                         :::::", process.env.owner);
  //setup FEE_MANAGER_ROLE
  console.log("SET_ROLE_ADMIN FEE_MANAGER_ROLE await              :::::", await instance.FEE_MANAGER_ROLE());
  await instance.setRoleAdmin(await instance.FEE_HOLDER_ROLE(), await instance.FEE_MANAGER_ROLE());
}

async function setInitRole(instance: Contract) {
  // console.log("grantRole setInitRole      start instance :::::", instance);
  //setup PAUSER_ROLE
  await instance.grantRole(await instance.PAUSER_ROLE(), process.env.owner);
  console.log("grantRole PAUSER_ROLE      :::::", process.env.owner);

  //setup BLACKLISTER_ROLE
  await instance.grantRole(await instance.BLACKLISTER_ROLE(), process.env.owner);
  console.log("grantRole BLACKLISTER_ROLE :::::", process.env.owner);

  //setup WHITELISTER_ROLE
  await instance.grantRole(await instance.WHITELISTER_ROLE(), process.env.owner);
  console.log("grantRole WHITELISTER_ROLE :::::", process.env.owner);

  //setup MINTER_ROLE
  await instance.grantRole(await instance.MINTER_ROLE(), process.env.owner);
  console.log("grantRole MINTER_ROLE      :::::", process.env.owner);

  //setup FEE_HOLDER_ROLE
  await instance.grantRole(await instance.FEE_HOLDER_ROLE(), process.env.owner);
  console.log("grantRole FEE_HOLDER_ROLE  :::::", process.env.owner);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
