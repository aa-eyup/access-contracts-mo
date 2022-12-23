// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IConfig {
    function getPaymentFacilitator() external view returns(address);
    function getOwnersContract() external view returns(address);
    function getAccessNFT(string memory _accessType) external view returns(address);
}