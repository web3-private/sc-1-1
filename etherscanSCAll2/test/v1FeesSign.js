// require("dotenv").config();
// // const { ethers } = require("hardhat");
// // const { keccak256, defaultAbiCoder, toUtf8Bytes } = ethers.utils;
// // scripts/signMessage.js
// const { ethers } = require("hardhat");
// // const { keccak256, defaultAbiCoder, toUtf8Bytes, solidityPack } = ethers.utils;

// async function main() {


//   const owneraddress = process.env.owneraddress;

//   await signTypedData();
//   console.log("signTypedData:");
// }

// async function signTypedData() {
//   // const signatory = "0xF896339CA453B561BfEec5b7Afdb964668E421e3"; // 要签名的账户地址
//   const [signatory] = await ethers.getSigners();
//   // 1. 定义你的 EIP-712 类型
//   const domainType = [
//       { name: "name", type: "string" },
//       { name: "version", type: "string" },
//       { name: "chainId", type: "uint256" },
//       { name: "verifyingContract", type: "address" }
//   ];

//   const domainData = {
//       name: "jdscToken",
//       version: "1",
//       chainId: 111, // 主网络的 chainId
//       verifyingContract: "0x42fAd15b13EBc1126BE2318ad876cb8e5f4b1C3E" // 验证合约的地址
//   };

//   const entityType = [
//     { name: "from", type: "address" },
//     { name: "to", type: "address" },
//     { name: "value", type: "uint256" },
//     { name: "validAfter", type: "uint256" },
//     { name: "validBefore", type: "uint256" },
//     { name: "nonce", type: "bytes32" }
//   ];

//     // 构造transferWithAuthorizationFee函数的参数
//     const feeAccount = "0x2A049b90Ba0f5656F3bdcC50067A1E3470a4Be09"; // 替换为您的feeAccount地址
//     const from = "0x2A049b90Ba0f5656F3bdcC50067A1E3470a4Be09";
//     // const fromData = signer.address;
//     const to = "0xf896339ca453b561bfeec5b7afdb964668e421e3"; // 替换为您的目标地址
//     const value = "10000"; // 替换为您的转账数量
//     console.log("valueData:", value);
//     const validAfter = 1715495222;
//     const validBefore = 1715668022;
//     const nonce = 0x3000000000000000000000000000000000000000000000000000000000000000;
//     // const validAfter =ethers.BigNumber.from(1715495222);
//     // const validBefore = ethers.BigNumber.from(1715668022);
//     // const nonce = ethers.BigNumber.from(0);
//     // const validAfterData = Math.floor(Date.now() / 1000); // 当前时间戳，单位秒
//     // const validBeforeData = validAfter + 3600; // 有效期1小时
//     // const nonceData = ethers.utils.randomBytes(32);

//   const entityData = {
//     from: from,
//     to: to,
//     value: value,
//     validAfter: validAfter,
//     validBefore: validBefore,
//     nonce: nonce
//   };

//   const typedData = {
//       types: {
//           EIP712Domain: domainType,
//           TransferWithAuthorizationFee: entityType
//       },
//       domain: domainData,
//       primaryType: "TransferWithAuthorizationFee",
//       message: entityData
//   };

//   // 2. 创建要签名的数据对象
//   const signature = await ethers.provider.send("eth_signTypedData_v4", [signatory, JSON.stringify(typedData)]);
//   console.log("Signature:", signature);
// }

// // main();
// main()
//   .then(() => process.exit(0))
//   .catch((err) => {
//     console.error("Error:", err.message || err);
//     process.exit(1);
//   });
