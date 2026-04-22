---
name: compound
description: Use after solving a notable problem to capture the learning into .sp-compound/solutions/ knowledge store. Documents the problem, root cause, solution, and prevention so future work benefits from the experience. Creates a compounding knowledge flywheel.
---

# Compound: Capture Learnings

## Overview

Capture solved problems into structured, searchable knowledge documents in `.sp-compound/solutions/`. Each documented solution compounds your team's knowledge — first-time research takes 30 minutes, documented lookups take 2 minutes.

**Announce at start:** "I'm using the sp-compound compound skill to capture this learning."

## Preconditions (advisory)

Before proceeding, verify:
- Problem has been solved (not in-progress)
- Solution has been verified working
- Non-trivial problem (not a simple typo or obvious error)

If any precondition is not met, note the gap and ask whether to proceed anyway.

## Execution Strategy

**Full mode is the default.** Proceed directly to Phase 0.5 unless the user explicitly requests compact-safe mode (e.g., `--compact` or "use compact mode").

### Compact-Safe Mode

Single-pass fallback for context-constrained sessions. Skips parallel subagents entirely.

The orchestrator performs ALL work in one sequential pass:
1. **Extract** from conversation: identify problem and solution. Check auto memory if available.
2. **Classify**: read `references/solution-schema.yaml` and `references/yaml-schema.md`, determine track and category
3. **Write minimal doc**: create `.sp-compound/solutions/<category>/YYYY-MM-DD-<slug>.md` using the appropriate track template from `references/resolution-template.md`
4. **Skip** overlap check and Phase 3 discoverability (suggest running `sp-compound:compound-refresh` later)

Output:
```
Learning captured (compact-safe mode): .sp-compound/solutions/<category>/<filename>.md

Note: Created in compact-safe mode. For richer documentation (cross-references,
overlap detection), re-run compound in a fresh session.
```

### Auto Mode

Invocation: `sp-compound:compound mode:auto` — designed for skill-to-skill calls (e.g., from `sp-compound:finishing-branch`). Never blocks, never prompts, never prints multi-line summaries or menus.

Behavior:
1. **Runs** Phase 0.5 (auto memory scan) and Phase 1 (3 parallel research agents).
2. **Runs** Phase 2 assembly with the full overlap matrix — including update-over-create when high overlap is detected.
3. **Skips** Phase 2.5 (no `compound-refresh` suggestion).
4. **Skips** Phase 3 (no discoverability instruction-file editing).
5. **Does not print** the "What's next?" menu or any blocking question.

**Pre-snapshot for rollback** (applies only on update case): before overwriting an existing doc, read and return its current contents as `pre_state` in the invocation result alongside the target path. The calling skill is responsible for retaining this snapshot for the rollback window.

Output contract — exactly **one** line to stdout:

```
✓ Captured: <repo-relative-path>
```

If overlap was high and an existing doc was updated, still use `✓ Captured:`; the caller owns "new vs update" semantics via the optional `pre_state` payload it received.

Error contract — if classification fails (no clean category/track assignment), no write happens. Instead emit exactly one line and return:

```
✓ Auto-capture skipped: <short reason>
```

Callers must treat this as non-fatal and continue their own flow.

Auto Mode MUST NOT be used when `$ARGUMENTS` also contains `mode:compact` — mode tokens are mutually exclusive; reject with an error line explaining which modes conflict.

---

## Phase 0.5: Auto Memory Scan

1. Read MEMORY.md from the auto memory directory (path is in system prompt context)
2. If the directory or MEMORY.md does not exist, is empty, or is unreadable — skip and proceed to Phase 1
3. Scan entries for anything related to the problem being documented (semantic judgment, not keyword matching)
4. If relevant entries found, pass them as a labeled block to Phase 1 agent prompts:
   ```
   ## Supplementary notes from auto memory
   Treat as additional context, not primary evidence.
   Conversation history and codebase findings take priority.
   [relevant entries]
   ```
5. If any memory notes end up in the final document, tag them with "(auto memory)" so their origin is clear to future readers

## Phase 1: Parallel Research (3 agents)

Launch in parallel:

### Agent 1: Context Analyzer

Dispatch a subagent that:
1. Classifies the problem: **bug track** (specific problem/solution) or **knowledge track** (general guidance)
2. Reads `references/solution-schema.yaml` for valid field values
3. Generates YAML frontmatter (title, category, track, module, component, tags, resolution_type, related_files)
4. Reads `references/yaml-schema.md` to determine the target directory
5. Suggests filename: `.sp-compound/solutions/<category>/YYYY-MM-DD-<descriptive-slug>.md`

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
1. Searches `.sp-compound/solutions/` using grep-first strategy:
   - Extract keywords from problem context (module names, technical terms, error messages)
   - If category is clear, narrow search to `.sp-compound/solutions/<category>/`
   - Use native content-search tool (e.g., Grep) to pre-filter candidates before reading: search frontmatter fields (`title:`, `tags:`, `module:`, `component:`) in parallel, case-insensitive
   - If >25 candidates: re-run with more specific patterns. If <3: broaden to full content search
   - Read only frontmatter (first 30 lines) to score relevance; fully read only strong/moderate matches
2. Scores overlap across 5 dimensions:
   - Problem statement similarity
   - Root cause similarity
   - Solution approach similarity
   - Referenced files overlap
   - Prevention rules similarity
3. Classifies overlap: **high** (3+ dimensions match) / **moderate** (1-2 match) / **low** (0 match)
4. Searches GitHub issues: prefer `gh issue list --search "<keywords>" --state all --limit 5`. If `gh` is not installed, fall back to GitHub MCP tools if available. If neither is available, skip and note it was skipped.

Returns: overlap assessment + matching doc paths. Does NOT write files.

**CRITICAL CONSTRAINT:** Phase 1 agents return TEXT DATA to the orchestrator. They must NOT use Write, Edit, or create any files.

## Phase 2: Assembly & Write

Collect all Phase 1 results. Check overlap score:

| Overlap | Action |
|---------|--------|
| **High** (3+ dimensions match) | Update the existing document rather than creating a duplicate. Preserve its file path and frontmatter structure. Update solution, code examples, prevention tips, and stale references. Add `last_updated: YYYY-MM-DD`. Do not change the title unless the problem framing materially shifted. |
| **Moderate** (1-2 match) | Create new document, add a note flagging potential future consolidation |
| **Low/None** | Create new document normally |

Write the document to `.sp-compound/solutions/<category>/YYYY-MM-DD-<slug>.md` using the template from `references/resolution-template.md`.

### Creating .sp-compound/solutions/ Directory

If `.sp-compound/solutions/` doesn't exist yet:
1. Create the directory and the relevant category subdirectory
2. Create `.sp-compound/solutions/README.md` with a brief description of the knowledge store

## Phase 2.5: Selective Refresh Check

**Always capture the new learning first. Refresh is a follow-up.**

Invoke `sp-compound:compound-refresh` selectively when the new learning suggests older docs may now be inaccurate:

**When to invoke:**
- A related doc recommends an approach the new fix now contradicts
- The new fix clearly supersedes an older documented solution
- The work involved a refactor, migration, or dependency upgrade that likely invalidated older references
- Related Docs Finder reported moderate overlap suggesting consolidation opportunities

**When NOT to invoke:**
- No related docs found
- Related docs still appear consistent with the new learning
- Overlap is superficial and doesn't change prior guidance

**Scope hints** — always pass the narrowest useful scope:
- Specific file when one doc is the likely stale artifact
- Module/component name when several related docs may need review
- Category name when drift is concentrated in one area

Examples: `sp-compound:compound-refresh auth-middleware`, `sp-compound:compound-refresh performance-issues`

Do not invoke without an argument unless the user explicitly wants a broad sweep. If context is already tight (compact-safe mode), recommend refresh as the next step rather than running it.

## Phase 3: Discoverability Check

Read and follow `references/discoverability-check.md`. Verify that project instruction files would lead agents to discover `.sp-compound/solutions/`.

## Common Mistakes

| Wrong | Correct |
|-------|---------|
| Subagents write files | Subagents return text data; orchestrator writes one final file |
| Research and assembly run in parallel | Phase 1 completes -> then Phase 2 assembly runs |
| Multiple files created during workflow | One solution doc written or updated (plus optional instruction-file edit for discoverability) |
| Creating a new doc when existing doc covers the same problem | Check overlap assessment; update existing doc when overlap is high |
| Auto Mode prints the "What's next?" menu or a multi-line summary | Auto Mode emits exactly one line; any multi-line output means the mode dispatch leaked into Full-mode output |

## Output

Present the captured learning to the user:

```
Learning captured: .sp-compound/solutions/<category>/<filename>.md

Title: <title>
Track: <bug|knowledge>
Category: <category>
Tags: <tags>

What's next?
1. Continue with other work (recommended)
2. Review the captured learning
3. Run sp-compound:compound-refresh (if overlap detected)
```

After displaying the output, present the "What's next?" options using the platform's blocking question tool (`AskUserQuestion` in Claude Code, `request_user_input` in Codex, `ask_user` in Gemini). If no question tool is available, present the numbered options and wait for the user's reply. Do not end the turn without the user's selection.

## Integration

**Invoked by:**
- User manually after solving a notable problem
- Suggested by `sp-compound:work` at Phase 4 when a notable problem was solved
- `sp-compound:finishing-branch` (Step 4.5) — via `mode:auto`, when user ships Option 1/2 and the notable-learning gate passes

**May invoke:**
- `sp-compound:compound-refresh` (Phase 2.5) when new learning contradicts existing docs

**Consumed by:**
- `sp-compound:plan` — learnings-researcher reads .sp-compound/solutions/ during Phase 1
- `sp-compound:review` — learnings-researcher reads .sp-compound/solutions/ during Stage 3
- `sp-compound:brainstorm` — lightweight frontmatter grep during Phase 1

**Reference files (read on demand, not bulk-loaded):**
- `references/solution-schema.yaml` — frontmatter field definitions and track classification
- `references/yaml-schema.md` — category-to-directory mapping
- `references/resolution-template.md` — document section templates
- `references/discoverability-check.md` — instruction file verification
