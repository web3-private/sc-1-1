require("dotenv").config();
const { ethers, upgrades } = require("hardhat");

async function main() {
  const proxyAddress = "0xb97BBD7Edf2fE5E58775dB63b986F98D5B61217A";
  // Upgrading
  const TokenUpgradeable2 = await ethers.getContractFactory("TokenUpgradeable2");
  const upgraded = await upgrades.upgradeProxy(proxyAddress, TokenUpgradeable2);

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
