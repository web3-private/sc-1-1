合约部署脚本

```shell
##compile
npx hardhat compile

##test
npx hardhat test   ./test/TokenUpgradeable.ts  --network <network-name>

##deploy
npx hardhat run scripts/deployToken.ts --network <network-name>

##verify
npx hardhat verify 0x.......... "params" --network <network-name>

##upgrade
npx hardhat run scripts/upgradeToken.ts --network <network-name>

```
