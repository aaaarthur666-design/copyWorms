---
name: hackathongame-project
description: "Use for every task performed in the HackathonGame Godot 4.6.2 repository: load its mandatory project context, enforce the project version, classify authorization, trace impact, choose safe tools, and apply project-specific verification before analysis, configuration, testing, review, or edits. Do not use outside this repository."
---

# HackathonGame Project Gate

Apply this Skill as the mandatory entry workflow for every task in the HackathonGame repository. It supplies project-specific judgment and safety boundaries; it never expands the user's authorization.

## Establish project context

After reading this Skill, and before task-specific analysis or any tool use beyond locating the repository, confirming its identity, and reading governing instructions:

1. Resolve the repository root from Git. If Git is unavailable, locate the nearest directory containing both `project.godot` and `TECHNICAL_ARCHITECTURE_REPORT.md`.
2. Confirm `project.godot` identifies `HackathonGame`. If the markers do not match, stop applying this Skill and report the mismatch.
3. Read the root `AGENTS.md` and `TECHNICAL_ARCHITECTURE_REPORT.md` completely in the current task. Do not rely on memory, an earlier task, or a cached summary.
4. Capture `git --no-optional-locks status --short` before planning changes. Treat all pre-existing modifications as user-owned and preserve them.
5. Inspect the actual files relevant to the request. The architecture report defines the documented project contract; code, scenes, resources, and `project.godot` establish observable implementation. If they disagree, surface the mismatch instead of silently choosing one.

Do not copy the architecture report into this Skill or create another architecture summary. Keep `TECHNICAL_ARCHITECTURE_REPORT.md` as the single maintained architecture source.

## Enforce engine-version precedence

- Treat `project.godot` and the root instructions as authoritative for the engine, scripting language, and renderer. This repository targets exactly Godot 4.6.2, GDScript, and GL Compatibility.
- The repository target overrides version assumptions and examples in generic or third-party Skills. Never upgrade the project, switch renderers or languages, or apply newer-version behavior merely because another Skill suggests it.
- Before using a version-sensitive API, property, command-line option, serialization form, import/export setting, or editor workflow, verify it against the Godot 4.6 documentation or the exact 4.6.2 runtime/class reference.
- If guidance depends on a newer engine version, translate it to a verified 4.6.2-supported alternative. If compatibility cannot be verified, report the incompatibility and stop before applying that guidance; do not guess.

## Route supporting Skills

- Apply this Project Skill first and keep it active for the entire task. A specialized Skill supplements this gate; it never replaces the project context, version baseline, authorization classification, or verification requirements.
- Select the smallest set of specialized Skills whose descriptions match the actual artifact and operation. Load more than one only when the task genuinely crosses domains, such as UI layout plus animation or scene composition plus event architecture.
- Resolve overlap by the primary decision being made: language syntax belongs to the language Skill; scene-tree composition to nodes/scenes; communication design to signals/groups; kinematic controller logic to movement; general collision, forces, Areas, and raycasts to physics; tile authoring to tilemap; build production to export; network replication to multiplayer.
- Honor the inclusion and exclusion boundaries in each specialized Skill description before reading its body. If no description is a clear match, continue under this Project Skill and inspect the repository instead of forcing a nearby Skill.
- Skill selection never grants write permission. Continue to use the authorization class and protected-content rules below.

## Classify the task and authorization

Place the request in the narrowest applicable class before acting:

- **Read-only:** explanation, architecture analysis, diagnosis, review, inventory, or status. Inspect and report; do not edit.
- **Project infrastructure:** AGENTS, Skills, MCP, tooling, documentation, or test setup. Change only the requested infrastructure; keep game content read-only.
- **Isolated experiment:** explicitly requested test assets or MCP write validation. Keep outputs outside formal scene chains and ensure they cannot become runtime dependencies.
- **Formal implementation:** gameplay, formal scenes, production scripts, resources, UI, audio, or architecture. Require an explicit implementation request and limit work to its scope.

If the request does not clearly authorize formal implementation, remain read-only for formal content. Ask for direction only when a missing product or architecture decision would materially change the outcome. Never interpret Skill invocation, MCP availability, or a broad goal as permission for unrelated edits, dependency installation, or external actions.

## Load task-specific evidence

After the mandatory sources, inspect only the evidence needed for the request:

- Scene lifecycle or progression: `project.godot`, `UI/TitleScreen.tscn`, `UI/MainEntry.*`, the affected level scenes/scripts, `Global/SceneTransitionManager.gd`, and cleanup paths.
- Global state, events, input, or audio: the relevant files under `Global/`, their subscribers/callers, and affected HUD or level consumers.
- Player, enemy, or combat behavior: the applicable base class, concrete override, `DataConfig/` resources, spawning path, event consumers, and Boss overrides when lifecycle semantics are involved.
- Level 02 memory/replay flow: also read `FUZHAN_WORK_MEMORY.md` and the actual `Level_02_03`/fuzhan scripts. Treat the scripts and approved source text as authoritative for dialogue.
- Pixelwork maps: inspect both source/generated map data and the matching runtime assembly or collision code.
- UI, shader, animation, or audio: inspect the scene/resource chain and plan real visual or listening verification.
- Skill or MCP work: inspect the relevant `SKILL.md`, `agents/openai.yaml`, `.codex/config.toml`, and upstream source/version. Do not touch game content during setup tests.

Use `README.md` for product identity only, not as proof of current implementation.

## Trace impact before editing

For an authorized change, map the smallest complete impact surface:

- target files and direct callers/consumers;
- attached scripts, external resources, signals, Autoloads, events, and state keys;
- initialization, pause/input behavior, death, cleanup, checkpoint, and transition effects where applicable;
- base-class behavior and concrete overrides, especially `Enemy_BossHuadan`;
- resource path casing, UID ownership, Web/Linux compatibility, and accidental `Backup/` dependencies;
- available automated, headless, isolated-scene, transition, and visual checks.

Do not guess a scene relationship from names alone. Confirm it from `.tscn`, scripts, signals, resources, or runtime inspection.

## Choose tools conservatively

- Prefer repository reads for static facts. Use Godot/editor inspection when static files cannot establish runtime or scene state.
- During MCP setup and read-only tasks, use only read-oriented Godot tools. Do not call scene, script, resource, project-setting, or node mutation operations.
- Validate MCP writes only in an explicitly isolated test scene before any formal use. Formal MCP writes require explicit authorization in the current task.
- Do not hand-edit `.godot/`, import caches, `.import` files, or unclear UIDs.
- Review the source, version, scripts, and declared dependencies before installing a third-party Skill, plugin, MCP server, or package.
- Keep project MCP connections loopback-only and project-scoped when practical. Never store secrets in the repository.

## Implement narrow, coherent changes

- Reuse established base classes, Builders, Resource configs, events, and naming conventions.
- Keep diffs focused. Do not batch-format, reorganize scenes, rewrite dialogue, rebalance values, migrate lifecycle models, or refactor adjacent systems unless explicitly requested.
- Preserve module direction: levels may assemble player, enemy, UI, and map systems; player and enemy code must not depend on concrete level scripts.
- Keep cross-scene state in `GameManager` only when necessary and pair it with explicit initialization and cleanup.
- Rely on `EnemyBase._ready()` for enemy registration; do not add a second registration after `add_child()`.
- Use exact-case `res://` paths and never introduce formal dependencies on `LevelModule/Backup/`.
- Update `TECHNICAL_ARCHITECTURE_REPORT.md` in the same task only when an authorized change alters architecture, lifecycle, public contracts, state keys, event payloads, main progression, resource boundaries, or confirmed risk status.

## Verify proportionally

Always preserve the initial working-tree status, capture the final status with the same `git --no-optional-locks status --short` command, inspect the final diff, run `git diff --check`, and compare the final status with the baseline. Separate pre-existing or concurrent changes from changes made for the task; do not claim another actor's change or use a clean diff alone as proof that no write occurred.

- AGENTS, Skill, or documentation changes: validate structure/metadata where a validator exists; check discovery paths, references, placeholders, and working-tree scope.
- MCP configuration: validate TOML, restart or start a new Codex task, confirm the expected server/tool allowlist, then perform read-only smoke tests.
- GDScript, scene, or Resource changes: use the exact Godot 4.6.2 executable for a headless main-scene start and affected-scene instantiation.
- Lifecycle, transition, or global-state changes: also verify adjacent mainline transitions and cleanup of input, pause, dialogue, music, player, enemy, and temporary state.
- Shader, animation, audio, and visual layout: add real graphics-backend or human visual/listening verification; headless checks are insufficient.

If a required executable, asset, environment, or decision is unavailable, report the unverified gate. Do not claim success from stale baselines, unrelated checks, or forced short-run exit logs.

## Report completion

State concisely:

- which authoritative project sources were read;
- the task class and authorization boundary used;
- files changed and why;
- checks run and their observed results;
- remaining warnings, manual checks, or blocked validation.
