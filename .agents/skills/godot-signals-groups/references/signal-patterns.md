# Signal & group patterns reference (Godot 4.6)

Depth companion to `godot-signals-groups`.

## Connection flags

`Object.connect` / `Signal.connect` accept a flags bitmask:

- `CONNECT_ONE_SHOT` — disconnect automatically after the first emission.
- `CONNECT_DEFERRED` — invoke the callback at idle time (end of frame) instead of
  immediately. Useful when the handler modifies the tree during physics.
- `CONNECT_PERSIST` — the connection is saved with the scene (editor-made connections).
- `CONNECT_REFERENCE_COUNTED` — multiple identical connections are reference-counted so
  the matching number of disconnects is required.

```gdscript
sig.connect(cb, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
```

## bind vs unbind

- `cb.bind(a, b)` — appends `a, b` to the end of the argument list when called.
- `cb.unbind(n)` — drops the last `n` signal arguments. Handy when the handler ignores
  the signal's payload: `sig.connect(_refresh.unbind(sig_arg_count))`.

## Custom signals with typed arguments

```gdscript
signal stat_changed(stat_name: String, old_value: int, new_value: int)

func set_stat(stat: String, value: int) -> void:
    var old := stats.get(stat, 0)
    stats[stat] = value
    stat_changed.emit(stat, old, value)
```

Typed parameters document the intended payload and let the editor's connection dialog
show argument names. Godot checks the emitted argument count; do not rely on the signal
declaration alone to validate runtime `Variant` values.

## Awaiting a signal with a timeout

`await` has no built-in timeout. Merely creating a `SceneTreeTimer` before awaiting
another signal does not race them: execution still resumes only from the signal being
awaited. When an immediate signal-or-timeout result is required, connect the concrete
signal and `SceneTreeTimer.timeout` to a small coordinator with `CONNECT_ONE_SHOT`, let
the first callback settle the result, then disconnect the losing callback. Match the
concrete signal's callback signature instead of hiding it behind an unchecked string.

For most gameplay, awaiting `animation_finished`, `timeout`, or `tween_finished`
directly is cleaner.

## Disconnecting safely

```gdscript
if sig.is_connected(cb):
    sig.disconnect(cb)
```

Nodes auto-disconnect connections where the *connected object* (the one owning the
Callable) is freed. You still must disconnect manually if the *emitter* outlives the
listener and you re-create listeners (otherwise stale connections accumulate).

## Groups: full API

```gdscript
add_to_group("saveable")                       # optional 2nd arg: persistent
remove_from_group("saveable")
is_in_group("saveable")
get_tree().get_nodes_in_group("saveable")      # Array[Node]
get_tree().get_first_node_in_group("player")   # first match or null
get_tree().call_group("enemies", "method", arg)
get_tree().set_group("enemies", "modulate", Color.RED)  # set a property on all
```

`call_group` has flag variants (`call_group_flags`) for deferred/unique-only calls.

## Signals vs direct calls — when to use which

- **Signal** when the emitter should not know or care who listens (reusable scenes,
  one-to-many, decoupling UI from logic).
- **Direct call** when there is a clear owner→owned relationship and coupling is fine
  (a controller calling a method on a component it created). Over-using signals for
  tightly coupled code adds indirection without benefit.

## Global event bus (autoload)

For events that cross scenes, declare signals on an autoload and have any scene emit or
connect:

```gdscript
# Events.gd (autoload). Emit: Events.player_died.emit(). Listen: Events.player_died.connect(...)
extends Node
signal player_died
signal level_completed(level_id: int)
```
