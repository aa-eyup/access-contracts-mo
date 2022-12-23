// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * Carries information regarding which account "owns" a given token on a Content Contract.
 * Only the owner of the token on the Content Contract can withdraw funds which were deposited
 * for that particular token.
 */
contract Owners is ERC721 {
    address private config;

    constructor(address _contentConfig) ERC721("name", "symbol") {
        config = _contentConfig;
    }
}
