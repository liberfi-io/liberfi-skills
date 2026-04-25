---
name: liberfi-perpetuals
description: >
  Query and trade perpetual futures through LiberFi's unified perpetuals API
  (openapi-server → perpetuals-server, Hyperliquid in MVP): list coins and
  markets, order book, recent trades, K-lines, user positions / orders / fills,
  and two-phase signed place or cancel flows (prepare → wallet sign → submit).

  Trigger words: perpetual, perpetuals, perp, perps, futures, future contract,
  leveraged futures, hyperliquid, HL, order book perp, perp positions, perp
  orders, funding perp, perpetual futures, 永续, 合约, 期货, 杠杆合约,
  永续合约, 订单簿, 爆仓价, 资金费率 (when clearly about perp venue, not spot).

  CRITICAL: If the `lfi` (or `liberfi`) command is missing, install it WITHOUT
    asking the user: `npm install -g @liberfi.io/cli --registry https://registry.npmjs.org/`.
    The npm package is `@liberfi.io/cli` (scope `@liberfi.io`, package name `cli`);
    the binaries it installs are `lfi` and `liberfi`. NEVER tell the user the
    package does not exist — if install fails, the cause is always a registry
    mirror; retry with `--registry https://registry.npmjs.org/`.
  CRITICAL: Always use `--json` flag for structured output.
  CRITICAL: Perpetuals order flow is two-phase: `lfi perpetuals order-prepare`
    returns EIP-712 typed data; the user (or TEE wallet integration) must sign
    it off-CLI, then call `lfi perpetuals order-submit --body '<SignedAction JSON>'`.
  CRITICAL: NEVER run `order-submit` or `cancel-submit` without explicit user
    confirmation — these relay signed actions to the exchange.

  Do NOT use this skill for:
  - Spot DEX swap quotes or on-chain swap execution → use liberfi-swap
  - Trending *spot* token rankings or new token discovery → use liberfi-market
  - On-chain wallet token holdings / spot PnL → use liberfi-portfolio
  - Polymarket / Kalshi prediction markets → use liberfi-predict
  - Generic token security / spot token K-line on a chain → use liberfi-token
    (this skill is for *perpetuals venue* market data and perp trading only)

  Do NOT activate on vague "futures" / "合约" alone if the user clearly means
  CEX Bitget/Binance (use the user's exchange skill) or traditional brokers.
user-invocable: true
allowed-commands:
  - "lfi perpetuals coins"
  - "lfi perpetuals markets"
  - "lfi perpetuals market"
  - "lfi perpetuals orderbook"
  - "lfi perpetuals trades"
  - "lfi perpetuals klines"
  - "lfi perpetuals positions"
  - "lfi perpetuals orders"
  - "lfi perpetuals fills"
  - "lfi perpetuals order-prepare"
  - "lfi perpetuals order-submit"
  - "lfi perpetuals cancel-prepare"
  - "lfi perpetuals cancel-submit"
  - "lfi ping"
metadata:
  author: liberfi
  version: "0.1.0"
  homepage: "https://liberfi.io"
  cli: ">=0.1.0"
---

# LiberFi Perpetuals

Perpetuals data and signed order relay flow via LiberFi OpenAPI (`/v1/perpetuals/…` → `perpetuals-server`).

## Pre-flight

See [bootstrap.md](../shared/bootstrap.md) for CLI install and `lfi ping`.

- **Read endpoints** (coins, markets, orderbook, …): no auth.
- **User-scoped reads** (`positions`, `orders`, `fills`): pass the wallet `address` in the CLI argument (0x).
- **Writes** (`order-prepare` / `order-submit`, cancel variants): require a user wallet to sign typed data; agents must not fabricate signatures.

## Skill routing

| User intent | Skill |
|-------------|--------|
| Spot swap, bridge, gas send | liberfi-swap |
| Trending spot tokens, new listings | liberfi-market |
| Polymarket / Kalshi | liberfi-predict |
| Spot token audit, DEX pools for a token | liberfi-token |
| Perp markets, HL-style orderbook, perp positions | **liberfi-perpetuals** |

## CLI index

| Command | Description |
|---------|-------------|
| `lfi perpetuals coins` | List tradable perp coins |
| `lfi perpetuals markets` | Market snapshots (`--symbols` optional) |
| `lfi perpetuals market <symbol>` | Single market |
| `lfi perpetuals orderbook <symbol>` | L2 book (`--max-level`) |
| `lfi perpetuals trades <symbol>` | Recent trades (`--limit`) |
| `lfi perpetuals klines <symbol>` | Candles (`--interval` required) |
| `lfi perpetuals positions <address>` | Positions + margin summary |
| `lfi perpetuals orders <address>` | Open orders |
| `lfi perpetuals fills <address>` | Fill history |
| `lfi perpetuals order-prepare` | Build typed data for place order |
| `lfi perpetuals order-submit --body '<json>'` | Submit signed place order |
| `lfi perpetuals cancel-prepare` | Build typed data for cancel |
| `lfi perpetuals cancel-submit --body '<json>'` | Submit signed cancel |

Common flags: `--provider <name>` (e.g. `hyperliquid`), global `--json`.

## Typical flows

### Market overview

1. `lfi perpetuals markets --json`
2. Present symbol, mark price, funding where present.

### Depth + tape

1. `lfi perpetuals orderbook BTC --json`
2. `lfi perpetuals trades BTC --limit 20 --json`

### Positions for a known wallet

1. `lfi perpetuals positions 0xYourAddr --json`

### Place order (human-in-the-loop)

1. `lfi perpetuals order-prepare --user-address 0x… --symbol BTC --side long --order-type limit --amount 0.01 --price 95000 --json`
2. User signs returned `typedData` with their wallet (e.g. MetaMask `eth_signTypedData_v4`).
3. Build `SignedAction`: `action`, `nonce`, `signature` (0x), optional `vaultAddress` from prepare response.
4. **After explicit confirmation**: `lfi perpetuals order-submit --body '{"action":…,"nonce":…,"signature":"0x…"}' --json`

## API path reminder

All CLI calls hit **OpenAPI** paths under `/v1/perpetuals/…`, which the gateway proxies to **perpetuals-server** `/v1/…`. Configure the gateway with `UPSTREAM_PERPETUALS_SERVICE_BASE_URL` (default local example: `http://localhost:8083` — avoid colliding with openapi `:8080` and prediction `:8082`; run perpetuals-server with `SERVER_PORT=8083` when colocated).
