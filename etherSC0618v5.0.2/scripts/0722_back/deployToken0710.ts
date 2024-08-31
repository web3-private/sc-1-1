import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";

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
  console.log("WHITELISTER_MANAGER_ROLE await:::::", await instance.WHITELISTER_MANAGER_ROLE());
  // const WHITELISTER_MANAGER_ROLE = await instance.WHITELISTER_MANAGER_ROLE();
  // console.log("WHITELISTER_MANAGER_ROLE await:::::", WHITELISTER_MANAGER_ROLE);

  //setup PAUSER_ROLE
  instance.grantRole(instance.PAUSER_ROLE, process.env.owner);
  console.log("grantRole PAUSER_ROLE      :::::", process.env.owner);

  //setup BLACKLISTER_ROLE
  instance.grantRole(instance.BLACKLISTER_ROLE, process.env.owner);
  console.log("grantRole BLACKLISTER_ROLE :::::", process.env.owner);

  //setup WHITELISTER_ROLE
  instance.grantRole(instance.WHITELISTER_ROLE, process.env.owner);
  console.log("grantRole WHITELISTER_ROLE :::::", process.env.owner);

  //setup MINTER_ROLE
  instance.grantRole(instance.MINTER_ROLE, process.env.owner);
  console.log("grantRole MINTER_ROLE      :::::", process.env.owner);

  //setup FEE_HOLDER_ROLE
  instance.grantRole(instance.FEE_HOLDER_ROLE, process.env.owner);
  console.log("grantRole FEE_HOLDER_ROLE  :::::", process.env.owner);

  // instance.grantRole(instance.DEFAULT_ADMIN_ROLE, process.env.owner);
  // _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
  //       _grantRole(ADMIN_ROLE, initialOwner);

  //       _grantRole(PAUSER_ROLE, initialOwner);
  //       _setRoleAdmin(PAUSER_ROLE, ADMIN_ROLE);

  //       _grantRole(BLACKLISTER_MANAGER_ROLE, initialOwner);

  //       _setRoleAdmin(BLACKLISTER_ROLE, BLACKLISTER_MANAGER_ROLE);

  //       _grantRole(WHITELISTER_MANAGER_ROLE, initialOwner);

  //       _setRoleAdmin(WHITELISTER_ROLE, WHITELISTER_MANAGER_ROLE);

  //       _grantRole(MASTER_MINTER_ROLE, initialOwner);

  //       _setRoleAdmin(MINTER_ROLE, MASTER_MINTER_ROLE);

  //       _grantRole(FEE_MANAGER_ROLE, initialOwner);

  //       _setRoleAdmin(FEE_HOLDER_ROLE, FEE_MANAGER_ROLE);

  // console.log("WHITELISTER_ROLE await:::::", await instance.getWhitelisterRole());
  // const WHITELISTER_ROLE = await instance.WHITELISTER_ROLE();

  // console.log("WHITELISTER_ROLE:::::", WHITELISTER_ROLE);
  // const owner = process.env.owner as string;

  // console.log("owner:::::", owner);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
