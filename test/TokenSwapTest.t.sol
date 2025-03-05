// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TokenSwap} from "../contracts/TokenSwap.sol";

contract TokenSwapTest is Test {
    TokenSwap tokenSwap;

    function setUp() public {
        address swapRouter = 0xYourUniswapV3RouterAddress; // replace with actual router address
        address tokenAddress = 0xYourTokenAddress; // replace with actual token address
        address wethAddress = 0xYourWETHAddress; // replace with actual WETH address
        tokenSwap = new TokenSwap(swapRouter, tokenAddress, wethAddress);
    }

    function testBuyToken() public {
        // Example test case to test buying tokens with Sepolia ETH
        uint256 amountOutMin = 1; // Replace with the expected minimum amount of tokens
        uint256 deadline = block.timestamp + 600; // 10 minutes

        uint256 initialBalance = tokenSwap.balanceOf(address(this));
        uint256 amountIn = 1 ether; // Send 1 ETH (Sepolia ETH)

        tokenSwap.buyToken{value: amountIn}(amountOutMin, deadline);

        uint256 finalBalance = tokenSwap.balanceOf(address(this));
        assertTrue(finalBalance > initialBalance, "Token balance should increase after swap");
    }
}
