// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/AAUDToken.sol";
import "../src/TokenSwap.sol";
import "../src/MockERC20.sol";

contract TokenSwapTest is Test {
    AAUDToken public aaudToken;
    TokenSwap public tokenSwap;
    MockERC20 public mockToken;
    MockERC20 public nonWhitelistedToken;
    
    address public owner;
    address public user1;
    address public user2;
    
    uint256 constant INITIAL_SUPPLY = 1000000 * 10**18;
    
    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        
        // Deploy AAUD token
        aaudToken = new AAUDToken("AAUD Stable Coin", "AAUD", owner);
        
        // Deploy TokenSwap contract
        tokenSwap = new TokenSwap(address(aaudToken), owner);
        
        // Deploy mock tokens
        mockToken = new MockERC20("Mock Token", "MOCK", 18, INITIAL_SUPPLY);
        nonWhitelistedToken = new MockERC20("Non-Whitelisted", "NWL", 18, INITIAL_SUPPLY);
        
        // Whitelist the mock token
        tokenSwap.setTokenWhitelist(address(mockToken), true);
        
        // Give some tokens to user1
        mockToken.transfer(user1, 1000 * 10**18);
        nonWhitelistedToken.transfer(user1, 1000 * 10**18);
    }
    
    function testInitialState() public {
        assertEq(address(tokenSwap.aaudToken()), address(aaudToken));
        assertEq(tokenSwap.owner(), owner);
        assertTrue(tokenSwap.whitelistedTokens(address(mockToken)));
        assertFalse(tokenSwap.whitelistedTokens(address(nonWhitelistedToken)));
    }
    
    function testSetTokenWhitelist() public {
        address newToken = address(0x123);
        
        tokenSwap.setTokenWhitelist(newToken, true);
        assertTrue(tokenSwap.whitelistedTokens(newToken));
        
        tokenSwap.setTokenWhitelist(newToken, false);
        assertFalse(tokenSwap.whitelistedTokens(newToken));
    }
    
    function testSwapToken() public {
        uint256 swapAmount = 100 * 10**18;
        
        // User1 approves TokenSwap to spend their tokens
        vm.prank(user1);
        mockToken.approve(address(tokenSwap), swapAmount);
        
        uint256 initialBalance = mockToken.balanceOf(user1);
        uint256 initialAAUDBalance = aaudToken.balanceOf(user1);
        
        // Perform swap
        vm.prank(user1);
        tokenSwap.swapToken(address(mockToken), swapAmount);
        
        // Check balances
        assertEq(mockToken.balanceOf(user1), initialBalance - swapAmount);
        assertEq(aaudToken.balanceOf(user1), initialAAUDBalance + swapAmount);
        assertEq(mockToken.balanceOf(address(tokenSwap)), swapAmount);
        assertEq(tokenSwap.totalSwapped(address(mockToken)), swapAmount);
    }
    
    function testSwapNonWhitelistedToken() public {
        uint256 swapAmount = 100 * 10**18;
        
        vm.prank(user1);
        nonWhitelistedToken.approve(address(tokenSwap), swapAmount);
        
        vm.prank(user1);
        vm.expectRevert("TokenSwap: Token not whitelisted");
        tokenSwap.swapToken(address(nonWhitelistedToken), swapAmount);
    }
    
    function testSwapZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert("TokenSwap: Amount must be greater than 0");
        tokenSwap.swapToken(address(mockToken), 0);
    }
    
    function testSwapInsufficientBalance() public {
        uint256 swapAmount = 2000 * 10**18; // More than user1 has
        
        vm.prank(user1);
        mockToken.approve(address(tokenSwap), swapAmount);
        
        vm.prank(user1);
        vm.expectRevert("TokenSwap: Insufficient token balance");
        tokenSwap.swapToken(address(mockToken), swapAmount);
    }
    
    function testEmergencyWithdraw() public {
        uint256 swapAmount = 100 * 10**18;
        
        // First perform a swap to get tokens in the contract
        vm.prank(user1);
        mockToken.approve(address(tokenSwap), swapAmount);
        vm.prank(user1);
        tokenSwap.swapToken(address(mockToken), swapAmount);
        
        // Emergency withdraw
        uint256 contractBalance = mockToken.balanceOf(address(tokenSwap));
        tokenSwap.emergencyWithdraw(address(mockToken), contractBalance, owner);
        
        assertEq(mockToken.balanceOf(address(tokenSwap)), 0);
        assertEq(mockToken.balanceOf(owner), INITIAL_SUPPLY - 1000 * 10**18 + contractBalance);
    }
    
    function testPauseUnpause() public {
        uint256 swapAmount = 100 * 10**18;
        
        vm.prank(user1);
        mockToken.approve(address(tokenSwap), swapAmount);
        
        // Pause contract
        tokenSwap.pause();
        
        // Should not be able to swap when paused
        vm.prank(user1);
        vm.expectRevert("Pausable: paused");
        tokenSwap.swapToken(address(mockToken), swapAmount);
        
        // Unpause
        tokenSwap.unpause();
        
        // Should be able to swap when unpaused
        vm.prank(user1);
        tokenSwap.swapToken(address(mockToken), swapAmount);
        assertEq(aaudToken.balanceOf(user1), swapAmount);
    }
}