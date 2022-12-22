// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * Serves as the single source of funds used to pay for accessing Content Contracts.
 * Payments made to access any given content will be routed to this contract.
 * When content owners want to withdraw funds, the funds will come from this contract.
 * PaymentFacilitator contracts have accounts on this contract to keep track of how many
 * funds were deposited/withdrawn to/from this contract.
 */
contract PaymentManager {
    
}
