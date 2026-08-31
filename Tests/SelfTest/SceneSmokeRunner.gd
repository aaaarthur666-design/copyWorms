extends Node

const ScriptErrorCapture := preload("res://addons/godot_ai/testing/script_error_capture.gd")
const EXIT_SETTLE_SECONDS := 0.5

var _failures: Array[String] = []
var _script_error_capture: ScriptErrorCapture = null
var _capture_registered: bool = false
var _completed_scene_count: int = 0
var _shutdown_timer: Timer = null
var _scene_paths: PackedStringArray = PackedStringArray()
var _scene_index: int = 0
var _current_scene_path: String = ""
var _current_instance: Node = null
var _target_process_frame: int = 0
var _target_physics_frame: int = 0

enum SmokePhase {
	IDLE,
	WAIT_FIRST_PROCESS,
	WAIT_PHYSICS,
	WAIT_SECOND_PROCESS,
	WAIT_FREE_PROCESS,
	SHUTDOWN,
}

var _phase: int = SmokePhase.IDLE


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_initialize_runner")


func _initialize_runner() -> void:
	_disable_inactive_mcp_game_helper()
	_register_script_error_capture()
	_scene_paths = OS.get_cmdline_user_args()
	if _scene_paths.is_empty():
		_failures.append("未提供待实例化场景路径")
	call_deferred("_start_next_scene")


func _disable_inactive_mcp_game_helper() -> void:
	if EngineDebugger.is_active():
		return
	var helper := get_node_or_null("/root/_mcp_game_helper")
	if is_instance_valid(helper):
		helper.free()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_unregister_script_error_capture()


func _process(_delta: float) -> void:
	match _phase:
		SmokePhase.WAIT_FIRST_PROCESS:
			if Engine.get_process_frames() >= _target_process_frame:
				_phase = SmokePhase.WAIT_PHYSICS
				_target_physics_frame = Engine.get_physics_frames() + 1
		SmokePhase.WAIT_PHYSICS:
			if Engine.get_physics_frames() >= _target_physics_frame:
				_phase = SmokePhase.WAIT_SECOND_PROCESS
				_target_process_frame = Engine.get_process_frames() + 1
		SmokePhase.WAIT_SECOND_PROCESS:
			if Engine.get_process_frames() >= _target_process_frame:
				_finish_loaded_scene()
		SmokePhase.WAIT_FREE_PROCESS:
			if Engine.get_process_frames() >= _target_process_frame:
				_finish_scene_cleanup()


func _start_next_scene() -> void:
	if _phase != SmokePhase.IDLE:
		return
	GameManager.run_mode = GlobalDefine.RunMode.SELF_TEST
	if _scene_index >= _scene_paths.size():
		_begin_shutdown()
		return
	_current_scene_path = _scene_paths[_scene_index]
	_begin_script_error_capture()
	if not ResourceLoader.exists(_current_scene_path):
		_fail_current_scene("场景不存在: %s" % _current_scene_path)
		return
	var packed := load(_current_scene_path) as PackedScene
	if packed == null:
		_fail_current_scene("场景加载失败: %s" % _current_scene_path)
		return
	_current_instance = packed.instantiate()
	if _current_instance == null:
		_fail_current_scene("场景实例化失败: %s" % _current_scene_path)
		return
	_current_instance.name = "SmokeSubject"
	add_child(_current_instance)
	_phase = SmokePhase.WAIT_FIRST_PROCESS
	_target_process_frame = Engine.get_process_frames() + 1


func _fail_current_scene(message: String) -> void:
	_failures.append(message)
	_end_script_error_capture(_current_scene_path)
	_current_instance = null
	_scene_index += 1
	_current_scene_path = ""
	_phase = SmokePhase.IDLE
	call_deferred("_start_next_scene")


func _finish_loaded_scene() -> void:
	print("[SCENE SMOKE] loaded %s" % _current_scene_path)
	if is_instance_valid(_current_instance):
		if _current_instance.has_method("prepare_for_level_exit"):
			_current_instance.call("prepare_for_level_exit")
		_current_instance.queue_free()
	_phase = SmokePhase.WAIT_FREE_PROCESS
	_target_process_frame = Engine.get_process_frames() + 1


func _finish_scene_cleanup() -> void:
	EventBus.clear_transient()
	InputManager.force_unblock_all()
	GameManager.reset_transient_state()
	_end_script_error_capture(_current_scene_path)
	_current_instance = null
	_scene_index += 1
	_current_scene_path = ""
	_phase = SmokePhase.IDLE
	call_deferred("_start_next_scene")


func _begin_shutdown() -> void:
	_phase = SmokePhase.SHUTDOWN
	EventBus.clear_all()
	InputManager.force_unblock_all()
	GameManager.reset_transient_state()
	MusicManager.stop_bgm(0.0)
	SFXManager.stop_all()
	_unregister_script_error_capture()
	_schedule_shutdown(_scene_paths.size())


func _schedule_shutdown(scene_count: int) -> void:
	_completed_scene_count = scene_count
	_shutdown_timer = Timer.new()
	_shutdown_timer.name = "SceneSmokeShutdownTimer"
	_shutdown_timer.one_shot = true
	_shutdown_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	_shutdown_timer.timeout.connect(_finish_after_shutdown, CONNECT_ONE_SHOT)
	add_child(_shutdown_timer)
	_shutdown_timer.start(EXIT_SETTLE_SECONDS)


func _finish_after_shutdown() -> void:
	if is_instance_valid(_shutdown_timer):
		_shutdown_timer.queue_free()
	_shutdown_timer = null
	if _failures.is_empty():
		print("[SCENE SMOKE] PASS — %d scenes" % _completed_scene_count)
		call_deferred("_quit_after_run", 0)
		return

	for failure: String in _failures:
		push_error("[SCENE SMOKE] %s" % failure)
	print("[SCENE SMOKE] FAIL — %d failures" % _failures.size())
	call_deferred("_quit_after_run", 1)


func _quit_after_run(exit_code: int) -> void:
	get_tree().quit(exit_code)


func _register_script_error_capture() -> void:
	if _capture_registered:
		return
	_script_error_capture = ScriptErrorCapture.new()
	if _script_error_capture == null:
		_failures.append("无法创建 GDScript 错误捕获器")
		return
	OS.add_logger(_script_error_capture)
	_capture_registered = true


func _unregister_script_error_capture() -> void:
	if not _capture_registered or _script_error_capture == null:
		return
	OS.remove_logger(_script_error_capture)
	_capture_registered = false
	_script_error_capture = null


func _begin_script_error_capture() -> void:
	if _capture_registered and _script_error_capture != null:
		_script_error_capture.begin_capture()


func _end_script_error_capture(scene_path: String) -> void:
	if not _capture_registered or _script_error_capture == null:
		return
	for error_text: String in _script_error_capture.end_capture():
		_failures.append("%s 运行时脚本错误: %s" % [scene_path, error_text])
