const { ethers } = require("hardhat");

async function main() {

     const Lock = await ethers.getContractFactory("Lock");
   const lock = await Lock.deploy(1714287590);
//    await lock.withdraw();

  console.log("Lock address:", lock.address);
}

main();
