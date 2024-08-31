require("dotenv").config();
const { ethers, upgrades } = require("hardhat");

async function main() {

  // Deploying
  const TokenUpgradeable4 = await ethers.getContractFactory("TokenUpgradeable4");
  console.log("start TokenUpgradeable...");

  const instance = await upgrades.deployProxy(TokenUpgradeable4,["jdscToken","jdsc"]);

  console.log("TokenUpgradeable4 upgrades  :", await upgrades.erc1967.getImplementationAddress(instance.target));
  //implementation address
  //Logical contract address of the agency contract
  const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target);
  console.log("TokenUpgradeable impl   address:", implAddress);
  console.log("TokenUpgradeable proxy  address:", instance.target);


  // Upgrading
  const TokenUpgradeable41 = await ethers.getContractFactory("TokenUpgradeable4");
  const upgraded = await upgrades.upgradeProxy(instance.target, TokenUpgradeable41);

  console.log("TokenUpgradeable41 proxy address:", upgraded.target);

  const implementationAddress4 = await upgrades.erc1967.getImplementationAddress(upgraded.target);

  console.log("TokenUpgradeable41 impl  address:", implementationAddress4);

}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
