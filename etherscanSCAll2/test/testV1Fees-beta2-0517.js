require("dotenv").config();
const { ethers } = require("hardhat");

/**
 * 
 * 适用于beta环境签名 和校验签名
 * 
 */
async function main() {

    //使用账户
    // 公钥2：
    // 0x66448E069B7E548a499921038b2eC16Bc06884aA
    // 私钥2：
    // 11e97084c058aafb89d61144c42acaebe16b6a42ead3f05ba804b0902dcf7305

    // 公钥3-Account3：
    // 0x5F7D50Ffe0f73EcF8a4f8EFE7c4bE5caC6AD6c41
    // 私钥3：
    // 6e5dfe69f51d6b8c9c978b77c4a5bb808691f0fa5bbb545ebe7104e8d60d58ab

    // 指定账户的私钥
    // 0x66448E069B7E548a499921038b2eC16Bc06884aA
    const privateKey = "11e97084c058aafb89d61144c42acaebe16b6a42ead3f05ba804b0902dcf7305";
    const wallet = new ethers.Wallet(privateKey);
    const singer = wallet.address;
    //签名账户
    console.log("singer:",singer);

    //手续费账户
    const feeAccount = "0xf896339ca453b561bfeec5b7afdb964668e421e3";
// {"amount":232300,
// "from":"0x66448E069B7E548a499921038b2eC16Bc06884aA",
// "nonce":1,
// "orderId":"24051500620000000001035570",
// "signature":"0xb748ef9112b095a0c453fac2c035054e308d217fdb87810cfb739f28750d2a331a6815d26d1dff9df7a131ce42b79fd7a8c280efe82b8e711f7b8e834bfdf3281b",
// "validAfter":1715688326,
// "validBefore":1715861126}

//signature
//0xb748ef9112b095a0c453fac2c035054e308d217fdb87810cfb739f28750d2a331a6815d26d1dff9df7a131ce42b79fd7a8c280efe82b8e711f7b8e834bfdf3281b
    //签名参数配置
    const from = "0x66448E069B7E548a499921038b2eC16Bc06884aA";//720800_00 720700_00 //beta 72070000  72060000
    const to = "0xf896339ca453b561bfeec5b7afdb964668e421e3";//2183307_00 2183407_00 //beta 198340700 198350700
    const value = ethers.parseUnits("2323", 2);
    console.log("value::", value);


    const validAfter = 1715953314; //1715750848
    const validBefore = 1716212514; //1718429248 
    // const validAfter = 1715950595; //1715750848
    // const validBefore = 1716209795; //1718429248 
    // const validAfter = 1715688326;
    // const validBefore = 1715861126;

    const nonce = "0x0000000000000000000000000000000000000000000000000000000000000001";
    // const nonce = "0x0000000000000000000000000000000000000000000000000000000000000000";

    const orderId = "0x313131";

    //以下是EIP712签名部分
    const domain = {
        name: "jdscToken",
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


    const JDSCValidSignBeta = await ethers.getContractFactory("JDSCValidSignBeta");
    const jdscValidSignBeta = await JDSCValidSignBeta.deploy();
    // 0x5FbDB2315678afecb367f032d93F642f64180aa3
    console.log("签名验证合约地址 jdscValidSignBeta target:::", jdscValidSignBeta.target);
    const dd = jdscValidSignBeta.validSignature(
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
