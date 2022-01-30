// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/math/SafeMath.sol";
import "./utils/Address.sol";
import "./access/Ownable.sol";

import "./token/ERC20/IERC20.sol";
import "./token/ERC20/extensions/ERC20Burnable.sol";
import "./token/ERC20/utils/SafeERC20.sol";
import './interfaces/IJustswapExchange.sol';

// interface IMigratorChef {
//     // Perform LP token migration from legacy UniswapV2 to ChaSwap.
//     // Take the current LP token address and return the new LP token address.
//     // Migrator should have full access to the caller's LP token.
//     // Return the new LP token address.
//     //
//     // XXX Migrator must have allowance access to UniswapV2 LP tokens.
//     // ChaSwap must mint EXACTLY the same amount of ChaSwap LP tokens or
//     // else something bad will happen. Traditional UniswapV2 does not
//     // do that so be careful!
//     function migrate(IERC20 token) external returns (IERC20);
// }

// ZhiToken is the master of Reward. He can make Reward and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once CHA is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract ZhiTokenPool is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // struct InviteInfo {
    //     address parent;
    //     uint256 totalPower;
    // }

    // Miner information describe miner. One should has many MinerInfos;
    struct MinerInfo {
        uint256 amount;      // 本金
        uint256 power;       // 算力
        uint256 pendingReward;
        uint256 harvestBlock;  // Reward debt. See explanation below.
        uint256 rewardDebt;  // Reward debt. See explanation below.
        uint256 startBlock;   // blocks for deposit cycle.;
        uint256 harvestReward;   // already released for owner.;
    }

    // Info of each pool. pool is set manully.
    struct PoolInfo {
        ERC20Burnable lpToken;      // Address of LP token contract.
        uint256 hcPerBlock;  // HC per block.
        uint256 accChaPerShare;
        uint256 totalReward;
        uint256 initBlock;
        uint256 delayBlock;
        uint256 totalPower;   // The power rate assigned to this pool. times 1000.
        uint256 releasedReward;
        uint256 lastRewardBlock;
        uint256 endRewardBlock;   // blocks for reward cycle.;
        uint256 endBlock;   // blocks for total miner cycle.;
    }
    
    PoolInfo[] public poolInfo;

    bool public active = true;

    ERC20Burnable public mainToken;
    address public blackholeAddress;

    mapping(uint256 => mapping(address => MinerInfo)) public minerInfo;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount, uint256 remain);
    event InviteUser(address indexed parent, address indexed child, uint256 timestamp);

    constructor(
    ) {
        blackholeAddress = address(0x000000000000000000000000000000000000dEaD);
    }

    function totalReward(uint256 _pid) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        return pool.totalReward;
    }

    function releasedReward(uint256 _pid) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        return pool.releasedReward;
    }

    modifier onlyInactive() {
        require(!active, "should inactive");
        _;
    }

    modifier onlyActive() {
        require(active, "should active");
        _;
    }

    function releaseReward(uint8 _pid) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        return pool.totalPower.mul(pool.accChaPerShare).div(1e12);
    }

    function remainReward(uint8 _pid) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        return pool.totalReward - pool.releasedReward;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function addPool(
        uint256 _startupBlock,
        uint256 _cycleBlock,
        uint256 _delayBlock,
        uint256 _totalReward,
        ERC20Burnable _lpToken
    ) public onlyOwner {
        uint256 totalBlock = _delayBlock.add(_cycleBlock);
        _startupBlock = _startupBlock < block.number?block.number: _startupBlock;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                hcPerBlock: _totalReward.div(_cycleBlock),
                totalReward: _totalReward,
                delayBlock: _delayBlock,
                endBlock: _startupBlock.add(totalBlock),
                endRewardBlock: _startupBlock.add(_cycleBlock),
                totalPower: 0,
                accChaPerShare: 0,
                releasedReward: 0,
                initBlock: _startupBlock,
                lastRewardBlock: _startupBlock < block.number?block.number: _startupBlock
            })
        );
    }

    // Update the given pool's CHA power rate. Can only be called by the owner.
    function setPool(
        uint256 _pid,
        uint256 _startBlock,
        uint256 _cycleBlock,
        uint256 _delayBlock,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            updateReward(_pid);
        }
        uint256 totalBlock = _delayBlock.add(_cycleBlock);
        _startBlock = _startBlock < block.number?block.number: _startBlock;
        poolInfo[_pid].hcPerBlock = poolInfo[_pid].totalReward.div(_cycleBlock);
        poolInfo[_pid].endRewardBlock = _startBlock.add(_cycleBlock);
        poolInfo[_pid].endBlock = _startBlock.add(totalBlock);
        poolInfo[_pid].lastRewardBlock = _startBlock;
        poolInfo[_pid].delayBlock = _delayBlock;
    }

    function setMainToken(
        address _token
    ) public onlyOwner{
        mainToken = ERC20Burnable(_token);
    }

    function setPoolDelay(
        uint256 _pid,
        uint256 delay,
        uint256 _totalBlock
    ) public onlyOwner{
        PoolInfo storage pool = poolInfo[_pid];
        pool.delayBlock = delay;
        pool.endBlock = pool.initBlock.add(_totalBlock);
    }

    function setActive (
        bool _active
    )public onlyOwner{
        active = _active;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }

    // Deposit LP tokens to BeanPool for CHA allocation.
    function deposit(uint256 _pid, uint256 _amount) payable public onlyActive returns (bool){
        updateReward(_pid);
        MinerInfo storage miner = minerInfo[_pid][msg.sender];
        PoolInfo storage pool = poolInfo[_pid];
        require(block.number >= pool.initBlock, "Not started.");
        require(block.number < pool.endRewardBlock, "Pool is end.");
        uint256 pending =
            miner.power.mul(pool.accChaPerShare).div(1e12).sub(
                miner.rewardDebt
            );
        miner.pendingReward = miner.pendingReward.add(pending);
        pool.lpToken.transferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 power = _amount;
        miner.startBlock = block.number;
        miner.harvestBlock = pool.initBlock.add(pool.delayBlock);
        miner.power = miner.power.add(power);
        miner.amount = miner.amount.add(power);
        pool.totalPower = pool.totalPower.add(power);
        miner.rewardDebt = miner.power.mul(pool.accChaPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);

        return true;
    }

    function pendingReward(uint256 _pid, address _user) external view returns (uint256, uint256)
    {
        MinerInfo memory miner = minerInfo[_pid][_user];
        PoolInfo memory pool = poolInfo[_pid];
        uint256 accCha = pool.accChaPerShare;
        uint256 power = miner.power;
        // calculate new pendingReward
        uint256 currentBlock = block.number < pool.endRewardBlock?block.number: pool.endRewardBlock;
        if (power != 0 && currentBlock > pool.lastRewardBlock && pool.totalPower != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, currentBlock);
            uint256 chaReward = multiplier.mul(pool.hcPerBlock);
            uint256 remain = pool.totalReward.sub(pool.releasedReward);
            if (remain < chaReward)
                chaReward = remain;
            accCha = accCha.add(
                chaReward.mul(1e12).div(pool.totalPower)
            );
        }
        uint256 pending =  miner.pendingReward.add(power.mul(accCha).div(1e12).sub(miner.rewardDebt));
        uint256 available = 0;
        currentBlock = block.number < pool.endBlock?block.number: pool.endBlock;
        // require(currentBlock > miner.harvestBlock, "harvest: none remain reward");
        // Current available reward
        // total reward
        // remain block
        // everyBlock = remainReward / remainBlock
        // available = (currentBlock - harvestBlock) * everyBlock
        if (currentBlock > miner.harvestBlock) {
            available = pending.mul(currentBlock.sub(miner.harvestBlock));
            available = available.div(pool.endBlock.sub(miner.harvestBlock));
        }
        return(available, pending);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updateReward(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        // uint256 remain = mainToken.balanceOf(address(this));
        uint256 remain = pool.totalReward.sub(pool.releasedReward);
        if (block.number <= pool.lastRewardBlock || remain < 0 || pool.totalPower == 0) {
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 chaReward = multiplier.mul(pool.hcPerBlock);
        // mainToken.mint(address(this), chaReward);
        if ( remain < chaReward ) {
            chaReward = remain;
        }
        pool.releasedReward  = pool.releasedReward.add(chaReward);
        
        pool.accChaPerShare = pool.accChaPerShare.add(
            chaReward.mul(1e12).div(pool.totalPower)
        );
        pool.lastRewardBlock = block.number;
    }

    function harvest(uint256 _pid) public onlyActive{
        updateReward(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        MinerInfo storage miner = minerInfo[_pid][msg.sender];
        uint256 pending =
            miner.power.mul(pool.accChaPerShare).div(1e12).sub(
                miner.rewardDebt
            );
        miner.pendingReward = miner.pendingReward.add(pending);
        require(miner.pendingReward > 0, "harvest: none reward");
        uint256 currentBlock = block.number < pool.endBlock?block.number: pool.endBlock;
        require(currentBlock > miner.harvestBlock, "harvest: none remain reward");
        // Current available reward
        // total reward
        // remain block
        // everyBlock = remainReward / remainBlock
        // available = (currentBlock - harvestBlock) * everyBlock
        pending = miner.pendingReward.mul(currentBlock.sub(miner.harvestBlock));
        pending = pending.div(pool.endBlock.sub(miner.harvestBlock));
        safeChaTransfer(msg.sender, pending);
        miner.rewardDebt = miner.power.mul(pool.accChaPerShare).div(1e12);
        miner.harvestBlock = currentBlock;
        miner.pendingReward = miner.pendingReward.sub(pending);
        miner.harvestReward = miner.harvestReward.add(pending);
        emit Harvest(msg.sender, _pid, pending, miner.pendingReward);
    }

    // // Withdraw LP tokens from Pool.
    function withdraw(uint256 _pid, uint256 amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        MinerInfo storage miner = minerInfo[_pid][msg.sender];
        require(miner.amount >= 0, "withdraw: not exist miner");
        require(pool.accChaPerShare > 0, "accChaPerShare should not be zero");
        updateReward(_pid);
        amount = miner.amount;
        
        uint256 pending = miner.power.mul(pool.accChaPerShare).div(1e12).sub(
            miner.rewardDebt
        );
        pending = miner.pendingReward.add(pending);

        uint256 currentBlock = block.number < pool.endBlock?block.number: pool.endBlock;
        // Current available reward
        uint256 available = 0;
        if (currentBlock > miner.harvestBlock) {
            available = pending.mul(currentBlock.sub(miner.harvestBlock));
            available = available.div(pool.endBlock.sub(miner.harvestBlock));
            safeChaTransfer(msg.sender, available);
            miner.harvestReward =miner.harvestReward.add(available);
        }
        // Remain should be burn
        if (pending > available) 
            mainToken.burn(pending.sub(available));
        // Release lp token.
        pool.lpToken.transfer(address(msg.sender), amount);
        pool.totalPower = pool.totalPower.sub(miner.power);
        //  reduce amount
        miner.power = 0;
        miner.amount = 0;
        miner.pendingReward = 0;
        miner.harvestBlock = currentBlock;
        miner.rewardDebt = miner.power.mul(pool.accChaPerShare).div(1e12);
        // minerInfo[_pid][msg.sender] = 0;

        emit Withdraw(msg.sender, _pid, amount);
    }

    // Safe mainToken transfer function, just in case if rounding error causes pool to not have enough CHA.
    function safeChaTransfer(address _to, uint256 _amount) internal {
        uint256 chaBal = mainToken.balanceOf(address(this));
        if (_amount > chaBal) {
            _amount = chaBal;
        }
        mainToken.transfer(_to, _amount);
    }
}