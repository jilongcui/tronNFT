// migrations/2_deploy.js
// SPDX-License-Identifier: MIT
const ERC20PresetFixedSupply = artifacts.require("ERC20PresetFixedSupply");
const ERC20ZhiToken = artifacts.require("ERC20ZhiToken");
const ERC20MuToken = artifacts.require("ERC20MuToken");
const PantheonIDO = artifacts.require("PantheonIDO");
const ERC20HCToken = artifacts.require("ERC20HCToken");
const ZhiTokenPool = artifacts.require("ZhiTokenPool");

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
  let lpToken1 = {}, lpToken2={};
  let startBlock;

  console.log("5: ZhiToken Pool init start.")
  console.log("accounts", accounts);

  // let lpToken = await ERC20PresetFixedSupply.deployed();
  let hcToken = await ERC20HCToken.deployed();
  let pool = await ZhiTokenPool.deployed(); 
  
  console.log(pool.address);
  // console.log(lpToken.address);
  console.log(hcToken.address);
  
  if (network == "mainnet") {
    // lpToken1.address = 'TPLyqfL19msuMh8Kan2XmG4svxZsdn5uk9'; //lpToken1
    // lpToken2.address = 'TF9nMp1pDFCm9ZahrGppydfhBRDC28kDU6'; //lpToken2
    lpToken1.address = 'TD1zWA8STBocignyvRfuEkwEErM2AjkAof';
    lpToken2.address = 'TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR';
    
    startBlock = 37598417; // 11:18 开始测试
  }
  else if (network == "shasta") {
    lpToken1.address = lpToken.address;
    lpToken2.address = lpToken.address;
    // startBlock = 0; // from now.
    startBlock = 21708300; //
  }
  else if (network == "development") {
    lpToken1.address = lpToken.address;
    lpToken2.address = lpToken.address;
    startBlock = 0;
  }

  // 发行总量：10000枚
  // HTU66/LP：4000枚
  // FEF/LP：1000枚
  // NFT：3500枚
  // Community Pool: 1000
  // Fund base: 400 + 100
  try {
    
    let totalRewardHC1 = 4000 * 10**6;
    let totalRewardHC2 = 1000 * 10**6;
    if (network !== "bsc") {
      // totalBlock = 1200 * 24 * 150; // 150
      delayBlock = 1200 * 24 * 60; // 延迟释放60
      cycleBlock = 1200 * 24 * 90; // 释放周期90天
    }

    // test1Address = "TV1ZW8z2kAQzfvT3XCmB5FJZ7KNQQLnVby"; // hong
    // test2Address = "TWRBkJ6R1q87SSp8YMcsiGXEUfDGKysagw"; // my test 6
    // test3Address  = "TUFi19U1qm1Nvgrb3ciyXGbpcK5uZEPEAG"; // ruoyi
    if (network === "mainnet") {
      // let zhiToken1 = tronWeb.contract().at("TDUm9wWovtmFUeA3x8Y5kvHvJpgf3PJ6DV");
      // let zhiToken1 = await ERC20ZhiToken.deployed();
      //   await zhiToken1.transfer(test1Address, "1000000000");
      //   await zhiToken1.transfer(test2Address, "1000000000");
      //   await zhiToken1.transfer(test3Address, "1000000000");
      //   await zhiToken1.transfer("THd4Wv4MgpUUEqep7F5YwGfgDjwZwudFng", "1000000000");
      //   await zhiToken1.transfer("TJHWE49hKzTVU63QFusEXKLFjN8AE1o6ZK", "1000000000");
      //   await zhiToken1.transfer("TGvKuG5PfGJfXs61aodfqRahBGhJJH9sQh", "1000000000");
      //   await zhiToken1.transfer("THgEtyu4TtRDcJYiqNP4m2TZFSnpTNMXRX", "1000000000");

        // let muToken2 = await ERC20MuToken.deployed();
        // // let muToken2 = tronWeb.contract().at("TEazWQJhgUcGfbPJZxhxJKaeXmmcGR8v3B");
        // await muToken2.transfer(test1Address, "1000000000");
        // await muToken2.transfer(test2Address, "1000000000");
        // await muToken2.transfer(test3Address, "1000000000");
        // await muToken2.transfer("THd4Wv4MgpUUEqep7F5YwGfgDjwZwudFng", "1000000000");
        // await muToken2.transfer("TJHWE49hKzTVU63QFusEXKLFjN8AE1o6ZK", "1000000000");
        // await muToken2.transfer("TGvKuG5PfGJfXs61aodfqRahBGhJJH9sQh", "1000000000");
        // await muToken2.transfer("THgEtyu4TtRDcJYiqNP4m2TZFSnpTNMXRX", "1000000000");
    }

    communityAddress = "TXpZWLXwJfmVzerNTUfeLErVk6PsnCoSrb"; //
    nftMarketAddress = "TWRBkJ6R1q87SSp8YMcsiGXEUfDGKysagw"; //
    fundbaseAddress  = "TPqW9bYzmkfdugoWbB97ATiuzkP4bz9vqs"; //
    groupAddress  = "TJMZumEL9LvFtSQADfXQFDLK5n9iGkDFNT"; //
    await hcToken.mint(pool.address,     "5000000000"); // lp 4000 + 1000
    if (network !== "development") {
      await hcToken.mint(communityAddress, "1000000000");
      await hcToken.mint(nftMarketAddress, "3500000000");
      await hcToken.mint(fundbaseAddress,   "400000000");
      // await hcToken.mint(groupAddress,      "100000000");
    }
    hcToken.grantRole('0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6',pool.address)
    await pool.addPool(startBlock, cycleBlock, delayBlock, totalRewardHC1, lpToken1.address);
    await pool.addPool(startBlock, cycleBlock, delayBlock, totalRewardHC2, lpToken2.address);
    await pool.setMainToken(hcToken.address);
    await pool.setActive(true);
  } catch (error) {
    console.error(error);
  }
  

  console.log("5: ZhiToken Pool init end.")
};


function toTimestamp(strDate){
  var datum = Date.parse(strDate);
  return datum/1000;
}
