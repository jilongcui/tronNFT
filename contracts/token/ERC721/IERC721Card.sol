// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Card is IERC721 {

    struct LevelInfo {
        uint16 total;
        uint16 current;
        uint16 power;
    }
    
    event MintWithLevel(address indexed to, uint16 level, uint256 id);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function levelOf(uint256 id) external view returns (uint8 level);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function levelView(uint8 level) external view returns (LevelInfo memory);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function mintWithLevel(uint8 _level, address to) external returns(bool);
}
