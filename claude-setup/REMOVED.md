# Removal log — 2026-09-22

Nine skills removed. 3,223 of 4,879 lines (66%).

| Skill | Lines | Why it went |
|---|---:|---|
| `humanizer` | 488 | Banned em dashes, boldface, and title-case headings — the exact things the profile requires and Dustin's own voice uses. Blocklist ("delve," "tapestry," "testament") targets 2023-era tells. Its scripted self-critique loop forced three drafts of everything. |
| `skill-creator` | 485 + scripts | A skill-authoring eval and benchmark harness. Dustin isn't running skill evals. |
| `marketing-psychology` | 455 | A 60-entry glossary of mental models and cognitive biases. Reference material, not instruction — and material the model already knows cold. |
| `ai-seo` | 398 | SaaS/startup answer-engine playbook. Recommends paid monitoring stacks against a "low-cost by default" rule, for a local advisory practice that doesn't compete on AI search. |
| `ad-creative` | 362 | Bulk RSA/Meta/TikTok variation generator. A supervised advisor can't run bulk creative tests without Osaic review, which is the actual bottleneck. |
| `content-strategy` | 359 | Pillar-and-cluster editorial planning for a blog that doesn't exist. |
| `email-sequence` | 309 | SaaS lifecycle drip design — onboarding, product usage, win-back. Dustin's email runs through Mailchimp and MyRepChat under compliance review. |
| `social-content` | 278 | Generic growth tactics ("reverse engineering viral content"). Overlaps copywriting and doesn't match the brand. |
| `import-memory` | 89 | One-time migration tool for importing another assistant's memory export. Already served its purpose. |

Also deleted: `humanizer/WARP.md` and `humanizer/README.md` — leftovers from the
Warp terminal harness, never read by Claude.

## Kept and rewritten
`copywriting` · `annual-review-consolidator` · `legacy-doc-review` ·
`midplains-weekly-dashboard`

## Kept untouched
`docx` `xlsx` `pptx` `pdf` — pure file-format capability, no opinions, no cost.
`docs` — Claude Docs connector stub, not user config.
`morning` — narrow trigger, only fires when explicitly invoked. Cut it if unused.

## Not touched — not yours
`stop-hook-git-check.sh` is working harness infrastructure.
`stop-hook-reply-gate.py` and `user-prompt-submit-reply-reminder.py` are
Anthropic Slack plumbing, env-gated off and not registered. They never run.
