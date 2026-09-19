# Vendored OmniRoute agent skills

Agent skills copied from the OmniRoute project so Claude Code loads them
automatically when running in this repository.

- Upstream: https://github.com/diegosouzapw/OmniRoute
- Source path: `skills/{id}/SKILL.md` (branch `main`)
- Vendored: 2026-09-19
- License: MIT (per upstream repository)

## What's here

| Skill | Covers |
| --- | --- |
| `omni-combos-routing` | Routing combos, 19 strategies, fallback chains, route testing |
| `omni-providers` | Provider connections, API keys, OAuth flows, connection tests |
| `omni-inference` | OpenAI-compatible endpoints: chat, embeddings, images, audio, rerank |
| `omni-compression` | RTK and Caveman compression, language packs, custom rules |
| `omni-mcp` | OmniRoute MCP server — tools and the SSE/stdio/HTTP transports |
| `omni-auth` | Bearer tokens, session cookies, login configuration |
| `omni-resilience` | Provider health, circuit breakers, latency percentiles, budget guards |
| `cli-serve` | `omniroute serve` — daemon mode, ports, auto-recovery |
| `cli-chat` | `omniroute chat` — completions, streaming, interactive REPL |
| `cli-setup` | `omniroute setup` — initial config, env vars, autostart |
| `omni-github-skills` | Searching, scoring, scanning, and importing agent skills from GitHub |

Upstream's full catalog is larger (42 canonical skills: 22 REST API + 20 CLI).
These are the ones carrying hand-written content rather than generated stubs.
`omni-github-skills` is the exception — it is a thin stub with no endpoints
mapped yet, kept because it was the original reason for this directory.

## Prerequisite

These files document OmniRoute's REST API and CLI. They are reference material
until you have a reachable OmniRoute instance:

1. Run or point at an OmniRoute server (default local port `20128`).
2. Authenticate with a bearer token via `POST /api/auth/login`, or set
   `REQUIRE_API_KEY=false` for local development.
3. `GET /api/openapi/spec` has the authoritative request/response schemas.

## Re-syncing

Upstream generates most of these from `src/lib/agentSkills/generator.ts`, so
refresh them rather than hand-editing:

    .claude/skills/sync-omniroute-skills.sh

Review `git diff` afterwards before committing. The script overwrites skill
files in place, and skill files are instructions this agent will follow.

## Caution

Skills pulled from public repositories are third-party instructions. The copies
here were scanned for pipe-to-shell commands, embedded credentials, and prompt
injection before being committed. Re-check after every sync, and keep your own
secrets out of anything committed to this directory.
