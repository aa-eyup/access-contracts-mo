// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/**
 * Accessors of Content Contracts become owners of an NFT.
 * Ownership of the NFT can be checked when access to the Content Contract is requested.
 * Each Access Type would require its own Access NFT contract.
 * Assumption: TokenIds on this NFT contract map to the tokenId on the Contract Contract.
 */
contract Access is ERC1155 {
    string ACCESS_TYPE;
    address private CONFIG;


    constructor(string memory _accessType, address _contentConfig, string memory uri_) ERC1155(uri_) {
        ACCESS_TYPE = _accessType;
        CONFIG = _contentConfig;
    }
}
