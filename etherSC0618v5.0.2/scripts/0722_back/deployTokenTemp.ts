require("dotenv").config();
import { ethers, upgrades } from "hardhat";

async function main() {

  // Deploying
  const TokenUpgradeableTemp1 = await ethers.getContractFactory("TokenUpgradeableTemp");
  console.log("start TokenUpgradeableTemp1...");

  const instance = await upgrades.deployProxy(TokenUpgradeableTemp1,["jdscToken","jdsc"], {
    initializer: 'initialize'
  });
  // const instance = await upgrades.deployProxy(TokenUpgradeableTemp1,["jdscToken","jdsc"]);



  console.log(upgrades);
  console.log(upgrades.erc1967.getImplementationAddress);
  //implementation address
  //Logical contract address of the agency contract
  const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target as string);
  console.log("TokenUpgradeableTemp1 impl   address:", implAddress);
  console.log("TokenUpgradeableTemp1 proxy  address:", instance.target);


  // Upgrading
  const TokenUpgradeableTemp2 = await ethers.getContractFactory("TokenUpgradeableTemp");
  const upgraded = await upgrades.upgradeProxy(instance.target, TokenUpgradeableTemp2);

  console.log("TokenUpgradeableTemp2 proxy address:", upgraded.target);

  const implementationAddress2 = await upgrades.erc1967.getImplementationAddress(upgraded.target as string);

  console.log("TokenUpgradeableTemp2 impl  address:", implementationAddress2);

}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
