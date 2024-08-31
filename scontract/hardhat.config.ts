import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter";
import "@openzeppelin/hardhat-upgrades";

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
          },
          evmVersion: "cancun"
        },
      },
    ]
  },
  defaultNetwork: "local",
  networks: {
    hardhat: {
      blockGasLimit: 30000000_000_000,
      gas: 3000000_000,
      gasPrice: 20e9,
      initialBaseFeePerGas: 0,
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
    polygonLocal: {
      url: "http://114.67.171.8:34961",
      accounts: [getEnvVar('POLYGON_PRIVATE_KEY')],
      chainId: 271828,
    },
    sepolia: {
      // url: "https://sepolia.infura.io/v3/23391cfbe581424fb963f2206611f974",
      url: "https://sepolia.infura.io/v3/" + getEnvVar('INFURA_SEPOLIA_PROJECT_ID'),
      accounts: [getEnvVar('ETHEREUM_SEPOLIA_PRIVATE_KEY')],
      chainId: 11155111,
    },
    mainnet: {
      url: "https://mainnet.infura.io/v3/" + getEnvVar('INFURA_MAINNET_PROJECT_ID'),
      accounts: [getEnvVar('ETHEREUM_MAINNET_PRIVATE_KEY')],
      chainId: 1,
    },
  },
  etherscan: {
    apiKey: {
      "mainnet" : getEnvVar('ETHERSCAN_API_KEY'),
      "sepolia" : getEnvVar('ETHERSCAN_API_KEY'),
      "L1Pos" : getEnvVar('ETHERSCAN_API_KEY')
    },
    customChains: [
      {
        network: "L1Pos",
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
    // reportFormat: "markdown",
    // outputFile: "gasReport.md",
    // enabled: (process.env.REPORT_GAS) ? true : false,
    token: "ETH",
    currency: 'JDSC',
    // offline: true,
    coinmarketcap: "abc123...",
  },
  sourcify: {
    enabled: true
  }
};

export default config;
