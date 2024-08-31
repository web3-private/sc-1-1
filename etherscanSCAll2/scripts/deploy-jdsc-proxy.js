require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {

  const implementationContract = "0x33BE085748E880c3B03CA5159e135cb698b59296";
  const owneraddress = process.env.owneraddress;
  const JDSCTokenProxy = await ethers.getContractFactory("JDSCTokenProxy");
  const jdscCTokenProxy = await JDSCTokenProxy.deploy(implementationContract);
//   await jdscCTokenProxy.waitForDeployment();
  await jdscCTokenProxy.deploymentTransaction().wait();

console.log("jdscCTokenProxy address:", jdscCTokenProxy.target);


}

// main();
main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
