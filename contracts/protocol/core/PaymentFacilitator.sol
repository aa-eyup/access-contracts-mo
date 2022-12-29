// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../../interfaces/IPaymentManager.sol";
import "../../interfaces/IConfig.sol";

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

    // keep track of how much Owners are paid
    mapping(address => uint256) paid;

    /**
     * @dev Emitted when tokens are transferred from `payer` to the PaymentManager contract to gain access to token `id` on the `accessNFT` contract
     */
    event AccessPayment(address indexed accessNFT, address indexed accessor, address indexed payer, uint256 id);
    /**
     * @dev Emitted when an owner withdraws funds which were paid to access a given `id` accross all `accessNFT`s
     */
    event Withdraw(address indexed owner, uint256 amount, uint256 id);

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

    /**
     * @dev Creates a transfer from the `_payer` to the PaymentManager where the funds are earmarked for the owner of `_id`.
     * The price to pay is looked up from the accessNFT.
     * If the balance of the `_accessor` for the given `_id` on the accessNFT is not greater than 0,
     * then a token with id `_id` will be minted to the `_accessor`.
     * A timestamp will be set to reflect the time of payment for the `_accessor` and then given `_id` on the respective accessNFT.
     *
     * Emits a {AccessPayment} event.
     *
     * Requirements:
     *
     * - the PaymenetManager contract must be approved by the `_payer` on the stablecoin's ERC20 contract
     * - `_accessType` must be a valid access type which was set on the Config contract during initialization.
     */
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

        emit AccessPayment(address(accessNFT), _accessor, _payer, _id);
        return true;
    }

    /**
     * @dev Creates a transfer from the PaymentManager contract to the owner of the `_id` 
     * as identified by the Owners NFT contract (not the owner of the id on the Content Contract).
     * 1 owner maps to multiple accessNFTs so the owner has the rights to all funds paid for multiple access types.
     *
     * Emits a {Withdraw} event.
     *
     * Requirements:
     *
     * - the caller of the function (msg.sender) must be owner of `_id` on the Owners contract
     * - amount of funds paid to access the given `_id` must be greater than 0
     */
    function withdraw(uint256 _id) external returns(uint256) {
        IERC721 owners = IERC721(config.getOwnersContract());
        address owner = owners.ownerOf(_id);
        require(msg.sender == owner);
        require(paid[owner] > 0);
        
        uint256 amountToWithdraw = paid[owner];
        paid[owner] = paid[owner] - amountToWithdraw;
        paymentManager.withdraw(owner, amountToWithdraw);
        emit Withdraw(owner, amountToWithdraw, _id);

        return (amountToWithdraw);
    }
}
