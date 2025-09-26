import React, { useState, useEffect } from 'react';
import { useAccount } from 'wagmi';
import { CONTRACT_ADDRESSES } from '../config/web3';
import {
  useTokenBalance,
  useTokenInfo,
  useTokenAllowance,
  useIsTokenWhitelisted,
  useTokenApproval,
  useTokenSwap,
} from '../hooks/useContracts';

interface Token {
  address: `0x${string}`;
  name: string;
  symbol: string;
}

const WHITELIST_TOKENS: Token[] = [
  {
    address: CONTRACT_ADDRESSES.MOCK_USDC as `0x${string}`,
    name: 'Mock USDC',
    symbol: 'USDC',
  },
  {
    address: CONTRACT_ADDRESSES.MOCK_USDT as `0x${string}`,
    name: 'Mock USDT',
    symbol: 'USDT',
  },
  {
    address: CONTRACT_ADDRESSES.MOCK_DAI as `0x${string}`,
    name: 'Mock DAI',
    symbol: 'DAI',
  },
];

export function TokenSwap() {
  const { address } = useAccount();
  const [selectedToken, setSelectedToken] = useState<Token>(WHITELIST_TOKENS[0]);
  const [swapAmount, setSwapAmount] = useState('');

  // Token info and balances
  const tokenInfo = useTokenInfo(selectedToken.address);
  const tokenBalance = useTokenBalance(selectedToken.address, address);
  const aaudBalance = useTokenBalance(CONTRACT_ADDRESSES.AAUD_TOKEN as `0x${string}`, address);
  
  // Contract interactions
  const tokenAllowance = useTokenAllowance(
    selectedToken.address,
    address,
    CONTRACT_ADDRESSES.TOKEN_SWAP as `0x${string}`
  );
  const isWhitelisted = useIsTokenWhitelisted(selectedToken.address);
  const { approve, isPending: isApproving, isSuccess: isApproved } = useTokenApproval();
  const { swapToken, isPending: isSwapping, isSuccess: isSwapped } = useTokenSwap();

  // Check if approval is needed
  const needsApproval = tokenAllowance.allowance === 0n || 
    (tokenBalance.decimals && swapAmount && 
     tokenAllowance.allowance! < BigInt(parseFloat(swapAmount) * Math.pow(10, tokenBalance.decimals)));

  // Reset form after successful swap
  useEffect(() => {
    if (isSwapped) {
      setSwapAmount('');
      tokenBalance.refetch();
      aaudBalance.refetch();
      tokenAllowance.refetch();
    }
  }, [isSwapped]);

  // Reset approval status when amount changes
  useEffect(() => {
    tokenAllowance.refetch();
  }, [swapAmount]);

  const handleApprove = () => {
    if (!tokenBalance.decimals || !swapAmount) return;
    approve(selectedToken.address, swapAmount, tokenBalance.decimals);
  };

  const handleSwap = () => {
    if (!tokenBalance.decimals || !swapAmount) return;
    swapToken(selectedToken.address, swapAmount, tokenBalance.decimals);
  };

  const isValidAmount = swapAmount && 
    parseFloat(swapAmount) > 0 && 
    parseFloat(swapAmount) <= parseFloat(tokenBalance.formattedBalance);

  if (!address) {
    return (
      <div className="swap-container">
        <h2>Token Swap</h2>
        <p>Please connect your wallet to use the token swap feature.</p>
      </div>
    );
  }

  return (
    <div className="swap-container">
      <h2>Swap Tokens for AAUD</h2>
      <p className="swap-description">
        Convert your whitelisted tokens to AAUD tokens at a 1:1 ratio.
      </p>

      <div className="swap-form">
        {/* Token Selection */}
        <div className="form-group">
          <label htmlFor="token-select">Select Token to Swap:</label>
          <select
            id="token-select"
            value={selectedToken.address}
            onChange={(e) => {
              const token = WHITELIST_TOKENS.find(t => t.address === e.target.value);
              if (token) setSelectedToken(token);
            }}
            className="token-select"
          >
            {WHITELIST_TOKENS.map((token) => (
              <option key={token.address} value={token.address}>
                {token.name} ({token.symbol})
              </option>
            ))}
          </select>
        </div>

        {/* Token Info */}
        <div className="token-info">
          <div className="balance-info">
            <span>Your {selectedToken.symbol} Balance: </span>
            <strong>{tokenBalance.formattedBalance}</strong>
          </div>
          <div className="balance-info">
            <span>Your AAUD Balance: </span>
            <strong>{aaudBalance.formattedBalance}</strong>
          </div>
          <div className="whitelist-status">
            <span>Whitelisted: </span>
            <span className={isWhitelisted ? 'status-active' : 'status-inactive'}>
              {isWhitelisted ? '✓ Yes' : '✗ No'}
            </span>
          </div>
        </div>

        {/* Amount Input */}
        <div className="form-group">
          <label htmlFor="amount-input">Amount to Swap:</label>
          <div className="amount-input-container">
            <input
              id="amount-input"
              type="number"
              value={swapAmount}
              onChange={(e) => setSwapAmount(e.target.value)}
              placeholder="0.0"
              min="0"
              max={tokenBalance.formattedBalance}
              step="0.000001"
              className="amount-input"
            />
            <button
              type="button"
              onClick={() => setSwapAmount(tokenBalance.formattedBalance)}
              className="max-button"
            >
              MAX
            </button>
          </div>
          {swapAmount && (
            <div className="conversion-info">
              You will receive: <strong>{swapAmount} AAUD</strong>
            </div>
          )}
        </div>

        {/* Action Buttons */}
        <div className="action-buttons">
          {needsApproval && isValidAmount && (
            <button
              onClick={handleApprove}
              disabled={isApproving || !isWhitelisted}
              className="approve-button"
            >
              {isApproving ? 'Approving...' : `Approve ${selectedToken.symbol}`}
            </button>
          )}
          
          <button
            onClick={handleSwap}
            disabled={!isValidAmount || needsApproval || isSwapping || !isWhitelisted}
            className="swap-button"
          >
            {isSwapping ? 'Swapping...' : 'Swap Tokens'}
          </button>
        </div>

        {/* Status Messages */}
        {!isWhitelisted && (
          <div className="error-message">
            This token is not whitelisted for swapping.
          </div>
        )}
        
        {swapAmount && !isValidAmount && (
          <div className="error-message">
            Invalid amount. Please check your balance.
          </div>
        )}

        {isApproved && (
          <div className="success-message">
            Token approved successfully! You can now swap.
          </div>
        )}

        {isSwapped && (
          <div className="success-message">
            Tokens swapped successfully! 🎉
          </div>
        )}
      </div>
    </div>
  );
}