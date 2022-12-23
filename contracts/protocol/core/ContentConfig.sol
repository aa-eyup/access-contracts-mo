// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../interfaces/IConfig.sol";

/**
 * Getter for contracts associated to a given Content Contract.
 * Deployed first then after the content related contract are related, this config is updated,
 */
contract ContentConfig is IConfig {
    string ACCESS_TYPE_VIEW_MONTHLY = "access-type-view-monthly";
    string ACCESS_TYPE_ADVERTISE = "access-type-advertise";

    address paymentFacilitator;
    address owners;
    mapping(string => address) accessNFTs;
    
    // TODO only owner
    function init(string[] memory _accessTypes, address[] memory _accessNFTs, address _paymentFacilitator, address _owners) external {
        assert(_accessTypes.length != 0 && _accessNFTs.length != 0);
        assert(_accessTypes.length == _accessNFTs.length);

        for (uint8 i = 0; i < _accessTypes.length; i++) {
            accessNFTs[_accessTypes[i]] = _accessNFTs[i];
        }

        paymentFacilitator = _paymentFacilitator;
        owners = _owners;
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
