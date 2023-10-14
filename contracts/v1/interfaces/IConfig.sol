// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IConfig {
    function getPaymentFacilitator() external view returns(address);
    function getOwnersContract() external view returns(address);
    function getAccessNFT(bytes32 _accessType) external view returns(address);
    function getContentNFT() external view returns(address);
}
