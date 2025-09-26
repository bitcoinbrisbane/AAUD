import '@rainbow-me/rainbowkit/styles.css';
import { WagmiProvider } from 'wagmi';
import { RainbowKitProvider } from '@rainbow-me/rainbowkit';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { config } from './config/web3';
import { WalletConnection } from './components/WalletConnection';
import { TokenSwap } from './components/TokenSwap';
import './App.css';

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <WagmiProvider config={config}>
        <RainbowKitProvider>
          <div className="App">
            <header className="App-header">
              <div className="header-content">
                <div className="logo-section">
                  <h1>AAUD Token Swap</h1>
                  <p className="tagline">Merge your tokens into AAUD stable coin</p>
                </div>
                <WalletConnection />
              </div>
            </header>

            <main className="App-main">
              <div className="container">
                <TokenSwap />
                
                <div className="info-section">
                  <h3>How it works</h3>
                  <ol>
                    <li>Connect your Web3 wallet</li>
                    <li>Select a whitelisted token from the dropdown</li>
                    <li>Enter the amount you want to swap</li>
                    <li>Approve the token spending (first time only)</li>
                    <li>Execute the swap to receive AAUD tokens at 1:1 ratio</li>
                  </ol>
                  
                  <div className="features">
                    <h4>Features:</h4>
                    <ul>
                      <li>✓ 1:1 token swap ratio</li>
                      <li>✓ Whitelisted token support</li>
                      <li>✓ Secure smart contract</li>
                      <li>✓ Real-time balance updates</li>
                      <li>✓ Transaction status tracking</li>
                    </ul>
                  </div>
                </div>
              </div>
            </main>

            <footer className="App-footer">
              <p>&copy; 2024 AAUD Token Project. Built with Foundry & React.</p>
            </footer>
          </div>
        </RainbowKitProvider>
      </WagmiProvider>
    </QueryClientProvider>
  );
}

export default App;
