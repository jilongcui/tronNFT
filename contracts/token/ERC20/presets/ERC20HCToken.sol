// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../access/Ownable.sol";
import "../../../utils/math/SafeMath.sol";
import "../../../utils/Address.sol";
import "../../../access/AccessControlEnumerable.sol";
import '../../../interfaces/IUniswapV2Factory.sol';
import '../../../interfaces/IJustswapExchange.sol';
import "../extensions/ERC20Burnable.sol";
import "../extensions/ERC20Pausable.sol";

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

contract ERC20HCToken is Context, ERC20Burnable, AccessControlEnumerable, Ownable {
    using SafeMath for uint256;
    using Address for address;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // public
    uint256 public initialSupply;

    // private

    // Mapping
    mapping (address => bool) private _isExcludedFromFee;

    /**
     * @dev Mints `initialSupply` amount of token and transfers them to `owner`.
     *
     * See {ERC20-constructor}.
     */
    constructor(
        uint256 _initialSupply,
        address owner
    ) ERC20("HongChengTest Token", "HCTest") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        initialSupply = _initialSupply * (10**decimals());
        
        _mint(owner, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool){
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= 5*10**decimals(), "Transfer amount must be greater than zero");
        
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= 5*10**decimals(), "Transfer amount must be greater than zero");
        _transfer(sender, recipient, amount);
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
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20: must have minter role to mint");
        _mint(to, amount);
    }

}
