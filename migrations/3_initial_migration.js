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
    // let muTokenAddr = "TF8MV9ogKfwK7xxxNF2HEWtE44gEFj9K8T";
    let muTokenAddr = muToken.address;
    let pool = await MuTokenPool.deployed();
    console.log(muTokenAddr);
    console.log(zhiToken.address);
    console.log(pool.address);

    let daoUnionAddress = "TSJERvooL1KqYHJeqfZGnX13D7w7MuUFrq";
    let liquidAddress = "TDbyz5iWmLAErnA5rU7ZNCspnF1Yyou1zN";

    // 初始填池子：6666枚
    // DAO联盟：2222枚
    // 全部挖矿产出：288万枚
    console.log("Pool init start 3.")
    await zhiToken.transfer(pool.address, "2800000000000"); // 2880000000000
    await zhiToken.transfer(liquidAddress, "6666000000");
    await zhiToken.transfer(daoUnionAddress, "2222000000");
    // // pool.addPool(rate, token, isLp, dayNum, withUpdate);
    console.log("balance: ", (await zhiToken.balanceOf(pool.address)).toString());
    await pool.addPool(1000, muTokenAddr, zeroAddress, true, 3*24*1200, false);
    await zhiToken.setExcludeFromFee(pool.address);
    await pool.setMainToken(zhiToken.address);
    await pool.setHavestDelay(3*3600);
    await pool.setFefTrxPair("TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR");
    await pool.setHtuTrxPair("TLkef9VYtmHG3oAi4neG75WMEnwhTmvsFB");
    console.log("Pool init end 3.")

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

    let zhiToken = await ERC20ZhiToken.deployed();
    let muToken = await ERC20MuToken.deployed();
    let pool = await MuTokenPool.deployed();
    console.log(muToken.address);
    console.log(zhiToken.address);
    console.log(pool.address);
    console.log("Pool init start.")
    await zhiToken.transfer(pool.address, "2700000000000"); // 2880000000000
    await zhiToken.transfer(accounts, "100000000000");
    // await zhiToken.transfer(liquidAddress, "6666000000");
    // await zhiToken.transfer(daoUnionAddress, "2222000000");
    // // pool.addPool(rate, token, isLp, dayNum, withUpdate);
    console.log("balance: ", (await zhiToken.balanceOf(pool.address)).toString());
    console.log("Pool init 2.")
    await pool.addPool(1000, muToken.address, zeroAddress, true, 3*24*1200, false);

    await zhiToken.setExcludeFromFee(pool.address);
    await pool.setMainToken(zhiToken.address);
    await pool.setBeneficience("TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ");
    await pool.setInviteEnable(true);
    await pool.setHavestDelay(6*3600);
    // transfer to myself
    // await muToken.transfer(accounts, "120000000000");
    // Transfer to royi
    await muToken.transfer("TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ", "200000000000");
    await muToken.transfer("TMCRYS9b71UszCHukC5xACDceEuCN12xjr", "100000000000");
    await muToken.transfer("TUFi19U1qm1Nvgrb3ciyXGbpcK5uZEPEAG", "100000000000");
    await muToken.transfer("TAKvaFEUEgZ8S5qcdJDNnUaWKrYawT17UB", "100000000000");
    await muToken.transfer("TXynF4tteSE6aQis6JH6sskEVfcKQk9pRt", "100000000000");
    await muToken.transfer("TBejHKVbmf1ETaf2XWRwWwAoJSZ57SK6Yg", "100000000000");
    await muToken.transfer("TB3sGzPZ5fCdP1Np1AdWYBu4eRtkNNBEvn", "100000000000");
    await muToken.transfer("TV1ZW8z2kAQzfvT3XCmB5FJZ7KNQQLnVby", "100000000000");

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
