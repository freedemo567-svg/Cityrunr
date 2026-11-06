import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { delimiter, dirname, resolve } from 'node:path';
import { tmpdir } from 'node:os';
import { existsSync, mkdirSync, mkdtempSync, renameSync, statSync } from 'node:fs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const godot = process.env.GODOT_BIN || 'godot';
const action = process.argv[2] || 'check';
const actions = ['check', 'import', 'run', 'test', 'build'];
function execute(args, timeout = 600_000, env = process.env) {
  const result = spawnSync(godot, args, { cwd: root, env, encoding: 'utf8', timeout, maxBuffer: 32 * 1024 * 1024 });
  if (result.stdout) process.stdout.write(result.stdout);
  if (result.stderr) process.stderr.write(result.stderr);
  if (result.error) throw new Error(`Cannot run Godot: ${result.error.message}. Set GODOT_BIN to the Godot executable path.`);
  if (result.status !== 0) throw new Error(`Godot failed (exit ${result.status ?? result.signal}).`);
  const output = `${result.stdout || ''}\n${result.stderr || ''}`;
  if (/resulting .*unsigned|APK is unsigned|SCRIPT ERROR:|Parse Error:|Failed to load script|Cannot export project|Project export .* failed/.test(output)) {
    throw new Error('Godot reported a script or export error. Read the output above.');
  }
  return output;
}
try {
  if (!actions.includes(action)) throw new Error(`Choose: ${actions.join(', ')}`);
  if (action === 'build') {
    const javaHome = process.env.JAVA_HOME;
    if (!javaHome || !existsSync(resolve(javaHome, 'bin', process.platform === 'win32' ? 'java.exe' : 'java'))) {
      throw new Error('Set JAVA_HOME to your JDK 17 folder before building. See BUILD_GUIDE_ML.md.');
    }
    process.env.PATH = resolve(javaHome, 'bin') + delimiter + (process.env.PATH || '');
  }
  const version = execute(['--version'], 30_000).trim();
  if (!version.startsWith('4.3.')) throw new Error(`Godot 4.3 Standard is required; found ${version}.`);
  if (!existsSync(resolve(root, 'project.godot'))) throw new Error('project.godot is missing. Extract the entire ZIP first.');
  if (action === 'check') {
    console.log('Godot and project found. Configure Android SDK, JDK 17 and export templates in Godot before Build APK.');
  } else {
    execute(['--headless', '--path', root, '--editor', '--quit']);
    if (action === 'run') execute(['--path', root], 24 * 60 * 60 * 1000);
    if (action === 'test') {
      const testData = mkdtempSync(resolve(tmpdir(), 'city-run-tests-'));
      execute(['--path', root, '--script', 'res://tests/smoke.gd'], 600_000,
        { ...process.env, APPDATA: testData, XDG_DATA_HOME: testData });
    }
    if (action === 'build') {
      const directory = resolve(root, 'build');
      mkdirSync(directory, { recursive: true });
      const temporary = resolve(directory, `city-run-${process.pid}-${Date.now()}.apk`);
      execute(['--headless', '--path', root, '--export-debug', 'Android', temporary]);
      if (!existsSync(temporary) || statSync(temporary).size < 1024) throw new Error('Godot did not create a usable APK.');
      const final = resolve(directory, 'city-run-3d.apk');
      renameSync(temporary, final);
      console.log(`APK ready: ${final}`);
    }
  }
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
