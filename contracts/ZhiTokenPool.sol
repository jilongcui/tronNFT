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
        uint256 rewardBlock;  // Reward debt. See explanation below.
        uint256 rewardDebt;  // Reward debt. See explanation below.
        uint256 startBlock;   // blocks for deposit cycle.;
        uint256 endBlock;   // blocks for deposit cycle.;
    }

    // Info of each pool. pool is set manully.
    struct PoolInfo {
        ERC20Burnable lpToken;      // Address of LP token contract.
        uint256 hcPerBlock;  // HC per block.
        uint256 accChaPerShare;
        uint256 totalReward;
        uint256 totalBlock;
        uint256 delayBlock;
        uint256 totalPower;   // The power rate assigned to this pool. times 1000.
        uint256 releasedReward;
        uint256 lastRewardBlock;
    }
    
    PoolInfo[] public poolInfo;

    bool public active = false;

    ERC20Burnable public mainToken;
    address public fefTRXPair;
    address public htuTRXPair;
    address public blackholeAddress;

    uint256 public initBlock;
    uint256 public havestDelay;
    uint256 public baseBlock;

    uint256 public destroyAmount;
    
    mapping(uint256 => mapping(address => MinerInfo)) public minerInfo;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event InviteUser(address indexed parent, address indexed child, uint256 timestamp);

    constructor(
    ) {
        blackholeAddress = address(0x000000000000000000000000000000000000dEaD);
        havestDelay = 7*24*3600;
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
        uint256 _totalBlock,
        uint256 _delayBlock,
        uint256 _totalReward,
        ERC20Burnable _lpToken
    ) public onlyOwner {
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                hcPerBlock: _totalReward.div(_totalBlock),
                totalReward: _totalReward,
                totalBlock: _totalBlock,
                delayBlock: _delayBlock,
                totalPower: 0,
                accChaPerShare: 0,
                releasedReward: 0,
                lastRewardBlock: _startupBlock
            })
        );
    }

    // Update the given pool's CHA power rate. Can only be called by the owner.
    function setPool(
        uint256 _pid,
        uint256 _hcPerBlock,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            updateReward(_pid);
        }
        poolInfo[_pid].hcPerBlock = _hcPerBlock;
    }

    function setHtuTrxPair(
        address _address
    ) public onlyOwner{
        htuTRXPair = _address;
    }

    function setFefTrxPair(
        address _address
    ) public onlyOwner{
        fefTRXPair = _address;
    }

    function setMainToken(
        address _token
    ) public onlyOwner{
        mainToken = ERC20Burnable(_token);
    }

    function setHavestDelay(
        uint256 delay
    ) public onlyOwner{
        havestDelay = delay;
    }

    function setActive (
        bool _active
    )public onlyOwner{
        active = _active;
    }

    // function setInitBlock (
    //     uint256 _initBlock
    // ) public onlyOwner onlyInactive{
    //     require(!active, "Require inactive");
    //     initBlock =
    //         block.number > _initBlock ? block.number : _initBlock;
    //     lastRewardBlock = initBlock;
    //     baseBlock = initBlock;
    //     active = true;
    // }

    // For check
    function getFefValue(uint256 amount) public view returns(uint256) {
        IJustswapExchange pair = IJustswapExchange(fefTRXPair);
        return pair.getTokenToTrxInputPrice(amount);
        // return amount.div(1000); // 1FEF = 0.1TRX
    }

    function getHtuValue(uint256 amount) public view returns(uint256) {
        IJustswapExchange pair = IJustswapExchange(htuTRXPair);
        return pair.getTokenToTrxInputPrice(amount);
        // return amount.div(5); // HTU = 0.2TRX; 
    }

    // function getUsdtValue(uint256 amount) public view returns(uint256) {
    //     IJustswapExchange pair = IJustswapExchange(usdtPairAddress);
    //     return pair.getTrxToTokenInputPrice(amount);
    //     // return amount.div(10); // 1TRX = 0.1U
    // }

    function getGlobalPoolInfo(uint256 pid) public view returns(uint256, uint256, uint256, uint256, uint256) {
        uint256 fefPrice = getFefValue(1e8);
        uint256 htuPrice = getHtuValue(1e6);
        uint256 destoryAmountOfFef = destroyAmount;
        uint256 releasedPerDayOfHtu = getMintHtuPerday();
        // uint256 releasedTotalOfHtu = getReleasedTotalOfHtu();
        uint256 destoryTotalOfHtu = mainToken.balanceOf(address(0));
        return (fefPrice, htuPrice, destoryAmountOfFef, releasedPerDayOfHtu,destoryTotalOfHtu);
    }

    function getMintHtuPerday() internal view returns(uint256) {
        if (active && block.number > baseBlock) {
            uint256 countBlock = block.number.sub(baseBlock);
            uint256 countDay = countBlock.div(24*1200);
            uint256 amount = 252500000;
            return amount.add(countDay.mul(5000000));
        }
        return 0;
        
    }

    // function getReleasedTotalOfHtu() internal view returns(uint256) {
    //     if (active && block.number > baseBlock) {
    //         uint256 lastBlock = lastRewardBlock;
    //         uint256 endBlock = block.number;
    //         uint256 multiplier = getMultiplier(lastBlock, endBlock);
    //         uint256 chaReward = multiplier.mul(chaPerBlock);
    //         return releasedReward.add(chaReward);
    //     }
    //     return 0;
    // }

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
        require(block.number > pool.lastRewardBlock, "Not started");
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
        miner.endBlock = block.number + pool.totalBlock;
        miner.rewardBlock = block.number + pool.delayBlock;
        miner.power = miner.power.add(power);
        pool.totalPower = pool.totalPower.add(power);
        miner.rewardDebt = miner.power.mul(pool.accChaPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);

        return true;
    }

    function pendingReward(uint256 _pid, address _user) external view returns (uint256)
    {
        MinerInfo memory miner = minerInfo[_pid][_user];
        PoolInfo memory pool = poolInfo[_pid];
        uint256 accCha = pool.accChaPerShare;
        uint256 power = miner.power;
        
        // calculate new pendingReward
        if (power != 0 && block.number > pool.lastRewardBlock && pool.totalPower != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 chaReward = multiplier.mul(pool.hcPerBlock);
            uint256 remain = pool.totalReward.sub(pool.releasedReward);
            if (remain < chaReward)
                chaReward = remain;
            accCha = accCha.add(
                chaReward.mul(1e12).div(pool.totalPower)
            );
        }
        return miner.pendingReward.add(power.mul(accCha).div(1e12).sub(miner.rewardDebt));
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
        // require (block.timestamp.sub(initTimestamp) >= havestDelay, "time limit for 7day");

        PoolInfo storage pool = poolInfo[_pid];
        MinerInfo storage miner = minerInfo[_pid][msg.sender];
        uint256 pending =
            miner.power.mul(pool.accChaPerShare).div(1e12).sub(
                miner.rewardDebt
            );
        pending = miner.pendingReward.add(pending);
        require(pending > 0, "harvest: none reward");
        uint256 currentBlock = block.number < miner.endBlock?block.number: miner.endBlock;
        require(currentBlock > miner.rewardBlock, "harvest: none remain reward");
        // Current available reward
        // total reward
        // remain block
        // everyBlock = remainReward / remainBlock
        // available = (currentBlock - rewardBlock) * everyBlock
        pending = pending.mul(currentBlock.sub(miner.rewardBlock));
        pending = pending.div(miner.endBlock.sub(miner.rewardBlock));
        safeChaTransfer(msg.sender, pending);
        miner.rewardDebt = miner.power.mul(pool.accChaPerShare).div(1e12);
        miner.rewardBlock = currentBlock;
        miner.pendingReward = 0;
        emit Harvest(msg.sender, _pid, pending);
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

        uint256 currentBlock = block.number < miner.endBlock?block.number: miner.endBlock;
        // Current available reward
        uint256 available = 0;
        if (currentBlock > miner.rewardBlock) {
            available = pending.mul(currentBlock.sub(miner.rewardBlock));
            available = available.div(miner.endBlock.sub(miner.rewardBlock));
            safeChaTransfer(msg.sender, available);
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
        miner.rewardBlock = currentBlock;
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