// const { ethers } = require("hardhat");
require("dotenv").config();
const { ethers } = require("hardhat");
// const { keccak256, defaultAbiCoder, toUtf8Bytes, solidityPack } = ethers.utils;

async function main() {

   // 冒充所有者地址
   await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: ["0xF896339CA453B561BfEec5b7Afdb964668E421e3"]
  });

  // 让签名者冒充所有者地址
  const ownerSigner = await ethers.getSigner("0xF896339CA453B561BfEec5b7Afdb964668E421e3");
  console.log("ownerSigner:::", ownerSigner.address);

  //0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    const [signer] = await ethers.getSigners();
    console.log("signer::", signer.address);
    const from = signer.address;
    const to = "0x2A049b90Ba0f5656F3bdcC50067A1E3470a4Be09"; // 替换为实际接收地址
    // const value = "10000"; // 替换为实际的金额
    const value = ethers.parseUnits("1000", 2); // 替换为实际的金额
    console.log("value::", value);
    // const value = ethers.utils.parseUnits("1.0", 18); // 替换为实际的金额
    // const validAfter = 0; // 或者使用实际的时间戳
    // const validBefore = Math.floor(Date.now() / 1000) + 3600; // 1小时后过期
    // const nonce = ethers.utils.hexlify(ethers.utils.randomBytes(32));

    const validAfter = 1715750848; //1715750848
    const validBefore = 1718429248; //1718429248 
    // const validAfter = 1715495222; //1715750848
    // const validBefore = 1715668022; //1718429248 
    console.log("ethers.nonce",ethers.nonce);
    console.log("signer.getNonce",signer.getNonce);

    const nonce = "0x0000000000000000000000000000000000000000000000000000000000000000";
    const domain = {
        name: "jdscToken",
        version: "1",
        chainId: 111, // 或者使用实际的链ID
        verifyingContract: "0x42fAd15b13EBc1126BE2318ad876cb8e5f4b1C3E" // 替换为你的合约地址
    };

    const types = {
        TransferWithAuthorization: [
            { name: "from", type: "address" },
            { name: "to", type: "address" },
            { name: "value", type: "uint256" },
            { name: "validAfter", type: "uint256" },
            { name: "validBefore", type: "uint256" },
            { name: "nonce", type: "bytes32" }
        ]
    };

    const message = {
        from,
        to,
        value,
        validAfter,
        validBefore,
        nonce
    };
    console.log("from       : ", from);
    console.log("to         : ", to);
    console.log("value      : ", value);
    console.log("validAfter : ", validAfter);
    console.log("validBefore: ", validBefore);
    console.log("nonce      : ", nonce);
    console.log("Signature11: ");
    const signature = await signer.signTypedData(domain, types, message);
    console.log("Signature:", signature);

    const sign = "0xc26f9e99e6d0dbab16d4f47141c318948a519a80944d5adc43a7d6c04be6e693547a9f2255b0da8d9b09d6f5cad88307fe1a49967f62377ba077779da64d99341c"; 

    // const [owner, addr1, addr2] = await ethers.getSigners();

    // const ValidSignature = await ethers.getContractFactory("ValidSignature");
    // const validSignature1 = await ValidSignature.deploy();
    // console.log("validSignature1:::",validSignature1.target);

    // const validSignature = await ethers.deployContract("ValidSignature");
    // await validSignature.waitForDeployment();
    // validSignature.

    const JDSCValidSign = await ethers.getContractFactory("JDSCValidSign");
    const jdscValidSign = await JDSCValidSign.deploy();
    //0x5FbDB2315678afecb367f032d93F642f64180aa3
    console.log("jdscValidSign1:::",jdscValidSign.target);
    const dd = jdscValidSign.validSignature(
      from,
      to,
      value,
      validAfter,
      validBefore,
      nonce,
      signature
    );

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
