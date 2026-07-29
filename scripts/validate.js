#!/usr/bin/env node
// Structural self-audit in ONE process (was ~180 subprocess spawns in bash,
// ~13s on Git-Bash; this is ~0.1s). Exit 1 on any violation.
'use strict';
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
let fail = 0;
const flag = (m) => { console.log('FAIL: ' + m); fail = 1; };
const read = (p) => fs.readFileSync(path.join(root, p), 'utf8');

let PV, MV;
try { PV = JSON.parse(read('.claude-plugin/plugin.json')).version; } catch { flag('plugin.json does not parse'); }
try { MV = JSON.parse(read('.claude-plugin/marketplace.json')).plugins[0].version; } catch { flag('marketplace.json does not parse'); }
if (PV && MV && PV !== MV) flag(`version mismatch: plugin=${PV} marketplace=${MV}`);
try { if (!read('CHANGELOG.md').includes('[' + PV + ']')) flag(`CHANGELOG.md has no [${PV}] entry`); } catch { flag('CHANGELOG.md unreadable'); }

const DASH = /[‒–—―−‐‑]/;
const skillsDir = path.join(root, 'skills');
const skills = fs.readdirSync(skillsDir).filter(n => fs.statSync(path.join(skillsDir, n)).isDirectory());
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
  if (desc.length >= 500) flag(`${n}: description ${desc.length} chars`);
  if (!desc.startsWith('Use when')) flag(`${n}: description must start 'Use when'`);
  if (DASH.test(body)) flag(`${n}: unicode dash`);
  if (/task tool/i.test(body)) flag(`${n}: forbidden 'Task tool'`);
  if (/subagent/i.test(body)) flag(`${n}: forbidden 'subagent'`);
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
  if (!/(next:|handoff|back to)/i.test(content.slice(-400))) flag(`${n}: no handoff line at end`);
}

// A4: reference files (non-SKILL.md) steer behavior too; gate them for dashes + forbidden tokens.
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
  if (/subagent/i.test(ref)) flag(`${rel}: forbidden 'subagent'`);
}

const rows = (read('README.md').match(/^\| [a-z]/gm) || []).length;
if (rows !== skills.length) flag(`README rows (${rows}) != skill count (${skills.length})`);

if (fail) process.exit(1);
console.log(`VALIDATION PASS: ${skills.length} skills, version ${PV}`);
