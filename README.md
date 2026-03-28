# LiberFi Agent Skills

AI Agent skills for the [LiberFi](https://liberfi.io) platform. These skills enable AI agents to research tokens, discover market trends, analyze wallets, and execute on-chain swaps — all through natural language, powered by the [`@liberfi.io/cli`](https://www.npmjs.com/package/@liberfi.io/cli).

## Skills

| Skill | Description | Reference |
|-------|-------------|-----------|
| [liberfi-token](skills/liberfi-token/SKILL.md) | Token research: search, details, security audit, pools, holders, traders, K-line | [SKILL.md](skills/liberfi-token/SKILL.md) |
| [liberfi-market](skills/liberfi-market/SKILL.md) | Market discovery: trending token rankings, new token listings | [SKILL.md](skills/liberfi-market/SKILL.md) |
| [liberfi-portfolio](skills/liberfi-portfolio/SKILL.md) | Portfolio analysis: wallet holdings, activity, PnL stats, net worth | [SKILL.md](skills/liberfi-portfolio/SKILL.md) |
| [liberfi-swap](skills/liberfi-swap/SKILL.md) | Swap & transactions: quotes, trade execution, fee estimation, broadcast | [SKILL.md](skills/liberfi-swap/SKILL.md) |

## Capability Matrix

| Capability | Skill | Auth | Mutating | Needs Confirmation |
|------------|-------|------|----------|--------------------|
| Search tokens by keyword | liberfi-token | No | No | No |
| Get token details (price, MC, volume) | liberfi-token | No | No | No |
| Run token security audit | liberfi-token | No | No | No |
| List DEX liquidity pools | liberfi-token | No | No | No |
| View top token holders | liberfi-token | No | No | No |
| Find smart money traders | liberfi-token | No | No | No |
| Get K-line candlestick data | liberfi-token | No | No | No |
| View trending token rankings | liberfi-market | No | No | No |
| Discover newly listed tokens | liberfi-market | No | No | No |
| View wallet token holdings | liberfi-portfolio | No | No | No |
| View wallet transaction activity | liberfi-portfolio | No | No | No |
| Check wallet PnL statistics | liberfi-portfolio | No | No | No |
| Get wallet net worth | liberfi-portfolio | No | No | No |
| List supported swap chains | liberfi-swap | No | No | No |
| List available swap tokens | liberfi-swap | No | No | No |
| Get swap quote | liberfi-swap | No | No | No |
| Build swap transaction | liberfi-swap | No | Yes | Yes |
| Estimate transaction fee | liberfi-swap | No | No | No |
| Broadcast signed transaction | liberfi-swap | No | Yes | Yes (irreversible) |

## Getting Started

### 1. Prerequisites

Install the LiberFi CLI:

```bash
npm install -g @liberfi.io/cli
```

Verify installation:

```bash
liberfi --version
liberfi ping --json
```

### 2. Install Skills

#### Via Agent (recommended)

Send this to your AI agent:

```
npx skills add liberfi-io/liberfi-skills
```

#### Manual installation

```bash
npx skills add liberfi-io/liberfi-skills
```

Install to specific agents:

```bash
npx skills add liberfi-io/liberfi-skills -a cursor -a claude-code
```

Install all skills:

```bash
npx skills add liberfi-io/liberfi-skills --all
```

### 3. Verify

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

| Platform | How to Use |
|----------|-----------|
| Cursor | `npx skills add liberfi-io/liberfi-skills -a cursor` |
| Claude Code | `npx skills add liberfi-io/liberfi-skills -a claude-code` |
| Codex | `npx skills add liberfi-io/liberfi-skills -a codex` |
| OpenClaw | `npx skills add liberfi-io/liberfi-skills -a openclaw` |
| Cline | `npx skills add liberfi-io/liberfi-skills -a cline` |
| Windsurf | `npx skills add liberfi-io/liberfi-skills -a windsurf` |
| OpenCode | `npx skills add liberfi-io/liberfi-skills -a opencode` |

See [vercel-labs/skills](https://github.com/vercel-labs/skills) for the full list of supported agents.

## Security

- No API keys or authentication required — all commands use public endpoints
- Swap operations generate transaction data but do NOT sign automatically — the user must sign with their own wallet
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
