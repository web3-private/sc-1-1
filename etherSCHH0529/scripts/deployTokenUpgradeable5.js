require("dotenv").config();
const { ethers, upgrades } = require("hardhat");

async function main() {


  // Deploying
  const TokenUpgradeable1 = await ethers.getContractFactory("TokenUpgradeable1");
  // const tokenUpgradeable2 = await TokenUpgradeable2.deploy();
  console.log("正在部署 TokenUpgradeable2...");

  const instance = await upgrades.deployProxy(TokenUpgradeable1,["jdscToken","jdsc"]);

  // await instance.deploymentTransaction();
  //实现合约地址
  const dd = await upgrades.erc1967.getImplementationAddress(instance.target);
  console.log("TokenUpgradeable impl1   address:", dd);
  console.log("TokenUpgradeable deploy  address:", instance.target);
  
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
