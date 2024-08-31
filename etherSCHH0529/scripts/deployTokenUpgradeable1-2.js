require("dotenv").config();
const { ethers, upgrades } = require("hardhat");

async function main() {

  // //initialize param
  // const tokenName = process.env.tokenName
  // const tokenSymbol = process.env.tokenSymbol
  // const tokenCurrency = process.env.tokenCurrency
  // const tokenDecimals = process.env.tokenDecimals
  // const tokenSupply = process.env.tokenSupply
  // const newMasterMinter = process.env.newMasterMinter
  // const newPauser = process.env.newPauser
  // const newBlacklister = process.env.newBlacklister
  // const newOwner = process.env.newOwner


  // const deployer = new ethers.Wallet(process.env.adminPk, ethers.provider);
  // const initializer = new ethers.Wallet(process.env.initializerPk, ethers.provider);
  // const owner = new ethers.Wallet(process.env.ownerPk, ethers.provider);



  // Deploying
  const TokenUpgradeable1 = await ethers.getContractFactory("TokenUpgradeable1");
  // const tokenUpgradeable1 = await TokenUpgradeable1.deploy();
  console.log("正在部署 TokenUpgradeable1...");

  // console.log("upgrades:::", upgrades);
  const instance = await upgrades.deployProxy(TokenUpgradeable1,["jdscToken","jdsc"]);
  // await instance.deployed();
  // console.log("TokenUpgradeable 部署在:", tokenUpgradeable1.address);
  //实现合约地址
  const dd = await upgrades.erc1967.getImplementationAddress(instance.target);
  // console.log("TokenUpgradeable impl:", upgrades.erc1967.getImplementationAddress(instance.target));
  console.log("TokenUpgradeable impl1:", dd);
  // console.log("TokenUpgradeable address:", instance);
  console.log("TokenUpgradeable address:", instance.target);

  const proxyAddress1 = instance.target; // 代理合约地址
  const implementationAddress1 = await upgrades.erc1967.getImplementationAddress(proxyAddress1); // 实现合约地址

  console.log("TokenUpgradeable2 proxyAddress1 address:", proxyAddress1);
  console.log("TokenUpgradeable1 imple address:", implementationAddress1);
  

  // Upgrading
  const TokenUpgradeable2 = await ethers.getContractFactory("TokenUpgradeable2");
  const upgraded = await upgrades.upgradeProxy(instance.target, TokenUpgradeable2);
  // console.log("TokenUpgradeable2 instance address:", upgraded.implementation);
  console.log("TokenUpgradeable2 upgraded address:", upgraded.target);

  const proxyAddress2 = upgraded.target; // 代理合约地址

  console.log("TokenUpgradeable2 proxyAddress2 address:", proxyAddress2);
  const implementationAddress2 = await upgrades.erc1967.getImplementationAddress(proxyAddress2); // 实现合约地址

  console.log("TokenUpgradeable2 imple address:", implementationAddress2);

}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
