import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, TypedDataDomain, BigNumberish, Signer, Provider } from "ethers";
import { splitSignature } from "@ethersproject/bytes";

export async function mintUtil(
  instance: Contract,
  // owner: Signer,
  // provider: Provider,
  admin: Signer,
  otherAccount: Signer,
  // feeAccount: Signer,
  // whitelistManager: Signer,
  // masterminter: Signer,
  // feemanager: Signer,
  minter1: Signer,
  // feehold1: Signer,
  //   ): Promise<[BigInt, BigInt, Number, Number, String, String]> {
) {
  //setup master minter, onlyOwner
  await instance.updateMasterMinter(admin);

  // Connect admin to the instance
  const adminInstance = instance.connect(admin) as Contract;

  //setup minter, onlyMasterMinter MINTER_ROLE
  await adminInstance.addMinter(await minter1.getAddress(), 21_000_000);

  //approveMint
  await adminInstance.approveMint(await minter1.getAddress(), 21_000_000);

  // Connect minter1 to the instance
  const minterInstance = adminInstance.connect(minter1) as Contract;

  //   const beforeTotalSupply = await instance.totalSupply();

  //mint, MINTER_ROLE
  await minterInstance.mint(await otherAccount.getAddress(), 21_000_000);
}

export async function transferUtil(
  instance: Contract,
  // owner: Signer,
  // provider: Provider,
  admin: Signer,
  otherAccount: Signer,
  // feeAccount: Signer,
  // whitelistManager: Signer,
  masterminter: Signer,
  feemanager: Signer,
  minter1: Signer,
  feehold1: Signer,
): Promise<[String, BigInt, BigInt, BigInt]> {
  expect(await instance.hasRole(await instance.MASTER_MINTER_ROLE(), masterminter)).to.equal(true);
  expect(await instance.hasRole(await instance.MINTER_ROLE(), minter1)).to.equal(true);
  expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), feehold1)).to.equal(true);

  // Connect masterminter to the instance
  const masterminterInstance = instance.connect(masterminter) as Contract;

  //approveMint
  await masterminterInstance.approveMint(await minter1.getAddress(), 21_000_000);

  // Connect minter1 to the instance
  const minter1Instance = instance.connect(minter1) as Contract;

  //mint, MINTER_ROLE
  await minter1Instance.mint(await admin.getAddress(), 21_000_000);

  // Connect masterminter to the instance
  const adminInstance = instance.connect(admin) as Contract;

  const adminBalance = await adminInstance.balanceOf(await admin.getAddress());
  expect(adminBalance).to.equal(ethers.toBigInt("21000000"));

  // Connect feemanager to the instance
  const feemanagerInstance = instance.connect(feemanager) as Contract;

  const newBasisPoints = 15; //MAX_SETTABLE_BASIS_POINTS=20
  const newMaxFee = 60000;
  const decimals = 3;
  const amount = ethers.toBigInt("1000000");

  //setup fee, onlyOwner, init common params
  await feemanagerInstance.setCommonParams(feehold1, newBasisPoints, newMaxFee, decimals);

  const fee = await adminInstance.calcCommonFee(amount); // fee = amount * 15 / 1000

  const feeAccount = await adminInstance.commonFeeAccount();

  // fee = value * 15 / 1000
  expect(fee).to.equal(
    (amount * BigInt(await adminInstance.basisPointsRate())) / BigInt(await adminInstance.basisPointsRateDecimal()),
  );

  expect(await instance.isBlacklisted(await admin.getAddress())).to.equal(false);
  expect(await instance.isBlacklisted(await otherAccount.getAddress())).to.equal(false);

  expect(await instance.isWhitelisted(await admin.getAddress())).to.equal(true);
  expect(await instance.isWhitelisted(await otherAccount.getAddress())).to.equal(true);

  const beforeFeeHold1TotalFee = await instance.totalFee(feeAccount);

  //transfer
  await adminInstance.transfer(otherAccount, amount);

  return [feeAccount, beforeFeeHold1TotalFee, fee, amount];
}

export async function redeemUtil(
  instance: Contract,
  // owner: Signer,
  provider: Provider,
  admin: Signer,
  // otherAccount: Signer,
  // feeAccount: Signer,
  whitelistManager: Signer,
  masterminter: Signer,
  feemanager: Signer,
  minter1: Signer,
  feehold1: Signer,
): Promise<[BigInt, BigInt, Number, Number, String, String]> {
  expect(await instance.hasRole(await instance.MASTER_MINTER_ROLE(), masterminter)).to.equal(true);
  expect(await instance.hasRole(await instance.MINTER_ROLE(), minter1)).to.equal(true);
  expect(await instance.hasRole(await instance.FEE_HOLDER_ROLE(), feehold1)).to.equal(true);

  // Connect masterminter to the instance
  const masterminterInstance = instance.connect(masterminter) as Contract;

  //approveMint
  await masterminterInstance.approveMint(await minter1.getAddress(), 21_000_000);

  // Connect masterminter to the instance
  const minterInstance = instance.connect(minter1) as Contract;

  //mint
  await minterInstance.mint(await admin.getAddress(), 21_000_000);
  expect(await minterInstance.balanceOf(await admin.getAddress())).to.equal(21_000_000);

  // Connect feemanager to the instance
  const feemanagerInstance = instance.connect(feemanager) as Contract;

  const newBasisPoints = 15; //MAX_SETTABLE_BASIS_POINTS=20
  const newMaxFee = 60000;
  const decimals = 3;

  //setup fee, onlyOwner, init common params
  await feemanagerInstance.setCommonParams(feehold1, newBasisPoints, newMaxFee, decimals);
  //setup fee, onlyOwner
  await feemanagerInstance.setParams(feehold1, newBasisPoints, newMaxFee);

  const MAX_SETTABLE_BASIS_POINTS = 20;
  const points = newBasisPoints > MAX_SETTABLE_BASIS_POINTS ? MAX_SETTABLE_BASIS_POINTS : newBasisPoints;

  expect(await feemanagerInstance.feeRateAccounts(feehold1)).to.equal(points);

  const network = await provider.getNetwork();
  const chainId: BigNumberish = network.chainId;
  const contractAddress = instance.target;

  const domain: TypedDataDomain = {
    name: "jdscToken",
    version: "1",
    chainId: chainId,
    verifyingContract: contractAddress as string,
  };

  const types = {
    Permit: [
      { name: "owner", type: "address" },
      { name: "spender", type: "address" },
      { name: "value", type: "uint256" },
      { name: "nonce", type: "uint256" },
      { name: "deadline", type: "uint256" },
    ],
  };

  const adminAddress = await admin.getAddress(); //token owner
  const minter1AccountAddress = await minter1.getAddress(); //token spender  _msgSender()
  const value = ethers.toBigInt("21000000"); //amount
  const nonce = await instance.nonces(await admin.getAddress()); // token owner nonce
  const deadline = Math.floor(Date.now() / 1000) + 3600;

  const message = {
    owner: adminAddress,
    spender: minter1AccountAddress,
    value: value,
    nonce: nonce,
    deadline: deadline,
  };

  const signature = await admin.signTypedData(domain, types, message);
  const { v, r, s } = splitSignature(signature);

  const fee = await minterInstance.calcFee(feehold1, value); // fee = value * 15 / 1000

  // fee = value * 15 / 1000
  expect(fee).to.equal((value * BigInt(newBasisPoints)) / BigInt(1000));

  expect(await minterInstance.isBlacklisted(await minter1.getAddress())).to.be.false;
  expect(await minterInstance.isBlacklisted(await admin.getAddress())).to.be.false;
  expect(await minterInstance.isBlacklisted(await feehold1.getAddress())).to.be.false;

  // Connect masterminter to the instance
  const managerInstance = instance.connect(whitelistManager) as Contract;

  // setup WHITELISTER_ROLE
  await managerInstance.grantRole(await managerInstance.WHITELISTER_ROLE(), await feehold1.getAddress());

  expect(await managerInstance.isWhitelisted(await admin.getAddress())).to.be.true;
  expect(await managerInstance.isWhitelisted(await feehold1.getAddress())).to.be.true;

  return [fee, value, deadline, v, r, s];
}
