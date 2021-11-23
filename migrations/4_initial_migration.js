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
    let lastRemainSupply = 188888;
    
    // let startTimestamp = toTimestamp("2021-09-18 21:00:00");
    let startTimestamp = "1632574800";
    let totalReward = "2880000000000";
    let startBlock = 35277657;
    // deployer.deploy(ERC20ZhiToken, airdropAddress, initSupply, lastRemainSupply, startTimestamp, accounts);
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
    await muToken.mint(accounts, "1000000000000");
    // let balance = await muToken.balanceOf(accounts);
    // console.log("account 0 balance", balance.toNumber());
    
    await muToken.transfer("TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ", "200000000000");
    await muToken.transfer("TMCRYS9b71UszCHukC5xACDceEuCN12xjr", "100000000000");
    await muToken.transfer("TUFi19U1qm1Nvgrb3ciyXGbpcK5uZEPEAG", "100000000000");
    await muToken.transfer("TAKvaFEUEgZ8S5qcdJDNnUaWKrYawT17UB", "100000000000");
    await muToken.transfer("TXynF4tteSE6aQis6JH6sskEVfcKQk9pRt", "100000000000");
    await muToken.transfer("TBejHKVbmf1ETaf2XWRwWwAoJSZ57SK6Yg", "100000000000");
    await muToken.transfer("TB3sGzPZ5fCdP1Np1AdWYBu4eRtkNNBEvn", "100000000000");
    await muToken.transfer("TV1ZW8z2kAQzfvT3XCmB5FJZ7KNQQLnVby", "100000000000");

    // let info;
    // info = await pool.getInviteInfo("TLQKY5RJnHUkRoeQJAdM34g4mtQp1ZZvnL");
    // console.log(info);

    // info = await pool.getInviteInfo("TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ");
    // console.log(info);

    // info = await pool.getInviteInfo("TXynF4tteSE6aQis6JH6sskEVfcKQk9pRt");
    // console.log(info);
    // console.log("------------")
    // info = await pool.minerInfo(0, "TLQKY5RJnHUkRoeQJAdM34g4mtQp1ZZvnL");
    // console.log(info);
    // info = await pool.minerInfo(0, "TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ")
    // console.log(info);
    // info = await pool.minerInfo(0, "TXynF4tteSE6aQis6JH6sskEVfcKQk9pRt")
    // console.log(info);
    // await zhiToken.transfer(blackHoleAddress, "158000000");

    // let pool = await MuTokenPool.deployed();
    // console.log(pool.address);
    // await sleep(5000);
    // await deployer.deploy(MuTokenPool, "TMzAxhn1ZgvBR4RsdeVPq6qhUg5svcjaox", FEFPairAddress, USDTPairAddress, inviteAddress, airdropAddress, beneficancy, startBlock, totalReward);
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
    // // // pool.addPool(rate, token, isLp, dayNum, withUpdate);
    // console.log("balance: ", (await zhiToken.balanceOf(pool.address)).toString());
    // console.log("Pool init 2.")
    // await pool.addPool(1000, muToken.address, zeroAddress, true, 3*24*1200, false);

    // await zhiToken.setExcludeFromFee(pool.address);
    // await pool.setMainToken(zhiToken.address);
    // await pool.setBeneficience("TXynF4tteSE6aQis6JH6sskEVfcKQk9pRt");
    // // await pool.setInviteEnable(false);
    // // transfer to myself
    // await muToken.transfer(accounts, "120000000000");
    // // Transfer to royi
    // await muToken.transfer("TUFi19U1qm1Nvgrb3ciyXGbpcK5uZEPEAG", "130000000000");


    const minerInfo = await pool.minerInfo(0, accounts);
    const reward = await pool.pendingReward(0, accounts);
    console.log(minerInfo);
    console.log(reward);
    // const approve = await zhiToken.approve(pool.address, "1000000000000", {from: accounts})
    // const deposit = await pool.deposit(0, 1000000, {callValue: 10000000, from: accounts});
    // console.log(minerInfo);
    // console.log(approve);
    // // const deposit = await pool.call("deposit", 0, "1000000", {value: "1000000"})
    // console.log(deposit);
    // // await pool.updateReward();
    // const minerInfo2 = await pool.minerInfo(0, accounts);
    // console.log(minerInfo2);

    // const balance = (await  zhiToken.balanceOf(pool.address)).toString();
    // console.log(balance);
    // assert.equal(minerInfo2.power.toString(), minerInfo.power.toNumber() + 2000000);
    // await wait(15);

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
    deployer.deploy(ERC20ZhiToken, airdropAddress, initSupply, lastRemainSupply, startTimestamp, accounts);
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
