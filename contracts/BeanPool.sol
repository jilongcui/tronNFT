// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/math/SafeMath.sol";
import "./utils/Address.sol";
import "./access/Ownable.sol";

import "./token/ERC721/IERC721.sol";
import "./token/ERC721/IERC721Card.sol";
import "./token/ERC20/IERC20.sol";
import "./token/ERC721/utils/ERC721Holder.sol";
import "./token/ERC20/utils/SafeERC20.sol";

interface IMigratorChef {
    // Perform LP token migration from legacy UniswapV2 to ChaSwap.
    // Take the current LP token address and return the new LP token address.
    // Migrator should have full access to the caller's LP token.
    // Return the new LP token address.
    //
    // XXX Migrator must have allowance access to UniswapV2 LP tokens.
    // ChaSwap must mint EXACTLY the same amount of ChaSwap LP tokens or
    // else something bad will happen. Traditional UniswapV2 does not
    // do that so be careful!
    function migrate(IERC20 token) external returns (IERC20);
}

// BeanPool is the master of Reward. He can make Reward and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once CHA is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract BeanPool is Ownable,ERC721Holder {
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
        uint256 endBlock; // 结束block
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 nft1;
        uint256 nft2;
        uint256 nft3;
    }
    // Info of each pool. pool is set manully.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        IERC20 lpToken2; // Address of LP token contract.
        bool isLp; // if isLp is true we should have a usdt token.
        uint32 timeBlocks; // timeBlocks;
        uint32 amountRate; // The amount rate for token 2, times 1000.
        uint256 powerRate; // The power rate assigned to this pool. times 1000.
    }
    
    IERC721Card public nftToken;
    uint256 public lastRewardBlock; // Last block number that CHAs distribution occurs.
    uint256 public accChaPerShare; // Accumulated CHAs per share, times 1e12. See below.
    // Total power
    uint256 public totalPower;
    uint16[] public nftRate = [1000, 2000, 3000]; // times 1000

    // Invite
    bool public inviteForce = true;
    uint8 public maxInviteLayer = 5;
    // The CHA TOKEN!
    IERC20 public panToken;
    // Dev address.
    address public devaddr;
    address public blackholeAddress;
    address public airdropAddress;
    // address public liquidAddress;
    // Block number when bonus CHA period ends.
    // uint256 public bonusEndBlock;
    // Total reward for miner
    uint256 public totalReward;
    // Total released reward
    uint256 public releasedReward;
    // CHA tokens created per block.
    uint256 public chaPerBlock;
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
    mapping(address => uint8) public userLevel;
    mapping(address => uint256) public inviteReward;
    // mapping(uint8 => mapping(uint8 => uint8)) memory inviteRatio;
    uint8[][] inviteRatio = [[0,0,0,0,0],[15,12,0,0,0],[20,15,10,0,0],[22,18,16,14,12]];
    mapping(uint256 => mapping(address => MinerInfo)) public minerInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when CHA mining starts.
    uint256 public startBlock;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event DepositWithNFT(address indexed user, uint256 indexed pid, uint256 amount,
        uint16 nft1, uint16 nft2, uint16 nft3);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event InviteUser(address indexed parent, address indexed child, uint256 timestamp);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        IERC20 _chaAddress,
        IERC721Card _nftAddress,
        address initInviteAddress,
        address _blackholeAddress,
        address _airdropAddress,
        // address _liquidAddress,
        uint256 _chaPerBlock,
        uint256 _startBlock,
        uint256 _totalReward
    ) {
        panToken = _chaAddress;
        blackholeAddress = _blackholeAddress;
        airdropAddress = _airdropAddress;
        // liquidAddress = _liquidAddress;
        chaPerBlock = _chaPerBlock;
        // bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        totalReward = _totalReward;
        nftToken = IERC721Card(_nftAddress);
        lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        // totalAllocPoint = totalAllocPoint.add(_allocPoint);
        userParent[initInviteAddress] = msg.sender;
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
        uint32 _amountRate,
        IERC20 _token,
        IERC20 _token2,
        bool _isLp,
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
                isLp: _isLp,
                timeBlocks: timeBlocks,
                powerRate: _powerRate,
                amountRate: _amountRate
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
        userParent[msg.sender] = parent;
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
    function getInviteInfo(address addr) public view returns (uint16, uint256, uint256, uint256, address){
        return (userLevel[addr],userPower[addr], groupPower[addr], inviteReward[addr], userParent[addr]);
    }
    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
        // if (_to <= bonusEndBlock) {
        //     return _to.sub(_from).mul(BONUS_MULTIPLIER);
        // } else if (_from >= bonusEndBlock) {
        //     return _to.sub(_from);
        // } else {
        //     return
        //         bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
        //             _to.sub(bonusEndBlock)
        //         );
        // }
    }

    // View function to see pending CHA on frontend.
    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        // PoolInfo storage pool = poolInfo[_pid];
        MinerInfo storage miner = minerInfo[_pid][_user];
        uint256 accCha = accChaPerShare;
        uint256 endBlock = block.number;
        if (block.number > miner.endBlock) {
            endBlock = miner.endBlock;
        }
        if (endBlock > lastRewardBlock && totalPower != 0) {
            uint256 multiplier =
                getMultiplier(lastRewardBlock, endBlock);
            uint256 chaReward = multiplier.mul(chaPerBlock);
            accCha = accCha.add(
                chaReward.mul(1e12).div(totalPower)
            );
            return miner.power.mul(accCha).div(1e12).sub(miner.rewardDebt);
        }
        return 0;
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    // function updateReward() public {
    //     uint256 length = poolInfo.length;
    //     for (uint256 pid = 0; pid < length; ++pid) {
    //         updateReward(pid);
    //     }
    // }

    // Update reward variables of the given pool to be up-to-date.
    function updateReward() public {
        // PoolInfo storage pool = poolInfo[_pid];
        // uint256 remain = panToken.balanceOf(address(this));
        uint256 remain = totalReward.sub(releasedReward);
        if (block.number <= lastRewardBlock && remain <= 0) {
            return;
        }
        if (totalPower == 0) {
            lastRewardBlock = block.number;
            return;
        }
        require(lastRewardBlock<=block.number, "lastRewardBlock not valid");
        uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
        uint256 chaReward = multiplier.mul(chaPerBlock);
        // panToken.mint(devaddr, chaReward.div(10));
        // panToken.mint(address(this), chaReward);
        if ( remain < chaReward ) {
            chaReward = remain;
        }
        releasedReward  = releasedReward.add(chaReward);
        accChaPerShare = accChaPerShare.add(
            chaReward.mul(1e12).div(totalPower)
        );
        lastRewardBlock = block.number;
    }


    // Deposit LP tokens to BeanPool for CHA allocation.
    function deposit(uint256 _pid, uint256 _amount) public returns (bool){
        PoolInfo storage pool = poolInfo[_pid];
        MinerInfo memory miner = minerInfo[_pid][msg.sender];
        updateReward();
        if (inviteForce == true) {
            require(userParent[msg.sender] != address(0), "You need be invited first.");
        }
        if (miner.amount > 0) {
            uint256 pending =
                miner.power.mul(accChaPerShare).div(1e12).sub(
                    miner.rewardDebt
                );
            safeChaTransfer(msg.sender, pending);
        }
        // pool.lpToken.approve(address(this), _amount);
        pool.lpToken.transferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        if (pool.isLp) {
            pool.lpToken2.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount.mul(pool.amountRate).div(1000)
            );
        }
        miner.amount = miner.amount.add(_amount);
        uint256 power = _amount.mul(pool.powerRate).div(1000);
        miner.power = miner.power.add(power);
        totalPower = totalPower.add(power);
        upGroupPower(msg.sender, power);
        userPower[msg.sender] = userPower[msg.sender].add(power);
        uint256 blockNumber = block.number;
        miner.endBlock = blockNumber.add(pool.timeBlocks); // * 24 * 1200;
        userLevel[msg.sender] = getUserLevel(userPower[msg.sender]);
        miner.rewardDebt = miner.power.mul(accChaPerShare).div(1e12);
        minerInfo[_pid][msg.sender] = miner;
        emit Deposit(msg.sender, _pid, _amount);
        return true;
    }

    // Deposit LP tokens to BeanPool for CHA allocation.
    function depositWithNFT(uint256 _pid, uint256 _amount, uint16 nft1, uint16 nft2, uint16 nft3) public {
        PoolInfo storage pool = poolInfo[_pid];
        MinerInfo memory miner = minerInfo[_pid][msg.sender];
        // require(miner.amount == 0, "You already depsoit this pool.");
        updateReward();
        if (miner.amount > 0) {
            uint256 pending =
                miner.power.mul(accChaPerShare).div(1e12).sub(
                    miner.rewardDebt
                );
            safeChaTransfer(msg.sender, pending);
        }
        pool.lpToken.transferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        if (pool.isLp) {
            pool.lpToken2.transferFrom(
                address(msg.sender),
                address(this),
                _amount.mul(pool.amountRate).div(1000)
            );
        }
        miner.amount = miner.amount.add(_amount);
        uint256 level;
        uint256 level2;
        uint256 level3;
        uint256 rate = pool.powerRate;
        if (nft1 > 0 && nftToken.ownerOf(nft1) == msg.sender) {
            level = nftToken.levelOf(nft1);
            rate += pool.powerRate * nftRate[level] / 1000;
            nftToken.safeTransferFrom(msg.sender, address(this), nft1);
        }
        if (nft2 > 0 && nftToken.ownerOf(nft2) == msg.sender) {
            level2 = nftToken.levelOf(nft2);
            rate += pool.powerRate * nftRate[level2] / 1000;
            nftToken.safeTransferFrom(msg.sender, address(this), nft2);
        }
        if (nft3 > 0 && nftToken.ownerOf(nft3) == msg.sender) {
            level3 = nftToken.levelOf(nft3);
            rate += pool.powerRate * nftRate[level3] / 1000;
            nftToken.safeTransferFrom(msg.sender, address(this), nft3);
        }
        // 同级别三张，有彩蛋
        if(level == 2 && level == level2 && level2 == level3) {
            rate += pool.powerRate * 5000/1000;
        }
        uint256 power = _amount.mul(rate).div(1000);
        miner.power = miner.power.add(power);
        totalPower = totalPower.add(power);
        upGroupPower(msg.sender, power);
        userPower[msg.sender] = userPower[msg.sender].add(power);
        uint256 blockNumber = block.number;
        miner.endBlock = blockNumber.add(pool.timeBlocks);
        miner.nft1 = uint16(nft1);
        miner.nft2 = uint16(nft2);
        miner.nft3 = uint16(nft3);
        userLevel[msg.sender] = getUserLevel(userPower[msg.sender]);
        miner.rewardDebt = miner.power.mul(accChaPerShare).div(1e12);
        minerInfo[_pid][msg.sender] = miner;
        emit DepositWithNFT(msg.sender, _pid, _amount, nft1, nft2, nft3);
    }
    function getUserLevel(uint256 power) private pure returns(uint8){
        uint8 level;
        power = power.div(1e18);
        level = 0;
        if (power >= 3000) {
            level = 3;
        } else if (power >= 2000) {
            level = 2;
        } else if (power >= 1000) {
            level = 1;
        }
        return level;
    }
    // // Get a random 100
    // Get a random 100
    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%100);
    }
    // harvest LP tokens from BeanPool.
    function harvest(uint256 _pid) public {
        // PoolInfo storage pool = poolInfo[_pid];
        MinerInfo storage miner = minerInfo[_pid][msg.sender];
        updateReward();
        uint256 pending =
            miner.power.mul(accChaPerShare).div(1e12).sub(
                miner.rewardDebt
            );
        require(pending > 0, "harvest: none reward");
        safeChaTransfer(msg.sender, pending);
        miner.rewardDebt = miner.power.mul(accChaPerShare).div(1e12);
        emit Harvest(msg.sender, _pid, pending);
    }

    // Withdraw LP tokens from BeanPool.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        MinerInfo storage miner = minerInfo[_pid][msg.sender];
        require(miner.amount >= _amount, "withdraw: not good");
        require(accChaPerShare > 0, "accChaPerShare should not be zero");
        require(miner.endBlock <= block.number, "Cannot withdraw with days limit.");
        updateReward();
        if (miner.amount.mul(accChaPerShare).div(1e12) > miner.rewardDebt) {
            uint256 pending = miner.amount.mul(accChaPerShare).div(1e12).sub(
                miner.rewardDebt
            );
            safeChaTransfer(msg.sender, pending);
        }
        
        if (pool.isLp) {
            pool.lpToken2.transfer(
                msg.sender,
                miner.amount.mul(pool.amountRate).div(1000)
            );
        }

        // miner.rewardDebt = miner.power.mul(accChaPerShare).div(1e12);
        // userLevel[msg.sender] = getUserLevel(userPower[msg.sender]);
        pool.lpToken.transfer(address(msg.sender), _amount);

        if (miner.nft1 > 0) {
            nftToken.safeTransferFrom(address(this), msg.sender, miner.nft1);
        }
        if (miner.nft2 > 0) {
            nftToken.safeTransferFrom(address(this), msg.sender, miner.nft2);
        }
        if (miner.nft3 > 0) {
            nftToken.safeTransferFrom(address(this), msg.sender, miner.nft3);
        }

        // reduce power
        // uint256 power = miner.power.mul(_amount).div(miner.amount);
        totalPower = totalPower.sub(miner.power);
        downGroupPower(msg.sender, miner.power);

        userPower[msg.sender] = userPower[msg.sender].sub(miner.power);
        //  reduce amount
        miner.power = 0;
        miner.amount = 0;
        miner.nft1 = 0;
        miner.nft2 = 0;
        miner.nft3 = 0;
        miner.rewardDebt = 0;
        // minerInfo[_pid][msg.sender] = 0;

        emit Withdraw(msg.sender, _pid, _amount);
    }

    function calculeInviteReward(address child, uint256 total) private {

        for(uint8 layer=0; layer< maxInviteLayer; layer++) {
            address parent = userParent[child];
            if (parent == address(0) || parent == child)
                return;
            uint8 level = userLevel[parent];
            uint8 ratio = inviteRatio[level][layer];
            if (ratio <= 0) {
                return ;
            }
            uint256 reward = total.mul(ratio).div(100);
            inviteReward[parent] = inviteReward[parent].add(reward);
            child = parent;
        }
    }

    function upGroupPower(address child, uint256 power) private {

        for(uint8 layer=0; layer< maxInviteLayer; layer++) {
            address parent = userParent[child];
            if (parent == address(0) || parent == child)
                return;
            groupPower[parent] = groupPower[parent].add(power);
            child = parent;
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

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        MinerInfo storage miner = minerInfo[_pid][msg.sender];
        require(miner.endBlock < block.number, "Cannot withdraw with days limit.");
        pool.lpToken.safeTransfer(address(msg.sender), miner.amount);
        if (pool.isLp) {
            pool.lpToken2.transfer(
                msg.sender,
                miner.amount.mul(pool.amountRate).div(1000)
            );
        }
        emit EmergencyWithdraw(msg.sender, _pid, miner.amount);
        userPower[msg.sender] = userPower[msg.sender].sub(miner.power);
        userLevel[msg.sender] = getUserLevel(userPower[msg.sender]);
        totalPower = totalPower.sub(miner.power);
        downGroupPower(msg.sender, miner.power);
        miner.amount = 0;
        miner.rewardDebt = 0;
        miner.power = 0;
    }

    // Safe panToken transfer function, just in case if rounding error causes pool to not have enough CHA.
    function safeChaTransfer(address _to, uint256 _amount) internal {
        uint256 chaBal = panToken.balanceOf(address(this));
        if (_amount > chaBal) {
            _amount = chaBal;
        }
        panToken.transfer(blackholeAddress, _amount.mul(2).div(100));
        panToken.transfer(airdropAddress, _amount.mul(10).div(100));
        // panToken.transfer(liquidAddress, _amount.mul(4).div(100));
        panToken.transfer(_to, _amount.sub(_amount.mul(12).div(100)));
        if(inviteForce)
           calculeInviteReward(_to, _amount);
    }
}