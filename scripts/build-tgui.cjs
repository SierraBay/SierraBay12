const path = require('node:path');
const { spawnSync } = require('node:child_process');

const frontend = path.resolve(__dirname, '../mods/tgui/frontend');
const yarn = path.join(frontend, '.yarn/releases/yarn-4.0.2.cjs');
const env = {
  ...process.env,
  CI: 'true',
  BROWSERSLIST_IGNORE_OLD_DATA: 'true',
  YARN_GLOBAL_FOLDER: process.env.YARN_GLOBAL_FOLDER || path.join(frontend, '.yarn/global'),
};

function run(args) {
  const result = spawnSync(process.execPath, [yarn, ...args], {
    cwd: frontend,
    env,
    stdio: 'inherit',
  });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status || 1);
}

run(['install', '--immutable']);
if (process.argv.includes('--check')) {
  run(['tgui:tsc']);
  run(['exec', 'jest', '--ci', '--runInBand']);
}
run(['tgui:build']);
