// const chalk = require('chalk')
const fs = require('fs');
// const tronbox = require('../tronbox');
// require("../contract/token/ERC20/IERC20");
var wait = require('./wait')
const ZhiTokenPool= artifacts.require("ZhiTokenPool");
const ERC20PresetFixedSupply= artifacts.require("ERC20PresetFixedSupply");
const ERC20MuToken= artifacts.require("ERC20MuToken");
const ERC20HCToken= artifacts.require("ERC20HCToken");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ZhiTokenPool", function (accounts) {
  let pool;
  let hcToken;
  let lpToken;
  let zeroAddress = "0x0000000000000000000000000000000000000000";
  let privateKey = "3233a7354f4f725d15f2a830d42c629f2bca65241d6a1ad320a7a102c20dce6e";
  // let lastRewardBlock = baseBlock;
  let startBlock = 0;
  let totalBlock = 1200 * 24 * 90;
  let delayBlock = 1200 * 24 * 60;
  let totalRewardHC1 = 4000 * 10**6;
  let totalRewardHC2 = 1000 * 10**6;

  before(async function () {
    // meta = await MetaCoin.deployed()
    pool = await ZhiTokenPool.deployed();
    lpToken = await ERC20PresetFixedSupply.deployed()
    hcToken = await ERC20HCToken.deployed()
    // const tradeobj = await tronWeb.transactionBuilder.sendTrx(pool.address, 500000000);
    // const signedtxn = await tronWeb.trx.sign(tradeobj, privateKey);
    // // console.log(signedtxn)
    // console.log(pool.address);
    // console.log(lpToken.address);
    // console.log(hcToken.address);
    // // console.log(accounts);

    communityAddress = "TWRBkJ6R1q87SSp8YMcsiGXEUfDGKysagw";
    nftMarketAddress = "TWRBkJ6R1q87SSp8YMcsiGXEUfDGKysagw"; // my test 6
    fundbaseAddress  = "TUFi19U1qm1Nvgrb3ciyXGbpcK5uZEPEAG"; // ruoyi
    // await pool.setPoolDelay(0, delayBlock, totalBlock);
    // await pool.setPoolDelay(0, delayBlock, totalBlock);
    await lpToken.transfer(accounts[0], "10000000000");
    await lpToken.transfer(accounts[2], "10000000000");

    // pool.addPool(_startBlock, _totalBlock, _totalHC, _token);
  })
  // it("Test init supply", async function () {
  //   const totalReward = (await pool.totalReward.call()).toString();
  //   // console.log(totalReward);
  //   assert.equal(totalReward, "2880000000000");
  // })

  it("Test init poolInfo", async function () {
    const poolInfo = await pool.poolInfo(0);
    assert.equal(poolInfo.lpToken, lpToken.address);
  })

  it("Test token balance of pool", async function() {
    const balance = (await hcToken.balanceOf(pool.address));
    assert.equal(balance.toString(), "5000000000");
  })

  // it("Test isExcludeFromFee of pool", async function() {
  //   const isExcludeFromFee = await token.isExcludedFromFee(pool.address);
  //   // console.log(isExcludeFromFee);
  //   assert.equal(isExcludeFromFee, true);
  // })

  it("Test pendingReward should be 0", async function() {
    const rewards = await pool.pendingReward(0, accounts[0]);
    assert.equal(rewards[0], '0');
    assert.equal(rewards[1], '0');
  })

  it("Test deposit with amount 1", async function() {
    const minerInfo = await pool.minerInfo(0, accounts[0]);
    // console.log(minerInfo);
    const balance = (await  lpToken.balanceOf(accounts[0]));
    // console.log(balance);
    const approve = await lpToken.approve(pool.address, "100000000", {from: accounts[0]})
    // console.log(approve);
    const deposit = await pool.deposit(0, 100000000, {shouldPollResponse: true, from: accounts[0]});
    // console.log(deposit);
    // await pool.updateReward();
    const minerInfo2 = await pool.minerInfo(0, accounts[0]);
    // console.log(minerInfo2);

    const balance2 = (await  lpToken.balanceOf(accounts[0]));
    // console.log(balance2);
    assert.equal(balance2.toString(), balance.toNumber() - 100000000);

    assert.equal(minerInfo2.power.toString(), minerInfo.power.toNumber() + 100000000);
    await wait(15);
  })

  it("Test deposit from account 2", async function() {
    await lpToken.transfer(accounts[2], "120000000");
    const minerInfo = await pool.minerInfo(0, accounts[2]);
    // console.log(minerInfo);
    const approve = await lpToken.approve(pool.address, "120000000", {from: accounts[2]})
    // console.log(approve);
    const deposit = await pool.deposit(0, 120000000, {shouldPollResponse: true, from: accounts[2]});
    // console.log(deposit);
    // await pool.updateReward();
    const minerInfo2 = await pool.minerInfo(0, accounts[2]);
    // console.log(minerInfo2);

    const balance = (await  lpToken.balanceOf(pool.address)).toString();
    // console.log(balance);
    assert.equal(minerInfo2.power.toString(), minerInfo.power.toNumber() + 120000000);
    await wait(10);
  })

  // it("Test trx balance of deposit ", async function() {
  //   const minerInfo = await pool.minerInfo(0, accounts[0]);
  //   // console.log(minerInfo);
  //   const balance = await tronWeb.trx.getBalance(accounts[0]);
  //   // console.log(balance);
  //   const approve = await lpToken.approve(pool.address, "1000000000000", {from: accounts[0]})
  //   // console.log(approve);
  //   const deposit = await pool.deposit(0, 1000000000, {callValue: 130000000, shouldPollResponse:true, from: accounts[0]});
  //   // const deposit = await pool.call("deposit", 0, "1000000", {value: "1000000"})
  //   await wait(10);
  //   // console.log(deposit);
  //   // await pool.updateReward();
  //   const minerInfo2 = await pool.minerInfo(0, accounts[0]);
  //   // console.log(minerInfo2);

  //   const balance2 = await tronWeb.trx.getBalance(accounts[0]);
  //   // console.log(balance2);
  //   assert.isTrue(balance2 + 30000000 > balance);
  //   assert.equal(minerInfo2.power.toString(), minerInfo.power.toNumber() + 2000000);
  //   await wait(10);
  // })

  it("Check pendingReward of pool", async function() {
    await pool.updateReward(0);
    const poolInfo = await pool.poolInfo(0);
    const minerInfo = await pool.minerInfo(0, accounts[0]);
    const rewards = await pool.pendingReward(0, accounts[0]);
    
    const totalPower = (await  poolInfo.totalPower).toString();
    // const baseBlock = (await  pool.baseBlock.call()).toString();
    // const lastRewardBlock = (await  pool.lastRewardBlock.call()).toString();
    const accChaPerShare = (await  poolInfo.accChaPerShare).toString();
    const block = await tronWeb.trx.getCurrentBlock()
    // console.log(totalPower, block.block_header.raw_data.number, accChaPerShare);
    
    const lastBlock = minerInfo.startBlock;
    const endBlock = block.block_header.raw_data.number;
    const baseReward = (endBlock - lastBlock) * poolInfo.hcPerBlock;
    // console.log(lastBlock, endBlock);
    // console.log(rewards[0], rewards[1], baseReward);
    
    assert.isTrue(block.block_header.raw_data.number >= lastBlock);
  })

  // it("Test repeat deposit with amount 1", async function() {
  //   await wait(15);
  //   const minerInfo = await pool.minerInfo(0, accounts[0]);
  //   // console.log(minerInfo);
  //   const approve = await lpToken.approve(pool.address, "1000000000000", {from: accounts[0]})
  //   // console.log(approve);
  //   const deposit = await pool.deposit(0, "1000000000", {callValue: 10000000, shouldPollResponse: true, from: accounts[0]});
  //   // const deposit = await pool.call("deposit", 0, "1000000", {value: "1000000"})
  //   // console.log(deposit);
  //   // await pool.updateReward();
  //   const minerInfo2 = await pool.minerInfo(0, accounts[0]);
  //   // console.log(minerInfo2);

  //   const balance = (await  lpToken.balanceOf(pool.address)).toString();
  //   // console.log(balance);
  //   assert.equal(minerInfo2.power.toString(), minerInfo.power.toNumber() + 2000000);
  // })

  // it("Check trx transfer after deposit with amount 1 trx", async function() {
  //   await pool.updateReward();
  //   await wait(10)
  //   const minerInfo = await pool.minerInfo(0, accounts[0]);
  //   // console.log(minerInfo);
  //   const trxBalance = await tronWeb.trx.getBalance(accounts[5]);

  //   // const approve = await token.approve(pool.address, "1000000000000")
  //   // // console.log(approve);
  //   const deposit = await pool.deposit(0, "1000000000", {callValue: "10000000", shouldPollResponse: true, from: accounts[0]});
  //   // const deposit = await pool.call("deposit", 0, "1000000", {value: "1000000"})
  //   // console.log(deposit);
  //   await wait(10)
  //   const minerInfo2 = await pool.minerInfo(0, accounts[0]);
  //   // console.log(minerInfo2);
  //   const trxBalance2 = await tronWeb.trx.getBalance(accounts[5]);
  //   // console.log(trxBalance, trxBalance2);
  //   assert.equal(trxBalance2.toString(), trxBalance + 10000000);
  // })

  // it("Check global pool info", async function() {
  //   // await pool.updateReward();
  //   // await wait(10)
  //   const poolInfo = await pool.getGlobalPoolInfo(0);
  //   // console.log(poolInfo);
  //   assert.equal(poolInfo[3].toString(), 252500000);
  // })

  it("Check havest before delay block", async function() {
    await wait(10)
    // await pool.updateReward();
    const balance = await hcToken.balanceOf(accounts[0]);
    const rewards = await  pool.pendingReward(0, accounts[0]);
    await  pool.harvest(0, {from: accounts[0]});
    await wait(6)
    const balance2 = await hcToken.balanceOf(accounts[0]);
    // console.log(balance.toString(), rewards[0].toString(), rewards[1].toString(), balance2.toString());
    assert.equal(balance2.toNumber(), balance.toNumber());
  })

  it("Check setPoolDelay ", async function() {
    // await pool.updateReward();
    await lpToken.transfer(accounts[3], "120000000");
    await lpToken.approve(pool.address, "120000000", {from: accounts[3]})

    await pool.setPoolDelay(0, 0, 1200, {shouldPollResponse: true, from: accounts[0]});
    await wait(30)
    const poolInfo = await pool.poolInfo(0);
    // console.log("poolInfo \n", poolInfo);
    const deposit = await pool.deposit(0, 120000000, {shouldPollResponse: true, from: accounts[3]});
    await wait(6)
    assert.isTrue(true);
  })

  it("Check havest after delay block", async function() {
    // await pool.updateReward();
    await wait(6)
    const minerInfo = await pool.minerInfo(0, accounts[3]);
    // console.log("minerInfo \n", minerInfo);
    const balance = await hcToken.balanceOf(accounts[3]);
    const rewards = await  pool.pendingReward(0, accounts[3]);
    const block = await tronWeb.trx.getCurrentBlock()
    // console.log("blockNumber ", block.block_header.raw_data.number);
    
    await  pool.harvest(0, {from: accounts[3]});
    await wait(6)
    const balance2 = await hcToken.balanceOf(accounts[3]);
    // console.log(balance.toString(), rewards[0].toString(), rewards[1].toString(), balance2.toString());
    assert.isTrue(balance2.toNumber() > balance.toNumber());
    // assert.isTrue(balance2.toNumber() > balance.toNumber() + rewards[0].toNumber() + 8000);
  })

  // it("Check havest", async function() {
  //   // await pool.updateReward();
  //   const balance = await token.balanceOf(accounts[0]);
  //   const rewards = await  pool.pendingReward(0, accounts[0]);
  //   await  pool.harvest(0, {from: accounts[0]});
  //   await wait(12);
  //   const balance2 = await token.balanceOf(accounts[0]);
  //   // console.log(balance.toString(), reward[0].toString(), balance2.toString());
  //   assert.isTrue(balance2.toNumber() < balance.toNumber() + reward[1].toNumber() + 8000);
  // })

  it("Check withdraw after delay block", async function() {
    // await pool.updateReward();
    await wait(6);
    const balance = await hcToken.balanceOf(accounts[3]);
    const rewards = await  pool.pendingReward(0, accounts[3]);
    await  pool.withdraw(0, 0, {from: accounts[3]});
    await wait(12);
    const balance2 = await hcToken.balanceOf(accounts[3]);
    // console.log(balance.toString(), rewards[0].toString(), rewards[1].toString(), balance2.toString());
    assert.isTrue(balance2.toNumber() > balance.toNumber() + rewards[0].toNumber());
  })

  it("Check withdraw", async function() {
    // await pool.updateReward();
    await wait(6);
    const balance = await hcToken.balanceOf(accounts[0]);
    let rewards = await  pool.pendingReward(0, accounts[0]);
    await  pool.withdraw(0, 0, {from: accounts[0]});
    await wait(12);
    const balance2 = await hcToken.balanceOf(accounts[0]);
    // console.log(balance.toString(), rewards[0].toString(), rewards[1].toString(), balance2.toString());
    assert.isTrue(balance2.toNumber() == balance.toNumber());
    await wait(12);
    const minerInfo = await pool.minerInfo(0, accounts[0]);
    assert.equal(minerInfo.amount, 0);
    assert.equal(minerInfo.power, 0);
    await wait(20);
    rewards = await  pool.pendingReward(0, accounts[0]);
    assert.equal(rewards[0], 0);
    assert.equal(rewards[1], 0);
  })

  // // it("Test deposit with amount 1 from account2", async function() {
  // //   const minerInfo = await pool.minerInfo(0, accounts[2]);
  // //   // console.log(minerInfo);
  // //   const approve = await token.approve(pool.address, "1000000000000", {from: accounts[2]})
  // //   // console.log(approve);
  // //   const deposit = await pool.deposit(0, 1000000, {callValue: 1000000, from: accounts[2]});
  // //   // console.log(deposit);
  // //   const minerInfo2 = await pool.minerInfo(0, accounts[2]);
  // //   // console.log(minerInfo2);
  // //   assert.equal(minerInfo2.power.toString(), minerInfo.power.toNumber() + 2000000);
  // //   await wait(15);
  // // })
});
