// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AAUDToken.sol";
import "../src/TokenEater.sol";
import "../src/MockERC20.sol";

contract TokenEaterTest is Test {
    AAUDToken public aaudToken;
    TokenEater public tokenEater;
    MockERC20 public mockToken;
    MockERC20 public nonWhitelistedToken;
    
    address public admin;
    address public user1;
    address public user2;
    
    uint256 constant INITIAL_SUPPLY = 1000000 * 10**18;
    
    function setUp() public {
        admin = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        
        // Deploy AAUD token
        aaudToken = new AAUDToken("AAUD Stable Coin", "AAUD");
        
        // Deploy TokenEater contract
        tokenEater = new TokenEater(address(aaudToken), admin);
        
        // Grant minter role to TokenEater
        aaudToken.grantRole(aaudToken.MINTER_ROLE(), address(tokenEater));
        
        // Deploy mock tokens
        mockToken = new MockERC20("Mock Token", "MOCK", 18, INITIAL_SUPPLY);
        nonWhitelistedToken = new MockERC20("Non-Whitelisted", "NWL", 18, INITIAL_SUPPLY);
        
        // Whitelist the mock token
        tokenEater.setTokenWhitelist(address(mockToken), true);
        
        // Give some tokens to user1
        mockToken.transfer(user1, 1000 * 10**18);
        nonWhitelistedToken.transfer(user1, 1000 * 10**18);
    }
    
    function testInitialState() public {
        assertEq(address(tokenEater.aaudToken()), address(aaudToken));
        assertTrue(tokenEater.hasRole(tokenEater.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(tokenEater.whitelistedTokens(address(mockToken)));
        assertFalse(tokenEater.whitelistedTokens(address(nonWhitelistedToken)));
    }
    
    function testSetTokenWhitelist() public {
        address newToken = address(0x123);
        
        tokenEater.setTokenWhitelist(newToken, true);
        assertTrue(tokenEater.whitelistedTokens(newToken));
        
        tokenEater.setTokenWhitelist(newToken, false);
        assertFalse(tokenEater.whitelistedTokens(newToken));
    }
    
    function testEatToken() public {
        uint256 eatAmount = 100 * 10**18;
        
        // User1 approves TokenEater to spend their tokens
        vm.prank(user1);
        mockToken.approve(address(tokenEater), eatAmount);
        
        uint256 initialBalance = mockToken.balanceOf(user1);
        uint256 initialAAUDBalance = aaudToken.balanceOf(user1);
        
        // Perform eat
        vm.prank(user1);
        tokenEater.eatToken(address(mockToken), eatAmount);
        
        // Check balances
        assertEq(mockToken.balanceOf(user1), initialBalance - eatAmount);
        assertEq(aaudToken.balanceOf(user1), initialAAUDBalance + eatAmount);
        assertEq(mockToken.balanceOf(address(tokenEater)), eatAmount);
        assertEq(tokenEater.totalEaten(address(mockToken)), eatAmount);
    }
    
    function testEatNonWhitelistedToken() public {
        uint256 eatAmount = 100 * 10**18;
        
        vm.prank(user1);
        nonWhitelistedToken.approve(address(tokenEater), eatAmount);
        
        vm.prank(user1);
        vm.expectRevert("TokenEater: Token not whitelisted");
        tokenEater.eatToken(address(nonWhitelistedToken), eatAmount);
    }
    
    function testEatZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert("TokenEater: Amount must be greater than 0");
        tokenEater.eatToken(address(mockToken), 0);
    }
    
    function testEatInsufficientBalance() public {
        uint256 eatAmount = 2000 * 10**18; // More than user1 has
        
        vm.prank(user1);
        mockToken.approve(address(tokenEater), eatAmount);
        
        vm.prank(user1);
        vm.expectRevert("TokenEater: Insufficient token balance");
        tokenEater.eatToken(address(mockToken), eatAmount);
    }
    
    function testMultipleEats() public {
        uint256 eatAmount = 100 * 10**18;
        
        // First eat
        vm.prank(user1);
        mockToken.approve(address(tokenEater), eatAmount);
        vm.prank(user1);
        tokenEater.eatToken(address(mockToken), eatAmount);
        
        // Check total eaten
        assertEq(tokenEater.totalEaten(address(mockToken)), eatAmount);
        
        // Second eat
        vm.prank(user1);
        mockToken.approve(address(tokenEater), eatAmount);
        vm.prank(user1);
        tokenEater.eatToken(address(mockToken), eatAmount);
        
        // Check total eaten is cumulative
        assertEq(tokenEater.totalEaten(address(mockToken)), eatAmount * 2);
    }
    
    function testPauseUnpause() public {
        uint256 eatAmount = 100 * 10**18;
        
        vm.prank(user1);
        mockToken.approve(address(tokenEater), eatAmount);
        
        // Pause contract
        tokenEater.pause();
        
        // Should not be able to eat when paused
        vm.prank(user1);
        vm.expectRevert();  // OpenZeppelin v5 uses custom errors
        tokenEater.eatToken(address(mockToken), eatAmount);
        
        // Unpause
        tokenEater.unpause();
        
        // Should be able to eat when unpaused
        vm.prank(user1);
        tokenEater.eatToken(address(mockToken), eatAmount);
        assertEq(aaudToken.balanceOf(user1), eatAmount);
    }
}