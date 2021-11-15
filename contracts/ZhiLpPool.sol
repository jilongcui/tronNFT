// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/math/SafeMath.sol";
import "./utils/Address.sol";
import "./access/Ownable.sol";

import "./token/ERC20/IERC20.sol";
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

// BeanPool is the master of Reward. He can make Reward and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once CHA is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract ZhiLpPool is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // Info of each user.
    // struct UserInfo {
    //     uint256 amount; // How many LP tokens the user has provided.
    //     uint256 rewardDebt; // Reward debt. See explanation below.
    //     //
    //     // We do some fancy math here. Basically, any point in time, the amount of CHA
    //     // entitled to a user but is pending to be distributed is:
    //     //
    //     //   pending reward = (user.amount * accChaPerShare) - user.rewardDebt
    //     //
    //     // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
    //     //   1. The pool's `accChaPerShare` (and `lastRewardBlock`) gets updated.
    //     //   2. User receives the pending reward sent to his/her address.
    //     //   3. User's `amount` gets updated.
    //     //   4. User's `rewardDebt` gets updated.
    // }

    struct InviteInfo {
        address parent;
        uint256 totalPower;
    }

    // Miner information describe miner. One should has many Miners;
    struct MinerInfo {
        uint256 amount; // 本金
        uint256 power; // 算力
        // uint256 endBlock; // 结束block
        uint256 pendingReward;
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
    // The CHA TOKEN!
    IERC20 public panToken;
    address public uniswapV2Pair;
    address public usdtPairAddress;
    // Dev address.
    address public blackholeAddress;
    address public airdropAddress;
    address public beneficience;
    // Block number when bonus CHA period ends.
    // Total reward for miner
    uint256 public totalReward;
    // Total released reward
    uint256 public releasedReward;
    // CHA tokens created per block.
    uint256 public chaPerBlock;
    uint256 public padPerBlock;
    uint256 public restartReward;
    // Bonus muliplier for early panToken makers.
    uint256 public constant BONUS_MULTIPLIER = 10;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    // IMigratorChef public migrator;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(address => uint256) public userPower;
    mapping(address => uint256) public groupPower;
    mapping(address => address) public userParent;
    // mapping(address => uint8) public userLevel;
    // mapping(address => uint256) public inviteReward;
    // mapping(uint8 => mapping(uint8 => uint8)) memory inviteRatio;
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
        address _uniswapV2Pair,
        address _usdtPairAddress,
        address _initInviteAddress,
        address _airdropAddress,
        address _beneficience,
        uint256 _initBlock,
        uint256 _totalReward
    ) {
        airdropAddress = _airdropAddress;
        beneficience = _beneficience;
        uniswapV2Pair = _uniswapV2Pair;
        usdtPairAddress = _usdtPairAddress;
        chaPerBlock = 7819444; // 225.2/24/1200 should div(1000)
        padPerBlock = 6028; // should div(1000000)
        restartReward = 50000000000;
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

    // function totalReward() external view returns (uint256) {
    //     return totalReward;
    // }

    // function releasedReward() external view returns (uint256) {
    //     return releasedReward;
    // }

    function releaseReward2() external view returns (uint256) {
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

    // Update the given pool's CHA power rate. Can only be called by the owner.
    function setPool(
        uint256 _pid,
        uint256 _powerRate,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            updateReward();
        }
        poolInfo[_pid].powerRate = _powerRate;
    }

    function setInvite(
        address parent
    ) public {
        require(userParent[msg.sender] == address(0), "You already be invited.");
        require(userParent[parent] != address(0), "Parent should be invite first.");
        require(parent != msg.sender, "You cannot invite yourself.");
        uint256 pid = 0;
        userParent[msg.sender] = parent;
        MinerInfo storage miner = minerInfo[pid][msg.sender];
        uint256 pending =
            miner.power.mul(accChaPerShare).div(1e12).sub(
                miner.rewardDebt
            );
        if (pending > 0) {
            // safeChaTransfer(msg.sender, pending);
            miner.pendingReward += pending;
            miner.rewardDebt = miner.power.mul(accChaPerShare).div(1e12);
            emit Harvest(msg.sender, pid, pending);
        }
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
        panToken = IERC20(_token);
    }

    // Set the migrator contract. Can only be called by the owner.
    // function setMigrator(IMigratorChef _migrator) public onlyOwner {
    //     migrator = _migrator;
    // }

    // // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    // function migrate(uint256 _pid) public {
    //     require(address(migrator) != address(0), "migrate: no migrator");
    //     PoolInfo storage pool = poolInfo[_pid];
    //     IERC20 lpToken = pool.lpToken;
    //     uint256 bal = lpToken.balanceOf(address(this));
    //     lpToken.safeApprove(address(migrator), bal);
    //     IERC20 newLpToken = migrator.migrate(lpToken);
    //     require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
    //     pool.lpToken = newLpToken;
    // }
    // function getInviteInfo(address addr) public view returns (uint16, uint256, uint256, uint256, address){
    //     return (userLevel[addr],userPower[addr], groupPower[addr], inviteReward[addr], userParent[addr]);
    // }
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
        uint256 power = miner.power;
        uint256 rewardDebt = miner.rewardDebt;
        
        // calculate new pendingReward
        if (power != 0 && block.number > lastRewardBlock && totalPower != 0) {
            uint256 lastBlock = lastRewardBlock.sub(baseBlock);
            uint256 endBlock = block.number.sub(baseBlock);
            uint256 multiplier = getMultiplier(lastBlock, endBlock);
            uint256 chaReward = multiplier.mul(chaPerBlock).div(1000);
            uint256 addition = endBlock.add(lastBlock).mul(multiplier).mul(padPerBlock).div(1000000);

            chaReward = chaReward.add(addition);
            accCha = accCha.add(
                chaReward.mul(1e12).div(totalPower)
            );
        }
        return miner.pendingReward.add(power.mul(accCha).div(1e12).sub(rewardDebt));
    }

    // Update reward variables of the given pool to be up-to-date.
    function updateReward() public {
        // PoolInfo storage pool = poolInfo[_pid];
        // uint256 remain = panToken.balanceOf(address(this));
        uint256 remain = totalReward.sub(releasedReward);
        if (block.number <= lastRewardBlock || remain < 0 || totalPower == 0) {
            return;
        }
        // if (totalPower == 0) {
        //     lastRewardBlock = block.number;
        //     return;
        // }
        // require(lastRewardBlock<=block.number, "lastRewardBlock not valid");
        uint256 lastBlock = lastRewardBlock.sub(baseBlock);
        uint256 endBlock = block.number.sub(baseBlock);
        uint256 multiplier = getMultiplier(lastBlock, endBlock);
        uint256 chaReward = multiplier.mul(chaPerBlock).div(1000);
        uint256 addition = endBlock.add(lastBlock).mul(multiplier).mul(padPerBlock).div(1000000);
        chaReward = chaReward.add(addition);
        // panToken.mint(address(this), chaReward);
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

    function getEthValue(uint256 amount) public view returns(uint256) {
        // IJustswapExchange pair = IJustswapExchange(uniswapV2Pair);
        // return pair.getTokenToTrxInputPrice(amount);
        return amount;
    }

    function getUsdtValue(uint256 amount) public view returns(uint256) {
        // IJustswapExchange pair = IJustswapExchange(usdtPairAddress);
        // return pair.getTrxToTokenInputPrice(amount);
        return amount;
    }

    // Deposit LP tokens to BeanPool for CHA allocation.
    function deposit(uint256 _pid, uint256 _amount) payable public returns (bool){
        updateReward();
        PoolInfo storage pool = poolInfo[_pid];
        MinerInfo memory miner = minerInfo[_pid][msg.sender];
        
        if (inviteForce == true) {
            require(userParent[msg.sender] != address(0), "You need be invited first.");
        }
        if (miner.amount > 0) {
            uint256 pending =
                miner.power.mul(accChaPerShare).div(1e12).sub(
                    miner.rewardDebt
                );
            // safeChaTransfer(msg.sender, pending);
            miner.pendingReward = miner.pendingReward.add(pending);
        }
        
        // pool.lpToken.approve(address(this), _amount);
        pool.lpToken.transferFrom(
            address(msg.sender),
            address(blackholeAddress),
            _amount
        );
        
        // trx
        // Get trx amount
        // getEthValue
        uint256 ethAmount = getEthValue(_amount);
        // if (ethAmount > msg.value)
        //     ethAmount = msg.value;
        require(msg.value >= ethAmount, "TRX amount is invalid");
        payable(beneficience).transfer(ethAmount);
        // if (pool.isInternal) {
        //     pool.lpToken2.safeTransferFrom(
        //         address(msg.sender),
        //         address(beneficience),
        //         ethAmount
        //     );
        // }
        miner.amount = miner.amount.add(_amount);
        uint256 usdtAmount = getUsdtValue(ethAmount);
        require(usdtAmount >= 1e6, "Require depsit value big than 25U.");
        uint256 power = usdtAmount.mul(2);
        miner.power = miner.power.add(power);
        totalPower = totalPower.add(power);
        upGroupPower(msg.sender, power);
        userPower[msg.sender] = userPower[msg.sender].add(power);
        miner.rewardDebt = miner.power.mul(accChaPerShare).div(1e12);
        minerInfo[_pid][msg.sender] = miner;
        emit Deposit(msg.sender, _pid, _amount);
        return true;
    }

    // Get a random 100
    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%100);
    }

    // harvest LP tokens from BeanPool.
    function harvest(uint256 _pid) public {
        updateReward();
        // PoolInfo storage pool = poolInfo[_pid];
        MinerInfo storage miner = minerInfo[_pid][msg.sender];
        uint256 pending =
            miner.power.mul(accChaPerShare).div(1e12).sub(
                miner.rewardDebt
            );
        pending = miner.pendingReward.add(pending);
        require(pending > 0, "harvest: none reward");
        safeChaTransfer(msg.sender, pending);
        miner.rewardDebt = miner.power.mul(accChaPerShare).div(1e12);
        miner.pendingReward = 0;
        emit Harvest(msg.sender, _pid, pending);
    }

    // // Withdraw LP tokens from BeanPool.
    // function withdraw(uint256 _pid, uint256 _amount) public {
    //     PoolInfo storage pool = poolInfo[_pid];
    //     MinerInfo storage miner = minerInfo[_pid][msg.sender];
    //     require(miner.amount >= _amount, "withdraw: not good");
    //     require(accChaPerShare > 0, "accChaPerShare should not be zero");
    //     updateReward();
    //     if (miner.amount.mul(accChaPerShare).div(1e12) > miner.rewardDebt) {
    //         uint256 pending = miner.amount.mul(accChaPerShare).div(1e12).sub(
    //             miner.rewardDebt
    //         );
    //         safeChaTransfer(msg.sender, pending);
    //     }
        
    //     if (pool.isInternal) {
    //         pool.lpToken2.transfer(
    //             msg.sender,
    //             miner.amount
    //         );
    //     }

    //     // miner.rewardDebt = miner.power.mul(accChaPerShare).div(1e12);
    //     // userLevel[msg.sender] = getUserLevel(userPower[msg.sender]);
    //     pool.lpToken.transfer(address(msg.sender), _amount);

    //     // reduce power
    //     // uint256 power = miner.power.mul(_amount).div(miner.amount);
    //     totalPower = totalPower.sub(miner.power);
    //     downGroupPower(msg.sender, miner.power);

    //     userPower[msg.sender] = userPower[msg.sender].sub(miner.power);
    //     //  reduce amount
    //     miner.power = 0;
    //     miner.amount = 0;
    //     miner.rewardDebt = 0;
    //     // minerInfo[_pid][msg.sender] = 0;

    //     emit Withdraw(msg.sender, _pid, _amount);
    // }

    function upGroupPower(address child, uint256 power) private {
        uint level = 0;
        for(uint8 layer=0; layer< maxInviteLayer; layer++) {
            address parent = userParent[child];
            if (parent == address(0) || parent == child)
                return;
            uint8 ratio = inviteRatio[level];
            if (ratio <= 0) {
                return ;
            }
            uint256 reward = power.mul(ratio).div(100);
            groupPower[parent] = groupPower[parent].add(reward);
            child = parent;
            level += 1;
        }
    }

    function downGroupPower(address child, uint256 power) private {

        for(uint8 layer=0; layer< maxInviteLayer; layer++) {
            address parent = userParent[child];
            if (parent == address(0) || parent == child)
                return;
            groupPower[parent] = groupPower[parent].sub(power);
            child = parent;
        }
    }

    // Safe panToken transfer function, just in case if rounding error causes pool to not have enough CHA.
    function safeChaTransfer(address _to, uint256 _amount) internal {
        uint256 chaBal = panToken.balanceOf(address(this));
        if (_amount > chaBal) {
            _amount = chaBal;
        }
        // panToken.transfer(blackholeAddress, _amount.mul(7).div(100));
        // panToken.transfer(airdropAddress, _amount.mul(1).div(100));
        // panToken.transfer(_to, _amount.sub(_amount.mul(8).div(100)));
        panToken.transfer(_to, _amount);
    }
}