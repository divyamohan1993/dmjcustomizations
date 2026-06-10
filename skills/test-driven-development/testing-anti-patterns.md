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

## 1. Asserting on mock behavior

```typescript
// BAD: proves the mock exists, nothing about the component
expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
// GOOD: test real behavior
render(<Page />);                                   // do not mock the sidebar
expect(screen.getByRole('navigation')).toBeInTheDocument();
```

Gate: before asserting on any mock element, ask "real behavior or mock existence?" If existence, delete the assertion or unmock.

## 2. Test-only methods in production

```typescript
// BAD: destroy() exists only so afterEach can call it
class Session { async destroy() { await this._wm?.destroyWorkspace(this.id); } }
// GOOD: keep Session stateless; cleanup lives in test-utils
export async function cleanupSession(s: Session) {
  const w = s.getWorkspaceInfo();
  if (w) await workspaceManager.destroyWorkspace(w.id);
}
```

Gate: before adding a method to a production class, ask "only used by tests?" (yes, move it out) and "does this class own this resource's lifecycle?" (no, wrong class).

## 3. Mocking without understanding

```typescript
// BAD: the mock removed the config write the test depends on, so the duplicate is never detected
vi.mock('ToolCatalog', () => ({ discoverAndCacheTools: vi.fn().mockResolvedValue(undefined) }));
await addServer(config);
await addServer(config);   // should throw, silently does not
// GOOD: mock only the slow external part, preserve the behavior under test
vi.mock('MCPServerManager');  // just the slow server startup
```

Gate: before mocking, ask what side effects the real method has and whether the test depends on any. If so, mock one level lower (the actual slow/external call), not the high-level method. Unsure what the test needs? Run against the real implementation first, observe, then add minimal mocking. Red flag: "I'll mock this to be safe."

## 4. Incomplete mocks

```typescript
// BAD: omits metadata that downstream code reads -> passes here, breaks in integration
const res = { status: 'success', data: { userId: '123' } };
// GOOD: mirror the real schema completely
const res = { status: 'success', data: { userId: '123', name: 'Alice' },
              metadata: { requestId: 'req-789', timestamp: 1234567890 } };
```

Iron rule: mock the COMPLETE structure as it exists in reality, not just the fields this test reads. Partial mocks fail silently when other code depends on omitted fields. Uncertain? Include every documented field.

## 5. Tests as afterthought

"Implementation complete, no tests, ready for testing" is not complete. Testing is part of implementation. TDD makes this structurally impossible: the test came first.

## The bottom line

Mocks isolate; they are not the thing under test. If TDD reveals you are testing mock behavior, you added mocks without first watching the test fail against real code. Test real behavior, or question why you mock at all. Back to discipline: `dmjcustomizations:test-driven-development`.
