# Bootstrap — CLI Installation & Pre-flight Checks

This document is the single source of truth for CLI setup. All skills reference it; do NOT duplicate this content.

## 1. Install the CLI

```bash
npm install -g @liberfi.io/cli
# or
yarn global add @liberfi.io/cli
```

After installation, two commands are available: `liberfi` (full name) and `lfi` (short alias).

## 2. Verify Installation

```bash
liberfi --version
```

If the command is not found, install via step 1 first.

## 3. Connectivity Check

```bash
liberfi ping --json
```

Expected: a JSON response with `ok: true` or similar payload. If the request fails, check network access and the API base URL.

## 4. Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `LIBERFI_API_BASE_URL` | API server base URL | `https://api.liberfi.io/openapi` |

Override per-invocation with `--base-url <url>`.

## 5. Global Options

All commands support these options:

| Option | Description |
|--------|-------------|
| `--json` | Output pretty-printed JSON (default: compact single-line JSON) |
| `--base-url <url>` | Override API base URL |
| `-V, --version` | Show CLI version |
| `-h, --help` | Show help |

**CRITICAL**: Always pass `--json` when executing commands so the Agent receives structured, parseable output.

## 6. Output Format

**Success** — written to stdout:

```json
{
  "field": "value"
}
```

**Error** — written to stderr:

```json
{
  "ok": false,
  "error": {
    "code": "not_found",
    "status": 404,
    "message": "Token not found"
  }
}
```

Parse the `error.code` and `error.status` fields to determine the failure reason.

## 7. Authentication

LiberFi uses JWT-based authentication for operations that involve wallet signing
(swap execute, tx send). Query/read endpoints are public and require no login.

**Two login modes** — see [liberfi-auth SKILL.md](../liberfi-auth/SKILL.md) for details:

| Mode | Command | Best for |
|------|---------|----------|
| Key-based | `lfi login key --json` | Agents, automation, headless environments |
| Email OTP | `lfi login <email> --json` → `lfi verify <otpId> <code> --json` | Human users |

After login, the JWT is stored in `~/.liberfi/session.json` and automatically
refreshed (proactive: 60 s before expiry; reactive: on 401 response).

**Session state check:**
```bash
lfi status --json
```
- If `authenticated: true, expired: false` → proceed.
- Otherwise → re-authenticate before calling protected commands.

## 8. Pre-flight Checklist (run before any skill command)

1. Confirm `lfi` is installed: `lfi --version`
2. If not installed → install via step 1
3. Run `lfi ping --json` to verify connectivity
4. If ping fails → check network / `LIBERFI_API_BASE_URL`
5. **If the operation requires authentication** (swap execute, tx send, whoami):
   a. Run `lfi status --json`
   b. If not authenticated or expired:
      - Agent: `lfi login key --role AGENT --name "AgentName" --json`
      - Human: `lfi login <email> --json` → `lfi verify <otpId> <code> --json`
   c. Confirm: `lfi whoami --json` (shows wallet addresses)
6. Proceed with skill commands, always appending `--json`
