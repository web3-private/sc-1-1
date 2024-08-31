require("@nomicfoundation/hardhat-toolbox");

//私钥或助记词
const PRIVATE_KEY1 = "d64ceb39823733bb4f401176334a3b40d16f20b4a7f7e32ad06d204f9e0f636d";// 帐户 testAccount 0x3C850E996a41DdbA5426e8b555E9551F32725b0E
const PRIVATE_KEY2 = "0x58ecf9b3a9cb9984b252e793b6031c84c9ddb4fe3f9adad7a89910bcb626ef8d";
const PRIVATE_KEY3 = "";

//coinbase
const PRIVATE_KEY4 = "1d6b055f50ac57124e44d3fdb305ad988bd630207302beff938f6d77931765f0";

//助记词
const Mnemonic = "";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      // {
      //   version: "0.6.12",
      //   settings: {
      //     optimizer: {
      //       enabled: true,
      //       runs: 10000000,
      //     },
      //   },
      // },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 2000000,
          },
        },
      },
      {
        version: "0.8.1",
        settings: {
          optimizer: {
            enabled: true,
            runs: 2000000,
          },
        },
      },
    ]
  },

  networks: {
    local: {
      url: "http://114.67.196.139:9049",
      accounts: [PRIVATE_KEY4],
      chainId: 111,
    },
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: [PRIVATE_KEY2],
      chainId: 1337,
    },
    goerli: {
      url: "https://eth-goerli.api.onfinality.io/public",
      accounts: [],
      chainId: 5,
    },
    mumbai: {
      url: "https://endpoints.omniatech.io/v1/matic/mumbai/public",
      accounts: {
        mnemonic: Mnemonic,
      },
      chainId: 80001,
    },
  },
  etherscan: {
    apiKey: ""
  }
};
