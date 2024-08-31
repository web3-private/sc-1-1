import * as dotenv from "dotenv";
import { ethers, upgrades, network } from "hardhat";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { splitSignature } from "@ethersproject/bytes";

async function main() {
  // 冒充所有者地址
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: ["0xF896339CA453B561BfEec5b7Afdb964668E421e3"],
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
  const owner = signer.address;
  const spender = "0xf896339ca453b561bfeec5b7afdb964668e421e3";
  const value = ethers.parseUnits("1000", 2);
  console.log("value::", value);

  // const validAfter = 1715750848; //1715750848
  // const validBefore = 1718429248; //1718429248
  const deadline = 1718429248; //1718429248

  console.log("signer.getNonce", signer.getNonce);

  const nonce = "0x0000000000000000000000000000000000000000000000000000000000000000";
  const domain = {
    name: "jdscToken",
    version: "1",
    chainId: 111, // 或者使用实际的链ID
    verifyingContract: "0x42fAd15b13EBc1126BE2318ad876cb8e5f4b1C3E", // 替换为你的合约地址
  };

  const types = {
    TransferPermit: [
      { name: "owner", type: "address" },
      { name: "spender", type: "address" },
      { name: "value", type: "uint256" },
      { name: "nonce", type: "bytes32" },
      { name: "deadline", type: "uint256" },
    ],
  };

  const message = {
    owner,
    spender,
    value,
    nonce,
    deadline,
  };
  console.log("owner      : ", owner);
  console.log("spender    : ", spender);
  console.log("value      : ", value);
  console.log("nonce      : ", nonce);
  console.log("deadline   : ", deadline);
  console.log("Signature11: ");
  const signature = await signer.signTypedData(domain, types, message);
  console.log("Signature:", signature);

  const signature1 = await wallet.signTypedData(domain, types, message);
  console.log("Signature111:", signature1);
  // 使用 splitSignature 提取 v, r, s
  const { v, r, s } = splitSignature(signature);
  console.log("v:", v);
  console.log("r:", r);
  console.log("s:", s);

  const sign =
    "0xc26f9e99e6d0dbab16d4f47141c318948a519a80944d5adc43a7d6c04be6e693547a9f2255b0da8d9b09d6f5cad88307fe1a49967f62377ba077779da64d99341c";

  const TokenValidSign = await ethers.getContractFactory("TokenValidSign");
  const tokenValidSign = await TokenValidSign.deploy();
  //0x5FbDB2315678afecb367f032d93F642f64180aa3
  console.log("tokenValidSign:::", tokenValidSign.target);
  const dd = tokenValidSign.validSignature(owner, spender, value, nonce, deadline, signature);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
