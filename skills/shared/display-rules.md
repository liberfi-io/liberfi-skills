# Display Rules

Unified formatting rules for all LiberFi Agent Skills. The Agent parses `--json` output and presents results to users following these rules.

## Numeric Formatting

| Type | Rule | Example |
|------|------|---------|
| Token price (< $0.01) | Show up to 6 significant digits | `$0.00000342` |
| Token price ($0.01–$999) | 2–4 decimal places | `$1.2345`, `$0.85` |
| Token price (>= $1000) | 2 decimal places | `$1,234.56` |
| Market cap / Volume / TVL | Abbreviated with suffix | `$1.2M`, `$340K`, `$5.6B` |
| Percentage | 1–2 decimal places with sign | `+12.5%`, `-3.2%` |
| Token amount (large) | Abbreviated with suffix | `1.2M USDC`, `340K SOL` |
| Token amount (small) | Full precision | `0.00123 ETH` |
| Basis points (bps) | Convert to percentage for display | `100 bps` → `1%` |

## Abbreviation Rules

| Range | Suffix | Example |
|-------|--------|---------|
| >= 1,000,000,000 | B | `$5.6B` |
| >= 1,000,000 | M | `$1.2M` |
| >= 1,000 | K | `$340K` |
| < 1,000 | No abbreviation | `$850` |

## Address Display

| Context | Rule | Example |
|---------|------|---------|
| In-line reference | Truncated: first 6 + last 4 chars | `So1111...1112` |
| Detailed view / Copy target | Full address | `So11111111111111111111111111111111111111112` |
| Transaction hash | Truncated: first 8 + last 6 chars | `5xGt9Qkz...a3bF2c` |

Always provide the full value when the user may need to copy it (e.g. for wallet lookup or token search).

## Time Formatting

| Context | Format | Example |
|---------|--------|---------|
| Timestamps | Relative time when < 24h | `3 minutes ago`, `2 hours ago` |
| Timestamps | Date when >= 24h | `Mar 28, 2026` |
| Duration parameters | Use CLI format directly | `1h`, `24h`, `7d`, `30d` |
| K-line resolution | Use CLI format directly | `1m`, `5m`, `15m`, `1h`, `4h`, `1d` |

## Sorting Defaults

| Data Type | Default Sort |
|-----------|-------------|
| Token search results | By relevance (API default) |
| Trending tokens | By volume descending |
| Wallet holdings | By value descending |
| Wallet activity | By time descending (newest first) |
| Token holders | By holding amount descending |
| Token pools | By liquidity descending |

## Empty State

When a query returns no results, clearly inform the user:

| Scenario | English | Chinese |
|----------|---------|---------|
| No results | "No results found." | "未找到相关结果。" |
| Empty holdings | "This wallet has no token holdings on this chain." | "该钱包在此链上没有代币持仓。" |
| No pools | "No DEX pools found for this token." | "未找到该代币的 DEX 池子。" |
| No activity | "No recent activity for this wallet." | "该钱包暂无近期活动。" |

## Multi-Language Message Templates

The Agent should match the user's conversation language. Key messages:

| Scenario | English | Chinese |
|----------|---------|---------|
| Confirm action | "Confirm this action?" | "确认执行此操作？" |
| Operation success | "Done! Here's the result:" | "完成！结果如下：" |
| Suggest next step | "Would you like to..." | "需要..." |
| Error occurred | "Something went wrong:" | "出现错误：" |
| Security warning | "Warning: This token has potential risks:" | "警告：该代币存在潜在风险：" |
| Swap confirmation | "Please review this swap:" | "请确认以下交易：" |

## Table Formatting

When presenting lists (e.g. trending tokens, holdings), use tables with these column priorities:

- **Token lists**: Name, Symbol, Price, Change (%), Volume, Market Cap
- **Holdings**: Token, Amount, Value (USD), Change (24h)
- **Activity**: Time, Type, Token, Amount, Tx Hash
- **Pools**: DEX, Pair, Liquidity, Volume (24h)

Limit table rows to **10–20** items by default. If more results exist, inform the user and suggest pagination.
