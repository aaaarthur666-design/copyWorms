# Project Memory — HackathonGame (copyWorms)

## Project Overview
- Godot 4.6 2D narrative-driven horizontal exploration game (Metroidvania-like)
- 5-layer architecture: Entry → Level Control → Character → Data Config → Infrastructure
- 5 Autoloads: GlobalDefine, EventBus, GameManager, InputManager, KeybindManager
- Core principles: code-built scenes, EventBus-only communication, collision layer constants, no hardcoded strings in code

## Key Conventions
- All terrain/UI built via code API (not .tscn drag-drop)
- All text numbers in .tres resources (LevelXXData.tres / LevelXXConfig.tres)
- Each level = 4 scripts (main controller + SceneBuilder + FSM + UIBuilder) + 2 resources (Config + Data) + 1 .tscn
- Collision layers must use GlobalDefine.Collision.* constants
- InteractiveObject input goes through InputManager.game_action signal, not direct polling
- Player skins: Warrior (default), Cyber, Lingnan (all include SmoothCamera as child node)

## Level 03 Current State (2026-06-18)
- 6-state state machine: TEA_SHOP_FRONT → LINGNAN_COMBAT → WORLD_SHIFT → CYBER_CITY → MEMORY_COLLECTION → AWAKENING → LEVEL_END_TRANSIT
- Seamless 4-zone single-coordinate space: 凉茶铺(0-1200) + 岭南街巷(1200-2400) + 过渡走廊(2400-3600) + 赛博城(3600-15600)
- Cyber city root initially hidden with collision disabled; revealed during WORLD_SHIFT
- World shift: 12-step performance (shake, glitch, color corruption, wall removal, skin swap, code rain, broadcast)
- Knockback reversal in cyber phases (push left -350)
- 2 memory echo collectibles (12000,550) and (14400,550)
- Known: _setup_player() hardcodes Player_Warrior.tscn (should use level_config.player_scene_path)
- Known: dream_runtime_flags read logic exists but dictionary is empty (Level_02 no longer writes to it)
- Exit: LEVEL_COMPLETE → next_level=Level_04
- 2026-06-18: Scene nodes migrated to Level_03.tscn (editable in editor). Level_03.gd now uses _bind_scene_nodes() instead of SceneBuilder.build_all(). SceneBuilder.gd retained as reference but no longer called.

## Fuzhan (复战) Levels HUD Timer (2026-07-02)
- Added HUD timer to `UI/HUD.gd`: top-right CanvasLayer Control at (980,20), 280x36, MM:SS.cs format
- Timer API: `start_timer()` / `stop_timer()` on HUD node; hidden by default, only shown when started
- Timing uses delta accumulation in `_process()` with `get_tree().paused` guard (pauses with game)
- `Level_fuzhan_memory_base.gd` (shared base for LevelFuzhan01/02) stores `_hud` ref, calls `start_timer()` in `_load_hud()`, calls `_stop_timer()` on area complete / player death / cleanup
