require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require("dotenv").config();

//私钥或助记词
const PRIVATE_KEY1 = process.env.PRIVATE_KEY1;
const PRIVATE_KEY2 = process.env.PRIVATE_KEY2;

//coinbase
const PRIVATE_KEY3 = process.env.PRIVATE_KEY3;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
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
      accounts: [PRIVATE_KEY3],
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
    // mumbai: {
    //   url: "https://endpoints.omniatech.io/v1/matic/mumbai/public",
    //   accounts: {
    //     mnemonic: Mnemonic,
    //   },
    //   chainId: 80001,
    // },
  },
  etherscan: {
    apiKey: ""
  },
  gasReporter: {
    enabled: true,
    // offline: true,
    currency: 'jdsc',
    currencyDisplayPrecision: "2",
    // L1: "etl",
    coinmarketcap: "abc123...",
  }
};
