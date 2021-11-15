// migrations/2_deploy.js
// SPDX-License-Identifier: MIT
const ERC20PresetFixedSupply = artifacts.require("ERC20PresetFixedSupply");
const ERC20MuToken = artifacts.require("ERC20MuToken");
const ERC20ZhiToken = artifacts.require("ERC20ZhiToken");
const ERC721Card = artifacts.require("ERC721Card");
const PantheonIDO = artifacts.require("PantheonIDO");
// const ERC20 = artifacts.require("ERC20");
const BeanC2C = artifacts.require("BeanC2C");
const BeanPool = artifacts.require("BeanPool");
const MuTokenPool = artifacts.require("MuTokenPool");
const BeanInviteReward = artifacts.require("BeanInviteReward");

const sleep = (timeout) => {
  return new Promise((resolve)=>{
    setTimeout(()=>{
      resolve();
    }, timeout)
  })
}

module.exports = async function(deployer, network, accounts) {
  // Deploy A, then deploy B, passing in A's newly deployed address
  let blackHoleAddress = "0x000000000000000000000000000000000000dEaD";
  let zeroAddress = "0x0000000000000000000000000000000000000000";
  let airdropAddress = accounts[4];
  let beneficancy = accounts[5];

  let WBNB = "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd";
  let WUSDT = "0xc350c613e1c1f8e90f662ccbaf24cd32fe0ebc0b";

  
  if (network == "mainnet") {
    WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
    WUSDT = "0xc350c613e1c1f8e90f662ccbaf24cd32fe0ebc0b";
    BUSDT = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t";
    FEFPairAddress = "TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR";
    USDTPairAddress = "TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE";
    airdropAddress = "TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ"; // 用来收取激励手续费
    // beneficancy = "TE8AUMubwZL1B8tH9Sci61urZ6caiGHBna"; // xxxx 用来收取C2C的USDT，和Pool的交易手续费
    beneficancy = "TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ";
    blackHoleAddress = "T9yD14Nj9j7xAB4dbGeiX9h8upfCg3PBbY";
    let inviteAddress = "TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ";
    console.log("accounts", accounts);

    // console.log("110");
    // await deployer.deploy(ERC20PresetFixedSupply, "USDT Token","USDT", 1000000, accounts[0]);
    // let usdtToken = await ERC20PresetFixedSupply.deployed();
    // await usdtToken.transfer(account1, web3.utils.toWei("10000"));
    // await usdtToken.transfer(account2, web3.utils.toWei("10000"));
    // console.log("111");

    // 发行总量：2888888枚
    // 初始填池子：6666枚
    // DAO联盟：2222枚
    // 全部挖矿产出：288万枚

    let initSupply = 2888888;
    let lastRemainSupply = 188888;
    
    // let startTimestamp = toTimestamp("2021-09-18 21:00:00");
    let startTimestamp = "1632574800";
    let totalReward = "2880000000000";
    let startBlock = 35277657;
    deployer.deploy(ERC20ZhiToken, airdropAddress, initSupply, lastRemainSupply, startTimestamp, accounts);
    deployer.link(ERC20ZhiToken, MuTokenPool);
    ERC20ZhiToken.deployed().then(async zhiToken => {
      await deployer.deploy(MuTokenPool, zhiToken.address, FEFPairAddress, USDTPairAddress, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
    });
    // console.log(zhiToken.address);
    await sleep(10000);
    // await deployer.deploy(MuTokenPool, "TMzAxhn1ZgvBR4RsdeVPq6qhUg5svcjaox", FEFPairAddress, USDTPairAddress, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
    // let pool = await MuTokenPool.deployed();
    // console.log(pool.address);
    console.log("Pool init start.")
    // MuTokenPool.deployed().then(pool => {
    //   // ERC20ZhiToken.deployed().then(zhiToken => {
    //   //   console.log("setExcludeFromFee start.")
    //   //   // console.log(zhiToken)
    //   //   // console.log(pool)
    //   //   // zhiToken.setExcludeFromFee(pool.address);
    //   //   // zhiToken.transfer(pool.address, "1000000000");
    //   //   // console.log("balance: ", (zhiToken.balanceOf(pool)).toString());
    //   //   console.log("setExcludeFromFee end.")
    //   // });
    // });
    // console.log("Pool init 1.")
    // await zhiToken.transfer(pool.address, "10000000000");
    // pool.addPool(rate, token, isLp, dayNum, withUpdate);
    // console.log("Pool init 2.")
    // console.log("balance: ", (await zhiToken.balanceOf(pool.address)).toString());
    // await pool.addPool(1000, zhiToken.address, zeroAddress, true, 3*24*1200, false);
    console.log("Pool init end.")
  }

  else if (network == "shasta") {
    WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
    WUSDT = "0xc350c613e1c1f8e90f662ccbaf24cd32fe0ebc0b";
    BUSDT = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t";
    FEFPairAddress = "TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR";
    USDTPairAddress = "TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE";
    airdropAddress = "TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ"; // 用来收取激励手续费
    // beneficancy = "TE8AUMubwZL1B8tH9Sci61urZ6caiGHBna"; // xxxx 用来收取C2C的USDT，和Pool的交易手续费
    beneficancy = "TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ";
    blackHoleAddress = "T9yD14Nj9j7xAB4dbGeiX9h8upfCg3PBbY";
    let inviteAddress = "TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ";
    console.log("accounts", accounts);

    // 发行总量：2888888枚
    // 初始填池子：6666枚
    // DAO联盟：2222枚
    // 全部挖矿产出：288万枚

    let initSupply = 2888888;
    let initMuSupply = 1000000;
    let lastRemainSupply = 188888;
    
    // let startTimestamp = toTimestamp("2021-09-18 21:00:00");
    let startTimestamp = "1632574800";
    let totalReward = "2880000000000";
    let startBlock = 	19889000;
    deployer.deploy(ERC20ZhiToken, airdropAddress, initSupply, lastRemainSupply, startTimestamp, accounts);
    deployer.deploy(ERC20MuToken, initMuSupply, accounts);
    deployer.deploy(MuTokenPool, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
    // await sleep(5000);
    // let zhiToken = await ERC20ZhiToken.deployed();
    // console.log(zhiToken.address);
    // let pool = await MuTokenPool.deployed();
    // console.log(pool.address);
    // await sleep(5000);
    // await deployer.deploy(MuTokenPool, "TMzAxhn1ZgvBR4RsdeVPq6qhUg5svcjaox", FEFPairAddress, USDTPairAddress, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
    // let pool = await MuTokenPool.deployed();
    // console.log(pool.address);
    console.log("Pool init start.")
    // MuTokenPool.deployed().then(pool => {
    //   ERC20ZhiToken.deployed().then(zhiToken => {
    //     console.log("setExcludeFromFee start.")
    //     // console.log(zhiToken)
    //     // console.log(pool)
    //     zhiToken.setExcludeFromFee(pool.address);
    //     zhiToken.transfer(pool.address, "1000000000");
    //     console.log("balance: ", (zhiToken.balanceOf(pool.address)).toString());
    //     console.log("setExcludeFromFee end.")
    //   });
    // });
    // console.log("Pool init 1.")
    // await zhiToken.transfer(pool.address, "10000000000");
    // // pool.addPool(rate, token, isLp, dayNum, withUpdate);
    // console.log("Pool init 2.")
    // console.log("balance: ", (await zhiToken.balanceOf(pool.address)).toString());
    // await pool.addPool(1000, zhiToken.address, zeroAddress, true, 3*24*1200, false);
    console.log("Pool init end.")

  }

  else if (network == "development") {
    WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
    WUSDT = "0xc350c613e1c1f8e90f662ccbaf24cd32fe0ebc0b";
    BUSDT = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t";
    FEFPairAddress = "TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR";
    USDTPairAddress = "TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE";
    airdropAddress = "TE8AUMubwZL1B8tH9Sci61urZ6caiGHBna"; // 用来收取激励手续费
    // beneficancy = "TE8AUMubwZL1B8tH9Sci61urZ6caiGHBna"; // xxxx 用来收取C2C的USDT，和Pool的交易手续费
    beneficancy = accounts;
    blackHoleAddress = "T9yD14Nj9j7xAB4dbGeiX9h8upfCg3PBbY";
    console.log("accounts", accounts);

    // console.log(erc721.address);
    console.log(airdropAddress);
    console.log(blackHoleAddress);

    // 发行总量：2888888枚
    // 初始填池子：6666枚
    // DAO联盟：2222枚
    // 全部挖矿产出：288万枚

    let initSupply = 2888888;
    let initMuSupply = 1000000;
    let lastRemainSupply = 188888;
    
    // let startTimestamp = toTimestamp("2021-09-18 21:00:00");
    let startTimestamp = "1632574800";
    let inviteAddress = accounts;
    let totalReward = "2880000000000";
    let startBlock = 0;
    // ERC20ZhiToken.resetAddress();
    // MuTokenPool.resetAddress();
    // ERC20MuToken.resetAddress();
    deployer.deploy(ERC20ZhiToken, airdropAddress, initSupply, lastRemainSupply, startTimestamp, accounts);
    deployer.deploy(ERC20MuToken, initMuSupply, accounts);
    deployer.deploy(MuTokenPool, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
    // deployer.link(ERC20ZhiToken, MuTokenPool);
    // ERC20ZhiToken.deployed().then(zhiToken => {
    // await deployer.deploy(MuTokenPool, FEFPairAddress, USDTPairAddress, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
    // });
    // let zhiToken = await ERC20ZhiToken.deployed();
    // console.log(zhiToken.address);
    // sleep(5000);
    // await deployer.deploy(MuTokenPool, "TMzAxhn1ZgvBR4RsdeVPq6qhUg5svcjaox", FEFPairAddress, USDTPairAddress, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
    // let pool = await MuTokenPool.deployed();
    // console.log(pool.address);
    console.log("Pool init start.")
    // MuTokenPool.deployed().then(pool => {
    //   // ERC20ZhiToken.deployed().then(zhiToken => {
    //   //   console.log("setExcludeFromFee start.")
    //   //   // console.log(zhiToken)
    //   //   // console.log(pool)
    //   //   // zhiToken.setExcludeFromFee(pool.address);
    //   //   // zhiToken.transfer(pool.address, "1000000000");
    //   //   // console.log("balance: ", (zhiToken.balanceOf(pool)).toString());
    //   //   console.log("setExcludeFromFee end.")
    //   // });
    // });
    // console.log("Pool init 1.")
    // await pool.setMainToken(zhiToken.address);
    // await zhiToken.transfer(pool.address, "10000000000");
    // pool.addPool(rate, token, isLp, dayNum, withUpdate);
    // console.log("Pool init 2.")
    // console.log("balance: ", (await zhiToken.balanceOf(pool.address)).toString());
    // await pool.addPool(1000, zhiToken.address, zeroAddress, true, 3*24*1200, false);
    console.log("Pool init end.")
    // let zhiToken = await ERC20PanToken.at("0x3aF28Da6a016143a9DCa040eC8632D88fAA1cfd2");
    // zhiToken.setSwapAndLiquifyEnabled(true);
    // console.log(zhiToken.address);
    // Deploy IDO
    // console.log("Deploy IDO");
    // let idoStart = toTimestamp("2021-08-19 15:00:00");
    // let idoEnd = toTimestamp("2021-08-29 23:00:00");
    // let claimStart = toTimestamp("2021-08-23 15:00:00");
    // let claimEnd = toTimestamp("2021-11-23 15:00:00");
    // await deployer.deploy(PantheonIDO, zhiToken.address, beneficancy, idoStart, idoEnd, claimStart, claimEnd);
    // let ido = await PantheonIDO.deployed();

  }
};

function toTimestamp(strDate){
  var datum = Date.parse(strDate);
  return datum/1000;
}
