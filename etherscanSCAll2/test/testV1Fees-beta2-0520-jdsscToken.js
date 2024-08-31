require("dotenv").config();
const { ethers } = require("hardhat");

/**
 * 
 * 适用于beta环境签名 和校验签名
 * 
 */
async function main() {
    // 指定账户的私钥
    // 0x30eaEf6b580ed64718Ddc094BDc23212D9cc8A47
    const privateKey = "910a5c76932b5d3293f18f8bb8a3feddbaf92ee51960c292ee815c548e6e041c";
    const wallet = new ethers.Wallet(privateKey);
    const singer = wallet.address;
    //签名账户
    console.log("singer:",singer);

    //手续费账户
    const feeAccount = "0xf896339ca453b561bfeec5b7afdb964668e421e3";

    //signature
    //签名参数配置
    const from = "0x30eaEf6b580ed64718Ddc094BDc23212D9cc8A47";
    const to = "0xf896339ca453b561bfeec5b7afdb964668e421e3";
    const value = ethers.parseUnits("2323", 2);
    console.log("value::", value);


    const validAfter = 1716171978; //1715750848
    const validBefore = 1716690138; //1718429248 
    // const validAfter = 1715864375; //1715750848
    // const validBefore = 1716209975; //1718429248 
    // const validAfter = 1715950595; //1715750848
    // const validBefore = 1716209795; //1718429248 

    const nonce = "0x0000000000000000000000000000000000000000000000000000000000000001";
    // const nonce = "0x0000000000000000000000000000000000000000000000000000000000000000";

    const orderId = "0x313131";

    //以下是EIP712签名部分
    const domain = {
        name: "jdsscToken",
        // name: "jdscToken",
        version: "1",
        chainId: 111,
        // beta 环境代理合约地址： 0x04966562CB4d768Ea08907e39670c0c2172938e2
        verifyingContract: "0x04966562CB4d768Ea08907e39670c0c2172938e2"
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


    const JDSCValidSignBetaJdsscToken = await ethers.getContractFactory("JDSCValidSignBetaJdsscToken");
    const jdscValidSignBetaJdsscToken = await JDSCValidSignBetaJdsscToken.deploy();
    // 0x5FbDB2315678afecb367f032d93F642f64180aa3
    console.log("签名验证合约地址 jdscValidSignBetaJdsscToken target:::", jdscValidSignBetaJdsscToken.target);
    const dd = jdscValidSignBetaJdsscToken.validSignature(
      from,
      to,
      value,
      validAfter,
      validBefore,
      nonce,
      signature
    );

    const domain_separator = await jdscValidSignBetaJdsscToken._DEPRECATED_CACHED_DOMAIN_SEPARATOR();
    //jdsscToken
    //0x392170ebacb62ef3068dc581ad5ee547a89c3ad68a02054d6da82b6df13411f8

    //jdscToken
    //0xbbb0bfc5f82c19ebee687d842e857628e2efefd4bc1a2d398cceeb65bb6f1e2b
    console.log("domain_separator:", domain_separator);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
