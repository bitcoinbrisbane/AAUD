import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseUnits, formatUnits } from 'viem';
import { TOKEN_SWAP_ABI, ERC20_ABI } from '../contracts/abis';
import { CONTRACT_ADDRESSES } from '../config/web3';

// Hook for reading token balance
export function useTokenBalance(tokenAddress: `0x${string}`, userAddress: `0x${string}` | undefined) {
  const { data: balance, isLoading, refetch } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'balanceOf',
    args: userAddress ? [userAddress] : undefined,
    query: {
      enabled: !!userAddress,
    },
  });

  const { data: decimals } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'decimals',
  });

  const formattedBalance = balance && decimals 
    ? formatUnits(balance as bigint, decimals as number)
    : '0';

  return {
    balance: balance as bigint | undefined,
    formattedBalance,
    decimals: decimals as number | undefined,
    isLoading,
    refetch,
  };
}

// Hook for reading token info
export function useTokenInfo(tokenAddress: `0x${string}`) {
  const { data: name } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'name',
  });

  const { data: symbol } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'symbol',
  });

  const { data: decimals } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'decimals',
  });

  return {
    name: name as string | undefined,
    symbol: symbol as string | undefined,
    decimals: decimals as number | undefined,
  };
}

// Hook for checking token allowance
export function useTokenAllowance(
  tokenAddress: `0x${string}`,
  ownerAddress: `0x${string}` | undefined,
  spenderAddress: `0x${string}`
) {
  const { data: allowance, refetch } = useReadContract({
    address: tokenAddress,
    abi: ERC20_ABI,
    functionName: 'allowance',
    args: ownerAddress ? [ownerAddress, spenderAddress] : undefined,
    query: {
      enabled: !!ownerAddress,
    },
  });

  return {
    allowance: allowance as bigint | undefined,
    refetch,
  };
}

// Hook for checking if token is whitelisted
export function useIsTokenWhitelisted(tokenAddress: `0x${string}`) {
  const { data: isWhitelisted } = useReadContract({
    address: CONTRACT_ADDRESSES.TOKEN_SWAP as `0x${string}`,
    abi: TOKEN_SWAP_ABI,
    functionName: 'isTokenWhitelisted',
    args: [tokenAddress],
  });

  return isWhitelisted as boolean | undefined;
}

// Hook for token approval
export function useTokenApproval() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const approve = (tokenAddress: `0x${string}`, amount: string, decimals: number) => {
    writeContract({
      address: tokenAddress,
      abi: ERC20_ABI,
      functionName: 'approve',
      args: [CONTRACT_ADDRESSES.TOKEN_SWAP as `0x${string}`, parseUnits(amount, decimals)],
    });
  };

  return {
    approve,
    hash,
    isPending,
    isConfirming,
    isSuccess,
  };
}

// Hook for token swap
export function useTokenSwap() {
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const swapToken = (tokenAddress: `0x${string}`, amount: string, decimals: number) => {
    writeContract({
      address: CONTRACT_ADDRESSES.TOKEN_SWAP as `0x${string}`,
      abi: TOKEN_SWAP_ABI,
      functionName: 'swapToken',
      args: [tokenAddress, parseUnits(amount, decimals)],
    });
  };

  return {
    swapToken,
    hash,
    isPending,
    isConfirming,
    isSuccess,
  };
}

// Hook for getting total swapped amount
export function useTotalSwapped(tokenAddress: `0x${string}`) {
  const { data: totalSwapped } = useReadContract({
    address: CONTRACT_ADDRESSES.TOKEN_SWAP as `0x${string}`,
    abi: TOKEN_SWAP_ABI,
    functionName: 'totalSwapped',
    args: [tokenAddress],
  });

  return totalSwapped as bigint | undefined;
}