# Testing Anti-Patterns

Load when writing/changing tests, adding mocks, or tempted to add test-only methods to production code.

**Core principle:** test what the code does, not what the mocks do. Strict TDD prevents every pattern below: if watching the test fail against real code first feels impossible, that is the anti-pattern announcing itself.

## Iron Laws

```
1. NEVER assert on mock behavior
2. NEVER add test-only methods to production classes
3. NEVER mock without understanding the dependency you are replacing
```

## Quick reference

| Anti-pattern | Smell | Fix |
|--------------|-------|-----|
| Assert on mock | assertion checks for `*-mock` id | test the real component, or do not mock it |
| Test-only production method | method called only from test files | move it to a test utility |
| Mock without understanding | mocked a method whose side effect the test needed | run with the real impl first, then mock minimally at the right level |
| Incomplete mock | mock has only the fields you happened to use | mirror the real response schema completely |
| Tests as afterthought | "implementation done, tests next" | tests first; you cannot claim done without them |
| Over-complex mock | mock setup is >50% of the test | use real components in an integration test |

## Gates before you write it

- Asserting on a mock element: "real behavior, or mock existence?" Existence means delete the assertion or unmock it.
- Adding a method to a production class: "called only by tests?" (move it out) and "does this class own this resource's lifecycle?" (no means wrong class).
- Mocking anything: name the real method's side effects and whether the test depends on any. If it does, mock one level lower, at the actual slow or external call, never the high-level method. Unsure what the test needs? Run against the real implementation first, observe, then mock minimally. "I'll mock this to be safe" is the red flag.

## Incomplete mock

```typescript
// BAD: omits metadata that downstream code reads -> passes here, breaks in integration
const res = { status: 'success', data: { userId: '123' } };
// GOOD: mirror the real schema completely
const res = { status: 'success', data: { userId: '123', name: 'Alice' },
              metadata: { requestId: 'req-789', timestamp: 1234567890 } };
```

Iron rule: mock the COMPLETE structure as it exists in reality, not just the fields this test reads. `metadata` is there because downstream code reads it, not because this test does. Partial mocks fail silently; uncertain means include every documented field.

## The bottom line

Mocks isolate; they are not the thing under test. If TDD reveals you are testing mock behavior, you added mocks without first watching the test fail against real code. Test real behavior, or question why you mock at all. Back to discipline: `dmj:test-driven-development`.
