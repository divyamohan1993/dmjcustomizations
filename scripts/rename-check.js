#!/usr/bin/env node
// Mechanical rename verifier for the release gate.
// Reads a staged diff on stdin; takes a DECLARED substitution map as args
// ("old=>new" pairs). Exit 0 ONLY if applying exactly those substitutions to
// the removed lines reproduces the added lines as a multiset, i.e. the diff is
// PRECISELY the declared rename and contains no other change. Exit 1 otherwise
// (residual real changes -> caller must fall through to the model gate).
//
// Safety: the operator must DECLARE the rename. A sneaky rule inversion
// (e.g. never->always) that is NOT in the declared map leaves residual lines
// that do not cancel, so this never false-passes a content change.
'use strict';
const pairs = process.argv.slice(2).map(a => {
  const i = a.indexOf('=>');
  if (i < 0) { console.error(`bad pair (need old=>new): ${a}`); process.exit(2); }
  return [a.slice(0, i), a.slice(i + 2)];
}).sort((x, y) => y[0].length - x[0].length); // longest old-token first

let buf = '';
process.stdin.on('data', d => buf += d);
process.stdin.on('end', () => {
  const removed = [], added = [];
  for (const line of buf.split('\n')) {
    if (line.startsWith('+++') || line.startsWith('---')) continue;
    if (line.startsWith('-')) removed.push(line.slice(1));
    else if (line.startsWith('+')) added.push(line.slice(1));
  }
  const apply = (s) => pairs.reduce((acc, [o, n]) => acc.split(o).join(n), s);
  const mapped = removed.map(apply);
  const ms = (arr) => { const m = new Map(); for (const x of arr) m.set(x, (m.get(x) || 0) + 1); return m; };
  const a = ms(mapped), b = ms(added);
  let pure = a.size === b.size;
  if (pure) for (const [k, v] of a) if (b.get(k) !== v) { pure = false; break; }
  if (pure) {
    console.log(`rename-check: PURE — diff is exactly the declared rename (${removed.length} lines), zero residual change.`);
    process.exit(0);
  }
  // Show what did not cancel, for the operator.
  const residual = [];
  for (const [k, v] of a) { const d = v - (b.get(k) || 0); for (let i = 0; i < d && k.trim(); i++) residual.push('- ' + k); }
  for (const [k, v] of b) { const d = v - (a.get(k) || 0); for (let i = 0; i < d && k.trim(); i++) residual.push('+ ' + k); }
  console.log(`rename-check: NOT pure — ${residual.length} residual line(s) beyond the declared rename:`);
  console.log(residual.slice(0, 12).join('\n'));
  process.exit(1);
});
