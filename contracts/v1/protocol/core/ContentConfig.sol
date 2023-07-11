// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../interfaces/IConfig.sol";
import "./BaseRoleCheckerPausable.sol";

/**
 * @title ContentConfig
 * @notice Used as getter for contracts associated to a given Content Contract.
 * Deployed first then after the content related contract are related, this config is updated,
 */
contract ContentConfig is IConfig, BaseRoleCheckerPausable {

    address paymentFacilitator;
    address owners;
    address contentContract;
    // keccak256 of access type's name maps to the address of the Access NFT contract
    mapping(bytes32 => address) accessNFTs;

    constructor(address _admin) {
        __BaseRoleCheckerPausable__init(_admin);
    }

    function __ContentConfig__init(
        bytes32[] memory _accessTypes,
        address[] memory _accessNFTs,
        address _paymentFacilitator,
        address _owners,
        address _contentContract
    ) external onlyAdmin {
        require(_accessTypes.length == _accessNFTs.length && _accessNFTs.length != 0);

        for (uint8 i = 0; i < _accessTypes.length; i++) {
            accessNFTs[_accessTypes[i]] = _accessNFTs[i];
        }

        paymentFacilitator = _paymentFacilitator;
        owners = _owners;
        contentContract = _contentContract;
    }

    function getPaymentFacilitator() external view returns(address) {
        return paymentFacilitator;
    }

    function getOwnersContract() external view returns(address) {
        return owners;
    }

    function getAccessNFT(bytes32 _accessType) external view returns(address) {
        address accessContract = accessNFTs[_accessType];
        require(accessContract != address(0), "Access type does not have a corresponding AccessNFT");
        return accessContract;
    }

    function getContentNFT() external view returns(address) {
        return contentContract;
    }
}
