// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/AAUDToken.sol";

contract AAUDTokenTest is Test {
    AAUDToken public aaudToken;
    address public owner;
    address public user1;
    address public user2;
    
    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        
        aaudToken = new AAUDToken("AAUD Stable Coin", "AAUD", owner);
    }
    
    function testInitialState() public {
        assertEq(aaudToken.name(), "AAUD Stable Coin");
        assertEq(aaudToken.symbol(), "AAUD");
        assertEq(aaudToken.decimals(), 18);
        assertEq(aaudToken.totalSupply(), 0);
        assertEq(aaudToken.owner(), owner);
    }
    
    function testMint() public {
        uint256 amount = 1000 * 10**18;
        
        aaudToken.mint(user1, amount);
        
        assertEq(aaudToken.balanceOf(user1), amount);
        assertEq(aaudToken.totalSupply(), amount);
    }
    
    function testMintOnlyOwner() public {
        uint256 amount = 1000 * 10**18;
        
        vm.prank(user1);
        vm.expectRevert("Ownable: caller is not the owner");
        aaudToken.mint(user1, amount);
    }
    
    function testBurn() public {
        uint256 amount = 1000 * 10**18;
        uint256 burnAmount = 500 * 10**18;
        
        aaudToken.mint(user1, amount);
        aaudToken.burn(user1, burnAmount);
        
        assertEq(aaudToken.balanceOf(user1), amount - burnAmount);
        assertEq(aaudToken.totalSupply(), amount - burnAmount);
    }
    
    function testPauseUnpause() public {
        uint256 amount = 1000 * 10**18;
        
        aaudToken.mint(user1, amount);
        
        // Pause the contract
        aaudToken.pause();
        
        // Should not be able to transfer when paused
        vm.prank(user1);
        vm.expectRevert("Pausable: paused");
        aaudToken.transfer(user2, 100 * 10**18);
        
        // Unpause
        aaudToken.unpause();
        
        // Should be able to transfer when unpaused
        vm.prank(user1);
        aaudToken.transfer(user2, 100 * 10**18);
        assertEq(aaudToken.balanceOf(user2), 100 * 10**18);
    }
}