# SierraBay12 build script

This is the WyccerraBay220 Juke Build runner adapted to SierraBay12. Frontend paths point to `mods/tgui/frontend`; the vendored Yarn 4.0.2 installs dependencies with `--immutable`. Install Node 24.13.0 and BYOND before using the runner.

- Windows:
  a) Run `bin\build.cmd` to build frontend first, then DM.
  b) Run `bin\tgui-build.cmd --ci` for frontend build, formatting, ESLint, TypeScript and Jest.
  c) Run `bin\test.cmd --map example` for Sierra DM unit tests; `--map sierra` selects the main station.
  d) Run `bin\server.cmd --port 1337` to build and start DreamDaemon.
- Linux:
  a) Run `sh tools/build/build` from the repository root.

`node tools/build/build.js <target>` is the cross-platform entry point. `bin/tgui-dev.cmd`, `bin/tgui-bench.cmd` and `bin/tgfont.cmd` expose the donor development, benchmark and font-generation targets. `mods/tgui/frontend/bin/tgui-prettier.bat` calls the same runner and no longer depends on the missing donor PowerShell script.

`clean` removes generated frontend files and the main DM build. `clean-all` additionally removes the frontend's local Yarn cache. Run these explicitly only when those outputs are no longer needed. Logs and dependency caches outside the checkout are preserved.

DM unit tests use a separate `baystation12.test` project, the `UNIT_TEST` and `MAP_OVERRIDE` defines and Sierra's existing success/runtime log checks. The temporary project is removed after the run. The original DME and ordinary compiled game are not replaced by the test project.

The script will skip build steps whose inputs have not changed since the last run.

## Getting list of available targets

You can get a list of all targets that you can build by running the following command:

```
tools/build/build --help
```

## Dependencies

- On Windows, `build.bat` uses Node installed on PATH.
- On Linux, install Node using your package manager or from <https://nodejs.org/en/download/>.
- On Linux, unless using tgs4 or later you will need to compile rust-g on the server and obtain a .so file, for instructions see https://github.com/tgstation/rust-g

## Why?

We used to include compiled versions of the tgui JavaScript code in the Git repository so that the project could be compiled using BYOND only. These pre-compiled files tended to have merge conflicts for no good reason. Using a build script lets us avoid this problem, while keeping builds convenient for people who are not modifying tgui.

This build script is based on [Juke Build](https://github.com/stylemistake/juke-build) - follow the link to read the documentation for the project and understand how it works and how to contribute.

## Named byond versions

If you have byond installations in non-standard locations or want to use few versions at once for testing you can fill in `dm_versions.json` file in this directory.
Entries with "default" set to true will be used BEFORE byond installations in standard locations. Otherwise you need to pass `--dm-version={name}` to the build script to choose version you want to use.
Example dm_versions.json file:
```
[
  {
    "name": "515.1594",
    "path": "C:\\Repo\\ByondVersions\\515.1594_byond\\byond\\bin\\dm.exe",
    "default": false
  },
  {
    "name": "funny_version",
    "path": "D:\\Repo\\ByondVersions\\514.1589_byond\\byond\\bin\\dm.exe",
    "default": true
  }
]
```
