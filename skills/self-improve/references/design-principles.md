# sp-compound Design Principles

All borrowing decisions in self-improve use these principles as filters. When principles conflict, higher-numbered principles yield to lower-numbered ones.

## 1. Conciseness First

Skills are agent instructions, not human documentation. Every line consumes agent context window. Port only what changes agent behavior — not motivational prose, redundant examples, or verbose explanations.

Evaluation: if a section cannot be mapped to a concrete agent decision or action, it does not belong.

## 2. Workflow Chain Coherence

The core chain — brainstorm -> plan -> work -> review -> compound — and the knowledge flywheel (.sp-compound/solutions/) are sp-compound's primary value. Any change that breaks the input/output contract between skills in this chain is unacceptable, regardless of the standalone value of that change.

Implication: modifying one skill's output format requires verifying all downstream consumers before committing.

## 3. Framework Agnostic

sp-compound assumes nothing about the user's language, framework, or toolchain. Do not port framework-specific enums, examples, or decision logic (e.g., Rails components, React patterns, Go idioms). If upstream has a valuable concept wrapped in framework-specific implementation, extract the generic principle and discard the specifics.

## 4. Knowledge Flywheel as Core Differentiator

The compound -> plan/review feedback loop is what makes sp-compound compound. Changes that enrich, accelerate, or make this loop more reliable are high value. Changes that bypass, weaken, or complicate the knowledge store are high risk.

## 5. Agent-First Design

Skills are read by AI agents, not humans. Prefer tables over paragraphs, enums over prose, checklists over narratives. Each instruction should translate directly into one agent decision or action. Avoid ambiguity that forces the agent to interpret intent.

## 6. Three-Way Parity

SP, CE, and sp-compound are peer projects evolving independently. "Upstream has it" is not a reason to adopt. "sp-compound users need it" is. Evaluate every difference on its own merit, not on its origin.

## 7. Protect Unique Improvements

sp-compound has features neither SP nor CE have (e.g., autonomous modes, pattern templates, merged multi-source skills). These represent deliberate design choices. Any change that regresses a unique improvement requires explicit justification and user consent.
