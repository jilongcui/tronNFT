
// SPDX-License-Identifier: MIT

/**
   # PAN tokens
 */
import "./utils/math/SafeMath.sol";
import "./utils/Address.sol";
import "./token/ERC721/IERC721.sol";
import "./token/ERC20/IERC20.sol";
import "./access/Ownable.sol";
import "./token/ERC721/utils/ERC721Holder.sol";

pragma solidity 0.8.6;

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

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Card {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function levelView(uint8 level) external view returns (
        uint16 total, 
        uint16 current,
        uint16 power
    );

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function levelOf(uint256 id) external view returns (uint8 level);

    function mintWithLevel(uint8 _level, address to) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    
}

contract PanToken is Context, IERC20, Ownable, ERC721Holder {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    mapping (address => uint256) private _lastTransferTime;
    mapping (address => uint256) private _lastClaimBonusTime;
    mapping (address => uint256) public _lastTransferLimitTime;
    mapping (address => uint256) public _lastTransferLimitCount;

    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 2 * 10**8 * 10**6;
    uint256 private _tFeeTotal;
    uint256 private BLACKHOLE_LIMIT = _tTotal - 5 * 10 ** 8 * 10 ** 6;

    string private _name = "PAN Token";
    string private _symbol = "PAN";
    uint8 private _decimals = 6;
    
    uint256 private _blackholeFee = 5;
    // uint256 private _luckyBonusFee = 2;
    // uint256 private _holderBonusFee = 5; // 4: holder bonus, 1: redeem fund
    uint256 private _airdropFee = 4;
    uint256 private _liquidityFee = 4;
    uint256 private _allTaxFee = 13; // all up fee.

    IUniswapV2Router02 public immutable uniswapV2Router;
    // address public immutable uniswapV2Pair;
    address public uniswapV2Pair;
    address public immutable blackholeAddress;
    address public redeemAddress;
    // address public luckyBonusAddress;
    address public airdropAddress;
    uint256 private airdropAmount;
    uint256 public _accHolderBonus; // scc
    // nft address
    IERC721Card  public nftToken;
    
    uint256 public _tokenPrice;
    uint256 lastPrice0Cumulative;
    uint256 lastPrice0Timestamp;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    uint256 public _maxTxAmount = 10 * 10**4 * 10**6;
    uint256 private numTokensSellToAddToLiquidity = 10 * 10**8 * 10**6;
    uint256 public _onedaySeconds = 24 * 3600;
    uint256 public _maxSwapAmount = 10 * 10**4 * 10**6;
    uint256 public LUCKY_THREDHOLD = 10**16;
    
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
    
    constructor (address pancakeRouter, address nftAddress_, address blackholeAddress_, address airdropAddress_) {
        _tOwned[_msgSender()] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(pancakeRouter);
         // Create a uniswap pair for this new token
        // uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        //   .createPair(address(this), _uniswapV2Router.WETH());
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        blackholeAddress = blackholeAddress_;
        airdropAddress = airdropAddress_;
        // nftToken = IERC721Card(nftAddress_);
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _tokenPrice = 40; // 1_scc_wei = 40 eth_wei
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    function tokenPrice() public view returns (uint256) {
        return _tokenPrice;
    }
    
    function blackholeAmount() public view returns (uint256) {
        return balanceOf(blackholeAddress);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setBlackholeFeePercent(uint256 blackholeFee) external onlyOwner() {
        _blackholeFee = blackholeFee;
    }

    // function setLuckyBonusFeePercent(uint256 luckyBonusFee) external onlyOwner() {
    //     _luckyBonusFee = luckyBonusFee;
    // }

    // function setHolderBonusFeePercent(uint256 holderBonusFee) external onlyOwner() {
    //     _holderBonusFee = holderBonusFee;
    // }

    function setAirdropFeePercent(uint256 airdropFee) external onlyOwner() {
        _airdropFee = airdropFee;
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        _liquidityFee = liquidityFee;
    }
   
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**4
        );
    }
    
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }

    function setOnedayTime(uint onedaySeconds) external onlyOwner() {
        _onedaySeconds = onedaySeconds;
    }
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getFeeValues(uint256 tAmount) private view
        returns (uint256, uint256, uint256, uint256) {
        uint256 tBlackholeFee = calculateBlackholeFee(tAmount);
        uint256 tLiquidityFee = calculateLiquidityFee(tAmount);
        // uint256 tLuckyBonusFee = calculateLuckyBonusFee(tAmount);
        // uint256 tHolderBonusFee = calculateHolderBonusFee(tAmount);
        uint256 tAirdropFee = calculateAirdropFee(tAmount);
        uint256 tAllTaxFee = calculateAllTaxFee(tAmount);

        uint256 tTransferAmount = tAmount.sub(tAllTaxFee);
        return (tTransferAmount, tBlackholeFee, tAirdropFee, tLiquidityFee);
    }

    function calculateAllTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_allTaxFee).div(
            10**2
        );
    }

    function calculateBlackholeFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_blackholeFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**2
        );
    }

    // function calculateLuckyBonusFee(uint256 _amount) private view returns (uint256) {
    //     return _amount.mul(_luckyBonusFee).div(
    //         10**2
    //     );
    // }

    // function calculateHolderBonusFee(uint256 _amount) private view returns (uint256) {
    //     return _amount.mul(_holderBonusFee).div(
    //         10**2
    //     );
    // }

    function calculateAirdropFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_airdropFee).div(
            10**2
        );
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool fromSwap; 
        address limitAddress;
        fromSwap = false;
        if(from == uniswapV2Pair) {
            limitAddress = to;
            fromSwap = true;
        } else if (to == uniswapV2Pair) {
            limitAddress = from;
            fromSwap = true;
        }
        if(fromSwap && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]
            && from != owner() && to != owner()) {
            if ( _lastTransferLimitTime[limitAddress] < 1)
                _lastTransferLimitTime[limitAddress] = block.timestamp;
            if ( _lastTransferLimitCount[limitAddress]>=20 ) {
                if (block.timestamp.sub(_lastTransferLimitTime[limitAddress]) >= _onedaySeconds) {
                    _lastTransferLimitCount[limitAddress] = 0;
                    _lastTransferLimitTime[limitAddress] = block.timestamp;
                }
                else
                    require(_lastTransferLimitCount[limitAddress]<20, "Transfer exceeds limit 20 times per day .");
            }
            
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            
            _lastTransferTime[from] = block.timestamp;
            _lastTransferLimitCount[limitAddress] = _lastTransferLimitCount[limitAddress].add(1);
        }
        
        // // is the token balance of this contract address over the min number of
        // // tokens that we need to initiate a swap + liquidity lock?
        // // also, don't get caught in a circular liquidity event.
        // // also, don't swap & liquify if sender is uniswap pair.
        // uint256 contractTokenBalance = balanceOf(address(this));
        
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _maxSwapAmount)
        {
            contractTokenBalance = _maxSwapAmount;
        }
        // uint256 currentSupply = _tTotal - balanceOf(blackholeAddress);
        
        // numTokensSellToAddToLiquidity = currentSupply.div(100000);
        
        // bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            // overMinTokenBalance &&
            !inSwapAndLiquify &&
            // from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            // contractTokenBalance = numTokensSellToAddToLiquidity;
            // Deal bonus and liquidity
            dealBonusAndLiquify(contractTokenBalance);
        }

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
        
        if ( !Address.isContract(to) ) {
            rand = nftToken.balanceOf(to)>5 ? rand * 3 /2 : rand;
            if ( rand <= 5 && amount > 1000e6){
                isLucky = true;
                level = 4;
            } else
            if ( rand <= 5 && amount > 500e6){
                isLucky = true;
                level = 3;
            } else
            if ( rand <= 10 && amount > 500e6){
                isLucky = true;
                level = 2;
            } else
            if (rand <= 20 && amount > 100e6) {
                isLucky = true;
                level = 1;
            } else
            if (rand <= 30 && amount >= 100e6) {
                isLucky = true;
                level = 0;
            }
            if (isLucky) {
                nftToken.mintWithLevel(level, to);
            }
        }
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _tokenTransferWithoutFee(from, to, amount);
            
        } else
            //transfer amount, it will take tax, burn, liquidity fee
            _tokenTransferWithFee(from, to, amount);
        
    }

    // Get a random 100
    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%100);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function dealHolderBonus() private {
        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify
            // from != uniswapV2Pair &&
            // swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            // Deal bonus and liquidity
            dealBonusAndLiquify(contractTokenBalance);
        }
    }

    function dealBonusAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        // 3/8 for liquidity, 5/8 for holder bonus
        uint256 half = contractTokenBalance.div(2); // 
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(otherHalf); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        
        // add liquidity to uniswap
        addLiquidity(half, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function getHolderBonusInfo() public view returns(bool, uint256, uint256, uint256) {
        uint256 totalBalance = _tTotal.sub(balanceOf(owner())).sub(balanceOf(address(this)))
            .sub(balanceOf(address(blackholeAddress)));
        uint256 pooledETH = address(this).balance;
        // 0.0001 ETH, can claim bonus
        bool hazBonus = (pooledETH > 10**15) 
            && (block.timestamp.sub(_lastClaimBonusTime[_msgSender()]) >= _onedaySeconds)
            && (block.timestamp.sub(_lastTransferTime[_msgSender()]) >= _onedaySeconds);
        uint256 bonus = balanceOf(_msgSender());
        return (hazBonus, bonus, totalBalance, pooledETH);
    }

    function claimForHolderBonus() public returns (bool) {
        uint256 pooledETH = address(this).balance;
        require(pooledETH > 10**15, "Total reward pool little than 0.1ETH.");
        require(block.timestamp.sub(_lastClaimBonusTime[_msgSender()]) >= _onedaySeconds, "Last claim time little than 24 Hours.");
        require(block.timestamp.sub(_lastTransferTime[_msgSender()]) >= _onedaySeconds, "Last tranfer time less than 24 Hours");

        _lastClaimBonusTime[_msgSender()] = block.timestamp;
        uint256 totalBalance = _tTotal.sub(balanceOf(owner())).sub(balanceOf(address(this)))
            .sub(balanceOf(address(blackholeAddress)));

        uint256 rate = _tOwned[_msgSender()].mul(10000).div(totalBalance);

        // single account should little than 5%
        if (rate > 500) {
            rate = 500;
        }
        uint256 ethValue = pooledETH.mul(rate).div(10000);
        // transfer to address
        payable(msg.sender).transfer(ethValue);
        
        return true;
    }

    function _tokenTransferWithFee(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tBlackholeAmount,
            uint256 tAirdropBonus, uint256 tLiquidity) = _getFeeValues(tAmount);
        // total token from sender
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        // real amount to recipient
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        //indicates if fee should be deducted from transfer
        // to lucky bonus account
        // _tOwned[luckyBonusAddress] = _tOwned[luckyBonusAddress].add(tLuckyBonusAmount);
        // to acc holder bonus account
        // _accHolderBonus = _accHolderBonus.add(tHolderBonusAmount);
        // to airdrop 
        _tOwned[airdropAddress] = _tOwned[airdropAddress].add(tAirdropBonus);

        _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);

        emit Transfer(sender, recipient, tTransferAmount);
        if (balanceOf(address(blackholeAddress)) < BLACKHOLE_LIMIT) {
            // to blackhole
            _tOwned[blackholeAddress] = _tOwned[blackholeAddress].add(tBlackholeAmount);
            emit Transfer(sender, blackholeAddress, tBlackholeAmount);
        }
        
        // emit Transfer(sender, luckyBonusAddress, tLuckyBonusAmount);
        emit Transfer(sender, airdropAddress, tAirdropBonus);
    }

    function _tokenTransferWithoutFee(address sender, address recipient, uint256 tAmount) private {
        // total token from sender
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        // real amount to recipient
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function setNFTToken(address nftAddress_) public onlyOwner{
        require(nftAddress_ != address(0));
        nftToken = IERC721Card(nftAddress_);
    }
}
