// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// Import Uniswap V3 Core and Periphery
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSwap is Ownable {
    ISwapRouter public swapRouter;
    address public tokenAddress; // Address of the token to swap
    address public wethAddress; // Address of WETH (wrapped Ether)

    constructor(
        address _swapRouter,
        address _tokenAddress,
        address _wethAddress
    ) {
        swapRouter = ISwapRouter(_swapRouter);
        tokenAddress = _tokenAddress;
        wethAddress = _wethAddress;
    }

    // Function to swap ETH (WETH) for tokens
    function buyToken(uint256 amountOutMin, uint256 deadline) external payable {
        // Path for swapping ETH (WETH) to your token
        address;
        path[0] = wethAddress;
        path[1] = tokenAddress;

        // Make the swap
        swapRouter.exactInput{value: msg.value}(
            ISwapRouter.ExactInputParams({
                path: path,
                recipient: msg.sender,
                amountIn: msg.value,
                amountOutMinimum: amountOutMin,
                deadline: deadline
            })
        );
    }

    // Function to withdraw any ETH (onlyOwner)
    function withdrawETH(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    // Receive ETH
    receive() external payable {}
}
