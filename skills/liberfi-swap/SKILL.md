---
name: liberfi-swap
description: >
  Execute token swaps and manage on-chain transactions: list supported swap chains,
  browse available swap tokens, get swap quotes with price/slippage/route info,
  build signable swap transactions, estimate gas/transaction fees, and broadcast
  signed transactions to the blockchain.

  Trigger words: swap, trade, exchange, buy token, sell token, convert, swap tokens,
  trade tokens, exchange tokens, buy crypto, sell crypto, get a quote, swap quote,
  price quote, how much will I get, swap rate, exchange rate, slippage, swap route,
  best price, execute swap, confirm swap, make a trade, place a trade,
  transaction, send transaction, broadcast, submit transaction, tx, send tx,
  gas fee, transaction fee, fee estimate, gas estimate, how much gas,
  supported chains, swap chains, which chains, available tokens, swap tokens,
  chain list, token list, build transaction, sign transaction.

  Chinese: 兑换, 交易, 买入, 卖出, 换币, 代币兑换, 报价, 兑换报价, 价格,
  能换多少, 滑点, 路由, 最优价格, 执行交易, 确认交易, 发送交易, 广播交易,
  手续费, Gas费, 费用估算, 支持的链, 可用代币, 构建交易, 签名交易.

  CRITICAL: Always use `--json` flag for structured output.
  CRITICAL: Swap amounts are in **smallest unit** (e.g. lamports for SOL, wei for ETH).
  CRITICAL: ALWAYS run `liberfi token security` on the target token BEFORE executing a swap.
  CRITICAL: NEVER execute swap or send transaction without explicit user confirmation.

  Do NOT use this skill for:
  - Token search, info, security audit, K-line → use liberfi-token
  - Trending tokens or new token rankings → use liberfi-market
  - Wallet holdings, activity, or PnL stats → use liberfi-portfolio
  - Token holder or trader analysis → use liberfi-token

  Do NOT activate on vague inputs like "trade" or "buy" without specifying tokens or amounts.
user-invocable: true
allowed-commands:
  - "liberfi swap chains"
  - "liberfi swap tokens"
  - "liberfi swap quote"
  - "liberfi swap execute"
  - "liberfi tx estimate"
  - "liberfi tx send"
  - "liberfi token security"
  - "liberfi ping"
metadata:
  author: liberfi
  version: "0.1.0"
  homepage: "https://liberfi.io"
  cli: ">=0.1.0"
---

# LiberFi Swap & Transaction

Execute token swaps and broadcast transactions using the LiberFi CLI.

## Pre-flight Checks

See [bootstrap.md](../shared/bootstrap.md) for CLI installation and connectivity verification.

This skill's auth requirements:
- **All commands**: No authentication required (public API)

**Additional pre-flight for swap operations**:
- Confirm the user has a wallet address ready
- Confirm the user knows the input/output token addresses (or help look them up via `liberfi swap tokens` or `liberfi token search`)

## Skill Routing

| If user asks about... | Route to |
|-----------------------|----------|
| Token search, price, details, security | liberfi-token |
| Token K-line, candlestick chart | liberfi-token |
| Token holders, smart money traders | liberfi-token |
| Trending tokens, market rankings | liberfi-market |
| Newly listed tokens | liberfi-market |
| Wallet holdings, balance, PnL | liberfi-portfolio |
| Wallet activity, transaction history | liberfi-portfolio |

## CLI Command Index

### Query Commands (read-only)

| Command | Description | Auth |
|---------|-------------|------|
| `liberfi swap chains` | List all supported swap chains | No |
| `liberfi swap tokens [--chain-id <id>]` | List available swap tokens | No |

### Mutating Commands (generate transactions)

| Command | Description | Auth |
|---------|-------------|------|
| `liberfi swap quote --in <addr> --out <addr> --amount <amt> --chain-family <fam> --chain-id <id>` | Get a swap quote | No |
| `liberfi swap execute --account <wallet> --in <addr> --out <addr> --amount <amt> --chain-family <fam> --chain-id <id>` | Build a signable swap transaction | No |
| `liberfi tx estimate --chain-family <fam> --chain-id <id> --data '<json>'` | Estimate transaction fee / gas | No |
| `liberfi tx send --chain-family <fam> --chain-id <id> --signed-tx <data>` | Broadcast a signed transaction | No |

### Parameter Reference

**Swap quote & execute** (shared parameters):
- `--in <address>` — **Required**. Input token address
- `--out <address>` — **Required**. Output token address
- `--amount <amount>` — **Required**. Input amount in **smallest unit** (lamports, wei, etc.)
- `--chain-family <family>` — **Required**. `evm` or `svm`
- `--chain-id <id>` — **Required**. Numeric chain ID (e.g. `0` for Solana mainnet, `1` for Ethereum)
- `--slippage-bps <bps>` — Slippage tolerance in basis points (e.g. `100` = 1%)
- `--swap-mode <mode>` — `ExactIn` (default) or `ExactOut`

**Execute-only additional parameter**:
- `--account <address>` — **Required**. Wallet address that will sign the transaction
- `--quote-result <json>` — Opaque quote result JSON from a prior `swap quote` call (pass through without modification)

**Tx estimate parameters**:
- `--chain-family <family>` — **Required**. `evm` or `svm`
- `--chain-id <id>` — **Required**. Numeric chain ID
- `--data <json>` — **Required**. Transaction data as JSON string (structure depends on chain family)

**Tx send parameters**:
- `--chain-family <family>` — **Required**. `evm` or `svm`
- `--chain-id <id>` — **Required**. Numeric chain ID
- `--signed-tx <data>` — **Required**. Signed transaction in base64 or hex encoding

## Operation Flow

### List Supported Chains

1. **Fetch chains**: `liberfi swap chains --json`
2. **Present**: Show chain name, chain ID, chain family (evm/svm)
3. **Suggest next step**: "Which chain do you want to trade on?"

### Find Available Tokens

1. **Fetch tokens**: `liberfi swap tokens --chain-id <id> --json`
2. **Present**: Show token name, symbol, address
3. **Suggest next step**: "Which tokens do you want to swap?"

### Get a Swap Quote

1. **Collect inputs**: Input token, output token, amount, chain family, chain ID
2. **(mandatory)** Run security check: `liberfi token security <chain> <outputTokenAddress> --json`
3. Review security result — warn user if any risk flags
4. **Get quote**: `liberfi swap quote --in <in> --out <out> --amount <amt> --chain-family <fam> --chain-id <id> --json`
5. **Present**: Show input amount, expected output amount, price impact, slippage, route
6. **Suggest next step**: "Want to execute this swap?"

### Execute a Swap (Full Flow)

1. **Collect inputs**: Account (wallet address), input/output tokens, amount, chain
2. **(mandatory)** Security check: `liberfi token security <chain> <outputTokenAddress> --json`
3. If security flags found → warn user, recommend NOT proceeding
4. **Get quote first**: `liberfi swap quote --in <in> --out <out> --amount <amt> --chain-family <fam> --chain-id <id> --json`
5. **Present swap summary to user**:
   - Input: X amount of TokenA
   - Output: ~Y amount of TokenB
   - Slippage: Z%
   - Estimated fees (if available)
6. **(mandatory)** Wait for explicit user confirmation
7. **Build transaction**: `liberfi swap execute --account <wallet> --in <in> --out <out> --amount <amt> --chain-family <fam> --chain-id <id> --quote-result '<quoteJson>' --json`
8. The response contains unsigned transaction data for the user/wallet to sign
9. **Suggest next step**: "Sign this transaction with your wallet, then I can broadcast it"

### Estimate Transaction Fee

1. **Estimate**: `liberfi tx estimate --chain-family <fam> --chain-id <id> --data '<txJson>' --json`
2. **Present**: Show estimated gas/fee in native token and USD equivalent
3. **Suggest next step**: "Ready to sign and send?"

### Broadcast Signed Transaction

1. **(mandatory)** Confirm user has signed the transaction
2. **(mandatory)** Final confirmation: "Are you sure you want to broadcast this transaction? This is irreversible."
3. **Send**: `liberfi tx send --chain-family <fam> --chain-id <id> --signed-tx <signedData> --json`
4. **Present**: Show transaction hash
5. **Suggest next step**: "Transaction submitted! You can track it on the block explorer."

## Cross-Skill Workflows

### "I want to swap SOL for USDC"

> Full flow: token → swap → swap

1. **token** → `liberfi token search --q "USDC" --chains sol --json` — Find USDC address on Solana
2. **token** → `liberfi token security sol <usdcAddress> --json` — Security check (mandatory)
3. **swap** → `liberfi swap quote --in So11111111111111111111111111111111111111112 --out <usdcAddress> --amount <amt> --chain-family svm --chain-id 0 --json` — Get quote
4. Present quote summary, wait for user confirmation
5. **swap** → `liberfi swap execute --account <wallet> ...` — Build transaction
6. User signs → `liberfi tx send ...` — Broadcast

### "What's the best price to buy this trending token?"

> Full flow: market → token → swap

1. **market** → `liberfi ranking trending sol 1h --limit 5 --json` — Get trending tokens
2. User picks a token
3. **token** → `liberfi token security sol <address> --json` — Mandatory security check
4. **swap** → `liberfi swap quote --in <baseToken> --out <address> --amount <amt> --chain-family svm --chain-id 0 --json`
5. Present quote with price impact analysis

### "Check my wallet, then sell half of my biggest holding"

> Full flow: portfolio → token → swap

1. **portfolio** → `liberfi wallet holdings sol <walletAddress> --json` — Get holdings
2. Identify largest holding, calculate half amount in smallest unit
3. **token** → `liberfi token security sol <tokenAddress> --json` — Security check
4. **swap** → `liberfi swap quote --in <tokenAddress> --out <baseToken> --amount <halfAmt> --chain-family svm --chain-id 0 --json`
5. Present quote, wait for confirmation
6. **swap** → `liberfi swap execute ...` → sign → `liberfi tx send ...`

## Suggest Next Steps

| Just completed | Suggest to user |
|----------------|-----------------|
| Chain list | "Which chain do you want to trade on?" / "想在哪条链上交易？" |
| Token list | "Which tokens do you want to swap?" / "想兑换哪些代币？" |
| Swap quote | "Want to execute this swap?" / "要执行这笔兑换吗？" |
| Swap execute | "Sign the transaction, then I can broadcast it." / "请签名交易，之后我可以广播。" |
| Fee estimate | "Ready to sign and send?" / "准备好签名并发送了吗？" |
| Tx send | "Transaction submitted! Track it on the block explorer." / "交易已提交！可在区块浏览器上查看。" |

## Edge Cases

- **Insufficient balance**: If the swap execute fails with an insufficient balance error, inform the user and suggest checking their holdings via `liberfi wallet holdings`
- **Slippage exceeded**: If the quote shows high price impact (>5%), warn the user and suggest reducing the amount or increasing slippage tolerance
- **Invalid token address**: Validate format before calling the API; ask user to verify the address
- **Unknown chain family**: Only `evm` and `svm` are supported; if user mentions a chain, map it to the correct family (e.g. Solana → `svm`, Ethereum/BSC/Base → `evm`)
- **Amount format error**: Remind user that amounts must be in smallest unit (lamports for SOL = amount * 10^9, wei for ETH = amount * 10^18)
- **Transaction already submitted**: If tx send fails, warn that the transaction may have already been broadcast; check status before retrying
- **Quote expired**: Quotes have a limited validity window; if too much time passes, get a new quote before executing
- **Network timeout**: Retry once after 3 seconds; if still fails, suggest checking connectivity

## Common Pitfalls

| Pitfall | Correct Approach |
|---------|-----------------|
| Using human-readable amounts (e.g. "1 SOL") | Convert to smallest unit first: 1 SOL = 1,000,000,000 lamports |
| Skipping security check before swap | ALWAYS run `liberfi token security` on the output token first |
| Executing swap without user confirmation | ALWAYS show quote summary and wait for explicit "yes" |
| Passing modified quote_result to execute | Pass the quote_result JSON through WITHOUT any modification |
| Broadcasting without confirming signing | Verify user has signed before calling `tx send` |
| Retrying failed tx send without checking | The tx may have been submitted; check on-chain status first |

## Security Notes

See [security-policy.md](../shared/security-policy.md) for global security rules.

Skill-specific rules:
- **Swap and transaction operations are HIGH RISK** — they can move funds irreversibly
- NEVER execute `swap execute` or `tx send` without explicit user confirmation
- ALWAYS run `token security` on the output token before presenting a swap quote
- If the security audit reveals honeypot or high tax flags, strongly recommend the user NOT proceed
- The `quote_result` field is opaque — pass it through as-is; do not interpret, modify, or display its raw content
- Transaction amounts in smallest unit are easy to get wrong — always double-check with the user: "You want to swap X SOL (= Y lamports), correct?"
- After broadcasting, provide the transaction hash so the user can independently verify on a block explorer
