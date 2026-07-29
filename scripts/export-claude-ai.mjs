#!/usr/bin/env node
// Export every skill as a claude.ai-uploadable zip. claude.ai Chat loads no
// plugins (Cowork and Code do); its only path is a zip wrapping one skill
// directory, uploaded under Settings > Capabilities. That surface caps
// description at 200 chars, accepts only name + description frontmatter, and
// knows nothing of the dmj: namespace, so this rewrites per-surface instead of
// degrading the plugin's own files. Output: dist/claude-ai/<skill>.zip
'use strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const outRoot = path.join(root, 'dist', 'claude-ai');
fs.rmSync(outRoot, { recursive: true, force: true });
fs.mkdirSync(outRoot, { recursive: true });

const clip = (d) => {
  if (d.length <= 200) return d;
  let cut = d.slice(0, 200);
  const stop = Math.max(cut.lastIndexOf('. '), cut.lastIndexOf(': '), cut.lastIndexOf(', '));
  cut = stop > 80 ? cut.slice(0, stop) : cut.slice(0, 197);
  return cut.replace(/[,:;.\s]+$/, '') + '.';
};

const zip = (dir, zipPath) => {
  const r = process.platform === 'win32'
    ? spawnSync('powershell', ['-NoProfile', '-Command',
        `Compress-Archive -Path '${dir}' -DestinationPath '${zipPath}' -Force`], { stdio: 'inherit' })
    : spawnSync('zip', ['-qr', zipPath, path.basename(dir)], { cwd: path.dirname(dir), stdio: 'inherit' });
  return r.status === 0;
};

let n = 0;
const over = [];
for (const name of fs.readdirSync(path.join(root, 'skills')).sort()) {
  const srcDir = path.join(root, 'skills', name);
  if (!fs.statSync(srcDir).isDirectory()) continue;
  const dstDir = path.join(outRoot, name);
  const copy = (src, dst) => {
    fs.mkdirSync(dst, { recursive: true });
    for (const f of fs.readdirSync(src)) {
      const s = path.join(src, f);
      if (fs.statSync(s).isDirectory()) { copy(s, path.join(dst, f)); continue; }
      let text = fs.readFileSync(s, 'utf8');
      if (f === 'SKILL.md' && src === srcDir) {
        const m = text.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
        if (!m) { console.error('no frontmatter: ' + name); process.exit(1); }
        const desc = (m[1].match(/^description:\s*(.+)$/m) || [])[1] || '';
        if (desc.length > 200) over.push(name);
        text = `---\nname: ${name}\ndescription: ${clip(desc)}\n---\n` + m[2];
      }
      text = text.replace(/dmj:([a-z][a-z-]*)/g, 'the $1 skill');
      fs.writeFileSync(path.join(dst, f), text);
    }
  };
  copy(srcDir, dstDir);
  if (!zip(dstDir, path.join(outRoot, name + '.zip'))) { console.error('zip failed: ' + name); process.exit(1); }
  n++;
}
console.log(`exported ${n} skills to dist/claude-ai/*.zip (upload at claude.ai Settings > Capabilities)`);
if (over.length) console.log(`descriptions clipped to 200 chars for this surface: ${over.join(', ')}`);
console.log('note: claude.ai Chat has no repo, git, or agent-team tools; orchestration skills act as advisory guidance there.');
