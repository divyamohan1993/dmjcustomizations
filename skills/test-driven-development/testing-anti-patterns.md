# Testing Anti-Patterns

Load when: writing/changing tests, adding mocks, tempted to add test-only methods to production code.

**Core principle:** test what the code does, not what the mocks do. Strict TDD prevents every pattern below: if watching it fail against real code first feels impossible, that IS the anti-pattern announcing itself.

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
| Tests as afterthought | "implementation done, tests next" | tests first; no done-claim without them |
| Over-complex mock | mock setup is >50% of the test | use real components in an integration test |

## Gates before you write it

- Asserting on a mock element: real behavior, or mock existence? Existence -> delete the assertion or unmock it.
- Adding a method to a production class: called only by tests? (move it out) Does this class own this resource's lifecycle? (no = wrong class)
- Mocking anything: name the real method's side effects + whether the test depends on any. It does -> mock one level lower, at the actual slow or external call, never the high-level method. Unsure? Run against the real implementation, observe, then mock minimally. "I'll mock this to be safe" = red flag.

## Incomplete mock

```typescript
// BAD: omits metadata that downstream code reads -> passes here, breaks in integration
const res = { status: 'success', data: { userId: '123' } };
// GOOD: mirror the real schema completely
const res = { status: 'success', data: { userId: '123', name: 'Alice' },
              metadata: { requestId: 'req-789', timestamp: 1234567890 } };
```

Iron rule: mock the COMPLETE real structure, not just the fields this test reads. `metadata` is there because downstream code reads it, not this test. Partial mocks fail silently; uncertain = include every documented field.

## The bottom line

Mocks isolate; they are not the thing under test. Testing mock behavior = mocks added without first watching the test fail against real code. Test real behavior, or question why you mock at all. Back to discipline: `dmj:test-driven-development`.
