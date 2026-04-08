# Testing Anti-Patterns

**Load when:** writing or changing tests, adding mocks, or tempted to add test-only methods to production code.

**Core principle:** Test what the code does, not what the mocks do.

## The Iron Laws

```
1. NEVER test mock behavior
2. NEVER add test-only methods to production classes
3. NEVER mock without understanding dependencies
```

## Anti-Pattern 1: Testing Mock Behavior

**The violation:** Asserting on mock elements instead of real component behavior.

```
# BAD: Testing that the mock exists
test('renders sidebar'):
  render(<Page />)
  expect(getByTestId('sidebar-mock')).exists  # Testing the mock!

# GOOD: Test real behavior
test('renders sidebar'):
  render(<Page />)  # Don't mock sidebar
  expect(getByRole('navigation')).exists     # Test real element
```

**Gate:** Before asserting on any mock element, ask: "Am I testing real behavior or mock existence?" If mock existence — delete the assertion or unmock.

## Anti-Pattern 2: Test-Only Methods in Production

**The violation:** Adding methods to production classes that are only used by tests.

```
# BAD: destroy() only used in tests
class Session:
  def destroy(self):     # Looks like production API!
    self.workspace.cleanup(self.id)

# GOOD: Test utilities handle cleanup
# Session has no destroy() - it's stateless in production
def cleanup_session(session):   # In test_utils
  workspace = session.get_workspace_info()
  if workspace:
    workspace_manager.destroy(workspace.id)
```

**Gate:** Before adding any method to production class, ask: "Is this only used by tests?" If yes — put it in test utilities.

## Anti-Pattern 3: Mocking Without Understanding

**The violation:** Mocking a method without knowing its side effects, then wondering why the test fails or passes for the wrong reason.

```
# BAD: Mock breaks test logic
test('detects duplicate server'):
  mock(ToolCatalog.discoverAndCache, returns=None)  # Prevents config write!
  addServer(config)
  addServer(config)    # Should throw but won't — config never written

# GOOD: Mock at correct level
test('detects duplicate server'):
  mock(MCPServerManager)    # Just mock slow server startup
  addServer(config)         # Config written
  addServer(config)         # Duplicate detected
```

**Gate:** Before mocking:
1. What side effects does the real method have?
2. Does this test depend on any of those side effects?
3. If yes — mock at a lower level, preserving the side effects the test needs.

## Anti-Pattern 4: Incomplete Mocks

**The violation:** Partial mock that only includes fields you think you need.

```
# BAD: Missing metadata that downstream code uses
mock_response = {
  'status': 'success',
  'data': {'user_id': '123', 'name': 'Alice'}
  # Missing: metadata.request_id that downstream code accesses
}

# GOOD: Mirror real API completeness
mock_response = {
  'status': 'success',
  'data': {'user_id': '123', 'name': 'Alice'},
  'metadata': {'request_id': 'req-789', 'timestamp': 1234567890}
}
```

**Gate:** Before creating mock responses, check: "What fields does the real API response contain?" Include ALL fields the system might consume downstream.

## Anti-Pattern 5: Integration Tests as Afterthought

**The violation:** "Implementation complete, ready for testing."

Testing is part of implementation. TDD prevents this entirely:
1. Write failing test
2. Implement to pass
3. Refactor
4. THEN claim complete

## When Mocks Become Too Complex

**Warning signs:**
- Mock setup longer than test logic
- Mocking everything to make test pass
- Mocks missing methods real components have
- Test breaks when mock changes

**Consider:** Integration tests with real components are often simpler than complex mocks.

## Quick Reference

| Anti-Pattern | Fix |
|--------------|-----|
| Assert on mock elements | Test real component or unmock |
| Test-only methods in production | Move to test utilities |
| Mock without understanding | Understand deps first, mock minimally |
| Incomplete mocks | Mirror real API completely |
| Tests as afterthought | TDD — tests first |
| Over-complex mocks | Consider integration tests |

## Red Flags

- Assertion checks for `*-mock` test IDs
- Methods only called in test files
- Mock setup is >50% of test
- Test fails when you remove mock
- Can't explain why mock is needed
- Mocking "just to be safe"
