# omni-github-skills

Agent skill vendored from the OmniRoute project so Claude Code picks it up when
running in this repository.

## Provenance

- Upstream: https://github.com/diegosouzapw/OmniRoute
- Source path: `skills/omni-github-skills/SKILL.md` (branch `main`)
- Vendored: 2026-09-19
- License: MIT (per upstream repository)

`SKILL.md` is a verbatim copy apart from two provenance comments. Upstream
generates the file from `src/lib/agentSkills/generator.ts`, so re-sync it rather
than hand-editing:

    curl -fsSL https://raw.githubusercontent.com/diegosouzapw/OmniRoute/main/skills/omni-github-skills/SKILL.md -o .claude/skills/omni-github-skills/SKILL.md

## What it covers

OmniRoute's API surface for discovering agent skills on GitHub: searching
repositories that contain `SKILL.md`, `CLAUDE.md`, `.cursorrules` and similar
files, scoring them for relevance, scanning them for malware or hardcoded
secrets, and installing them into a local agent skills directory.

## What it needs to actually run

The file documents a REST API, not a self-contained workflow. Using it requires
a reachable OmniRoute instance (self-hosted or hosted) plus credentials:

1. Run or point at an OmniRoute server.
2. Get a bearer token via `POST /api/auth/login`, or set `REQUIRE_API_KEY=false`
   for local development.
3. Read `GET /api/openapi/spec` for the concrete request/response schemas — the
   upstream file currently ships no endpoint map for this area.

Without that instance it is reference material only.

## Caution

Skills pulled from public repositories are third-party instructions. Review
anything this skill would install before trusting it, and keep credentials out
of any skill file committed here.
