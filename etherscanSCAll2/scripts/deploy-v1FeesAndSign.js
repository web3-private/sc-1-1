require("dotenv").config();
const { ethers } = require("hardhat");
// const { keccak256, defaultAbiCoder, toUtf8Bytes } = ethers.utils;

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

  // //设置手续费参数
  // const newBasisPoints = 1;
  // const newMaxFee = 10000;
  // await jDSCTokenV1WithFees.setParams(newBasisPoints, newMaxFee);


  await signTypedData();

  // //账户下的总手续费
  // const _account = "";
  // await jDSCTokenV1WithFees.totalFee(_account);

//   const feeAccount = "";
//   const from = "";
//   const to = "";
//   const value = "";
//   const validAfter = "";
//   const validBefore = "";
//   const nonce = "";
//   const signature = "";
//   jDSCTokenV1WithFees.transferWithAuthorizationFee(
//     feeAccount, 
//     from,
//     to,
//     value,
//     validAfter,
//     validBefore,
//     nonce,
//     signature
//   );

}

async function signTypedData() {
  const signatory = "0x1234567890123456789012345678901234567890"; // 要签名的账户地址

  // 1. 定义你的 EIP-712 类型
  const domainType = [
      { name: "name", type: "string" },
      { name: "version", type: "string" },
      { name: "chainId", type: "uint256" },
      { name: "verifyingContract", type: "address" }
  ];

  const domainData = {
      name: "jdscToken",
      version: "1",
      chainId: 111, // 主网络的 chainId
      verifyingContract: "0x42fAd15b13EBc1126BE2318ad876cb8e5f4b1C3E" // 验证合约的地址
  };

  const entityType = [
    { name: "from", type: "address" },
    { name: "to", type: "address" },
    { name: "value", type: "uint256" },
    { name: "validAfter", type: "uint256" },
    { name: "validBefore", type: "uint256" },
    { name: "nonce", type: "bytes32" }
  ];

    // 构造transferWithAuthorizationFee函数的参数
    const feeAccount = "0x2A049b90Ba0f5656F3bdcC50067A1E3470a4Be09"; // 替换为您的feeAccount地址
    const fromData = "0x2A049b90Ba0f5656F3bdcC50067A1E3470a4Be09";
    // const fromData = signer.address;
    const toData = "0xf896339ca453b561bfeec5b7afdb964668e421e3"; // 替换为您的目标地址
    const valueData = ethers.BigNumber.from("10000"); // 替换为您的转账数量
    console.log("valueData:", valueData);
    const validAfterData =v
    const validBeforeData = ethers.BigNumber.from(1715668022);
    const nonceData = ethers.BigNumber.from(0);
    // const validAfterData = Math.floor(Date.now() / 1000); // 当前时间戳，单位秒
    // const validBeforeData = validAfter + 3600; // 有效期1小时
    // const nonceData = ethers.utils.randomBytes(32);

  const entityData = {
    from: fromData,
    to: toData,
    value: valueData,
    validAfter: validAfterData,
    validBefore: validBeforeData,
    nonce: nonceData
  };

  const typedData = {
      types: {
          EIP712Domain: domainType,
          TransferWithAuthorizationFee: entityType
      },
      domain: domainData,
      primaryType: "TransferWithAuthorizationFee",
      message: entityData
  };

  // 2. 创建要签名的数据对象
  const signature = await ethers.provider.send("eth_signTypedData_v4", [signatory, JSON.stringify(typedData)]);
  console.log("Signature:", signature);
}

// main();
main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
