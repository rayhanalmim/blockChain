// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {EnforcedPause} from "../src/OurToken.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test {
    uint256 public constant BOB_STARTING_AMOUNT = 100 ether;
    uint256 public constant initialSupply = 1_000_000 ether;

    OurToken public ourToken;
    address public deployerAddress;
    address public bob;
    address public alice;

    function setUp() public {
        bob = makeAddr("bob");
        alice = makeAddr("alice");

        // Deploy the token contract
        ourToken = new OurToken(initialSupply);

        // Give Bob some initial balance for testing transfers and burns
        deal(address(ourToken), bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), 0); // No tokens minted at deployment
        assertEq(ourToken.i_MAX_SUPPLY(), initialSupply);
    }

    function testUsersCantMint() public {
        vm.prank(bob);
        vm.expectRevert();
        ourToken.mint(address(this), 1 ether);
    }

    function testOwnerCanMint() public {
        uint256 mintAmount = 100 ether;
        vm.prank(address(this)); // OnlyOwner can mint
        ourToken.mint(alice, mintAmount);
        assertEq(ourToken.balanceOf(alice), mintAmount);
    }

    function testMintExceedsMaxSupply() public {
        uint256 excessMint = initialSupply + 1;
        vm.prank(address(this));
        vm.expectRevert("Exceeds max supply");
        ourToken.mint(alice, excessMint);
    }

    function testBurnTokens() public {
        uint256 burnAmount = 50 ether;
        vm.prank(bob);
        ourToken.burn(burnAmount);
        assertEq(ourToken.balanceOf(bob), BOB_STARTING_AMOUNT - burnAmount);
    }

    function testPauseAndUnpause() public {
        vm.prank(address(this));
        ourToken.pause();

        // Update the expected revert error to "EnforcedPause.selector"
        vm.prank(bob);
        vm.expectRevert(EnforcedPause.selector); // <-- Change this line
        ourToken.transfer(alice, 10 ether);

        vm.prank(address(this));
        ourToken.unpause();
        vm.prank(bob);
        ourToken.transfer(alice, 10 ether);
        assertEq(ourToken.balanceOf(alice), 10 ether);
    }

    function testUsersCannotPause() public {
        vm.prank(bob);
        vm.expectRevert("Ownable: caller is not the owner");
        ourToken.pause();
    }

    function testTransfer() public {
        uint256 transferAmount = 20 ether;
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
    }

    function testTransferFailsWhenPaused() public {
        vm.prank(address(this));
        ourToken.pause();
        vm.prank(bob);
        vm.expectRevert("Pausable: paused");
        ourToken.transfer(alice, 10 ether);
    }

    function testTransferToZeroAddressFails() public {
        vm.prank(bob);
        vm.expectRevert("Cannot transfer to zero address");
        ourToken.transfer(address(0), 10 ether);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000 ether;
        uint256 transferAmount = 500 ether;

        // Bob approves Alice to spend tokens
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Alice transfers on behalf of Bob
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
        assertEq(
            ourToken.allowance(bob, alice),
            initialAllowance - transferAmount
        );
    }
}
