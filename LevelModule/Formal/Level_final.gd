# ============================================================
# Level_final.gd - 终局关卡（视频演出后进入）
# 玩家出生后触发终局互动，分页显示结尾文本
# ============================================================
extends Node2D

@export var level_data: LevelFinalData = preload("res://DataConfig/Level/LevelFinalData.tres")

var _all_interactives: Array[InteractiveObject] = []
var _dialog_open: bool = false
var _dialog_panel: Panel = null
var _dialog_label: RichTextLabel = null
var _dialog_lines: Array[String] = []
var _dialog_index: int = 0
var _ending_triggered: bool = false
var _ending_pause_guard_token: int = -1
var _hud: CanvasLayer = null

const INTERACT_ID := "final_sun"

func _ready() -> void:
	if not level_data:
		push_error("[Level_final] LevelFinalData 加载失败，停止初始化")
		return
	GameManager.set_current_level(self)
	# 清除旧玩家
	if GameManager.player_ref and is_instance_valid(GameManager.player_ref):
		GameManager.player_ref.queue_free()
		GameManager.player_ref = null
	# 背景色
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.size = level_data.background_size
	bg.position = Vector2(0, 0)
	bg.color = level_data.background_color
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.z_index = -10
	add_child(bg)

	# 创建玩家（普通外观，非赛博非岭南）
	var path := level_data.player_scene_path
	if ResourceLoader.exists(path):
		var p = load(path).instantiate()
		p.position = level_data.player_spawn
		add_child(p)
		GameManager.register_player(p)

		# 禁用跳跃/攻击/闪避/技能
		p.can_jump = false
		p.can_dash = false
		p.can_attack = false
		p.can_skill = false
		p.runtime_move_speed_multiplier = level_data.player_move_speed_multiplier
		var cam = p.get_node_or_null("SmoothCamera") as SmoothCamera
		if cam:
			# 摄像机配置
			cam.limit_left = level_data.camera_limit_left
			cam.limit_right = level_data.camera_limit_right
			cam.limit_top = level_data.camera_limit_top
			cam.limit_bottom = level_data.camera_limit_bottom
			cam.zoom = level_data.camera_zoom
			cam.offset = Vector2.ZERO
			cam.lerp_speed = level_data.camera_lerp_speed
			cam.bind_target(p)
			cam.follow_enabled = true
			cam.make_current()
	# 终局保留共享暂停界面，但隐藏血条、技能等玩法 HUD。
	_load_hud()
	# 创建交互点
	_create_interactive()
	# 订阅交互事件
	EventBus.subscribe(GlobalDefine.EventName.INTERACTIVE_OBJECT_TRIGGERED, self, "_on_object_interacted")
	EventBus.emit(GlobalDefine.EventName.LEVEL_LOADED, {"level": self})
	set_process(true)
	set_process_input(true)
	print("[Level_final] 终局关卡加载完成")


func _exit_tree() -> void:
	prepare_for_level_exit()


func prepare_for_level_exit() -> void:
	_release_ending_pause_guard()
	InputManager.release_input_for_owner(self)
	GameManager.end_dialog(self)
	_dialog_open = false
	EventBus.unsubscribe_all(self)


func _create_interactive() -> void:
	var obj = InteractiveObject.new()
	obj.name = "FinalSun"
	obj.object_id = INTERACT_ID
	obj.is_active = true
	obj.prompt_text = ""
	obj.position = level_data.interaction_position
	obj.collision_layer = 0
	obj.collision_mask = GlobalDefine.Collision.PLAYER
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var rect = RectangleShape2D.new()
	rect.size = level_data.interaction_size
	col.shape = rect
	obj.add_child(col)
	add_child(obj)
	_all_interactives.append(obj)
	# 复用关卡1光点视觉
	obj.apply_level01_dot_visual()

func _process(_delta: float) -> void:
	var pl = GameManager.player_ref
	if pl and is_instance_valid(pl) and not _dialog_open:
		for obj in _all_interactives:
			if is_instance_valid(obj):
				obj.check_player_in_range(pl)

func _input(event: InputEvent) -> void:
	var is_left_click = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if _dialog_open:
		if event.is_action_pressed("ui_accept") or is_left_click:
			_advance_dialog()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept") or is_left_click:
		var obj = _find_nearby_interactive()
		if obj:
			EventBus.emit(GlobalDefine.EventName.INTERACTIVE_OBJECT_TRIGGERED, {"object_id": obj.object_id})
			get_viewport().set_input_as_handled()

func _find_nearby_interactive() -> InteractiveObject:
	for obj in _all_interactives:
		if is_instance_valid(obj) and obj.is_active and not obj.completed and obj.is_player_in_range:
			return obj
	return null

func _on_object_interacted(data: Dictionary) -> void:
	var oid = data.get("object_id", "")
	if oid == INTERACT_ID:
		_trigger_ending()

## 交互触发：锁定交互 + 分页显示结尾文本，读完后黑屏返回标题
func _trigger_ending() -> void:
	if _ending_triggered:
		return
	_ending_triggered = true
	# 锁定交互物
	for obj in _all_interactives:
		if is_instance_valid(obj):
			obj.mark_completed()
			obj.set_active(false)
	_dialog_open = true
	_ending_pause_guard_token = InputManager.acquire_pause_guard("终局演出", self)
	InputManager.block_input("终局", self)
	GameManager.begin_dialog(self)
	# 显示文本框
	if not _dialog_panel:
		_create_dialog_panel()
	_dialog_lines = GameUIStyle.paginate_interaction_text(level_data.ending_text)
	_dialog_index = 0
	_show_dialog_page()
	_dialog_panel.visible = true

func _show_dialog_page() -> void:
	if _dialog_index < _dialog_lines.size():
		GameUIStyle.fit_interaction_text_panel(_dialog_panel, _dialog_label, _dialog_lines[_dialog_index])
	else:
		_finish_ending()

func _advance_dialog() -> void:
	if not _dialog_open:
		return
	_dialog_index += 1
	_show_dialog_page()

func _finish_ending() -> void:
	_dialog_open = false
	GameManager.end_dialog(self)
	if _dialog_panel:
		_dialog_panel.hide()
	# 读完后开始5s黑屏渐入
	var cv = CanvasLayer.new()
	cv.name = "FadeCanvas"
	cv.layer = UILayerContract.CINEMATIC
	add_child(cv)
	var black = ColorRect.new()
	cv.add_child(black)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black.color = Color(0, 0, 0, 0.0)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 5s 渐入满黑 → 切回标题界面
	var tw = get_tree().create_tween()
	tw.tween_property(black, "color:a", 1.0, level_data.ending_fade_duration).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func():
		SceneTransitionManager.request_scene_change(level_data.title_scene_path, self)
	)

## 创建文本框面板
func _create_dialog_panel() -> void:
	var cv = CanvasLayer.new()
	cv.name = "DialogLayer"
	cv.layer = UILayerContract.LEVEL_UI
	add_child(cv)
	_dialog_panel = Panel.new()
	_dialog_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cv.add_child(_dialog_panel)
	_dialog_label = RichTextLabel.new()
	_dialog_panel.add_child(_dialog_label)
	GameUIStyle.apply_interaction_text_panel(_dialog_panel, _dialog_label, 22)


func _load_hud() -> void:
	if _hud and is_instance_valid(_hud):
		return
	var hud_path := "res://UI/HUD.tscn"
	if not ResourceLoader.exists(hud_path):
		push_warning("[Level_final] HUD.tscn 未找到，无法提供暂停界面")
		return
	_hud = load(hud_path).instantiate() as CanvasLayer
	add_child(_hud)
	_hud.call("set_gameplay_hud_enabled", false)


func _release_ending_pause_guard() -> void:
	if _ending_pause_guard_token < 0:
		return
	InputManager.release_pause_guard_token(_ending_pause_guard_token)
	_ending_pause_guard_token = -1
