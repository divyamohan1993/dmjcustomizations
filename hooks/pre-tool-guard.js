#!/usr/bin/env node
'use strict';
// Node engine for hooks/pre-tool-guard: a faithful port of the single perl
// pass, selected only when perl is absent (Ubuntu cloud VMs ship node, not
// perl). The three properties adversarial fuzzing forced, preserved exactly:
//   1. Extraction scoped to tool_input (a decoy "command" key earlier in the
//      payload must lose).
//   2. Single left-to-right unescape pass: \uXXXX, then \n \t \r to space,
//      then \X to X. A decoded backslash is never re-read as an escape.
//   3. Program name matches case-insensitively; flags stay case-sensitive.
let input = '';
try { input = require('fs').readFileSync(0, 'utf8'); } catch { process.exit(0); }
const scopeMatch = input.match(/"tool_input"\s*:\s*\{([\s\S]*)$/);
const scope = scopeMatch ? scopeMatch[1] : input;
const cmdMatch = scope.match(/"command"\s*:\s*"((?:[^"\\]|\\[\s\S])*)"/);
if (!cmdMatch) process.exit(0);
// [^\n] mirrors perl's dot without /s so an escaped literal newline behaves
// identically in both engines.
const c = cmdMatch[1].replace(/\\(u([0-9a-fA-F]{4})|[^\n])/g, (m, g1, g2) =>
  g2 !== undefined ? String.fromCharCode(parseInt(g2, 16)) : (/^[ntr]$/.test(g1) ? ' ' : g1));
const GIT = '\\b(?:[gG][iI][tT])\\b';
const out = [];
if (new RegExp(GIT + '[^|;&]*--no-verify\\b').test(c)) out.push('noverify');
if (new RegExp(GIT + '[^|;&]*\\bpush\\b[^|;&]*(?:--force(?!-with-lease)\\b|\\s-f\\b)').test(c)) out.push('forcepush');
if (new RegExp(GIT + '[^|;&]*\\breset\\b[^|;&]*--hard\\b[^|;&]*(?:origin\\/|@\\{u\\})').test(c)) out.push('hardreset');
if (out.length) process.stdout.write(out.join('\n') + '\n');
process.exit(0);
