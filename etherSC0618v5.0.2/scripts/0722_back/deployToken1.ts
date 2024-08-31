import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";

async function main() {

  // Deploying
  const TokenUpgradeable1 = await ethers.getContractFactory("TokenUpgradeable");
  console.log("start TokenUpgradeable...");

  // const instance = await upgrades.deployProxy(TokenUpgradeable1, ["jdscToken", "jdsc"], { kind: 'transparent' });
 
  const instance = await upgrades.deployProxy(TokenUpgradeable1, [process.env.owner, process.env.tokenName, process.env.tokenSymbol]);

  // const instance = await upgrades.deployProxy(TokenUpgradeable1, ["0xbD8b976650e9A799B0ffE3666E2970F80a9a962f", "jdscToken", "jdsc"]);
  console.log("TokenUpgradeable proxy  address:", instance.target);

  //implementation address
  //Logical contract address of the agency contract
  const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target as string);
  // console.log("TokenUpgradeable impl   address:", implAddress);
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
