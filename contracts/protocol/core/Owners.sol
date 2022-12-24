// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Owners ERC721 contract
 * @notice Used as source of truth regarding which account "owns" rights over the funds paid to access a given token
 * on the Content Contract.
 */
contract Owners is ERC721 {
    address private config;

    constructor(address _contentConfig) ERC721("name", "symbol") {
        config = _contentConfig;
    }
}
