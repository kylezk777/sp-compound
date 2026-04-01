---
name: flexible-tdd
description: Use when implementing any feature or bugfix, before writing implementation code. Provides TDD with strategy selection - test-first (default), characterization-first (legacy), or pragmatic (non-behavioral changes).
---

# Flexible TDD

## Overview

Write tests first. Watch them fail. Write minimal code to pass. But choose the RIGHT testing strategy for the context.

**Core principle:** Test discipline is non-negotiable. Test strategy is context-dependent.

## Strategy Selection

The plan's **execution note** per implementation unit determines which strategy to use. Default is always **test-first**.

### Strategy 1: test-first (DEFAULT)

SP's TDD Iron Law. Use for all new features, bug fixes, refactoring, behavior changes.

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it. Start over.

**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Delete means delete

**Red-Green-Refactor:**

1. **RED** — Write one minimal failing test showing desired behavior
   - One behavior per test
   - Clear name describing behavior
   - Real code, no mocks unless unavoidable
2. **Verify RED** — Run test, confirm it FAILS for the right reason (feature missing, not typo)
3. **GREEN** — Write simplest code to pass the test. Nothing more.
4. **Verify GREEN** — Run test, confirm it PASSES. Confirm other tests still pass.
5. **REFACTOR** — Clean up while keeping tests green. Don't add behavior.
6. **Repeat** — Next failing test for next behavior.

**Common rationalizations (all mean: delete code, start over):**

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Need to explore first" | Fine. Throw away exploration, start with TDD. |
| "TDD will slow me down" | TDD is faster than debugging. |
| "Manual test faster" | Manual doesn't prove edge cases. |
| "Keep as reference" | You'll adapt it. That's testing after. Delete means delete. |

### Strategy 2: characterization-first (LEGACY CODE)

Use when: modifying code with no existing test infrastructure, high-risk changes to poorly-understood code. **Must be explicitly marked in plan's execution note.**

```
LOCK EXISTING BEHAVIOR BEFORE CHANGING IT
```

1. **Write characterization tests** — Tests that capture CURRENT behavior (even if buggy)
   - Run code with known inputs, assert actual outputs
   - Cover main paths and any paths your change will touch
   - These tests document what the system does NOW
2. **Verify all characterization tests PASS** — They MUST pass against current code
3. **Make your change** — Modify the code as needed
4. **Run characterization tests** — Verify ONLY your target behavior changed
   - Tests that should still pass -> still pass
   - Tests that should change -> update assertions to new expected behavior
   - Any unexpected test failures -> investigate before proceeding
5. **Add new tests** — For the new/changed behavior, follow test-first for these
6. **Commit** — Characterization tests + change + new tests together

**When NOT to use characterization-first:**
- Greenfield code (use test-first)
- Code with existing test suite (use test-first, run existing tests)
- Simple bug fixes with clear behavior (use test-first)

### Strategy 3: pragmatic (NON-BEHAVIORAL CHANGES)

Use when: changes don't affect runtime behavior. **Must be explicitly marked in plan's execution note.**

Applies to:
- Configuration file changes
- Documentation updates
- Dependency version bumps (with no API changes)
- CI/CD pipeline changes
- Trivial formatting/linting fixes

For pragmatic changes:
1. Verify the change is truly non-behavioral
2. Apply the change
3. Run existing tests to confirm nothing broke
4. Commit

**If ANY doubt about whether a change is behavioral -> use test-first.**

## Verification Checklist

Before marking work complete:

- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing (test-first) OR locked behavior first (characterization-first)
- [ ] Each test failed for expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and errors covered

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write wished-for API. Write assertion first. Ask your human partner. |
| Test too complicated | Design too complicated. Simplify interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup huge | Extract helpers. Still complex? Simplify design. |
| Test fails for unexpected reason | Invoke `sp-compound:debug` — find root cause before fixing. |

## Integration

**Called by:**
- **sp-compound:work** — invokes appropriate strategy per implementation unit
- Directly by engineers following plan execution notes

**Strategy determined by:**
- **sp-compound:plan** — sets execution note per implementation unit during planning
