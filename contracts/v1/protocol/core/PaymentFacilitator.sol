// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../../interfaces/IPaymentManager.sol";
import "../../interfaces/IConfig.sol";

/**
 * @title PaymentFacilitator contract
 * @notice Serves as access point to deposit/withdraw funds.
 *
 * This contract is responsible for the accounting necessary to facilitate
 * payments and withdrawals.
 * When a content accessor pays to access content, this contract will transfer
 * funds to the PaymentManager contract.
 * When a contents' payment owner(s) want to withdraw funds,
 * this contract will pull funds from PaymentManager transferring them to the owner(s).
 */
contract PaymentFacilitator {
    IConfig private config;
    IPaymentManager private paymentManager;

    // tokenId => address => withdrawable amount
    mapping(uint256 => mapping(address => uint256)) private withdrawable;

    // tokenId => amount paid
    mapping(uint256 => uint256) private pendingAllocation;

    constructor (address _contentConfig, address _paymentManager) {
        config = IConfig(_contentConfig);
        paymentManager = IPaymentManager(_paymentManager);
    }

    function getWithdrawableBalance(address _account, uint256 _id) public view returns(uint256) {
        return withdrawable[_id][_account];
    }

    function getAmountPendingAllocation(uint256 _tokenId) public view returns(uint256) {
        return pendingAllocation[_tokenId];
    }

    function pay(uint256 _id, bytes32 _accessType) external returns(bool) {
        return _pay(_id, _accessType, msg.sender, msg.sender);
    }

    function payFor(uint256 _id, bytes32 _accessType, address _accessor) external returns(bool) {
        return _pay(_id, _accessType, _accessor, msg.sender);
    }

    /**
     * @notice Costly operation if any funds are pending allocation to token owners due to O(N) complexity where N is the number of owners for {@param _tokenId}.
     *
     */
    function allocateToOwners(uint256 _tokenId) public {
        uint256 amount = getAmountPendingAllocation(_tokenId);

        if (!(amount > 0)) {
            return;
        }

        (address[] memory tokenOwners, uint256[] memory share) = getAmountsForOwners(_tokenId, amount);

        setAmountPendingAllocation(_tokenId, 0);

        mapping(address => uint256) storage withdrawableForToken = withdrawable[_tokenId];

        for (uint16 i = 0; i < tokenOwners.length; i++) {
            withdrawableForToken[tokenOwners[i]] += share[i];
        }
    }

    function setAmountPendingAllocation(uint256 _tokenId, uint256 _amount) private {
        pendingAllocation[_tokenId] = _amount;
    }

    /**
     * @dev Calls the PaymentManager to initiate a fund transfer.
     * Allocates funds being paid to access accross the owners of the payments.
     *
     * The price to pay is looked up on the accessNFT.
     * If the balance of the `_accessor` for the given `_id` on the accessNFT is not greater than 0,
     * then a token with id `_id` will be minted to the `_accessor`.
     *
     * A timestamp will be set to reflect the time of payment for the `_accessor` and then given `_id` on the respective accessNFT.
     *
     * Requirements:
     *
     * - the PaymenetManager contract must be approved by the `_payer` on the stablecoin's ERC20 contract
     * - `_accessType` must be a valid access type which was set on the Config contract during initialization.
     */
    function _pay(uint256 _id, bytes32 _accessType, address _accessor, address _payer) private returns(bool) {
        IERC1155 accessNFT = IERC1155(config.getAccessNFT(_accessType));

        // PaymentManager is responsible for pulling funds
        uint256 amountPaid = paymentManager.pay(_id, _payer, address(accessNFT), _accessor, _accessType);

        // add to amount pending allocation to token owners
        // allocating to owners on payment is costly
        setAmountPendingAllocation(_id, getAmountPendingAllocation(_id) + amountPaid);

        uint256 balance = accessNFT.balanceOf(_accessor, _id);
        if (!(balance > 0)) {
            (bool mintSuccess, ) = address(accessNFT).call(abi.encodeWithSignature("mint(address,uint256)", _accessor, _id));

            require(mintSuccess, "PaymentFacilitator: access-mint-failed");
        }
        (bool setTimestampSuccess, ) = address(accessNFT).call(abi.encodeWithSignature("setPreviousPaymentTime(uint256,address)", _id, _accessor));

        require(setTimestampSuccess, "PaymentFacilitator: failed-to-set-previous-payment-time");

        return true;
    }

    /**
     * @notice Costly operation if amount pending allocation for given {@param _tokenId} is greater than 0 due to O(N) complexy where N is number of owners of token.
     * @dev Creates a transfer from the PaymentManager contract to the msg.sender if the msg.sender has any redeemable funds.
     * 1 owner maps to multiple accessNFTs so the owner has the rights to all funds paid for multiple access types.
     *
     * Requirements:
     *
     * - the caller of the function (msg.sender) must be owner of `_id` on the Owners contract
     * - amount of funds withdrawable must be greater than 0
     */
    function withdraw(uint256 _tokenId) external returns(uint256) {
        allocateToOwners(_tokenId);

        address receiver = msg.sender;
        uint256 amountToWithdraw = getWithdrawableBalance(receiver, _tokenId);

        require(amountToWithdraw > 0, "PaymentFacilitator: zero-withdrawable-amount");

        withdrawable[_tokenId][receiver] -= amountToWithdraw;

        require(withdrawable[_tokenId][receiver] == 0, "PaymentFacilitator: incomplete-withdrawal");

        paymentManager.withdraw(receiver, amountToWithdraw, _tokenId);

        return (amountToWithdraw);
    }

    function getAmountsForOwners(uint256 _id, uint256 _amount) private view returns (address[] memory, uint256[] memory) {
        address owners = config.getOwnersContract();

        (bool getTokenOwnersSuccess, bytes memory tokenOwnersBytes) = owners.staticcall(abi.encodeWithSignature("getOwners(uint256)", _id));

        require(getTokenOwnersSuccess, "PaymentFacilitator: failed-to-get-token-owners");

        address[] memory tokenOwners = abi.decode(tokenOwnersBytes, (address[]));

        (bool getPaymentSharesSuccess, bytes memory paymentShareBytes) = owners.staticcall(abi.encodeWithSignature("getOwnerSharesOfPayment(address[],uint256,uint256)", tokenOwners, _id, _amount));

        require(getPaymentSharesSuccess, "PaymentFacilitator: failed-to-get-payment-shares");

        uint256[] memory paymentShares = abi.decode(paymentShareBytes, (uint256[]));

        return (tokenOwners, paymentShares);
    }
}
