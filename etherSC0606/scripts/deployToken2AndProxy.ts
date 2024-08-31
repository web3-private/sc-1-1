import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";

async function main() {

  // Deploying
  const TokenUpgradeable1 = await ethers.getContractFactory("TokenUpgradeable1");
  console.log("start TokenUpgradeable...");

  const instance = await upgrades.deployProxy(TokenUpgradeable1,["jdscToken","jdsc"]);

  //implementation address
  //Logical contract address of the agency contract
  const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target as string);
  console.log("TokenUpgradeable impl   address:", implAddress);
  console.log("TokenUpgradeable proxy  address:", instance.target);


    // Deploy proxy admin:
    const proxyAdminFactory = await ethers.getContractFactory(
      "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol:ProxyAdmin",
      deployer
  );
  const deployTransactionAdmin = (await proxyAdminFactory.getDeployTransaction()).data;
  const dataCallAdmin = proxyAdminFactory.interface.encodeFunctionData("transferOwnership", [deployer.address]);
  const [proxyAdminAddress, isProxyAdminDeployed] = await create2Deployment(
      zkEVMDeployerContract,
      salt,
      deployTransactionAdmin,
      dataCallAdmin,
      deployer

      
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
