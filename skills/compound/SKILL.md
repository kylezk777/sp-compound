---
name: compound
description: Use after solving a notable problem to capture the learning into docs/solutions/ knowledge store. Documents the problem, root cause, solution, and prevention so future work benefits from the experience. Creates a compounding knowledge flywheel.
---

# Compound: Capture Learnings

## Overview

Capture solved problems into structured, searchable knowledge documents in `docs/solutions/`. Each documented solution compounds your team's knowledge — first-time research takes 30 minutes, documented lookups take 2 minutes.

**Announce at start:** "I'm using the sp-compound compound skill to capture this learning."

## Phase 0.5: Auto Memory Scan

Check the project's auto memory directory (if it exists) for relevant notes. Pass relevant entries as supplementary context to Phase 1 agents. Conversation history takes priority over memory notes.

## Phase 1: Parallel Research (3 agents)

Launch in parallel:

### Agent 1: Context Analyzer

Dispatch a subagent that:
1. Classifies the problem: **bug track** (specific problem/solution) or **knowledge track** (general guidance)
2. Reads `references/solution-schema.yaml` for valid field values
3. Generates YAML frontmatter (title, category, track, module, component, tags, resolution_type, related_files)
4. Reads `references/yaml-schema.md` to determine the target directory
5. Suggests filename: `docs/solutions/<category>/YYYY-MM-DD-<descriptive-slug>.md`

Returns: frontmatter YAML + suggested path. Does NOT write files.

### Agent 2: Solution Extractor

Dispatch a subagent that produces track-appropriate content:

**Bug track sections:**
- Problem: symptoms observed
- Root Cause: technical explanation
- Failed Attempts: what was tried that didn't work (optional)
- Solution: what fixed it with code snippets
- Prevention: how to prevent recurrence

**Knowledge track sections:**
- Context: when this guidance applies
- Guidance: the recommended approach
- Rationale: why this approach
- Applicability: when it does/doesn't apply
- Examples: code showing the approach (optional)

Returns: structured text content. Does NOT write files.

### Agent 3: Related Docs Finder

Dispatch a subagent that:
1. Searches `docs/solutions/` using grep-first strategy
2. Scores overlap across 5 dimensions:
   - Problem statement similarity
   - Root cause similarity
   - Solution approach similarity
   - Referenced files overlap
   - Prevention rules similarity
3. Classifies overlap: **high** (3+ dimensions match) / **moderate** (1-2 match) / **low** (0 match)
4. Optionally searches GitHub issues via `gh` if available

Returns: overlap assessment + matching doc paths. Does NOT write files.

**CRITICAL CONSTRAINT:** Phase 1 agents return TEXT DATA to the orchestrator. They must NOT use Write, Edit, or create any files.

## Phase 2: Assembly & Write

Collect all Phase 1 results. Check overlap score:

| Overlap | Action |
|---------|--------|
| **High** (3+ dimensions match) | Update the existing document with new information rather than creating a duplicate |
| **Moderate** (1-2 match) | Create new document, add a note flagging potential future consolidation |
| **Low/None** | Create new document normally |

Write the document to `docs/solutions/<category>/YYYY-MM-DD-<slug>.md` using the template from `references/resolution-template.md`.

### Creating docs/solutions/ Directory

If `docs/solutions/` doesn't exist yet:
1. Create the directory and the relevant category subdirectory
2. Create `docs/solutions/README.md` with a brief description of the knowledge store

## Phase 2.5: Selective Refresh Check

If the new learning CONTRADICTS or SUPERSEDES content in an existing document (detected by Related Docs Finder), conditionally invoke `sp-compound:compound-refresh` targeted at the specific document.

**Always capture the new learning first. Refresh is a follow-up.**

## Phase 3: Discoverability Check

Check whether project instruction files (AGENTS.md, CLAUDE.md) would lead agents to discover `docs/solutions/`.

### Assessment
An agent reading instruction files should learn:
1. That a searchable knowledge store exists
2. Enough about its structure to search effectively
3. When to search it (during planning and review)

This is a **semantic assessment**, not a string match.

### If Not Discoverable
1. Identify natural placement in the instruction file
2. Draft smallest addition matching file's style and tone
3. **Require user consent** before editing any instruction file
4. Keep tone informational, not imperative

## Output

Present the captured learning to the user:

```
Learning captured: docs/solutions/<category>/<filename>.md

Title: <title>
Track: <bug|knowledge>
Category: <category>
Tags: <tags>

Next steps:
1. Review the captured learning
2. Continue with other work
3. Run sp-compound:compound-refresh (if overlap detected)
```

## Integration

**Invoked by:**
- User manually after solving a notable problem
- Suggested by `sp-compound:work` at Phase 4 when a notable problem was solved

**May invoke:**
- `sp-compound:compound-refresh` (Phase 2.5) when new learning contradicts existing docs

**Consumed by:**
- `sp-compound:plan` — learnings-researcher reads docs/solutions/ during Phase 1
- `sp-compound:review` — learnings-researcher reads docs/solutions/ during Stage 3
- `sp-compound:brainstorm` — lightweight frontmatter grep during Phase 1

**Reference files (read on demand, not bulk-loaded):**
- `references/solution-schema.yaml` — frontmatter field definitions
- `references/yaml-schema.md` — category-to-directory mapping
- `references/resolution-template.md` — document section templates
