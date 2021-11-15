// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/math/SafeMath.sol";
import "./utils/Address.sol";
import "./access/Ownable.sol";

import "./token/ERC20/IERC20.sol";
import "./token/ERC20/utils/SafeERC20.sol";


// FEFPool is the master of Reward. He can make Reward and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once CHA is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MuTokenPool is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Miner information describe miner. One should has many Miners;
    struct MinerInfo {
        uint256 amount; // Fund
        uint256 power; // power
        uint256 invitePower; // Invite power
        uint256 pendingReward; // Pending reward
        uint256 rewardDebt; // Reward debt. See explanation below.
    }
    // Info of each pool. pool is set manully.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        IERC20 lpToken2; // Address of LP token contract.
        bool isInternal; // if isInternal is true we should have a usdt token.
        uint32 timeBlocks; // timeBlocks;
        uint256 powerRate; // The power rate assigned to this pool. times 1000.
    }
    
    uint256 public lastRewardBlock; // Last block number that CHAs distribution occurs.
    uint256 public accChaPerShare; // Accumulated CHAs per share, times 1e12. See below.
    // Total power
    uint256 public totalPower;

    // Invite
    bool public inviteForce = false;
    uint8 public maxInviteLayer = 2;
    // The main TOKEN!
    IERC20 public mainToken;
    // Dev address.
    address public blackholeAddress;
    address public airdropAddress;
    address public beneficience;
    // Total reward for miner
    uint256 public totalReward;
    // Total released reward
    uint256 public releasedReward;
    uint256 public destroyFefAmount;
    // tokens minted per block.
    uint256 public chaPerBlock;
    uint256 fefDivder = 100;
    uint256 htuDivder = 5;
    uint256 usdtDivder = 10;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(address => uint256) public userPower;
    mapping(address => uint256) public groupPower;
    mapping(address => address) public userParent;
    mapping(address => uint16) public inviteCount;
    uint8[] inviteRatio = [8, 3, 0];
    mapping(uint256 => mapping(address => MinerInfo)) public minerInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when CHA mining starts.
    uint256 public initBlock;
    uint256 public baseBlock;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event InviteUser(address indexed parent, address indexed child, uint256 timestamp);

    constructor(
        address _initInviteAddress,
        address _airdropAddress,
        address _beneficience,
        uint256 _initBlock,
        uint256 _totalReward
    ) {
        airdropAddress = _airdropAddress;
        beneficience = _beneficience;
        chaPerBlock = 7819444;
        blackholeAddress = address(0x000000000000000000000000000000000000dEaD);
        
        totalReward = _totalReward;
        lastRewardBlock =
            block.number > _initBlock ? block.number : _initBlock;
        initBlock = lastRewardBlock;
        baseBlock = lastRewardBlock;
        // totalAllocPoint = totalAllocPoint.add(_allocPoint);
        userParent[_initInviteAddress] = msg.sender;
        totalPower = 0;
    }

    function releaseReward() external view returns (uint256) {
        return totalPower.mul(accChaPerShare).div(1e12);
    }

    function remainReward() external view returns (uint256) {
        return totalReward - releasedReward;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function addPool(
        uint256 _powerRate,
        IERC20 _token,
        IERC20 _token2,
        bool _isInternal,
        uint32 timeBlocks,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            updateReward();
        }
        
        poolInfo.push(
            PoolInfo({
                lpToken: _token,
                lpToken2: _token2,
                isInternal: _isInternal,
                timeBlocks: timeBlocks,
                powerRate: _powerRate
            })
        );
    }

    function setInvite(
        address parent
    ) public {
        require(userParent[msg.sender] == address(0), "You already be invited.");
        require(userParent[parent] != address(0), "Parent should be invite first.");
        require(parent != msg.sender, "You cannot invite yourself.");
        userParent[msg.sender] = parent;
        inviteCount[parent] = inviteCount[parent] + 1;
        emit InviteUser(parent, msg.sender, block.timestamp);
    }

    function setInviteEnable(
        bool enable
    ) public {
        inviteForce = enable;
    }

    function setMaxInviteLayer(uint8 layer) public {
        maxInviteLayer = layer;
    }

    function setBeneficience(
        address _beneficience
    ) public onlyOwner{
        beneficience = _beneficience;
    }

    function setMainToken(
        address _token
    ) public onlyOwner{
        mainToken = IERC20(_token);
    }

    function getInviteInfo(address addr) public view returns (uint16, uint256, uint256, address){
        return (inviteCount[addr], userPower[addr], groupPower[addr], userParent[addr]);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }

    // View function to see pending CHA on frontend.
    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        // PoolInfo storage pool = poolInfo[_pid];
        MinerInfo memory miner = minerInfo[_pid][_user];
        uint256 accCha = accChaPerShare;
        uint256 power = miner.power.add(miner.invitePower);
        uint256 rewardDebt = miner.rewardDebt;
        
        // calculate new pendingReward
        if (power != 0 && block.number > lastRewardBlock && totalPower != 0) {
            uint256 chaReward = calculateReward();
            accCha = accCha.add(
                chaReward.mul(1e12).div(totalPower)
            );
        }
        return miner.pendingReward.add(power.mul(accCha).div(1e12).sub(rewardDebt));
    }

    // Update reward variables of the given pool to be up-to-date.
    function updateReward() public {
        // PoolInfo storage pool = poolInfo[_pid];
        // uint256 remain = mainToken.balanceOf(address(this));
        uint256 remain = totalReward.sub(releasedReward);
        if (block.number <= lastRewardBlock || remain < 0 || totalPower == 0) {
            return;
        }
        uint256 chaReward = calculateReward();
        // mainToken.mint(address(this), chaReward);
        if ( remain < chaReward ) {
            chaReward = remain;
        }
        releasedReward  = releasedReward.add(chaReward);
        if(block.number >= baseBlock.add(24*1200*100)) {
            baseBlock = block.number;
        }
        accChaPerShare = accChaPerShare.add(
            chaReward.mul(1e12).div(totalPower)
        );
        lastRewardBlock = block.number;
    }

    function calculateReward() private view returns(uint256){
        uint256 lastBlock = lastRewardBlock.sub(baseBlock);
        uint256 endBlock = block.number.sub(baseBlock);
        uint256 multiplier = getMultiplier(lastBlock, endBlock);
        uint256 reward = multiplier.mul(chaPerBlock).div(1000);
        return reward;
    }

    function getGlobalPoolInfo(uint256 pid) public view returns(uint256, uint256, uint256, uint256, uint256, uint256) {
        uint256 fefPrice = getFefValue(1e8);
        uint256 htuPrice = getHtuValue(1e6);
        uint256 destoryAmountOfFef = destroyFefAmount;
        uint256 releasedPerDayOfHtu = getMintHtuPerday();
        uint256 releasedTotalOfHtu = getReleasedTotalOfHtu();
        uint256 destoryTotalOfHtu = mainToken.balanceOf(blackholeAddress);
        return (fefPrice, htuPrice, destoryAmountOfFef, releasedPerDayOfHtu, releasedTotalOfHtu,destoryTotalOfHtu);
    }

    function getMintHtuPerday() internal view returns(uint256) {
        uint256 countBlock = block.number.sub(baseBlock);
        uint256 countDay = countBlock.div(24*1200);
        uint256 amount = 225200;
        return amount.add(countDay.mul(5000));
    }

    function getReleasedTotalOfHtu() internal view returns(uint256) {
        uint256 chaReward = calculateReward();
        return releasedReward.add(chaReward);
    }

    // Deposit LP tokens to FEFPool for CHA allocation.
    function deposit(uint256 _pid, uint256 _amount) payable public returns (bool){
        updateReward();
        PoolInfo storage pool = poolInfo[_pid];
        MinerInfo memory miner = minerInfo[_pid][msg.sender];
        
        if (inviteForce == true) {
            require(userParent[msg.sender] != address(0), "You need be invited first.");
        }
        if (miner.amount > 0) {
            uint256 pending =
                miner.power.add(miner.invitePower).mul(accChaPerShare).div(1e12).sub(
                    miner.rewardDebt
                );
            miner.pendingReward = miner.pendingReward.add(pending);
        }
        
        pool.lpToken.transferFrom(
            address(msg.sender),
            address(blackholeAddress),
            _amount
        );
        destroyFefAmount = destroyFefAmount.add(_amount);
        
        // Get trx amount
        uint256 ethAmount = getFefValue(_amount);
        require(msg.value >= ethAmount, "TRX amount is invalid");
        payable(beneficience).transfer(ethAmount);
        miner.amount = miner.amount.add(_amount);
        uint256 usdtAmount = getUsdtValue(ethAmount);
        require(usdtAmount >= 1e6, "Require depsit value big than 25U.");
        uint256 power = usdtAmount.mul(2);
        miner.power = miner.power.add(power);
        totalPower = totalPower.add(power);
        miner.rewardDebt = miner.power.add(miner.invitePower).mul(accChaPerShare).div(1e12);
        minerInfo[_pid][msg.sender] = miner;
        emit Deposit(msg.sender, _pid, _amount);

        return true;
    }

    // harvest LP tokens from FEFPool.
    function harvest(uint256 _pid) public {
        updateReward();
        MinerInfo storage miner = minerInfo[_pid][msg.sender];
        uint256 pending =
            miner.power.add(miner.invitePower).mul(accChaPerShare).div(1e12).sub(
                miner.rewardDebt
            );
        pending = miner.pendingReward.add(pending);
        require(pending > 0, "harvest: none reward");
        safeChaTransfer(msg.sender, pending);
        miner.rewardDebt = miner.power.add(miner.invitePower).mul(accChaPerShare).div(1e12);
        miner.pendingReward = 0;
        emit Harvest(msg.sender, _pid, pending);
    }

    // Safe mainToken transfer function, just in case if rounding error causes pool to not have enough CHA.
    function safeChaTransfer(address _to, uint256 _amount) internal {
        uint256 chaBal = mainToken.balanceOf(address(this));
        if (_amount > chaBal) {
            _amount = chaBal;
        }
        // mainToken.transfer(blackholeAddress, _amount.mul(7).div(100));
        // mainToken.transfer(airdropAddress, _amount.mul(1).div(100));
        // mainToken.transfer(_to, _amount.sub(_amount.mul(8).div(100)));
        mainToken.transfer(_to, _amount);
    }

    function getFefValue(uint256 amount) public view returns(uint256) {
        return amount.div(fefDivder); // 1FEF = 1TRX
    }

    function getHtuValue(uint256 amount) public view returns(uint256) {
        return amount.div(htuDivder); // HTU = 0.2TRX; 
    }

    function getUsdtValue(uint256 amount) public view returns(uint256) {
        return amount.div(usdtDivder); // 1TRX = 0.1U
    }

    function setFefDivder(uint256 amount) public onlyOwner  {
        fefDivder = amount;
    }

    function setHtuDivder(uint256 amount) public onlyOwner {
        htuDivder = amount;
    }

    function setUsdtDivder(uint256 amount) public onlyOwner {
        usdtDivder = amount;
    }

}