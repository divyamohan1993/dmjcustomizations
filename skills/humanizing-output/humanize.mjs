#!/usr/bin/env node
// humanize: rewrite flagged prose to plain human language, show a diff, apply on
// approval. Needs the `claude` CLI; degrades to a report if it is missing.
// Usage: node humanize.mjs <file...>   (prose files: md, mdx, txt)
'use strict';
import { readFileSync, writeFileSync, unlinkSync, existsSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { createInterface } from 'node:readline/promises';
import { stdin, stdout } from 'node:process';

const files = process.argv.slice(2)
  .filter((f) => /\.(md|mdx|markdown|txt)$/i.test(f) && existsSync(f));
if (!files.length) { console.log('humanize: pass prose file(s) to rewrite.'); process.exit(0); }

try { execFileSync('claude', ['--version'], { stdio: 'ignore' }); }
catch {
  console.log('humanize: `claude` CLI not found. Run humanize-guard.mjs and fix by hand.');
  process.exit(0);
}

const PROMPT = [
  'Rewrite the text below so it reads like a careful human engineer wrote it.',
  'Remove AI-tell words (delve, robust, seamless, leverage, utilize, tapestry, boasts,',
  '"it is worth noting", "testament to", underscores, moreover, elevate, unlock, myriad,',
  'plethora, pivotal, foster, and similar).',
  'Remove every em and en dash; use commas, colons, semicolons, or periods instead.',
  'Keep the meaning, markdown structure, code blocks, links, numbers, and technical',
  'accuracy EXACTLY. Do not add or drop facts. Output ONLY the rewritten text.',
].join(' ');

const rl = createInterface({ input: stdin, output: stdout });
for (const f of files) {
  const orig = readFileSync(f, 'utf8');
  let out;
  try {
    out = execFileSync('claude', ['-p', '--model', 'sonnet'],
      { input: PROMPT + '\n\n---\n' + orig, maxBuffer: 1 << 24 }).toString();
  } catch (e) { console.log(`humanize: claude failed on ${f}: ${e.message}`); continue; }
  out = out.replace(/\s+$/, '') + '\n';
  if (out.trim() === orig.trim()) { console.log(`humanize: ${f} already clean.`); continue; }
  const tmp = f + '.humanized';
  writeFileSync(tmp, out);
  try { execFileSync('git', ['--no-pager', 'diff', '--no-index', '--', f, tmp], { stdio: 'inherit' }); } catch {}
  const ans = (await rl.question(`Apply humanized ${f}? [y/N] `)).trim().toLowerCase();
  if (ans === 'y' || ans === 'yes') { writeFileSync(f, out); console.log(`  applied ${f}`); }
  else console.log(`  skipped ${f}`);
  try { unlinkSync(tmp); } catch {}
}
rl.close();
