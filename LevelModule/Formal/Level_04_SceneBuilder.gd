# ============================================================
# Level_04_SceneBuilder.gd — 只创建必要容器
# ============================================================
extends RefCounted
class_name Level_04_SceneBuilder

const RUNTIME_UI_BUILT_META: StringName = &"level_04_runtime_ui_built"

var level: Level_04

func _init(parent: Level_04) -> void:
	level = parent

func build_all() -> void:
	level._dynamic_actors = level._get_or_create_child("DynamicActors", Node2D)
	_build_canvas_ui()


func _build_canvas_ui() -> void:
	var canvas = level._get_or_create_child("CanvasLayerUI", CanvasLayer) as CanvasLayer
	canvas.layer = UILayerContract.LEVEL_UI
	canvas.process_mode = Node.PROCESS_MODE_PAUSABLE
	var special_fx = level._get_or_create_child("Level45SpecialFX", CanvasLayer) as CanvasLayer
	special_fx.layer = UILayerContract.LEVEL45_SPECIAL_FX
	special_fx.process_mode = Node.PROCESS_MODE_PAUSABLE
	if level.get_meta(RUNTIME_UI_BUILT_META, false):
		return
	Level_04_UIBuilder.new(level, canvas, special_fx).build_all()
	level.set_meta(RUNTIME_UI_BUILT_META, true)
