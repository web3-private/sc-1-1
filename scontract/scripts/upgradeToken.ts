import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";

async function main() {

  const proxyAddress = process.env.proxyAddress
  console.log("TokenUpgradeable2 proxyAddress :", proxyAddress);

  if (!proxyAddress) {
    throw new Error("Proxy address is undefined. Please set the proxyAddress in your .env file.");
  }


  // Upgrading
  const deployer = new ethers.Wallet(process.env.deployerPk as string, ethers.provider);
  console.log("TokenUpgradeable deployer  address:", deployer);
  const TokenUpgradeable2 = await ethers.getContractFactory("TokenUpgradeable", deployer);
  const upgraded = await upgrades.upgradeProxy(proxyAddress, TokenUpgradeable2);


  console.log("TokenUpgradeable2 proxy address:", upgraded.target);

  // const implementationAddress2 = await upgrades.erc1967.getImplementationAddress(upgraded.target as string);

  // console.log("TokenUpgradeable2 impl  address:", implementationAddress2);

}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
