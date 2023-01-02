// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IPaymentManager {
    function pay(uint256 _tokenId, address _payer, address _accessNFT) external returns(uint256);
    function withdraw(address _recipient, uint256 _amountToWithdraw) external;
}