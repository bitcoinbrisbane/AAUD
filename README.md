# AAUD Token Swap Project

AAUD (Australian Dollar) stable coin project with token swap functionality. Built with Foundry for smart contracts and React/Vite for the frontend.

## Features

- **ERC20 AAUD Token**: Mintable and pausable stable coin implementation
- **Token Swap Contract**: 1:1 swap ratio for whitelisted tokens
- **Web3 Frontend**: Modern React application with wallet integration
- **Security**: Comprehensive tests, reentrancy protection, and access controls

## Project Structure

```
AAUD/
├── src/                    # Smart contracts
│   ├── AAUDToken.sol      # Main AAUD token contract
│   ├── TokenSwap.sol      # Token swap functionality
│   └── MockERC20.sol      # Mock tokens for testing
├── test/                  # Smart contract tests
├── script/                # Deployment scripts
├── frontend/              # React/Vite frontend
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── hooks/         # Custom React hooks
│   │   ├── contracts/     # Contract ABIs and types
│   │   └── config/        # Configuration files
└── foundry.toml           # Foundry configuration
```

## Smart Contracts

### AAUDToken.sol
- ERC20 compliant token with additional features
- Owner-only minting and burning
- Pausable transfers for emergency situations
- 18 decimal precision

### TokenSwap.sol
- Facilitates 1:1 token swapping
- Whitelist system for approved tokens
- Reentrancy protection
- Emergency withdrawal functionality
- Event logging for transparency

## Getting Started

### Prerequisites

- Node.js 16+ and npm
- Foundry (for smart contract development)
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/bitcoinbrisbane/AAUD.git
cd AAUD
```

2. Install dependencies:
```bash
npm install
cd frontend && npm install && cd ..
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

### Smart Contract Development

1. Compile contracts:
```bash
forge build
```

2. Run tests:
```bash
forge test
```

3. Run tests with gas reporting:
```bash
forge test --gas-report
```

4. Deploy to local network:
```bash
# Start a local node in another terminal
anvil

# Deploy contracts
forge script script/Deploy.s.sol --rpc-url localhost --broadcast
```

### Frontend Development

1. Start the development server:
```bash
cd frontend
npm run dev
```

2. Build for production:
```bash
npm run build
```

## Usage

### Web3 Integration

The frontend provides a complete interface for:

1. **Wallet Connection**: Connect MetaMask or other Web3 wallets
2. **Token Selection**: Choose from whitelisted tokens
3. **Balance Checking**: View your token balances
4. **Token Approval**: Approve spending for the swap contract
5. **Token Swapping**: Execute 1:1 swaps to receive AAUD tokens

### Smart Contract Interaction

The contracts can be interacted with directly or through the frontend:

```solidity
// Deploy AAUD Token
AAUDToken aaud = new AAUDToken("AAUD Stable Coin", "AAUD", owner);

// Deploy Token Swap
TokenSwap swap = new TokenSwap(address(aaud), owner);

// Whitelist a token
swap.setTokenWhitelist(tokenAddress, true);

// Perform a swap (user must approve first)
IERC20(tokenAddress).approve(address(swap), amount);
swap.swapToken(tokenAddress, amount);
```

## Testing

### Smart Contract Tests

```bash
# Run all tests
forge test

# Run specific test file
forge test --match-path test/AAUDToken.t.sol

# Run with verbose output
forge test -vv

# Generate coverage report
forge coverage
```

### Frontend Testing

```bash
cd frontend
npm test
```

## Deployment

### Local Deployment

1. Start Anvil local node:
```bash
anvil
```

2. Deploy contracts:
```bash
forge script script/Deploy.s.sol --rpc-url localhost --broadcast
```

### Testnet Deployment

1. Set up your `.env` file with:
   - `PRIVATE_KEY`: Your deployment wallet private key
   - `ETHERSCAN_API_KEY`: For contract verification

2. Deploy to Sepolia:
```bash
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify
```

### Update Frontend Configuration

After deployment, update the contract addresses in:
- `frontend/src/config/web3.ts`
- Update `CONTRACT_ADDRESSES` with deployed contract addresses

## Security Considerations

- All contracts use OpenZeppelin's battle-tested implementations
- Reentrancy protection on all state-changing functions
- Access control for sensitive operations
- Pausable functionality for emergency situations
- Comprehensive test coverage

## Architecture Decisions

1. **1:1 Swap Ratio**: Simplifies calculations and provides predictable outcomes
2. **Whitelist System**: Allows controlled token merging with approved assets
3. **Separate Contracts**: Modular design for easier upgrades and maintenance
4. **Modern Frontend**: React/Vite for fast development and optimal user experience

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For questions and support, please open an issue on GitHub.

---

**Built with ❤️ by Bitcoin Brisbane**
