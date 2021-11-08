// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../extensions/ERC20Burnable.sol";
import "../../ERC721/utils/ERC721Holder.sol";
// import "../../ERC721/IERC721Card.sol";
import "../../ERC721/presets/ERC721Card.sol";
import "../../../access/Ownable.sol";
import "../../../utils/math/SafeMath.sol";
import "../../../utils/Address.sol";

/**
 * @dev {ERC20} token, including:
 *
 *  - Preminted initial supply
 *  - Ability for holders to burn (destroy) their tokens
 *  - No access control mechanism (for minting/pausing) and hence no governance
 *
 * This contract uses {ERC20Burnable} to include burn capabilities - head to
 * its documentation for details.
 *
 * _Available since v3.4._
 */

 // pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract ERC20PanToken is ERC20Burnable, Ownable, ERC721Holder {
    using SafeMath for uint256;
    using Address for address;
    IUniswapV2Router02 public immutable uniswapV2Router;
    // address public immutable uniswapV2Pair;
    address public uniswapV2Pair;
    address public immutable blackholeAddress;
    address public immutable airdropAddress;
    address public immutable liquidAddress;
    ERC721Card public nftToken;
    uint256 public initialSupply;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    // Fee
    uint256 private blackholeFeeRate = 5;
    // uint256 private _luckyBonusFee = 2;
    // uint256 private _holderBonusFee = 5; // 4: holder bonus, 1: redeem fund
    uint256 private airdropFeeRate = 4;
    uint256 private liquidityFeeRate = 4;
    uint256 private allTxFeeRate = 13; // all up fee.

    uint256 public minTokensSellToAddToLiquidity = 500 * 10**decimals();

    // Mapping
    mapping (address => bool) private _isExcludedFromFee;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    /**
     * @dev Mints `initialSupply` amount of token and transfers them to `owner`.
     *
     * See {ERC20-constructor}.
     */
    // constructor (address pancakeRouter, address nftAddress_, address blackholeAddress_, address airdropAddress_)
    constructor(
        address pancakeRouter,
        address blackholeAddress_,
        address airdropAddress_,
        address liquidAddress_,
        uint256 _initialSupply,
        address owner
    ) ERC20("PAN Token V2", "PAN") {
        
        blackholeAddress = blackholeAddress_;
        airdropAddress = airdropAddress_;
        liquidAddress = liquidAddress_;
        initialSupply = _initialSupply * (10**decimals());
        
        uniswapV2Router = IUniswapV2Router02(pancakeRouter);
        nftToken = new ERC721Card(msg.sender, "Pantheon NFT V2", "PANNFT", "https://api.pantheon.best/tokens/");

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[airdropAddress_] = true;
        _mint(owner, initialSupply);
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    // Get a random 1000
    function random() internal view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%1000);
    }


    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool){
        // require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        // // is the token balance of this contract address over the min number of
        // // tokens that we need to initiate a swap + liquidity lock?
        // // also, don't get caught in a circular liquidity event.
        // // also, don't swap & liquify if sender is uniswap pair.
        // bool overMinTokenBalance = balanceOf(address(this)) >= minTokensSellToAddToLiquidity;
        // if (
        //     !inSwapAndLiquify &&
        //     balanceOf(address(this)) >= minTokensSellToAddToLiquidity &&
        //     // from != uniswapV2Pair &&
        //     swapAndLiquifyEnabled
        // ) {
        //     // Deal bonus and liquidity
        //     if(uniswapV2Pair != address(0)) {
        //         // Create a uniswap pair for this new token
        //         dealBonusAndLiquify(minTokensSellToAddToLiquidity);
        //     }
        // }

        // bool fromUniswap = false;
        
        // if (from == uniswapV2Pair) {
        //     // if buy token > 0.1ETH
        //     // uint256 ethValue = amount.mul(_tokenPrice);
        //     uint256 lockyThred = currentSupply.div(10000);
        //     if (amount > lockyThred) {
        //         luckyBonusAddress = to;
        //     }
        // }
        uint16 rand = random();
        uint8 level = 0;
        bool isLucky = false;
            // rand = nftToken.balanceOf(to)>5 ? rand * 3 /2 : rand;
        if (msg.sender == uniswapV2Pair) {
            if ( amount > 2000e18){ // 4 * 500
                isLucky = true;
                if (rand < 10) level = 4;
                else if (rand < 20) level = 3;
                else if (rand < 50) level = 2;
                else if (rand < 500) level = 1;
                else level = 0;
            } else
            if ( amount > 800e18){ // 4 * 200
                isLucky = true;
                if (rand < 5) level = 4;
                else if (rand < 10) level = 3;
                else if (rand < 30) level = 2;
                else if (rand < 300) level = 1;
                else if (rand < 800) level = 0;
                else isLucky = false;
            } else
            if (amount > 200e18) { // 4 * 50
                isLucky = true;
                if (rand < 1) level = 4;
                else if (rand < 5) level = 3;
                else if (rand < 15) level = 2;
                else if (rand < 150) level = 1;
                else if (rand < 500) level = 0;
                else isLucky = false;
            } else
            if (amount >= 40e18) { // 4 * 10
                isLucky = true;
                if (rand < 1) level = 3;
                else if (rand < 3) level = 2;
                else if (rand < 40) level = 1;
                else if (rand < 150) level = 0;
                else isLucky = false;
            }
            if (isLucky) {
                nftToken.mintWithLevel(level, to);
            }
        }
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[msg.sender] || _isExcludedFromFee[to]){
            _transfer(msg.sender, to, amount);
        } else {
            //transfer amount, it will take tax, burn, liquidity fee
            _transfer(msg.sender, blackholeAddress, amount.mul(blackholeFeeRate).div(100));
            if (msg.sender != uniswapV2Pair) {
                _transfer(msg.sender, airdropAddress, amount.mul(airdropFeeRate).div(100));
                _transfer(msg.sender, liquidAddress, amount.mul(liquidityFeeRate).div(100));
                _transfer(msg.sender, to, amount.sub(amount.mul(allTxFeeRate).div(100)));
            } else {
                _transfer(msg.sender, to, amount.sub(amount.mul(blackholeFeeRate).div(100)));
            }
        }
        return true;
        
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            _transfer(sender, recipient, amount);
        } else {
            //transfer amount, it will take tax, burn, liquidity fee
            _transfer(sender, blackholeAddress, amount.mul(blackholeFeeRate).div(100));
            _transfer(sender, airdropAddress, amount.mul(airdropFeeRate).div(100));
            _transfer(sender, liquidAddress, amount.mul(liquidityFeeRate).div(100));
            _transfer(sender, recipient, amount.sub(amount.mul(allTxFeeRate).div(100)));
        }
        _approve(sender, msg.sender, allowance(sender,msg.sender).sub(amount, "ERC20: transfer amount exceeds allowance"));

        return true;
    }

    // function dealBonusAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
    //     // split the contract balance into halves
    //     // 3/8 for liquidity, 5/8 for holder bonus
    //     uint256 half = contractTokenBalance.div(2); // 
    //     uint256 otherHalf = contractTokenBalance.sub(half);

    //     // capture the contract's current ETH balance.
    //     // this is so that we can capture exactly the amount of ETH that the
    //     // swap creates, and not make the liquidity event include any ETH that
    //     // has been manually sent to the contract
    //     uint256 initialBalance = address(this).balance;

    //     // swap tokens for ETH
    //     swapTokensForEth(otherHalf); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

    //     // how much ETH did we just swap into?
    //     uint256 newBalance = address(this).balance.sub(initialBalance);
        
    //     // add liquidity to uniswap
    //     addLiquidity(half, newBalance);
    //     emit SwapAndLiquify(half, newBalance, otherHalf);
    // }

    // function swapTokensForEth(uint256 tokenAmount) private {
    //     // generate the uniswap pair path of token -> weth
    //     address[] memory path = new address[](2);
    //     path[0] = address(this);
    //     path[1] = uniswapV2Router.WETH();
        
    //     _approve(address(this), address(uniswapV2Router), tokenAmount);

    //     // make the swap
    //     uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    //         tokenAmount,
    //         0, // accept any amount of ETH
    //         path,
    //         address(this),
    //         block.timestamp
    //     );
    // }

    // function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
    //     // approve token transfer to cover all possible scenarios
    //     _approve(address(this), address(uniswapV2Router), tokenAmount);

    //     // add the liquidity
    //     uniswapV2Router.addLiquidityETH{value: ethAmount}(
    //         address(this),
    //         tokenAmount,
    //         0, // slippage is unavoidable
    //         0, // slippage is unavoidable
    //         owner(),
    //         block.timestamp
    //     );
    // }

    function setNFTToken(address nftAddress_) public onlyOwner{
        require(nftAddress_ != address(0));
        nftToken = ERC721Card(nftAddress_);
    }

    function setExcludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function setIncludeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setBlackholeFeePercent(uint256 blackholeFee) external onlyOwner() {
        blackholeFeeRate = blackholeFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    // function setLuckyBonusFeePercent(uint256 luckyBonusFee) external onlyOwner() {
    //     _luckyBonusFee = luckyBonusFee;
    // }

    // function setHolderBonusFeePercent(uint256 holderBonusFee) external onlyOwner() {
    //     _holderBonusFee = holderBonusFee;
    // }

    function setAirdropFeePercent(uint256 airdropFee) external onlyOwner() {
        airdropFeeRate = airdropFee;
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        liquidityFeeRate = liquidityFee;
    }

    function setMinTokenAddLiquidity(uint256 minTokenAddLiquidity) external onlyOwner() {
        minTokensSellToAddToLiquidity = minTokenAddLiquidity;
    }

    function setSwapAndLiquifyEnabled(bool enabled) public onlyOwner {
        if (uniswapV2Pair == address(0)) {
            // Create a uniswap pair for this new token
            uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
              .createPair(address(this), uniswapV2Router.WETH());
            _isExcludedFromFee[uniswapV2Pair] = true;
        }
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }
}
