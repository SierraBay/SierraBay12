#!/usr/bin/env node
/**
 * Build script for /tg/station 13 codebase.
 *
 * This script uses Juke Build, read the docs here:
 * https://github.com/stylemistake/juke-build
 */

import fs from "fs";
import Juke from "./juke/index.js";
import { DreamDaemon, DreamMaker, NamedVersionFile } from "./lib/byond.js";
import { yarn } from "./lib/yarn.js";

const TGS_MODE = process.env.CBT_BUILD_MODE === "TGS";

Juke.chdir("../..", import.meta.url);
// Launchers add a target before user arguments; help must not execute that target.
if (process.argv.includes("--help") || process.argv.includes("-h")) process.argv.splice(2, process.argv.length - 2, "--help");
Juke.setup({ file: import.meta.url }).then((code) => {
  if (code !== 0 && process.argv.includes("--wait-on-error")) {
    Juke.logger.error("Please inspect the error and close the window.");
  }

  if (TGS_MODE) {
    // workaround for ESBuild process lingering
    // Once https://github.com/privatenumber/esbuild-loader/pull/354 is merged and updated to, this can be removed
    setTimeout(() => process.exit(code), 10000);
  } else {
    process.exit(code);
  }
});

const DME_NAME = "baystation12";

export const DefineParameter = new Juke.Parameter({
  type: "string[]",
  alias: "D",
});

export const PortParameter = new Juke.Parameter({
  type: "string",
  alias: "p",
});

export const DmVersionParameter = new Juke.Parameter({
  type: "string",
});

export const MapParameter = new Juke.Parameter({ type: "string" });

export const CiParameter = new Juke.Parameter({ type: "boolean" });

export const WarningParameter = new Juke.Parameter({
  type: "string[]",
  alias: "W",
});

export const DmMapsIncludeTarget = new Juke.Target({
  executes: async () => {
    const folders = [
      ...Juke.glob("maps/**/*.dmm"),
      ...Juke.glob("maps/random_ruins/**/*.dmm"),
      ...Juke.glob("maps/away/**/*.dmm"),
      ...Juke.glob("_maps/mapsystem/**/*.dmm"),
      ...Juke.glob("_maps/sierra/**/*.dmm"),
    ];
    const content =
      folders
        .map((file) => file.replace("maps/", ""))
        .map((file) => `#include "${file}"`)
        .join("\n") + "\n";
    fs.writeFileSync("maps/templates.dm", content);
  },
});

export const DmTarget = new Juke.Target({
  parameters: [DefineParameter, DmVersionParameter, WarningParameter],
  dependsOn: ({ get }) => [
    TguiTarget,
    get(DefineParameter).includes("ALL_MAPS") && DmMapsIncludeTarget,
  ],
  inputs: [
    "maps/generic/**",
    "code/**",
    "html/**",
    "icons/**",
    "interface/**",
    "maps/**",
    "mods/**",
    "nano/**",
    "packs/**",
    "~code/**",
    `${DME_NAME}.dme`,
    NamedVersionFile,
  ],
  outputs: ({ get }) => {
    if (get(DmVersionParameter)) {
      return []; // Always rebuild when dm version is provided
    }
    return [`${DME_NAME}.dmb`, `${DME_NAME}.rsc`];
  },
  executes: async ({ get }) => {
    await DreamMaker(`${DME_NAME}.dme`, {
      defines: get(DefineParameter),
      warningsAsErrors: get(WarningParameter).includes("error"),
      namedDmVersion: get(DmVersionParameter),
    });
  },
});

export const DmTestTarget = new Juke.Target({
  parameters: [DefineParameter, DmVersionParameter, WarningParameter, MapParameter],
  dependsOn: ({ get }) => [
    TguiTarget,
    get(DefineParameter).includes("ALL_MAPS") && DmMapsIncludeTarget,
  ],
  executes: async ({ get }) => {
    const map = get(MapParameter) || "example";
    if (!/^[a-zA-Z0-9_-]+$/.test(map) || !fs.existsSync(`maps/${map}/${map}.dm`)) {
      Juke.logger.error(`Unknown map: ${map}`);
      throw new Juke.ExitCode(1);
    }
    const testBase = `${DME_NAME}.test`;
    const project = fs.readFileSync(`${DME_NAME}.dme`, "utf8");
    fs.writeFileSync(`${testBase}.dme`, project.replace(
      '#include "maps\\_map_include.dm"',
      `#include "maps\\${map}\\${map}.dm"`,
    ));
    try {
      await DreamMaker(`${testBase}.dme`, {
        defines: ["UNIT_TEST", "MAP_OVERRIDE", ...get(DefineParameter)],
        warningsAsErrors: get(WarningParameter).includes("error"),
        namedDmVersion: get(DmVersionParameter),
      });
      const result = await DreamDaemon({
        dmbFile: `${testBase}.dmb`,
        namedDmVersion: get(DmVersionParameter),
      }, "-invisible", "-trusted", "-core", ...(process.platform === "win32" ? ["-close"] : []));
      if (!result.combined.includes("All Unit Tests Passed")
        || !result.combined.includes("Caught 0 Runtimes")
        || /runtime error:|Process scheduler caught exception processing|WARNING:|ERROR:/.test(result.combined)) {
        Juke.logger.error("Sierra unit tests failed or reported runtime errors.");
        throw new Juke.ExitCode(1);
      }
    } finally {
      for (const extension of ["dme", "dmb", "rsc"]) fs.rmSync(`${testBase}.${extension}`, { force: true });
    }
  },
});

export const AutowikiTarget = new Juke.Target({
  parameters: [DefineParameter, DmVersionParameter, WarningParameter],
  dependsOn: ({ get }) => [
    get(DefineParameter).includes("ALL_MAPS") && DmMapsIncludeTarget,
  ],
  outputs: ["data/autowiki_edits.txt"],
  executes: async ({ get }) => {
    fs.copyFileSync(`${DME_NAME}.dme`, `${DME_NAME}.test.dme`);
    await DreamMaker(`${DME_NAME}.test.dme`, {
      defines: ["CBT", "AUTOWIKI", ...get(DefineParameter)],
      warningsAsErrors: get(WarningParameter).includes("error"),
      namedDmVersion: get(DmVersionParameter),
    });
    Juke.rm("data/autowiki_edits.txt");
    Juke.rm("data/autowiki_files", { recursive: true });
    Juke.rm("data/logs/ci", { recursive: true });

    const options = {
      dmbFile: `${DME_NAME}.test.dmb`,
      namedDmVersion: get(DmVersionParameter),
    };
    await DreamDaemon(
      options,
      "-close",
      "-trusted",
      "-verbose",
      "-params",
      "log-directory=ci",
    );
    Juke.rm("*.test.*");
    if (!fs.existsSync("data/autowiki_edits.txt")) {
      Juke.logger.error("Autowiki did not generate an output, exiting");
      throw new Juke.ExitCode(1);
    }
  },
});

export const YarnTarget = new Juke.Target({
  parameters: [CiParameter],
  inputs: [
    "mods/tgui/frontend/.yarn/+(cache|releases|plugins|sdks)/**/*",
    "mods/tgui/frontend/**/package.json",
    "mods/tgui/frontend/yarn.lock",
  ],
  outputs: ["mods/tgui/frontend/.yarn/install-target"],
  executes: () => yarn("install", "--immutable"),
});

export const TgFontTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  inputs: [
    "mods/tgui/frontend/.yarn/install-target",
    "mods/tgui/frontend/packages/tgfont/**/*.+(js|cjs|svg)",
    "mods/tgui/frontend/packages/tgfont/package.json",
  ],
  outputs: [
    "mods/tgui/frontend/packages/tgfont/dist/tgfont.css",
    "mods/tgui/frontend/packages/tgfont/dist/tgfont.eot",
    "mods/tgui/frontend/packages/tgfont/dist/tgfont.woff2",
    "mods/tgui/frontend/packages/tgfont/static/tgfont.css",
    "mods/tgui/frontend/packages/tgfont/static/tgfont.eot",
    "mods/tgui/frontend/packages/tgfont/static/tgfont.woff2",
  ],
  executes: async () => {
    await yarn("workspace", "tgfont", "tgfont:build");
    fs.copyFileSync(
      "mods/tgui/frontend/packages/tgfont/dist/tgfont.css",
      "mods/tgui/frontend/packages/tgfont/static/tgfont.css",
    );
    fs.copyFileSync(
      "mods/tgui/frontend/packages/tgfont/dist/tgfont.eot",
      "mods/tgui/frontend/packages/tgfont/static/tgfont.eot",
    );
    fs.copyFileSync(
      "mods/tgui/frontend/packages/tgfont/dist/tgfont.woff2",
      "mods/tgui/frontend/packages/tgfont/static/tgfont.woff2",
    );
    await yarn("exec", "prettier", "--write", "packages/tgfont/static/tgfont.css");
  },
});

export const TguiTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  inputs: [
    "mods/tgui/frontend/.yarn/install-target",
    "mods/tgui/frontend/webpack.config.js",
    "mods/tgui/frontend/**/package.json",
    "mods/tgui/frontend/packages/**/*.+(js|cjs|ts|tsx|scss)",
    "mods/tgui/frontend/packages/tgfont/static/**",
  ],
  outputs: [
    "mods/tgui/frontend/public/tgui.bundle.css",
    "mods/tgui/frontend/public/tgui.bundle.js",
  ],
  executes: () => yarn("tgui:build"),
});

export const TguiEslintTarget = new Juke.Target({
  parameters: [CiParameter],
  dependsOn: [YarnTarget],
  executes: () => yarn("tgui:lint"),
});

export const TguiPrettierTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: () => yarn("tgui:prettier"),
});

export const TguiTscTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: () => yarn("tgui:tsc"),
});

export const TguiTestTarget = new Juke.Target({
  parameters: [CiParameter],
  dependsOn: [YarnTarget],
  executes: ({ get }) =>
    yarn("exec", "jest", "--ci", "--runInBand", get(CiParameter) && "--coverage"),
});

export const TguiLintTarget = new Juke.Target({
  dependsOn: [YarnTarget, TguiPrettierTarget, TguiEslintTarget, TguiTscTarget],
});

export const TguiDevTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: ({ args }) => yarn("tgui:dev", ...args),
});

export const DevTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: ({ args }) => yarn("tgui:dev", ...args),
});

export const TguiAnalyzeTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: () => yarn("tgui:analyze"),
});

export const TguiBenchTarget = new Juke.Target({
  dependsOn: [YarnTarget],
  executes: () => yarn("tgui:bench"),
});

export const TestTarget = new Juke.Target({
  dependsOn: [DmTestTarget, TguiTestTarget],
});

export const LintTarget = new Juke.Target({
  dependsOn: [TguiLintTarget],
});

export const BuildTarget = new Juke.Target({
  dependsOn: [TguiTarget, DmTarget],
});

export const ServerTarget = new Juke.Target({
  parameters: [DmVersionParameter, PortParameter],
  dependsOn: [BuildTarget],
  executes: async ({ get }) => {
    const port = get(PortParameter) || "1337";
    const options = {
      dmbFile: `${DME_NAME}.dmb`,
      namedDmVersion: get(DmVersionParameter),
    };
    await DreamDaemon(options, port, "-trusted");
  },
});

export const AllTarget = new Juke.Target({
  dependsOn: [TestTarget, LintTarget, BuildTarget],
});

export const TguiCleanTarget = new Juke.Target({
  executes: async () => {
    Juke.rm("mods/tgui/frontend/public/.tmp", { recursive: true });
    Juke.rm("mods/tgui/frontend/public/*.map");
    Juke.rm("mods/tgui/frontend/public/*.{chunk,bundle,hot-update}.*");
    Juke.rm("mods/tgui/frontend/packages/tgfont/dist", { recursive: true });
    Juke.rm("mods/tgui/frontend/.yarn/{cache,unplugged,webpack}", { recursive: true });
    Juke.rm("mods/tgui/frontend/.yarn/build-state.yml");
    Juke.rm("mods/tgui/frontend/.yarn/install-state.gz");
    Juke.rm("mods/tgui/frontend/.yarn/install-target");
    Juke.rm("mods/tgui/frontend/.pnp.*");
  },
});

export const CleanTarget = new Juke.Target({
  dependsOn: [TguiCleanTarget],
  executes: async () => {
    Juke.rm(`${DME_NAME}.{dmb,rsc}`);
    Juke.rm(`${DME_NAME}.m.{dme,dmb,rsc}`);
  },
});

/**
 * Removes more junk at the expense of much slower initial builds.
 */
export const CleanAllTarget = new Juke.Target({
  dependsOn: [CleanTarget],
  executes: async () => {
    Juke.rm("mods/tgui/frontend/.yarn/global", { recursive: true });
  },
});

/**
 * Prepends the defines to the .dme.
 * Does not clean them up, as this is intended for TGS which
 * clones new copies anyway.
 */
const prependDefines = (...defines) => {
  const dmeContents = fs.readFileSync(`${DME_NAME}.dme`);
  const textToWrite = defines.map((define) => `#define ${define}\n`);
  fs.writeFileSync(`${DME_NAME}.dme`, `${textToWrite}\n${dmeContents}`);
};

export const TgsTarget = new Juke.Target({
  dependsOn: [TguiTarget],
  executes: async () => {
    Juke.logger.info("Prepending TGS define");
    prependDefines("TGS");
  },
});

export default TGS_MODE ? TgsTarget : BuildTarget;
