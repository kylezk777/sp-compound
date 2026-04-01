# Discoverability Check

Verify that project instruction files would lead agents to discover `docs/solutions/`.

## When to Run

Every time after writing or refreshing a knowledge store document.

## Assessment

An agent reading project instruction files should learn:

1. **That a searchable knowledge store exists** — `docs/solutions/` is mentioned
2. **Enough about its structure to search effectively** — frontmatter fields, category directories
3. **When to search it** — during planning and review, or when encountering a known problem domain

This is a **semantic assessment**, not a string match. If the instruction files already convey these three points (even in different words), no change is needed.

## Target Files

Check in priority order:
1. `AGENTS.md` (if exists — preferred location for agent-facing guidance)
2. `CLAUDE.md` (fallback)

**Target the substantive instruction file.** If `CLAUDE.md` is a shim that includes `AGENTS.md`, edit `AGENTS.md`, not `CLAUDE.md`.

## If Not Discoverable

1. Identify natural placement in the instruction file (near related guidance, not at bottom)
2. Draft the smallest effective addition matching the file's existing density and tone
3. **Require user consent** before editing any instruction file — never edit without asking
4. Keep tone informational, not imperative

## Example Addition

```markdown
## Knowledge Store

Project learnings are stored in `docs/solutions/` with YAML frontmatter (module, component, tags).
Search it during planning and review for historical experience with the target modules.
```

This is a minimal example. Adapt length and detail to match the file's existing style.
