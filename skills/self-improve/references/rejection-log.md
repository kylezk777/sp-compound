# Rejection Log

Differences evaluated and explicitly rejected during self-improve runs. Recorded here so future runs do not re-evaluate the same items unless context has materially changed.

## Format

```
### [YYYY-MM-DD] skill-name: feature-name

**Source:** SP / CE
**What upstream has:** [brief description]
**sp-compound approach:** [how sp-compound handles this, or why it's not needed]
**Rejection reason:** [one of: sp-compound approach is better / conflicts with design principle #N / cost exceeds benefit / cascade too broad]
**Re-evaluate if:** [condition under which this decision should be revisited]
```

## Entries

### [2026-04-12] compound: CE mode selection UX

**Source:** CE
**What upstream has:** 2-option mode selection prompt before starting
**sp-compound approach:** Auto-proceed-to-full mode, more streamlined
**Rejection reason:** sp-compound approach is better — more agent-first, less interactive friction
**Re-evaluate if:** User feedback indicates mode selection is needed

### [2026-04-12] compound: Session Historian agent

**Source:** CE
**What upstream has:** Agent 4 that reads ~/.claude/projects/ and ~/.codex/sessions/ for context
**sp-compound approach:** Auto memory scan (lighter equivalent)
**Rejection reason:** Framework-specific (reads platform-specific paths), high complexity. Conflicts with principle #3
**Re-evaluate if:** sp-compound adds multi-platform session support

### [2026-04-12] compound: Specialized review agents

**Source:** CE
**What upstream has:** Named reviewers (kieran-rails-reviewer, performance-oracle, etc.)
**sp-compound approach:** Generic reviewer set
**Rejection reason:** Framework-dependent. Conflicts with principle #3
**Re-evaluate if:** sp-compound adds a plugin system for custom reviewers

### [2026-04-12] compound: Overlap threshold 4-5 dimensions

**Source:** CE
**What upstream has:** Higher overlap threshold (4-5 dimensions) for knowledge dedup
**sp-compound approach:** 3+ threshold, intentionally more aggressive for knowledge flywheel
**Rejection reason:** sp-compound approach is better — supports principle #4 (knowledge flywheel)
**Re-evaluate if:** Users report too many false-positive overlaps

### [2026-04-12] compound: Schema design differences (problem_type, Rails enums, severity)

**Source:** CE
**What upstream has:** problem_type field, Rails-specific component enum, severity as required
**sp-compound approach:** Framework-agnostic schema with lifecycle fields (status, stale_reason)
**Rejection reason:** sp-compound approach is better — framework-agnostic with unique lifecycle tracking. Principles #3, #7
**Re-evaluate if:** Never — fundamental design choice

### [2026-04-12] work: Tiered code review (Tier 1/Tier 2)

**Source:** CE
**What upstream has:** Routing logic for review depth tiers
**sp-compound approach:** sp-compound:review handles review depth internally
**Rejection reason:** Redundant — would create two decision points for the same concern. Principle #1
**Re-evaluate if:** Review skill loses depth routing capability

### [2026-04-12] work: Figma design sync / Frontend design guidance

**Source:** CE
**What upstream has:** Domain-specific UI tooling integration
**sp-compound approach:** None needed — framework-agnostic
**Rejection reason:** Conflicts with principle #3
**Re-evaluate if:** Never — framework-specific

### [2026-04-12] work: Codex delegation workflow

**Source:** CE
**What upstream has:** Experimental beta feature with 100+ lines of delegation logic
**sp-compound approach:** Standard subagent dispatch
**Rejection reason:** Cost exceeds benefit — massive complexity for experimental feature. Principles #1, #3
**Re-evaluate if:** Codex delegation becomes stable and framework-agnostic

### [2026-04-12] plan: "Decisions not code" principle

**Source:** CE
**What upstream has:** Plans describe decisions, not code blocks
**sp-compound approach:** Plans include complete code blocks (SP heritage)
**Rejection reason:** Fundamental philosophical conflict. Code-forward plans are sp-compound's intentional differentiator. Principle #7
**Re-evaluate if:** Never — core design choice

### [2026-04-12] plan: Non-software domain routing

**Source:** CE
**What upstream has:** Universal planning for non-software domains
**sp-compound approach:** Software development discipline only
**Rejection reason:** Dilutes scope. sp-compound is an SDD plugin
**Re-evaluate if:** sp-compound expands scope beyond software development

### [2026-04-12] plan: Pipeline/headless mode

**Source:** CE
**What upstream has:** LFG/SLFG pipeline integration
**sp-compound approach:** No pipeline architecture
**Rejection reason:** Not architecturally relevant to sp-compound
**Re-evaluate if:** sp-compound adds pipeline/automation mode

### [2026-04-12] brainstorm: document-review skill dependency

**Source:** CE
**What upstream has:** Calls document-review skill in Phase 3.5
**sp-compound approach:** Inline self-review (expanded to 9 checks)
**Rejection reason:** Increases coupling, skill may not exist. sp-compound's 9-check self-review is adequate
**Re-evaluate if:** sp-compound adds a document-review skill

### [2026-04-12] brainstorm: Slack context integration

**Source:** CE
**What upstream has:** Reads Slack channels for context
**sp-compound approach:** None — framework-agnostic
**Rejection reason:** Conflicts with principle #3
**Re-evaluate if:** Never — external service dependency

### [2026-04-12] debug: condition-based-waiting-example.ts

**Source:** SP
**What upstream has:** TypeScript example file for Lace project
**sp-compound approach:** Generic pattern in condition-based-waiting.md
**Rejection reason:** Framework-specific. Principle #3. The .md already covers the pattern
**Re-evaluate if:** Never

### [2026-04-12] flexible-tdd: Graphviz flowchart

**Source:** SP
**What upstream has:** Dot graph visualization of TDD flow
**sp-compound approach:** Text-based steps
**Rejection reason:** Dot graphs not rendered by LLMs. Text steps are functionally equivalent and more token-efficient. Principle #1
**Re-evaluate if:** LLMs gain native graph rendering

### [2026-04-12] flexible-tdd: TypeScript examples

**Source:** SP
**What upstream has:** Language-specific Good/Bad code examples
**sp-compound approach:** Pseudocode in anti-patterns doc
**Rejection reason:** Framework-specific. Principle #3
**Re-evaluate if:** Never

### [2026-04-12] review: CE expanded reviewer roster (17 personas)

**Source:** CE
**What upstream has:** 17 named personas including stack-specific reviewers (DHH, Kieran, etc.)
**sp-compound approach:** 5+2 lean reviewer set
**Rejection reason:** CE-specific, tied to named humans and specific stacks (Rails, Stimulus/Turbo). Principles #1, #3
**Re-evaluate if:** sp-compound adds pluggable persona system

### [2026-04-12] review: Todo creation in autofix mode

**Source:** CE
**What upstream has:** Creates todo files during autofix
**sp-compound approach:** Knowledge flywheel (compound skill, solutions store)
**Rejection reason:** Would create parallel tracking system conflicting with knowledge flywheel. Principle #4
**Re-evaluate if:** Never — architectural conflict

### [2026-04-12] git-commit-push-pr: CE evidence capture (ce-demo-reel)

**Source:** CE
**What upstream has:** Full demo-reel evidence integration
**sp-compound approach:** None
**Rejection reason:** Depends on CE-specific skill not available in sp-compound
**Re-evaluate if:** sp-compound adds demo/evidence capture capability

### [2026-04-12] git-worktree: CE worktree-manager.sh script

**Source:** CE
**What upstream has:** 500-line bash script for worktree lifecycle
**sp-compound approach:** Scriptless design — agent handles operations inline
**Rejection reason:** sp-compound approach is better — simpler and more portable. Principle #1
**Re-evaluate if:** Never — deliberate simplicity choice

### [2026-04-12] reproduce-bug: Full fix phase (Phase 3)

**Source:** CE
**What upstream has:** Test-first fix with 3-attempt escalation in reproduce-bug
**sp-compound approach:** Delegates fixing to sp-compound:debug or sp-compound:work
**Rejection reason:** sp-compound approach is better — separation of concerns. Principle #2 (workflow chain coherence)
**Re-evaluate if:** Never — architectural choice

### [2026-04-12] writing-skills: anthropic-best-practices.md (1100+ lines)

**Source:** SP
**What upstream has:** Large reference file with Anthropic best practices
**sp-compound approach:** Key principles inlined in SKILL.md
**Rejection reason:** Cost exceeds benefit — 1100 lines of token cost. Principle #1
**Re-evaluate if:** sp-compound adds lazy reference file loading

### [2026-04-12] using-sp-compound: Multi-platform support (Copilot/Codex/Gemini)

**Source:** SP
**What upstream has:** Tool mappings for multiple AI platforms
**sp-compound approach:** Claude Code focused
**Rejection reason:** Out of scope. sp-compound is CC-focused by design
**Re-evaluate if:** sp-compound expands to multi-platform
