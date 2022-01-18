// migrations/2_deploy.js
// SPDX-License-Identifier: MIT
const ERC20PresetFixedSupply = artifacts.require("ERC20PresetFixedSupply");
const ERC20ZhiToken = artifacts.require("ERC20ZhiToken");
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
  
  if (network == "mainnet") {
    lpToken1 = 'TU6wBBaPfNxwf5WgS1yEfspWohkoJLXZW2';
    lpToken2 = 'TU6wBBaPfNxwf5WgS1yEfspWohkoJLXZW2';
  }
  else if (network == "shasta") {
    // WUSDT = "0xc350c613e1c1f8e90f662ccbaf24cd32fe0ebc0b";
    // BUSDT = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t";
    // FEFPairAddress = "TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR";
    // USDTPairAddress = "TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE";
    // blackHoleAddress = "T9yD14Nj9j7xAB4dbGeiX9h8upfCg3PBbY";
    lpToken1 = 'TFr3sJ8sG43byX78GjYqNdKThRNwTs1oL3';
    lpToken2 = 'TQk9Y7oQV3mbqoxbWx5UkGUXyDtkGYdtEG';
    // let zhiToken = await ERC20PanToken.at("0x3aF28Da6a016143a9DCa040eC8632D88fAA1cfd2");
  }

  else if (network == "development") {
    // WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
    // WUSDT = "0xc350c613e1c1f8e90f662ccbaf24cd32fe0ebc0b";
    // BUSDT = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t";
    // FEFPairAddress = "TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR";
    // USDTPairAddress = "TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE";
    // blackHoleAddress = "T9yD14Nj9j7xAB4dbGeiX9h8upfCg3PBbY";
    lpToken1 = 'TU6wBBaPfNxwf5WgS1yEfspWohkoJLXZW2';
    lpToken2 = 'TU6wBBaPfNxwf5WgS1yEfspWohkoJLXZW2';
  }

  console.log("5: ZhiToken Pool init start.")
  console.log("accounts", accounts);

  let hcToken = await ERC20HCToken.deployed();
  let pool = await ZhiTokenPool.deployed(); 
  
  // 发行总量：10000枚
  // HTU66/LP：4000枚
  // FEF/LP：1000枚
  // NFT：3500枚
  // Community Pool: 1000
  // Fund base: 400 + 100
  // 全部挖矿产出：288万枚

  communityAddress = "TWRBkJ6R1q87SSp8YMcsiGXEUfDGKysagw";
  nftMarketAddress = "TWRBkJ6R1q87SSp8YMcsiGXEUfDGKysagw"; // my test 6
  fundbaseAddress  = "TUFi19U1qm1Nvgrb3ciyXGbpcK5uZEPEAG"; // ruoyi
  await hcToken.transfer(pool.address,     "5000000000"); // lp 4000 + 1000
  await hcToken.transfer(communityAddress, "1000000000");
  await hcToken.transfer(nftMarketAddress, "3500000000");
  await hcToken.transfer(fundbaseAddress,   "500000000");

  // pool.addPool(_startBlock, _totalBlock, _totalHC, _token);
  startBlock = 37295168;
  totalBlock = 1200 * 24 * 90;
  delayBlock = 1200 * 24 * 60;
  totalRewardHC1 = 4000 * 10**6;
  totalRewardHC2 = 1000 * 10**6;
  
  await pool.addPool(startBlock, totalBlock, delayBlock, totalRewardHC1, lpToken1);
  await pool.addPool(startBlock, totalBlock, delayBlock, totalRewardHC2, lpToken2);
  await pool.setMainToken(hcToken.address);
  // await pool.setHavestDelay(1200 * 24 * 60);

  await pool.setFefTrxPair("TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR");
  pool.setActive(true);

  console.log("5: ZhiToken Pool init end.")
};


function toTimestamp(strDate){
  var datum = Date.parse(strDate);
  return datum/1000;
}
