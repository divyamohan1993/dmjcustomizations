#!/usr/bin/env node
// Structural self-audit in ONE process (~0.1s). Exit 1 on any violation.
// Checks structure and invariants, not judgement: caps are runaway guards,
// the description bar lives in dmj:writing-skills, and content decisions
// belong to authors plus review. Three protections are mechanical here:
//   - security tokens must stay present in defending-in-depth (relocation
//     during a dedup pass must never become deletion),
//   - a skill's protection-line count may only drop with a CHANGELOG
//     "Removed" entry naming the skill (silent law deletion fails CI),
//   - the two pre-tool-guard engines must keep matching pattern tokens
//     (drift tripwire; the suites that once covered them are gone by order).
// Regenerate the protection baseline after a deliberate change:
//   node scripts/validate.js --update-baseline
'use strict';
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
const UPDATE_BASELINE = process.argv.includes('--update-baseline');
let fail = 0;
const flag = (m) => { console.log('FAIL: ' + m); fail = 1; };
const read = (p) => fs.readFileSync(path.join(root, p), 'utf8');
const strictSemver = /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$/;

const nativeFiles = [
  '.codex-plugin/plugin.json',
  '.codex/hooks.json',
  'features/codex-plugin-compatibility.feature',
  'scripts/test-hook-compatibility.mjs',
];
for (const rel of nativeFiles) if (!fs.existsSync(path.join(root, rel))) flag(`native compatibility file missing: ${rel}`);

let PV, MV, CV, CodexManifest;
try { PV = JSON.parse(read('.claude-plugin/plugin.json')).version; } catch { flag('plugin.json does not parse'); }
try { MV = JSON.parse(read('.claude-plugin/marketplace.json')).plugins[0].version; } catch { flag('marketplace.json does not parse'); }
try {
  CodexManifest = JSON.parse(read('.codex-plugin/plugin.json'));
  CV = CodexManifest.version;
  if (Object.hasOwn(CodexManifest, 'hooks')) flag('Codex plugin.json contains unsupported hooks field');
} catch { flag('Codex plugin.json does not parse'); }
for (const [label, version] of [['Claude plugin', PV], ['Claude marketplace', MV], ['Codex plugin', CV]]) {
  if (!strictSemver.test(version || '')) flag(`${label} version is not strict semver: ${version}`);
}
if (PV && MV && CV && new Set([PV, MV, CV]).size !== 1) flag(`version mismatch: claude=${PV} marketplace=${MV} codex=${CV}`);
else if (PV && MV && CV) console.log(`version parity: ${PV}`);
let changelog = '';
try {
  changelog = read('CHANGELOG.md');
  if (!changelog.includes('[' + PV + ']')) flag(`CHANGELOG.md has no [${PV}] entry`);
} catch { flag('CHANGELOG.md unreadable'); }
// Topmost slice: [Unreleased] plus the newest release section, where a
// deliberate protection removal must be recorded.
const clTop = (() => {
  const parts = changelog.split(/\n## \[/);
  return parts.slice(0, 3).join('\n## [');
})();

const DASH = /[‒–—―−‐‑]/;
const skillsDir = path.join(root, 'skills');
const skills = fs.readdirSync(skillsDir).filter(n => fs.statSync(path.join(skillsDir, n)).isDirectory());

const nativeInterface = CodexManifest?.interface;
if (!nativeInterface || typeof nativeInterface !== 'object' || Array.isArray(nativeInterface)) {
  flag('Codex plugin.json interface must be an object');
} else {
  for (const field of ['displayName', 'shortDescription', 'longDescription', 'developerName', 'category']) {
    if (typeof nativeInterface[field] !== 'string' || !nativeInterface[field].trim()) flag(`Codex interface.${field} must be a non-empty string`);
  }
  if (!Array.isArray(nativeInterface.capabilities) || nativeInterface.capabilities.length === 0 || !nativeInterface.capabilities.every((value) => typeof value === 'string' && value.trim())) {
    flag('Codex interface.capabilities must be a non-empty array of strings');
  }
  if (!Array.isArray(nativeInterface.defaultPrompt) || nativeInterface.defaultPrompt.length === 0 || !nativeInterface.defaultPrompt.every((value) => typeof value === 'string' && value.trim())) {
    flag('Codex interface.defaultPrompt must be a non-empty array of strings');
  }
}

// Protection-line metric: MUST/NEVER (exact case, word-bound) + "Iron Law".
const protCount = (s) => (s.match(/\b(MUST|NEVER)\b/g) || []).length + (s.match(/Iron Law/g) || []).length;
const BASELINE_PATH = 'scripts/protection-baseline.json';
let baseline = {};
try { baseline = JSON.parse(read(BASELINE_PATH)); } catch { if (!UPDATE_BASELINE) flag(`${BASELINE_PATH} missing or unparsable; run: node scripts/validate.js --update-baseline`); }
const newBaseline = {};

for (const n of skills) {
  const rel = `skills/${n}/SKILL.md`;
  let body;
  try { body = read(rel); } catch { flag(`${n}: missing SKILL.md`); continue; }
  const fm = body.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/);
  if (!fm) { flag(`${n}: no frontmatter`); continue; }
  const front = fm[1], content = fm[2];
  const name = (front.match(/^name:\s*(.+)$/m) || [])[1];
  if (name !== n) flag(`${n}: frontmatter name '${name}' != dir`);
  const desc = (front.match(/^description:\s*(.+)$/m) || [])[1] || '';
  const descLine = front.match(/^description:\s+([^\r\n]+)$/m);
  if (descLine && !/^['"]/.test(descLine[1].trim()) && /:\s/.test(descLine[1])) flag(`${rel}: single-line description containing ': ' must be quoted`);
  if (desc.length >= 500) flag(`${n}: description ${desc.length} chars`);
  if (DASH.test(body)) flag(`${n}: unicode dash`);
  if (/task tool/i.test(body)) flag(`${n}: forbidden 'Task tool'`);
  // word counts: total = all body words; prose = excluding fenced blocks + table rows
  let inFence = false, prose = [], total = [];
  for (const line of content.split('\n')) {
    const t = line.trim();
    total.push(line);
    if (t.startsWith('```')) { inFence = !inFence; continue; }
    if (inFence || t.startsWith('|')) continue;
    prose.push(line);
  }
  const wc = (a) => a.join(' ').split(/\s+/).filter(Boolean).length;
  const cap = n === 'using-dmj' ? 600 : 1200;
  const pw = wc(prose), tw = wc(total);
  if (pw >= cap) flag(`${n}: prose ${pw} (cap ${cap})`);
  if (tw >= 1800) flag(`${n}: total ${tw} (cap 1800)`);
  if (!/(next:|handoff|back to|dmj:[a-z][a-z-]+)/i.test(content.slice(-400))) flag(`${n}: no handoff or routing pointer at end`);

  // Protection-line ratchet: a drop needs a CHANGELOG "Removed" entry naming the skill.
  const pc = protCount(content);
  newBaseline[n] = pc;
  if (!UPDATE_BASELINE && baseline[n] !== undefined && pc < baseline[n]) {
    const recorded = /### Removed/.test(clTop) && clTop.includes(n);
    if (!recorded) flag(`${n}: protection lines dropped ${baseline[n]} -> ${pc} with no CHANGELOG "Removed" entry naming the skill`);
  }
}

// Reference files (non-SKILL.md) steer behavior too; gate them for dashes + dead vocab.
const walk = (d) => fs.readdirSync(d, { withFileTypes: true }).flatMap((e) => {
  const p = path.join(d, e.name);
  return e.isDirectory() ? walk(p) : [p];
});
for (const p of walk(skillsDir)) {
  if (!p.endsWith('.md') || path.basename(p) === 'SKILL.md') continue;
  const rel = path.relative(root, p).replace(/\\/g, '/');
  const ref = fs.readFileSync(p, 'utf8');
  if (DASH.test(ref)) flag(`${rel}: unicode dash`);
  if (/task tool/i.test(ref)) flag(`${rel}: forbidden 'Task tool'`);
}

// Security-token presence: consolidation must never become deletion. Each class
// greps positive in defending-in-depth/SKILL.md, the surviving home.
try {
  const did = read('skills/defending-in-depth/SKILL.md');
  const TOKENS = [
    [/AEGIS-256/, 'AEGIS-256'], [/ML-KEM-1024/, 'ML-KEM-1024'],
    [/ML-DSA-87/, 'ML-DSA-87'], [/SLH-DSA/, 'SLH-DSA'],
    [/argon2id/i, 'Argon2id'], [/per-record/i, 'per-record DEK'],
    [/KEK/, 'KEK wrapping'], [/hash-chain/i, 'hash-chained audit'],
    [/egress/i, 'egress allowlist'], [/hybrid/i, 'hybrid PQC'],
  ];
  for (const [re, label] of TOKENS) {
    if (!re.test(did)) flag(`defending-in-depth: security token missing: ${label}`);
  }
} catch { flag('skills/defending-in-depth/SKILL.md unreadable'); }

// The shell wrapper must invoke the one authoritative Node guard engine. The
// fixture owns the policy behavior; this tripwire catches a missing engine.
try {
  const guardSh = read('hooks/pre-tool-guard');
  const guardJs = read('hooks/pre-tool-guard.js');
  if (!guardSh.includes('node "$JS_ENGINE"')) flag('hooks/pre-tool-guard: Node engine invocation missing');
  for (const tok of ['--no-verify', '-with-lease', '--hard']) if (!guardJs.includes(tok)) flag(`hooks/pre-tool-guard.js: guard token missing: ${tok}`);
} catch { flag('pre-tool-guard engine files unreadable'); }

const rows = (read('README.md').match(/^\| [a-z]/gm) || []).length;
if (rows !== skills.length) flag(`README rows (${rows}) != skill count (${skills.length})`);

if (UPDATE_BASELINE) {
  fs.writeFileSync(path.join(root, BASELINE_PATH), JSON.stringify(newBaseline, null, 2) + '\n');
  console.log(`baseline written: ${BASELINE_PATH} (${Object.keys(newBaseline).length} skills)`);
}
if (fail) process.exit(1);
console.log(`VALIDATION PASS: ${skills.length} skills, version ${PV}`);
