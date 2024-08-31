require("dotenv").config();
const { ethers, upgrades } = require("hardhat");

async function main() {





// TokenUpgradeable impl1   address: 0xffBE95d0Ba046C4A1E31B2DC31D9f7c98BF9C9aE
// TokenUpgradeable deploy  address: 0xae20A6dBe665818C084bD9e683518d100ceA63F1
  const proxyAddress = "0xae20A6dBe665818C084bD9e683518d100ceA63F1";


  // TokenUpgradeable2 address: 0xA138cF22ACA913E91C1C87Dc3449f4f92DE19C0D
  // Upgrading
  const TokenUpgradeable2 = await ethers.getContractFactory("TokenUpgradeable2");
  console.log("正在部署 TokenUpgradeable2...");
  const upgraded = await upgrades.upgradeProxy(proxyAddress, TokenUpgradeable2);
  console.log("TokenUpgradeable2 address:", upgraded.target);




  // TokenUpgradeable2 address: 0xA138cF22ACA913E91C1C87Dc3449f4f92DE19C0D
  // TokenUpgradeable2 impl2  address: 0xffBE95d0Ba046C4A1E31B2DC31D9f7c98BF9C9aE
    //实现合约地址
  const dd2 = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  console.log("TokenUpgradeable2 impl2  address:", dd2);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
