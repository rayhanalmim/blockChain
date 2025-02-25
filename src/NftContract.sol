// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RealEstateNFT is ERC721, Ownable, Pausable {
    IERC20 public immutable bdtToken;
    uint256 private _tokenIdCounter;

    struct Property {
        string location;
        uint256 price;
        bool forSale;
    }

    mapping(uint256 => Property) public properties;

    event PropertyListed(uint256 indexed tokenId, uint256 price);
    event PropertySold(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event PropertyDelisted(uint256 indexed tokenId);

    constructor(address tokenAddress) ERC721("Real Estate NFT", "RE-NFT") Ownable(msg.sender) {
        bdtToken = IERC20(tokenAddress);
    }

    /// @notice Mint a new property NFT
    /// @param to The owner of the new NFT
    /// @param location The real estate property location
    /// @param price The price in BDT tokens
    function mintProperty(address to, string memory location, uint256 price) external onlyOwner {
        uint256 tokenId = _tokenIdCounter++;
        properties[tokenId] = Property(location, price, false);
        _mint(to, tokenId);
    }

    /// @notice List a property for sale
    /// @param tokenId The NFT tokenId to list
    /// @param price The selling price in BDT tokens
    function listProperty(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "Not the property owner");
        properties[tokenId].price = price;
        properties[tokenId].forSale = true;
        emit PropertyListed(tokenId, price);
    }

    /// @notice Buy a property NFT using BDT tokens
    /// @param tokenId The NFT tokenId to buy
    function buyProperty(uint256 tokenId) external whenNotPaused {
        require(properties[tokenId].forSale, "Property not for sale");
        address seller = ownerOf(tokenId);
        uint256 price = properties[tokenId].price;

        require(bdtToken.transferFrom(msg.sender, seller, price), "BDT transfer failed");

        _transfer(seller, msg.sender, tokenId);
        properties[tokenId].forSale = false;

        emit PropertySold(tokenId, msg.sender, price);
    }

    /// @notice Delist a property from sale
    /// @param tokenId The NFT tokenId to delist
    function delistProperty(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not the property owner");
        properties[tokenId].forSale = false;
        emit PropertyDelisted(tokenId);
    }

    /// @notice Pause contract (OnlyOwner)
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause contract (OnlyOwner)
    function unpause() external onlyOwner {
        _unpause();
    }
}
