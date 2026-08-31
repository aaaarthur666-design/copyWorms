# ============================================================
# GameManager.gd - 游戏管理器 (Autoload)
# 统一管理瞬态生命周期、玩家/敌人引用与跨关卡运行时状态。
# ============================================================
extends Node

var run_mode: int = GlobalDefine.RunMode.FORMAL

var player_ref: Node2D = null
var current_level: Node = null
var enemy_list: Array[Node2D] = []
var boss_target: Node2D = null

var is_paused: bool = false
var is_game_over: bool = false
var is_dialog_active: bool = false

var dream_runtime_state: DreamRuntimeState = DreamRuntimeState.new()
var dream_runtime_flags: Dictionary:
	get:
		return dream_runtime_state.to_dictionary()
	set(value):
		if not dream_runtime_state.replace_from(value):
			push_error("[GameManager] 拒绝写入类型不合法的 dream_runtime_flags")

var checkpoint_scene_path: String = ""
var checkpoint_stage: int = 0
var checkpoint_data: Dictionary = {}

var _tracked_enemy_ids: Dictionary = {}
var _tracked_player_ids: Dictionary = {}
var _dialog_owners: Dictionary = {}
var _tracked_dialog_owner_ids: Dictionary = {}


func _ready() -> void:
	_apply_global_font()
	_detect_run_mode()
	call_deferred("_detect_run_mode")


func _apply_global_font() -> void:
	const CJK_FONT_PATH := "res://Assets/Fonts/文泉驿点阵宋体/WenQuanYi Bitmap Song 16px.ttf"
	var font := load(CJK_FONT_PATH) as FontFile
	if font == null:
		push_error("[GameManager] 文泉驿点阵宋体 16px.ttf 加载失败")
		return
	var default_theme := ThemeDB.get_default_theme()
	default_theme.set_default_font(font)
	_apply_font_to_theme_variants(default_theme, font)


func _apply_font_to_theme_variants(theme: Theme, font: FontFile) -> void:
	for theme_type in ["Label", "Button", "LineEdit", "TextEdit", "CodeEdit"]:
		theme.set_font("font", theme_type, font)
	for font_name in ["normal_font", "bold_font", "italics_font", "bold_italics_font", "mono_font"]:
		theme.set_font(font_name, "RichTextLabel", font)


func _detect_run_mode() -> void:
	var tree := get_tree()
	var scene_path := ""
	if tree and tree.current_scene:
		scene_path = tree.current_scene.scene_file_path
	if scene_path.contains("SelfTest"):
		run_mode = GlobalDefine.RunMode.SELF_TEST
	else:
		run_mode = GlobalDefine.RunMode.FORMAL


func _on_scene_changed() -> void:
	_detect_run_mode()


func register_player(player: Node2D) -> void:
	if player == null or not is_instance_valid(player):
		push_warning("[GameManager] 忽略失效玩家注册")
		return
	if player_ref == player:
		return
	player_ref = player
	var player_id := player.get_instance_id()
	if not _tracked_player_ids.has(player_id):
		_tracked_player_ids[player_id] = true
		player.tree_exited.connect(_on_player_tree_exited.bind(player_id), CONNECT_ONE_SHOT)
	EventBus.emit(GlobalDefine.EventName.PLAYER_SPAWNED, {"player": player})


func register_enemy(enemy: Node2D) -> void:
	if enemy == null or not is_instance_valid(enemy):
		push_warning("[GameManager] 忽略失效敌人注册")
		return
	_prune_enemies()
	if enemy in enemy_list:
		return
	enemy_list.append(enemy)
	var enemy_id := enemy.get_instance_id()
	if not _tracked_enemy_ids.has(enemy_id):
		_tracked_enemy_ids[enemy_id] = true
		enemy.tree_exited.connect(_on_enemy_tree_exited.bind(enemy_id), CONNECT_ONE_SHOT)
	EventBus.emit(GlobalDefine.EventName.ENEMY_SPAWNED, {"enemy": enemy})


func unregister_enemy(enemy: Node2D) -> void:
	if enemy == null:
		return
	enemy_list.erase(enemy)


func get_enemies() -> Array[Node2D]:
	_prune_enemies()
	return enemy_list.duplicate()


func get_nearest_enemy(pos: Vector2) -> Node2D:
	_prune_enemies()
	var nearest: Node2D = null
	var min_dist := INF
	for enemy: Node2D in enemy_list:
		var dist := pos.distance_squared_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
	return nearest


func set_current_level(level: Node) -> void:
	current_level = level


func begin_dialog(owner: Node) -> void:
	var owner_id := 0
	if owner and is_instance_valid(owner):
		owner_id = owner.get_instance_id()
		if not _tracked_dialog_owner_ids.has(owner_id):
			_tracked_dialog_owner_ids[owner_id] = true
			owner.tree_exited.connect(_on_dialog_owner_tree_exited.bind(owner_id), CONNECT_ONE_SHOT)
	var entry: Dictionary = _dialog_owners.get(owner_id, {"count": 0, "owner": weakref(owner) if owner else null})
	entry["count"] = int(entry["count"]) + 1
	_dialog_owners[owner_id] = entry
	_refresh_dialog_state()


func end_dialog(owner: Node = null) -> void:
	var owner_id := owner.get_instance_id() if owner and is_instance_valid(owner) else 0
	if not _dialog_owners.has(owner_id):
		return
	var entry: Dictionary = _dialog_owners[owner_id]
	entry["count"] = maxi(int(entry["count"]) - 1, 0)
	if int(entry["count"]) == 0:
		_dialog_owners.erase(owner_id)
	else:
		_dialog_owners[owner_id] = entry
	_refresh_dialog_state()


func clear_dialogs() -> void:
	_dialog_owners.clear()
	is_dialog_active = false


func set_dream_flag(key: StringName, value: Variant) -> bool:
	return dream_runtime_state.set_value(key, value)


func get_dream_flag(key: StringName, fallback: Variant = null) -> Variant:
	return dream_runtime_state.get_value(key, fallback)


func toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused
	if is_paused:
		EventBus.emit(GlobalDefine.EventName.GAME_PAUSE)
	else:
		EventBus.emit(GlobalDefine.EventName.GAME_RESUME)


func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	EventBus.emit(GlobalDefine.EventName.GAME_OVER)


func is_self_test() -> bool:
	_detect_run_mode()
	return run_mode == GlobalDefine.RunMode.SELF_TEST


func is_formal() -> bool:
	return run_mode == GlobalDefine.RunMode.FORMAL


func dev_tools_enabled() -> bool:
	return is_self_test() or OS.has_feature("editor") or OS.has_feature("debug")


## 开始一局全新的流程。标题页的正式/精彩入口都必须经过这里，
## 防止上一局的梦境标记和检查点污染新流程。
func begin_new_run(mode: int = GlobalDefine.RunMode.FORMAL) -> void:
	run_mode = mode
	reset_transient_state()
	reset_run_progress()


func reset_transient_state() -> void:
	is_paused = false
	is_game_over = false
	player_ref = null
	current_level = null
	enemy_list.clear()
	boss_target = null
	clear_dialogs()
	var tree := get_tree()
	if tree:
		tree.paused = false


func reset_run_progress() -> void:
	dream_runtime_state.clear()
	checkpoint_scene_path = ""
	checkpoint_stage = 0
	checkpoint_data.clear()


func set_checkpoint(scene_path: String, stage: int = 0, data: Dictionary = {}) -> void:
	checkpoint_scene_path = scene_path
	checkpoint_stage = stage
	checkpoint_data = data.duplicate(true)


func update_checkpoint_stage(stage: int, data: Dictionary = {}) -> void:
	checkpoint_stage = stage
	if not data.is_empty():
		checkpoint_data = data.duplicate(true)


func restart_from_checkpoint() -> void:
	is_game_over = false
	is_paused = false
	get_tree().paused = false
	SceneTransitionManager.request_checkpoint_restart()


func _prune_enemies() -> void:
	enemy_list = enemy_list.filter(func(enemy: Node2D) -> bool:
		return is_instance_valid(enemy) and not _enemy_is_dead(enemy)
	)


func _enemy_is_dead(enemy: Node2D) -> bool:
	if enemy is EnemyBase:
		return (enemy as EnemyBase).is_dead
	return false


func _on_enemy_tree_exited(enemy_id: int) -> void:
	enemy_list = enemy_list.filter(func(enemy: Node2D) -> bool:
		return is_instance_valid(enemy) and enemy.get_instance_id() != enemy_id
	)
	_tracked_enemy_ids.erase(enemy_id)


func _on_player_tree_exited(player_id: int) -> void:
	if player_ref and is_instance_valid(player_ref) and player_ref.get_instance_id() == player_id:
		player_ref = null
	_tracked_player_ids.erase(player_id)


func _on_dialog_owner_tree_exited(owner_id: int) -> void:
	_dialog_owners.erase(owner_id)
	_tracked_dialog_owner_ids.erase(owner_id)
	_refresh_dialog_state()


func _refresh_dialog_state() -> void:
	is_dialog_active = not _dialog_owners.is_empty()
