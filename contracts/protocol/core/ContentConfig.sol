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
    string ACCESS_TYPE_VIEW_MONTHLY = "access-type-view-monthly";
    string ACCESS_TYPE_ADVERTISE = "access-type-advertise";

    address paymentFacilitator;
    address owners;
    address contentContract;
    mapping(string => address) accessNFTs;

    constructor(address _admin) {
        __BaseRoleCheckerPausable__init(_admin);
    }
    
    function init(
        string[] memory _accessTypes,
        address[] memory _accessNFTs,
        address _paymentFacilitator,
        address _owners,
        address _contentContract
    ) external onlyAdmin {
        require(_accessTypes.length != 0 && _accessNFTs.length != 0);
        require(_accessTypes.length == _accessNFTs.length);

        for (uint8 i = 0; i < _accessTypes.length; i++) {
            accessNFTs[_accessTypes[i]] = _accessNFTs[i];
        }

        paymentFacilitator = _paymentFacilitator;
        owners = _owners;
        contentContract = _contentContract;
    }

    function getPaymentFacilitator() external view returns(address){
        return paymentFacilitator;
    }

    function getOwnersContract() external view returns(address) {
        return owners;
    }

    function getAccessNFT(string memory _accessType) external view returns(address){
        return accessNFTs[_accessType];
    }

}
