// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/AAUDToken.sol";
import "../src/TokenSwap.sol";
import "../src/MockERC20.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy AAUD Token
        AAUDToken aaudToken = new AAUDToken("AAUD Stable Coin", "AAUD", deployer);
        console.log("AAUD Token deployed at:", address(aaudToken));
        
        // Deploy TokenSwap contract
        TokenSwap tokenSwap = new TokenSwap(address(aaudToken), deployer);
        console.log("TokenSwap contract deployed at:", address(tokenSwap));
        
        // Deploy mock tokens for testing (only on testnets)
        if (block.chainid != 1) { // Not mainnet
            MockERC20 mockUSDC = new MockERC20("Mock USDC", "USDC", 6, 1000000 * 10**6);
            MockERC20 mockUSDT = new MockERC20("Mock USDT", "USDT", 6, 1000000 * 10**6);
            MockERC20 mockDAI = new MockERC20("Mock DAI", "DAI", 18, 1000000 * 10**18);
            
            console.log("Mock USDC deployed at:", address(mockUSDC));
            console.log("Mock USDT deployed at:", address(mockUSDT));
            console.log("Mock DAI deployed at:", address(mockDAI));
            
            // Whitelist mock tokens
            tokenSwap.setTokenWhitelist(address(mockUSDC), true);
            tokenSwap.setTokenWhitelist(address(mockUSDT), true);
            tokenSwap.setTokenWhitelist(address(mockDAI), true);
            
            console.log("Mock tokens whitelisted");
        }
        
        vm.stopBroadcast();
        
        // Log deployment info
        console.log("Deployment completed!");
        console.log("AAUD Token:", address(aaudToken));
        console.log("TokenSwap:", address(tokenSwap));
        console.log("Deployer:", deployer);
        console.log("Chain ID:", block.chainid);
    }
}