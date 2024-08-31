import type { HardhatUserConfig } from "hardhat/config";
// import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter";
import "@openzeppelin/hardhat-upgrades";
import "@nomicfoundation/hardhat-foundry";
import "flatten";
import "dotenv/config";

import "./scripts/flattenAll";

function getEnvVar(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Environment variable ${name} is not set`);
  }
  return value;
}


const config: HardhatUserConfig = {
  // solidity: "0.8.24",
  solidity: {
    compilers: [
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
  defaultNetwork: "hardhat",
  // defaultNetwork: "local",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
    },
    local: {
      url: "http://114.67.196.139:9049",
      accounts: [getEnvVar('LOCAL_PRIVATE_KEY')],
      chainId: 111,
    },
    L1Pos: {
      url: "http://114.67.196.139:8645",
      accounts: [getEnvVar('LOCAL_POS_PRIVATE_KEY')],
      chainId: 32382,
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
    apiKey: getEnvVar('ETHERSCAN_API_KEY'),
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
    // enabled: (process.env.REPORT_GAS) ? true : false,
    currency: 'ETH',
    // currency: 'JDSC',
    // offline: false,
    // offline: true,
    // L1: "polygon",
    coinmarketcap: "cc037b37-bff0-4aef-8bf6-933f7913f3d3",
  },
  sourcify: {
    enabled: true
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
};

export default config;
