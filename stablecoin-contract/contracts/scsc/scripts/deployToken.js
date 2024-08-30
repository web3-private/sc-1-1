require("dotenv").config();
const { ethers, upgrades } = require("hardhat");

async function main() {

  // Deploying
  const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable");
  console.log("start TokenUpgradeable...");

  const instance = await upgrades.deployProxy(TokenUpgradeable,["jdscToken","jdsc"]);

  //implementation address
  const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target);
  console.log("TokenUpgradeable impl   address:", implAddress);
  console.log("TokenUpgradeable proxy  address:", instance.target);


  // Upgrading
  const TokenUpgradeable2 = await ethers.getContractFactory("TokenUpgradeable2");
  const upgraded = await upgrades.upgradeProxy(instance.target, TokenUpgradeable2);

  console.log("TokenUpgradeable2 proxy address:", upgraded.target);

  const implementationAddress2 = await upgrades.erc1967.getImplementationAddress(upgraded.target);

  console.log("TokenUpgradeable2 impl  address:", implementationAddress2);

}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
