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
    // 0xdFd8fB01d9141c7fAA253Afe81133C6996531Ea7
    const privateKey = "0xb8718c91d6cd82de00b2d3884193275237deb140166a582541adbb6036b8b658";
    const wallet = new ethers.Wallet(privateKey);
    const singer = wallet.address;
    //签名账户
    console.log("singer:",singer);

    //手续费账户
    //0x16075b060cd0730386b4e1aa90b9e9eca6c2df0f61cf57b393e921ca94b78971
    const feeAccount = "0x3aF22348dA61b334CAaD8dc4Ed6395F2df95848c";

    //signature
    //签名参数配置
    const from = "0xbD8b976650e9A799B0ffE3666E2970F80a9a962f";
    const to = "0x3aF22348dA61b334CAaD8dc4Ed6395F2df95848c";
    const value = ethers.parseUnits("120", 2);
    console.log("value::", value);


    const validAfter = 1715953314; //1715750848
    const validBefore = 1716212514; //1718429248 
    // const validAfter = 1715950595; //1715750848
    // const validBefore = 1716209795; //1718429248 

    // const nonce = "0x0000000000000000000000000000000000000000000000000000000000000001";
    const nonce = "0x0000000000000000000000000000000000000000000000000000000000000000";

    const orderId = "0x313131";

    //以下是EIP712签名部分
    const domain = {
        name: "jdscToken",
        version: "1",
        chainId: 1337,
        // beta 环境代理合约地址： 0x03865440e46916E1806B1990DBDe6e160f90abD0
        verifyingContract: "0x03865440e46916E1806B1990DBDe6e160f90abD0"
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


    const JDSCValidSignGanache = await ethers.getContractFactory("JDSCValidSignGanache");
    const jdscValidSignGanache = await JDSCValidSignGanache.deploy();
    // 0x5FbDB2315678afecb367f032d93F642f64180aa3
    console.log("签名验证合约地址 jdscValidSignGanache target:::", jdscValidSignGanache.target);
    const dd = jdscValidSignGanache.validSignature(
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
