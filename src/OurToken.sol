// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract OurToken is ERC20, Ownable, Pausable {
    uint256 public immutable i_MAX_SUPPLY = 100_000 * 10 ** 18;

    constructor(uint256 INITIAL_SUPPLY) ERC20("Taka", "BDT") Ownable(msg.sender) {
       i_MAX_SUPPLY = INITIAL_SUPPLY;
    }

    /// @notice Mint new tokens, onlyOwner
    /// @param to The recipient of the newly minted tokens
    /// @param amount The amount to mint
    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= i_MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }

    /// @notice Burn tokens from sender's balance
    /// @param amount The amount to burn
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /// @notice Burn tokens from the total supply (onlyOwner)
    /// @param amount The amount to burn
    function burnFromTotalSupply(uint256 amount) external onlyOwner {
        require(totalSupply() >= amount, "Not enough total supply to burn");
        _burn(address(this), amount);
    }

    /// @notice Pause token transfers (OnlyOwner)
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause token transfers (OnlyOwner)
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Get the balance of a specific account
    /// @param account The address to query the balance for
    /// @return The balance of the given account
    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }

    /// @notice Transfer tokens from caller to another account
    /// @param to The recipient address
    /// @param value The amount to transfer
    /// @return success Returns true if transfer succeeds
    function transfer(
        address to,
        uint256 value
    ) public override whenNotPaused returns (bool) {
        require(to != address(0), "Cannot transfer to zero address");
        _transfer(msg.sender, to, value);
        return true;
    }
}
