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

### [2026-05-08] reproduce-bug: Assumption audit

**Source:** CE (ce-debug Phase 2)
**What upstream has:** Explicit "list the beliefs your understanding depends on, mark each verified/assumed" step before hypothesis formation
**sp-compound approach:** reproduce-bug only forms 2-3 initial hypotheses to direct reproduction; deep hypothesis scaffolding belongs in sp-compound:debug
**Rejection reason:** Belongs in sp-compound:debug. Same rationale as detailed prediction-quality examples — principles #1, #2
**Re-evaluate if:** sp-compound:debug loses assumption-audit guidance

### [2026-05-08] reproduce-bug: Environment sanity verification checklist

**Source:** CE (ce-debug Phase 1.2)
**What upstream has:** Full checklist before tracing — branch, dependencies installed, runtime version, env vars, stale build artifacts, local services
**sp-compound approach:** Phase 3 "If reproduction fails" already notes "Check for environment-specific factors — differences between environments IS the investigation"
**Rejection reason:** Existing coverage adequate; expanding into a full framework-neutral-but-still-long checklist violates principle #1
**Re-evaluate if:** Users repeatedly miss env-level causes during reproduction

### [2026-05-08] reproduce-bug: Bug-class pattern checklist

**Source:** CE (ce-debug investigation-techniques.md)
**What upstream has:** Pre-trace checklist (time/timezone, encoding, floating-point, off-by-one, cache staleness, permissions, version drift, path/case, concurrency, stale artifacts, TOCTOU)
**sp-compound approach:** reproduce-bug forms hypotheses from issue symptoms and code search; deep hypothesis scaffolding belongs in sp-compound:debug
**Rejection reason:** Belongs in sp-compound:debug (hypothesis-quality aid). Principles #1, #2
**Re-evaluate if:** sp-compound:debug loses pattern-checklist coverage

### [2026-05-08] reproduce-bug: Parallel sub-agent investigation

**Source:** CE (ce-debug Phase 2)
**What upstream has:** Dispatch read-only sub-agents in parallel when hypotheses are evidence-bottlenecked across independent subsystems
**sp-compound approach:** reproduce-bug is intake + reproduction only; deep multi-hypothesis investigation belongs in sp-compound:debug
**Rejection reason:** Out of scope. Principles #1, #2
**Re-evaluate if:** Never — architectural

### [2026-05-08] reproduce-bug: Adopting ce-report-bug (external plugin-bug intake)

**Source:** CE (ce-report-bug skill)
**What upstream has:** Dedicated skill for plugin users to file bug reports against the compound-engineering plugin itself (structured Q&A + gh issue create)
**sp-compound approach:** reproduce-bug investigates bugs in the user's codebase from issue trackers; ce-report-bug's purpose (reporting bugs against the plugin itself) is an unrelated capability
**Rejection reason:** Different skill purpose — not a reproduce-bug comparison point. If sp-compound wants user-facing plugin-bug reporting, it would be a new skill, not a reproduce-bug change
**Re-evaluate if:** Users request a sp-compound:report-bug skill; at that point treat as a new skill, not reproduce-bug

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

### [2026-05-08] flexible-tdd: SP "Violating the letter is violating the spirit" principle line

**Source:** SP
**What upstream has:** Overview reinforcer line: "Violating the letter of the rules is violating the spirit of the rules."
**sp-compound approach:** Common Rationalizations table already addresses "It's about spirit not ritual" and Red Flags list repeats it; Strategy 1 opens with "Thinking 'skip TDD just this once'? Stop. That's rationalization."
**Rejection reason:** Redundant — the spirit-vs-letter dodge is already closed at two stronger points (table row + red flag). Adding a third is prose padding. Principle #1
**Re-evaluate if:** The table row and red flag both get removed

### [2026-05-08] flexible-tdd: SP "Test hard = design unclear" rationalization row

**Source:** SP
**What upstream has:** Row in Common Rationalizations: "Test hard = design unclear | Listen to test. Hard to test = hard to use."
**sp-compound approach:** When Stuck table already has "Test too complicated | Design too complicated. Simplify interface." plus "Must mock everything | Code too coupled. Use dependency injection."
**Rejection reason:** Same guidance expressed in the action-oriented When Stuck table where the agent actually lands when stuck. Adding to the rationalization table duplicates with weaker framing. Principle #1
**Re-evaluate if:** When Stuck table loses the complexity/coupling rows

### [2026-05-08] flexible-tdd: SP anti-patterns ❌/✅ emoji markers + "your human partner's correction" quotes

**Source:** SP (testing-anti-patterns.md)
**What upstream has:** ❌/✅ emoji prefixes on code blocks and "your human partner's correction: '...'" / "your human partner's question: '...'" callout quotations
**sp-compound approach:** Plain BAD/GOOD labels, no persona quotations
**Rejection reason:** Emoji markers are cosmetic (no agent decision changes); persona quotations are user-specific idiom akin to the already-rejected Circle K phrase. Principles #1, #3
**Re-evaluate if:** Never

### [2026-05-08] flexible-tdd: SP anti-patterns expanded Gate Function pseudocode blocks

**Source:** SP (testing-anti-patterns.md)
**What upstream has:** Multi-line `BEFORE ... IF ... STOP` pseudocode blocks (plus nested "Red flags" and "If unsure" branches) for each anti-pattern's Gate section
**sp-compound approach:** One- or two-sentence prose Gate after each anti-pattern carrying the same question + action ("Before X, ask Y. If Z — do W.")
**Rejection reason:** Prose Gates already convey the single decision the agent needs; the pseudocode wrapper adds structure without adding a new decision point. Principle #1
**Re-evaluate if:** Agents are skipping gates because prose is missed in dense reads

### [2026-05-08] flexible-tdd: SP anti-patterns "class owns resource lifecycle" second gate

**Source:** SP (testing-anti-patterns.md, Anti-Pattern 2)
**What upstream has:** Second gate question "Does this class own this resource's lifecycle? IF no: STOP — Wrong class for this method"
**sp-compound approach:** Single gate "Is this only used by tests? If yes — put it in test utilities"
**Rejection reason:** The lifecycle-ownership check is a broader design concern (wrong-class placement for production code), not a testing anti-pattern. Expanding this file's scope conflicts with its stated purpose. Principle #1
**Re-evaluate if:** sp-compound adds a dedicated design-boundaries reference that would be the proper home for this check

### [2026-05-08] plan: Solo + Brainstorm-sourced synthesis checkpoints (Phase 0.7 / 5.1.5)

**Source:** CE
**What upstream has:** Two chat-time three-bucket (Stated/Inferred/Out) scope checkpoints before and after research, with a full `references/synthesis-summary.md` discipline file, soft-cut blocking, and headless-mode `## Assumptions` routing
**sp-compound approach:** Phase 0 ingests the brainstorm requirements doc directly; Phase 2 resolves planning questions; Phase 5.1 self-reviews coverage. No chat-time scope checkpoint — brainstorm owns scope validation, plan owns implementation shape.
**Rejection reason:** Heavy ceremony (one full reference file, soft-cut state, bucket routing) for a job the sp-compound workflow chain already does via the brainstorm->plan handoff. Adding synthesis checkpoints reopens scope-resolution at plan time, blurring the brainstorm/plan boundary. Principles #1, #2
**Re-evaluate if:** Users report scope drift between brainstorm and plan, or solo (no-brainstorm) invocations consistently produce mis-scoped plans

### [2026-05-08] plan: ## Summary and ## Problem Frame template split

**Source:** CE
**What upstream has:** Dedicated forward-looking `## Summary` + backward-looking `## Problem Frame` template sections, each with strict content rules
**sp-compound approach:** Single `**Goal:**` one-liner + `**Architecture:**` 2-3 sentence summary in the plan header
**Rejection reason:** sp-compound's Goal/Architecture header already carries the forward-looking summary; Problem Frame content (the "why") lives in the origin requirements doc and is referenced via the `origin:` frontmatter field. Duplicating it in the plan violates Principle #1 and creates drift risk against the origin doc
**Re-evaluate if:** Plans without an origin doc prove hard to read because the "why" is missing

### [2026-05-08] plan: ## Assumptions section for headless mode

**Source:** CE
**What upstream has:** Dedicated `## Assumptions` section that captures un-validated agent inferences when the skill runs non-interactively (LFG / disable-model-invocation contexts)
**sp-compound approach:** No headless/pipeline mode; interactive by design. Assumptions in sp-compound plans are captured inline as part of Key Technical Decisions or deferred questions, user-corrected in chat
**Rejection reason:** No pipeline mode in sp-compound (already rejected 2026-04-12). Without non-interactive runs, there is no class of un-validated bets needing a separate audit surface. Principle #2
**Re-evaluate if:** sp-compound adds a pipeline/automation mode

### [2026-05-08] plan: Artifact-backed deepening mode (scratch dir, per-agent files)

**Source:** CE
**What upstream has:** Optional `mode:artifact-backed` for deepening — create per-run scratch dir via `mktemp`, have each sub-agent write one compact artifact file, return only a summary, cleanup after synthesis
**sp-compound approach:** Direct-mode dispatch only — sub-agents return findings inline; deepening gate caps at top 2-5 sections with max ~8 agents total
**Rejection reason:** sp-compound's deepening budget is already capped low (~8 agents max) and direct-mode returns fit in context without disk I/O. Artifact-backed mode exists to manage CE's higher agent counts and its write-failure / malformed-artifact / cleanup-skipped paths — failure modes not present at sp-compound scale. Principles #1, #3
**Re-evaluate if:** sp-compound deepening routinely dispatches 6+ agents with bulky source-backed returns

### [2026-05-08] plan: NNN sequence number + type in filename

**Source:** CE
**What upstream has:** `docs/plans/YYYY-MM-DD-NNN-<type>-<name>-plan.md` with zero-padded 3-digit sequence and `<type>` prefix (`feat`/`fix`/`refactor`)
**sp-compound approach:** `.sp-compound/plans/YYYY-MM-DD-<feature-name>-plan.md`; `type` lives in YAML frontmatter
**Rejection reason:** Cosmetic naming convention; sp-compound typically produces at most one plan per topic per day, so multi-plan-per-day collisions are rare and already handled by the descriptive name. Adding NNN + type prefix bloats filenames without changing agent behavior. Principle #1
**Re-evaluate if:** Users report frequent same-day filename collisions in practice

### [2026-05-08] plan: ce-doc-review skill as mandatory post-write gate

**Source:** CE
**What upstream has:** Mandatory `ce-doc-review mode:headless <plan-path>` after plan write — even when the confidence check passed; headless envelope drives the post-generation menu summary; 5-option Proof-integrated menu
**sp-compound approach:** Inline Phase 5.1 self-review checklist; no separate doc-review skill
**Rejection reason:** sp-compound's inline checklist already covers the classes of issues CE's doc-review catches (placeholders, trace gaps, test coverage, path hygiene) without a second skill dispatch. Adding a mandatory sub-skill call conflicts with Principle #1 and creates a new review-plan skill maintenance surface
**Re-evaluate if:** Users report plan-quality issues the inline checklist misses that a dedicated reviewer would catch

### [2026-05-08] plan: Core Principles list (8 numbered principles in SKILL.md body)

**Source:** CE
**What upstream has:** Top-level `## Core Principles` section with 8 numbered items (source-of-truth, decisions-not-code, research-before-structuring, right-size, separate planning from execution, portability, execution-posture lightness, honor user-named resources)
**sp-compound approach:** Single `## Core Principle` one-liner ("research ensures code blocks are grounded in reality") with behavioral rules inlined in each phase
**Rejection reason:** sp-compound already enforces these behaviors through phase instructions; listing them as prose principles duplicates the phase rules without changing agent decisions. Several CE principles (decisions-not-code, honor user-named resources) are also individually rejected. Principle #1
**Re-evaluate if:** Reviewers report agent behavior inconsistent with a listed principle that phase rules do not already cover

### [2026-05-08] plan: Stakeholder and Impact Awareness prose section

**Source:** CE (Phase 3.2)
**What upstream has:** Standing instruction to briefly consider who is affected by the change (end users, developers, operations, other teams) and note affected parties in System-Wide Impact
**sp-compound approach:** Requirements trace + Risks & Dependencies fields already capture relevant cross-team impact; plans do not include a System-Wide Impact template section (already rejected 2026-04-22)
**Rejection reason:** Without a System-Wide Impact section to anchor it, the stakeholder prose has no destination inside the plan template. Adding the section would reopen an already-rejected item. Principle #1
**Re-evaluate if:** sp-compound adopts a System-Wide Impact section

### [2026-05-08] git-worktree: SP default-to-`.worktrees/` (no user ask)

**Source:** SP (using-git-worktrees)
**What upstream has:** When nothing is declared and no existing dir is found, SP skips the ask and defaults to `.worktrees/` at project root, then verifies/commits .gitignore
**sp-compound approach:** Directory Selection Step 3 asks the user to choose between `.worktrees/` (project-local) and `~/worktrees/<project>/` (global) when no existing dir / CLAUDE.md preference exists
**Rejection reason:** Explicit consent on first-time directory placement is a deliberate UX choice — global vs project-local is a per-user preference that persists across the project's lifetime, and silently defaulting would commit `.gitignore` changes without the user knowing global-path was an option. Principle #7 (protect unique improvement); one extra turn is cheap vs wrong-default churn
**Re-evaluate if:** Users report the ask friction is disruptive, OR sp-compound drops global-path support

### [2026-05-08] git-worktree: SP backward-compat `~/.config/superpowers/worktrees/` legacy path

**Source:** SP (using-git-worktrees)
**What upstream has:** Directory-selection probes `~/.config/superpowers/worktrees/<project>` as a step for backward compatibility with legacy SP installs
**sp-compound approach:** Generic `~/worktrees/<project>/` option offered to user; no superpowers-branded path
**Rejection reason:** Out of scope — sp-compound has no install-history of that path, so no user would have it. Principle #3 (agnostic) and #6 (three-way parity: "upstream has it" is not a reason)
**Re-evaluate if:** sp-compound users migrating from SP report losing their legacy worktree directories

### [2026-05-08] git-worktree: SP separate "Common Mistakes" section

**Source:** SP (using-git-worktrees)
**What upstream has:** Dedicated Common Mistakes section with problem/fix pairs (Fighting the harness, Skipping detection, Skipping ignore verification, Assuming directory location, Proceeding with failing tests)
**sp-compound approach:** Red Flags Never/Always lists + Quick Reference table cover the same anti-patterns more concisely, and Step 0 + Prefer Native Tools now cover harness-fighting and nested-worktree cases directly
**Rejection reason:** Redundant with existing Red Flags + Quick Reference. Principle #1 (conciseness) and #5 (tables/checklists over prose)
**Re-evaluate if:** Red Flags stops covering anti-patterns explicitly

### [2026-05-08] compound: "What It Captures / What It Creates / Compounding Philosophy" prose sections

**Source:** CE
**What upstream has:** Three motivational prose sections (~40 lines) explaining compounding metaphor, feedback loop ASCII diagram, and enumerated captured fields
**sp-compound approach:** Overview one-paragraph tagline + concise Phase/Integration tables
**Rejection reason:** Verbose human-motivational prose with no agent decision. Principles #1, #5
**Re-evaluate if:** Never — agent-first design

### [2026-05-08] compound: Auto-Invoke trigger-phrases block

**Source:** CE
**What upstream has:** `<auto_invoke>` block listing "that worked", "it's fixed", "working now", "problem solved" trigger phrases
**sp-compound approach:** `description` frontmatter field handles invocation ("Use after solving a notable problem...")
**Rejection reason:** Redundant with description field. Adding trigger phrases increases false-positive auto-trigger rate on casual conversation. Principle #1
**Re-evaluate if:** sp-compound loses description-based auto-invocation

### [2026-05-08] compound: Pre-resolved git branch via `!` bash expansion

**Source:** CE
**What upstream has:** `!`git rev-parse --abbrev-ref HEAD`` at skill load, passed to Session Historian
**sp-compound approach:** No pre-resolved block — the only downstream consumer (Session Historian) is rejected
**Rejection reason:** Dead pre-resolution — no consumer in sp-compound reads it. Parallels git-commit-push-pr `!` rejection 2026-04-22 (plugin-wide consistency). Principles #1, #2
**Re-evaluate if:** sp-compound adopts a Session-Historian-like agent needing git-branch context

### [2026-05-08] compound: `mkdir -p` shell step in Phase 2 assembly

**Source:** CE
**What upstream has:** Explicit `mkdir -p docs/solutions/[category]/` shell command in Phase 2
**sp-compound approach:** "Create the directory and the relevant category subdirectory" — handled by native Write tool auto-creating parents
**Rejection reason:** Cosmetic / tooling-specific. sp-compound agents use Write with auto-parent-creation. Principle #1
**Re-evaluate if:** Never — tooling choice

### [2026-05-08] compound-refresh: Long description with trigger-phrase catalog

**Source:** CE
**What upstream has:** ~200-word description listing trigger phrases ("refresh my learnings", "audit docs/solutions/", etc.) to drive model auto-invocation
**sp-compound approach:** `disable-model-invocation: true` frontmatter — compound-refresh is invoked by user or by `sp-compound:compound` Phase 2.5, not via pattern matching
**Rejection reason:** Different invocation model by design. Flipping to CE's pattern would require removing disable-model-invocation and risk spurious triggers on conversational phrases. Principle #7
**Re-evaluate if:** sp-compound removes disable-model-invocation from compound-refresh

### [2026-05-08] compound/compound-refresh: Schema framework-specific component + root_cause enums

**Source:** CE
**What upstream has:** `component` enum (rails_model, hotwire_turbo, brief_system, …) and `root_cause` enum (missing_association, thread_violation, …) in schema.yaml
**sp-compound approach:** `component` is a free-form optional string; no root_cause enum; bug-track fields kept framework-agnostic
**Rejection reason:** Framework-specific (Rails vocabulary baked into enums). Parallels already-logged 2026-04-12 schema-design rejection; re-confirmed for this run. Principle #3
**Re-evaluate if:** Never — fundamental design choice

### [2026-05-08] compound/compound-refresh: ToolSearch AskUserQuestion preload protocol

**Source:** CE
**What upstream has:** "call ToolSearch with select:AskUserQuestion first if schema isn't loaded" micro-instructions repeated throughout both skills
**sp-compound approach:** Plain "use the platform's blocking question tool when available, otherwise numbered options"
**Rejection reason:** Platform-specific verbosity; parallels plan/brainstorm rejections 2026-04-22. Principle #1
**Re-evaluate if:** Claude Code schema loading becomes a common failure mode

### [2026-05-08] compound: CE resolution-template section renames

**Source:** CE (assets/resolution-template.md)
**What upstream has:** Section order Problem / Symptoms / What Didn't Work / Solution / Why This Works / Prevention / Related Issues
**sp-compound approach:** Problem / Root Cause / Failed Attempts / Solution / Prevention / Related Issues (Root Cause promoted, Why-This-Works folded into Root Cause + Solution)
**Rejection reason:** Equivalent structure with minor ordering differences; changing would cascade across all existing .sp-compound/solutions/ docs. Principles #1, #2
**Re-evaluate if:** Never — cosmetic section ordering

### [2026-05-08] compound-refresh: CE "2-option Full vs Lightweight" prompt at start

**Source:** CE
**What upstream has:** Explicit blocking prompt for Full vs Lightweight mode at skill start
**sp-compound approach:** Mode Detection from `$ARGUMENTS` (interactive default, mode:autofix, mode:autonomous) — no start-of-session prompt
**Rejection reason:** Already rejected for compound 2026-04-12 (auto-proceed-to-full); same rationale applies to compound-refresh. Principle #5
**Re-evaluate if:** Never — architectural

### [2026-05-08] debug: SP pointer to condition-based-waiting-example.ts inside condition-based-waiting.md

**Source:** SP
**What upstream has:** Line "See `condition-based-waiting-example.ts` in this directory for complete implementation..." following the generic polling function
**sp-compound approach:** The example file itself was rejected 2026-04-12 (framework-specific TypeScript for the Lace project); the pointer is therefore dead text
**Rejection reason:** Consistent with the already-rejected example file — pointing at a file sp-compound doesn't ship is dead text. Principles #1, #3
**Re-evaluate if:** Never — the example file itself is permanently rejected

### [2026-05-08] receiving-review: CE "Agent time is cheap. Tech debt is expensive." framing quote

**Source:** CE (ce-resolve-pr-feedback)
**What upstream has:** Motivational preamble quote above the "Fix everything valid" policy
**sp-compound approach:** Functional instruction only
**Rejection reason:** Motivational prose — policy line already changes behavior; quote adds no decision value. Principle #1
**Re-evaluate if:** Never — already covered by functional instruction

### [2026-05-08] receiving-review: CE full PR-resolve automation (re-confirmed)

**Source:** CE (ce-resolve-pr-feedback)
**What upstream has:** GraphQL scripts, parallel agent dispatch, cross-invocation cluster analysis, triage/actionability filters, iteration gate, combined-state validation
**sp-compound approach:** receiving-review is behavioral/mindset; no automation skill exists
**Rejection reason:** Re-confirmed from 2026-04-22. Different scope — would require a separate skill. Scripts conflict with scriptless design. Principle #1
**Re-evaluate if:** User demand for dedicated PR-resolution automation

### [2026-05-08] review: `metadata.json` sidecar in run artifact

**Source:** CE (ce-code-review)
**What upstream has:** Per-run `metadata.json` sidecar with branch/HEAD/commit info next to the findings JSON artifact
**sp-compound approach:** Single `triage.json` artifact, no metadata sidecar
**Rejection reason:** No downstream consumer — triage.json is read only by the same-run report renderer; `.sp-compound/solutions/` is written by compound, not review. Principle #1 (don't emit signals nothing reads)
**Re-evaluate if:** sp-compound adds a programmatic downstream consumer needing branch/HEAD verification

### [2026-05-08] review: SP "Strengths" acknowledgment section in output

**Source:** SP (requesting-code-review)
**What upstream has:** Section praising what's done well before listing findings
**sp-compound approach:** Severity-grouped findings + verdict blockquote; no strengths section
**Rejection reason:** Cosmetic — doesn't change agent behavior or verdict routing. Principle #1
**Re-evaluate if:** Never — cosmetic

### [2026-05-08] review: SP "Push back if reviewer is wrong" guidance inline

**Source:** SP (requesting-code-review)
**What upstream has:** Inline guidance telling the review-consumer to push back if a finding is wrong
**sp-compound approach:** Quality-gate #2 ("No false positives from skimming") plus dedicated `sp-compound:receiving-review` skill
**Rejection reason:** Equivalent coverage via quality gate + separate skill. Inline guidance duplicates. Principle #1
**Re-evaluate if:** receiving-review skill loses push-back framing

### [2026-05-08] review: CE project-standards / stack-specific reviewers added to always-on set

**Source:** CE (ce-code-review)
**What upstream has:** CLAUDE.md/AGENTS.md compliance + stack-specific personas in always-on reviewer set
**sp-compound approach:** 5+2 lean reviewer set; project-standards compliance absorbed into correctness reviewer when relevant
**Rejection reason:** Hard rule — preserve 5+2. Widening the always-on set dilutes signal and increases cost. If needed later, absorb into existing persona. Principle #7
**Re-evaluate if:** Evidence that project-standards compliance is routinely missed by current correctness reviewer

### [2026-05-08] finishing-branch: SP expanded Option 4 confirmation template

**Source:** SP (finishing-a-development-branch)
**What upstream has:** Multi-line confirmation block spelling out branch/commits/worktree/"Type 'discard'"
**sp-compound approach:** Single instruction listing the same required fields
**Rejection reason:** Equivalent coverage; template form adds ~10 lines without behavior change. Principle #1
**Re-evaluate if:** Users report missing fields in Option 4 confirmations

### [2026-05-08] finishing-branch: SP standalone "Common Mistakes" section

**Source:** SP (finishing-a-development-branch)
**What upstream has:** Dedicated Common Mistakes section with problem/fix pairs (Fighting the harness, Skipping detection, Skipping ignore verification, Assuming directory location, Proceeding with failing tests)
**sp-compound approach:** Red Flags only; SP's items folded into Never/Always bullets
**Rejection reason:** Dual sections restate the same content twice. Folding captures the behavior without duplication. Principle #1
**Re-evaluate if:** Red Flags loses Never/Always structure

### [2026-05-08] work: AGENTS.md adopted as canonical project-conventions doc

**Source:** CE (ce-work)
**What upstream has:** Reads AGENTS.md as canonical per-project conventions document in Phase 1 context gathering
**sp-compound approach:** Reads CLAUDE.md + AGENTS.md where present; neither treated as canonical
**Rejection reason:** Canonicalizing AGENTS.md cross-skill would cascade across brainstorm/plan/review and lock sp-compound to a CE convention. Principles #1, #6
**Re-evaluate if:** AGENTS.md becomes an industry-standard convention across SP + CE

### [2026-05-08] work: Sensitive-surface enumeration in Large-triage routing

**Source:** CE (ce-work)
**What upstream has:** Large-change triage enumerates sensitive surfaces (auth, payments, migrations, public APIs) that re-trigger tiered review routing
**sp-compound approach:** sp-compound:review owns review-depth decisions internally; work dispatches uniformly
**Rejection reason:** Reintroduces Tier routing through a side door. Already-rejected Tier 1/Tier 2 routing (2026-04-12, 2026-04-22) applies. Principle #1
**Re-evaluate if:** sp-compound:review loses internal depth routing

### [2026-05-08] work: Shipping flow extracted to separate references/ file

**Source:** CE (ce-work)
**What upstream has:** Shipping workflow moved to `references/shipping.md`
**sp-compound approach:** Phases 3-4 (~15 lines) inline in SKILL.md
**Rejection reason:** Extraction adds failure mode (missing-reference, load error) without savings at 15 lines. Principle #1
**Re-evaluate if:** Shipping section grows substantially

### [2026-05-08] git-commit-push-pr: PR mode dispatch on pasted URL/number

**Source:** CE (ce-commit-push-pr)
**What upstream has:** Arbitrary pasted PR ref (URL or #N) triggers description-update mode on that PR
**sp-compound approach:** Description-update mode detects current branch's PR via `gh pr view`
**Rejection reason:** Niche; doubles conditional surface in Step 5 for a rare workflow. Principle #1
**Re-evaluate if:** Users routinely update PRs other than their current branch's

### [2026-05-08] git-commit-push-pr: Visual-aids 6-row PR-shape table

**Source:** CE (ce-commit-push-pr)
**What upstream has:** Table mapping 6 change shapes (state/ERD/flow/measurements/trade-offs/etc.) to mermaid vs table choice
**sp-compound approach:** Concise "3+ interacting components" trigger
**Rejection reason:** Same topology-vs-rows content already rejected 2026-04-22. Principle #1
**Re-evaluate if:** Agents repeatedly pick the wrong visual aid

### [2026-05-08] git-commit-push-pr: Pre-composition user focus hint parameter

**Source:** CE (ce-commit-push-pr)
**What upstream has:** Optional pre-composition parameter letting user pre-steer the description focus before first draft
**sp-compound approach:** Post-preview steering — user refines after seeing the first draft
**Rejection reason:** Post-preview path covers the realistic workflow (user sees draft, asks for changes) without a new input parameter. Principle #1
**Re-evaluate if:** Users repeatedly regenerate from scratch instead of refining

### [2026-05-08] git-commit-push-pr: GHES `refs/pull/<n>/head` fetch fallback

**Source:** CE (ce-commit-push-pr)
**What upstream has:** GitHub Enterprise Server `refs/pull/<n>/head` fetch fallback for cross-repo PRs
**sp-compound approach:** Fork-remote handling in base resolution only
**Rejection reason:** Tied to the already-rejected cross-repo PR API fallback (2026-04-22); same edge-case category. Principle #1
**Re-evaluate if:** GHES + cross-repo fork PR workflows become common in sp-compound user base
