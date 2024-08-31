require("dotenv").config();
const { ethers } = require("hardhat");

/**
 * 
 * 适用于beta环境签名 和校验签名
 * 
 */
async function main() {
    // 指定账户的私钥
    // 0x2A049b90Ba0f5656F3bdcC50067A1E3470a4Be09
    const privateKey = "dbd45e0af888861250a6d67a44bd78a1548828bb10a72fad7ca3cf69c3910171";
    const wallet = new ethers.Wallet(privateKey);
    const singer = wallet.address;
    //签名账户
    console.log("singer:",singer);

    //手续费账户
    const feeAccount = "0xf896339ca453b561bfeec5b7afdb964668e421e3";

    //signature
    //签名参数配置
    const from = "0x2A049b90Ba0f5656F3bdcC50067A1E3470a4Be09";
    const to = "0xf896339ca453b561bfeec5b7afdb964668e421e3";
    // const value = 5432100;
    const value = ethers.parseUnits("1000", 2);
    console.log("value::", value);


    const validAfter = 1716292808; //1715750848
    const validBefore = 1717156808; //1718429248 
    // const validAfter = 1716189978; //1715750848
    // const validBefore = 1716690138; //1718429248

    const nonce = ethers.zeroPadValue(ethers.toBeHex(0), 32);
    console.log("nonce::", nonce);
    // const nonce = "0x0000000000000000000000000000000000000000000000000000000000000001";
    // const nonce = "0x0000000000000000000000000000000000000000000000000000000000000000";

    const orderId = ethers.encodeBytes32String("24052100620000000001037522");
    // const orderId = "0x313131";
    console.log("orderId::", orderId);

    //以下是EIP712签名部分
    const domain = {
        name: "jdscToken",
        version: "1",
        chainId: 111,
        // beta 环境代理合约地址： 0x1Fdc41D89dca6dB5F576D52235F01f66198d3DE1
        verifyingContract: "0x1Fdc41D89dca6dB5F576D52235F01f66198d3DE1"
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

    const signature = await wallet.signTypedData(domain, types, message);
    console.log("eip712 data signature:", signature);

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


    const JDSCValidSignBeta0521 = await ethers.getContractFactory("JDSCValidSignBeta0521");
    const jdscValidSignBeta0521 = await JDSCValidSignBeta0521.deploy();
    // 0x5FbDB2315678afecb367f032d93F642f64180aa3
    console.log("签名验证合约地址 jdscValidSignBeta0521 target:::", jdscValidSignBeta0521.target);
    const dd = jdscValidSignBeta0521.validSignature(
      from,
      to,
      value,
      validAfter,
      validBefore,
      nonce,
      signature
    );

    const domain_separator = await jdscValidSignBeta0521._DEPRECATED_CACHED_DOMAIN_SEPARATOR();

    //beta env : 0x1354811732a61db05e40b18f4895bc28a85733a9571c802bd9791a7539d5d45e

    //jdscToken
    //0x1354811732a61db05e40b18f4895bc28a85733a9571c802bd9791a7539d5d45e
    console.log("domain_separator:", domain_separator);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
