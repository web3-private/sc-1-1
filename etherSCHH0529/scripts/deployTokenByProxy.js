require("dotenv").config();
const { ethers, upgrades } = require("hardhat");

async function main() {


  const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable");
  const tokenUpgradeable = await TokenUpgradeable.deploy();
  await tokenUpgradeable.deployed();

  const ProxyAdmin = await ethers.getContractFactory("ProxyAdmin");
  const proxyAdmin = await ProxyAdmin.deploy();
  await proxyAdmin.deployed();

  const data = tokenUpgradeable.interface.encodeFunctionData("initialize", ["jdscToken" ,"jdsc"]);
  const TransparentUpgradeableProxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
  const proxy = await TransparentUpgradeableProxy.deploy(tokenUpgradeable.address, proxyAdmin.address, data);
  await proxy.deployed();

  console.log("Proxy deployed to:", proxy.address);

  
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
