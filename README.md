# Access NFT Project

This project is meant to build out a set of tools which help owners of NFTs
monetize the underlying content of their NFTs by providing and enforcing ownership 
of various access types.

If the creator of an NFT collection (a.k.a the Content Contract) chooses to, they would be able to plug their collection into the contracts within this project in a way where each token Id on the collection would have an accompanying token on Access NFT(s) and an accompanying token on an Owners NFT.

Monetization tools for NFTs are useful when the owner of some content does not want to sell ownership of the content but wants to generate revenue from it by selling access to the content. Additionally the content owner would be able to sell the ownership of the revenues generated to access the content, in other words sell the future cash flows from the content. Cash up front in exchange for future cash flows grants the content owner an opportunity to make other investments. The owners of the revenues become incentivized to increase revenue generation from the content.

## Access NFT(s)
- There can be multiple Access NFTs per collection (Content Contract) where there is 1 Access NFT per access type (access types determined during deployment)
- A token Id maps to the same token Id on the Content Contract
- Implements ERC1155 so that multiple accounts can have the same access type to the same content

## Owners NFT
- A token Id maps to the same token Id on the Content Contract
- Implements ERC721 because there can only be 1 owner with the rights to redeem the payments made for a given token Id across all access types
- The owner of the access payments does not have to be same as the owner of the token on the Content Contract

## The Content Contract (not developed within this project)
- Must be an ERC721 or ERC1155

## Flow of Funds
1. An `accessor` will pay for for a certain access type (say for example to have access to the content for 1 day) - let's say then want to access token with Id `132`
2. Upon payment, multiple things will happen: the Access NFT will post a timestamp of when the payment was made, the funds will be transferred to a `PaymentManager` contract, and `accessor` will be minted an ERC1155 token on the Access NFT contract (if does not already own the given token Id on the AccessNFT)
3. When the `accessor` wants to "access" the content of the tokenId on the collection which they paid for, then the timestamp which they paid can be checked to make sure it happened less than 1 day ago and the ownership of the ERC1155 with token Id `132` (on the Access NFT) can be checked to make sure the accessor did not pay and then sell/transfer the ERC1155 (prevents double dipping). Note that these checks would happen off-chain, but the data to check is on-chain.
4. The `Owners` ERC721 contract will track which account "owns" the rights to redeem payments to access a given token Id. For example if account `0xabc` owns token Id `132` on the `Owners` ERC721 then only account `0xabc` can withdraw all payments made to access token Id `132` (across all access types). Note that account `0xabc` must withdraw all funds paid to access token Id `132` before transferring token `132` on the Owner ERC721. Also note that account `0xabc` can be a Smart Contract which divies the funds to multple stake holders in any way.
