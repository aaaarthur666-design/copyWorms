# ============================================================
# Level_04.gd - 第四关「维度侵蚀与空间崩塌」控制器
# ============================================================
extends LevelBase
class_name Level_04

@export var level_data: Level04Data = preload("res://DataConfig/Level/Level04Data.tres")

enum LevelState { HOMOMORPHIC_COMBAT, STAGE2, STAGE3, LEVEL_END_TRANSIT }

var current_state: int = LevelState.HOMOMORPHIC_COMBAT

# ---- 地图切换 ----
var _current_world: int = 0
var _swap_count: int = 0
var _lingnan_spawn_index: int = 0
var _lingnan_enemies_spawned: bool = false
var _lingnan_intro_done: bool = false
var _wall_dialog_shown: bool = false
var _cyber_return_dialog_shown: bool = false
var _swap_cooldown: float = 0.0
var _hurt_swap_pending: bool = false
var _stage1_enemies: Array[Node2D] = []
var _stage2_entered: bool = false

# ---- 坠落死亡延迟（仅限死亡区域，让玩家掉出视野后再显示失败面板） ----
var _fall_death_pending: bool = false
var _fall_death_timer: float = 0.0

# ---- 阶段2 自动世界切换 ----
var _stage2_auto_swap: bool = false
var _stage2_swap_timer: float = 0.0
var _stage2_warning_active: bool = false
var _stage2_current_map: int = 0  # 0=岭南(bg 2-1), 1=赛博(bg 2-2)
var _stage2_warning_tween: Tween = null
var _stage2_warning_overlay: ColorRect = null
var _stage2_pulse_tween: Tween = null
var _stage2_alarm_player: AudioStreamPlayer = null
var _stage2_alarm_playback: AudioStreamGeneratorPlayback = null
var _stage2_alarm_phase: float = 0.0
var _stage2_pulse_phase: float = 0.0

# ---- 侵蚀值系统 ----
var _erosion_value: float = 0.0
var _erosion_bar_bg: ColorRect = null
var _erosion_bar_fill: ColorRect = null
var _erosion_label: Label = null
var _erosion_vignette: ColorRect = null

# ---- 阶段2敌人 + 阶段3 ----
var _stage2_lingnan_enemies: Array[Node2D] = []
var _stage2_cyber_enemies: Array[Node2D] = []
var _enemy_lantern_scene: PackedScene = null
var _enemy_paper_effigy_scene: PackedScene = null
var _enemy_cyber_bull_scene: PackedScene = null
var _stage3_entered: bool = false

# ---- 交互物 ----
var _all_interactives: Array[InteractiveObject] = []

# ---- 场景节点 ----
var _dynamic_actors: Node2D = null

# ---- UI ----
var _narrative_panel: Panel = null
var _narrative_text: RichTextLabel = null
var _code_rain_overlay: CodeRain = null
var _glitch_overlay: ColorRect = null
var _ending_prompt: Control = null
var _ending_label: Label = null

# ---- 叙事 ----
var _is_interacting: bool = false
var _narrative_open: bool = false
var _narrative_enter_pressed: bool = false
var _narrative_pages: Array[String] = []
var _narrative_page_index: int = 0
var _narrative_arm_remaining: float = 0.0
var _narrative_wait_elapsed: float = 0.0
var _narrative_poll_elapsed: float = 0.0
var _narrative_callback: Callable = Callable()

# ---- 右侧边缘闪烁光效（引导玩家找到 IA_Stage3） ----
var _right_edge_flash: ColorRect = null
var _right_edge_glow: ColorRect = null
var _right_edge_flash_active: bool = false

# ---- 敌人 ----
var _enemy_cyber_wolf_scene: PackedScene = null

# ---- 终局 ----
var _ending_enter_armed: bool = false
var _level_complete_emitted: bool = false

# ---- 浮动文字 ----
var _float_text: Label = null
var _float_text_timer: float = 0.0


# ============================================================
# 生命周期
# ============================================================

func _setup_player() -> void:
	if GameManager.player_ref and is_instance_valid(GameManager.player_ref):
		return
	if not level_config:
		push_error("[Level_04] 缺少 LevelConfig，无法创建玩家")
		return
	var path = level_config.player_scene_path
	if ResourceLoader.exists(path):
		var p = load(path).instantiate()
		p.position = level_config.spawn_point
		add_child(p)
		GameManager.register_player(p)

func _swap_player_skin(skin: String) -> void:
	var old = GameManager.player_ref
	if not old or not is_instance_valid(old): return
	GameUIStyle.set_ui_theme(GameUIStyle.UI_THEME_LINGNAN if skin == "Lingnan" else GameUIStyle.UI_THEME_CYBER)
	var h = old.current_health; var m = old.max_health
	var f = old.is_facing_right; var pos = old.global_position
	# 先断开旧玩家信号
	if InputManager.game_action.is_connected(old._on_game_action):
		InputManager.game_action.disconnect(old._on_game_action)
	# 先创建新玩家，再释放旧的（避免 player_ref=null 的空窗期）
	var path = level_data.lingnan_player_scene_path if skin == "Lingnan" else level_data.cyber_player_scene_path
	if not ResourceLoader.exists(path): return
	var p = load(path).instantiate()
	p.global_position = pos; p.current_health = h
	p.max_health = m; p.is_facing_right = f; p.velocity = Vector2.ZERO
	# 暂时移除旧玩家引用，避免 add_child 触发 _ready 时 register_player 冲突
	GameManager.player_ref = null
	add_child(p)
	GameManager.register_player(p)
	# 释放旧玩家（先禁用处理，再释放，避免释放前被访问）
	old.set_physics_process(false)
	old.set_process(false)
	old.queue_free()
	# _ready 中 _apply_config 会重置血量为 max_health，需在此之后恢复
	p.current_health = h
	p.max_health = m
	# 推送血量到 HUD（修复换皮肤后血条不更新）
	EventBus.emit(GlobalDefine.EventName.HEALTH_CHANGED, {
		"target": p,
		"current_health": p.current_health,
		"max_health": p.max_health
	})

func _on_ready() -> void:
	super._on_ready()
	GameUIStyle.set_ui_theme(GameUIStyle.UI_THEME_CYBER)
	# 入场黑屏遮罩（初始化在黑屏下进行，末尾淡出呈现关卡）
	_play_intro_fade_in()
	if not level_config: level_config = load("res://DataConfig/Level/Level04Config.tres") as LevelConfig; _apply_config()
	if not level_data:  level_data  = load("res://DataConfig/Level/Level04Data.tres") as Level04Data
	if not level_config or not level_data:
		push_error("[Level_04] 必需的 LevelConfig/Level04Data 加载失败，停止初始化")
		return

	var wolf = "res://EnemyModule/Formal/Enemy_CyberWolf.tscn"
	if ResourceLoader.exists(wolf): _enemy_cyber_wolf_scene = load(wolf)
	var lantern = "res://EnemyModule/Formal/Enemy_LanternGhost.tscn"
	if ResourceLoader.exists(lantern): _enemy_lantern_scene = load(lantern)
	var paper = "res://EnemyModule/Formal/Enemy_PaperEffigy.tscn"
	if ResourceLoader.exists(paper): _enemy_paper_effigy_scene = load(paper)
	var bull = "res://EnemyModule/Formal/Enemy_CyberBull.tscn"
	if ResourceLoader.exists(bull): _enemy_cyber_bull_scene = load(bull)

	Level_04_SceneBuilder.new(self).build_all()
	_setup_camera_limits()
	_set_cam_from_group($Stage1Collisions, level_data.stage_1_camera_top)
	_cache_ui_refs()
	_start_code_rain()
	# 收集交互物引用 + 启动闪烁动画
	for c in get_node_or_null("Interactives").get_children():
		if c is InteractiveObject:
			_all_interactives.append(c)
			var ind = c.get_node_or_null("Indicator")
			var glw = c.get_node_or_null("Glow")
			if ind:
				var tw = ind.create_tween().set_loops()
				tw.tween_property(ind, "color:a", 0.2, 0.6).set_trans(Tween.TRANS_SINE)
				tw.tween_property(ind, "color:a", 0.9, 0.6).set_trans(Tween.TRANS_SINE)
			if glw:
				var tw2 = glw.create_tween().set_loops()
				tw2.tween_property(glw, "color:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
				tw2.tween_property(glw, "color:a", 0.3, 0.6).set_trans(Tween.TRANS_SINE)
	var wt = get_node_or_null("Stage1Collisions/WallTrigger")
	if wt: wt.body_entered.connect(_on_wall_trigger)
	_ensure_player_collision_layer()
	_connect_kill_zones()
	_build_erosion_ui()

	EventBus.subscribe(GlobalDefine.EventName.INTERACTIVE_OBJECT_TRIGGERED, self, "_on_object_interacted")
	EventBus.subscribe(GlobalDefine.EventName.PLAYER_ATTACK_HIT, self, "_on_combat_hit")
	EventBus.subscribe(GlobalDefine.EventName.PLAYER_HURT, self, "_on_combat_hit")
	EventBus.subscribe(GlobalDefine.EventName.ENEMY_DIED, self, "_on_enemy_died")

	if not InputManager.game_action.is_connected(_on_game_action):
		InputManager.game_action.connect(_on_game_action)

	_load_hud(); set_process(true)
	# 初始化完成，淡出黑屏呈现关卡
	_finish_intro_fade_in()

	if level_data and level_data.anchor_narrative != "":
		_show_narrative(level_data.opening_protocol_text, _show_opening_anchor_narrative)
	else:
		_spawn_stage1_enemies(); _restore_combat_mechanics()
	print("[Level_04] 初始化完成")
	# 调试：阶段测试面板（按0开关）
	if GameManager.dev_tools_enabled():
		_setup_stage_test_panel()


func _setup_stage_test_panel() -> void:
	var script = load("res://Tools/StageTestPanel.gd")
	if not script:
		push_error("[Level_04] 无法加载 StageTestPanel.gd")
		return
	var panel = script.new(self, [
		{"name": "阶段1: 同构战斗", "action": func(): _goto_stage1_test()},
		{"name": "阶段2: 世界切换", "action": func(): _goto_stage2_test()},
		{"name": "阶段3: 出口交互", "action": func(): _goto_stage3_test()},
	])
	add_child(panel)


func _exit_tree() -> void:
	_disconnect_input_manager()


func prepare_for_level_exit() -> void:
	_full_cleanup()


func _show_opening_anchor_narrative() -> void:
	if not is_inside_tree() or not level_data:
		return
	_show_narrative(
		"[color=goldenrod]阿明：[/color]" + level_data.anchor_narrative,
		_pan_opening_camera
	)


func _pan_opening_camera() -> void:
	if not is_inside_tree() or not level_data:
		return
	_pan_camera_to(level_data.stage_1_intro_pan_target, _finish_opening_sequence)


func _finish_opening_sequence() -> void:
	if not is_inside_tree():
		return
	_spawn_stage1_enemies()
	_restore_combat_mechanics()


func _disconnect_input_manager() -> void:
	if InputManager.game_action.is_connected(_on_game_action):
		InputManager.game_action.disconnect(_on_game_action)


func _get_or_create_child(node_name: String, node_type) -> Node:
	var e = get_node_or_null(node_name); if e: return e
	var n = node_type.new(); n.name = node_name; add_child(n); return n

## 入场黑屏遮罩：创建满黑 CanvasLayer，覆盖整个初始化过程
func _play_intro_fade_in() -> void:
	var cv = CanvasLayer.new()
	cv.name = "IntroFadeCanvas"
	cv.layer = 2000
	add_child(cv)
	var black = ColorRect.new()
	black.name = "IntroFadeBlack"
	cv.add_child(black)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black.color = Color(0, 0, 0, 1.0)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE

## 初始化完成后淡出黑屏（1.5s），完成后自动清理遮罩节点
func _finish_intro_fade_in() -> void:
	var cv = get_node_or_null("IntroFadeCanvas")
	if not cv: return
	var black = cv.get_node_or_null("IntroFadeBlack")
	if not black: return
	var tw = black.create_tween()
	tw.tween_property(black, "color:a", 0.0, level_data.intro_fade_duration).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(cv.queue_free)

func _load_hud() -> void:
	var p = "res://UI/HUD.tscn"
	if ResourceLoader.exists(p):
		add_child(load(p).instantiate())
		# 立即推送当前血量到 HUD
		var pl = GameManager.player_ref
		if pl and is_instance_valid(pl):
			EventBus.emit(GlobalDefine.EventName.HEALTH_CHANGED, {
				"target": pl,
				"current_health": pl.current_health,
				"max_health": pl.max_health
			})

func _cache_ui_refs() -> void:
	var c = $CanvasLayerUI
	if not c: return
	_narrative_panel = c.get_node_or_null("NarrativePanel")
	if _narrative_panel: _narrative_text = _narrative_panel.get_node_or_null("RichTextLabel")
	_code_rain_overlay = c.get_node_or_null("CodeRainOverlay")
	_glitch_overlay = c.get_node_or_null("GlitchOverlay")
	_ending_prompt = c.get_node_or_null("EndingPrompt")
	if _ending_prompt: _ending_label = _ending_prompt.get_node_or_null("EndingLabel")

func _start_code_rain() -> void:
	if _code_rain_overlay and is_instance_valid(_code_rain_overlay):
		_code_rain_overlay.start_rain()

func _stop_code_rain(immediate: bool = false) -> void:
	if _code_rain_overlay and is_instance_valid(_code_rain_overlay):
		_code_rain_overlay.stop_rain(immediate)



# ============================================================
# 输入
# ============================================================

func _on_game_action(action: StringName, _event: InputEvent) -> void:
	if action != &"ui_accept": return
	if current_state == LevelState.LEVEL_END_TRANSIT:
		if _ending_enter_armed: _ending_enter_armed = false; _emit_level_complete()
		return
	if _narrative_open: _narrative_enter_pressed = true; return

func _input(event: InputEvent) -> void:
	# 游戏结束后禁止所有输入
	if GameManager.is_game_over: return
	# 鼠标左键等价于Enter（对话推进/交互触发）
	var is_left_click: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if not event.is_action_pressed("ui_accept") and not is_left_click: return
	if current_state == LevelState.LEVEL_END_TRANSIT:
		if _ending_enter_armed: _ending_enter_armed = false; _emit_level_complete(); get_viewport().set_input_as_handled()
		return
	if _narrative_open: _narrative_enter_pressed = true; get_viewport().set_input_as_handled(); return
	var obj = _find_nearby_interactive()
	if obj:
		EventBus.emit(GlobalDefine.EventName.INTERACTIVE_OBJECT_TRIGGERED, {"object_id": obj.object_id})
		get_viewport().set_input_as_handled()


func _find_nearby_interactive() -> InteractiveObject:
	for obj in _all_interactives:
		if is_instance_valid(obj) and obj.is_active and not obj.completed and obj.is_player_in_range:
			return obj
	var p = GameManager.player_ref
	if not p or not is_instance_valid(p): return null
	var best: InteractiveObject = null; var best_dist: float = INF
	for obj in _all_interactives:
		if not is_instance_valid(obj) or not obj.is_active or obj.completed: continue
		var d = p.global_position.distance_to(obj.global_position)
		if d < level_data.interaction_fallback_radius and d < best_dist: best_dist = d; best = obj
	if best: best.is_player_in_range = true
	return best


func _poll_interactives_in_range() -> void:
	var p = GameManager.player_ref
	if not p or not is_instance_valid(p): return
	for obj in _all_interactives:
		if is_instance_valid(obj): obj.check_player_in_range(p)

func _on_object_interacted(data: Dictionary) -> void:
	var oid: String = data.get("object_id", "")
	if oid == "guide":
		if _float_text: _float_text.visible = false
		_show_narrative(level_data.guide_text)
	elif oid == "greeting":
		_show_floating_text("晚上好，椰汁城")
	elif oid == "enter_stage2":
		_enter_stage2()
	elif oid == "enter_stage3":
		_enter_stage3()


# ============================================================
# 每帧
# ============================================================

func _process(delta: float) -> void:
	_update_narrative(delta)
	# 切换冷却计数
	if _swap_cooldown > 0.0: _swap_cooldown -= delta

	# 坠落死亡延迟倒计时：让玩家掉落出视野后再触发失败
	# 期间世界的物理过程继续运行（玩家继续下坠），但世界切换/侵蚀停止
	if _fall_death_pending:
		_fall_death_timer -= delta
		if _fall_death_timer <= 0.0:
			_fall_death_pending = false
			GameManager.trigger_game_over()
		# 坠落延迟期间仅更新交互物轮询，跳过世界切换/侵蚀等
		_poll_interactives_in_range()
		return

	# 游戏结束后停止世界自动切换、侵蚀增长等（但保留坠落动画播放）
	if GameManager.is_game_over:
		_poll_interactives_in_range()
		return

	# 阶段2 自动世界切换计时
	if _stage2_auto_swap and current_state == LevelState.STAGE2 and not _narrative_open:
		_stage2_swap_timer -= delta
		if not _stage2_warning_active and _stage2_swap_timer <= level_data.stage_2_warning_time:
			_stage2_warning_active = true
			_start_stage2_warning()
		if _stage2_warning_active:
			_process_stage2_alarm()
		if _stage2_swap_timer <= 0.0:
			_stage2_swap_timer = 0.0
			_stage2_warning_active = false
			_perform_stage2_swap()
			_start_stage2_swap_timer()

	# 侵蚀值随时间增长（全阶段生效，终局除外）
	if current_state != LevelState.LEVEL_END_TRANSIT:
		_modify_erosion(level_data.erosion_rate * delta)

	# bg 2-2 掉落死亡 Y 轴兜底检测
	_check_fall_death()

	# 阶段2敌人垂直不可达检测（防止来回转向）
	if current_state == LevelState.STAGE2:
		_check_enemy_vertical_reachability()

	# 交互物轮询
	_poll_interactives_in_range()

	# 浮动文字计时
	if _float_text_timer > 0.0:
		_float_text_timer -= delta
		if _float_text_timer <= 0.0 and _float_text:
			_float_text.visible = false
		elif _float_text:
			var p = GameManager.player_ref
			if p and is_instance_valid(p):
				_float_text.global_position = p.global_position + Vector2(-40, -60)

	# 交互冷却后安全退出
	if _is_interacting and not _narrative_open:
		_is_interacting = false

	# 右侧边缘闪烁：检测 IA_Stage3 目标是否入镜
	if _right_edge_flash_active:
		_check_stage3_in_view()






func _show_floating_text(txt: String) -> void:
	if not _float_text:
		_float_text = Label.new()
		_float_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_float_text.add_theme_font_size_override("font_size", 24)
		_float_text.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
		_float_text.size = Vector2(200, 30)
		add_child(_float_text)
	_float_text.text = txt
	_float_text.visible = true
	var p = GameManager.player_ref
	if p and is_instance_valid(p):
		_float_text.global_position = p.global_position + Vector2(-40, -60)
	_float_text_timer = level_data.floating_text_duration


# ============================================================
# 其余函数
# ============================================================

func _ensure_player_collision_layer() -> void:
	var p = GameManager.player_ref
	if p and is_instance_valid(p) and not (p.collision_layer & GlobalDefine.Collision.PLAYER):
		p.collision_layer |= GlobalDefine.Collision.PLAYER

func _setup_camera_limits() -> void:
	if not level_config: return
	var p = GameManager.player_ref; if not p or not is_instance_valid(p): return
	var c = p.get_node_or_null("SmoothCamera") as SmoothCamera; if not c: return
	c.limit_left = level_config.camera_limit_left; c.limit_right = level_config.camera_limit_right
	c.limit_top = level_config.camera_limit_top; c.limit_bottom = level_config.camera_limit_bottom

func _set_camera_limits(l: int, r: int, t: int, b: int) -> void:
	var p = GameManager.player_ref; if not p or not is_instance_valid(p): return
	var c = p.get_node_or_null("SmoothCamera") as SmoothCamera; if not c: return
	c.limit_left = l; c.limit_right = r; c.limit_top = t; c.limit_bottom = b

## 遍历容器内所有 StaticBody2D 的 RectangleShape2D，取世界坐标 AABB 并集
func _collision_group_rect(group: Node) -> Rect2:
	var rect := Rect2()
	var first := true
	if not group or not is_instance_valid(group): return rect
	for body in group.get_children():
		if body is StaticBody2D:
			for c in body.get_children():
				if c is CollisionShape2D and c.shape is RectangleShape2D:
					var rs := c.shape as RectangleShape2D
					var center: Vector2 = (body as Node2D).global_position + (c as CollisionShape2D).position
					var r := Rect2(center - rs.size / 2.0, rs.size)
					if first: rect = r; first = false
					else: rect = rect.merge(r)
	return rect

## 从碰撞体容器自动计算 AABB 设置摄像机边界（左边界统一 0，上边界手动指定）
## extra_group 可选：合并第二个容器（如边界墙）的 AABB
## bottom 可选：手动指定下边界（>=0 时生效，避免墙体高度拉低边界）
func _set_cam_from_group(group: Node, top: int, extra_group: Node = null, bottom: int = -1) -> void:
	if not group or not is_instance_valid(group): return
	var rect := _collision_group_rect(group)
	if extra_group and is_instance_valid(extra_group):
		var extra := _collision_group_rect(extra_group)
		if extra.has_area():
			rect = rect.merge(extra)
	var b: int = bottom if bottom >= 0 else int(rect.end.y)
	_set_camera_limits(0, int(rect.end.x), top, b)

func _restore_combat_mechanics() -> void:
	var p = GameManager.player_ref; if not p: return
	p.can_attack = true; p.can_dash = true; p.can_skill = true

func _freeze_player(f: bool) -> void:
	var p = GameManager.player_ref; if not p: return
	# [旧实现 - 保留以备回退] 已迁移至 PlayerBase.set_frozen() 统一处理动画冻结问题
	# if f:
	#     p.velocity = Vector2.ZERO; p.set_physics_process(false); p.set_process_input(false)
	#     p._change_state(GlobalDefine.PlayerState.IDLE)
	# else:
	#     p.set_physics_process(true); p.set_process_input(true)
	p.set_frozen(f)


# ---- 叙事 ----

func _show_narrative(text: String, cb: Callable = Callable()) -> void:
	if not level_data:
		return
	if _narrative_open:
		_close_narrative(false)
	InputManager.block_input("叙事面板", self)
	_is_interacting = true
	_narrative_open = true
	_narrative_enter_pressed = false
	_narrative_arm_remaining = level_data.narrative_input_arm_delay
	_narrative_wait_elapsed = 0.0
	_narrative_poll_elapsed = 0.0
	_narrative_callback = cb
	GameManager.begin_dialog(self)
	_freeze_player(true)
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
	if _narrative_wait_elapsed >= level_data.narrative_input_timeout:
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
	var was_open := _narrative_open
	_narrative_callback = Callable()
	_narrative_pages.clear()
	_narrative_page_index = 0
	_narrative_arm_remaining = 0.0
	_narrative_wait_elapsed = 0.0
	_narrative_poll_elapsed = 0.0
	_narrative_enter_pressed = false
	_narrative_open = false
	if _narrative_panel and is_instance_valid(_narrative_panel):
		_narrative_panel.hide()
	_freeze_player(false)
	if was_open:
		GameManager.end_dialog(self)
		InputManager.unblock_input("叙事面板", self)
	_is_interacting = false
	if invoke_callback and callback.is_valid() and is_inside_tree():
		callback.call()


# ---- 地图切换 ----

func _on_combat_hit(data: Dictionary) -> void:
	if current_state != LevelState.HOMOMORPHIC_COMBAT: return
	if _stage2_entered: return
	if _narrative_open or _is_interacting: return
	if _hurt_swap_pending: return
	if _swap_cooldown > 0.0: return
	_swap_cooldown = level_data.world_swap_cooldown
	# 玩家受击：延迟切换（先播放受击反馈）
	if data.has("current_health"):
		if int(data.get("current_health", 1)) <= 0:
			return  # 玩家死亡不切换
		var hurt_player = data.get("player", GameManager.player_ref)
		if hurt_player and is_instance_valid(hurt_player):
			_prime_hurt_feedback_before_swap(hurt_player)
		_hurt_swap_pending = true
		await get_tree().create_timer(level_data.hurt_swap_delay).timeout
		_hurt_swap_pending = false
		# await 后重新检查状态（期间可能进入stage2/对话/死亡）
		if current_state != LevelState.HOMOMORPHIC_COMBAT: return
		if _stage2_entered: return
		if _narrative_open: return
		if GameManager.is_game_over: return
		var p = GameManager.player_ref
		if not p or not is_instance_valid(p): return
	# 执行世界切换
	_swap_world()


func _prime_hurt_feedback_before_swap(player: Node) -> void:
	if player.has_method("_change_state"):
		player.call("_change_state", GlobalDefine.PlayerState.HURT)
	if player.has_method("_update_animation"):
		player.call("_update_animation")


func _on_wall_trigger(_body: Node2D) -> void:
	if _wall_dialog_shown: return
	_wall_dialog_shown = true
	_show_narrative(level_data.wall_block_text)

func _swap_world() -> void:
	var p = GameManager.player_ref; if not p or not is_instance_valid(p): return
	_flash_screen()

	if _current_world == 0:
		var tgt = level_data.lingnan_swap_positions[_lingnan_spawn_index]
		var dia = level_data.lingnan_swap_dialogues[_lingnan_spawn_index]
		_lingnan_spawn_index = (_lingnan_spawn_index + 1) % level_data.lingnan_swap_positions.size()
		p.global_position = tgt; _current_world = 1
		_swap_player_skin("Lingnan"); p = GameManager.player_ref
		p.velocity = Vector2.ZERO
		_snap_camera(p)
		_set_cam_from_group($LingnanCollisions, level_data.lingnan_camera_top)
		if not _lingnan_intro_done:
			_lingnan_intro_done = true
			_pan_camera_to(level_data.lingnan_intro_pan_target)
		_spawn_lingnan_enemies_once()
		if dia != "":
			_schedule_world_narrative("[color=cyan]阿明：[/color]" + dia, 1)
	else:
		p.global_position = level_data.cyber_teleport; _current_world = 0
		_swap_player_skin("Cyber"); p = GameManager.player_ref
		p.velocity = Vector2.ZERO
		_snap_camera(p)
		_set_cam_from_group($Stage1Collisions, level_data.stage_1_camera_top)
		if not _cyber_return_dialog_shown:
			_cyber_return_dialog_shown = true
			_schedule_world_narrative(level_data.cyber_return_dialogue, 0)
	_swap_count += 1


func _schedule_world_narrative(text: String, expected_world: int) -> void:
	var timer := Timer.new()
	timer.name = "WorldNarrativeTimer"
	timer.one_shot = true
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.timeout.connect(
		_on_world_narrative_timeout.bind(timer, text, expected_world),
		CONNECT_ONE_SHOT
	)
	add_child(timer)
	timer.start(level_data.post_swap_dialogue_delay)


func _on_world_narrative_timeout(timer: Timer, text: String, expected_world: int) -> void:
	if is_instance_valid(timer):
		timer.queue_free()
	if not is_inside_tree() or _current_world != expected_world or _narrative_open:
		return
	_show_narrative(text)

func _snap_camera(p: CharacterBody2D) -> void:
	var c = p.get_node_or_null("SmoothCamera")
	if c: c.global_position = p.global_position


# ---- 阶段2 ----

func _enter_stage2() -> void:
	if _stage2_entered: return
	_stage2_entered = true
	_is_interacting = true
	_freeze_player(true)
	# 黑屏淡入
	var blk = _create_black_overlay()
	if not blk: _freeze_player(false); _is_interacting = false; return
	await get_tree().create_tween().tween_property(blk, "color", Color.BLACK, level_data.stage_2_transition_fade_duration).finished
	# 传送（await 后重新获取玩家引用，避免旧引用已释放）
	var p = GameManager.player_ref
	if not p or not is_instance_valid(p):
		blk.queue_free(); _freeze_player(false); _is_interacting = false; return
	p.global_position = level_data.stage_2_spawn; p.velocity = Vector2.ZERO
	_snap_camera(p)
	_swap_player_skin("Lingnan")
	p = GameManager.player_ref
	if not p or not is_instance_valid(p):
		blk.queue_free(); _freeze_player(false); _is_interacting = false; return
	_set_camera_limits(
		level_data.stage_2_lingnan_camera_left,
		level_data.stage_2_lingnan_camera_right,
		level_data.stage_2_lingnan_camera_top,
		level_data.stage_2_lingnan_camera_bottom
	)
	current_state = LevelState.STAGE2
	for e in _stage1_enemies:
		if is_instance_valid(e): e.queue_free()
	_stage1_enemies.clear()
	# 黑屏淡出
	await get_tree().create_tween().tween_property(blk, "color:a", 0.0, level_data.stage_2_transition_fade_duration).finished
	blk.queue_free()
	_freeze_player(false)
	_is_interacting = false
	_stage2_current_map = 0
	_start_stage2_swap_timer()
	_spawn_stage2_enemies()
	_start_right_edge_flash()
	_show_narrative(level_data.stage_2_entry_text)

func _create_black_overlay() -> ColorRect:
	var cv = $CanvasLayerUI
	if not cv: return null
	var f = ColorRect.new()
	f.name = "Blackout"; f.set_anchors_preset(Control.PRESET_FULL_RECT)
	f.color = Color(0, 0, 0, 0); f.mouse_filter = Control.MOUSE_FILTER_IGNORE; f.z_index = 200
	cv.add_child(f)
	return f


# ============================================================
# 阶段2 自动世界切换
# ============================================================

func _start_stage2_swap_timer() -> void:
	_stage2_auto_swap = true
	_stage2_warning_active = false
	_stage2_swap_timer = randf_range(level_data.stage_2_swap_interval_min, level_data.stage_2_swap_interval_max)
	print("[Level_04] 阶段2 下次世界切换: %.1f 秒后" % _stage2_swap_timer)

func _start_stage2_warning() -> void:
	# ---- 视觉：glitch 强度渐升 ----
	if _glitch_overlay and _glitch_overlay.material:
		_glitch_overlay.show()
		var m = _glitch_overlay.material as ShaderMaterial
		m.set_shader_parameter("intensity", 0.0)
		if _stage2_warning_tween and _stage2_warning_tween.is_valid():
			_stage2_warning_tween.kill()
		_stage2_warning_tween = create_tween()
		_stage2_warning_tween.tween_method(
			func(v: float) -> void: m.set_shader_parameter("intensity", v),
			0.0, 0.85, level_data.stage_2_warning_time
		).set_trans(Tween.TRANS_QUAD)

	# ---- 视觉：目标地图主题色脉冲覆盖 ----
	var cv = get_node_or_null("CanvasLayerUI")
	if cv:
		if _stage2_warning_overlay:
			_stage2_warning_overlay.queue_free()
		_stage2_warning_overlay = ColorRect.new()
		_stage2_warning_overlay.name = "Stage2WarnPulse"
		_stage2_warning_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		_stage2_warning_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage2_warning_overlay.z_index = 150
		# 岭南→赛博: 青色; 赛博→岭南: 深墨色
		var base: Color = Color(0.1, 0.7, 0.95) if _stage2_current_map == 0 else Color(0.12, 0.08, 0.3)
		_stage2_warning_overlay.color = Color(base.r, base.g, base.b, 0.0)
		cv.add_child(_stage2_warning_overlay)
		if _stage2_pulse_tween and _stage2_pulse_tween.is_valid():
			_stage2_pulse_tween.kill()
		_stage2_pulse_tween = create_tween().set_loops()
		_stage2_pulse_tween.tween_property(_stage2_warning_overlay, "color:a", 0.28, 0.16).set_trans(Tween.TRANS_SINE)
		_stage2_pulse_tween.tween_property(_stage2_warning_overlay, "color:a", 0.0, 0.16).set_trans(Tween.TRANS_SINE)

	# ---- 音效：程序化警报 ----
	_start_stage2_alarm()
	print("[Level_04] [WARN] 阶段2 世界切换预警启动！")

func _stop_stage2_warning() -> void:
	# 停止 glitch
	if _stage2_warning_tween and _stage2_warning_tween.is_valid():
		_stage2_warning_tween.kill()
		_stage2_warning_tween = null
	if _glitch_overlay and _glitch_overlay.material:
		var m = _glitch_overlay.material as ShaderMaterial
		m.set_shader_parameter("intensity", 0.0)
		_glitch_overlay.hide()
	# 停止脉冲
	if _stage2_pulse_tween and _stage2_pulse_tween.is_valid():
		_stage2_pulse_tween.kill()
		_stage2_pulse_tween = null
	if _stage2_warning_overlay:
		_stage2_warning_overlay.queue_free()
		_stage2_warning_overlay = null
	# 停止警报
	_stop_stage2_alarm()

func _perform_stage2_swap() -> void:
	var p = GameManager.player_ref
	if not p or not is_instance_valid(p):
		_stop_stage2_warning()
		return
	# 保留速度以支持滞空操作连贯性
	var old_vel: Vector2 = p.velocity
	_stop_stage2_warning()
	_flash_screen()

	if _stage2_current_map == 0:
		# 岭南 → 赛博
		_stage2_current_map = 1
		p.global_position.y += level_data.stage_2_map_offset
		_swap_player_skin("Cyber")
		p = GameManager.player_ref
		if p and is_instance_valid(p):
			p.velocity = old_vel
		_set_cam_from_group(
			$Stage2_CyberCollisions,
			level_data.stage_2_cyber_camera_top,
			$Stage2_CyberBorders,
			level_data.stage_2_cyber_camera_bottom
		)
	else:
		# 赛博 → 岭南
		_stage2_current_map = 0
		p.global_position.y -= level_data.stage_2_map_offset
		_swap_player_skin("Lingnan")
		p = GameManager.player_ref
		if p and is_instance_valid(p):
			p.velocity = old_vel
		_set_camera_limits(
			level_data.stage_2_lingnan_camera_left,
			level_data.stage_2_lingnan_camera_right,
			level_data.stage_2_lingnan_camera_top,
			level_data.stage_2_lingnan_camera_bottom
		)

	if p and is_instance_valid(p):
		_snap_camera(p)
	print("[Level_04] 阶段2 世界切换完成 → %s" % ("赛博" if _stage2_current_map == 1 else "岭南"))

func _start_stage2_alarm() -> void:
	if not _stage2_alarm_player:
		_stage2_alarm_player = AudioStreamPlayer.new()
		_stage2_alarm_player.name = "Stage2Alarm"
		var gen = AudioStreamGenerator.new()
		gen.mix_rate = 44100
		gen.buffer_length = 0.1
		_stage2_alarm_player.stream = gen
		_stage2_alarm_player.volume_db = -4.0
		add_child(_stage2_alarm_player)
	_stage2_alarm_player.play()
	_stage2_alarm_playback = _stage2_alarm_player.get_stream_playback() as AudioStreamGeneratorPlayback
	_stage2_alarm_phase = 0.0
	_stage2_pulse_phase = 0.0

func _process_stage2_alarm() -> void:
	if not _stage2_alarm_playback: return
	var frames = _stage2_alarm_playback.get_frames_available()
	# 已经过的预警时间（0 → 2.5）
	var elapsed: float = level_data.stage_2_warning_time - maxf(_stage2_swap_timer, 0.0)
	# 脉冲频率随时间递增：3Hz → 13Hz
	var pulse_rate: float = 3.0 + elapsed * 4.0
	# 基音频率随时间微升：280Hz → 480Hz
	var base_freq: float = 280.0 + elapsed * 80.0
	var sr: float = 44100.0
	for i in frames:
		var pulse: float = sin(_stage2_pulse_phase) * 0.5 + 0.5
		var sample: float = sin(_stage2_alarm_phase) * 0.18 * (0.3 + pulse * 0.7)
		_stage2_alarm_phase += TAU * base_freq / sr
		_stage2_pulse_phase += TAU * pulse_rate / sr
		_stage2_alarm_playback.push_frame(Vector2(sample, sample))

func _stop_stage2_alarm() -> void:
	if _stage2_alarm_player and _stage2_alarm_player.playing:
		_stage2_alarm_player.stop()
	_stage2_alarm_playback = null


# ============================================================
# 侵蚀值系统
# ============================================================

func _build_erosion_ui() -> void:
	var hud = get_node_or_null("HUD")
	if not hud:
		call_deferred("_build_erosion_ui")
		return

	# ---- 侵蚀进度条容器 ----
	var container = Control.new()
	container.name = "ErosionBar"
	container.position = Vector2(20, 105)
	container.size = Vector2(280, 28)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(container)

	# 背景
	_erosion_bar_bg = ColorRect.new()
	_erosion_bar_bg.name = "ErosionBg"
	_erosion_bar_bg.size = Vector2(280, 24)
	_erosion_bar_bg.position = Vector2(0, 4)
	_erosion_bar_bg.color = Color(0.1, 0.05, 0.12, 0.9)
	_erosion_bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(_erosion_bar_bg)

	# 填充条
	_erosion_bar_fill = ColorRect.new()
	_erosion_bar_fill.name = "ErosionFill"
	_erosion_bar_fill.size = Vector2(0, 24)
	_erosion_bar_fill.position = Vector2(0, 4)
	_erosion_bar_fill.color = Color(0.65, 0.15, 0.8, 0.95)
	_erosion_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(_erosion_bar_fill)

	# 标签
	_erosion_label = Label.new()
	_erosion_label.name = "ErosionLabel"
	_erosion_label.size = Vector2(280, 24)
	_erosion_label.position = Vector2(0, 4)
	_erosion_label.text = "侵蚀 0%"
	_erosion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_erosion_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_erosion_label.add_theme_font_size_override("font_size", 18)
	_erosion_label.add_theme_color_override("font_color", Color.WHITE)
	_erosion_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(_erosion_label)

	# ---- 侵蚀边缘扭曲覆盖层 ----
	_erosion_vignette = ColorRect.new()
	_erosion_vignette.name = "ErosionVignette"
	_erosion_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_erosion_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_erosion_vignette.z_index = 140
	var shader = load("res://LevelModule/Formal/erosion_vignette.gdshader")
	if shader:
		var mat = ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("intensity", 0.0)
		_erosion_vignette.material = mat
	var cv = get_node_or_null("CanvasLayerUI")
	if cv:
		cv.add_child(_erosion_vignette)

func _update_erosion_ui() -> void:
	if not _erosion_bar_fill or not _erosion_label: return
	# 确保侵蚀条始终可见（防止世界切换等操作意外隐藏）
	var container = _erosion_bar_fill.get_parent()
	if container and is_instance_valid(container):
		container.visible = true
	if _erosion_bar_bg: _erosion_bar_bg.visible = true
	_erosion_bar_fill.visible = true
	_erosion_label.visible = true
	var ratio: float = _erosion_value / level_data.erosion_max
	_erosion_bar_fill.size.x = 280.0 * ratio
	_erosion_label.text = "侵蚀 %.0f%%" % _erosion_value
	# 颜色从紫→红逐渐变化
	if ratio > 0.7:
		_erosion_bar_fill.color = Color(0.9, 0.1, 0.2, 0.95)
	elif ratio > 0.4:
		_erosion_bar_fill.color = Color(0.8, 0.25, 0.5, 0.95)
	else:
		_erosion_bar_fill.color = Color(0.65, 0.15, 0.8, 0.95)

	# 侵蚀视觉强度跟随 0%→100% 连续增强，shader 内部仍保留阶段感。
	var vignette_intensity: float = pow(ratio, 0.85)
	if _erosion_vignette and _erosion_vignette.material:
		_erosion_vignette.material.set_shader_parameter("intensity", vignette_intensity)

func _modify_erosion(delta: float) -> void:
	_erosion_value = clampf(_erosion_value + delta, 0.0, level_data.erosion_max)
	_update_erosion_ui()
	if _erosion_value >= level_data.erosion_max:
		# 侵蚀满 → 播放死亡动画后再触发失败
		_stage2_auto_swap = false
		_stop_stage2_warning()
		print("[Level_04] 侵蚀值已满！世界崩溃……")
		var p = GameManager.player_ref
		if p and is_instance_valid(p) and p.current_state != GlobalDefine.PlayerState.DEAD:
			p.die()
		GameManager.trigger_game_over()


# ============================================================
# Kill Zone (bg 2-2 缺口掉出即死)
# ============================================================

func _connect_kill_zones() -> void:
	var borders = get_node_or_null("Stage2_CyberBorders")
	if not borders: return
	for i in [1, 2, 3]:
		var kz = borders.get_node_or_null("S2C_KillZone_" + str(i))
		if kz:
			kz.body_entered.connect(_on_fall_zone_entered)

func _on_fall_zone_entered(body: Node2D) -> void:
	if body != GameManager.player_ref: return
	if GameManager.is_game_over: return
	if _fall_death_pending: return  # 已在坠落延迟中
	print("[Level_04] 玩家掉入维度裂隙！延迟1秒后触发失败（让玩家掉落出视野）")
	_fall_death_pending = true
	_fall_death_timer = level_data.fall_death_delay

func _check_fall_death() -> void:
	# Y轴兜底检测：当玩家在赛博地图(bg 2-2)且掉到Y>=7550时触发失败
	if GameManager.is_game_over: return
	if _fall_death_pending: return  # 已在坠落延迟中
	var p = GameManager.player_ref
	if not p or not is_instance_valid(p): return
	# 判断是否在赛博地图范围内（通过摄像机Y上限）
	if p.global_position.y > level_data.fall_detection_map_min_y and p.global_position.y > level_data.fall_death_y:
		print("[Level_04] 玩家坠落出界（Y=%.0f）" % p.global_position.y)
		_fall_death_pending = true
		_fall_death_timer = level_data.fall_death_delay

func _check_enemy_vertical_reachability() -> void:
	# 当敌人追踪玩家但与玩家垂直距离超过阈值时，强制退出追逐状态
	# 防止敌人在不同层地形上反复来回转向
	var p = GameManager.player_ref
	if not p or not is_instance_valid(p): return

	var all_enemies := _stage2_lingnan_enemies + _stage2_cyber_enemies
	for e in all_enemies:
		if not is_instance_valid(e) or e.is_dead: continue
		var dy := absf(p.global_position.y - e.global_position.y)
		if dy > level_data.enemy_vertical_reachability and (e.current_state == GlobalDefine.EnemyState.CHASE or e.current_state == GlobalDefine.EnemyState.ATTACK):
			e._change_state(GlobalDefine.EnemyState.PATROL)


# ============================================================
# 阶段2 敌人生成
# ============================================================

func _spawn_stage2_enemies() -> void:
	# 清除旧敌人
	for e in _stage2_lingnan_enemies:
		if is_instance_valid(e):
			GameManager.unregister_enemy(e)
			e.queue_free()
	_stage2_lingnan_enemies.clear()
	for e in _stage2_cyber_enemies:
		if is_instance_valid(e):
			GameManager.unregister_enemy(e)
			e.queue_free()
	_stage2_cyber_enemies.clear()

	# ---- bg 2-1 岭南敌人 ----
	# 灯笼鬼（漂浮，不会掉落）
	var lantern_spots := level_data.stage_2_lantern_spawn_points
	for sp in lantern_spots:
		if _enemy_lantern_scene:
			var e = _enemy_lantern_scene.instantiate()
			e.global_position = sp
			add_child(e)
			_stage2_lingnan_enemies.append(e)

	# 纸符人（平台中央，远离边缘）
	var paper_spots := level_data.stage_2_paper_spawn_points
	for sp in paper_spots:
		if _enemy_paper_effigy_scene:
			var e = _enemy_paper_effigy_scene.instantiate()
			e.global_position = sp
			add_child(e)
			_stage2_lingnan_enemies.append(e)

	# ---- bg 2-2 赛博敌人 ----
	# 赛博狼人（平台中央，远离边缘）
	var wolf_spots := level_data.stage_2_wolf_spawn_points
	for sp in wolf_spots:
		if _enemy_cyber_wolf_scene:
			var e = _enemy_cyber_wolf_scene.instantiate()
			e.global_position = sp
			add_child(e)
			_stage2_cyber_enemies.append(e)

	# 赛博冲撞兽（平台中央）
	var bull_spots := level_data.stage_2_bull_spawn_points
	for sp in bull_spots:
		if _enemy_cyber_bull_scene:
			var e = _enemy_cyber_bull_scene.instantiate()
			e.global_position = sp
			add_child(e)
			_stage2_cyber_enemies.append(e)

	print("[Level_04] 阶段2 敌人生成: 岭南%d只 + 赛博%d只" % [_stage2_lingnan_enemies.size(), _stage2_cyber_enemies.size()])


# ============================================================
# 阶段3 过渡
# ============================================================

func _enter_stage3() -> void:
	if _stage3_entered: return
	_stage3_entered = true
	_stage2_auto_swap = false
	_stop_right_edge_flash()
	_stop_stage2_warning()
	_is_interacting = true
	_freeze_player(true)

	# 黑屏过渡 → 跳转到 Level_05
	var blk = _create_black_overlay()
	if not blk: _freeze_player(false); _is_interacting = false; return
	await get_tree().create_tween().tween_property(blk, "color", Color.BLACK, level_data.stage_3_transition_fade_duration).finished

	# 清除阶段2敌人
	for e in _stage2_lingnan_enemies:
		if is_instance_valid(e): GameManager.unregister_enemy(e); e.queue_free()
	_stage2_lingnan_enemies.clear()
	for e in _stage2_cyber_enemies:
		if is_instance_valid(e): GameManager.unregister_enemy(e); e.queue_free()
	_stage2_cyber_enemies.clear()

	# 传递侵蚀值和血量给 Level_05
	GameManager.set_dream_flag(&"erosion_value", _erosion_value)
	var pl = GameManager.player_ref
	if pl and is_instance_valid(pl):
		GameManager.set_dream_flag(&"player_health", pl.current_health)
		GameManager.set_dream_flag(&"player_max_health", pl.max_health)

	# 跳转
	SceneTransitionManager.request_scene_change(level_data.next_level_path, self)


func _pan_camera_to(target: Vector2, cb: Callable = Callable()) -> void:
	var p = GameManager.player_ref
	if not p or not is_instance_valid(p): return
	var cam = p.get_node_or_null("SmoothCamera") as SmoothCamera
	if not cam: return
	_is_interacting = true
	_freeze_player(true)
	cam.follow_enabled = false
	var t = create_tween()
	t.tween_property(cam, "global_position", target, level_data.camera_pan_travel_duration).set_trans(Tween.TRANS_SINE)
	t.tween_interval(level_data.camera_pan_hold_duration)
	t.tween_property(cam, "global_position", p.global_position, level_data.camera_pan_travel_duration).set_trans(Tween.TRANS_SINE)
	await t.finished
	# await 后重新获取玩家引用（避免旧玩家在 await 期间被切皮肤释放）
	p = GameManager.player_ref
	if not p or not is_instance_valid(p):
		_is_interacting = false
		if cb.is_valid(): cb.call()
		return
	cam = p.get_node_or_null("SmoothCamera") as SmoothCamera
	if not cam:
		_freeze_player(false)
		_is_interacting = false
		if cb.is_valid(): cb.call()
		return
	cam.global_position = p.global_position
	cam.follow_enabled = true
	_freeze_player(false)
	_is_interacting = false
	if cb.is_valid(): cb.call()


# ============================================================
# 右侧边缘闪烁光效（引导玩家找到 IA_Stage3）
# ============================================================

func _start_right_edge_flash() -> void:
	if _right_edge_flash_active: return
	if not _right_edge_flash or not is_instance_valid(_right_edge_flash):
		push_warning("[Level_04] _right_edge_flash 节点为空，无法启动闪烁")
		return
	# 确保节点在 CanvasLayer 顶层
	_right_edge_flash.visible = true
	_right_edge_flash.color = Color(1.0, 0.85, 0.2, 0.0)
	_right_edge_glow.visible = true
	_right_edge_glow.color = Color(1.0, 0.9, 0.3, 0.0)
	var tw = _right_edge_flash.create_tween().set_loops()
	tw.tween_property(_right_edge_flash, "color:a", 0.8, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_right_edge_flash, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	var tw2 = _right_edge_glow.create_tween().set_loops()
	tw2.tween_property(_right_edge_glow, "color:a", 0.25, 0.5).set_trans(Tween.TRANS_SINE)
	tw2.tween_property(_right_edge_glow, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	_right_edge_flash_active = true

func _stop_right_edge_flash() -> void:
	if not _right_edge_flash_active: return
	_right_edge_flash_active = false
	if _right_edge_flash and is_instance_valid(_right_edge_flash):
		_right_edge_flash.hide()
	if _right_edge_glow and is_instance_valid(_right_edge_glow):
		_right_edge_glow.hide()

func _check_stage3_in_view() -> void:
	var p = GameManager.player_ref
	if not p or not is_instance_valid(p): return
	var cam = p.get_node_or_null("SmoothCamera") as SmoothCamera
	if not cam: return
	var half_visible = get_viewport_rect().size * 0.5 / cam.zoom
	var cam_center = cam.global_position + cam.offset
	var view_rect = Rect2(cam_center - half_visible, half_visible * 2)
	# 检测所有交互物中 object_id=="enter_stage3" 的是否入镜
	for obj in _all_interactives:
		if is_instance_valid(obj) and obj.object_id == "enter_stage3" and view_rect.has_point(obj.global_position):
			_stop_right_edge_flash()
			return

func _flash_screen() -> void:
	var strength = minf(
		level_data.swap_glitch_base_strength + _swap_count * level_data.swap_glitch_strength_per_swap,
		level_data.swap_glitch_max_strength
	)
	var duration = level_data.swap_glitch_base_duration + _swap_count * level_data.swap_glitch_duration_per_swap

	if _glitch_overlay and _glitch_overlay.material:
		_glitch_overlay.show()
		var m = _glitch_overlay.material as ShaderMaterial
		m.set_shader_parameter("intensity", strength)
		var gt = create_tween()
		gt.tween_property(m, "shader_parameter/intensity", 0.0, duration)
		# glitch淡出后隐藏覆盖层，防止全屏覆盖层遮挡侵蚀条等UI
		gt.tween_callback(func(): if _glitch_overlay: _glitch_overlay.hide())

	var f = ColorRect.new()
	f.name = "SwapFlash"; f.set_anchors_preset(Control.PRESET_FULL_RECT)
	f.color = Color.WHITE; f.mouse_filter = Control.MOUSE_FILTER_IGNORE; f.z_index = 100
	var cv = $CanvasLayerUI; if cv: cv.add_child(f)
	var t = create_tween(); t.tween_property(f, "color:a", 0.0, level_data.swap_flash_duration); t.tween_callback(f.queue_free)


# ---- 敌人 ----

func _spawn_stage1_enemies() -> void:
	if not _enemy_cyber_wolf_scene: return
	var sp := level_data.surface_enemy_spawn_points
	if sp.is_empty():
		push_error("[Level_04] Level04Data.surface_enemy_spawn_points 不能为空")
		return
	var cf = load("res://DataConfig/Enemy/CleanerConfig.tres") as EnemyConfig
	for i in range(mini(level_data.surface_enemy_count, sp.size())):
		var s: Vector2 = sp[i]
		var e = _spawn_enemy_with_config(_enemy_cyber_wolf_scene, s, cf)
		if e: e.modulate = Color(0.3, 0.3, 0.35, 0.95); _stage1_enemies.append(e)
	print("[Level_04] 赛博敌人生成: %d 只" % _stage1_enemies.size())

func _spawn_lingnan_enemies_once() -> void:
	if _lingnan_enemies_spawned: return
	_lingnan_enemies_spawned = true
	if not _enemy_cyber_wolf_scene: return
	var cf = load("res://DataConfig/Enemy/CleanerConfig.tres") as EnemyConfig
	for s in level_data.lingnan_enemy_spawn_points:
		var e = _spawn_enemy_with_config(_enemy_cyber_wolf_scene, s, cf)
		if e: e.modulate = Color(0.2, 0.15, 0.35, 0.95); _stage1_enemies.append(e)
	print("[Level_04] 岭南敌人生成: %d 只" % level_data.lingnan_enemy_spawn_points.size())

func _spawn_enemy_with_config(sc: PackedScene, sp: Vector2, cf: EnemyConfig) -> Node2D:
	if not sc: return null
	var e = sc.instantiate(); if cf: e.config = cf; e.global_position = sp
	(_dynamic_actors if _dynamic_actors else self).add_child(e); return e

func _on_enemy_died(data: Dictionary) -> void:
	var e = data.get("enemy")
	if not e or not is_instance_valid(e): return
	if current_state == LevelState.HOMOMORPHIC_COMBAT and e in _stage1_enemies:
		_stage1_enemies.erase(e); _swap_count += level_data.stage_1_enemy_swap_progress
	if e in _stage2_lingnan_enemies or e in _stage2_cyber_enemies:
		# 击杀降低侵蚀值
		_modify_erosion(-level_data.erosion_kill_reduction)
		if e in _stage2_lingnan_enemies:
			_stage2_lingnan_enemies.erase(e)
		elif e in _stage2_cyber_enemies:
			_stage2_cyber_enemies.erase(e)


# ---- 终局 ----

func _trigger_level_end() -> void:
	_stage2_auto_swap = false
	_stop_stage2_warning()
	current_state = LevelState.LEVEL_END_TRANSIT
	if _ending_prompt: _ending_prompt.show()
	if _ending_label and level_data: _ending_label.text = level_data.override_protocol_text
	_ending_enter_armed = true

func _emit_level_complete() -> void:
	if _level_complete_emitted: return
	_level_complete_emitted = true
	_full_cleanup()
	EventBus.emit(GlobalDefine.EventName.LEVEL_COMPLETE, {"level": self, "next_level": level_data.next_level_path})

func _full_cleanup() -> void:
	_disconnect_input_manager()
	_close_narrative(false)
	InputManager.release_input_for_owner(self)
	_stage2_auto_swap = false
	_stop_stage2_warning()
	_stop_right_edge_flash()
	if _stage2_alarm_player:
		_stage2_alarm_player.queue_free()
		_stage2_alarm_player = null
	for e in _stage1_enemies:
		if is_instance_valid(e): GameManager.unregister_enemy(e); e.queue_free()
	_stage1_enemies.clear()
	for e in _stage2_lingnan_enemies:
		if is_instance_valid(e): GameManager.unregister_enemy(e); e.queue_free()
	_stage2_lingnan_enemies.clear()
	for e in _stage2_cyber_enemies:
		if is_instance_valid(e): GameManager.unregister_enemy(e); e.queue_free()
	_stage2_cyber_enemies.clear()
	EventBus.unsubscribe_all(self)

# ---- 测试面板跳转 ----

func _goto_stage1_test() -> void:
	current_state = LevelState.HOMOMORPHIC_COMBAT
	var p = GameManager.player_ref
	if p and is_instance_valid(p):
		p.global_position = level_data.stage_1_test_player_position
		_swap_player_skin("Cyber")
		_snap_camera(GameManager.player_ref)
		_set_cam_from_group($Stage1Collisions, level_data.stage_1_camera_top)

func _goto_stage2_test() -> void:
	if not _stage2_entered:
		_enter_stage2()
	else:
		var p = GameManager.player_ref
		if p and is_instance_valid(p):
			p.global_position = level_data.stage_2_spawn
			_swap_player_skin("Lingnan")
			_snap_camera(GameManager.player_ref)
			_set_camera_limits(
				level_data.stage_2_lingnan_camera_left,
				level_data.stage_2_lingnan_camera_right,
				level_data.stage_2_lingnan_camera_top,
				level_data.stage_2_lingnan_camera_bottom
			)

func _goto_stage3_test() -> void:
	# 直接跳到阶段3交互点附近
	if not _stage2_entered:
		_enter_stage2()
	var p = GameManager.player_ref
	if p and is_instance_valid(p):
		# 移动到 enter_stage3 交互点附近
		for obj in _all_interactives:
			if obj.object_id == "enter_stage3" and is_instance_valid(obj):
				p.global_position = obj.global_position + level_data.stage_3_test_player_offset
				break
		_snap_camera(p)
