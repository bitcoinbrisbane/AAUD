import React from 'react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useAccount, useBalance } from 'wagmi';

export function WalletConnection() {
  const { address, isConnected } = useAccount();
  const { data: balance } = useBalance({ address });

  return (
    <div className="wallet-connection">
      <div className="wallet-info">
        <ConnectButton />
        {isConnected && address && (
          <div className="account-info">
            <div className="address">
              Connected: {`${address.slice(0, 6)}...${address.slice(-4)}`}
            </div>
            {balance && (
              <div className="eth-balance">
                ETH Balance: {parseFloat(balance.formatted).toFixed(4)} {balance.symbol}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}