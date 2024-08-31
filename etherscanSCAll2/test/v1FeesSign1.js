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

//   //0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    const [signer] = await ethers.getSigners();

    // 指定账户的私钥
    const privateKey = "bb4f4a6a898a88b9f7b3be78508fb557219bf5c75a6679ea8d0621d027729a1d";
    // 使用指定私钥创建一个 Wallet 对象
    const wallet = new ethers.Wallet(privateKey);

    console.log("signer::", signer.address);
    // const from = "0x2A049b90Ba0f5656F3bdcC50067A1E3470a4Be09";
    const from = signer.address;
    const to = "0xf896339ca453b561bfeec5b7afdb964668e421e3";
    const value = ethers.parseUnits("1000", 2);
    console.log("value::", value);

    const validAfter = 1715750848; //1715750848
    const validBefore = 1718429248; //1718429248 
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

    const signature1 = await wallet.signTypedData(domain, types, message);
    //0x9bfd745c612d3bf2e1b3d92a3d26a8c0ce85e24529c6a47fee48d954aa8758cf215b33d7265531eba17aa01aab4853493ccd33b01c466b7e5b4b3610ad4bb93f1c
    console.log("Signature111:", signature1);

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
