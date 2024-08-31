require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {


  const owneraddress = process.env.owneraddress;

  const JDSCTokenV1WithFees = await ethers.getContractFactory("JDSCTokenV1WithFees");
  const jDSCTokenV1WithFees = await JDSCTokenV1WithFees.deploy();

//   await jDSCTokenV1WithFees.waitForDeployment();
  await jDSCTokenV1WithFees.deploymentTransaction().wait();


    await jDSCTokenV1WithFees.initialize(
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


//初始化
await jDSCTokenV1WithFees.initializeV1WithFee(accountsToBlacklist ,owneraddress);

console.log("jDSCTokenV1WithFees address:", jDSCTokenV1WithFees.target);

//设置手续费参数
const newBasisPoints = 0.1;
const newMaxFee = 10000;
await jDSCTokenV1WithFees.setParams(newBasisPoints, newMaxFee);

// //账户下的总手续费
// const _account = "";
// await jDSCTokenV1WithFees.totalFee(_account);

const feeAccount = "";
const from = "";
const to = "";
const value = "";
const validAfter = "";
const validBefore = "";
const nonce = "";
const signature = "";
jDSCTokenV1WithFees.transferWithAuthorizationFee(
  feeAccount, 
  from,
  to,
  value,
  validAfter,
  validBefore,
  nonce,
  signature
);

}

// main();
main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
