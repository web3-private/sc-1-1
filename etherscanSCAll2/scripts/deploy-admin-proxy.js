require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {

  const implementationContract = "0x33BE085748E880c3B03CA5159e135cb698b59296";
  const owneraddress = process.env.owneraddress;
  const AdminUpgradeabilityProxy = await ethers.getContractFactory("AdminUpgradeabilityProxy");
  const adminUpgradeabilityProxy = await AdminUpgradeabilityProxy.deploy(implementationContract);
//   await adminUpgradeabilityProxy.waitForDeployment();
  await adminUpgradeabilityProxy.deploymentTransaction().wait();

console.log("adminUpgradeabilityProxy address:", adminUpgradeabilityProxy.target);


}

// main();
main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
