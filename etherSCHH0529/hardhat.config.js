// require("@nomicfoundation/hardhat-toolbox");

// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   solidity: "0.8.24",
// };

require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require('@openzeppelin/hardhat-upgrades');
// require('@openzeppelin/defender-sdk-base-client');
// require("@nomiclabs/hardhat-solhint");
require("flatten");
require("dotenv").config();


// //私钥或助记词
// const GANACHE_PRIVATE_KEY = process.env.GANACHE_PRIVATE_KEY;

// //
// const LOCAL_PRIVATE_KEY = process.env.LOCAL_PRIVATE_KEY;

// const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY;

// const SEPOLIA_API_KEY = process.env.SEPOLIA_API_KEY;
// const SEPOLIA_PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY;

// const POLYGON_PRIVATE_KEY = process.env.POLYGON_PRIVATE_KEY;

module.exports = {
  solidity: {
    compilers: [
      // {
      //   version: "0.8.19",
      //   settings: {
      //     optimizer: {
      //       enabled: true,
      //       runs: 2000000,
      //     },
      //   },
      // },
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
    localPos: {
      url: "http://127.0.0.1:8545",
      accounts: [process.env.LOCAL_POS_PRIVATE_KEY],
      chainId: 32382,
    },
    L1Pos: {
      url: "http://114.67.196.139:8645",
      accounts: [process.env.LOCAL_POS_PRIVATE_KEY],
      chainId: 32382,
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
    },
    customChains: [
      {
        network: "custom",
        chainId: 1337,
        urls: {
          apiURL: "http://localhost:8545/api",
          browserURL: "http://localhost:8545"
        }
      }
    ]
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
