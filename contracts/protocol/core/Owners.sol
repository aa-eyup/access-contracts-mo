// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Owners ERC721 contract
 * @notice Carries information regarding which account "owns" a given token on a Content Contract.
 * Ownership pertains to rights over the funds paid to access a particular token.
 */
contract Owners is ERC721 {
    address private config;

    constructor(address _contentConfig) ERC721("name", "symbol") {
        config = _contentConfig;
    }
}
