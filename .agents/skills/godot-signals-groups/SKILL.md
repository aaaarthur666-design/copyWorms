---
name: godot-signals-groups
description: >
  Design or debug Godot 4.6 node communication with custom signals, Callable
  connections, bind or one-shot flags, groups, call_group(), or an Autoload event bus.
  Use for event architecture and broadcasts; use godot-gdscript for isolated signal
  syntax and godot-nodes-scenes for scene composition or Autoload registration. In
  HackathonGame, cross-module broadcasts use EventBus and local signals stay local.
---

# Godot Signals & Groups (4.x)

Decouple nodes with the observer pattern (signals) and act on many nodes at once
(groups), instead of hard-coding references between scenes. Targets **Godot 4.6**.

## When to use

- Use when a node needs to tell others "something happened" (player died, item picked
  up, wave cleared) without holding direct references to them.
- Use when you need to address a whole category of nodes at once ("pause all enemies",
  "save every checkpoint").

**When *not* to use:** raw signal *syntax* basics → `godot-gdscript`; scene structure
and instancing → `godot-nodes-scenes`. For cross-scene global events, emit from an
autoload (see `godot-nodes-scenes`); in HackathonGame use the existing `EventBus`.

## HackathonGame adaptation

- Use typed Godot signals for local node/sub-scene contracts. Use `EventBus` for
  cross-module events with project event-name constants, string method names, and a
  dynamic `Dictionary` payload; validate payload keys at both boundaries.
- `EventBus.emit()` dispatches synchronously over a listener snapshot. Callback order
  can therefore affect same-stack state, while subscriptions added or removed inside a
  callback affect only later emissions. Use `emit_deferred()` only when the next process
  frame is intentional; transient cleanup cancels events still waiting in that queue.
- GDScript has no `try/catch` boundary around listener calls. Validate handlers and
  payloads before dispatch, and do not promise that `EventBus` isolates callback errors.
- Groups are for local categorization/broadcast. Enemy registration is not a group-based
  substitute: `EnemyBase._ready()` owns registration and `GameManager` owns the list.

## Core workflow

1. **Decide the direction.** A child/sub-scene should *emit* a signal upward; the parent
   *connects* to it. This keeps the child reusable and ignorant of who listens.
2. **Declare typed signals** on the emitter; `emit()` them when the event occurs.
3. **Connect with a Callable** (`sig.connect(_on_sig)`), optionally in the editor's Node
   dock. Use `CONNECT_ONE_SHOT` for fire-once, `bind()` to pass extra context.
4. **Use groups for broadcast**: add nodes to a named group, then iterate
   `get_tree().get_nodes_in_group(...)` or `call_group(...)`.
5. **Disconnect when needed** (e.g. before freeing a long-lived listener) and check
   `is_connected()` to avoid duplicate connections.

## Patterns

### 1. Emit upward, connect from the parent

```gdscript
# coin.gd (reusable pickup — knows nothing about the player or HUD)
extends Area2D
signal collected(value: int)

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        collected.emit(10)
        queue_free()
```

```gdscript
# level.gd (generic parent wiring; HackathonGame uses its documented GameManager boundary)
func _ready() -> void:
    for coin in get_tree().get_nodes_in_group("coins"):
        coin.collected.connect(_on_coin_collected)

func _on_coin_collected(value: int) -> void:
    # Generic only; use an approved project state owner instead of adding GameState here.
    GameState.add_score(value)
```

### 2. Connect flags: one-shot and bind extra arguments

```gdscript
func _ready() -> void:
    # Fire exactly once, then auto-disconnect.
    $Door.opened.connect(_on_door_opened, CONNECT_ONE_SHOT)
    # bind() appends arguments supplied at connect time (after the signal's own args).
    $RedButton.pressed.connect(_on_button.bind("red"))

func _on_button(color: String) -> void:
    print("Pressed the %s button" % color)
```

### 3. Groups: broadcast to many nodes

```gdscript
func pause_all_enemies() -> void:
    # Call a method on every node in the "enemies" group (no-op if missing).
    get_tree().call_group("enemies", "set_paused", true)

func count_enemies() -> int:
    return get_tree().get_nodes_in_group("enemies").size()
```

For a project-wide event, prefer the existing EventBus contract rather than adding a new
autoload bus:

```gdscript
EventBus.emit(GlobalDefine.EventName.LEVEL_COMPLETE, {"level_id": level_id})
```

Add a node to a group from code or via the editor's Node > Groups tab:

```gdscript
func _ready() -> void:
    add_to_group("enemies")        # remove_from_group("enemies") to leave
```

### 4. Await a signal inline

```gdscript
func open_chest() -> void:
    $AnimationPlayer.play("open")
    await $AnimationPlayer.animation_finished   # pause until it emits
    spawn_loot()
```

## Pitfalls

- **3.x connect signature is gone.** `connect("died", self, "_on_died")` →
  `died.connect(_on_died)`. The target is implied by the Callable. The legacy
  `Object.connect("died", Callable(self, "_on_died"))` works but the method-name string
  form does not.
- **Duplicate connections fire handlers multiple times.** Connecting again in `_ready()`
  after re-adding a node stacks callbacks. Guard with
  `if not sig.is_connected(cb): sig.connect(cb)`.
- **Connecting to a freed node errors.** Disconnect long-lived listeners, or rely on
  Godot auto-disconnecting when the *connected object* is freed (it does for nodes).
- **Groups are global to the SceneTree**, not per-scene. Two levels using the same group
  name share membership. Namespace group names if that matters.
- **`call_group` silently ignores nodes lacking the method.** Typos in the method name
  fail quietly — prefer a typed signal when the contract matters.
- **Signal args must match.** Emitting with the wrong argument count raises an error.
  Typed parameters document the intended payload, but do not replace validation of
  runtime `Variant` data; emit the declared count and expected value kinds.

## References

- For connection flags, deferred connections, custom signal arguments, awaiting with
  timeouts, and signals vs. direct calls trade-offs, read `references/signal-patterns.md`.

## Related skills

- `godot-gdscript` — signal/`await` syntax fundamentals.
- `godot-nodes-scenes` — autoloads for global event buses.
