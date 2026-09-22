# Claude setup — source of truth

The live copies live in Dustin's claude.ai account and sync down to
`~/.claude/skills/synced/` at session start. **That directory is overwritten
every session — editing it changes nothing.** This repo is where the real
versions live.

## Applying a change

**Profile** — `PROFILE.md` → claude.ai → Settings → Personal preferences.
Replace the whole thing.

**Skills** — claude.ai → Settings → Capabilities → Skills.
Delete the nine in `REMOVED.md`. For the four in `skills/`, replace the body
of each existing skill with the version here (keeps the skill ID and its
history).

## Design rule for anything added later

State the outcome. State the hard boundaries. State what good looks like.
Stop there.

Don't write the method — the model reasons on its own, and a prescribed
procedure only narrows what it can do. The one exception is a deterministic
operational job where the steps *are* the knowledge: `midplains-weekly-dashboard`
is detailed on purpose, because the column mappings, proration formulas, and
validation gates aren't inferable from anywhere.

## Known gap

There's no brand file. Nothing stores LRP/Signature colors, fonts, taglines,
approved CTA language, Osaic disclosure blocks, or client personas — which is
why every marketing skill used to open by interrogating Dustin. One brand
context file would answer those questions permanently.
