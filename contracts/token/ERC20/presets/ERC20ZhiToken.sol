// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../extensions/ERC20Burnable.sol";
// import "../../ERC721/utils/ERC721Holder.sol";
import "../../../access/Ownable.sol";
import "../../../utils/math/SafeMath.sol";
import "../../../utils/Address.sol";
import "../extensions/ERC20Pausable.sol";
import "../../../access/AccessControlEnumerable.sol";
import '../../../interfaces/IUniswapV2Factory.sol';
// import '../../../interfaces/IUniswapV2Pair.sol';
// import '../utils/BetaOracleUniswapV2.sol';
import '../../../interfaces/IJustswapExchange.sol';

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

contract ERC20ZhiToken is Context, ERC20Burnable, ERC20Pausable, AccessControlEnumerable, Ownable {
    using SafeMath for uint256;
    using Address for address;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    // IUniswapV2Router02 public immutable uniswapV2Router;
    // BetaOracleUniswapV2 oracleUniswap;
    // address public immutable uniswapV2Pair;
    // address public uniswapV2Pair;
    address public immutable blackholeAddress;
    address public immutable airdropAddress;
    // address public immutable liquidAddress;
    // ERC721Card public nftToken;
    uint256 public initialSupply;
    uint256 public lastRemainSupply;
    uint256 public startTimestamp;
    // bool inSwapAndLiquify;
    // bool public swapAndLiquifyEnabled = false;
    // uint256 level1EthValue;
    // uint256 level2EthValue;
    // uint256 level3EthValue;

    // Fee
    uint256 private blackholeFeeRate = 7;
    // uint256 private liquidityFeeRate = 1;
    uint256 private airdropFeeRate = 1;
    uint256 private allTxFeeRate = 8; // all up fee.

    // uint256 public minTokensSellToAddToLiquidity = 500 * 10**decimals();

    // Mapping
    mapping (address => bool) private _isExcludedFromFee;

    // event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    // event SwapAndLiquifyEnabledUpdated(bool enabled);
    // event SwapAndLiquify(
    //     uint256 tokensSwapped,
    //     uint256 ethReceived,
    //     uint256 tokensIntoLiqudity
    // );
    
    // modifier lockTheSwap {
    //     inSwapAndLiquify = true;
    //     _;
    //     inSwapAndLiquify = false;
    // }

    /**
     * @dev Mints `initialSupply` amount of token and transfers them to `owner`.
     *
     * See {ERC20-constructor}.
     */
    // constructor (address pancakeRouter, address nftAddress_, address blackholeAddress_, address airdropAddress_)
    constructor(
        // address pancakeRouter,
        // address _blackholeAddress,
        address _airdropAddress,
        // address _liquidAddress,
        uint256 _initialSupply,
        uint256 _lastRemainSupply,
        uint256 _startTimestamp,
        address owner
    ) ERC20("MyZhi Token", "MyZhi") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        blackholeAddress = address(0);
        airdropAddress = _airdropAddress;
        // liquidAddress = _liquidAddress;
        startTimestamp = _startTimestamp;
        initialSupply = _initialSupply * (10**decimals());
        lastRemainSupply = _lastRemainSupply * (10**decimals());
        // level1EthValue = 1.3e18;
        // level2EthValue = 3.9e18;
        // level3EthValue = 7.8e18;
        
        // uniswapV2Router = IUniswapV2Router02(pancakeRouter);
        // nftToken = new ERC721Card(msg.sender, "MagicBean NFT", "BEANNFT", "https://api.magicbean.cc/tokens/");

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        // _isExcludedFromFee[_liquidAddress] = true;
        _isExcludedFromFee[_airdropAddress] = true;
        _mint(owner, initialSupply);
    }
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    // Get a random 1000
    // function random() internal view returns (uint8) {
    //     return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%1000);
    // }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool){
        // require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        // uint8 level = 0;
        // bool isLucky = false;
        // rand = nftToken.balanceOf(to)>5 ? rand * 3 /2 : rand;
        // if (msg.sender == uniswapV2Pair) {
        //     IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
        //     uint112 reserve0;
        //     uint112 reserve1;
        //     // uint32  timeBlock;
        //     require(block.timestamp >= startTimestamp, "Token transfer didn't start.");
        //     (reserve0, reserve1, ) = pair.getReserves();
        //     // uint256 ethAmount = oracleUniswap.getAssetETHValue(address(this), amount);
        //     uint256 ethAmount = uniswapV2Router.quote(amount, reserve0, reserve1);
            
        //     if (ethAmount >= level1EthValue) { // 500U, 1BNB
        //         isLucky = true;
        //         level = 0;
        //     } 
        // }
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        // if(balanceOf(msg.sender) == amount && amount > 1e18) {
        //     amount -= 1e18;
        // }
        if(_isExcludedFromFee[msg.sender] || _isExcludedFromFee[to] || totalSupply() < lastRemainSupply){
            _transfer(msg.sender, to, amount);
        }
        else {
            _burn(msg.sender, amount.mul(blackholeFeeRate).div(100));
            _transfer(msg.sender, airdropAddress, amount.mul(airdropFeeRate).div(100));
            // _transfer(msg.sender, liquidAddress, amount.mul(liquidityFeeRate).div(100));
            _transfer(msg.sender, to, amount.sub(amount.mul(allTxFeeRate).div(100)));
        }
        return true;
        
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        //if any account belongs to _isExcludedFromFee account then remove the fee
        // oracleUniswap.updatePriceFromPair(address(this));
        // if(balanceOf(sender) == amount && amount > 1e18) {
        //     amount -= 1e18;
        // }
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient] || totalSupply() < lastRemainSupply){
            _transfer(sender, recipient, amount);
        } else {
            //transfer amount, it will take tax, burn, liquidity fee
            _transfer(sender, blackholeAddress, amount.mul(blackholeFeeRate).div(100));
            _transfer(sender, airdropAddress, amount.mul(airdropFeeRate).div(100));
            // _transfer(sender, liquidAddress, amount.mul(liquidityFeeRate).div(100));
            _transfer(sender, recipient, amount.sub(amount.mul(allTxFeeRate).div(100)));
        }
        _approve(sender, msg.sender, allowance(sender,msg.sender).sub(amount, "ERC20: transfer amount exceeds allowance"));

        return true;
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint(to, amount);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
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

    // function setNFTToken(address nftAddress_) public onlyOwner{
    //     require(nftAddress_ != address(0));
    //     nftToken = ERC721Card(nftAddress_);
    // }

    function setExcludeFromFee(address account) public onlyOwner{
        _isExcludedFromFee[account] = true;
    }
    
    function setIncludeInFee(address account) public onlyOwner{
        _isExcludedFromFee[account] = false;
    }
    
    // function setBlackholeFeePercent(uint256 blackholeFee) external onlyOwner() {
    //     blackholeFeeRate = blackholeFee;
    // }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    // function setLuckyBonusFeePercent(uint256 luckyBonusFee) external onlyOwner() {
    //     _luckyBonusFee = luckyBonusFee;
    // }

    // function setHolderBonusFeePercent(uint256 holderBonusFee) external onlyOwner() {
    //     _holderBonusFee = holderBonusFee;
    // }

    // function setAirdropFeePercent(uint256 airdropFee) external onlyOwner() {
    //     airdropFeeRate = airdropFee;
    // }

    function setStartTimestamp(uint256 timestamp) external onlyOwner() {
        startTimestamp = timestamp;
    }

    // function setNftLevelEthValue(uint256 level1, uint256 level2, uint256 level3) external onlyOwner(){
    //     level1EthValue = level1;
        // level2EthValue = level2;
        // level3EthValue = level3;
    // }
    
    // function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
    //     liquidityFeeRate = liquidityFee;
    // }

    // function setMinTokenAddLiquidity(uint256 minTokenAddLiquidity) external onlyOwner() {
        // minTokensSellToAddToLiquidity = minTokenAddLiquidity;
    // }

    // function setSwapAndLiquifyEnabled(bool enabled) public onlyOwner {
    //     if (uniswapV2Pair == address(0)) {
    //         // Create a uniswap pair for this new token
    //         uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
    //           .createPair(address(this), uniswapV2Router.WETH());
    //         // _isExcludedFromFee[uniswapV2Pair] = true;
    //         // oracleUniswap = new BetaOracleUniswapV2(uniswapV2Router.WETH(), uniswapV2Router.factory(), 3);
    //         // oracleUniswap.initPriceFromPair(address(this));
    //     }
    //     swapAndLiquifyEnabled = enabled;
    //     emit SwapAndLiquifyEnabledUpdated(enabled);
    // }
}
