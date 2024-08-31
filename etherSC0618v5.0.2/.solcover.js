module.exports = {
    providerOptions: {
        // gasLimit: 300000, // 设置适当的 gas limit
        gasLimit: 30000000, // 设置适当的 gas limit
        // gasLimit: 3000000000000, // 设置适当的 gas limit
        // hardfork: 'istanbul',
        // gas: 3000000,
        // blockGasLimit: 30000000,
        // defaultBalanceEther: 100000000, // 设置更高的初始余额
        // skipFiles: ['interfaces/TimeLock.sol']
    },
    skipFiles: ['interfaces/TimeLock.sol' , "./interfaces/TokenErrors.sol"],
    // modifierWhitelist: [notWhitelisted]
    // modifierWhitelist: [onlyOwner]
    // skipFiles: ['Migrations.sol'], // 如果有需要跳过的文件
  };
  

// const {execSync} = require('child_process');
// async function moveCoverage(config) {
//   execSync('mv ./.coverage_artifacts/contracts ./networks/coverage-contracts');
// }

// async function moveCoverageBack() {
//   execSync('mv ./networks/coverage-contracts ./.coverage_artifacts/contracts');
// }

// module.exports = {
//   port: 1337,
//   providerOpts: 
//     { // See example coverage settings at https://github.com/sc-forks/solidity-coverage
//       gas: 0xfffffff,
//       gasPrice: 0x01
//     },
//   mocha: {
//     enableTimeouts: false,
//     grep: /@gas|@no-cov/,
//     invert: true
//   },
//   onCompileComplete: moveCoverage,
//   onTestsComplete: moveCoverageBack,
//   skipFiles: ['test'].concat(
//     process.env['SKIP_UNITROLLER'] ? ['Unitroller.sol'] : []),
// };
