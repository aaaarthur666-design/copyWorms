extends Node

const STARTUP_SETTLE_FRAMES := 5
const EXIT_SETTLE_FRAMES := 10
const EXIT_AUDIO_SETTLE_SECONDS := 0.5


class MainSceneMonitor:
	extends Node

	var failures: Array[String] = []

	func start() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS
		call_deferred("_run")

	func _run() -> void:
		var tree := get_tree()
		var main_path := String(ProjectSettings.get_setting("application/run/main_scene", ""))
		if main_path.is_empty() or not ResourceLoader.exists(main_path):
			failures.append("project.godot 未配置有效主场景: %s" % main_path)
			await _finish()
			return
		var packed := load(main_path) as PackedScene
		if packed == null:
			failures.append("主场景无法加载为 PackedScene: %s" % main_path)
			await _finish()
			return
		var change_error := tree.change_scene_to_packed(packed)
		packed = null
		if change_error != OK:
			failures.append("主场景切换失败: %s（错误码 %d）" % [main_path, change_error])
			await _finish()
			return
		for _frame: int in range(STARTUP_SETTLE_FRAMES):
			await tree.process_frame
		var current := tree.current_scene
		if not is_instance_valid(current) or current.scene_file_path != main_path:
			failures.append("主场景未成为 SceneTree.current_scene: %s" % main_path)
		await _finish()

	func _finish() -> void:
		var tree := get_tree()
		var current := tree.current_scene
		if is_instance_valid(current) and current.has_method("prepare_for_level_exit"):
			current.call("prepare_for_level_exit")
		MusicManager.stop_bgm(0.0)
		SFXManager.stop_all()
		EventBus.clear_all()
		InputManager.force_unblock_all()
		GameManager.reset_transient_state()
		if is_instance_valid(current):
			current.queue_free()
		await _wait_for_audio_shutdown()
		for _frame: int in range(EXIT_SETTLE_FRAMES):
			await tree.process_frame
		if failures.is_empty():
			print("[MAIN SCENE SMOKE] PASS")
			call_deferred("_quit_after_run", 0)
			return
		for failure: String in failures:
			push_error("[MAIN SCENE SMOKE] %s" % failure)
		print("[MAIN SCENE SMOKE] FAIL — %d failures" % failures.size())
		call_deferred("_quit_after_run", 1)

	func _quit_after_run(exit_code: int) -> void:
		get_tree().quit(exit_code)

	func _wait_for_audio_shutdown() -> void:
		var timer := Timer.new()
		timer.name = "MainSceneAudioShutdownTimer"
		timer.one_shot = true
		timer.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(timer)
		timer.start(EXIT_AUDIO_SETTLE_SECONDS)
		await timer.timeout
		timer.queue_free()
		await get_tree().process_frame


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_initialize_runner")


func _initialize_runner() -> void:
	_disable_inactive_mcp_game_helper()
	var monitor := MainSceneMonitor.new()
	monitor.name = "MainSceneSmokeMonitor"
	get_tree().root.add_child.call_deferred(monitor)
	monitor.start.call_deferred()


func _disable_inactive_mcp_game_helper() -> void:
	if EngineDebugger.is_active():
		return
	var helper := get_node_or_null("/root/_mcp_game_helper")
	if is_instance_valid(helper):
		helper.free()
