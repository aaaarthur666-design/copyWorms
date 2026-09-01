extends Node2D
class_name LevelFuzhanMemoryBase

const PAPER_EFFIGY_SCENE_PATH := "res://EnemyModule/Formal/Enemy_PaperEffigy.tscn"
const PAPER_EFFIGY_CONFIG_PATH := "res://DataConfig/Enemy/PaperEffigyConfig.tres"
const LANTERN_GHOST_SCENE_PATH := "res://EnemyModule/Formal/Enemy_LanternGhost.tscn"
const LANTERN_GHOST_CONFIG_PATH := "res://DataConfig/Enemy/LanternGhostConfig.tres"
@export var level_data: Level02Data = preload("res://DataConfig/Level/Level02Data.tres")
@export var level_config: LevelConfig = preload("res://DataConfig/Level/Level02Config.tres")

var area_config: MemoryRecoveryAreaConfig = null
var area_index: int
var spawn_node_path: NodePath
var camera_limit_left: int
var camera_limit_right: int
var camera_limit_top: int
var camera_limit_bottom: int
var camera_zoom: Vector2
var camera_lerp_speed: float
var enemy_spawn_y: float
var enemy_spawn_x_range: Vector2
var allow_upper_lantern_spawns: bool
var drop_spawn_y: float
var drop_spawn_y_range: Vector2
var drop_spawn_x_range: Vector2
var use_override_spawn_position: bool
var override_spawn_position: Vector2
var fallback_spawn_position: Vector2
var max_alive_enemies: int
var enemy_spawn_interval: float

var _paper_scene: PackedScene = null
var _lantern_scene: PackedScene = null
var _paper_config: EnemyConfig = null
var _lantern_config: EnemyConfig = null
var _dynamic_actors: Node2D = null
var _spawn_timer: Timer = null
var _enemies: Array[Node2D] = []
var _drops: Array[DropItem] = []
var _kills_since_drop: int = 0
var _transition_running: bool = false
var _narrative_open: bool = false
var _narrative_enter_pressed: bool = false
var _narrative_pages: Array[String] = []
var _narrative_page_index: int = 0
var _narrative_arm_remaining: float = 0.0
var _narrative_wait_elapsed: float = 0.0
var _narrative_poll_elapsed: float = 0.0
var _narrative_callback: Callable = Callable()
var _ui_layer: CanvasLayer = null
var _progress_label: Label = null
var _narrative_panel: Panel = null
var _narrative_text: RichTextLabel = null
var _left_edge_flash: ColorRect = null
var _left_edge_glow: ColorRect = null
var _left_edge_flash_active: bool = false
var _right_edge_flash: ColorRect = null
var _right_edge_glow: ColorRect = null
var _right_edge_flash_active: bool = false
var _enemies_frozen: bool = false
var _narrative_pause_guard_token: int = -1


func _ready() -> void:
	_apply_area_configuration()
	if not area_config:
		push_error("[%s] 缺少 MemoryRecoveryAreaConfig，副本停止初始化" % name)
		return
	_validate_area_configuration()
	GameManager.set_current_level(self)
	GameUIStyle.set_ui_theme(GameUIStyle.UI_THEME_LINGNAN)
	LevelFuzhanSub01.start_flow()
	MusicManager.fade_to(level_config.bgm_path, level_data.memory_bgm_fade_duration)
	_setup_player()
	_setup_camera_limits()
	_load_hud()
	_build_dynamic_actors()
	_build_ui()
	_load_enemy_resources()
	_bind_events()
	_start_enemy_spawns()
	EventBus.emit(GlobalDefine.EventName.LEVEL_LOADED, { "level": self })
	print("[%s] 记忆回收场景初始化完成，当前进度: %d/%d" % [name, LevelFuzhanSub01.area_collected(area_index), LevelFuzhanSub01.required_per_area()])
	_show_narrative(LevelFuzhanSub01.intro_text(area_index))


func _exit_tree() -> void:
	_cleanup()


func prepare_for_level_exit() -> void:
	_cleanup()


func _process(delta: float) -> void:
	_update_narrative(delta)
	if GameManager.is_game_over:
		GameManager.is_game_over = false
		_hide_game_over_panels()
	_check_player_death_guard()
	_poll_drops()
	if _left_edge_flash_active or _right_edge_flash_active:
		_check_flash_target_in_view()


func _input(event: InputEvent) -> void:
	var is_left_click: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if not event.is_action_pressed("ui_accept") and not is_left_click:
		return
	if _narrative_open:
		_narrative_enter_pressed = true
		get_viewport().set_input_as_handled()
		return
	var drop := _find_nearby_drop()
	if drop:
		EventBus.emit(GlobalDefine.EventName.INTERACTIVE_OBJECT_TRIGGERED, { "object_id": drop.object_id })
		get_viewport().set_input_as_handled()


func _setup_player() -> void:
	var spawn_pos := _get_spawn_position()
	if GameManager.player_ref and is_instance_valid(GameManager.player_ref):
		GameManager.player_ref.global_position = spawn_pos
		_reset_player_for_memory_recovery(GameManager.player_ref)
		return
	var player_scene_path := level_config.player_scene_path
	if not ResourceLoader.exists(player_scene_path):
		push_error("[%s] 玩家场景不存在: %s" % [name, player_scene_path])
		return
	var player_scene := load(player_scene_path) as PackedScene
	var player := player_scene.instantiate() as Node2D
	player.global_position = spawn_pos
	add_child(player)
	GameManager.register_player(player)
	_reset_player_for_memory_recovery(player)


func _reset_player_for_memory_recovery(player: Node2D) -> void:
	var collision_player := player as CollisionObject2D
	if collision_player and not (collision_player.collision_layer & GlobalDefine.Collision.PLAYER):
		collision_player.collision_layer |= GlobalDefine.Collision.PLAYER
	if player.has_method("set_frozen"):
		player.set_frozen(false)
	player.set("can_jump", true)
	player.set("can_attack", true)
	player.set("can_dash", true)
	player.set("can_skill", true)
	player.set("can_double_jump", false)
	player.set("has_double_jumped", false)
	player.set("runtime_move_speed_multiplier", level_data.memory_player_move_speed_multiplier)
	var current_health = player.get("current_health")
	var max_health = player.get("max_health")
	if current_health != null and max_health != null:
		EventBus.emit(GlobalDefine.EventName.HEALTH_CHANGED, {
			"target": player,
			"current_health": current_health,
			"max_health": max_health,
		})


func _get_spawn_position() -> Vector2:
	if use_override_spawn_position:
		return override_spawn_position
	var spawn := get_node_or_null(spawn_node_path) as Marker2D
	if spawn:
		return spawn.global_position
	return fallback_spawn_position


func _setup_camera_limits() -> void:
	var player := GameManager.player_ref
	if not player or not is_instance_valid(player):
		return
	var cam := player.get_node_or_null("SmoothCamera") as SmoothCamera
	if not cam:
		return
	cam.limit_left = camera_limit_left
	cam.limit_right = camera_limit_right
	cam.limit_top = camera_limit_top
	cam.limit_bottom = camera_limit_bottom
	cam.zoom = camera_zoom
	cam.offset = Vector2.ZERO
	cam.lerp_speed = camera_lerp_speed
	cam.bind_target(player)


func _load_hud() -> void:
	var hud_path := "res://UI/HUD.tscn"
	if ResourceLoader.exists(hud_path):
		add_child(load(hud_path).instantiate())


func _apply_area_configuration() -> void:
	pass


func _use_area_config(config: MemoryRecoveryAreaConfig) -> void:
	area_config = config
	if not area_config:
		return
	area_index = area_config.area_index
	spawn_node_path = area_config.spawn_node_path
	camera_limit_left = area_config.camera_limit_left
	camera_limit_right = area_config.camera_limit_right
	camera_limit_top = area_config.camera_limit_top
	camera_limit_bottom = area_config.camera_limit_bottom
	camera_zoom = area_config.camera_zoom
	camera_lerp_speed = area_config.camera_lerp_speed
	enemy_spawn_y = area_config.enemy_spawn_y
	enemy_spawn_x_range = area_config.enemy_spawn_x_range
	allow_upper_lantern_spawns = area_config.allow_upper_lantern_spawns
	drop_spawn_y = area_config.drop_spawn_y
	drop_spawn_y_range = area_config.drop_spawn_y_range
	drop_spawn_x_range = area_config.drop_spawn_x_range
	use_override_spawn_position = area_config.use_override_spawn_position
	override_spawn_position = area_config.override_spawn_position
	fallback_spawn_position = area_config.fallback_spawn_position
	max_alive_enemies = area_config.max_alive_enemies
	enemy_spawn_interval = area_config.enemy_spawn_interval


func _validate_area_configuration() -> void:
	var min_x := minf(drop_spawn_x_range.x, drop_spawn_x_range.y)
	var max_x := maxf(drop_spawn_x_range.x, drop_spawn_x_range.y)
	if min_x > max_x:
		push_warning("[%s] drop_spawn_x_range 顺序异常: %s" % [name, drop_spawn_x_range])
		drop_spawn_x_range = Vector2(max_x, min_x)
		min_x = drop_spawn_x_range.x
		max_x = drop_spawn_x_range.y
	var cam_max_x := float(camera_limit_right) - level_data.memory_drop_spawn_edge_margin
	if max_x > cam_max_x:
		push_warning("[%s] drop_spawn_x_range 右边界 %.1f 超出 camera_limit_right=%d，已截断" % [name, max_x, camera_limit_right])
		drop_spawn_x_range = Vector2(min_x, cam_max_x)


func _build_dynamic_actors() -> void:
	_ensure_dynamic_actors_root()


func _ensure_dynamic_actors_root() -> Node2D:
	var existing := get_node_or_null("DynamicActors") as Node2D
	if existing and existing.get_parent() != self:
		push_warning("[%s] DynamicActors 不在关卡根节点下，已重建" % name)
		existing = null
	if not existing:
		existing = Node2D.new()
		existing.name = "DynamicActors"
		add_child(existing)
	existing.position = Vector2.ZERO
	existing.rotation = 0.0
	existing.scale = Vector2.ONE
	_dynamic_actors = existing
	return _dynamic_actors


func _load_enemy_resources() -> void:
	if ResourceLoader.exists(PAPER_EFFIGY_SCENE_PATH):
		_paper_scene = load(PAPER_EFFIGY_SCENE_PATH) as PackedScene
	if ResourceLoader.exists(LANTERN_GHOST_SCENE_PATH):
		_lantern_scene = load(LANTERN_GHOST_SCENE_PATH) as PackedScene
	if ResourceLoader.exists(PAPER_EFFIGY_CONFIG_PATH):
		_paper_config = load(PAPER_EFFIGY_CONFIG_PATH) as EnemyConfig
	if ResourceLoader.exists(LANTERN_GHOST_CONFIG_PATH):
		_lantern_config = load(LANTERN_GHOST_CONFIG_PATH) as EnemyConfig


func _bind_events() -> void:
	EventBus.subscribe(GlobalDefine.EventName.ENEMY_DIED, self, "_on_enemy_died")
	EventBus.subscribe(GlobalDefine.EventName.PLAYER_DIED, self, "_on_player_died")
	EventBus.subscribe(GlobalDefine.EventName.GAME_OVER, self, "_on_game_over_suppressed")
	EventBus.subscribe(GlobalDefine.EventName.INTERACTIVE_OBJECT_TRIGGERED, self, "_on_object_interacted")


func _on_game_over_suppressed(_data: Dictionary = {}) -> void:
	GameManager.is_game_over = false
	_hide_game_over_panels()


func _start_enemy_spawns() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.name = "MemoryEnemySpawnTimer"
	_spawn_timer.wait_time = enemy_spawn_interval
	_spawn_timer.one_shot = false
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)
	for i in range(max_alive_enemies):
		_spawn_enemy()
	_spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	_enemies = _enemies.filter(func(e): return is_instance_valid(e))
	if _enemies.size() >= max_alive_enemies:
		return
	_spawn_enemy()


func _spawn_enemy() -> void:
	var use_paper := _roll_paper_effigy_spawn()
	var scene := _paper_scene if use_paper else _lantern_scene
	if not scene:
		scene = _lantern_scene if _lantern_scene else _paper_scene
	if not scene:
		return
	var enemy := scene.instantiate() as Node2D
	enemy.set("config", _paper_config if use_paper else _lantern_config)
	_spawn_actor_at_world(enemy, _random_enemy_spawn_position(use_paper))
	_enemies.append(enemy)


func _roll_paper_effigy_spawn() -> bool:
	var total := level_data.memory_lantern_spawn_weight + level_data.memory_paper_spawn_weight
	return randf() < float(level_data.memory_paper_spawn_weight) / float(total)


func _random_enemy_spawn_position(use_paper: bool) -> Vector2:
	var min_x := minf(enemy_spawn_x_range.x, enemy_spawn_x_range.y)
	var max_x := maxf(enemy_spawn_x_range.x, enemy_spawn_x_range.y)
	min_x = maxf(min_x, float(camera_limit_left) + level_data.memory_drop_spawn_edge_margin)
	max_x = minf(max_x, float(camera_limit_right) - level_data.memory_drop_spawn_edge_margin)
	if min_x > max_x:
		min_x = float(camera_limit_left) + level_data.memory_drop_spawn_edge_margin
		max_x = float(camera_limit_right) - level_data.memory_drop_spawn_edge_margin
	var player := GameManager.player_ref
	var x := randf_range(min_x, max_x)
	if player and is_instance_valid(player):
		var side := 1.0 if randf() < level_data.memory_positive_spawn_side_chance else -1.0
		x = clampf(player.global_position.x + side * randf_range(level_data.memory_enemy_spawn_distance_min, level_data.memory_enemy_spawn_distance_max), min_x, max_x)
	var y := enemy_spawn_y
	if not use_paper and allow_upper_lantern_spawns and randf() < level_data.memory_upper_enemy_chance:
		y = level_data.memory_upper_enemy_y
	return Vector2(x, y)


func _on_enemy_died(data: Dictionary) -> void:
	if _transition_running:
		return
	var enemy := data.get("enemy") as Node2D
	if not enemy or not _enemies.has(enemy):
		return
	_enemies.erase(enemy)
	if LevelFuzhanSub01.area_collected(area_index) >= LevelFuzhanSub01.required_per_area():
		return
	_kills_since_drop += 1
	_update_progress_label()
	if _kills_since_drop >= LevelFuzhanSub01.kills_per_drop():
		_kills_since_drop = 0
		_spawn_memory_drop()


func _spawn_memory_drop() -> void:
	_drops = _drops.filter(func(drop): return is_instance_valid(drop) and not drop.completed)
	if not _drops.is_empty():
		_show_narrative("已有童年回忆样本正在等待回收。")
		return
	var drop := DropItem.new()
	var configured_drop_types := LevelFuzhanSub01.drop_types()
	if configured_drop_types.is_empty():
		push_error("[%s] memory_drop_types 不能为空" % name)
		return
	var type_index := clampi(LevelFuzhanSub01.total_fragments(), 0, configured_drop_types.size() - 1)
	drop.drop_type = configured_drop_types[type_index]
	drop.object_id = "memory_drop_%d_%d" % [area_index, Time.get_ticks_msec()]
	drop.collision_layer = 0
	drop.collision_mask = GlobalDefine.Collision.PLAYER
	var spawn_pos := _random_drop_spawn_position()
	var placed_pos := _spawn_drop_at_world(drop, spawn_pos)
	print("[%s] 生成童年回忆掉落物: %s target=%s placed=%s bounds=%s cfg_x=%s" % [
		name,
		drop.drop_type,
		spawn_pos,
		placed_pos,
		_drop_spawn_bounds(),
		drop_spawn_x_range,
	])
	if not _is_within_drop_spawn_bounds(placed_pos):
		push_error("[%s] 掉落物放置后仍越界 placed=%s bounds=%s" % [name, placed_pos, _drop_spawn_bounds()])
		placed_pos = _spawn_drop_at_world(drop, _random_drop_spawn_position())
	call_deferred("_verify_drop_world_position", drop)
	_drops.append(drop)
	_start_drop_edge_flash()
	_show_narrative(LevelFuzhanSub01.drop_ready_text(area_index))


func _random_drop_spawn_position() -> Vector2:
	var bounds := _drop_spawn_bounds()
	return Vector2(
		randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
		randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
	)


func _drop_spawn_bounds() -> Rect2:
	var cfg_min_x := minf(drop_spawn_x_range.x, drop_spawn_x_range.y)
	var cfg_max_x := maxf(drop_spawn_x_range.x, drop_spawn_x_range.y)
	var cfg_min_y := drop_spawn_y
	var cfg_max_y := drop_spawn_y
	if drop_spawn_y_range != Vector2.ZERO:
		cfg_min_y = minf(drop_spawn_y_range.x, drop_spawn_y_range.y)
		cfg_max_y = maxf(drop_spawn_y_range.x, drop_spawn_y_range.y)
	var cam_min_x := float(camera_limit_left) + level_data.memory_drop_spawn_edge_margin
	var cam_max_x := float(camera_limit_right) - level_data.memory_drop_spawn_edge_margin
	var cam_min_y := float(camera_limit_top) + level_data.memory_drop_spawn_edge_margin
	var cam_max_y := float(camera_limit_bottom) - level_data.memory_drop_spawn_edge_margin
	var min_x := maxf(cfg_min_x, cam_min_x)
	var max_x := minf(cfg_max_x, cam_max_x)
	var min_y := maxf(cfg_min_y, cam_min_y)
	var max_y := minf(cfg_max_y, cam_max_y)
	if min_x > max_x or min_y > max_y:
		push_error("[%s] 掉落范围与相机边界无交集 cfg_x=%s bounds_y=%s" % [name, drop_spawn_x_range, _drop_spawn_y_debug_text()])
		min_x = cfg_min_x
		max_x = cfg_max_x
		min_y = cfg_min_y
		max_y = cfg_max_y
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)


func _clamp_to_drop_spawn_bounds(world_pos: Vector2) -> Vector2:
	var bounds := _drop_spawn_bounds()
	return Vector2(
		clampf(world_pos.x, bounds.position.x, bounds.position.x + bounds.size.x),
		clampf(world_pos.y, bounds.position.y, bounds.position.y + bounds.size.y)
	)


func _is_within_drop_spawn_bounds(world_pos: Vector2) -> bool:
	var bounds := _drop_spawn_bounds()
	return bounds.has_point(world_pos)


func _spawn_drop_at_world(drop: DropItem, world_pos: Vector2) -> Vector2:
	var safe_world := _clamp_to_drop_spawn_bounds(world_pos)
	var actors := _ensure_dynamic_actors_root()
	if drop.get_parent() and drop.get_parent() != actors:
		drop.get_parent().remove_child(drop)
	if drop.get_parent() != actors:
		actors.add_child(drop)
	drop.global_position = safe_world
	var actual := drop.global_position
	if actual.distance_to(safe_world) > 1.0:
		push_warning("[%s] 掉落物坐标回写偏差 target=%s actual=%s parent_xform=%s" % [
			name,
			safe_world,
			actual,
			actors.global_transform,
		])
		drop.global_position = safe_world
		actual = drop.global_position
	return actual


func _spawn_actor_at_world(node: Node2D, world_pos: Vector2) -> Vector2:
	var actors := _ensure_dynamic_actors_root()
	if node.get_parent() and node.get_parent() != actors:
		node.get_parent().remove_child(node)
	# 与 Level_02_01 一致：add_child 前写入坐标，避免 LanternGhost._on_ready 在 y=0 时缓存漂浮高度。
	node.global_position = world_pos
	if node.get_parent() != actors:
		actors.add_child(node)
	return node.global_position


func _place_node_at_world(node: Node2D, world_pos: Vector2, bounds: Rect2 = Rect2()) -> Vector2:
	var safe_world := world_pos
	if bounds.size.x > 0.0 and bounds.size.y > 0.0:
		safe_world = Vector2(
			clampf(world_pos.x, bounds.position.x, bounds.position.x + bounds.size.x),
			clampf(world_pos.y, bounds.position.y, bounds.position.y + bounds.size.y)
		)
	if node is DropItem:
		return _spawn_drop_at_world(node as DropItem, safe_world)
	return _spawn_actor_at_world(node, safe_world)


func _verify_drop_world_position(drop: DropItem) -> void:
	if not is_instance_valid(drop) or drop.completed:
		return
	if _is_within_drop_spawn_bounds(drop.global_position):
		return
	push_error("[%s] 掉落物延迟校验失败 pos=%s bounds=%s cfg_x=%s parent_xform=%s" % [
		name,
		drop.global_position,
		_drop_spawn_bounds(),
		drop_spawn_x_range,
		_dynamic_actors.global_transform if _dynamic_actors else "null",
	])
	_spawn_drop_at_world(drop, _clamp_to_drop_spawn_bounds(drop.global_position))


func _drop_spawn_y_debug_text() -> String:
	if drop_spawn_y_range == Vector2.ZERO:
		return str(Vector2(drop_spawn_y, drop_spawn_y))
	return str(drop_spawn_y_range)


func _on_object_interacted(data: Dictionary) -> void:
	var obj_id := str(data.get("object_id", ""))
	if not obj_id.begins_with("memory_drop_"):
		return
	for drop in _drops:
		if not is_instance_valid(drop) or drop.object_id != obj_id or drop.completed:
			continue
		_set_enemies_frozen(true)
		drop.on_collected(func():
			_finish_memory_drop_collection()
		)
		_stop_all_edge_flash()
		return


func _finish_memory_drop_collection() -> void:
	var collected := LevelFuzhanSub01.add_fragment(area_index)
	_update_progress_label()
	if collected >= LevelFuzhanSub01.required_per_area():
		_complete_area()
	else:
		_show_narrative("童年回忆样本已回收。\n当前区域进度：%d / %d。" % [collected, LevelFuzhanSub01.required_per_area()])


func _check_player_death_guard() -> void:
	if _transition_running:
		return
	var player := GameManager.player_ref
	if not player or not is_instance_valid(player):
		return
	var current_health = player.get("current_health")
	if current_health == null or int(current_health) > 0:
		return
	player.set("current_health", level_data.memory_death_guard_health)
	player.set("is_invincible", true)
	player.set("invincible_timer", level_data.memory_death_guard_invincibility_duration)
	_on_player_died({ "player": player })


func _on_player_died(_data: Dictionary) -> void:
	if _transition_running:
		return
	_transition_running = true
	GameManager.is_game_over = false
	_hide_game_over_panels()
	_set_enemies_frozen(true)
	LevelFuzhanSub01.request_return_to_reality(area_index, false)
	_show_narrative(LevelFuzhanSub01.field_failed_text(area_index), func():
		_return_to_reality_scene()
	)


func _complete_area() -> void:
	if _transition_running:
		return
	_transition_running = true
	LevelFuzhanSub01.request_return_to_reality(area_index, true)
	if _spawn_timer:
		_spawn_timer.stop()
	_set_enemies_frozen(true)
	_show_narrative(LevelFuzhanSub01.field_complete_text(area_index), func():
		_return_to_reality_scene()
	)


func _return_to_reality_scene() -> void:
	_cleanup()
	InputManager.force_unblock_all()
	if not _is_loaded_under_main_entry():
		SceneTransitionManager.request_scene_change(level_data.memory_return_scene_path, self)
		return
	EventBus.emit(GlobalDefine.EventName.LEVEL_COMPLETE, {
		"level": self,
		"next_level": level_data.memory_return_scene_path,
	})


func _poll_drops() -> void:
	var player := GameManager.player_ref
	if not player or not is_instance_valid(player):
		return
	for drop in _drops:
		if is_instance_valid(drop):
			drop.check_player_in_range(player)


func _find_nearby_drop() -> DropItem:
	var player := GameManager.player_ref
	if not player or not is_instance_valid(player):
		return null
	var best: DropItem = null
	var best_dist := INF
	for drop in _drops:
		if not is_instance_valid(drop) or drop.completed:
			continue
		drop.check_player_in_range(player)
		if not drop.is_player_in_range:
			continue
		var dist := drop.get_interaction_distance_to(player)
		if dist < best_dist:
			best_dist = dist
			best = drop
	return best


func _build_ui() -> void:
	_ui_layer = CanvasLayer.new()
	_ui_layer.name = "MemoryRecoveryUI"
	_ui_layer.layer = UILayerContract.LEVEL_UI
	add_child(_ui_layer)
	_progress_label = Label.new()
	_progress_label.name = "MemoryProgressLabel"
	_progress_label.position = Vector2(28, 118)
	_progress_label.size = Vector2(520, 42)
	_progress_label.add_theme_font_size_override("font_size", 22)
	_progress_label.add_theme_color_override("font_color", Color(0.95, 0.86, 0.52))
	_ui_layer.add_child(_progress_label)
	_update_progress_label()

	_narrative_panel = Panel.new()
	_narrative_panel.name = "MemoryNarrativePanel"
	_narrative_panel.visible = false
	_narrative_panel.anchor_left = 0.0
	_narrative_panel.anchor_top = 1.0
	_narrative_panel.anchor_right = 1.0
	_narrative_panel.anchor_bottom = 1.0
	_narrative_panel.offset_left = 0.0
	_narrative_panel.offset_top = -200.0
	_narrative_panel.offset_right = 0.0
	_narrative_panel.offset_bottom = 0.0
	_narrative_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_layer.add_child(_narrative_panel)
	_narrative_text = RichTextLabel.new()
	_narrative_panel.add_child(_narrative_text)
	GameUIStyle.apply_interaction_text_panel(_narrative_panel, _narrative_text, 22)

	_left_edge_flash = ColorRect.new()
	_left_edge_flash.name = "LeftEdgeFlash"
	_left_edge_flash.color = Color(1.0, 0.85, 0.2, 0.0)
	_left_edge_flash.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_left_edge_flash.offset_right = 8
	_left_edge_flash.visible = false
	_left_edge_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_left_edge_flash.z_index = 100
	_ui_layer.add_child(_left_edge_flash)
	_left_edge_glow = ColorRect.new()
	_left_edge_glow.name = "LeftEdgeGlow"
	_left_edge_glow.color = Color(1.0, 0.9, 0.3, 0.0)
	_left_edge_glow.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_left_edge_glow.offset_right = 30
	_left_edge_glow.visible = false
	_left_edge_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_left_edge_glow.z_index = 99
	_ui_layer.add_child(_left_edge_glow)

	_right_edge_flash = ColorRect.new()
	_right_edge_flash.name = "RightEdgeFlash"
	_right_edge_flash.color = Color(1.0, 0.85, 0.2, 0.0)
	_right_edge_flash.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_right_edge_flash.offset_left = -8
	_right_edge_flash.visible = false
	_right_edge_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_right_edge_flash.z_index = 100
	_ui_layer.add_child(_right_edge_flash)
	_right_edge_glow = ColorRect.new()
	_right_edge_glow.name = "RightEdgeGlow"
	_right_edge_glow.color = Color(1.0, 0.9, 0.3, 0.0)
	_right_edge_glow.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_right_edge_glow.offset_left = -30
	_right_edge_glow.visible = false
	_right_edge_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_right_edge_glow.z_index = 99
	_ui_layer.add_child(_right_edge_glow)


func _update_progress_label() -> void:
	if not _progress_label:
		return
	_progress_label.text = "记忆回收 Area %02d  %d / %d    击杀进度 %d / %d" % [
		area_index,
		LevelFuzhanSub01.area_collected(area_index),
		LevelFuzhanSub01.required_per_area(),
		_kills_since_drop,
		LevelFuzhanSub01.kills_per_drop(),
	]


func _show_narrative(text: String, callback: Callable = Callable()) -> void:
	if text == "":
		if callback.is_valid():
			callback.call()
		return
	if _narrative_open:
		_close_narrative(false)
	_narrative_pause_guard_token = InputManager.acquire_pause_guard("记忆回收叙事", self)
	_set_enemies_frozen(true)
	_narrative_open = true
	_narrative_enter_pressed = false
	_narrative_arm_remaining = level_data.narrative_input_arm_delay
	_narrative_wait_elapsed = 0.0
	_narrative_poll_elapsed = 0.0
	_narrative_callback = callback
	_narrative_pages.clear()
	_narrative_pages.append_array(GameUIStyle.paginate_interaction_text(text))
	if _narrative_pages.is_empty():
		_narrative_pages.append(text)
	_narrative_page_index = 0
	_show_narrative_page()


func _update_narrative(delta: float) -> void:
	if not _narrative_open or not level_data:
		return
	if _narrative_arm_remaining > 0.0:
		_narrative_arm_remaining = maxf(_narrative_arm_remaining - delta, 0.0)
		if _narrative_arm_remaining <= 0.0:
			_narrative_enter_pressed = false
		return
	_narrative_poll_elapsed += delta
	var poll_interval := maxf(level_data.narrative_poll_interval, 0.001)
	if _narrative_poll_elapsed < poll_interval:
		return
	_narrative_wait_elapsed += _narrative_poll_elapsed
	_narrative_poll_elapsed = 0.0
	if _narrative_enter_pressed:
		_narrative_enter_pressed = false
		if _narrative_page_index < _narrative_pages.size() - 1:
			_narrative_page_index += 1
			_narrative_wait_elapsed = 0.0
			_show_narrative_page()
			return
		_close_narrative(true)
		return
	if _narrative_wait_elapsed >= level_data.memory_narrative_timeout:
		_close_narrative(true)


func _show_narrative_page() -> void:
	if _narrative_panel:
		if _narrative_text:
			GameUIStyle.fit_interaction_text_panel(
				_narrative_panel,
				_narrative_text,
				_narrative_pages[_narrative_page_index]
			)
		_narrative_panel.show()


func _close_narrative(invoke_callback: bool) -> void:
	var callback := _narrative_callback
	_narrative_callback = Callable()
	_narrative_pages.clear()
	_narrative_page_index = 0
	_narrative_arm_remaining = 0.0
	_narrative_wait_elapsed = 0.0
	_narrative_poll_elapsed = 0.0
	_narrative_enter_pressed = false
	_narrative_open = false
	if _narrative_pause_guard_token >= 0:
		InputManager.release_pause_guard_token(_narrative_pause_guard_token)
		_narrative_pause_guard_token = -1
	if _narrative_panel and is_instance_valid(_narrative_panel):
		_narrative_panel.hide()
	if not _transition_running:
		_set_enemies_frozen(false)
	if invoke_callback and callback.is_valid() and is_inside_tree():
		callback.call()


func _set_enemies_frozen(frozen: bool) -> void:
	if _enemies_frozen == frozen:
		return
	_enemies_frozen = frozen
	if _spawn_timer and is_instance_valid(_spawn_timer):
		_spawn_timer.paused = frozen
	for enemy in _enemies:
		if not is_instance_valid(enemy):
			continue
		enemy.set_physics_process(not frozen)
		enemy.set_process(not frozen)
		if frozen:
			enemy.set("velocity", Vector2.ZERO)


func _hide_game_over_panels() -> void:
	var root := get_tree().root
	if not root:
		return
	_hide_game_over_panels_recursive(root)


func _hide_game_over_panels_recursive(node: Node) -> void:
	if node.name == "GameOverPanel" and node is CanvasItem:
		(node as CanvasItem).hide()
	for child in node.get_children():
		_hide_game_over_panels_recursive(child)


func _get_camera_view_rect() -> Rect2:
	var player := GameManager.player_ref
	if not player or not is_instance_valid(player):
		return Rect2()
	var cam := player.get_node_or_null("SmoothCamera") as SmoothCamera
	if not cam:
		return Rect2()
	var half_visible := get_viewport_rect().size * 0.5 / cam.zoom
	var cam_center := cam.global_position + cam.offset
	return Rect2(cam_center - half_visible, half_visible * 2.0)


func _get_pending_drop_for_flash() -> DropItem:
	for drop in _drops:
		if is_instance_valid(drop) and not drop.completed:
			return drop
	return null


func _start_drop_edge_flash() -> void:
	_stop_all_edge_flash()
	var drop := _get_pending_drop_for_flash()
	if not drop:
		return
	var view_rect := _get_camera_view_rect()
	if view_rect.size == Vector2.ZERO:
		return
	if view_rect.has_point(drop.global_position):
		return
	if drop.global_position.x < view_rect.position.x:
		_start_left_edge_flash()
	elif drop.global_position.x > view_rect.position.x + view_rect.size.x:
		_start_right_edge_flash()
	else:
		var view_center_x := view_rect.position.x + view_rect.size.x * 0.5
		if drop.global_position.x < view_center_x:
			_start_left_edge_flash()
		else:
			_start_right_edge_flash()


func _start_left_edge_flash() -> void:
	if _left_edge_flash_active or not _left_edge_flash or not _left_edge_glow:
		return
	_stop_right_edge_flash()
	_left_edge_flash.show()
	_left_edge_glow.show()
	_left_edge_flash.color.a = 0.0
	_left_edge_glow.color.a = 0.0
	var tw := _left_edge_flash.create_tween().set_loops()
	tw.tween_property(_left_edge_flash, "color:a", 0.8, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_left_edge_flash, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	var tw2 := _left_edge_glow.create_tween().set_loops()
	tw2.tween_property(_left_edge_glow, "color:a", 0.25, 0.5).set_trans(Tween.TRANS_SINE)
	tw2.tween_property(_left_edge_glow, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	_left_edge_flash_active = true


func _start_right_edge_flash() -> void:
	if _right_edge_flash_active or not _right_edge_flash or not _right_edge_glow:
		return
	_stop_left_edge_flash()
	_right_edge_flash.show()
	_right_edge_glow.show()
	_right_edge_flash.color.a = 0.0
	_right_edge_glow.color.a = 0.0
	var tw := _right_edge_flash.create_tween().set_loops()
	tw.tween_property(_right_edge_flash, "color:a", 0.8, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_right_edge_flash, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	var tw2 := _right_edge_glow.create_tween().set_loops()
	tw2.tween_property(_right_edge_glow, "color:a", 0.25, 0.5).set_trans(Tween.TRANS_SINE)
	tw2.tween_property(_right_edge_glow, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	_right_edge_flash_active = true


func _check_flash_target_in_view() -> void:
	if not _left_edge_flash_active and not _right_edge_flash_active:
		return
	var drop := _get_pending_drop_for_flash()
	if not drop:
		_stop_all_edge_flash()
		return
	var view_rect := _get_camera_view_rect()
	if view_rect.size == Vector2.ZERO:
		return
	if view_rect.has_point(drop.global_position):
		_stop_all_edge_flash()


func _stop_left_edge_flash() -> void:
	_left_edge_flash_active = false
	if _left_edge_flash:
		_left_edge_flash.hide()
	if _left_edge_glow:
		_left_edge_glow.hide()


func _stop_right_edge_flash() -> void:
	_right_edge_flash_active = false
	if _right_edge_flash:
		_right_edge_flash.hide()
	if _right_edge_glow:
		_right_edge_glow.hide()


func _stop_all_edge_flash() -> void:
	_stop_left_edge_flash()
	_stop_right_edge_flash()


func _cleanup() -> void:
	_close_narrative(false)
	EventBus.unsubscribe_all(self)
	if _spawn_timer and is_instance_valid(_spawn_timer):
		_spawn_timer.stop()
	_enemies.clear()
	_drops.clear()


func _is_loaded_under_main_entry() -> bool:
	var node := get_parent()
	while node:
		if node.name == "MainEntry":
			return true
		node = node.get_parent()
	return false
