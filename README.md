# LiberFi Agent Skills

AI Agent skills for the [LiberFi](https://liberfi.io) platform. These skills enable AI agents to research tokens, discover market trends, analyze wallets, and execute on-chain swaps — all through natural language, powered by the [`@liberfi.io/cli`](https://www.npmjs.com/package/@liberfi.io/cli).

## Skills

| Skill | Description | Reference |
|-------|-------------|-----------|
| [liberfi-auth](skills/liberfi-auth/SKILL.md) | Authentication: key-based login, email OTP, session management, wallet assignment | [SKILL.md](skills/liberfi-auth/SKILL.md) |
| [liberfi-token](skills/liberfi-token/SKILL.md) | Token research: search, details, security audit, pools, holders, traders, K-line | [SKILL.md](skills/liberfi-token/SKILL.md) |
| [liberfi-market](skills/liberfi-market/SKILL.md) | Market discovery: trending token rankings, new token listings | [SKILL.md](skills/liberfi-market/SKILL.md) |
| [liberfi-portfolio](skills/liberfi-portfolio/SKILL.md) | Portfolio analysis: public wallet & own TEE wallet holdings, activity, PnL stats, net worth | [SKILL.md](skills/liberfi-portfolio/SKILL.md) |
| [liberfi-swap](skills/liberfi-swap/SKILL.md) | Swap & transactions: quotes, TEE wallet trade execution, fee estimation, broadcast | [SKILL.md](skills/liberfi-swap/SKILL.md) |
| [liberfi-predict](skills/liberfi-predict/SKILL.md) | Prediction markets: events, balances, positions, trades, orders, Kalshi/Polymarket order placement | [SKILL.md](skills/liberfi-predict/SKILL.md) |

## Capability Matrix

| Capability | Skill | Auth | Mutating | Needs Confirmation |
|------------|-------|------|----------|--------------------|
| Key-based login (agent / headless) | liberfi-auth | No | No | No |
| Email OTP login — send code | liberfi-auth | No | No | No |
| Email OTP login — verify code | liberfi-auth | No | No | No |
| Check current user profile | liberfi-auth | Yes | No | No |
| Check local session status | liberfi-auth | No | No | No |
| Logout (clear local session) | liberfi-auth | No | No | No |
| Search tokens by keyword | liberfi-token | No | No | No |
| Get token details (price, MC, volume) | liberfi-token | No | No | No |
| Run token security audit | liberfi-token | No | No | No |
| List DEX liquidity pools | liberfi-token | No | No | No |
| View top token holders | liberfi-token | No | No | No |
| Find smart money traders | liberfi-token | No | No | No |
| Get K-line candlestick data | liberfi-token | No | No | No |
| View trending token rankings | liberfi-market | No | No | No |
| Discover newly listed tokens | liberfi-market | No | No | No |
| View public wallet token holdings | liberfi-portfolio | No | No | No |
| View public wallet transaction activity | liberfi-portfolio | No | No | No |
| Check public wallet PnL statistics | liberfi-portfolio | No | No | No |
| Get public wallet net worth | liberfi-portfolio | No | No | No |
| View own TEE wallet holdings | liberfi-portfolio | Yes | No | No |
| View own TEE wallet activity | liberfi-portfolio | Yes | No | No |
| Check own TEE wallet PnL statistics | liberfi-portfolio | Yes | No | No |
| Get own TEE wallet net worth | liberfi-portfolio | Yes | No | No |
| List supported swap chains | liberfi-swap | No | No | No |
| List available swap tokens | liberfi-swap | No | No | No |
| Get swap quote | liberfi-swap | No | No | No |
| Execute swap via TEE wallet | liberfi-swap | Yes | Yes | Yes |
| Sign and broadcast swap in one step | liberfi-swap | Yes | Yes | Yes (irreversible) |
| Estimate transaction fee | liberfi-swap | No | No | No |
| Broadcast signed transaction | liberfi-swap | Yes | Yes | Yes (irreversible) |
| List prediction events (Kalshi / Polymarket) | liberfi-predict | No | No | No |
| Get prediction event detail | liberfi-predict | No | No | No |
| Check prediction USDC balance | liberfi-predict | No | No | No |
| View prediction positions | liberfi-predict | No | No | No |
| List prediction trade history | liberfi-predict | No | No | No |
| List / inspect prediction orders | liberfi-predict | No (POLY_* for Polymarket) | No | No |
| Request Kalshi quote | liberfi-predict | No | No | No |
| Submit signed Kalshi transaction | liberfi-predict | No | Yes | Yes (irreversible) |
| Create Polymarket order | liberfi-predict | POLY_* headers | Yes | Yes (irreversible) |

## Getting Started

### Quick Install (recommended)

One command installs the CLI and every skill into every detected agent
(Cursor, Claude Code, Codex, …):

```bash
curl -fsSL https://raw.githubusercontent.com/liberfi-io/liberfi-skills/main/scripts/install.sh | bash
```

The installer is idempotent — re-run it anytime to upgrade.
Pass `--agents <list>` to target specific agents:

```bash
curl -fsSL https://raw.githubusercontent.com/liberfi-io/liberfi-skills/main/scripts/install.sh \
  | bash -s -- --agents cursor,claude-code
```

Other flags: `--skip-cli`, `--skip-skills`, `--skip-ping`. Run with
`--help` for the full reference.

### Manual install (if you prefer step-by-step)

1. Install the CLI:

   ```bash
   npm install -g @liberfi.io/cli
   liberfi --version
   liberfi ping --json
   ```

2. Install all skills into every detected agent:

   ```bash
   npx skills add liberfi-io/liberfi-skills --all
   ```

   Or target specific agents:

   ```bash
   npx skills add liberfi-io/liberfi-skills --skill '*' -a cursor -a claude-code -y
   ```

### Verify

Test with a simple query — send this to your AI agent:

```
Search for Bitcoin token info on Solana
```

## Quick Start Examples

### Token Research

```
Search for BONK token on Solana and check if it's safe to buy.
```

### Market Discovery

```
Show me the top 10 trending tokens on Solana in the last 24 hours.
```

### Portfolio Analysis

```
Check my wallet holdings on Solana: 5ZWj7a1f8tWkjBESHKgrLmXMEo2BTrEZtJhNR6dvVjbG
```

### Swap Execution

```
Get a swap quote for 1 SOL to USDC on Solana.
```

### Prediction Markets

```
Show me trending Kalshi prediction events about Bitcoin.
```

## Supported Chains

| Chain | Identifier | Family | Token / Market / Portfolio | Swap |
|-------|-----------|--------|---------------------------|------|
| Solana | `sol` | svm | Yes | Yes |
| Ethereum | `eth` | evm | Yes | Yes |
| BNB Chain | `bsc` | evm | Yes | Yes |

> Additional chains may be available. Run `liberfi swap chains --json` to see the full list.

## Architecture

```
Natural Language Input
    |
AI Agent (Cursor / Claude Code / Codex / OpenClaw / ...)
    |
SKILL.md (skill routing + operation flow)
    |
@liberfi.io/cli  (liberfi / lfi)
    |  --json output
LiberFi OpenAPI (api.liberfi.io/openapi)
    |
Structured JSON → Agent interprets → Natural language response
```

## Configuration

| Environment Variable | Description | Default |
|---------------------|-------------|---------|
| `LIBERFI_API_BASE_URL` | API server base URL | `https://api.liberfi.io/openapi` |

Override per-invocation: `liberfi --base-url <url> <command>`

## Shared Resources

Skills share common configurations in [`skills/shared/`](skills/shared/):

| File | Purpose |
|------|---------|
| [bootstrap.md](skills/shared/bootstrap.md) | CLI installation, pre-flight checks, environment config |
| [security-policy.md](skills/shared/security-policy.md) | Security rules, risk levels, safety flow for swaps |
| [display-rules.md](skills/shared/display-rules.md) | Number formatting, address display, multi-language templates |

## Compatible Platforms

Any AI agent that can **read files + run CLI commands** should work with these skills.

All commands install every skill non-interactively (`--skill '*' -y`):

| Platform | How to Use |
|----------|-----------|
| Cursor | `npx skills add liberfi-io/liberfi-skills --skill '*' -a cursor -y` |
| Claude Code | `npx skills add liberfi-io/liberfi-skills --skill '*' -a claude-code -y` |
| Codex | `npx skills add liberfi-io/liberfi-skills --skill '*' -a codex -y` |
| OpenClaw | `npx skills add liberfi-io/liberfi-skills --skill '*' -a openclaw -y` |
| Cline | `npx skills add liberfi-io/liberfi-skills --skill '*' -a cline -y` |
| Windsurf | `npx skills add liberfi-io/liberfi-skills --skill '*' -a windsurf -y` |
| OpenCode | `npx skills add liberfi-io/liberfi-skills --skill '*' -a opencode -y` |

Or use the [Quick Install](#quick-install-recommended) script with
`--agents <list>` to do the same in one line.

See [vercel-labs/skills](https://github.com/vercel-labs/skills) for the full list of supported agents.

## Security

- Read-only commands (token info, rankings, public wallet) use public endpoints — no authentication required
- Mutating commands (`swap execute`, `swap sign-and-send`, `tx send`, `me *`) require JWT authentication — run `lfi login key --json` (agent) or email OTP flow (human) first
- `swap execute` and `swap sign-and-send` sign and broadcast transactions server-side via the authenticated user's TEE wallet — no manual signing step is required, and funds move immediately upon execution
- Token security audits are run as mandatory pre-checks before any swap
- All mutating operations require explicit user confirmation
- See [security-policy.md](skills/shared/security-policy.md) for the complete security policy

## Contributing

To add a new skill:

1. Create a folder in `skills/` with a lowercase, hyphenated name
2. Add a `SKILL.md` file with YAML frontmatter (`name`, `description`, `allowed-commands`)
3. Follow the content structure: Pre-flight, Routing, Command Index, Operation Flow, Cross-Skill Workflows, Suggest Next Steps, Edge Cases, Security Notes
4. Update the Capability Matrix in this README
5. Update shared resources if the new skill introduces common patterns

See the [Agent Skills specification](https://github.com/vercel-labs/skills) for the complete format.

## License

MIT
