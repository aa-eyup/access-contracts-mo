// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Owners ERC721 contract
 * @notice Used as source of truth regarding which account "owns" rights over the funds paid to access a given token
 * on the Content Contract. The owner of a given token id will have the rights to the entirety of funds paid for all access types 
 * for the respective token id's content. 
 * A token id on the Content Contract corresponds to the same token id on the Access NFTs and Owners NFT.
 */
contract Owners is ERC721 {
    address private config;

    constructor(address _contentConfig) ERC721("Access Payment Owners NFT", "APO") {
        config = _contentConfig;
    }
}
