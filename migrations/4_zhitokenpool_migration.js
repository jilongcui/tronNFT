// migrations/2_deploy.js
// SPDX-License-Identifier: MIT
const ERC20PresetFixedSupply = artifacts.require("ERC20PresetFixedSupply");
const ERC20HCToken = artifacts.require("ERC20HCToken");
const ERC20ZhiToken = artifacts.require("ERC20ZhiToken");
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
  let airdropAddress = accounts[4];
  let beneficancy = accounts[5];

  let WBNB = "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd";
  let WUSDT = "0xc350c613e1c1f8e90f662ccbaf24cd32fe0ebc0b";

  
  if (network == "mainnet") {
    USDTAddress = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t";
    FEFPairAddress = "TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR";
    USDTPairAddress = "TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE";
    beneficancy = "TQTxerYaSaR8XHh5mBL4H6A3gktM5Kwanw";
    blackHoleAddress = "T9yD14Nj9j7xAB4dbGeiX9h8upfCg3PBbY";
    airdropAddress = "TB7Jei89VMW5B3DmifmSGd8HD1Pwtnb62J";

    console.log("accounts", accounts);
  }

  else if (network == "shasta") {
    WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
    WUSDT = "0xc350c613e1c1f8e90f662ccbaf24cd32fe0ebc0b";
    BUSDT = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t";
    FEFPairAddress = "TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR";
    USDTPairAddress = "TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE";
    beneficancy = "TDSdiemNFgaPA6EqWBbCZsPiCmQNiVVZvJ";
  }

  else if (network == "development") {
    WBNB = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
    WUSDT = "0xc350c613e1c1f8e90f662ccbaf24cd32fe0ebc0b";
    BUSDT = "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t";
    FEFPairAddress = "TThQqQjsWvhRNhgHR7MaH8fy7j9njuzQUR";
    USDTPairAddress = "TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE";
    blackHoleAddress = "T9yD14Nj9j7xAB4dbGeiX9h8upfCg3PBbY";
    console.log("accounts", accounts);
  }
  // ???????????????10000???
  // HTU66/LP???4000???
  // FEF/LP???1000???
  // NFT???3500???
  // Community Pool: 1000
  // Fund base: 400 + 100

  console.log("4. Pool init start.")
  // let startTimestamp = toTimestamp("2021-09-18 21:00:00");
  console.log("4. accounts", accounts);
  // initSupply = 0;
  // deployer.deploy(ERC20PresetFixedSupply, 'LPToken', 'LPToken', initSupply*100, accounts);
  let initSupply = 2888888;
    let lastRemainSupply = 188888;    
    let initMuSupply = 1000000;
    let totalReward = "2880000000000";
    // deployer.deploy(ERC20ZhiToken, airdropAddress, initSupply, lastRemainSupply, accounts);
  initSupply = 0; // HC Token 
  deployer.deploy(ERC20HCToken, initSupply, accounts);
  deployer.deploy(ZhiTokenPool);
  await sleep(5000);
  console.log("4. Pool init end.")
};

function toTimestamp(strDate){
  var datum = Date.parse(strDate);
  return datum/1000;
}
