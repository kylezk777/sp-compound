---
name: writing-skills
description: "Use when creating new skills, editing existing skills, or verifying skills work before deployment. Applies TDD methodology to skill authoring — write pressure tests first, then write the skill."
disable-model-invocation: true
---

# Writing Skills

Writing skills IS Test-Driven Development applied to process documentation.

**Core principle:** If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

## What is a Skill?

A **skill** is a reference guide for proven techniques, patterns, or tools. Skills help future agent instances find and apply effective approaches.

**Skills are:** Reusable techniques, patterns, tools, reference guides
**Skills are NOT:** Narratives about how you solved a problem once

## When to Create

**Create when:**
- Technique wasn't intuitively obvious
- You'd reference this again across projects
- Pattern applies broadly (not project-specific)

**Don't create for:**
- One-off solutions
- Standard practices well-documented elsewhere
- Project-specific conventions (put in CLAUDE.md/AGENTS.md)
- Mechanical constraints enforceable with automation

## Skill Types

| Type | Description | Example |
|------|-------------|---------|
| **Technique** | Concrete method with steps | condition-based-waiting, root-cause-tracing |
| **Pattern** | Way of thinking about problems | flatten-with-flags, test-invariants |
| **Reference** | API docs, syntax guides | tool documentation, schema references |

## SKILL.md Structure

```yaml
---
name: skill-name-with-hyphens
description: "Use when [specific triggering conditions and symptoms]"
---
```

**Frontmatter rules:**
- `name`: letters, numbers, hyphens only
- `description`: starts with "Use when...", describes TRIGGERING CONDITIONS only. Never summarize the skill's workflow — agents may follow the description instead of reading the full skill.

**Body structure:**
1. Overview — core principle in 1-2 sentences
2. When to Use — symptoms and use cases (flowchart if decision non-obvious)
3. Core Pattern — before/after code comparison
4. Quick Reference — table for scanning
5. Implementation — inline code or link to reference file
6. Common Mistakes — what goes wrong + fixes

## Claude Search Optimization (CSO)

### Description Field

The description decides whether the skill gets loaded. Make it answer: "Should I read this skill right now?"

```yaml
# BAD: Summarizes workflow — agent may shortcut and skip the skill body
description: "Review code between tasks with spec compliance then quality check"

# GOOD: Just triggering conditions
description: "Use when executing implementation plans with independent tasks"
```

### Keyword Coverage

Use words agents search for: error messages, symptoms, synonyms, tool names.

### Token Efficiency

- Target <500 words for most skills, <200 for frequently-loaded
- Move heavy reference (100+ lines) to separate files
- Use cross-references instead of repeating content
- One excellent example beats many mediocre ones

## File Organization

```
skill-name/
  SKILL.md              # Main reference (required)
  references/           # Large docs loaded on demand
  scripts/              # Executable tools
  assets/               # Output templates
```

**Flat namespace** — all skills in one searchable directory. Separate files only for heavy reference (100+ lines) or reusable tools.

## TDD for Skills: RED-GREEN-REFACTOR

### RED: Write Failing Test (Baseline)

Run pressure scenario with a subagent WITHOUT the skill. Document:
- What choices did the agent make?
- What rationalizations did it use (verbatim)?
- Which pressures triggered violations?

### GREEN: Write Minimal Skill

Write skill addressing those specific rationalizations. Run same scenarios WITH skill — agent should now comply.

### REFACTOR: Close Loopholes

Agent found new rationalization? Add explicit counter. Re-test until bulletproof.

## Testing by Skill Type

| Skill Type | Test With | Success Criteria |
|------------|-----------|-----------------|
| **Discipline** (TDD, verification) | Pressure scenarios (time + sunk cost + exhaustion) | Follows rule under maximum pressure |
| **Technique** (how-to guides) | Application + edge cases + missing info | Successfully applies to new scenario |
| **Pattern** (mental models) | Recognition + application + counter-examples | Correctly identifies when/how to apply |
| **Reference** (docs/APIs) | Retrieval + application + gap testing | Finds and correctly applies information |

## Bulletproofing Against Rationalization

### Close Every Loophole Explicitly

Don't just state the rule — forbid specific workarounds:

```markdown
# BAD
Write code before test? Delete it.

# GOOD
Write code before test? Delete it. Start over.
**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Don't look at it
- Delete means delete
```

### Build Rationalization Table

Every excuse agents make during baseline testing goes in the table:

```markdown
| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
```

### Create Red Flags List

Make it easy for agents to self-check:

```markdown
## Red Flags - STOP and Start Over
- Code before test
- "I already manually tested it"
- "This is different because..."
```

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

Applies to NEW skills AND EDITS. Write skill before testing? Delete it. Start over. No exceptions.

## Checklist

**RED Phase:**
- [ ] Create pressure scenarios (3+ combined pressures for discipline skills)
- [ ] Run WITHOUT skill — document baseline behavior verbatim
- [ ] Identify rationalization patterns

**GREEN Phase:**
- [ ] Name: letters, numbers, hyphens only
- [ ] Frontmatter: `name` + `description` (starts with "Use when...")
- [ ] Description: triggering conditions only, no workflow summary
- [ ] Address specific baseline failures from RED
- [ ] Run WITH skill — verify compliance

**REFACTOR Phase:**
- [ ] Identify new rationalizations from testing
- [ ] Add explicit counters
- [ ] Build rationalization table + red flags list
- [ ] Re-test until bulletproof

**Quality:**
- [ ] Flowchart only if decision non-obvious
- [ ] Quick reference table
- [ ] Common mistakes section
- [ ] No narrative storytelling
- [ ] Supporting files only for tools or heavy reference

## Integration

**Complements:** `sp-compound:flexible-tdd` — same discipline, different domain (code vs documentation)
