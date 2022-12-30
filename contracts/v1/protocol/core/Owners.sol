// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "../../interfaces/IConfig.sol";

/**
 * @title Owners ERC721 contract
 * @notice Used as source of truth regarding which account "owns" rights over the funds paid to access a given token
 * on the Content Contract. The owner of a given token id will have the rights to the entirety of funds paid for all access types 
 * for the respective token id's content. 
 * A token id on the Content Contract corresponds to the same token id on the Access NFTs and Owners NFT.
 */
contract Owners is ERC721 {
    IConfig private config;

    constructor(address _contentConfig) ERC721("Access Payment Owners NFT", "APO") {
        config = IConfig(_contentConfig);
    }

    /**
     * Mints the `_owner` account an ERC721 which will allow funds paid to access to given token's content
     * to be withdrawn by the `_owner`.
     * 
     * Requirements:
     * - The redeemable balance by the Owner must be 0 in order to transfer Ownership.
     * - The content contract must implement EIP165 so that the NFT type can be determined
     * - if the content contract is an ERC1155 then the msg.sender must own quantity > 0 of the given token `_id`
     * 
     * @param _id tokenId
     * @param _owner the account which has the rights to withdraw funds paid to access the given token
     */
    function setOwner(uint256 _id, address _owner) external {
        // content NFT can be ERC721 or ERC1155 or other
        address contentContract = config.getContentNFT();
        address contentOwner;
        bool isApproved;
        if (IERC165(contentContract).supportsInterface(0x80ac58cd)) {
            // content contract supports the ERC721 interface
            contentOwner = IERC721(contentContract).ownerOf(_id);
            isApproved = IERC721(contentContract).isApprovedForAll(contentOwner, msg.sender);
        } else if (IERC165(contentContract).supportsInterface(0xd9b67a26)) {
            // content contract supports the ERC1155 interface
            // the msg.sender must own some quantity of the tokenId on the ERC1155 content contract
            require(IERC1155(contentContract).balanceOf(msg.sender, _id) > 0);
            contentOwner = msg.sender;
        }
        require(msg.sender == contentOwner || isApproved, "Must own the token or be approved on the content contract to set the owner");
        _safeMint(_owner, _id);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override verifyOwnerBalance(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override verifyOwnerBalance(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override verifyOwnerBalance(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    modifier verifyOwnerBalance(address _owner) {
        address paymentFacilitator = config.getPaymentFacilitator();
        (bool checkBalanceSuccess, bytes memory balanceData) = paymentFacilitator.staticcall(abi.encodeWithSignature("getOwnerBalance(address)", _owner));
        require(checkBalanceSuccess, "Failed to check outstanding balance credited to the current owner");
        uint256 balance = abi.decode(balanceData, (uint256));
        require(balance == 0, "Balance of current owner must be be 0 before transferring ownership");
        _;
    }
}
