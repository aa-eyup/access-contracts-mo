// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../interfaces/IPaymentManager.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * Serves as the single source of funds used to pay for accessing Content Contracts.
 * Payments made to access any given content will be routed to this contract.
 * When content owners want to withdraw funds, the funds will come from this contract.
 * PaymentFacilitator contracts have accounts on this contract to keep track of how many
 * funds were deposited/withdrawn to/from this contract.
 */
contract PaymentManager is IPaymentManager {

    IERC20 USDC = IERC20(0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E);
    mapping(address => uint256) facilitatorAccounts;
    mapping(address => bool) activeFacilitators;

    
    function pay(address _payer, address _accessNFT, uint256 _tokenId) external returns(bool, uint256) {
        require(activeFacilitators[msg.sender], "must be called by an active PaymentFacilitator contract");

        // call on AccessNFT to check amount to pull
        (bool getPriceSuccess, bytes memory data) = _accessNFT.staticcall(abi.encodeWithSignature("getPrice(uint256)", _tokenId));
        require(getPriceSuccess);
        uint256 price = abi.decode(data, (uint256));

        // call on token to transferFrom funds (revert if call fails)
        bool transferSuccess = doUSDCTransfer(_payer, address(this), price);
        require(transferSuccess, "failed to transfer USDC from payer");
        facilitatorAccounts[msg.sender] = facilitatorAccounts[msg.sender] + price;
        
        // emit event

        return (true, price);
    }

    function withdraw(address _recipient, uint256 _amount) external returns(bool) {
        require(activeFacilitators[msg.sender], "must be called by an active PaymentFacilitator contract");
        require(_amount <= facilitatorAccounts[msg.sender]);
        facilitatorAccounts[msg.sender] = facilitatorAccounts[msg.sender] - _amount;
        bool transferSuccess = doUSDCTransfer(address(this), _recipient, _amount);
        require(transferSuccess, "failed to transfer USDC from PaymentManager");
        return true;
    }

    function doUSDCTransfer(address _from, address _to, uint256 _amount) private returns(bool) {
        require(_from != address(0), "can not transfer USDC from 0 address");
        require(_to != address(0), "can not transfer USDC to 0 address");
        return USDC.transferFrom(_from, _to, _amount);
    }

    function setFacilitator(address _facilitator, bool _active) external {
        // only admin
        activeFacilitators[_facilitator] = _active;
    }
}
