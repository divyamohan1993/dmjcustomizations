# Debugging Techniques

Two techniques used inside `dmj:systematic-debugging`. Validation-at-every-layer (defense in depth) is not duplicated here: see `dmj:defending-in-depth`.

## Root-cause tracing (Phase 1, step 5)

Bugs surface deep in the call stack (git init in the wrong dir, a file written to the wrong path), so fixing where the error appears treats a symptom.

**Process:** observe the symptom, find the code directly causing it, then ask "what called this with that value?" repeatedly up the chain until you reach the source. Fix there.

```
git init fails in packages/core      <- symptom: cwd is process.cwd()
  execFileAsync('git',['init'],{cwd: projectDir})   <- projectDir = ''
    WorktreeManager.create(projectDir)
      Session.create() passed ''
        test read context.tempDir before beforeEach ran   <- ORIGIN
```

Root cause: a top-level variable read an empty value before setup populated it. Fix at the origin (make `tempDir` a getter that throws if read early), not at `git init`.

**When you cannot trace by eye, instrument before the dangerous operation:**

```typescript
async function gitInit(directory: string) {
  console.error('DEBUG git init:', { directory, cwd: process.cwd(), stack: new Error().stack });
  await execFileAsync('git', ['init'], { cwd: directory });
}
```

Use `console.error` in tests (a logger may be suppressed). Log *before* the operation, include directory/cwd/env. Capture with `npm test 2>&1 | grep 'DEBUG git init'`, then read the stack for the triggering test file/line.

**Which test pollutes shared state?** Run `find-polluter.sh` in this directory: it runs matching tests one by one, stops at the first that creates the artifact. `./find-polluter.sh '.git' 'src/**/*.test.ts'`.

## Condition-based waiting (kills flaky timing)

Arbitrary delays (`setTimeout`, `sleep`) race: green on a fast machine, red under CI load. Wait for the condition you actually care about, not a guess at how long it takes.

```typescript
// BAD: guessing
await new Promise(r => setTimeout(r, 50));
// GOOD: wait for the real condition
await waitFor(() => getResult() !== undefined, 'result ready');
```

Minimal poller (poll ~10ms, always bound with a timeout that names what it waited for):

```typescript
async function waitFor<T>(cond: () => T | undefined | null | false,
                          description: string, timeoutMs = 5000): Promise<T> {
  const start = Date.now();
  while (true) {
    const r = cond();
    if (r) return r;
    if (Date.now() - start > timeoutMs) throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    await new Promise(res => setTimeout(res, 10));
  }
}
```

Wait on the real predicate: an event in a list, a state field, a count reaching its threshold, a file existing.

Mistakes: polling every 1ms (CPU burn, use 10ms), no timeout (hangs forever), caching state outside the loop (call the getter inside for fresh data).

**When an arbitrary timeout IS correct** (testing real timed behavior, e.g. a 100ms tick): first `await` the triggering condition, then wait a duration derived from known timing, with a comment stating why. Never a bare guess.
