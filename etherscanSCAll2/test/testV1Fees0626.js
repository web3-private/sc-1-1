require("dotenv").config();
const { ethers } = require("hardhat");

const { splitSignature }= require("@ethersproject/bytes");


async function main() {

    // 指定账户的私钥
    // 0x2d299a98A237bD8193256b018EdCCe2811C24Bc8
    const privateKey = "b156546961fdc9445d09c42ece2ed3518f452ddc1a57a918a18f27c9c835ef3a";
    const wallet = new ethers.Wallet(privateKey);
    const singer = wallet.address;
    //签名账户
    console.log("singer:",singer);

    //手续费账户
    const feeAccount = "0xf896339ca453b561bfeec5b7afdb964668e421e3";

    //签名参数配置
    const from = "0x2d299a98A237bD8193256b018EdCCe2811C24Bc8";
    const to = "0xf896339ca453b561bfeec5b7afdb964668e421e3";
    const value = ethers.parseUnits("100", 2);
    console.log("value::", value);



    console.log("valu222ether::",    ethers.parseEther("2000000"));
    //0x021e19e0c9bab2400000
    console.log("valu222ether hex::",    ethers.toBeHex(ethers.parseEther("10000")));
    //0x043c33c1937564800000
    console.log("valu222ether hex::",    ethers.toBeHex(ethers.parseEther("20000")));
    // ether 转换成16进制 0x043c33c1937564800000
    console.log("valu222ether hex::",    ethers.toBeHex(ethers.parseUnits("20000", 18)));
    //0x01a784379d99db42000000
    console.log("valu222ether hex::",    ethers.toBeHex(ethers.parseEther("2000000")));
    // ether 转换成16进制
    //0x01a784379d99db42000000
    console.log("valu222ether hex::",    ethers.toBeHex(ethers.parseUnits("2000000", 18)));
    //0x01a784379d99db42000000
    console.log("valu222ether9999  hex::",    ethers.toBeHex(ethers.parseUnits("99999999999", 18)));
    console.log("valu222e::", ethers.parseUnits("100", 18));

    const validAfter = 1715750848;
    const validBefore = 1718429248;

    const nonce = "0x0000000000000000000000000000000000000000000000000000000000000000";

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


    console.log("domain      : ", domain);
    console.log("types      : ", types);
    console.log("message      : ", message);

    const signature = await wallet.signTypedData(domain, types, message);
    console.log("eip712 data signature:", signature);

    // 使用 splitSignature 提取 v, r, s
    const { v, r, s } = splitSignature(signature);
    console.log("v:", v);
    console.log("r:", r);
    console.log("s:", s);


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
    console.log("             ");
    console.log("all data   : ", feeAccount +","+ from +","+ to +","+ value +","+ validAfter +","+ validBefore +","+ nonce +","+ signature +","+ orderId);
    console.log("             ");
    console.log("data end   : ");
    console.log("             ");


    const JDSCValidSign = await ethers.getContractFactory("JDSCValidSign");
    const jdscValidSign = await JDSCValidSign.deploy();
    //0x5FbDB2315678afecb367f032d93F642f64180aa3
    console.log("签名验证合约地址 jdscValidSign1 target:::",jdscValidSign.target);
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
