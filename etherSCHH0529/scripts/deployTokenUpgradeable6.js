require("dotenv").config();
const { ethers, upgrades } = require("hardhat");

async function main() {

  // Deploying
  const TokenUpgradeable3 = await ethers.getContractFactory("TokenUpgradeable3");
  console.log("start TokenUpgradeable...");

  const instance = await upgrades.deployProxy(TokenUpgradeable3,["jdscToken","jdsc"]);

  //implementation address
  //Logical contract address of the agency contract
  const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target);
  console.log("TokenUpgradeable impl   address:", implAddress);
  console.log("TokenUpgradeable proxy  address:", instance.target);


  // Upgrading
  const TokenUpgradeable31 = await ethers.getContractFactory("TokenUpgradeable3");
  const upgraded = await upgrades.upgradeProxy(instance.target, TokenUpgradeable31);

  console.log("TokenUpgradeable31 proxy address:", upgraded.target);

  const implementationAddress3 = await upgrades.erc1967.getImplementationAddress(upgraded.target);

  console.log("TokenUpgradeable31 impl  address:", implementationAddress3);

}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
