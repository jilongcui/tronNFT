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
    let zhiToken = await ERC20ZhiToken.deployed();
    let muToken = await ERC20MuToken.deployed();
    let pool = await MuTokenPool.deployed();
    console.log("Pool init start 4.")
    
    // await pool.setHtuTrxPair("TD1zWA8STBocignyvRfuEkwEErM2AjkAof");

    console.log(accounts);
    console.log(await pool.fefTRXPair());
    console.log(await pool.htuTRXPair());
    console.log(await pool.usdtPairAddress());
    
    // let poolInfo = await pool.getGlobalPoolInfo(0);
    // console.log(poolInfo);
    // let poolInfo2 = await pool.poolInfo(0);
    // console.log(poolInfo2);

    // let baseBlock = await pool.baseBlock();
    // console.log("baseBlock ", baseBlock.toString());

    // let invitePower = await pool.getInviteInfo("TQMWBb1xyoVdaEibjaR3kYEdxKv8tWKkg9");
    // let invitePower2 = await pool.getInviteInfo("TYvQu7s67m72r6GoMQURZgsCjrUUzWfiVD");
    // let invitePower3 = await pool.getInviteInfo("TVQLCa6E7uZryUdFzwLrTSVctq1QwmPbWj");
    // let invitePower4 = await pool.getInviteInfo("TPQ3oEWptritzt1EMhTFMRxKHzyGj9fZSo");
    // console.log(invitePower[1].toString());
    // console.log(invitePower[2].toString());
    // console.log(invitePower[3].toString());
    // console.log(invitePower2[1].toString());
    // console.log(invitePower2[2].toString());
    // console.log(invitePower2[3].toString());
    // console.log(invitePower3[1].toString());
    // console.log(invitePower3[2].toString());
    // console.log(invitePower3[3].toString());
    // console.log(invitePower4[1].toString());
    // console.log(invitePower4[2].toString());
    // console.log(invitePower4[3].toString());
    
    // await pool.setInvite("TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ");
    // let parent = await pool.getInviteInfo(accounts);
    // console.log("parent", parent);
    // let value = await pool.getFefValue("100000000");
    // console.log(value.toNumber());
    // let value2 = await pool.getUsdtValue(value.toString());
    // console.log(value2.toNumber());
    // let value3 = await pool.getUsdtValue(value);
    // console.log(value3.toNumber());

    // await muToken.approve(pool.address, '10000000000');
    // let log = await pool.deposit(0, '100000000', {callValue: 30000000});
    // console.log(log);

    // await zhiToken.setExcludeFromFee("TQZdtUJehkbHrmBJakdRLrJXWxpfgWK44X");
    // await zhiToken.setExcludeFromFee("TFoackUgMhZGbzJT6RLq67kDMJXwJPNmfa");
    // await zhiToken.setExcludeFromFee("TSTPpZboB4yyf6V38j4UEH9pFuCq6boomL");
    // await zhiToken.setExcludeFromFee("TJ5q9mipdGmgRjwgtEeyU7YCwPwSQrt5cY");
    // await zhiToken.setExcludeFromFee("TVwMfDZP7ss799hUUZKckkk7GJVnG4pBTS");
    // await zhiToken.setExcludeFromFee("TTVfLNvA34Ni77m2nuMzsLWSKniLM3WXGt");
    // await zhiToken.setExcludeFromFee("TRJPwZWDrwFyM5s4pfzmTRqdyiLjdLMVaP");
    await zhiToken.setIncludeInFee("TD1zWA8STBocignyvRfuEkwEErM2AjkAof");

    // let startBlock = 35709673;
    // const currentBlock = await tronWeb.trx.getCurrentBlock();
    // console.log("Current block ", currentBlock);
    // await pool.setInitBlock(35986670);
    
    console.log("Pool init end 4.")
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
    let lastRemainSupply = 188888;
    
    // let startTimestamp = toTimestamp("2021-09-18 21:00:00");
    let startTimestamp = "1632574800";
    let totalReward = "2880000000000";
    let startBlock = 35277657;
    // deployer.deploy(ERC20ZhiToken, airdropAddress, initSupply, lastRemainSupply, accounts);
    // await deployer.link(ERC20ZhiToken, MuTokenPool);
    //.then(async zhiToken => {
    // deployer.deploy(MuTokenPool, FEFPairAddress, USDTPairAddress, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
    //});
    // await sleep(5000);
    let zhiToken = await ERC20ZhiToken.deployed();
    let muToken = await ERC20MuToken.deployed();
    let pool = await MuTokenPool.deployed();
    console.log(muToken.address);
    console.log(zhiToken.address);
    console.log(pool.address);
    console.log("Pool init start.")
    
    // await muToken.transfer("TB7Jei89VMW5B3DmifmSGd8HD1Pwtnb62J", "200000000000");
    await muToken.transfer("TWRBkJ6R1q87SSp8YMcsiGXEUfDGKysagw", "200000000000");
    
    // let balance = await muToken.balanceOf(accounts);
    // console.log("account 0 balance", balance.toNumber());

    // const minerInfo = await pool.minerInfo(0, accounts);
    // const reward = await pool.pendingReward(0, accounts);
    // console.log(minerInfo);
    // console.log(reward);

    // const currentBlock = await tronWeb.trx.getCurrentBlock();
    // console.log("Start at block ", currentBlock);
    // await pool.setInitBlock(0);
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
    let lastRemainSupply = 188888;
    
    // let startTimestamp = toTimestamp("2021-09-18 21:00:00");
    let startTimestamp = "1632574800";
    let inviteAddress = accounts;
    let totalReward = "2880000000000";
    let startBlock = 0;
    ERC20ZhiToken.resetAddress();
    MuTokenPool.resetAddress();
    deployer.deploy(ERC20ZhiToken, airdropAddress, initSupply, lastRemainSupply, accounts);
    // deployer.link(ERC20ZhiToken, MuTokenPool);
    deployer.deploy(MuTokenPool, FEFPairAddress, USDTPairAddress, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
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
    // ERC20ZhiToken.deployed()
    //     .then(zhiToken => {
    //       tronWeb.contract().at(zhiToken.address).then( zhi2 => {
    //         console.log(zhi2.address);
    //       });
    //       // let totalReward = "2880000";
    //       // let startBlock = "35197155";
    //       // console.log(zhiToken.address);
    //       // deployer.deploy(MuTokenPool, zhiToken.address, FEFPairAddress, USDTPairAddress, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
    //       // MuTokenPool.deployed().then(async pool => {
    //       //   console.log(pool.address);
    //       //   console.log("Pool init start.")
    //       //   await zhiToken.setExcludeFromFee(pool.address);
    //       //   console.log("Pool init 2.")
    //       //   await zhiToken.transfer(pool.address, "10000000000");
    //       //   // pool.addPool(rate, token, isLp, dayNum, withUpdate);
    //       //   console.log("Pool init 2.")
    //       //   await pool.addPool(1000, zhiToken.address, zeroAddress, true, 3*24*1200, false);
    //       //   console.log("Pool init end.")
            
    //       // });
    //       // // 要转给那几个地址
    //       // await zhiToken.transfer("0x2f6aA65C79c7210da9d9CFA9DaD5Bcd0433D3C0A", web3.utils.toWei("290000")); //
    //       // await zhiToken.transfer("0x31cDB66F1A8A1A243121674cb3928eD27D23c795", web3.utils.toWei("200000")); //
    //       // await zhiToken.transfer("0x23bE592f69f83EafeDD03aA9992F22A3E856AC49", web3.utils.toWei("300000")); //
    //       // await zhiToken.transfer("0x03fB46515DC130736f14492c4d67002B02A6488d", web3.utils.toWei("200000")); //
    //       // // await zhiToken.transfer(ido.address, web3.utils.toWei("400000"));
    //       // await zhiToken.setExcludeFromFee(pool.address);
    //       // await zhiToken.setExcludeFromFee("0x2f6aA65C79c7210da9d9CFA9DaD5Bcd0433D3C0A");
    //       // await zhiToken.setExcludeFromFee("0x31cDB66F1A8A1A243121674cb3928eD27D23c795");
    //       // await zhiToken.setExcludeFromFee("0x23bE592f69f83EafeDD03aA9992F22A3E856AC49");
    //       // await zhiToken.setExcludeFromFee("0x03fB46515DC130736f14492c4d67002B02A6488d");
    //       // await zhiToken.transfer(pool.address, "10000000000");
    //       // // console.log(token);
    //       // // pool.addPool(rate, token, isLp, dayNum, withUpdate);
    //       // await pool.addPool(1000, zhiToken.address, zeroAddress, true, 3*24*1200, false);
    //       // await pool.addPool(4000, 0, zhiToken.address, zeroAddress, false, 7*24*1200, false);
    //       // await pool.addPool(8000, 0, zhiToken.address, zeroAddress, false, 15*24*1200, false);
    //       // await pool.addPool(16000, 0, zhiToken.address, zeroAddress, false, 30*24*1200, false);

    //       // await deployer.deploy(BeanInviteReward, zhiToken.address, "0x2f6aA65C79c7210da9d9CFA9DaD5Bcd0433D3C0A");
    //       // let inviteReward = await BeanInviteReward.deployed();
    //       // await zhiToken.transfer(inviteReward.address, web3.utils.toWei("2000000"));
    //       // // await pool.setInvite(inviteAddress, {from: "0x10586d9aA9dA7eB6E8FF045cD2F57ABC5EBB57D8"});

    //       // console.log("115");
    //       // console.log("BEAN");
    //       // console.log(zhiToken.address);
    //       // console.log("ERC721");
    //       // console.log(erc721Address);
    //       // // console.log("IDO");
    //       // // console.log(ido.address);
    //       // console.log("C2C");
    //       // console.log(c2c.address);
    //       // console.log("Pool");
    //       // console.log(pool.address);
    //       // console.log("Invite");
    //       // console.log(inviteReward.address);
    //       // console.log("USDT");
    //       // console.log(BUSDT);
    //     });
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
