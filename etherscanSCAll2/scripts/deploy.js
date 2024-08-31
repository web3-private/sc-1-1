require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {

  const owneraddress = process.env.owneraddress;
  const JDSCTokenV1 = await ethers.getContractFactory("JDSCTokenV1");
  const jDSCTokenV1 = await JDSCTokenV1.deploy();
//   await jDSCTokenV1.waitForDeployment();
  await jDSCTokenV1.deploymentTransaction().wait();

  const JDSCTokenV1WithFees = await ethers.getContractFactory("JDSCTokenV1WithFees");
  const jDSCTokenV1WithFees = await JDSCTokenV1WithFees.deploy();

//   await jDSCTokenV1WithFees.waitForDeployment();
  await jDSCTokenV1WithFees.deploymentTransaction().wait();


    await jDSCTokenV1.initialize(
    "jdsc1",
    "jdsctoken",
    "hkd",
    6,
    2177777,
    owneraddress,
    owneraddress,
    owneraddress,
    owneraddress,

);

const accountsToBlacklist = ["0x971f1C4f13766CD4B09d04D835E441BcCA9EF40D"];
accountsToBlacklist.push("0x971f1C4f13766CD4B09d04D835E441BcCA9EF40D");
console.log("数组元素accountsToBlacklist:", accountsToBlacklist);


// await jDSCTokenV1WithFees.initializeV1WithFee(accountsToBlacklist ,owneraddress);

console.log("jDSCTokenV1 address:", jDSCTokenV1.target);
console.log("jDSCTokenV1WithFees address:", jDSCTokenV1WithFees.target);


}

// main();
main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
