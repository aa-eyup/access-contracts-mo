// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../interfaces/IPaymentManager.sol";
import "../../interfaces/IConfig.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title PaymentFacilitator contract
 * @notice Serves as access point to deposit/withdraw funds.
 * When a content accessor deposits funds to access content, 
 * it will be sent to this contract which will then forward it to the PaymentManager contract.
 * When a content creator wants to withdraw funds, this contract will pull funds from PaymentManager
 * and then send them to the withdrawer.
 * This contract keeps track of how many funds were deposited to access a given token ID on the Content Contract.
 * Checks the AccessNFT to see if payer already has access, if not, mints token on AccessNFT for payer.
 */
contract PaymentFacilitator {
    IConfig private config;
    IPaymentManager private paymentManager;

    mapping(address => uint256) paid;

    constructor (address _contentConfig, address _paymentManager) {
        config = IConfig(_contentConfig);
        paymentManager = IPaymentManager(_paymentManager);
    }

    function pay(uint256 _id, string memory _accessType) external returns(bool) {
        return _pay(_id, _accessType, msg.sender, msg.sender);
    }

    function payFor(uint256 _id, string memory _accessType, address _accessor) external returns(bool) {
        return _pay(_id, _accessType, _accessor, msg.sender);
    }

    function _pay(uint256 _id, string memory _accessType, address _accessor, address _payer) private returns(bool) {
        IERC1155 accessNFT = IERC1155(config.getAccessNFT(_accessType));
        IERC721 owners = IERC721(config.getOwnersContract());
        // PaymentManager is responsible for actually pulling funds
        uint256 amountPaid = paymentManager.pay(_payer, address(accessNFT), _id);

        // update the amount owner of the content token has been paid
        address owner = owners.ownerOf(_id);
        paid[owner] = paid[owner] + amountPaid;

        uint256 balance = accessNFT.balanceOf(_accessor, _id);
        if (!(balance > 0)) {
            (bool mintSuccess, ) = address(accessNFT).call(abi.encodeWithSignature("mint(uint256,address)", _id, _accessor));
            require(mintSuccess, "failed to mint acces token");
        }
        (bool setTimestampSuccess, ) = address(accessNFT).call(abi.encodeWithSignature("setPreviousPaymentTime(uint256,address)", _id, _accessor));
        require(setTimestampSuccess, "failed to set previous payment timestamp");
        // emit event for latest payment date?
        return true;
    }

    function withdraw(uint256 _id) external returns(uint256) {
        IERC721 owners = IERC721(config.getOwnersContract());
        address owner = owners.ownerOf(_id);
        require(msg.sender == owner);
        require(paid[owner] > 0);
        
        uint256 amountToWithdraw = paid[owner];
        paid[owner] = paid[owner] - amountToWithdraw;
        paymentManager.withdraw(owner, amountToWithdraw);
        return (amountToWithdraw);
    }
}
