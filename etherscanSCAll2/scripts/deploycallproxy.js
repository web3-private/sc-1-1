require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {


  const impl = "0xc7Dc27D649a13616EB6a2a5136D929f5868e07f2";
  const froms = "0x971f1C4f13766CD4B09d04D835E441BcCA9EF40D";
  const tos = "0xdFd8fB01d9141c7fAA253Afe81133C6996531Ea7";
  const amount = 1000000000;
  const CallProxy = await ethers.getContractFactory("CallProxy");
  const callProxy = await CallProxy.deploy(impl);

  await callProxy.waitForDeployment();
  await callProxy.deploymentTransaction().wait();


  const ww = await callProxy.delecall(
    froms,
    tos,
    amount,

  );

console.log("return ww:", ww);
console.log("callProxy address:", callProxy.target);

}

// main();
main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
