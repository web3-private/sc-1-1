module.exports = {
  port: 1337,
  providerOpts: 
    { 
      gas: 0xfffffff,
      gasPrice: 0x01
    },
  mocha: {
    enableTimeouts: false,
    grep: /@gas|@no-cov/,
    invert: true
  },
  skipFiles: ['interfaces/TimeLock.sol'],
};
  