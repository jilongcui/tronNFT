// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/math/SafeMath.sol";
import "./utils/Address.sol";
import "./access/Ownable.sol";
import "./token/ERC20/IERC20.sol";
import "./BeanPool.sol";

contract BeanInviteReward is Ownable{

  uint TOTAL_PAN_SUPPLY = 40*10**10; // 40*10^10 400000
  uint MIN_PAN_CLAIM = 1*10**6; // 1 PAN
  uint MIN_CLAIM_TIMEOFF = 24* 3600; // 1Day

  struct Reward {
    uint lastAmount;
    uint extraReward;
    uint lastClaimTime;
  }

  using SafeMath for uint;
  // 发布者
  address public chairperson;
  // 剩余供应
  uint public remainSupply;
  // Token对象
  IERC20 public token;
  // Pool token
  address public poolAddress;
  // Claim is enabled
  bool public claimEnabled;
  // 新的IDO地址，用户领取状态
  mapping(address => Reward) public rewardInfo;
  // Event
  event RewardClaimedEvent(uint amount, uint totalReward, uint timestamp);

  // 构建函数，代币地址，受益者地址
  // ido 开始时间、结束时间、可以领取时间、领取结束时间
  constructor(
    address payable erc20Address_,
    address poolAddress_
    ) payable {
  	chairperson = msg.sender;
  	remainSupply = TOTAL_PAN_SUPPLY;
  	token = IERC20(erc20Address_);
    poolAddress = poolAddress_;
    claimEnabled = true;
  }
  
  function setTokenAddress(address erc20Address_) public onlyOwner{
    require(erc20Address_ != address(0));
     token = IERC20(erc20Address_);
  }

  function setPoolAddress(address address_) public onlyOwner{
    require(address_ != address(0));
    require(address_ != address(this));
    require(address_ != msg.sender);
    poolAddress = address_;
  }

  function setClaimEnabled(bool enable) public onlyOwner {
    claimEnabled = enable;
  }

  function setExtraReward(address user, uint amount) public onlyOwner {
    Reward memory reward = rewardInfo[user];
    reward.extraReward += amount;
    rewardInfo[user] = reward;
  }
  
  function release() public  onlyOwner {
      token.transfer(chairperson, token.balanceOf(address(this)));
      payable(chairperson).transfer(address(this).balance);
  }
  
  // claim
  function claimFromInvite() public returns (bool){
  	require(claimEnabled, "The claim is disable.");
  	Reward memory reward = rewardInfo[msg.sender];
    
    // Get current reward info from Pool address
    uint timestamp = block.timestamp;
    // require(timestamp.sub(reward.lastClaimTime) >= MIN_CLAIM_TIMEOFF, "You claim too frequency.");
    
    // Transfer
    BeanPool poolContract = BeanPool(poolAddress);
    uint totalReward = poolContract.inviteReward(msg.sender);
    totalReward = totalReward.add(reward.extraReward);
    uint amount = totalReward.sub(reward.lastAmount);
  	require(amount >=10e18, "The reward is little than 10 pan.");
    require(token.balanceOf(address(this)) >= amount, "Reward pool has invalid balance.");
    token.transfer(msg.sender, amount);
    reward.lastAmount = totalReward;
    reward.extraReward = 0;
    reward.lastClaimTime = timestamp;
    rewardInfo[msg.sender] = reward;
    emit RewardClaimedEvent(amount, totalReward, timestamp);
    return true;
  }

  function getClaimInfo(address user) public view returns(uint,uint) {
    Reward memory reward = rewardInfo[user];
    BeanPool poolContract = BeanPool(poolAddress);
    uint totalReward = poolContract.inviteReward(user);
    totalReward = totalReward.add(reward.extraReward);
    uint amount = totalReward.sub(reward.lastAmount);
    return (amount, totalReward);
  }

  function isClaimEnabled() public view returns(bool) {
    return claimEnabled;
  }

}
