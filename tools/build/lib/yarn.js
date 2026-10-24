import Juke from '../juke/index.js';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const frontend = fileURLToPath(new URL('../../../mods/tgui/frontend/', import.meta.url));
const yarnPath = path.join(frontend, '.yarn/releases/yarn-4.0.2.cjs');

export const yarn = (...args) => {
  return Juke.exec(process.execPath, [
    yarnPath,
    ...args.filter((arg) => typeof arg === 'string'),
  ], {
    cwd: frontend,
    env: {
      ...process.env,
      YARN_GLOBAL_FOLDER: process.env.YARN_GLOBAL_FOLDER || path.join(frontend, '.yarn/global'),
      BROWSERSLIST_IGNORE_OLD_DATA: 'true',
    },
  });
};
