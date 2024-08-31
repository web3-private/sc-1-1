import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";

async function main() {

  const proxyAddress = "0x6b73143aD9C9Cc2A8000Eceb7593154324D38B38";
  // Upgrading
  const TokenUpgradeable2 = await ethers.getContractFactory("TokenUpgradeable2");
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
