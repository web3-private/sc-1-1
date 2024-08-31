import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";

async function main() {

  // Deploying
  const FeeAggregator = await ethers.getContractFactory("FeeAggregator");
  console.log("start FeeAggregator...");

  // const instance = await upgrades.deployProxy(FeeAggregator, ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "6"], { kind: 'transparent' });

  const instance = await upgrades.deployProxy(FeeAggregator, ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "6"]);

  //implementation address
  //Logical contract address of the agency contract
  const implAddress = await upgrades.erc1967.getImplementationAddress(instance.target as string);
  console.log("FeeAggregator impl   address:", implAddress);
  console.log("FeeAggregator proxy  address:", instance.target);

  // 使用 getAdminAddress 获取代理管理员地址
  const adminAddress = await upgrades.erc1967.getAdminAddress(instance.target as string);
  console.log("Admin address:", adminAddress);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
