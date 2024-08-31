import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";

async function main() {
  // Deploying
  const TokenUpgradeable1 = await ethers.getContractFactory("TokenUpgradeable");
  console.log("start TokenUpgradeable...");

  // const instance = await upgrades.deployProxy(TokenUpgradeable1, ["jdscToken", "jdsc"], { kind: 'transparent' });

  const instance = await upgrades.deployProxy(TokenUpgradeable1, [
    process.env.owner,
    process.env.tokenName,
    process.env.tokenSymbol,
  ]);

  // const instance = await upgrades.deployProxy(TokenUpgradeable1, [process.env.owner, process.env.admin, process.env.tokenName, process.env.tokenSymbol]);

  console.log("TokenUpgradeable proxy  address:", instance.target);

  //   //implementation address
  //   //Logical contract address of the agency contract
  //   const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target as string);
  //   console.log("TokenUpgradeable impl   address:", implAddress);
  //   console.log("TokenUpgradeable proxy  address:", instance.target);

  //   // 使用 getAdminAddress 获取代理管理员地址
  //   const adminAddress = await upgrades.erc1967.getAdminAddress(instance.target as string);
  //   console.log("Admin address                  :", adminAddress);

  // init role
  // instance.

  // console.log("WHITELISTER_ROLE await:::::", await instance.);
  // const WHITELISTER_ROLE = await instance.WHITELISTER_ROLE();

  
  console.log("WHITELISTER_MANAGER_ROLE await:::::", await instance.WHITELISTER_MANAGER_ROLE());
  const WHITELISTER_MANAGER_ROLE = await instance.WHITELISTER_MANAGER_ROLE();
  console.log("WHITELISTER_MANAGER_ROLE await:::::", WHITELISTER_MANAGER_ROLE);

  console.log("WHITELISTER_ROLE await:::::", await instance.getWhitelisterRole());
  const WHITELISTER_ROLE = await instance.WHITELISTER_ROLE();

  // console.log("WHITELISTER_ROLE:::::", WHITELISTER_ROLE);
  const owner = process.env.owner as string;

  console.log("owner:::::", owner);
  // const ownerInstance = instance.connect(owner) as Contract;
  // // Grant WHITELISTER_ROLE to otherAccount
  // await instance.grantRole(WHITELISTER_ROLE, process.env.otherAccount.address);

  // // Check if otherAccount has WHITELISTER_ROLE
  // await instance.hasRole(WHITELISTER_ROLE, otherAccount.address);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
