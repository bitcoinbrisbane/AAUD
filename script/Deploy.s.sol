// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AAUDToken.sol";
import "../src/TokenEater.sol";
import "../src/MockERC20.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy AAUD Token first
        AAUDToken aaudToken = new AAUDToken("AAUD Stable Coin", "AAUD");
        console.log("AAUD Token deployed at:", address(aaudToken));
        
        // Deploy TokenEater contract
        TokenEater tokenEater = new TokenEater(address(aaudToken), deployer);
        console.log("TokenEater contract deployed at:", address(tokenEater));
        
        // Grant minter role to TokenEater
        aaudToken.grantRole(aaudToken.MINTER_ROLE(), address(tokenEater));
        console.log("Granted MINTER_ROLE to TokenEater");
        
        // Deploy mock tokens for testing (only on testnets)
        if (block.chainid != 1) { // Not mainnet
            MockERC20 mockUSDC = new MockERC20("Mock USDC", "USDC", 6, 1000000 * 10**6);
            MockERC20 mockUSDT = new MockERC20("Mock USDT", "USDT", 6, 1000000 * 10**6);
            MockERC20 mockDAI = new MockERC20("Mock DAI", "DAI", 18, 1000000 * 10**18);
            
            console.log("Mock USDC deployed at:", address(mockUSDC));
            console.log("Mock USDT deployed at:", address(mockUSDT));
            console.log("Mock DAI deployed at:", address(mockDAI));
            
            // Whitelist mock tokens
            tokenEater.setTokenWhitelist(address(mockUSDC), true);
            tokenEater.setTokenWhitelist(address(mockUSDT), true);
            tokenEater.setTokenWhitelist(address(mockDAI), true);
            
            console.log("Mock tokens whitelisted");
        }
        
        vm.stopBroadcast();
        
        // Log deployment info
        console.log("Deployment completed!");
        console.log("AAUD Token:", address(aaudToken));
        console.log("TokenEater:", address(tokenEater));
        console.log("Deployer:", deployer);
        console.log("Chain ID:", block.chainid);
    }
}