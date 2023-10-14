// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ContentContract1155 is ERC1155 {
    constructor(address _owner, uint256 _tokenId) ERC1155("") {
        _mint(_owner, _tokenId, 1, "");
    }

    function mint(address _owner, uint256 _tokenId) external {
        _mint(_owner, _tokenId, 1, "");
    }
}
