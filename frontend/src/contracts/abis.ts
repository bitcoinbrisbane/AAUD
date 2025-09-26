export const AAUD_TOKEN_ABI = [
  {
    "type": "constructor",
    "inputs": [
      { "name": "name", "type": "string" },
      { "name": "symbol", "type": "string" },
      { "name": "owner", "type": "address" }
    ]
  },
  {
    "type": "function",
    "name": "name",
    "inputs": [],
    "outputs": [{ "type": "string" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "symbol",
    "inputs": [],
    "outputs": [{ "type": "string" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "decimals",
    "inputs": [],
    "outputs": [{ "type": "uint8" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "totalSupply",
    "inputs": [],
    "outputs": [{ "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "balanceOf",
    "inputs": [{ "name": "account", "type": "address" }],
    "outputs": [{ "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "transfer",
    "inputs": [
      { "name": "to", "type": "address" },
      { "name": "amount", "type": "uint256" }
    ],
    "outputs": [{ "type": "bool" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "allowance",
    "inputs": [
      { "name": "owner", "type": "address" },
      { "name": "spender", "type": "address" }
    ],
    "outputs": [{ "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "approve",
    "inputs": [
      { "name": "spender", "type": "address" },
      { "name": "amount", "type": "uint256" }
    ],
    "outputs": [{ "type": "bool" }],
    "stateMutability": "nonpayable"
  }
] as const;

export const TOKEN_SWAP_ABI = [
  {
    "type": "constructor",
    "inputs": [
      { "name": "_aaudToken", "type": "address" },
      { "name": "owner", "type": "address" }
    ]
  },
  {
    "type": "function",
    "name": "aaudToken",
    "inputs": [],
    "outputs": [{ "type": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "whitelistedTokens",
    "inputs": [{ "name": "token", "type": "address" }],
    "outputs": [{ "type": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "totalSwapped",
    "inputs": [{ "name": "token", "type": "address" }],
    "outputs": [{ "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "isTokenWhitelisted",
    "inputs": [{ "name": "token", "type": "address" }],
    "outputs": [{ "type": "bool" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "swapToken",
    "inputs": [
      { "name": "tokenIn", "type": "address" },
      { "name": "amountIn", "type": "uint256" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "TokenSwapped",
    "inputs": [
      { "name": "user", "type": "address", "indexed": true },
      { "name": "tokenIn", "type": "address", "indexed": true },
      { "name": "amountIn", "type": "uint256", "indexed": false },
      { "name": "amountOut", "type": "uint256", "indexed": false }
    ]
  }
] as const;

export const ERC20_ABI = [
  {
    "type": "function",
    "name": "name",
    "inputs": [],
    "outputs": [{ "type": "string" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "symbol",
    "inputs": [],
    "outputs": [{ "type": "string" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "decimals",
    "inputs": [],
    "outputs": [{ "type": "uint8" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "totalSupply",
    "inputs": [],
    "outputs": [{ "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "balanceOf",
    "inputs": [{ "name": "account", "type": "address" }],
    "outputs": [{ "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "transfer",
    "inputs": [
      { "name": "to", "type": "address" },
      { "name": "amount", "type": "uint256" }
    ],
    "outputs": [{ "type": "bool" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "allowance",
    "inputs": [
      { "name": "owner", "type": "address" },
      { "name": "spender", "type": "address" }
    ],
    "outputs": [{ "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "approve",
    "inputs": [
      { "name": "spender", "type": "address" },
      { "name": "amount", "type": "uint256" }
    ],
    "outputs": [{ "type": "bool" }],
    "stateMutability": "nonpayable"
  }
] as const;