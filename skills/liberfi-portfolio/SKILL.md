---
name: liberfi-portfolio
description: >
  Analyze wallet portfolios on supported blockchains: view token holdings with
  current values, track transaction activity and history, check PnL (profit and loss)
  statistics over different time windows, and query total wallet net worth.

  Trigger words: wallet, portfolio, holdings, my tokens, my coins, my balance,
  what do I hold, what tokens do I have, wallet balance, wallet holdings,
  wallet activity, transaction history, recent transactions, transfers, swaps,
  trade history, wallet stats, PnL, profit and loss, profit, loss, gains,
  returns, performance, how much did I make, how much did I lose, win rate,
  net worth, total value, portfolio value, total balance, how much is my wallet,
  wallet overview, wallet summary, wallet analysis, check wallet, view wallet,
  my portfolio, account balance.

  Chinese: 钱包, 持仓, 我的代币, 我持有什么, 余额, 钱包余额, 交易记录,
  交易历史, 最近交易, 转账记录, 钱包统计, 盈亏, 利润, 亏损, 收益, 收益率,
  胜率, 净值, 总价值, 钱包总价值, 钱包概览, 钱包分析, 查看钱包.

  CRITICAL: Always use `--json` flag for structured output.
  CRITICAL: Requires both chain and wallet address — always ask the user for these if not provided.

  Do NOT use this skill for:
  - Token search, info, security audit, K-line → use liberfi-token
  - Trending tokens or new token rankings → use liberfi-market
  - Swap quotes, trade execution, or transaction broadcast → use liberfi-swap
  - Token holder analysis (for a specific token) → use liberfi-token

  Do NOT activate on vague inputs like "wallet" alone without a wallet address
  or clear intent to check portfolio data.
user-invocable: true
allowed-commands:
  - "liberfi wallet holdings"
  - "liberfi wallet activity"
  - "liberfi wallet stats"
  - "liberfi wallet net-worth"
  - "liberfi ping"
metadata:
  author: liberfi
  version: "0.1.0"
  homepage: "https://liberfi.io"
  cli: ">=0.1.0"
---

# LiberFi Portfolio Analysis

Analyze wallet holdings, transaction activity, PnL statistics, and net worth using the LiberFi CLI.

## Pre-flight Checks

See [bootstrap.md](../shared/bootstrap.md) for CLI installation and connectivity verification.

This skill's auth requirements:
- **All commands**: No authentication required (public API, uses on-chain data)

## Skill Routing

| If user asks about... | Route to |
|-----------------------|----------|
| Token search, price, details, security | liberfi-token |
| Token holders, smart money traders | liberfi-token |
| Token K-line, candlestick chart | liberfi-token |
| Trending tokens, market rankings | liberfi-market |
| Newly listed tokens | liberfi-market |
| Swap, trade, buy, sell tokens | liberfi-swap |
| Transaction fees, gas estimation | liberfi-swap |

## CLI Command Index

### Query Commands

| Command | Description | Auth |
|---------|-------------|------|
| `liberfi wallet holdings <chain> <address>` | Get all token holdings with values | No |
| `liberfi wallet activity <chain> <address>` | Get transaction activity history | No |
| `liberfi wallet stats <chain> <address> [--resolution <window>]` | Get PnL statistics | No |
| `liberfi wallet net-worth <chain> <address>` | Get total wallet net worth | No |

### Parameter Reference

**Activity options**:
- `--type <type>` — Comma-separated transfer types to filter
- `--token-address <address>` — Filter activity by specific token address
- `--cursor <cursor>` — Pagination cursor
- `--limit <limit>` — Max results per page
- `--direction <direction>` — Cursor direction: `next` or `prev`

**Stats options**:
- `--resolution <resolution>` — Time window: `7d`, `30d`, or `all` (default: `all`)

## Operation Flow

### View Wallet Holdings

1. **Collect inputs**: Ask user for chain (e.g. `sol`, `eth`, `bsc`) and wallet address if not provided
2. **Fetch holdings**: `liberfi wallet holdings <chain> <address> --json`
3. **Present**: Show a table with Token, Amount, Value (USD), sorted by value descending
4. **Suggest next step**: "Want to see your PnL stats or transaction history?"

### View Transaction Activity

1. **Collect inputs**: Chain and wallet address
2. **Fetch activity**: `liberfi wallet activity <chain> <address> --limit 20 --json`
3. **Present**: Show a table with Time, Type, Token, Amount, Tx Hash
4. **Suggest next step**: "Want to filter by a specific token or check your overall PnL?"

### Filter Activity by Token

1. **Fetch filtered**: `liberfi wallet activity <chain> <address> --token-address <tokenAddress> --limit 20 --json`
2. **Present**: Show filtered transaction list
3. **Suggest next step**: "Want to check the details or security of this token?"

### Check PnL Statistics

1. **Determine time window**: Ask user or default to `all`. Options: `7d`, `30d`, `all`
2. **Fetch stats**: `liberfi wallet stats <chain> <address> --resolution <window> --json`
3. **Present**: Show PnL summary — total PnL, win rate, realized/unrealized P&L
4. **Suggest next step**: "Want to see your current holdings or total net worth?"

### Check Net Worth

1. **Fetch net worth**: `liberfi wallet net-worth <chain> <address> --json`
2. **Present**: Show total portfolio value in USD
3. **Suggest next step**: "Want to see the breakdown by token?"

### Full Portfolio Overview

1. **Net worth**: `liberfi wallet net-worth <chain> <address> --json` → total value
2. **Holdings**: `liberfi wallet holdings <chain> <address> --json` → token breakdown
3. **Stats**: `liberfi wallet stats <chain> <address> --json` → PnL summary
4. **Present**: Consolidated portfolio report with total value, top holdings, and PnL

## Cross-Skill Workflows

### "Check my wallet and tell me about my biggest holding"

> Full flow: portfolio → token → token

1. **portfolio** → `liberfi wallet holdings <chain> <address> --json` — Get all holdings
2. Identify the largest holding by USD value
3. **token** → `liberfi token info <chain> <tokenAddress> --json` — Get token details
4. **token** → `liberfi token security <chain> <tokenAddress> --json` — Security audit
5. Present findings: "Your largest holding is X, currently worth $Y"

### "Show my recent trades and check if any tokens I hold are risky"

> Full flow: portfolio → portfolio → token

1. **portfolio** → `liberfi wallet activity <chain> <address> --limit 10 --json` — Recent activity
2. **portfolio** → `liberfi wallet holdings <chain> <address> --json` — Current holdings
3. For each held token: **token** → `liberfi token security <chain> <tokenAddress> --json`
4. Present: Activity summary + risk flags for any held tokens

### "What's my PnL this month, and what's trending that I should look at?"

> Full flow: portfolio → market

1. **portfolio** → `liberfi wallet stats <chain> <address> --resolution 30d --json` — Monthly PnL
2. **market** → `liberfi ranking trending <chain> 24h --limit 10 --json` — Current trends
3. Present: "Your 30d PnL is $X. Here are today's trending tokens you might consider."

## Suggest Next Steps

| Just completed | Suggest to user |
|----------------|-----------------|
| Holdings view | "Want to check your PnL or transaction history?" / "需要查看盈亏或交易记录？" |
| Activity list | "Want to filter by token or check PnL stats?" / "需要按代币筛选或查看盈亏统计？" |
| PnL stats | "Want to see your current holdings?" / "需要查看当前持仓？" |
| Net worth | "Want to see the token breakdown?" / "需要查看各代币明细？" |
| Full overview | "Want to research any specific token or check trends?" / "需要研究某个代币或查看趋势？" |

## Edge Cases

- **Invalid wallet address**: If the API returns 400/404, ask the user to verify the address format. Solana addresses are base58 (32–44 chars), EVM addresses are `0x` + 40 hex chars
- **Wallet not found / Empty wallet**: Inform user: "This wallet has no token holdings on this chain. Verify the address and chain are correct."
- **No activity**: Inform user: "No recent activity found for this wallet on this chain."
- **Network timeout**: Retry once after 3 seconds; if still fails, suggest checking connectivity
- **Wrong chain for address**: EVM addresses used with `sol` chain (or vice versa) will fail; detect the address format and suggest the correct chain
- **Large number of holdings**: Default to top 20 by value; inform user if more exist and offer pagination

## Security Notes

See [security-policy.md](../shared/security-policy.md) for global security rules.

Skill-specific rules:
- Wallet data is **public on-chain information** — no privacy concern in querying any address
- Never ask for or accept private keys or seed phrases — only public wallet addresses are needed
- When displaying wallet addresses provided by the user, confirm the address before querying to avoid mistakes
- PnL data is historical and may not reflect real-time values — note this when presenting stats
