// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StableCoin is ERC20 {
    constructor(address _payer, uint256 _mintAmount) ERC20("Test USDC", "tUSDC") {
        _mint(_payer, _mintAmount);
    }
}