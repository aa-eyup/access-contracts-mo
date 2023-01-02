// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ContentContract721 is ERC721 {
    constructor(address _owner, uint256 _tokenId) ERC721("Test Content ERC721", "C721") {
        _mint(_owner, _tokenId);
    }

    function mint(address _owner, uint256 _tokenId) external {
        _mint(_owner, _tokenId);
    }
}