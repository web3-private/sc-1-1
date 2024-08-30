require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require('@openzeppelin/hardhat-upgrades');
// require("@nomiclabs/hardhat-solhint");
require("flatten");
require("dotenv").config();

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 2000000,
          },
        },
      },
      {
        version: "0.8.24",
        settings: {
          optimizer: {
            enabled: true,
            runs: 2000000
          },
          // evmVersion: "cancun"
        },
      },
    ]
  },
  
  networks: {
    local: {
      url: "http://114.67.196.139:9049",
      accounts: [process.env.LOCAL_PRIVATE_KEY],
      chainId: 111,
    },
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: [process.env.GANACHE_PRIVATE_KEY],
      chainId: 1337,
    },
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/PIia0lqC0aI1GAvfiDzb3H7xiz8b1QRn",
      accounts: [process.env.SEPOLIA_PRIVATE_KEY],
      chainId: 11155111,
    },
    polygonLocal: {
      url: "http://114.67.171.8:34961",
      accounts: [process.env.POLYGON_PRIVATE_KEY],
      chainId: 271828,
    },
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY
    }
  },
  gasReporter: {
    enabled: true,
    // enabled: (process.env.REPORT_GAS) ? true : false,
    currency: 'JDSC',
    // L1: "polygon",
    coinmarketcap: "abc123...",
  },
  sourcify: {
    enabled: true
  }
};
