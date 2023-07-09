# Access NFT Project

This project is meant to build out a set of tools which help owners of NFTs
monetize the underlying content of their NFTs by providing and enforcing ownership 
of various access types.

If the creator of an NFT collection (a.k.a the Content Contract) chooses to, they would be able to plug their collection into the contracts within this project in a way where each token Id on the collection would have accompanying tokens on the Access contracts(s) and accompanying tokens on the Owners contract. The Access contract(s) are ERC1155 tokens that are minted to accounts which pay to obtain the given access type (1 ERC1155 contract per access type). The Owners contract is an ERC1155 that is used to track which accounts are compensated for payments made to access a given token. Each Owner tokenId has a supply limit of 10000 where 1 token represents 1 basis point of ownership.

Monetization tools for NFTs are useful when the owner of some content does not want to sell ownership of the content but wants to generate revenue from it by selling access to the content. Additionally the content owner would be able to sell the ownership of the revenues generated to access the content, in other words sell the future cash flows from the content. Cash up front in exchange for future cash flows grants the content owner an opportunity to make other investments. The owners of the revenues become incentivized to increase revenue generation from the content.

## Access NFT(s)
- There can be multiple Access NFTs per collection (Content Contract) where there is 1 Access NFT per access type (access types determined during deployment)
- A token Id maps to the same token Id on the Content Contract
- Implements ERC1155 so that multiple accounts can have the same access type to the same content

## Owners NFT
- A token Id maps to the same token Id on the Content Contract
- Implements ERC1155 so that the share of access revenue generated from the corresponding content can be divided among multiple accounts.

## The Content Contract (not developed within this project)
- Must be an ERC721
- Content can be concealed and only revealed to accounts which own a given Access ERC1155 token in which case the access type is enforced. An example of an Access type is "view for 1 week" where if an account with a token of that access type wants to view the content then a payment must have been made within the last week.

## Flow of Funds
1. An `accessor` will pay for for a certain access type (say for example to have access to the content for 1 day) - let's say then want to access token with Id `132`.
2. Upon payment, multiple things will happen: the Access NFT will post a timestamp of when the payment was made, the funds will be transferred to a `PaymentManager` contract, and `accessor` will be minted an ERC1155 token on the Access NFT contract (if does not already own the given token Id on the AccessNFT).
3. When the `accessor` wants to "access" the content of the tokenId on the collection which they paid for, then the timestamp which they paid can be checked to make sure it happened less than 1 day ago and the ownership of the ERC1155 with token Id `132` (on the Access NFT) can be checked to make sure the accessor did not pay and then sell/transfer the ERC1155 (prevents double dipping). Note that these checks would happen off-chain, but the data to check is on-chain.
4. The `Owners` ERC1155 contract will track which accounts "own" the rights to redeem payments to access a given token Id's content. For example if account `0xabc` owns all 10000 units of token Id `132` on the `Owners` ERC1155 then only account `0xabc` can withdraw all payments made to access token Id `132` (across all access types). Note that account `0xabc` must withdraw all funds paid to access token Id `132` before transferring token(s) (ownership share) of `132` on the Owner ERC1155.

Remarks:
- Payments are divided among Owners ERC1155 token owners ON the payment (via a mapping), so payment calls are more complex than withdrawals. This design choice was made to properly divide payments among owners in an idempotent way e.g. if an owner withdraws, only that account's share is decremented.
- Withdrawals by accounts which own Owners ERC1155 tokens must be done at the token level because a given account can own revenue share for multiple tokens (withdrawals are managed by a single contract called the PaymentFacilitator).
- The PaymentManager is a single contract which holds all payments until the payments are withdrawn by the revenue owners. Having a single contract manage funds is an intentional design choice because payments and withdrawals will interact with a single underlying contract as opposed to requiring several calls to push/pull funds.
