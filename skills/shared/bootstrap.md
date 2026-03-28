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

The CLI currently does **not** require API keys or login. All commands are public.

> **Future-proofing**: If authentication is added later, the auth flow (e.g. `liberfi auth login`) will be documented here. Skills should check this section before assuming public access.

## 8. Pre-flight Checklist (run before any skill command)

1. Confirm `liberfi` is installed: `liberfi --version`
2. If not installed → install via step 1
3. Run `liberfi ping --json` to verify connectivity
4. If ping fails → check network / `LIBERFI_API_BASE_URL`
5. Proceed with skill commands, always appending `--json`
