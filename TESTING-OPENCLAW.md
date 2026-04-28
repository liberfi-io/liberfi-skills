# Testing LiberFi Skills in OpenClaw

End-to-end guide for testing all seven LiberFi skills inside an OpenClaw chat session, starting from a "user only has OpenClaw installed" state.

## I. Reset to bare OpenClaw (shell, one-time)

```bash
openclaw uninstall --service --state --workspace --yes || true
npm uninstall -g @liberfi.io/cli 2>/dev/null || true
rm -rf ~/.openclaw ~/.liberfi
```

This wipes every LiberFi-related artifact (skills, CLI, session, keys), leaving only the `openclaw` binary on `PATH`.

## II. Start OpenClaw (shell)

```bash
openclaw setup --wizard       # follow prompts for model + gateway config
openclaw gateway --force &
sleep 2
openclaw tui                  # opens the chat
```

## III. Test inside the chat (everything else is user-language only)

### Step 1 — Install the skills (one sentence)

```
帮我安装 liberfi-io/liberfi-skills 的全部 skills
```

OpenClaw will run `npx skills add liberfi-io/liberfi-skills --skill '*' -a openclaw -y` and prompt for exec approval — approve once.

### Step 2 onward — Talk like a normal user

#### A. Token / market
```
帮我看下 sol 链上的 BONK 现在多少钱
BONK 安不安全，能买吗
谁是 BONK 的大户
SOL 最近一天 K 线给我看下
sol 上现在最热门的币是哪些
sol 上有没有刚发的新币
pump.fun 上最近一小时哪个币涨得最猛
```
> The first prompt triggers `npm install -g @liberfi.io/cli` (approve once).

#### B. Wallet / portfolio
```
这个 sol 钱包持有什么 5ZWj7a1f8tWkjBESHKgrLmXMEo2BTrEZtJhNR6dvVjbG
它最近赚了多少钱
我自己的钱包里有什么币
我最近一个月赚了多少
我的钱包总共值多少钱
```
> "我自己的钱包" triggers `lfi login key --role AGENT` (approve once). Session is reused for 24h.

#### C. Trading
```
我想在 sol 上买点 TRUMP 币
1 SOL 能换多少 USDC
帮我把 0.001 SOL 换成 USDC
```
> Mutating ops run a security audit, show a quote, then **ask yes/no** before broadcasting. Real money — start with the smallest amount.

#### D. Prediction markets
```
Kalshi 上有什么关于比特币的预测
我在预测市场赚了多少
我现在押了哪些
```

#### E. Perpetuals (Hyperliquid MVP)

Read-only queries:
```
Hyperliquid 上有哪些永续合约
BTC 永续现在订单簿什么样
ETH 永续最近一小时 K 线给我看下
我在 Hyperliquid 上有什么持仓
```
> Read-only queries route through `lfi perpetuals coins/markets/orderbook/candles/user-positions`.
> Order placement is two-phase (`order-prepare` returns EIP-712 typed data → wallet
> signs externally → `order-submit` relays). Don't expect the agent to broadcast
> a perp order without an external signer wired in.

Deposit (Solana → Hyperliquid via Relay, TEE one-click):
```
帮我向永续合约账户入金 0.1 SOL
Deposit 1 SOL to my Hyperliquid perpetuals account
我想给我的 perp 账户充值
```
> Expected agent behaviour:
> 1. If `lfi status` shows not authenticated → run `lfi login key` first.
> 2. Confirm the **deposit amount** (and recipient if non-default) with the user
>    before doing anything irreversible.
> 3. Convert SOL → lamports (×1e9) and call
>    `lfi perpetuals deposit-place --gross-lamports <n> --json`.
> 4. Print the returned `intentId` + `solanaTxHash`, then poll
>    `lfi perpetuals deposit-status <intentId>` until `status: settled`.
>
> Reverse case — agent must **ask for the amount** when the user says
> "我想给我的 perp 账户充值" without a number.

Deposit status query:
```
查一下我刚才那笔 perp 入金的状态
强制刷新 perp deposit XXXX 的状态
```
> Without "强制" / "再查一次" / "force refresh" → `lfi perpetuals deposit-status <id> --json`.
> With those modifiers → `lfi perpetuals deposit-status <id> --refresh --json`.

Atomic deposit flow (advanced — escape hatch):
```
先帮我拿一份 perp deposit 的报价：从 <SOL 地址> 入 0.5 SOL 到 <EVM 地址>
我已经广播了交易 <txHash>，请帮我提交 perp deposit submit
```
> Expected: `deposit-quote` for the first prompt, `deposit-submit` for the second.
> Agent must **not** offer to sign / broadcast the SOL tx itself in the atomic
> flow — the whole point of this path is that the user controls signing.

Counter-examples (route to OTHER skills, not liberfi-perpetuals):
```
帮我充值 USDC 到 Polymarket          → liberfi-predict (polymarket-deposit-addresses)
我想 swap SOL 换 USDC                 → liberfi-swap
查我钱包里的 SOL 余额                  → liberfi-portfolio
```
> The word "充值 / 入金 / deposit" alone is not enough — agent must distinguish
> by destination (perp account vs prediction Safe vs spot wallet vs swap).

#### F. Cross-skill routing
```
sol 上最热的 meme 币挑一个，安全的话帮我买 0.001 SOL
我钱包里最不值钱的币，帮我换成 USDC
比特币最近一天涨跌怎么样，Kalshi 上有相关预测吗
BTC 现货价格 vs Hyperliquid BTC 永续标记价差多少
```

## IV. What you have to do during the test

| Moment | Action |
|---|---|
| Step 1 — install skills | Approve `npx skills add ...` |
| First read-only command | Approve `npm install -g @liberfi.io/cli` |
| First "我的…" command | Approve `lfi login key ...` |
| Any swap / order command | Type `yes` after the quote + safety summary |
| Everything else | Just read the answer |

## V. Pass/fail criteria

| Category | Success looks like |
|---|---|
| A. Token / market | Real prices, market cap, candle data, security score |
| B. Wallet | "我自己的…" returns your real holdings / PnL / net worth |
| C. Trading | Quote numbers reasonable; on confirm, balance changes on chain |
| D. Prediction | Real Kalshi / Polymarket events, balance, positions |
| E. Perpetuals | Hyperliquid coin list, live order book, your TEE wallet positions, `deposit-place` returns intentId + tx hash, status polls until `settled` |
| F. Cross-skill | Agent chains skills automatically without you naming them |

## VI. Troubleshooting

| Symptom | Fix |
|---|---|
| Agent says skill not found | Repeat Step 1 prompt |
| Agent says "lfi not on npm" | Outdated skills cache — `openclaw skills update`, or repeat Step 1 |
| `npm install` fails / times out | Switch to official npm registry: `nrm use npm`, retry |
| 401 / login failed | `rm -rf ~/.liberfi`, then in chat say "我的钱包里有什么币" |
| Completely stuck | Re-run Section I, start over |

## VII. Recurring use

Next time you want to retest, in any Cursor chat just say **"重置 OpenClaw"** and the rule at `liberfi-skills/.cursor/rules/openclaw-zero-state-reset.mdc` will run Section I for you.
