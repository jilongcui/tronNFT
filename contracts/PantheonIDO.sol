// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/math/SafeMath.sol";
import "./utils/Address.sol";
import "./access/Ownable.sol";
import "./token/ERC20/IERC20.sol";

contract PantheonIDO is Ownable{

  // 1BNB = 400U
  // 1BNB = 1600PAN
  // 1PAN = 10^6wei
  // 1ETH = 10^18wei
  uint MIN_DEPOSITE = 1*10**16; // 0.01
  uint MAX_DEPOSITE_ETH = 0.125*10**18; // ether; //50U=200PAN
  uint MAX_DEPOSITE_PAN = 1*10**18; //10**12
  uint TOTAL_PAN_SUPPLY = 40*10**10; // 40*10^10 400000
  uint TOTAL_ETH_SUPPLY = 250*10**18; // 250ETH
  uint MIN_PAN_CLAIM = 1*10**6; // 1 PAN

  enum IdoStatus{
    IDO_START,
    IDO_END,
    IDO_CLAIM_START,
    IDO_CLAIM
  }

  struct Idoer {
    uint ethValue;
    uint panValue;
    // uint timestamp;
    bool claimed;
  }

  // struct IdoerLog {
  //   address addr;
  //   uint ethValue;
  //   uint panValue;
  //   uint timestamp;
  // }

  using SafeMath for uint;

  event IdoProcessEvent(uint remain, uint total);
  event IdoStateEvent(IdoStatus status);

  // 发布者
  address public chairperson;
  // 受益者
  address public beneficancy;
  // IdoerLog[] public idoerLogs;
  // 剩余供应
  uint public remainSupply;
  // 开始时间戳
  uint public idoStartTimestamp;
  // 结束时间戳
  uint public idoEndTimestamp;
  // 领取时间戳
  uint public claimStartTimestamp;
  // 结束领取时间戳
  uint public claimEndTimestamp;

  // 代币的地址
  address payable public erc20Address;
  
  // token对象
  IERC20 public token;
  // 新的IDO地址，用户领取状态
  mapping(address => Idoer) public idoers;
  // 构建函数，代币地址，受益者地址
  // ido 开始时间、结束时间、可以领取时间、领取结束时间
  constructor(address payable erc20Address_,
    address beneficancy_,
    uint idoStart_,
    uint idoEnd_,
    uint claimStart_,
    uint claimEnd_
    ) payable {
  	chairperson = msg.sender;
  	remainSupply = TOTAL_ETH_SUPPLY;
    beneficancy = beneficancy_;
    erc20Address = erc20Address_;
    idoStartTimestamp = idoStart_;
    idoEndTimestamp = idoEnd_;
    claimStartTimestamp = claimStart_;
    claimEndTimestamp = claimEnd_;
  	token = IERC20(erc20Address);
  }
  
  function setTokenAddress(address payable erc20Address_) public onlyOwner{
    require(erc20Address_ != address(0));
     erc20Address = erc20Address_;
     token = IERC20(erc20Address);
  }

  function setIdoTime(uint start, uint end) public onlyOwner{
    idoStartTimestamp = start;
    idoEndTimestamp = end;
  }

  function setClaimTime(uint start, uint end) public onlyOwner{
    claimStartTimestamp = start;
    claimEndTimestamp = end;
  }

  // 发送Eth进行IDO
  // 本质是通过这个函数发送ETH，然后得到的对应代币的数量，这些记录在链上。
  function sendEthForIdo() payable public returns (bool){
    uint timestamp = block.timestamp;
    require(msg.value <= remainSupply, "No remain supply");
    require(msg.value >= MIN_DEPOSITE, "IDO value should big than 0.1ETH");
    require(msg.value <= MAX_DEPOSITE_ETH, "IDO value should less than 4ETH");
    require(idoers[msg.sender].ethValue + msg.value <= MAX_DEPOSITE_ETH, "IDO total value should less than 4ETH");
    require(timestamp >= idoStartTimestamp && timestamp < idoEndTimestamp, "IDO stopped");

    Idoer memory idoer = idoers[msg.sender];

    uint value = msg.value;
    uint panValue = value.mul(1600).div(10**12);
    remainSupply = remainSupply.sub(value);

    uint newValue = idoer.ethValue + value;
    uint newPanValue = idoer.panValue + panValue;
    idoers[msg.sender] = Idoer({
      ethValue: newValue,
      panValue: newPanValue,
      claimed: false
    });
  	payable(beneficancy).transfer(value);

    emit IdoProcessEvent(remainSupply, TOTAL_ETH_SUPPLY);
    // idoerLogs.push(IdoerLog({
    //   addr: address(msg.sender),
    //   ethValue: newValue,
    //   panValue: panValue,
    //   timestamp: timestamp
    // }));
    return true;
  }
  
  function release() public  onlyOwner {
      payable(chairperson).transfer(address(this).balance);
      token.transfer(chairperson, token.balanceOf(address(this)));
  }
  
  // claim
  function claimFromIdo() public returns (bool){
    uint timestamp = block.timestamp;
  	require(timestamp >= claimStartTimestamp); //  && timestamp < claimEndTimestamp
    // require(token.balanceOf(address(this)) >= idoers[msg.sender].panValue, "PANIdo has invalid balance.");
  	
  	Idoer memory idoer = idoers[msg.sender];
  	// idoer = idoers[msg.sender];
  	
  	require(idoer.panValue >=10**6, "You need deposite fund first.");
  	require(!idoer.claimed, "You already claimed");
    // require(idoer.panValue >= MIN_PAN_CLAIM, "Claim value should big than 1PAN");
    
    uint value = idoer.panValue;
    idoer.claimed = true;
    
    token.transfer(msg.sender, value);
    // idoer.panValue = idoer.panValue.sub(value);
    idoer.panValue = 0;
    idoers[msg.sender] = idoer;
    return true;
  }

  function isIdoEnable() public view returns(bool) {
    uint timestamp = block.timestamp;
    if (timestamp >= idoStartTimestamp && timestamp < idoEndTimestamp)
      return true;
    else
      return false;
  }

  function isClaimEnable() public view returns(bool) {
    uint timestamp = block.timestamp;
    if (timestamp >= claimStartTimestamp && timestamp < claimEndTimestamp)
      return true;
    else
      return false;
  }

  function getIdoRemainSupply() public view returns(uint,uint) {
    return (remainSupply, TOTAL_ETH_SUPPLY);
  }

  function getIdoRemainEth() public view returns(uint, uint) {
    return (idoers[msg.sender].ethValue, MAX_DEPOSITE_ETH);
  }

  function getIdoRemainPAN() public view returns(uint, uint) {
    return (idoers[msg.sender].panValue, MAX_DEPOSITE_PAN);
  }

  function getIdoReleaseDate() public view returns(bool, uint) {
    return (block.timestamp >= claimStartTimestamp, claimStartTimestamp);
  }

}
