// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AAUDToken.sol";

contract AAUDTokenTest is Test {
    AAUDToken public aaudToken;
    address public admin;
    address public minter;
    address public user1;
    address public user2;
    
    function setUp() public {
        admin = address(this);
        minter = address(0x99);
        user1 = address(0x1);
        user2 = address(0x2);
        
        aaudToken = new AAUDToken("AAUD Stable Coin", "AAUD");
        
        // Grant minter role to the minter address
        aaudToken.grantRole(aaudToken.MINTER_ROLE(), minter);
    }
    
    function testInitialState() public {
        assertEq(aaudToken.name(), "AAUD Stable Coin");
        assertEq(aaudToken.symbol(), "AAUD");
        assertEq(aaudToken.decimals(), 18);
        assertEq(aaudToken.totalSupply(), 0);
        assertTrue(aaudToken.hasRole(aaudToken.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(aaudToken.hasRole(aaudToken.MINTER_ROLE(), minter));
    }
    
    function testMint() public {
        uint256 amount = 1000 * 10**18;
        
        vm.prank(minter);
        aaudToken.mint(user1, amount);
        
        assertEq(aaudToken.balanceOf(user1), amount);
        assertEq(aaudToken.totalSupply(), amount);
    }
    
    function testMintOnlyMinter() public {
        uint256 amount = 1000 * 10**18;
        
        vm.prank(user1);
        vm.expectRevert();
        aaudToken.mint(user1, amount);
    }
    
    function testTransfer() public {
        uint256 amount = 1000 * 10**18;
        uint256 transferAmount = 100 * 10**18;
        
        vm.prank(minter);
        aaudToken.mint(user1, amount);
        
        // Transfer tokens
        vm.prank(user1);
        aaudToken.transfer(user2, transferAmount);
        
        assertEq(aaudToken.balanceOf(user1), amount - transferAmount);
        assertEq(aaudToken.balanceOf(user2), transferAmount);
    }
}