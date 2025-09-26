// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./AAUDToken.sol";

/**
 * @title TokenSwap
 * @dev Contract for swapping whitelisted ERC20 tokens for AAUD tokens at 1:1 ratio
 */
contract TokenSwap is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    
    AAUDToken public immutable aaudToken;
    
    // Mapping of whitelisted tokens
    mapping(address => bool) public whitelistedTokens;
    
    // Mapping to track total swapped amounts per token
    mapping(address => uint256) public totalSwapped;
    
    // Events
    event TokenWhitelisted(address indexed token, bool whitelisted);
    event TokenSwapped(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 amountOut
    );
    event EmergencyWithdraw(address indexed token, uint256 amount);
    
    constructor(address _aaudToken, address owner) {
        require(_aaudToken != address(0), "TokenSwap: AAUD token address cannot be zero");
        aaudToken = AAUDToken(_aaudToken);
        _transferOwnership(owner);
    }
    
    /**
     * @dev Add or remove a token from the whitelist
     * @param token The token address to whitelist/unwhitelist
     * @param whitelisted Whether the token should be whitelisted
     */
    function setTokenWhitelist(address token, bool whitelisted) external onlyOwner {
        require(token != address(0), "TokenSwap: Token address cannot be zero");
        whitelistedTokens[token] = whitelisted;
        emit TokenWhitelisted(token, whitelisted);
    }
    
    /**
     * @dev Swap whitelisted ERC20 tokens for AAUD tokens at 1:1 ratio
     * @param tokenIn The address of the token to swap from
     * @param amountIn The amount of tokens to swap
     */
    function swapToken(address tokenIn, uint256 amountIn) external nonReentrant whenNotPaused {
        require(whitelistedTokens[tokenIn], "TokenSwap: Token not whitelisted");
        require(amountIn > 0, "TokenSwap: Amount must be greater than 0");
        
        IERC20 inputToken = IERC20(tokenIn);
        require(
            inputToken.balanceOf(msg.sender) >= amountIn,
            "TokenSwap: Insufficient token balance"
        );
        
        // Transfer tokens from user to this contract
        inputToken.safeTransferFrom(msg.sender, address(this), amountIn);
        
        // Mint equivalent AAUD tokens to user (1:1 ratio)
        aaudToken.mint(msg.sender, amountIn);
        
        // Update tracking
        totalSwapped[tokenIn] += amountIn;
        
        emit TokenSwapped(msg.sender, tokenIn, amountIn, amountIn);
    }
    
    /**
     * @dev Check if a token is whitelisted
     * @param token The token address to check
     */
    function isTokenWhitelisted(address token) external view returns (bool) {
        return whitelistedTokens[token];
    }
    
    /**
     * @dev Get the total amount swapped for a specific token
     * @param token The token address
     */
    function getTotalSwapped(address token) external view returns (uint256) {
        return totalSwapped[token];
    }
    
    /**
     * @dev Emergency function to withdraw tokens from the contract
     * @param token The token to withdraw
     * @param amount The amount to withdraw
     * @param to The address to send tokens to
     */
    function emergencyWithdraw(
        address token,
        uint256 amount,
        address to
    ) external onlyOwner {
        require(to != address(0), "TokenSwap: Cannot withdraw to zero address");
        
        if (token == address(0)) {
            // Withdraw ETH
            payable(to).transfer(amount);
        } else {
            // Withdraw ERC20 token
            IERC20(token).safeTransfer(to, amount);
        }
        
        emit EmergencyWithdraw(token, amount);
    }
    
    /**
     * @dev Pause the contract
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}