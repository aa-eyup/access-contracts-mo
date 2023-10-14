// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IPaymentManager {
    function pay(uint256 _tokenId, address _payer, address _accessNFT, address _accessor, bytes32 _accessType) external returns(uint256);
    function withdraw(address _recipient, uint256 _amountToWithdraw, uint256 _tokenId) external;
}
