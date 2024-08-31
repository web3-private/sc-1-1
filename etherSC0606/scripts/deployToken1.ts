import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";

async function main() {

  // Deploying
  const TokenUpgradeable1 = await ethers.getContractFactory("TokenUpgradeable1");
  console.log("start TokenUpgradeable...");

  // const instance = await upgrades.deployProxy(TokenUpgradeable1, ["jdscToken", "jdsc"], { kind: 'transparent' });

  const instance = await upgrades.deployProxy(TokenUpgradeable1, ["jdscToken", "jdsc"]);

  //implementation address
  //Logical contract address of the agency contract
  const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target as string);
  console.log("TokenUpgradeable impl   address:", implAddress);
  console.log("TokenUpgradeable proxy  address:", instance.target);

  // 使用 getAdminAddress 获取代理管理员地址
  const adminAddress = await upgrades.erc1967.getAdminAddress(instance.target as string);
  console.log("Admin address:", adminAddress);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
