import type { HardhatUserConfig } from "hardhat/config";
// import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter";

import "@openzeppelin/hardhat-upgrades";
import "@nomicfoundation/hardhat-verify";
// import "@nomiclabs/hardhat-ethers";
import "@typechain/hardhat";

import "flatten";
import "dotenv/config";

function getEnvVar(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Environment variable ${name} is not set`);
  }
  return value;
}


const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.26",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
            // runs: 2000000
          },
          evmVersion: "cancun"
        },
      },
    ]
  },
  paths: {
    sources: "./contracts",
  },
  defaultNetwork: "local",
  networks: {
    hardhat: {
      blockGasLimit: 30000000_000_000, // 设置区块的 gas limit
      gas: 3000000_000, // 设置交易的 gas limit
      gasPrice: 20e9, // 设置 gas price
      initialBaseFeePerGas: 0, // 防止 EIP-1559 相关的费用问题
      allowUnlimitedContractSize: true,
      // allowUnlimitedContractSize: false,
      accounts: {
        count: 20,
        accountsBalance: "100000000000000000000000000", // 设置账户初始余额（比之前更高）
      },
    },
    local: {
      url: "http://114.67.196.139:9049",
      accounts: [getEnvVar('LOCAL_PRIVATE_KEY')],
      chainId: 111,
    },
    localPos: {
      allowUnlimitedContractSize: true,
      url: "http://127.0.0.1:8645",
      accounts: [getEnvVar('LOCAL_POS_PRIVATE_KEY')],
      chainId: 1337,
    },
    L1Pos: {
      url: "http://114.67.196.139:8645",
      accounts: [getEnvVar('LOCAL_POS_PRIVATE_KEY')],
      chainId: 1337,
    },
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: [getEnvVar('GANACHE_PRIVATE_KEY')],
      chainId: 1337,
    },
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/PIia0lqC0aI1GAvfiDzb3H7xiz8b1QRn",
      accounts: [getEnvVar('SEPOLIA_PRIVATE_KEY')],
      chainId: 11155111,
    },
    polygonLocal: {
      url: "http://114.67.171.8:34961",
      accounts: [getEnvVar('POLYGON_PRIVATE_KEY')],
      chainId: 271828,
    },
  },
  etherscan: {
    // apiKey: getEnvVar('ETHERSCAN_API_KEY'),
    apiKey: {
      mainnet: getEnvVar('ETHERSCAN_API_KEY'),
      sepolia: getEnvVar('ETHERSCAN_API_KEY'),
      zksyncera: getEnvVar('ETHERSCAN_API_KEY')

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
    // outputFile: "gas-reporter.txt",
    reportFormat: "markdown",
    outputFile: "gas-reporter.md",
    // enabled: (process.env.REPORT_GAS) ? true : false,
    token: "ETH",
    gasPrice: 0x7,
    // gasPriceApi: "",
    currency: 'JDSC',
    currencyDisplayPrecision: 0x2,
    offline: true,
    // L1: "polygon",
    coinmarketcap: "abc123...",
    blobBaseFee: 0x7,
    // blobBaseFeeApi: ""
    // showTimeSpent: true
  },
  sourcify: {
    enabled: true,
    // Optional: specify a different Sourcify server
    apiUrl: "https://sourcify.dev/server",
    // Optional: specify a different Sourcify repository
    browserUrl: "https://repo.sourcify.dev",
  }
};

export default config;
