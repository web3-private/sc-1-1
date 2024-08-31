require("dotenv").config();
const { ethers, upgrades } = require("hardhat");

async function main() {

  // //initialize param
  // const tokenName = process.env.tokenName
  // const tokenSymbol = process.env.tokenSymbol
  // const tokenCurrency = process.env.tokenCurrency
  // const tokenDecimals = process.env.tokenDecimals
  // const tokenSupply = process.env.tokenSupply
  // const newMasterMinter = process.env.newMasterMinter
  // const newPauser = process.env.newPauser
  // const newBlacklister = process.env.newBlacklister
  // const newOwner = process.env.newOwner


  // const deployer = new ethers.Wallet(process.env.adminPk, ethers.provider);
  // const initializer = new ethers.Wallet(process.env.initializerPk, ethers.provider);
  // const owner = new ethers.Wallet(process.env.ownerPk, ethers.provider);



  // Deploying
  const TokenUpgradeable = await ethers.getContractFactory("TokenUpgradeable");

  console.log("正在部署 TokenUpgradeable...");

  console.log("upgrades:::", upgrades);
  const instance = await upgrades.deployProxy(TokenUpgradeable,["jdscToken","jdsc"]);
  await instance.deployed();
  console.log("TokenUpgradeable 部署在:", token.address);
  console.log("TokenUpgradeable address:", instance.address);


  // // Upgrading
  // const WorldCupV2 = await ethers.getContractFactory("WorldCupV2");
  // const upgraded = await upgrades.upgradeProxy(instance.address, WorldCupV2);
  // console.log("WorldCupV2 address:", upgraded.address);

  // await upgraded.changeDeadline(deadline + 100)
  // console.log("deadline2:", await upgraded.deadline())

  // //lib
  // const SignatureChecker = await ethers.getContractFactory("SignatureChecker");
  // const signatureChecker = await SignatureChecker.connect(deployer).deploy();
  // console.log("signatureChecker address:", signatureChecker.target);

  // //impl contract
  // const JDSCTokenV1_3WithFees = await ethers.getContractFactory("JDSCTokenV1_3WithFees", {
  //   libraries: {
  //     SignatureChecker: signatureChecker.target,
  //   }
  // });

  // // const JDSCTokenV1_3WithFees = await ethers.getContractFactory("JDSCTokenV1_3WithFees");
  // const jdscTokenV1_3WithFees = await JDSCTokenV1_3WithFees.connect(deployer).deploy();
  // console.log("jdscTokenV1_3WithFees address:", jdscTokenV1_3WithFees.target);

  // //proxy contract
  // const JDSCTokenProxy = await ethers.getContractFactory("JDSCTokenProxy");
  // const jdscTokenProxy = await JDSCTokenProxy.connect(deployer).deploy(jdscTokenV1_3WithFees.target);
  // console.log("jdscTokenProxy address:", jdscTokenProxy.target);

  // await jdscTokenProxy.deploymentTransaction().wait();
  // // const impl = await jdscTokenProxy.implementation();
  // // console.log("proxyContract:::", impl);

  // const proxyContract = await ethers.getContractAt("JDSCTokenV1_3WithFees", jdscTokenProxy.target, initializer);

  // // const proxyContract = new ethers.Contract(jdscTokenProxy.target, jdscTokenV1_3WithFees.interface, initializer);

  // //initialize
  // const initTx = await proxyContract.connect(initializer).initialize(
  //   tokenName,
  //   tokenSymbol,
  //   tokenCurrency,
  //   tokenDecimals,
  //   ethers.parseUnits(tokenSupply, 2),
  //   newMasterMinter,
  //   newPauser,
  //   newBlacklister,
  //   newOwner
  // );

  // await initTx.wait();
  // console.log("initializer TxHash: ", initTx.hash);

  // const list = process.env.accountsToBlacklist.split(",");
  // console.log("elements process.env.accountsToBlacklist:", list);
  // const initWithFeeTx = await proxyContract.connect(initializer).initializeV1WithFee(list ,newOwner);

  // console.log("initializeV1WithFee TxHash: ", initWithFeeTx.hash);
  // console.log("  ");


  // //owner call
  // const ownerProxyContract = await ethers.getContractAt("JDSCTokenV1_3WithFees", jdscTokenProxy.target, owner);
  // // const ownerProxyContract = JDSCTokenV1_3WithFees.attach(jdscTokenProxy.target);

  // //setParams
  // console.log("setParams newBasisPoints:", process.env.newBasisPoints);
  // console.log("setParams newMaxFee:", process.env.newMaxFee);
  // const setParamsTx = await ownerProxyContract.connect(owner).setParams(process.env.newBasisPoints, process.env.newMaxFee);  
  // await setParamsTx.wait();

  // console.log("setParams TxHash: ", setParamsTx.hash);
  // console.log("  ");

  // //setAccountBasisPointsRate
  // console.log("setAccountBasisPointsRate newBasisPoints:", process.env.account);
  // console.log("setAccountBasisPointsRate newMaxFee:", process.env.accountBasisPoints);
  // const setAccountBasisPointsRateTx = await ownerProxyContract.connect(owner).setAccountBasisPointsRate(process.env.account, process.env.accountBasisPoints);
  // await setAccountBasisPointsRateTx.wait();
  // console.log("setAccountBasisPointsRate TxHash: ", setAccountBasisPointsRateTx.hash);
  // console.log("  ");


  // //updateWhitelister
  // console.log("updateWhitelister newWhitelister:", process.env.newWhitelister);
  // const updateWhitelisterTx = await ownerProxyContract.connect(owner).updateWhitelister(process.env.newWhitelister);
  // await updateWhitelisterTx.wait();
  // console.log("updateWhitelister TxHash: ", updateWhitelisterTx.hash);
  // console.log("  ");

}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Error:", err.message || err);
    process.exit(1);
  });
