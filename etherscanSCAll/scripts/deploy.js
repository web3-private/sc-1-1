const { ethers } = require("hardhat");

async function main() {

  let owneraddress = "0x971f1C4f13766CD4B09d04D835E441BcCA9EF40D";
  const JDSCTokenV1 = await ethers.getContractFactory("JDSCTokenV1");

  const JDSCTokenV1WithFees = await ethers.getContractFactory("JDSCTokenV1WithFees");

        // string memory tokenName,
        // string memory tokenSymbol,
        // string memory tokenCurrency,
        // uint8 tokenDecimals,
        // uint256 tokenSupply,
        // address newMasterMinter,
        // address newPauser,
        // address newBlacklister,
        // address newOwner


        JDSCTokenV1.initialize(
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
JDSCTokenV1WithFees.initializeV1WithFee(owneraddress);

  console.log("JDSCTokenV1WithFees address:", JDSCTokenV1WithFees.address);
}

main();
// main()
//   .then(() => process.exit(0))
//   .catch((err) => {
//     console.error("Error:", err.message || err);
//     process.exit(1);
//   });
