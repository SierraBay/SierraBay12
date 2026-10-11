# TGUI

Port of [WyccerraBay220 at `87059e5d0d558625ca64dc933b0ccd3b37a328e7`](https://github.com/ss220club/WyccerraBay220/tree/87059e5d0d558625ca64dc933b0ccd3b37a328e7), with Sierra gameplay adapters. ID: `TGUI`.

## Source and scope

`donor-inventory.json` records 88 donor DM files containing TGUI or asset references, including calls outside the framework. Each reference has an inclusion/exclusion classification and each source file points to its Sierra implementation. `donor-files.json` records the original Git blob hashes of copied infrastructure, frontend, UI resources and licenses. Those hashes describe donor inputs, before the documented adaptations.

The donor server framework, window pool, access states, updates, dialogs, browser transport and webroot transport are included. Frontend dependencies and browser polyfills stay at the donor versions in the immutable Yarn lockfile. The donor JS/CSS, fonts and ordinary TGUI protocol are built together.

Excluded: `tgui/packages/tgui-panel/**`, panel initialization/restart hooks, chat and ping subsystems serving the panel, panel audio and telemetry, `TTSSeedsExplorer`, text-to-speech components/preferences, voice selection and its donor dependencies. Sierra's existing Goonchat renderer and `to_chat` delivery remain in use.

The chat skin uses separate legacy and browser panes, selected by a `CHILD` control, to prevent BYOND 516 from revealing native output over Goonchat during resource transfers. This adapts [tgstation #88663](https://github.com/tgstation/tgstation/pull/88663), originally by Absolucy, ShadowLarkens and S34N through VOREStation and Paradise. Goonchat startup, preferences and Fix Chat use the same pane selector; custom skins with the old layout retain the previous visibility switching.

Copyright and SPDX headers remain in the imported sources. The verified donor repository license is in `licenses/WyccerraBay220-LICENSE`; the MIT notice for Aleksej Komarov's TGUI code is in `licenses/TGUI-MIT`. Font Awesome notices and third-party notices in distributed resources are preserved. Production builds emit `tgui.bundle.js.LICENSE.txt`, which should accompany the bundle. Credits retain donor and Sierra contributors.

## Upstream compatibility fixes

The port also adapts these upstream fixes without changing the donor Inferno dependency stack:

| Source | Local adaptation |
| --- | --- |
| [tgstation #89956](https://github.com/tgstation/tgstation/pull/89956) | Retry CSS load failures under WebView2 while retaining IE load validation |
| [BeeStation #12834](https://github.com/BeeStation/BeeStation-Hornet/pull/12834) | Separate input and window focus; release movement keys on input focus |
| [tgstation #90295](https://github.com/tgstation/tgstation/pull/90295) | Split oversized actions into acknowledged chunks bounded by encoded size, owner and timeout |
| [tgstation #85313](https://github.com/tgstation/tgstation/pull/85313) | Character-based clipping in TGUI text input and its native input fallbacks |
| [Paradise #25160](https://github.com/ParadiseSS13/Paradise/pull/25160) | Cancel input timeout timers during datum destruction |
| [tgstation #86868](https://github.com/tgstation/tgstation/pull/86868) | Keep cached windows hidden until asynchronous geometry restoration finishes |
| [tgstation #87834](https://github.com/tgstation/tgstation/pull/87834) | Defer draggable-input focus until rendered and cancel deferred focus on unmount |
| [Paradise #26433](https://github.com/ParadiseSS13/Paradise/pull/26433) | Chromium scrollbar colors, document themes and background dimensions |

Oversized actions use the same TGUI action/access checks after assembly. Partial messages are removed on timeout, close, lock release, refresh and destruction. The server accepts four assemblies per window, up to 32 chunks each by default. Optional `tgui_max_chunk_count 32` in `config/config.txt` changes that limit (bounded to 1-128). Each chunk budgets 1024 characters after JSON escaping and URL encoding on the frontend; the server also bounds received chunk size. NanoUI's original Topic links retain their existing transport.

Window visibility is controlled by the Inferno Window lifecycle after geometry restoration; stale asynchronous work cannot show a suspended, replaced or unmounted interface. This concerns TGUI windows; the chat pane selector described above handles native chat/output overlap.

## Interfaces and Sierra handlers

All 21 ordinary donor interfaces are included, plus the local NanoUI adapter:

| Interface | Server implementation / local behavior |
| --- | --- |
| APC | APC override; Sierra channel values, wires, locks, malfunction and overload rules |
| Biogenerator | Biogenerator override; original prices, efficiency, production delay and output placement |
| Canister | Canister override; Sierra valve handling, pressure limits, labels and gas-release logging |
| ChemDispenser | `dispenser2.dm` override; cartridges, skills, contamination and original transfer amounts |
| ChemMaster | Chemistry machinery override; transfers, analysis, disposal mode, pills, bottles, blisters and dissolution |
| Credits | `code/credits.dm`, `credits_datums.dm`; client-owned module and approved project links |
| CrewMonitor | Medical suit-sensor Nano module override; Sierra sensor access, host z-level and AI tracking |
| DisposalBin | Disposal override; pump, flush and ejection through Sierra Topic |
| Fabricator | RnD autolathe override; original disks, material/reagent costs, licenses, queue, printing and quality |
| GPS | GPS override; Sierra GPS registry, tracking compass, hidden signals, labels and range |
| Orbit | `code/orbit.dm`; Sierra follow holders and visibility; ghost Follow opens the menu |
| Pump | Atmospheric pump override; local pressure bounds, power and icon updates |
| SimpleDockingConsole | Simple docking controller override; Sierra docking program and override commands |
| SmartFridge | Smartfridge override; original secure access and stock; drying racks retain automatic drying |
| SuitStorage | Suit storage override; original safety/panel/door checks and occupant ejection |
| Tank | Tank override; local release pressure and internals, including airtight helmets |
| Vending | Vending override; original prices, payment, coins, access, product indexes, refill and stock |
| AlertModal | `tgui_alert` |
| ListInputModal | `tgui_input_list`; duplicate display names keep distinct selectable entries |
| NumberInputModal | `tgui_input_number`; zero and Cancel remain distinct |
| TextInputModal | `tgui_input_text`; empty text and Cancel remain distinct |
| NanoUI | `mods/_master_files/code/modules/nano/nanoui.dm`; remaining Sierra templates inside TGUI |

Existing `ui_interact` entry points route converted machinery directly to TGUI, avoiding an additional NanoUI window. The donor SimpleDockingConsole had no server handler; its Sierra adapter supplies one. Escape-pod controller subclasses retain their own interface and use the NanoUI adapter.

Character setup and gear-tweak input calls use donor dialogs while retaining Sierra validation, organs, species, traits and loadout rules. Macro reset in `ssinput` uses `tgui_alert`. Sierra's MAP character preview and its loadout descriptions remain intact.

Fabricator adds the controls Sierra needs beyond the donor contract: both disks, beaker, reagents, insert materials, pause/abort and print quantity. Recipes update dynamically as disks change. ChemMaster exposes Sierra blisters and pill dissolution. SuitStorage includes occupant ejection. No donor stock, research or chemical gameplay implementation replaces Sierra's implementation.

Vending retains the donor product grid and smile overlay. Payment details appear while the machine is ready and has a pending purchase; during delivery the smile appears for paid and free products, even while Sierra retains the pending product until dispensing completes.

### Interface audit

The local review covers all 21 native interfaces and the NanoUI wrapper. Fabricator now reserves space for its controls, scrolls materials independently of the queue, and matches Sierra's list-valued recipe categories. Image buttons retain recipe names when material costs are empty. SuitStorage gives its contents and controls separate space; ChemMaster accommodates blister and dissolution controls, supports fractional reagent transfers, and highlights DM's text-valued pill style.

ChemDispenser keeps a bounded window with scrolling cartridge and beaker panels. Cartridge gauges use the actual server-side capacity. CrewMonitor scrolls crew records and sizes its map to the available panel; leaving a dragged map removes document listeners. Vending payment controls use the available viewport, including wrapped payment errors. Empty fridges and removed canister tanks display their current state.

Input dialogs keep long messages scrollable in bounded windows. Enter and Escape send a single request, list searches cannot submit missing entries, numeric splitting respects the minimum and fractional mode, and text sanitization handles every newline group. Orbit search handles antagonist records directly and keys duplicate names by reference.

## NanoUI adapter

`/datum/nanoui.open()` creates one `/datum/tgui` with interface `NanoUI`. The frontend places the original NanoUI document in an iframe; its CSS, jQuery, templates and globals stay separate from the TGUI document. `document.write` supports BYOND's IE browser without depending on `srcdoc`.

Updates travel through TGUI and call the frame's original `receiveUpdateData`. The adapter waits for NanoUI libraries, keeps the latest pending update and preserves config-only updates. Reinitialization replaces the frame document; ordinary data updates retain it.

Legacy assets are sent directly through `SSassets` and acknowledged before opening. They are not added to TGUI's asset mappings, which automatically execute JS and load CSS in the parent page. Native CrewMonitor receives map-only assets, uses Sierra's `<map>-<z>.png` filenames and retains the sensor repository's reported positions, including jammer effects.

Legacy links retain the NanoUI datum's original Topic reference. Sierra's NanoUI access state, AI behavior, master/child status and source Topic checks still apply. SSnano continues producing updates; SStgui owns the window, browser close callback, user transfer and window cleanup. Closing or deleting either side unregisters both sides. Dimensions retain Sierra's window-size preference. The original close reference and `on_close_logic` are honored for a user close.

## One asset system

The old `code/modules/client/asset_cache.dm` is excluded from compilation. Its file remains as upstream source, with no active singleton, second cache or second transport. All registered browser assets live in `SSassets.cache`; `SSassets.transport` selects the donor browse_rsc or webroot backend.

`register_asset`, `send_asset`, `send_asset_list`, `getFilesSlow` and `/client/getFiles` are compatibility entry points into that cache. Legacy fixed-name resources are explicitly marked `legacy` and `keep_local_name`, so existing HTML and templates work with either transport. This also covers Goonchat icon HTML, newscaster/news photos and RnD camera/design photos.

NanoUI common assets use donor replacements where present and Sierra fallbacks otherwise. All templates, including `mods-*` aliases and Sierra-only templates, are registered and sent through the same transport. Research design icons retain `design.ui_data["icon"]`. Permission editor, paper and pAI resources use the new cache. Lobby datums use donor resources with fixed filenames. Generated Sierra changelog content stays local; corresponding decoration/CSS resources come from the donor.

`SSassets` initializes after map/research setup and before the ticker. Cache acknowledgements must correspond to a pending job; preload JSON is size-limited, decoded defensively, and accepted only for known matching resource hashes. Executable resources reload. Client cleanup releases pending jobs, UIs, pooled windows and module references.

Optional server configuration:

```text
asset_transport webroot
asset_cdn_url https://assets.example.invalid/
asset_cdn_webroot data/asset-webroot/
asset_simple_preload 1
```

Default transport is browse_rsc. A webroot must be writable and served by the configured URL. Sierra compatibility resources still use browse_rsc from this same transport when webroot is selected.

## Files outside the mod

Core edits are tagged `SIERRA-ADD`, `SIERRA-EDIT` or `SIERRA-REMOVE` with ID `TGUI`:

| File | Reason |
| --- | --- |
| `baystation12.dme` | Include shared defines before consumers; exclude the old asset implementation |
| `code/__defines/~mods/tgui.dm` | Donor defines plus Sierra macro spelling and subsystem priorities |
| `code/controllers/subsystems/initialization/misc_late.dm` | Remove old singleton asset initialization |
| `code/modules/client/client_procs.dm` | Validate job acknowledgements and load donor cache-validation/preload page |
| `code/modules/admin/view_variables/topic.dm` | Asset repair clears the new `sent_assets` cache |
| `code/modules/goonchat/_helpers.dm` | Send the actual registered icon key through compatibility transport |
| `code/modules/organs/external/_external.dm`, `_external_damage.dm` | Dispatch automatic injury screams with `invoke_async` so emote input cannot block `Initialize()` |
| `code/modules/mob/living/carbon/human/human_organs.dm` | Dispatch automatic collapse/scream emotes without blocking organ processing or initialization |
| `mods/global_modpacks.dm` | Load TGUI last so its overrides follow other Sierra mods |
| `mods/lobbyscreen/code/assets.dm` | New transport flags and donor UI resource paths |

Two existing mod sources also receive narrow diagnostic fixes: `mods/TG_signals/code/core/_component.dm` explicitly casts component collections to a list before indexing, and `mods/emote_panel/code/pain.dm` makes automatic agony screams nonblocking. Injury calculations remain synchronous; `invoke_async` executes the emote immediately until its first blocking operation.

All other behavior overrides mirror their original paths under `mods/_master_files/`. They cover configuration, datum/mob/client destruction, Nano processing and adaptation, machinery, preferences, permission editing, paper, pAI, component hosting, RnD, credits and ssinput. The include list is in `_tgui_includes.dm`; it is not a separate DreamMaker project. NanoUI `open()` does not block its legacy callers while waiting for browser/resource acknowledgements, preserving its original no-result contract.

Build/CI edits: `scripts/build-tgui.cjs`, `.github/actions/build-tgui/action.yml`, `.github/workflows/test.yml`, `.github/workflow-config/preflight-filters.yml`, `test/check-paths.sh`, ignore rules and the changelog entry. The path checker accounts for the additional client cleanup override and headless test output. Frontend builds run before DM checks and map/unit tests, and a dedicated job runs TypeScript and Jest.

## Build and deploy

`Special Verbs > Refresh TGUI` reloads active native and adapted NanoUI windows after confirmation in a standard BYOND dialog. It resends their assets and preserves their UI owners. Idle pooled windows and closing or deleted interfaces are skipped, so recovery does not create blank windows or reserve unused pool slots.

From the repository root, with Node **24.13.0**:

```sh
node scripts/build-tgui.cjs --check
```

The script uses the vendored Yarn **4.0.2**, installs with `--immutable`, runs TypeScript/Jest and builds production frontend. Omit `--check` for a build only. Dependencies need network access on the first installation. Do not regenerate the lockfile as part of ordinary builds.

Build frontend before compiling DM. Retain `mods/tgui/frontend/public/` and `mods/tgui/frontend/packages/tgfont/static/` in the server checkout: the donor uses runtime `file()` resources as well as compiled HTML/polyfills. Retain `mods/tgui/resources/`, Sierra `nano/` fallbacks and original chat/lobby resources. Generated bundles, caches and dependency files are ignored; CI rebuilds them.

The donor's eight root `bin/*.cmd` launchers and `tools/build/` runner are also imported. They use the installed Node, the frontend under `mods/tgui/frontend`, immutable Yarn dependencies and Sierra DM unit-test flags/log checks. `bin/tgui-build.cmd --ci` runs production build, formatting, ESLint, TypeScript and Jest. See `tools/build/README.md` for the game build, tests, development server, benchmark, font generation and cleanup commands. The original asset-cache documentation is preserved at `docs/asset-cache.md` within this mod. The frontend Prettier launcher calls this runner instead of the donor's missing `tgui_.ps1`.

## Validation and limits

Local baseline and port were compiled in isolated DME copies because an existing DreamDaemon held the main RSC. BYOND **516.1675**: baseline and port each compiled with **0 errors, 0 warnings**.

Full static validation uses the installed VS Code DM language server **1.12.0+5** with the repository's DreamChecker configuration. A clean `HEAD` snapshot reports three errors (component list access and two blocking emote paths from grab initialization) and six hints. After the fixes, the port reports **0 errors, 0 warnings** and the same six hints: three documentation comments in `code/__defines/misc.dm:301–303`, one datum-iteration hint in `code/_helpers/logging.dm:222`, and two in `code/modules/modular_computers/ntos/components.dm:6,10`. The earlier MCP check missed proc-body diagnostics; its three-hint output was not a full static validation.

Frontend: immutable dependency installation, TypeScript, production build and **41 passing Jest tests**. Tests cover Sierra machine controls, vending selection/payment/paid and free delivery states, map filenames and sensor z-levels, plus NanoUI document isolation, deferred/latest updates, config-only updates and timer cleanup. Added regression coverage checks keyboard submission, empty list searches, numeric splitting, newline sanitation, recipe categories, cartridge capacities, pill-style selection and map listener cleanup. Bootstrap tests verify the original HTML's `ready` handshake for WebView2, Trident and legacy CEF, and ensure external pages do not send it. The donor's browser detection is adapted for BYOND 516 WebView2.

The repository path/style checks in `test/check-paths.sh` passed. GitHub Actions and the full map/unit-test matrix were not run locally; the focused tests below used the isolated harness. Python-dependent CI checks were not run because this environment has no working Python interpreter.

The interface audit additionally passed ESLint for all interfaces and the changed shared components. The updated port compiled with BYOND 516.1675 with 0 errors and 0 warnings; full DreamChecker diagnostics retained the six existing hints. A local headless Edge harness rendered 34 fixture states across all 21 native interfaces and the NanoUI wrapper, including maintenance, map, empty-container, payment-error and long-message states. No unreachable clipped controls or JavaScript exceptions remained in those fixtures. This checks browser layout with test data; it does not establish a live BYOND round trip, legacy IE behavior, or delivery of game-generated maps and sprite sheets.

Five DM tests passed in an isolated headless DreamDaemon, with **0 failures and 0 runtime errors**. Coverage includes parent/child access transitions, close/logout/transfer, source and user deletion, window locks, numeric/text/list edge cases, protocol encoding, shared resource registration and both NanoUI/TGUI registries. The browser boundary is a test window: these tests exercise server ownership and cleanup without claiming a BYOND browser session.

The tests are included in the normal repository unit-test environment. A focused isolated build can additionally define `TGUI_HEADLESS_TESTS`; `tests/headless.dm` runs only these five tests and writes `tgui-results.txt`. This replaces world startup for that validation build, so it must not be enabled on a game server. Compile and run an isolated DME/RSC, with frontend/resources present relative to the server working directory. Existing map CI runs the tests in the normal startup environment.

Interactive BYOND client validation has **not** been performed. The following acceptance checks still require a client and a running game:

- With an empty BYOND cache, open every native interface and representative NanoUI machines/modules; confirm CSS, fonts, templates, images, lobby video and existing chat render.
- Exercise each action, automatic update, refresh, reinitialization and close; open several windows together and reopen after suspension/pool exhaustion.
- Test adjacent/distant, incapacitated, observer/admin and AI wired/camera access; remove access while a window is open and attempt an action.
- Logout/reconnect, change mob and delete a viewed object with native and adapted NanoUI windows open.
- Test vending by coin/card/cash, hidden stock and refill; RnD disks, reagents, quantity, pause, queue and printing; ChemMaster/Condimaster production; docking and suit safety rules.
- Repeat resource checks with webroot delivery and a custom skin where applicable.

Headless tests establish cache registration and server lifecycle behavior. They do not establish actual IE loading, browser round-trip acknowledgements, complete gameplay integration, a full station bootstrap, or external CDN delivery.
