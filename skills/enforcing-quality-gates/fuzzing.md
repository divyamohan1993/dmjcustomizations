# Fuzzing

Every repo gets a fuzz lane. The question is never "is this repo security-shaped", it is "what here parses input it did not create".

## Picking targets

Rank by blast radius, not by how security-flavoured the filename sounds:

1. **Allow/deny decisions.** Auth checks, permission guards, rate limiters, path validators. Bypass = total. Most commonly missed: a passing behavior suite makes them look covered.
2. **Parsers of untrusted input.** Request bodies, JSON/YAML/XML/CSV readers, config loaders, query builders, template renderers, CLI argument handlers, filename and path handling, webhook payloads.
3. **Serialization boundaries.** Encodes then decodes; reads a format it also writes. Round-trip properties: cheap to assert, catch a lot.
4. **State machines with untrusted transitions.** Session lifecycle, payment/order status, retry logic.
5. **Arithmetic on user numbers.** Money, quotas, pagination offsets, array indices.

Parses untrusted input **and** fails open = first. That combination produces the silent bypasses.

## The four axes

Behavior suite tests cases the author imagined. Fuzz suite attacks axes the author did not think in. Cover all four; most real bypasses live in the first two.

| Axis | Attack | Example |
|---|---|---|
| **Encoding** | The consumer decodes; does the validator? | `\uXXXX` escapes, percent-encoding, double encoding, unicode normalization, homoglyphs, overlong UTF-8, null bytes |
| **Structural** | Which field does the validator actually read? | duplicate keys, a decoy key placed earlier, deep nesting, arrays where objects are expected, prototype pollution keys |
| **Lexical** | Same command, different spelling | case variation, whitespace and tab padding, absolute vs relative paths, aliases, extensions, comments injected mid-token |
| **Boundary** | Sizes and limits | empty, one byte, exactly the limit, limit plus one, megabytes, deeply recursive, negative and overflow numbers |

## Verdict classes

Three states, not two. The third keeps the suite honest.

- **must-deny / must-allow**: correctness assertions. Failure = bug.
- **gap**: documented limit of the approach. String matching cannot resolve what a shell expands at runtime, so `$(...)` substitution and variable indirection are gaps, not bugs. Assert them anyway: a change in *either* direction stays visible instead of silent.

Three tested known gaps beat three unknown ones. Writing them down stops a guard being sold as more than it is.

## Harness discipline

- **Corpus is data, never a command-line argument.** A command guard's corpus = exactly the strings it blocks; passed as arguments, the guard blocks the test run. Payloads live in a file the runner reads.
- **Seed from reality.** Best initial corpus = real production input: logged request bodies, saved fixtures, previous crash cases. Scrub secrets first.
- **Every crash becomes a committed regression case.** Fixed without a corpus entry = you get it again, and not from the same run next time.
- **Time-box, then commit the corpus.** Coverage-guided fuzzers improve indefinitely. T2 = short smoke over the committed corpus, deterministic and fast. T3 = long search; every new input it finds gets committed for T2 to keep forever.
- **Assert on invariants, not outputs.** "Never crashes", "never emits malformed JSON", "never returns allow for a command containing this token after decoding", "output always round-trips". Outputs change; invariants are the contract.
- **Structural fuzz asserts three things**: no crash, no hang (timeout, exit >= 124 = failure), no malformed output.

## Property-based vs coverage-guided

Both, different tiers.

- **Property-based** (fast-check, hypothesis, proptest): inputs from a spec you write, failures shrunk to a minimal case. Fast, deterministic enough for T2, shrinking makes failures readable.
- **Coverage-guided** (atheris, cargo-fuzz, `go test -fuzz`, Jazzer): mutates inputs, follows coverage into paths you never described. Deeper bugs, needs a time box, T3.

Start property-based on the top target: an afternoon, and it finds the boundary bugs. Add coverage-guided once the target list is stable.

## Why fuzz at all

A real fail-open security control that had passed a 13-probe behavior suite for weeks gave up 10 live bypasses on its first fuzz run (four axes, three verdict classes, structural fuzz with timeout and JSON-validity assertions, a mutation loop over dangerous command cores). A green behavior suite is not evidence against adversarial input; only a fuzz lane is.
