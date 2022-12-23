// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../interfaces/IConfig.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title Access ERC1155 Contract
 * @notice Accessors of Content Contracts become owners of an NFT.
 * Ownership of the NFT can be checked when access to the Content Contract is requested.
 * Each Access Type would require its own Access NFT contract.
 * Assumption: TokenIds on this NFT contract map to the tokenId on the Contract Contract.
 */
contract Access is ERC1155 {
    string ACCESS_TYPE;
    IConfig private config;

    // tokenId => price to access the token
    mapping(uint256 => uint256) prices;

    constructor(string memory _accessType, address _contentConfig, string memory uri_) ERC1155(uri_) {
        ACCESS_TYPE = _accessType;
        config = IConfig(_contentConfig);
    }

    function mint(uint256 _id, address _to) external {
        require(msg.sender == config.getPaymentFacilitator());
        _mint(_to, _id, 1, "");
    }

    function setPrice(uint256 _id, uint256 _price) external {
        IERC721 owners = IERC721(config.getOwnersContract());
        address owner = owners.ownerOf(_id);
        bool isApproved = owners.isApprovedForAll(owner, msg.sender);
        require(msg.sender == owner || isApproved);
        prices[_id] = _price;
    }

    function getPrice(uint256 _id) external view returns(uint256) {
        return prices[_id];
    }
}
