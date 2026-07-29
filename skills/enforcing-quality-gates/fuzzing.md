# Fuzzing

Every repo gets a fuzz lane. The question is never "is this repo security-shaped", it is "what in this repo parses input it did not create".

## Picking targets

Rank by blast radius, not by how security-flavoured the filename sounds. In order:

1. **Anything that makes an allow or deny decision.** Auth checks, permission guards, rate limiters, path validators. A bypass here is total, and these are the most commonly missed, because a passing behavior suite makes them look covered.
2. **Parsers of untrusted input.** Request bodies, JSON/YAML/XML/CSV readers, config loaders, query builders, template renderers, CLI argument handlers, filename and path handling, webhook payloads.
3. **Serialization boundaries.** Anything that encodes then decodes, or that reads a format it also writes. Round-trip properties are cheap to assert and catch a lot.
4. **State machines with untrusted transitions.** Session lifecycle, payment/order status, retry logic.
5. **Anything doing arithmetic on user numbers.** Money, quotas, pagination offsets, array indices.

A target that both parses untrusted input **and** fails open goes first: that combination is what produces silent bypasses.

## The four axes

A behavior suite tests the cases the author imagined; a fuzz suite attacks the axes the author did not think in. Cover all four; most real bypasses live in the first two.

| Axis | Attack | Example |
|---|---|---|
| **Encoding** | The consumer decodes; does the validator? | `\uXXXX` escapes, percent-encoding, double encoding, unicode normalization, homoglyphs, overlong UTF-8, null bytes |
| **Structural** | Which field does the validator actually read? | duplicate keys, a decoy key placed earlier, deep nesting, arrays where objects are expected, prototype pollution keys |
| **Lexical** | Same command, different spelling | case variation, whitespace and tab padding, absolute vs relative paths, aliases, extensions, comments injected mid-token |
| **Boundary** | Sizes and limits | empty, one byte, exactly the limit, limit plus one, megabytes, deeply recursive, negative and overflow numbers |

## Verdict classes

Three states, not two. The third is what keeps the suite honest.

- **must-deny / must-allow**: correctness assertions. A failure is a bug.
- **gap**: a documented limit of the approach. String matching cannot resolve what a shell will expand at runtime, so `$(...)` substitution and variable indirection are gaps, not bugs. Assert them anyway, so that a change in *either* direction is visible instead of silent.

A control with three known gaps that are tested is safer than one with three unknown gaps, and writing them down is what stops a guard from being sold as more than it is.

## Harness discipline

- **Corpus is data, never a command-line argument.** A fuzz corpus for a command guard contains exactly the strings that guard blocks. Pass them as arguments and the guard blocks the test run. Keep payloads in a file the runner reads.
- **Seed from reality.** Best initial corpus is real production input: logged request bodies, saved fixtures, previous crash cases. Scrub secrets first.
- **Every crash becomes a committed regression case.** A fuzz finding fixed without a corpus entry is a finding you will get again, and the next time it will not be found by the same run.
- **Time-box, then commit the corpus.** Coverage-guided fuzzers improve indefinitely. T2 runs a short smoke over the committed corpus so it is deterministic and fast; T3 runs the long search and any new input it finds gets committed for T2 to keep forever.
- **Assert on invariants, not outputs.** "Never crashes", "never emits malformed JSON", "never returns allow for a command containing this token after decoding", "output always round-trips". Outputs change; invariants are the contract.
- **Structural fuzz asserts three things**: does not crash, does not hang (use a timeout, treat exit >= 124 as failure), and does not emit malformed output.

## Property-based vs coverage-guided

Both, in different tiers.

- **Property-based** (fast-check, hypothesis, proptest) generates inputs from a spec you write and shrinks failures to a minimal case. Fast, deterministic enough for T2, and the shrinking makes failures readable.
- **Coverage-guided** (atheris, cargo-fuzz, `go test -fuzz`, Jazzer) mutates inputs and follows code coverage into paths you never described. Finds deeper bugs, needs a time box, belongs in T3.

Start with property-based on the top target. It costs an afternoon and finds the boundary bugs. Add coverage-guided once the target list is stable.

## Why fuzz at all

A real fail-open security control that had passed a 13-probe behavior suite for weeks gave up 10 live bypasses on its first fuzz run (four axes, three verdict classes, structural fuzz with timeout and JSON-validity assertions, a mutation loop over dangerous command cores). A green behavior suite is not evidence against adversarial input; only a fuzz lane is.
