#!/usr/bin/env node
'use strict';

const deny = (reason) => {
  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'deny',
      permissionDecisionReason: reason,
    },
  }) + '\n');
  process.exit(0);
};

let input;
try {
  input = require('node:fs').readFileSync(0, 'utf8');
} catch {
  deny('dmj guard: PreToolUse input could not be read. Retry the tool call.');
}
if (input.trim() === '') deny('dmj guard: PreToolUse input is empty. Retry the tool call.');

let payload;
try {
  payload = JSON.parse(input);
} catch {
  deny('dmj guard: PreToolUse input is malformed JSON. Retry the tool call.');
}

const command = payload?.tool_input?.command;
if (typeof command !== 'string' || command.length === 0) {
  deny('dmj guard: tool_input.command is required. Retry the tool call.');
}

const git = '\\b[gG][iI][tT]\\b';
if (new RegExp(`${git}[^|;&]*--no-verify\\b`).test(command)) {
  deny('dmj guard: --no-verify skips hooks; fix the failing hook instead.');
}
if (new RegExp(`${git}[^|;&]*\\bpush\\b[^|;&]*(?:--force(?!-with-lease)\\b|\\s-f\\b)`).test(command)) {
  deny('dmj guard: force push rewrites shared history; use --force-with-lease if truly needed.');
}
if (new RegExp(`${git}[^|;&]*\\breset\\b[^|;&]*--hard\\b[^|;&]*(?:origin\\/|@\\{u\\})`).test(command)) {
  deny('dmj guard: reset --hard to a remote ref destroys local work; stash or branch first.');
}
