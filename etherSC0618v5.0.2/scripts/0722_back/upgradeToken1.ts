import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";

async function main() {

  // const proxyAddress = "0x6F8b33D3356184351c7AF479e0C4748eBE36753d";
  const proxyAddress = process.env.proxyAddress

  if (!proxyAddress) {
    throw new Error("Proxy address is undefined. Please set the proxyAddress in your .env file.");
  }

  // Upgrading
  const TokenUpgradeable2 = await ethers.getContractFactory("TokenUpgradeable");
  const upgraded = await upgrades.upgradeProxy(proxyAddress, TokenUpgradeable2);

  console.log("TokenUpgradeable2 proxy address:", upgraded.target);

  const implementationAddress2 = await upgrades.erc1967.getImplementationAddress(upgraded.target as string);

  console.log("TokenUpgradeable2 impl  address:", implementationAddress2);

}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
