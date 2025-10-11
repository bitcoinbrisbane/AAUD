// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./AAUDToken.sol";

/**
 * @title TokenEater
 * @dev Contract for eating whitelisted ERC20 tokens for AAUD tokens at 1:1 ratio
 */
contract TokenEater is AccessControl, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    
    bytes32 public constant WHITELIST_MANAGER_ROLE = keccak256("WHITELIST_MANAGER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    AAUDToken public immutable aaudToken;
    
    // Mapping of whitelisted tokens
    mapping(address => bool) public whitelistedTokens;
    
    // Mapping to track total eaten amounts per token
    mapping(address => uint256) public totalEaten;
    
    // Events
    event TokenWhitelisted(address indexed token, bool whitelisted);
    event TokenEaten(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 amountOut
    );
    event EmergencyWithdraw(address indexed token, uint256 amount);
    
    constructor(address _aaudToken, address admin) {
        require(_aaudToken != address(0), "TokenEater: AAUD token address cannot be zero");
        aaudToken = AAUDToken(_aaudToken);
        
        // Grant roles to admin
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(WHITELIST_MANAGER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }
    
    /**
     * @dev Add or remove a token from the whitelist
     * @param token The token address to whitelist/unwhitelist
     * @param whitelisted Whether the token should be whitelisted
     */
    function setTokenWhitelist(address token, bool whitelisted) external onlyRole(WHITELIST_MANAGER_ROLE) {
        require(token != address(0), "TokenEater: Token address cannot be zero");
        whitelistedTokens[token] = whitelisted;
        emit TokenWhitelisted(token, whitelisted);
    }
    
    /**
     * @dev Eat whitelisted ERC20 tokens for AAUD tokens at 1:1 ratio
     * @param tokenIn The address of the token to eat
     * @param amountIn The amount of tokens to eat
     */
    function eatToken(address tokenIn, uint256 amountIn) external nonReentrant whenNotPaused {
        require(whitelistedTokens[tokenIn], "TokenEater: Token not whitelisted");
        require(amountIn > 0, "TokenEater: Amount must be greater than 0");
        
        IERC20 inputToken = IERC20(tokenIn);
        require(
            inputToken.balanceOf(msg.sender) >= amountIn,
            "TokenEater: Insufficient token balance"
        );
        
        // Transfer tokens from user to this contract
        inputToken.safeTransferFrom(msg.sender, address(this), amountIn);
        
        // Mint equivalent AAUD tokens to user (1:1 ratio)
        aaudToken.mint(msg.sender, amountIn);
        
        // Update tracking
        totalEaten[tokenIn] += amountIn;
        
        emit TokenEaten(msg.sender, tokenIn, amountIn, amountIn);
    }
    
    /**
     * @dev Check if a token is whitelisted
     * @param token The token address to check
     */
    function isTokenWhitelisted(address token) external view returns (bool) {
        return whitelistedTokens[token];
    }
    
    /**
     * @dev Get the total amount eaten for a specific token
     * @param token The token address
     */
    function getTotalEaten(address token) external view returns (uint256) {
        return totalEaten[token];
    }
    
    /**
     * @dev Pause the eating functionality
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }
    
    /**
     * @dev Unpause the eating functionality
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}