// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../extensions/ERC20Burnable.sol";
import "../../../access/Ownable.sol";
import "../../../utils/math/SafeMath.sol";
import "../../../utils/Address.sol";
import "../extensions/ERC20Pausable.sol";
import "../../../access/AccessControlEnumerable.sol";

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
    address public immutable blackholeAddress;
    address public immutable airdropAddress;
    // address public immutable liquidAddress;
    uint256 public initialSupply;
    uint256 public lastRemainSupply;
    uint256 public startTimestamp;

    // Fee
    uint256 private blackholeFeeRate = 7;
    // uint256 private liquidityFeeRate = 1;
    uint256 private airdropFeeRate = 1;
    uint256 private allTxFeeRate = 8; // all up fee.


    // Mapping
    mapping (address => bool) private _isExcludedFromFee;

    /**
     * @dev Mints `initialSupply` amount of token and transfers them to `owner`.
     *
     * See {ERC20-constructor}.
     */
    constructor(
        address _airdropAddress,
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
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_airdropAddress] = true;
        _mint(owner, initialSupply);
    }
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool){
        // require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
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

    function setExcludeFromFee(address account) public onlyOwner{
        _isExcludedFromFee[account] = true;
    }
    
    function setIncludeInFee(address account) public onlyOwner{
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function setStartTimestamp(uint256 timestamp) external onlyOwner() {
        startTimestamp = timestamp;
    }
}
