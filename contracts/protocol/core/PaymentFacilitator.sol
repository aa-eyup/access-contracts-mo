// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * Serves as access point to deposit/withdraw funds.
 * When a content accessor deposits funds to access content, 
 * it will be sent to this contract which will then forward it to the PaymentManager contract.
 * When a content creator wants to withdraw funds, this contract will pull funds from PaymentManager
 * and then send them to the withdrawer.
 * This contract keeps track of how many funds were deposited to access a given token ID on the Content Contract.
 */
contract PaymentFacilitator {
    
}
