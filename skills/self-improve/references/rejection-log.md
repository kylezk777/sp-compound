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

### [2026-04-22] work: Frontend design guidance (ce-work-beta)

**Source:** CE (ce-work-beta)
**What upstream has:** `ce-frontend-design` skill invocation for UI tasks without Figma
**sp-compound approach:** None — framework-agnostic, no UI domain skill
**Rejection reason:** Framework-specific, beta-only feature. Conflicts with principle #3
**Re-evaluate if:** Never — framework-specific

### [2026-04-22] work: Residual Work Gate (Tier 2 follow-up)

**Source:** CE
**What upstream has:** Blocking prompt after review with Apply/File tickets/Accept/Stop options
**sp-compound approach:** `sp-compound:review` handles the autofix/report loop internally
**Rejection reason:** Redundant with sp-compound:review. Adding a gate in work creates two decision points for the same concern. Principle #1
**Re-evaluate if:** sp-compound:review loses interactive resolution flow

### [2026-04-22] work: Tracker-defer / ticket filing fallback chain

**Source:** CE (references/tracker-defer.md)
**What upstream has:** Linear/GitHub Issues/Jira fallback detection for filing deferred findings
**sp-compound approach:** Knowledge flywheel (.sp-compound/solutions/) + PR "Known Residuals"
**Rejection reason:** Parallel tracking system would conflict with knowledge flywheel. Principle #4. Also depends on CE-specific tracker probing
**Re-evaluate if:** sp-compound adds first-class tracker integration

### [2026-04-22] work: U-ID / R-ID traceability preservation in task subjects

**Source:** CE
**What upstream has:** Preserve plan's U-IDs as task subject prefix (e.g., "U3: Add parser coverage")
**sp-compound approach:** sp-compound:plan does not emit U-IDs
**Rejection reason:** Upstream plan schema not adopted. Porting the work-side convention without plan-side IDs would create dangling references. Principle #2
**Re-evaluate if:** sp-compound:plan adopts U-ID emission

### [2026-04-22] work: SP "final code reviewer for entire implementation" after all tasks

**Source:** SP (subagent-driven-development)
**What upstream has:** Dispatch a final full-codebase code reviewer subagent after all tasks done
**sp-compound approach:** Phase 3 invokes `sp-compound:review` (multi-reviewer) and `sp-compound:verification`
**Rejection reason:** Equivalent and better — review skill is richer than a single subagent. Principle #1
**Re-evaluate if:** Never — architectural choice

### [2026-04-22] work: "Assess testing coverage" per-task reflection step

**Source:** CE
**What upstream has:** Per-task reflection: did behavior change? were tests added? if not, why?
**sp-compound approach:** Test Discovery (4-category table) + System-Wide Test Check + Phase 3 verification cover this
**Rejection reason:** Equivalent coverage. Adding another reflection point increases prose without changing decisions. Principle #1
**Re-evaluate if:** Never — equivalent

### [2026-04-22] work: Tiered review routing (Tier 1/Tier 2) re-evaluation

**Source:** CE (ce-work shipping-workflow)
**What upstream has:** Explicit Tier 1 (inline self-review) vs Tier 2 (full review) routing with 4-criteria gate
**sp-compound approach:** Always invoke sp-compound:review (which handles depth internally)
**Rejection reason:** Re-confirmed — already rejected 2026-04-12. CE's Tier system is a decision-point duplication. Principle #1
**Re-evaluate if:** sp-compound:review loses internal depth routing

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

### [2026-04-22] plan: High-Level Technical Design section (pseudo-code / mermaid)

**Source:** CE
**What upstream has:** Optional H2 section with pseudo-code grammar, sequence diagrams, state diagrams, framed as directional guidance
**sp-compound approach:** SP-format tasks with complete code blocks communicate design shape directly
**Rejection reason:** Conflicts with code-forward differentiator. Directional pseudo-code would dilute the "show the real code" contract SP heritage gives sp-compound. Principle #7
**Re-evaluate if:** sp-compound moves away from code-forward plans

### [2026-04-22] plan: Visual Communication reference (mermaid dependency graphs)

**Source:** CE (references/visual-communication.md)
**What upstream has:** Guidance for mermaid/ASCII dependency graphs, interaction diagrams, comparison tables inside plan documents
**sp-compound approach:** Phased Deep planning already expresses cross-unit structure through Module Map + Interface Contracts + Execution Order + batches
**Rejection reason:** Functional overlap; adding a reference file costs context for marginal benefit. Principles #1, #6
**Re-evaluate if:** Phased planning proves inadequate for visualizing complex multi-unit plans

### [2026-04-22] plan: System-Wide Impact as template section

**Source:** CE
**What upstream has:** Dedicated H2 template section with interaction graph, error propagation, state lifecycle, API parity, integration coverage, unchanged invariants
**sp-compound approach:** Deepening workflow triggers strengthening in this area; code-forward tasks expose system edges through actual code
**Rejection reason:** Adding a template section encourages boilerplate padding; deepening already handles it on the weak cases. Principle #1
**Re-evaluate if:** Reviewers report blast-radius blind spots not caught by deepening

### [2026-04-22] plan: Origin A/F/AE ID carry-through

**Source:** CE
**What upstream has:** Actors / Key Flows / Acceptance Example IDs carried from brainstorm doc to plan, with stability rules
**sp-compound approach:** Requirements trace (R-IDs) only; brainstorm does not emit A/F/AE IDs
**Rejection reason:** Requires brainstorm changes — cascade too broad. Principle #2
**Re-evaluate if:** sp-compound:brainstorm adds A/F/AE IDs

### [2026-04-22] plan: "Honor user-named resources" core principle

**Source:** CE (Core Principle #8)
**What upstream has:** Explicit principle telling the agent to treat user-named tools/URLs/MCPs as authoritative and not silently substitute
**sp-compound approach:** Agent-first tables and rules; good agent behavior is implicit
**Rejection reason:** Verbose prose; conciseness. Principle #1
**Re-evaluate if:** Users report silent substitution bugs

### [2026-04-22] plan: ToolSearch fallback for AskUserQuestion

**Source:** CE
**What upstream has:** Detailed instructions to call ToolSearch with select:AskUserQuestion if schema isn't loaded, fallback to numbered options only on tool error
**sp-compound approach:** Simple "use AskUserQuestion when available, otherwise numbered options"
**Rejection reason:** Platform-specific verbosity; sp-compound is Claude Code focused and AskUserQuestion just works. Principle #1
**Re-evaluate if:** Claude Code schema loading becomes a common failure mode

### [2026-04-22] plan: Three-way Scope Boundaries split

**Source:** CE
**What upstream has:** Origin-triggered three-way split — Deferred for later / Outside this product's identity / Deferred to Follow-Up Work
**sp-compound approach:** Simpler `Deferred to Separate Tasks` subsection under Scope Boundaries
**Rejection reason:** CE's split is coupled to its brainstorm depth tiers (Deep-product detection); sp-compound brainstorm does not emit those markers. Principle #2
**Re-evaluate if:** sp-compound:brainstorm adopts CE's depth tiers

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

### [2026-04-22] brainstorm: CE Proof editor integration in handoff

**Source:** CE
**What upstream has:** "Open in Proof — review and comment to iterate with the agent" handoff option, ce-proof skill dispatch, HITL review, stale-local-pull warnings
**sp-compound approach:** Handoff offers plan/work/ask-more/done only; no external editor integration
**Rejection reason:** External service dependency (Every's Proof). Conflicts with principle #3
**Re-evaluate if:** Never — external service

### [2026-04-22] brainstorm: AskUserQuestion ToolSearch schema-load guidance

**Source:** CE
**What upstream has:** Micro-instructions to call `ToolSearch` with `select:AskUserQuestion` first if schema isn't loaded; Codex/Gemini tool name mappings
**sp-compound approach:** Plain "Use the platform's question tool when available"
**Rejection reason:** CC-focused per existing using-sp-compound decision; platform-specific micro-instructions add clutter without value. Principle #1
**Re-evaluate if:** sp-compound expands to multi-platform

### [2026-04-22] brainstorm: SP multi-platform server launch (visual-companion + start-server.sh)

**Source:** SP
**What upstream has:** Detailed platform-specific launch blocks for Claude Code macOS/Linux, Claude Code Windows (run_in_background), Codex (CODEX_CI auto-foreground), Gemini (--foreground + is_background)
**sp-compound approach:** Single Claude Code launch example; Windows OSTYPE auto-foreground retained
**Rejection reason:** sp-compound is CC-focused by design (parallel to using-sp-compound decision). Principle #3
**Re-evaluate if:** sp-compound expands to multi-platform

### [2026-04-22] brainstorm: SP Graphviz dot process-flow diagram

**Source:** SP
**What upstream has:** `dot` graph in SKILL.md showing the brainstorming flow
**sp-compound approach:** Checklist in prose, phases described in sections
**Rejection reason:** Dot graphs not rendered by LLM consumers; text steps functionally equivalent and token-efficient. Parallel to flexible-tdd Graphviz rejection. Principle #1
**Re-evaluate if:** LLMs gain native graph rendering

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

### [2026-04-22] review: Stage 5b independent validator sub-agent pass

**Source:** CE
**What upstream has:** Post-merge per-finding validator sub-agent (parallel dispatch, 15-cap) that re-verifies each finding before externalization; runs in autofix/headless/externalizing modes
**sp-compound approach:** Cross-reviewer boost (+0.10 when 2+ reviewers agree) plus confidence gate (<0.60 suppress, P0 at 0.50+) as multi-signal suppression of false positives
**Rejection reason:** Cost exceeds benefit — adds N+1 sub-agent dispatches per review plus a new validator template and merge stage. sp-compound's 5-reviewer lean set already gets corroboration from cross-reviewer boost; a second wave isn't justified without evidence of persistent false positives. Principle #1
**Re-evaluate if:** Field data shows false-positive rate above acceptable threshold

### [2026-04-22] review: Anchored confidence scale {0,25,50,75,100}

**Source:** CE
**What upstream has:** Integer confidence anchors with per-value behavioral criteria; prevents false precision at 0.73 vs 0.81
**sp-compound approach:** Float 0.0-1.0 with band semantics (0.85+ certain, 0.70-0.84 high, 0.60-0.69 moderate, <0.60 suppressed, <0.30 don't report)
**Rejection reason:** Cascade too broad — changing anchors touches findings-schema.md, merge-pipeline.md, review-output-template.md, and every reviewer agent. sp-compound's bands already provide coarse anchoring; no evidence of miscalibration. Principle #1
**Re-evaluate if:** Reviewers demonstrably clustering at meaningless precision

### [2026-04-22] review: Per-finding walk-through, bulk preview, tracker-defer

**Source:** CE
**What upstream has:** Interactive-mode option A (review each finding one-by-one: Apply/Defer/Skip/LFG), bulk preview before batch actions, Linear/GitHub Issues ticket filing
**sp-compound approach:** Single Stage-6 policy question after safe_auto applied; residual work handed off as report rows
**Rejection reason:** Massive complexity (3 large reference files, ToolSearch preload protocol, tie-break rules, tracker detection tuple) for UX polish. tracker-defer is the same "todo creation" pattern already rejected — parallel tracking surface would compete with knowledge flywheel. Principles #1, #4
**Re-evaluate if:** sp-compound adopts external tracker integration as a first-class concern

### [2026-04-22] review: Detail-tier / merge-tier field split with per-agent artifact files

**Source:** CE
**What upstream has:** Compact JSON to orchestrator (merge fields only) + full JSON artifact per reviewer on disk; re-read during headless enrichment
**sp-compound approach:** Single compact JSON with all fields (why_it_matters, evidence) returned directly
**Rejection reason:** Cost exceeds benefit. Split exists because CE dispatches 6+ always-on reviewers; sp-compound's lean 5-reviewer set has no context-bloat problem. Adds disk I/O failure modes (write fail, no-match fallback) without measurable savings. Principles #1, #7
**Re-evaluate if:** sp-compound reviewer count grows enough that compact payloads become prohibitive

### [2026-04-22] review: Mode-aware demotion of weak general-quality findings

**Source:** CE
**What upstream has:** Rule to reroute P2/P3 advisory findings produced solely by testing or maintainability reviewers to soft buckets (testing_gaps / residual_risks)
**sp-compound approach:** Confidence gate + cross-reviewer boost handle low-signal findings; soft buckets populated via reviewer-provided residual_risks/testing_gaps arrays only
**Rejection reason:** Narrow applicability — sp-compound has no maintainability reviewer, so the rule reduces to a testing-only special case. Marginal benefit; increases merge-pipeline complexity. Principle #1
**Re-evaluate if:** sp-compound adds maintainability reviewer and signal-to-noise becomes a problem

### [2026-04-22] review: Trivial-PR judgment sub-agent in skip pre-check

**Source:** CE
**What upstream has:** Haiku-tier sub-agent judges whether a PR is trivial (lock-file bumps, automated releases) and skips review
**sp-compound approach:** Adopted closed/merged state check only; trivial-PR judgment not adopted
**Rejection reason:** Extra sub-agent dispatch on every PR review for modest convenience. CE's own false-negative bias means borderline PRs get reviewed anyway, reducing savings. Principle #1
**Re-evaluate if:** Users report frequent wasted reviews on automated PRs

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

### [2026-04-22] reproduce-bug: CE consolidation into ce-debug

**Source:** CE
**What upstream has:** CE removed the standalone reproduce-bug skill and merged reproduction+investigation+fix into ce-debug (now handles GitHub/Linear/Jira issue intake too)
**sp-compound approach:** Keeps reproduce-bug and debug as separate skills (reproduce-bug for external issues, debug for bugs encountered during development)
**Rejection reason:** Merging would reopen the already-rejected full-fix-phase question. Separate skill provides clearer routing. Principles #2, #7
**Re-evaluate if:** User feedback shows confusion between the two skills

### [2026-04-22] reproduce-bug: Detailed prediction-quality examples (bad vs good)

**Source:** CE (ce-debug/references/anti-patterns.md)
**What upstream has:** "Bad prediction (restates hypothesis)" vs "Good prediction (tests non-obvious)" worked examples with rule-of-thumb
**sp-compound approach:** reproduce-bug delegates deep hypothesis/prediction work to sp-compound:debug; only states the prediction core principle
**Rejection reason:** Belongs in sp-compound:debug, not reproduce-bug. Duplicating here violates separation of concerns and principle #1
**Re-evaluate if:** sp-compound:debug loses prediction guidance

### [2026-04-22] reproduce-bug: Framework-specific investigation sections

**Source:** CE (investigation-techniques.md — Rails, Node.js, Python sections)
**What upstream has:** Per-framework debugging techniques (Rails callbacks, Node async-stack-traces, Python pdb)
**sp-compound approach:** Framework-agnostic only
**Rejection reason:** Conflicts with principle #3
**Re-evaluate if:** Never — framework-specific

### [2026-04-22] reproduce-bug: Brainstorm routing for design-level bugs

**Source:** CE (ce-debug Phase 2 "When to suggest brainstorm")
**What upstream has:** Explicit signals (wrong responsibility, wrong requirements, every fix is a workaround) to route from debug to brainstorm
**sp-compound approach:** reproduce-bug ends at findings + handoff; design escalation belongs in sp-compound:debug which owns design-level investigation
**Rejection reason:** Belongs in sp-compound:debug. reproduce-bug is intake + reproduction only. Principles #1, #2
**Re-evaluate if:** sp-compound:debug loses design-escalation guidance

### [2026-04-22] reproduce-bug: Workspace safety check (git status pre-edit)

**Source:** CE (ce-debug Phase 3)
**What upstream has:** Check uncommitted changes before editing files in the fix phase
**sp-compound approach:** Not applicable — reproduce-bug does not edit code; fix path delegated to debug/work which own workspace safety
**Rejection reason:** Out of scope — reproduce-bug has no fix phase
**Re-evaluate if:** Never — architectural

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

### [2026-04-22] using-sp-compound: GEMINI.md in Instruction Priority list

**Source:** SP
**What upstream has:** Lists GEMINI.md alongside CLAUDE.md/AGENTS.md as user-instruction source
**sp-compound approach:** CLAUDE.md + AGENTS.md only
**Rejection reason:** Multi-platform content. Conflicts with CC-focus decision (see 2026-04-12 entry)
**Re-evaluate if:** sp-compound expands to multi-platform

### [2026-04-22] using-sp-compound: Platform Adaptation section / references to copilot-tools / codex-tools / gemini-tools

**Source:** SP
**What upstream has:** Dedicated section pointing at per-platform tool-mapping reference files
**sp-compound approach:** None — CC-only, no references/ directory needed
**Rejection reason:** Multi-platform content. Already covered by 2026-04-12 rejection
**Re-evaluate if:** sp-compound expands to multi-platform

### [2026-04-22] using-sp-compound: Cosmetic differences ("≠" vs "is not", em-dash style)

**Source:** SP
**What upstream has:** Uses Unicode "≠" in red-flag table, slightly different dash usage
**sp-compound approach:** Plain "is not", consistent em-dashes
**Rejection reason:** Cosmetic only, no agent behavior impact. Principle #1
**Re-evaluate if:** Never

### [2026-04-22] debug: CREATION-LOG.md and test-pressure-*.md artifacts

**Source:** SP
**What upstream has:** CREATION-LOG.md (skill authoring history) and test-academic.md / test-pressure-1/2/3.md (skill pressure-test scenarios)
**sp-compound approach:** Not present; sp-compound skills don't ship meta/development artifacts
**Rejection reason:** These files are not operational agent instructions — they document how the SP skill was authored and tested. Adding them consumes context with no agent-behavior change. Principle #1
**Re-evaluate if:** sp-compound adopts a skill-authoring history convention

### [2026-04-22] debug: SP's simpler Phase 4.5 (Question Architecture only)

**Source:** SP
**What upstream has:** Step 5 under Phase 4 with just "question fundamentals" prose after 3+ failed fixes
**sp-compound approach:** Expanded Step 5 into competing-hypotheses framework with Step A (generate 2+ hypotheses across Code-path / Environment / Assumption lanes), Step B (identify discriminating probe), Step C (run probe before Fix #4), Step D (architectural escalation)
**Rejection reason:** sp-compound approach is strictly better — gives the agent a concrete next action instead of an open-ended reflection prompt. Principles #5, #7
**Re-evaluate if:** Never — deliberate sp-compound improvement

### [2026-04-22] verification: "From 24 failure memories" specific count

**Source:** SP
**What upstream has:** "From 24 failure memories:" as evidence preamble
**sp-compound approach:** "From real failure patterns:" (generic)
**Rejection reason:** Specific count is tied to SP's private history and goes stale. Generic phrasing is truthful and maintenance-free. Principle #1
**Re-evaluate if:** Never

### [2026-04-22] flexible-tdd: SP "Why Order Matters" expanded prose

**Source:** SP
**What upstream has:** ~60 lines of prose expanding on "tests after", "manually tested", "sunk cost", "TDD is dogmatic", "spirit not ritual" with detailed reasoning per excuse
**sp-compound approach:** Same content compressed into the Common Rationalizations table under Strategy 1 (one-row-per-excuse)
**Rejection reason:** Table form is more agent-friendly and ~5x shorter. No behavior change lost. Principles #1, #5
**Re-evaluate if:** Never

### [2026-04-22] flexible-tdd: SP "Example: Bug Fix" TypeScript walkthrough

**Source:** SP
**What upstream has:** Full TypeScript Red-Green-Refactor example for an empty-email bug fix
**sp-compound approach:** None — Strategy 1 describes the cycle abstractly
**Rejection reason:** Framework-specific TypeScript example. Principle #3 (already-rejected category for flexible-tdd)
**Re-evaluate if:** Never

### [2026-04-22] flexible-tdd: SP Good/Bad TypeScript examples in RED/GREEN subsections

**Source:** SP
**What upstream has:** `<Good>`/`<Bad>` TypeScript code blocks (retryOperation with jest mocks) inside RED-Green-Refactor cycle sections
**sp-compound approach:** Prose description of each phase, no code
**Rejection reason:** Framework-specific TypeScript + jest. Principle #3
**Re-evaluate if:** Never

### [2026-04-22] receiving-review: CE full workflow automation (ce-resolve-pr-feedback)

**Source:** CE
**What upstream has:** Full PR resolution workflow — GraphQL scripts (get-pr-comments, reply-to-pr-thread, resolve-pr-thread), parallel agent dispatch, cross-invocation cluster analysis, targeted vs full mode, triage/actionability silent-drop, iteration limit
**sp-compound approach:** receiving-review is a behavioral/mindset skill (how to mentally receive feedback). sp-compound has no parallel automation skill.
**Rejection reason:** Different scope — would require a separate skill. Scripts conflict with scriptless design principle #1. Cross-invocation analysis is heavy for uncertain ROI
**Re-evaluate if:** User demand emerges for a dedicated PR-resolution automation skill; could become sp-compound:resolve-pr

### [2026-04-22] receiving-review: "Strange things are afoot at the Circle K" signal phrase

**Source:** SP
**What upstream has:** Code phrase for signaling discomfort with pushback
**sp-compound approach:** None — direct technical reasoning
**Rejection reason:** User-specific idiom (Jesse's phrase). Conflicts with principle #3 (framework-agnostic) and #5 (agent-first)
**Re-evaluate if:** Never — personal convention

### [2026-04-22] git-worktree: Branch-aware direnv trust with per-branch-class rules

**Source:** CE (ce-worktree)
**What upstream has:** Full trust matrix — trusted base branches (main/develop/dev/trunk/staging/release/*) vs other branches, with `direnv allow` skipped for feature/review branches regardless of diff
**sp-compound approach:** Simpler rule ("only auto-trust unchanged from base") + single-line caveat for PR-review worktrees
**Rejection reason:** Full matrix adds subtle conditional logic for narrow security benefit. sp-compound's simpler rule + review-branch caveat covers the critical case. Principle #1
**Re-evaluate if:** Users report real incidents from direnv auto-trust in review worktrees

### [2026-04-22] git-worktree: worktree-manager.sh script (re-confirmed)

**Source:** CE
**What upstream has:** 500-line bash script for worktree lifecycle
**sp-compound approach:** Scriptless — agent handles operations inline
**Rejection reason:** Already rejected 2026-04-12; re-confirmed in this run. Principle #1
**Re-evaluate if:** Never

### [2026-04-22] finishing-branch: SP's "For Options 1, 2, 4" cleanup instruction

**Source:** SP
**What upstream has:** Cleanup step text says cleanup for Options 1, 2, 4 — but its own table shows Option 2 keeps worktree
**sp-compound approach:** Corrected to "For Options 1 and 4" (matches table)
**Rejection reason:** sp-compound approach is better — SP has an internal inconsistency that sp-compound already fixed
**Re-evaluate if:** Never — bug fix

### [2026-04-22] git-commit-push-pr: Two-skill extraction (ce-pr-description)

**Source:** CE
**What upstream has:** Extracts PR description generation into separate `ce-pr-description` skill; delegates via `{title, body_file}` temp-file handoff
**sp-compound approach:** Monolithic single-skill design
**Rejection reason:** sp-compound has no second caller (no ce-pr-stack equivalent); extraction would double file count with no reuse benefit. Principles #1, #2
**Re-evaluate if:** sp-compound adds a stacked-PR workflow needing shared description logic

### [2026-04-22] git-commit-push-pr: Pre-populated bash context (`!` prefix)

**Source:** CE
**What upstream has:** CC-native `!` prefix on bash blocks so git status/diff/log pre-populate at skill load
**sp-compound approach:** Runs context commands inline via Bash tool
**Rejection reason:** No other sp-compound skill uses this pattern. Adopting in one skill breaks plugin-wide consistency
**Re-evaluate if:** Plugin-wide migration to CC-native skill syntax is on the roadmap

### [2026-04-22] git-commit-push-pr: Multi-platform question tool mapping

**Source:** CE
**What upstream has:** Explicit `AskUserQuestion` / `request_user_input` / `ask_user` mapping for CC/Codex/Gemini
**sp-compound approach:** CC-focused, plain conversational ask
**Rejection reason:** Out of scope per `using-sp-compound` multi-platform rejection
**Re-evaluate if:** sp-compound expands to multi-platform

### [2026-04-22] git-commit-push-pr: Compound Engineering badge footer

**Source:** CE
**What upstream has:** Promotional badge + model/harness chip appended to every PR body
**sp-compound approach:** No badge
**Rejection reason:** Marketing content, no agent-decision value. Principle #1
**Re-evaluate if:** Never

### [2026-04-22] git-commit-push-pr: Cross-repo PR API fallback (Case B)

**Source:** CE
**What upstream has:** `gh pr diff` + `gh pr view --json commits` path for PRs whose head is in a different repo
**sp-compound approach:** Fork-remote handling in base resolution only
**Rejection reason:** Edge case; cost exceeds benefit. Principle #1
**Re-evaluate if:** Users report cross-repo fork PR workflows are common

### [2026-04-22] git-commit-push-pr: No em dashes writing rule

**Source:** CE
**What upstream has:** "No em dashes or `--` substitutes" writing voice rule
**sp-compound approach:** No rule; sp-compound docs use em dashes
**Rejection reason:** Cosmetic style; conflicts with sp-compound's own written style
**Re-evaluate if:** Never — style preference

### [2026-04-22] git-commit-push-pr: Edges-vs-rows Mermaid/table distinction

**Source:** CE
**What upstream has:** Extended prose on topology (edges) vs parallel variation (rows) for picking Mermaid vs table
**sp-compound approach:** Concise "3+ interacting components" trigger
**Rejection reason:** sp-compound's brief guidance is adequate. Principle #1
**Re-evaluate if:** Agents repeatedly pick the wrong visual aid

### [2026-04-22] writing-skills: testing-skills-with-subagents.md (full 12K reference file)

**Source:** SP
**What upstream has:** 400-line dedicated reference file — full testing methodology, pressure scenarios, meta-testing, bulletproofing workflow, worked TDD bulletproofing example
**sp-compound approach:** Inline TDD RED-GREEN-REFACTOR + adopted concrete pieces (pressure types table, meta-testing diagnostic, bulletproof signs) directly in SKILL.md
**Rejection reason:** Cost exceeds benefit as a whole file — adopted the actionable pieces inline (~25 lines); the rest is narrative/worked examples that conflict with principle #1
**Re-evaluate if:** Users report the inline coverage is insufficient for writing discipline skills

### [2026-04-22] writing-skills: persuasion-principles.md (Cialdini/Meincke research)

**Source:** SP
**What upstream has:** 180-line theoretical foundation — 7 persuasion principles with research citations (Cialdini 2021, Meincke 2025)
**sp-compound approach:** Techniques (authority imperatives, "no exceptions", "delete means delete") embedded directly in skill prose without theorizing them
**Rejection reason:** Cost exceeds benefit — the techniques work whether or not authors read the theory; 180 lines of citations don't change authoring behavior. Principle #1
**Re-evaluate if:** sp-compound adds a theory/education track for skill authors

### [2026-04-22] writing-skills: graphviz-conventions.dot + render-graphs.js

**Source:** SP
**What upstream has:** Dot-graph style guide (170 lines) + Node.js SVG renderer script
**sp-compound approach:** Text-based flowcharts and markdown tables
**Rejection reason:** LLMs don't natively render dot graphs (see 2026-04-12 flexible-tdd Graphviz rejection). Principles #1, #5
**Re-evaluate if:** LLMs gain native graph rendering

### [2026-04-22] writing-skills: examples/CLAUDE_MD_TESTING.md worked example

**Source:** SP
**What upstream has:** 190-line narrative worked example testing CLAUDE.md documentation variants
**sp-compound approach:** None — the skill's own anti-pattern rule forbids narrative examples
**Rejection reason:** Violates the skill's own stated anti-pattern ("In session 2025-10-03..."). Self-contradictory to include. Principle #1
**Re-evaluate if:** Never

### [2026-04-22] writing-skills: TDD Mapping conceptual table

**Source:** SP
**What upstream has:** Table mapping TDD concepts (test case, production code, RED/GREEN/REFACTOR) to skill-authoring equivalents
**sp-compound approach:** Tagline "Writing skills IS Test-Driven Development applied to process documentation" + direct RED/GREEN/REFACTOR sections
**Rejection reason:** Cosmetic elaboration — doesn't change agent behavior. Principle #1
**Re-evaluate if:** Never — already conveyed inline

### [2026-04-22] using-sp-compound: EnterPlanMode → brainstorm gate in flowchart

**Source:** SP (ported in, then rolled back after adversarial review)
**What upstream has:** Disconnected subgraph — "About to EnterPlanMode?" → "Already brainstormed?" → "Invoke sp-compound:brainstorm" → "Might any skill apply?"
**sp-compound approach:** `skills/plan/SKILL.md` section 0.4 (No-Requirements Fallback) already gates for missing brainstorming and routes to `sp-compound:brainstorm` when product framing is ambiguous
**Rejection reason:** Duplicates an existing downstream gate; introduces a disconnected flowchart subgraph with no incoming edge; references `EnterPlanMode` — a platform-specific concept not defined in sp-compound's vocabulary (Principle #3). Principles #1 (conciseness), #2 (workflow chain coherence)
**Re-evaluate if:** plan skill loses its No-Requirements Fallback routing, or sp-compound defines an abstract plan-mode concept in its own vocabulary

### [2026-04-22] writing-skills: Pressure Types table (7 named pressure categories)

**Source:** SP
**What upstream has:** 13-line table enumerating Time / Sunk cost / Authority / Economic / Exhaustion / Social / Pragmatic pressure types with examples
**sp-compound approach:** Instruction retained: "Force concrete A/B/C choice with real constraints, not open-ended questions" — the concrete-choice rule is the actionable part
**Rejection reason:** The 7 pressure types are psychology concepts already in the LLM's base knowledge; enumerating them does not change agent behavior when generating pressure scenarios. Tokens without a decision. Principles #1, #5
**Re-evaluate if:** Empirical evidence shows agents generate narrower or inconsistent pressure scenarios without the taxonomy

### [2026-04-22] writing-skills: Bulletproof Signs vs Not-Yet-Bulletproof table

**Source:** SP
**What upstream has:** 4-row comparison table of "bulletproof" vs "not bulletproof" agent behaviors under pressure
**sp-compound approach:** Success criteria already specified per skill type in "Testing by Skill Type" table; REFACTOR phase already describes the loophole-closing loop; meta-test diagnostic (retained) gives a sharper signal
**Rejection reason:** Restates success criteria already captured in "Testing by Skill Type" in different words. Redundant. Principle #1
**Re-evaluate if:** "Testing by Skill Type" is removed or substantially changed

### [2026-04-22] brainstorm: Reuse / Extend / Build label on chosen approach

**Source:** CE
**What upstream has:** Instruction to label the chosen direction as Reuse an existing pattern / Extend an existing capability / Build something net new, as a "signal for planning"
**sp-compound approach:** No label; plan skill does not consume a Reuse/Extend/Build signal
**Rejection reason:** Dead signal — no downstream consumer in `skills/plan/` reads or branches on this label. Producing a signal without a consumer is pure spec pollution. Principle #1, #2
**Re-evaluate if:** plan skill adds explicit handling for reuse-vs-new-build distinctions in its research or task generation

### [2026-04-22] brainstorm requirements-capture: Duplicate plain-bullets-for-lightweight rule

**Source:** Self-improve (internal duplication introduced while adapting CE size heuristics)
**What upstream has:** The rule "For Lightweight docs with 1-3 simple requirements, plain bullets without R-IDs are acceptable" was added to the Size Heuristics block
**sp-compound approach:** The same rule (phrased as "For very small requirements docs with only 1-3 simple requirements, plain bullet requirements are acceptable") already exists in the scope-matched ceremony section earlier in the same file
**Rejection reason:** Same rule stated twice in one file — duplication that introduces drift risk if one copy is edited. Principle #1
**Re-evaluate if:** Never — one canonical location only

### [2026-04-22] git-commit-push-pr: Compression Pass "remove Commits/Review section" bullet

**Source:** CE
**What upstream has:** A Compression-Pass bullet instructing "If a Commits or Review section exists, remove it (see principles above)"
**sp-compound approach:** Writing Principles already contain "No Commits section" and "No Review / process section" rules that forbid creating those sections in the first place
**Rejection reason:** Redundant cleanup step — Writing Principles prevent creation, so the compression-pass cleanup has nothing to do. Principle #1
**Re-evaluate if:** Writing Principles stop forbidding Commits/Review sections

### [2026-04-22] git-worktree: "Dev tool trust skipped" troubleshooting row

**Source:** CE
**What upstream has:** Troubleshooting-table row instructing to review the config diff and run the trust command manually when dev tool trust was skipped
**sp-compound approach:** Creation step 5 already instructs "Flag modified configs for manual review" — the resolution path is already documented at the point it applies
**Rejection reason:** Restates guidance already present in the creation step. Principle #1
**Re-evaluate if:** Creation step 5 stops mentioning manual review
