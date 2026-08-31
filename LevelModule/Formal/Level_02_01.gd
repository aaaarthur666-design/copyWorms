# ============================================================
# Level_02_01.gd - 第二关分段 01 控制器
# 流程: 老街分段 0-4464 → 右边界切换到 Level_02_02
# ============================================================
extends LevelBase
class_name Level_02_01

@export var level_data: Level02Data = preload("res://DataConfig/Level/Level02Data.tres")

const PAPER_EFFIGY_SCENE_PATH: String = "res://EnemyModule/Formal/Enemy_PaperEffigy.tscn"
const PAPER_EFFIGY_CONFIG_PATH: String = "res://DataConfig/Enemy/PaperEffigyConfig.tres"
const LANTERN_GHOST_SCENE_PATH: String = "res://EnemyModule/Formal/Enemy_LanternGhost.tscn"
const LANTERN_GHOST_CONFIG_PATH: String = "res://DataConfig/Enemy/LanternGhostConfig.tres"

var _exit_trigger: Area2D = null
var _exit_white_overlay: ColorRect = null
var _dynamic_actors: Node2D = null
var _paper_effigy_scene: PackedScene = null
var _paper_effigies: Array[Node2D] = []
var _lantern_ghost_scene: PackedScene = null
var _lantern_ghosts: Array[Node2D] = []
var _level_complete_emitted: bool = false


func _setup_player() -> void:
	if GameManager.player_ref and is_instance_valid(GameManager.player_ref):
		return
	var player_path: String = level_config.player_scene_path if level_config else "res://PlayerModule/Formal/Player_Warrior.tscn"
	if not ResourceLoader.exists(player_path):
		return
	var player = load(player_path).instantiate()
	player.position = _get_spawn_position()
	add_child(player)
	GameManager.register_player(player)


func _on_ready() -> void:
	super._on_ready()
	GameUIStyle.set_ui_theme(GameUIStyle.UI_THEME_LINGNAN)

	_bind_spawn_point()
	_build_collision_bodies()
	_setup_camera_limits()
	_ensure_player_collision_layer()
	_build_exit_trigger()
	_build_dynamic_actors_container()
	_load_enemy_scene()
	_build_enemy_spawn_points()
	_spawn_paper_effigies()
	_spawn_lantern_ghosts()
	_load_hud()
	_build_exit_white_overlay()
	print("[Level_02_01] 初始化完成")


func _setup_camera_limits() -> void:
	if not level_config:
		return
	var player = GameManager.player_ref
	if not player or not is_instance_valid(player):
		return
	var cam = player.get_node_or_null("SmoothCamera") as SmoothCamera
	if not cam:
		return
	cam.limit_left = level_data.segment_01_map_left
	cam.limit_right = level_data.segment_01_map_right
	cam.limit_top = level_data.segment_01_camera_top
	cam.limit_bottom = level_data.segment_01_camera_bottom
	cam.zoom = level_data.segment_01_camera_zoom
	cam.offset = Vector2.ZERO
	cam.lerp_speed = level_data.segment_01_camera_lerp_speed
	cam.bind_target(player)


func _load_hud() -> void:
	var hud_path = "res://UI/HUD.tscn"
	if ResourceLoader.exists(hud_path):
		var hud = load(hud_path).instantiate()
		add_child(hud)
		print("[Level_02_01] HUD 加载成功")
	else:
		push_warning("[Level_02_01] HUD.tscn 未找到，跳过")


func _ensure_player_collision_layer() -> void:
	var player = GameManager.player_ref
	if not player or not is_instance_valid(player):
		return
	if not (player.collision_layer & GlobalDefine.Collision.PLAYER):
		player.collision_layer |= GlobalDefine.Collision.PLAYER


func _build_exit_trigger() -> void:
	var container = _get_or_create_child("TriggerZones", Node2D)

	_exit_trigger = _ensure_trigger_zone(
		container,
		"Level0201ExitTrigger",
		level_data.segment_01_exit_trigger_position,
		level_data.segment_01_exit_trigger_size
	)
	if not _exit_trigger.body_entered.is_connected(_on_exit_trigger_body_entered):
		_exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)


func _create_trigger_zone(zone_name: String, pos: Vector2, size: Vector2) -> Area2D:
	var area = Area2D.new()
	area.name = zone_name
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = GlobalDefine.Collision.PLAYER
	area.monitoring = true
	area.monitorable = false
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	area.add_child(col)
	return area


func _bind_spawn_point() -> void:
	var container = _get_or_create_child("SpawnPoints", Node2D)
	var spawn = container.get_node_or_null("SegmentSpawn") as Marker2D
	if not spawn:
		spawn = Marker2D.new()
		spawn.name = "SegmentSpawn"
		spawn.position = level_data.segment_01_spawn_position
		container.add_child(spawn)
	else:
		spawn.position = level_data.segment_01_spawn_position
	player_spawn_point = spawn


func _get_spawn_position() -> Vector2:
	var spawn = get_node_or_null("SpawnPoints/SegmentSpawn") as Marker2D
	if spawn:
		return spawn.position
	return level_data.segment_01_spawn_position


func _build_collision_bodies() -> void:
	var container = _get_or_create_child("CollisionBodies", Node2D)
	var map_left := level_data.segment_01_map_left
	var map_right := level_data.segment_01_map_right
	_ensure_static_body(container, "SegmentGround", Vector2(float(map_right - map_left) / 2.0, 620), Vector2(map_right - map_left, 40))
	_ensure_static_body(container, "LeftWall", Vector2(map_left - 10, 360), Vector2(20, 720))
	_ensure_static_body(container, "RightWall", Vector2(map_right + 10, 360), Vector2(20, 720))
	_ensure_static_body(container, "UpperWalkwayCollision", Vector2(3620, 420), Vector2(1112, 8))


func _build_dynamic_actors_container() -> void:
	_dynamic_actors = _get_or_create_child("DynamicActors", Node2D) as Node2D


func _load_enemy_scene() -> void:
	if ResourceLoader.exists(PAPER_EFFIGY_SCENE_PATH):
		_paper_effigy_scene = load(PAPER_EFFIGY_SCENE_PATH) as PackedScene
	else:
		push_warning("[Level_02_01] Enemy_PaperEffigy.tscn 不存在，跳过纸符人生成")
	if ResourceLoader.exists(LANTERN_GHOST_SCENE_PATH):
		_lantern_ghost_scene = load(LANTERN_GHOST_SCENE_PATH) as PackedScene
	else:
		push_warning("[Level_02_01] Enemy_LanternGhost.tscn 不存在，跳过灯笼鬼生成")


func _build_enemy_spawn_points() -> void:
	var root = _get_or_create_child("EnemySpawnPoints", Node2D)
	var paper_ground_layer = _get_or_create_child_on(root, "PaperEffigyGroundLayer", Node2D)
	var paper_upper_layer = _get_or_create_child_on(root, "PaperEffigyUpperLayer", Node2D)
	var lantern_ground_layer = _get_or_create_child_on(root, "LanternGhostGroundLayer", Node2D)
	var lantern_upper_layer = _get_or_create_child_on(root, "LanternGhostUpperLayer", Node2D)
	var paper_ground_positions: Array[Vector2] = []
	for x in range(
		level_data.segment_01_map_left + level_data.segment_01_paper_spawn_interval,
		level_data.segment_01_map_right,
		level_data.segment_01_paper_spawn_interval
	):
		paper_ground_positions.append(Vector2(x, level_data.segment_01_enemy_ground_y))
	var paper_upper_positions: Array[Vector2] = []
	for spawn_x in level_data.segment_01_paper_upper_spawn_x:
		paper_upper_positions.append(Vector2(spawn_x, level_data.segment_01_enemy_upper_y))
	var lantern_ground_positions: Array[Vector2] = []
	for x in range(
		level_data.segment_01_map_left + level_data.segment_01_lantern_spawn_interval,
		level_data.segment_01_map_right,
		level_data.segment_01_lantern_spawn_interval
	):
		lantern_ground_positions.append(Vector2(x, level_data.segment_01_enemy_ground_y))
	var lantern_upper_positions: Array[Vector2] = []
	for spawn_x in level_data.segment_01_lantern_upper_spawn_x:
		lantern_upper_positions.append(Vector2(spawn_x, level_data.segment_01_enemy_upper_y))
	_replace_marker_layer(paper_ground_layer, "PaperEffigy_Ground", paper_ground_positions)
	_replace_marker_layer(paper_upper_layer, "PaperEffigy_Upper", paper_upper_positions)
	_replace_marker_layer(lantern_ground_layer, "LanternGhost_Ground", lantern_ground_positions)
	_replace_marker_layer(lantern_upper_layer, "LanternGhost_Upper", lantern_upper_positions)


func _replace_marker_layer(parent: Node, marker_prefix: String, positions: Array[Vector2]) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	for i in range(positions.size()):
		_create_marker(parent, "%s_%02d" % [marker_prefix, i + 1], positions[i])


func _spawn_paper_effigies() -> void:
	if not _paper_effigy_scene:
		return
	var config = load(PAPER_EFFIGY_CONFIG_PATH) as EnemyConfig if ResourceLoader.exists(PAPER_EFFIGY_CONFIG_PATH) else null
	for marker in _get_enemy_spawn_markers("PaperEffigy"):
		var enemy = _paper_effigy_scene.instantiate()
		if config:
			enemy.config = config
		enemy.global_position = marker.global_position
		_dynamic_actors.add_child(enemy)
		_paper_effigies.append(enemy)


func _spawn_lantern_ghosts() -> void:
	if not _lantern_ghost_scene:
		return
	var config = load(LANTERN_GHOST_CONFIG_PATH) as EnemyConfig if ResourceLoader.exists(LANTERN_GHOST_CONFIG_PATH) else null
	for marker in _get_enemy_spawn_markers("LanternGhost"):
		var enemy = _lantern_ghost_scene.instantiate()
		if config:
			enemy.config = config
		enemy.global_position = marker.global_position
		_dynamic_actors.add_child(enemy)
		_lantern_ghosts.append(enemy)


func _get_enemy_spawn_markers(name_prefix: String) -> Array[Marker2D]:
	var markers: Array[Marker2D] = []
	var root = get_node_or_null("EnemySpawnPoints")
	if not root:
		return markers
	for layer in root.get_children():
		for child in layer.get_children():
			if child is Marker2D and child.name.begins_with(name_prefix):
				markers.append(child)
	return markers


func _get_or_create_child(node_name: String, node_type: Variant) -> Node:
	var existing = get_node_or_null(node_name)
	if existing:
		return existing
	var node = node_type.new()
	node.name = node_name
	add_child(node)
	return node


func _get_or_create_child_on(parent: Node, node_name: String, node_type: Variant) -> Node:
	var existing = parent.get_node_or_null(node_name)
	if existing:
		return existing
	var node = node_type.new()
	node.name = node_name
	parent.add_child(node)
	return node


func _create_marker(parent: Node, node_name: String, pos: Vector2) -> Marker2D:
	var marker = Marker2D.new()
	marker.name = node_name
	marker.position = pos
	parent.add_child(marker)
	return marker


func _ensure_static_body(container: Node, node_name: String, pos: Vector2, size: Vector2) -> StaticBody2D:
	var body = container.get_node_or_null(node_name) as StaticBody2D
	if not body:
		body = StaticBody2D.new()
		body.name = node_name
		container.add_child(body)
	body.position = pos
	body.collision_layer = GlobalDefine.Collision.TERRAIN
	body.collision_mask = 0
	var col_shape := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not col_shape:
		col_shape = CollisionShape2D.new()
		col_shape.name = "CollisionShape2D"
		body.add_child(col_shape)
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = size
	col_shape.shape = rect_shape
	return body


func _ensure_trigger_zone(container: Node, zone_name: String, pos: Vector2, size: Vector2) -> Area2D:
	var area = container.get_node_or_null(zone_name) as Area2D
	if not area:
		area = _create_trigger_zone(zone_name, pos, size)
		container.add_child(area)
	area.position = pos
	var collision := area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not collision:
		collision = CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		area.add_child(collision)
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	return area


func _on_exit_trigger_body_entered(body: Node2D) -> void:
	if not _is_player_body(body) or _level_complete_emitted:
		return
	_level_complete_emitted = true
	_exit_trigger.set_deferred("monitoring", false)
	_freeze_player(true)
	InputManager.block_input("终局转场", self)
	_exit_white_overlay.color = Color(1, 1, 1, 0)
	_exit_white_overlay.show()
	var tw = create_tween()
	tw.tween_property(_exit_white_overlay, "color:a", 1.0, level_data.segment_01_whiteout_fade_duration).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(level_data.segment_01_whiteout_duration)
	tw.tween_callback(_emit_level_complete)


func _build_exit_white_overlay() -> void:
	var canvas = _get_or_create_child("CanvasLayerUI", CanvasLayer) as CanvasLayer
	canvas.layer = 2
	_exit_white_overlay = ColorRect.new()
	_exit_white_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_exit_white_overlay.color = Color(1, 1, 1, 0)
	_exit_white_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(_exit_white_overlay)


func _freeze_player(freeze: bool) -> void:
	var player = GameManager.player_ref
	if not player or not is_instance_valid(player):
		return
	# [旧实现 - 保留以备回退] 已迁移至 PlayerBase.set_frozen() 统一处理动画冻结问题
	# if freeze:
	#     player.velocity = Vector2.ZERO
	#     player.set_physics_process(false)
	#     player.set_process_input(false)
	#     if player.has_method("_change_state"):
	#         player._change_state(GlobalDefine.PlayerState.IDLE)
	# else:
	#     player.set_physics_process(true)
	#     player.set_process_input(true)
	player.set_frozen(freeze)


func _is_player_body(body: Node2D) -> bool:
	if not body is CharacterBody2D:
		return false
	if body.collision_layer & GlobalDefine.Collision.PLAYER:
		return true
	return body.is_in_group("player")


func _emit_level_complete() -> void:
	var next_level_path := level_data.segment_01_next_level_path
	get_viewport().gui_release_focus()
	InputManager.force_unblock_all()
	_cleanup_enemies()
	EventBus.unsubscribe_all(self)
	if not _is_loaded_under_main_entry():
		print("[Level_02_01] 无 MainEntry，直接切换场景 → ", next_level_path)
		SceneTransitionManager.request_scene_change(next_level_path, self)
		return
	print("[Level_02_01] 发射 LEVEL_COMPLETE（白屏转场）→ ", next_level_path)
	EventBus.emit(GlobalDefine.EventName.LEVEL_COMPLETE, {
		"level": self,
		"next_level": next_level_path,
		"transition_white": true,
	})


func _is_loaded_under_main_entry() -> bool:
	var node = get_parent()
	while node:
		if node.name == "MainEntry":
			return true
		node = node.get_parent()
	return false


func _cleanup_enemies() -> void:
	for enemy in _paper_effigies:
		if is_instance_valid(enemy):
			GameManager.unregister_enemy(enemy)
			enemy.queue_free()
	_paper_effigies.clear()
	for enemy in _lantern_ghosts:
		if is_instance_valid(enemy):
			GameManager.unregister_enemy(enemy)
			enemy.queue_free()
	_lantern_ghosts.clear()
