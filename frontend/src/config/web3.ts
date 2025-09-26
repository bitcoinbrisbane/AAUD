import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { mainnet, polygon, optimism, arbitrum, base, sepolia } from 'wagmi/chains';

export const config = getDefaultConfig({
  appName: 'AAUD Token Swap',
  projectId: 'YOUR_PROJECT_ID', // Get from WalletConnect Cloud
  chains: [mainnet, polygon, optimism, arbitrum, base, sepolia],
  ssr: false,
});

// Contract addresses - these should be updated after deployment
export const CONTRACT_ADDRESSES = {
  AAUD_TOKEN: '0x0000000000000000000000000000000000000000', // Update after deployment
  TOKEN_SWAP: '0x0000000000000000000000000000000000000000', // Update after deployment
  // Mock tokens for testing
  MOCK_USDC: '0x0000000000000000000000000000000000000000',
  MOCK_USDT: '0x0000000000000000000000000000000000000000',
  MOCK_DAI: '0x0000000000000000000000000000000000000000',
} as const;

export const SUPPORTED_CHAINS = [sepolia, mainnet] as const;

export const DEFAULT_CHAIN = sepolia;