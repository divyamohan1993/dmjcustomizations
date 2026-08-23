#!/usr/bin/env node
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const root = path.resolve(import.meta.dirname, '..');
const failures = [];
const pass = [];
const fail = (message) => failures.push(message);
const ok = (message) => pass.push(message);
const exists = (relative) => fs.existsSync(path.join(root, relative));
const read = (relative) => fs.readFileSync(path.join(root, relative), 'utf8');
const readJson = (relative) => {
  try {
    return JSON.parse(read(relative));
  } catch {
    fail(`invalid JSON: ${relative}`);
    return null;
  }
};
const equal = (actual, expected, message) => {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) fail(message);
  else ok(message);
};
const strictSemver = /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$/;

const featureScenarios = [
  'Native manifests expose exactly the supported events',
  'Windows and POSIX commands route to shared hooks',
  'Shared hooks preserve valid behavior and deny unsafe input',
  'Runner and Claude surface integrity are checked',
];
const featureText = read('features/codex-plugin-compatibility.feature');
for (const scenario of featureScenarios) {
  if (!featureText.includes(`Scenario: ${scenario}`)) fail(`feature scenario is not bound: ${scenario}`);
  else ok(`feature scenario bound: ${scenario}`);
}

const guardSource = read('hooks/pre-tool-guard');
const fixtureSource = read('scripts/test-hook-compatibility.mjs');
const sessionSource = read('hooks/session-start');
const qgateSource = read('qgate.sh');
const installerSource = read('skills/enforcing-quality-gates/install-gate.sh');
const fuzzSource = read('scripts/fuzz-hooks.sh');
const workflowSource = read('.github/workflows/qgate.yml');
if (!fixtureSource.includes('if (result.status === null)')) fail('fixture process helper must fail null child status');
if (/\bcat\b/.test(guardSource) || /\|\s*node\b/.test(guardSource)) fail('pre-tool-guard must pass inherited stdin directly to Node');
const nodeCheckAt = guardSource.indexOf('command -v node');
const stdinReadAt = guardSource.search(/\bINPUT\s*=|exec\s+0</);
if (nodeCheckAt < 0 || (stdinReadAt >= 0 && nodeCheckAt > stdinReadAt)) fail('pre-tool-guard must check Node and engine before reading stdin');
if (!/\/dev\/null/.test(sessionSource)) fail('session-start background update must detach stdin');
if (!/lock/i.test(sessionSource) || !/mv\b/.test(sessionSource)) fail('session-start update must use an atomic lock and notice rename');
if (!/timeout\b|LANE_TIMEOUT/.test(qgateSource)) fail('qgate lanes must enforce a per-lane timeout');
if (!/git ls-files --cached --others --exclude-standard/.test(qgateSource) || !/git ls-files --cached --others --exclude-standard/.test(installerSource)) {
  fail('qgate file enumeration must include tracked and non-ignored untracked files');
}
if (!/timeout\b|FUZZ_CASE_TIMEOUT/.test(fuzzSource)) fail('hook fuzz cases must have a per-case timeout');
if (!/bats/.test(workflowSource) || !/shellcheck/.test(workflowSource)) fail('qgate workflow must provision wired shell tools');

// This hash and semantic snapshot are the Claude hook baseline. The native
// compatibility change must not edit hooks/hooks.json.
const CLAUDE_HOOKS_SHA256 = 'f69cdfaf96a6b103e50da2b8770a28cb88f84e4d4b0d85fd4cc86e5f216ab1b2';
const CLAUDE_HOOKS_SEMANTIC = {
  hooks: {
    SessionStart: [{
      matcher: 'startup|clear|compact',
      hooks: [{
        type: 'command',
        command: '"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" session-start',
        async: false,
      }],
    }],
    PreToolUse: [{
      matcher: 'Bash|PowerShell',
      hooks: [{
        type: 'command',
        command: '"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" pre-tool-guard',
        timeout: 10,
      }],
    }],
  },
};

const required = ['.codex-plugin/plugin.json', '.codex/hooks.json'];
for (const relative of required) {
  if (!exists(relative)) fail(`missing ${relative}`);
}
if (failures.length) {
  for (const message of failures) console.log(`FAIL: ${message}`);
  process.exit(1);
}

const codexPlugin = readJson('.codex-plugin/plugin.json');
const codexHooks = readJson('.codex/hooks.json');
const claudePlugin = readJson('.claude-plugin/plugin.json');
const marketplace = readJson('.claude-plugin/marketplace.json');

if (codexPlugin) {
  for (const field of ['name', 'description', 'author', 'homepage', 'repository', 'license', 'keywords']) {
    if (!codexPlugin[field]) fail(`Codex metadata missing real field: ${field}`);
  }
  if (codexPlugin.name !== 'dmj') fail('Codex metadata name is not dmj');
  if (!strictSemver.test(codexPlugin.version || '')) fail(`Codex version is not strict semver: ${codexPlugin.version}`);
  if (Object.hasOwn(codexPlugin, 'hooks')) fail('Codex plugin metadata contains unsupported hooks field');
}
if (claudePlugin && marketplace && codexPlugin) {
  const versions = [codexPlugin.version, claudePlugin.version, marketplace.plugins?.[0]?.version];
  if (versions.some((version) => !strictSemver.test(version || ''))) fail(`version is not strict semver: ${versions.join(', ')}`);
  if (new Set(versions).size !== 1) fail(`version mismatch: ${versions.join(', ')}`);
  else ok(`version parity ${versions[0]}`);
}

const nativeHooks = codexHooks?.hooks;
if (!nativeHooks || typeof nativeHooks !== 'object' || Array.isArray(nativeHooks)) {
  fail('Codex hooks manifest has no hooks object');
} else {
  const events = Object.keys(nativeHooks);
  equal(events, ['SessionStart', 'PreToolUse'], 'native event count and order');
  for (const forbidden of ['UserPromptSubmit', 'PostToolUse']) {
    if (Object.hasOwn(nativeHooks, forbidden)) fail(`forbidden native event: ${forbidden}`);
  }
  const expected = {
    SessionStart: { matcher: 'startup|clear|compact', script: 'session-start' },
    PreToolUse: { matcher: 'Bash|PowerShell', script: 'pre-tool-guard' },
  };
  for (const [event, route] of Object.entries(expected)) {
    const entries = nativeHooks[event];
    if (!Array.isArray(entries) || entries.length !== 1) {
      fail(`${event} must have exactly one matcher`);
      continue;
    }
    if (entries[0].matcher !== route.matcher) fail(`${event} matcher drift`);
    const hooks = entries[0].hooks;
    if (!Array.isArray(hooks) || hooks.length !== 1) {
      fail(`${event} must have exactly one command hook`);
      continue;
    }
    const hook = hooks[0];
    const expectedPosix = `"\${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" ${route.script}`;
    if (hook.type !== 'command') fail(`${event} native hook type is not command`);
    if (hook.command !== expectedPosix) fail(`${event} command drift: ${hook.command}`);
    const expectedNativeWindows = String.raw`cmd.exe /c ""%CLAUDE_PLUGIN_ROOT%\hooks\run-hook.cmd" ${route.script}"`;
    if (hook.commandWindows !== expectedNativeWindows) fail(`${event} commandWindows drift: ${hook.commandWindows}`);
    if (!String(hook.command).includes('CLAUDE_PLUGIN_ROOT') || !String(hook.commandWindows).includes('CLAUDE_PLUGIN_ROOT')) {
      fail(`${event} route does not preserve CLAUDE_PLUGIN_ROOT`);
    }
    if (!String(hook.command).endsWith(` ${route.script}`) || !String(hook.commandWindows).endsWith(` ${route.script}"`)) {
      fail(`${event} route does not use the shared ${route.script} entry point`);
    }
  }
}

if (exists('hooks/hooks.json')) {
  const claudeBytes = fs.readFileSync(path.join(root, 'hooks/hooks.json'));
  const hash = crypto.createHash('sha256').update(claudeBytes).digest('hex');
  if (hash !== CLAUDE_HOOKS_SHA256) fail(`Claude hook manifest hash drift: ${hash}`);
  else ok('Claude hook manifest hash preserved');
  equal(JSON.parse(claudeBytes.toString('utf8')), CLAUDE_HOOKS_SEMANTIC, 'Claude hook manifest semantic snapshot');
}

const runner = path.join(root, 'hooks', 'run-hook.cmd');
const CHILD_TIMEOUT_MS = 30000;
const shellEnv = {
  ...process.env,
  CLAUDE_PLUGIN_ROOT: root,
  CLAUDE_PLUGIN_DATA: fs.mkdtempSync(path.join(os.tmpdir(), 'dmj-data-')),
};
const runProcess = (label, file, args, options) => {
  const started = Date.now();
  let result;
  try {
    result = spawnSync(file, args, {
      ...options,
      encoding: 'utf8',
      timeout: CHILD_TIMEOUT_MS,
      windowsHide: true,
    });
  } catch (error) {
    fail(`${label}: ${error.message} after ${Date.now() - started}ms`);
    return { status: null, stdout: '', stderr: '', error };
  }
  if (result.error) fail(`${label}: ${result.error.message} after ${Date.now() - started}ms`);
  if (result.status === null && !result.error) fail(`${label}: child returned null status after ${Date.now() - started}ms`);
  return result;
};
const trustedBash = () => {
  const candidates = process.platform === 'win32'
    ? ['C:\\Program Files\\Git\\bin\\bash.exe', 'C:\\Program Files (x86)\\Git\\bin\\bash.exe']
    : ['/usr/bin/bash', '/bin/bash'];
  const selected = candidates.find((candidate) => fs.existsSync(candidate));
  if (!selected) fail('trusted Git Bash was not found');
  return selected;
};
const quoteWindowsArg = (value) => `"${String(value).replaceAll('"', '""')}"`;
const runRunner = (workingRoot, ...args) => {
  const input = typeof args.at(-1) === 'string' && args.length > 1 && args.at(-1).startsWith('{') ? args.pop() : '';
  const target = path.join(workingRoot, 'hooks', 'run-hook.cmd');
  const env = { ...shellEnv, CLAUDE_PLUGIN_ROOT: workingRoot };
  if (process.platform === 'win32') {
    const command = ['call', quoteWindowsArg(target), ...args.map(quoteWindowsArg)].join(' ');
    return runProcess(`runner:${args[0]}`, process.env.ComSpec || 'cmd.exe', ['/d', '/c', command], {
      cwd: workingRoot,
      env,
      input,
      windowsVerbatimArguments: true,
    });
  }
  return runProcess(`runner:${args[0]}`, trustedBash(), [target, ...args], { cwd: workingRoot, env, input });
};
const runRunnerBash = (workingRoot, ...args) => {
  const input = typeof args.at(-1) === 'string' && args.length > 1 && args.at(-1).startsWith('{') ? args.pop() : '';
  const target = path.join(workingRoot, 'hooks', 'run-hook.cmd');
  const bash = trustedBash();
  if (!bash) return { status: null, stdout: '', stderr: '' };
  return runProcess(`runner-bash:${args[0]}`, bash, [target, ...args], {
    cwd: workingRoot,
    env: { ...shellEnv, CLAUDE_PLUGIN_ROOT: workingRoot },
    input,
  });
};
const runNodeGuard = (input, extraEnv = {}, workingRoot = root) => runProcess(
  'guard-node',
  process.execPath,
  [path.join(workingRoot, 'hooks', 'pre-tool-guard.js')],
  { cwd: workingRoot, env: { ...shellEnv, CLAUDE_PLUGIN_ROOT: workingRoot, ...extraEnv }, input },
);
const runShellGuard = (input, extraEnv = {}, workingRoot = root) => {
  const bash = trustedBash();
  if (!bash) return { status: null, stdout: '', stderr: '' };
  return runProcess(
    'guard-shell',
    bash,
    [path.join(workingRoot, 'hooks', 'pre-tool-guard')],
    { cwd: workingRoot, env: { ...shellEnv, CLAUDE_PLUGIN_ROOT: workingRoot, ...extraEnv }, input },
  );
};

const routeRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'dmj route '));
fs.mkdirSync(path.join(routeRoot, 'hooks'));
for (const file of ['run-hook.cmd', 'pre-tool-guard', 'pre-tool-guard.js']) {
  fs.copyFileSync(path.join(root, 'hooks', file), path.join(routeRoot, 'hooks', file));
}
const routeInput = '{"tool_name":"Bash","tool_input":{"command":"git status"}}';
const routeHook = codexHooks.hooks.PreToolUse[0].hooks[0];
const expandedPosixRoute = routeHook.command.replaceAll('${CLAUDE_PLUGIN_ROOT}', routeRoot);
const expandedWindowsRoute = routeHook.commandWindows.replaceAll('%CLAUDE_PLUGIN_ROOT%', routeRoot);
const posixMatch = expandedPosixRoute.match(/^"(.+)" ([^\s]+)$/);
const windowsMatch = expandedWindowsRoute.match(/^cmd\.exe\s+\/c\s+(.+)$/i);
if (!posixMatch || !posixMatch[1].startsWith(routeRoot)) fail('expanded POSIX manifest route is not executable');
if (!windowsMatch || !windowsMatch[1].includes(routeRoot)) fail('expanded Windows manifest route is not executable');
if (posixMatch) {
  const result = runProcess('manifest-posix-route', trustedBash(), [posixMatch[1], posixMatch[2]], {
    cwd: routeRoot,
    env: { ...shellEnv, CLAUDE_PLUGIN_ROOT: routeRoot },
    input: routeInput,
  });
  if (result.error || result.status === null) fail('manifest POSIX route did not start');
  else if (result.status !== 0 || result.stdout !== '') fail('manifest POSIX route did not allow harmless input');
  else ok('manifest POSIX route executed');
}
if (windowsMatch) {
  const result = runProcess('manifest-windows-route', process.env.ComSpec || 'cmd.exe', ['/d', '/c', windowsMatch[1]], {
    cwd: routeRoot,
    env: { ...shellEnv, CLAUDE_PLUGIN_ROOT: routeRoot },
    input: routeInput,
    windowsVerbatimArguments: true,
  });
  if (result.error || result.status === null) fail('manifest Windows route did not start');
  else if (result.status !== 0 || result.stdout !== '') fail('manifest Windows route did not allow harmless input');
  else ok('manifest Windows route executed');
}

const session = runRunner(root, 'session-start');
if (session.status !== 0) fail(`SessionStart runner exit ${session.status}: ${session.stderr.trim()}`);
else {
  try {
    const payload = JSON.parse(session.stdout);
    if (payload.hookSpecificOutput?.hookEventName !== 'SessionStart') fail('SessionStart JSON event mismatch');
    if (typeof payload.hookSpecificOutput?.additionalContext !== 'string' || !payload.hookSpecificOutput.additionalContext.includes('<dmj>')) {
      fail('SessionStart JSON context missing');
    } else ok('SessionStart output is valid JSON');
  } catch {
    fail('SessionStart output is not valid JSON');
  }
}

const runGuard = (input, extraEnv = {}, workingRoot = root) => runNodeGuard(input, extraEnv, workingRoot);
const assertEmptyAllow = (input) => {
  const result = runGuard(input);
  if (result.error || result.status === null) return;
  if (result.status !== 0 || result.stdout !== '') fail(`harmless input was not allowed empty: status=${result.status} output=${JSON.stringify(result.stdout)}`);
  else ok('harmless PreToolUse input allowed');
};
const assertDeny = (label, input, workingRoot = root, extraEnv = {}, execute = runGuard) => {
  const result = execute(input, extraEnv, workingRoot);
  if (result.error || result.status === null) return;
  if (result.status !== 0) {
    fail(`${label} returned exit ${result.status}`);
    return;
  }
  try {
    const payload = JSON.parse(result.stdout);
    const output = payload.hookSpecificOutput;
    if (output?.hookEventName !== 'PreToolUse' || output.permissionDecision !== 'deny' || typeof output.permissionDecisionReason !== 'string') {
      fail(`${label} did not return a valid deny JSON`);
    } else ok(`${label} denied with valid JSON`);
  } catch {
    fail(`${label} output is not valid JSON: ${JSON.stringify(result.stdout)}`);
  }
};

assertEmptyAllow('{"tool_name":"Bash","tool_input":{"command":"git status"}}');
assertDeny('no-verify', '{"tool_name":"Bash","tool_input":{"command":"git commit --no-verify -m x"}}');
assertDeny('force push', '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}');
assertDeny('hard reset', '{"tool_name":"Bash","tool_input":{"command":"git reset --hard origin/main"}}');
assertDeny('environment bypass values', '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}', root, { DMJ_ALLOW: '1', DMJ_GUARD_ENGINE: 'perl' }, runShellGuard);
assertDeny('empty input', '');
assertDeny('malformed input', '{not-json');
assertDeny('missing command', '{"tool_name":"Bash","tool_input":{}}');

const invalid = runRunnerBash(root, 'not-an-allowed-hook');
if (invalid.status === 0) fail('invalid runner script unexpectedly succeeded');
else ok('invalid runner script failed');
const extra = runRunnerBash(root, 'session-start', 'extra');
if (extra.status === 0) fail('runner accepted extra arguments');
else ok('runner rejected extra arguments');

const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'dmj-runner-'));
fs.mkdirSync(path.join(tempRoot, 'hooks'));
fs.copyFileSync(runner, path.join(tempRoot, 'hooks', 'run-hook.cmd'));
fs.writeFileSync(path.join(tempRoot, 'hooks', 'pre-tool-guard'), '#!/usr/bin/env bash\nexit 7\n');
if (process.platform !== 'win32') fs.chmodSync(path.join(tempRoot, 'hooks', 'pre-tool-guard'), 0o755);
const child = runRunnerBash(tempRoot, 'pre-tool-guard');
if (child.status !== 7) fail(`runner did not return real child exit code: ${child.status}`);
else ok('runner returned real child exit code');

const noNodePath = process.env.PATH.split(path.delimiter).filter((entry) => !/node/i.test(entry)).join(path.delimiter);
assertDeny('missing Node', '{"tool_name":"Bash","tool_input":{"command":"git status"}}', root, { PATH: noNodePath }, runShellGuard);

const missingEngineRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'dmj-no-engine-'));
fs.mkdirSync(path.join(missingEngineRoot, 'hooks'));
fs.copyFileSync(runner, path.join(missingEngineRoot, 'hooks', 'run-hook.cmd'));
fs.copyFileSync(path.join(root, 'hooks', 'pre-tool-guard'), path.join(missingEngineRoot, 'hooks', 'pre-tool-guard'));
assertDeny('missing engine file', '{"tool_name":"Bash","tool_input":{"command":"git status"}}', missingEngineRoot, {}, runShellGuard);

const engineErrorRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'dmj-engine-error-'));
fs.mkdirSync(path.join(engineErrorRoot, 'hooks'));
fs.copyFileSync(runner, path.join(engineErrorRoot, 'hooks', 'run-hook.cmd'));
fs.copyFileSync(path.join(root, 'hooks', 'pre-tool-guard'), path.join(engineErrorRoot, 'hooks', 'pre-tool-guard'));
fs.writeFileSync(path.join(engineErrorRoot, 'hooks', 'pre-tool-guard.js'), 'process.exit(9);\n');
assertDeny('engine error', '{"tool_name":"Bash","tool_input":{"command":"git status"}}', engineErrorRoot, {}, runShellGuard);

const guardShell = read('hooks/pre-tool-guard');
if (guardShell.includes('DMJ_ALLOW') || guardShell.includes('DMJ_GUARD_ENGINE')) fail('guard bypass environment remains');
for (const policy of ['--no-verify', '--force', '--hard']) if (guardShell.includes(policy)) fail(`duplicate policy logic remains in shell guard: ${policy}`);

if (failures.length) {
  for (const message of failures) console.log(`FAIL: ${message}`);
  process.exit(1);
}
console.log(`HOOK COMPATIBILITY PASS: ${pass.length} checks`);
