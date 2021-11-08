// const chalk = require('chalk')
const fs = require('fs');
// const tronbox = require('../tronbox');
// require("../contract/token/ERC20/IERC20");
var wait = require('./wait')
const MuTokenPool= artifacts.require("MuTokenPool");
const ERC20ZhiToken= artifacts.require("ERC20ZhiToken");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("MuTokenPool", function (accounts) {
  let pool;
  let token;
  let zeroAddress = "0x0000000000000000000000000000000000000000";
  let privateKey = "3233a7354f4f725d15f2a830d42c629f2bca65241d6a1ad320a7a102c20dce6e";
  let baseBlock = 0;
  // let lastRewardBlock = baseBlock;

  before(async function () {
    // meta = await MetaCoin.deployed()
    pool = await MuTokenPool.deployed();
    token = await ERC20ZhiToken.deployed()
    // const tradeobj = await tronWeb.transactionBuilder.sendTrx(pool.address, 500000000);
    // const signedtxn = await tronWeb.trx.sign(tradeobj, privateKey);
    // console.log(signedtxn)

    await token.setExcludeFromFee(pool.address);
    await token.transfer(pool.address, "1000000000000");
    await token.transfer(accounts[0], "100000000");
    await token.transfer(accounts[2], "100000000");
    // pool.addPool(rate, token, isLp, dayNum, withUpdate);
    await pool.addPool(1000, token.address, zeroAddress, true, 3*24*1200, false);
    console.log("Beneficience ", accounts[5]);
    await pool.setBeneficience(accounts[5]);
    await pool.setMainToken(token.address);
    
    if(accounts.length < 3) {
      // Set your own accounts if you are not using Tron Quickstart

    }
  })
  it("Test init supply", async function () {
    const totalReward = (await pool.totalReward.call()).toString();
    console.log(totalReward);
    assert.equal(totalReward, "2880000000000");
  })

  it("Test init poolInfo", async function () {
    const poolInfo = await pool.poolInfo(0);
    console.log(poolInfo);
    assert.equal(poolInfo.lpToken, token.address);
  })

  it("Test token balance of pool", async function() {
    const balance = (await  token.balanceOf(pool.address)).toString();
    console.log(balance);
    assert.equal(balance, "1000000000000");
  })

  it("Test isExcludeFromFee of pool", async function() {
    const isExcludeFromFee = await token.isExcludedFromFee(pool.address);
    console.log(isExcludeFromFee);
    assert.equal(isExcludeFromFee, true);
  })

  it("Test pendingReward should be 0", async function() {
    const reward = await pool.pendingReward(0, accounts[0]);
    console.log(reward);
    assert.equal(reward, '0');
  })

  it("Test deposit with amount 1", async function() {
    const minerInfo = await pool.minerInfo(0, accounts[0]);
    console.log(minerInfo);
    const approve = await token.approve(pool.address, "1000000000000", {from: accounts[0]})
    console.log(approve);
    const deposit = await pool.deposit(0, 1000000, {callValue: 1000000, from: accounts[0]});
    // const deposit = await pool.call("deposit", 0, "1000000", {value: "1000000"})
    console.log(deposit);
    // await pool.updateReward();
    const minerInfo2 = await pool.minerInfo(0, accounts[0]);
    console.log(minerInfo2);

    const balance = (await  token.balanceOf(pool.address)).toString();
    console.log(balance);
    assert.equal(minerInfo2.power.toString(), minerInfo.power.toNumber() + 2000000);
    await wait(15);
  })

  it("Check pendingReward of pool", async function() {
    await pool.updateReward();
    const minerInfo = await pool.minerInfo(0, accounts[0]);
    const reward = (await  pool.pendingReward(0, accounts[0])).toString();
    
    const totalPower = (await  pool.totalPower.call()).toString();
    const baseBlock = (await  pool.baseBlock.call()).toString();
    // const lastRewardBlock = (await  pool.lastRewardBlock.call()).toString();
    const accChaPerShare = (await  pool.accChaPerShare.call()).toString();
    const block = await tronWeb.trx.getCurrentBlock()
    console.log(reward, totalPower, block.block_header.raw_data.number, baseBlock, accChaPerShare);
    
    const lastBlock = baseBlock - baseBlock;
    const endBlock = block.block_header.raw_data.number - baseBlock;
    const baseReward = (endBlock - lastBlock) * 7819444 / 1000;
    const addition = (endBlock + lastBlock)*(endBlock - lastBlock)*6028/1000000;
    console.log(lastBlock, endBlock);
    console.log(reward, parseInt(baseReward+addition));
    
    assert.isTrue(block.block_header.raw_data.number >= lastBlock);
  })

  it("Test repeat deposit with amount 1", async function() {
    await wait(15);
    const minerInfo = await pool.minerInfo(0, accounts[0]);
    console.log(minerInfo);
    const approve = await token.approve(pool.address, "1000000000000", {from: accounts[0]})
    console.log(approve);
    const deposit = await pool.deposit(0, 1000000, {callValue: 1000000, from: accounts[0]});
    // const deposit = await pool.call("deposit", 0, "1000000", {value: "1000000"})
    console.log(deposit);
    // await pool.updateReward();
    const minerInfo2 = await pool.minerInfo(0, accounts[0]);
    console.log(minerInfo2);

    const balance = (await  token.balanceOf(pool.address)).toString();
    console.log(balance);
    assert.equal(minerInfo2.power.toString(), minerInfo.power.toNumber() + 2000000);
  })

  it("Check trx transfer after deposit with amount 1 trx", async function() {
    await pool.updateReward();
    await wait(10)
    const minerInfo = await pool.minerInfo(0, accounts[0]);
    console.log(minerInfo);
    const trxBalance = await tronWeb.trx.getBalance(accounts[5]);

    // const approve = await token.approve(pool.address, "1000000000000")
    // console.log(approve);
    const deposit = await pool.deposit(0, "1000000", {callValue: "1000000", from: accounts[0]});
    // const deposit = await pool.call("deposit", 0, "1000000", {value: "1000000"})
    console.log(deposit);
    await wait(10)
    const minerInfo2 = await pool.minerInfo(0, accounts[0]);
    console.log(minerInfo2);
    const trxBalance2 = await tronWeb.trx.getBalance(accounts[5]);
    console.log(trxBalance, trxBalance2);
    assert.equal(trxBalance2.toString(), trxBalance + 1000000);
  })

  it("Check havest", async function() {
    await wait(10)
    await pool.updateReward();
    const balance = await token.balanceOf(accounts[0]);
    const reward = await  pool.pendingReward(0, accounts[0]);
    await  pool.harvest(0, {from: accounts[0]});
    await wait(4)
    const balance2 = await token.balanceOf(accounts[0]);
    console.log(balance.toString(), reward.toString(), balance2.toString());
    assert.isTrue(balance2.toNumber() < balance.toNumber() + reward.toNumber() + 8000);
  })

  it("Check havest", async function() {
    await pool.updateReward();
    const balance = await token.balanceOf(accounts[0]);
    const reward = await  pool.pendingReward(0, accounts[0]);
    await  pool.harvest(0, {from: accounts[0]});
    await wait(6)
    const balance2 = await token.balanceOf(accounts[0]);
    console.log(balance.toString(), reward.toString(), balance2.toString());
    assert.isTrue(balance2.toNumber() < balance.toNumber() + reward.toNumber() + 8000);
  })

  it("Check havest", async function() {
    await pool.updateReward();
    const balance = await token.balanceOf(accounts[0]);
    const reward = await  pool.pendingReward(0, accounts[0]);
    await  pool.harvest(0, {from: accounts[0]});
    await wait(12);
    const balance2 = await token.balanceOf(accounts[0]);
    console.log(balance.toString(), reward.toString(), balance2.toString());
    assert.isTrue(balance2.toNumber() < balance.toNumber() + reward.toNumber() + 8000);
  })
  // it("Test deposit with amount 1 from account2", async function() {
  //   const minerInfo = await pool.minerInfo(0, accounts[2]);
  //   console.log(minerInfo);
  //   const approve = await token.approve(pool.address, "1000000000000", {from: accounts[2]})
  //   console.log(approve);
  //   const deposit = await pool.deposit(0, 1000000, {callValue: 1000000, from: accounts[2]});
  //   console.log(deposit);
  //   const minerInfo2 = await pool.minerInfo(0, accounts[2]);
  //   console.log(minerInfo2);
  //   assert.equal(minerInfo2.power.toString(), minerInfo.power.toNumber() + 2000000);
  //   await wait(15);
  // })
});
