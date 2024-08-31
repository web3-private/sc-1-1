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
//   const Fork = await ethers.getContractFactory("Fork");
//   const fork = await Fork.attach(contractAddress);

  // // 使用所有者签名者连接到已部署的合约
  // const connectedContract = fork.connect(ownerSigner);


//   //0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    const [signer] = await ethers.getSigners();

    // // 指定账户的私钥
    // const privateKey = "bb4f4a6a898a88b9f7b3be78508fb557219bf5c75a6679ea8d0621d027729a1d";// 0xf896339ca453b561bfeec5b7afdb964668e421e3
    // // 使用指定私钥创建一个 Wallet 对象
    // const wallet = new ethers.Wallet(privateKey);


    // 指定账户的私钥
    const privateKey = "b156546961fdc9445d09c42ece2ed3518f452ddc1a57a918a18f27c9c835ef3a";// 0x2d299a98A237bD8193256b018EdCCe2811C24Bc8
    // 使用指定私钥创建一个 Wallet 对象
    const wallet = new ethers.Wallet(privateKey);
    const DDD = wallet.address;
    //签名账户
    console.log("DDD:",DDD);

    //手续费账户
    const feeAccount = "0xf896339ca453b561bfeec5b7afdb964668e421e3";

    const from = "0x2d299a98A237bD8193256b018EdCCe2811C24Bc8";
    // console.log("signer::", signer.address);
    // const from = signer.address;
    const to = "0xf896339ca453b561bfeec5b7afdb964668e421e3";
    const value = ethers.parseUnits("100", 2);
    console.log("value::", value);

    //1715941126
    const validAfter = 1715941126; //1715750848
    const validBefore = 1716200326; //1718429248 
    // const validAfter = 1716199216; //1715750848
    // const validBefore = 1716199580; //1718429248 
    console.log("ethers.nonce",ethers.nonce);
    console.log("signer.getNonce",signer.getNonce);

    const nonce = "0x0000000000000000000000000000000000000000000000000000000000000000";
    // const nonce = "0x0000000000000000000000000000000000000000000000000000000000000000";

    const orderId = "0x313131";

    //以下是EIP712签名部分
    const domain = {
        name: "jdscToken",
        version: "1",
        chainId: 111,
        verifyingContract: "0x42fAd15b13EBc1126BE2318ad876cb8e5f4b1C3E"
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


    console.log("             ");
    console.log("data start : ");
    console.log("feeAccount : ", feeAccount);
    console.log("from       : ", from);
    console.log("to         : ", to);
    console.log("value      : ", value);
    console.log("validAfter : ", validAfter);
    console.log("validBefore: ", validBefore);
    console.log("nonce      : ", nonce);
    console.log("orderId    :", orderId);

    console.log("all data   : ", feeAccount +","+ from +","+ to +","+ value +","+ validAfter +","+ validBefore +","+ nonce +","+ orderId);
    console.log("data end   : ");
    console.log("             ");


    // const signature = await signer.signTypedData(domain, types, message);
    // console.log("Signature:", signature);


    //
    // 0x2d299a98A237bD8193256b018EdCCe2811C24Bc8,0xf896339ca453b561bfeec5b7afdb964668e421e3,10000,1715750848,1718429248,0x0000000000000000000000000000000000000000000000000000000000000000,0x09627384d8662340e08ee5ca2a120e4724dcc21e9be9a744abbc7f4afff5630d4db3ad6bb3c8363bbbe9186eb35846aeccb586b8a3480b876df635e7031b191b1c

    // 0xF896339CA453B561BfEec5b7Afdb964668E421e3,0x2d299a98A237bD8193256b018EdCCe2811C24Bc8,0xf896339ca453b561bfeec5b7afdb964668e421e3,10000,1715750848,1718429248,0x0000000000000000000000000000000000000000000000000000000000000000,0x09627384d8662340e08ee5ca2a120e4724dcc21e9be9a744abbc7f4afff5630d4db3ad6bb3c8363bbbe9186eb35846aeccb586b8a3480b876df635e7031b191b1c,0x313131

    const signature = await wallet.signTypedData(domain, types, message);
    //0x09627384d8662340e08ee5ca2a120e4724dcc21e9be9a744abbc7f4afff5630d4db3ad6bb3c8363bbbe9186eb35846aeccb586b8a3480b876df635e7031b191b1c
    console.log("Signature111:", signature);


    console.log("Signature11: ");
    const sign = "0x09627384d8662340e08ee5ca2a120e4724dcc21e9be9a744abbc7f4afff5630d4db3ad6bb3c8363bbbe9186eb35846aeccb586b8a3480b876df635e7031b191b1c"; 


    console.log("Contains all the data for the signature");
    console.log("             ");
    console.log("data start : ");
    console.log("feeAccount : ", feeAccount);
    console.log("from       : ", from);
    console.log("to         : ", to);
    console.log("value      : ", value);
    console.log("validAfter : ", validAfter);
    console.log("validBefore: ", validBefore);
    console.log("nonce      : ", nonce);
    console.log("signature  : ", signature);
    console.log("orderId    :", orderId);


    console.log("all data   : ", feeAccount +","+ from +","+ to +","+ value +","+ validAfter +","+ validBefore +","+ nonce +","+ signature +","+ orderId);
    console.log("data end   : ");
    console.log("             ");


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

    console.log("dd:{}", dd);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
