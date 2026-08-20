extends Node2D

signal prototype_crashed

## Short, deterministic IDE preview used by Level_01's narrative sequence.
## Keeping it self-contained prevents a missing debug scene from interrupting
## the formal game path or adding gameplay resources to the Web startup pack.
@export var crash_delay: float = 2.0

var _elapsed: float = 0.0

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= crash_delay:
		set_process(false)
		prototype_crashed.emit()
