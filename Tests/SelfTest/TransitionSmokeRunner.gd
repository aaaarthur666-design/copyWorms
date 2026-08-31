extends Node

const TITLE_SCENE := "res://UI/TitleScreen.tscn"
const MAIN_ENTRY_SCENE := "res://Global/MainEntry.tscn"
const LEVEL_01_SCENE := "res://LevelModule/Formal/Level_01.tscn"
const LEVEL_03_SCENE := "res://LevelModule/Formal/Level_03.tscn"
const LEVEL_04_SCENE := "res://LevelModule/Formal/Level_04.tscn"
const LEVEL_05_SCENE := "res://LevelModule/Formal/Level_05.tscn"
const MAX_WAIT_FRAMES := 180
const EXIT_SETTLE_SECONDS := 0.5


class TransitionMonitor:
	extends Node

	var prepare_calls: int = 0
	var assertion_count: int = 0
	var failures: Array[String] = []
	var _pending_exit_code: int = 0
	var _quit_timer: Timer = null

	func start() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS
		call_deferred("_run")

	func prepare_for_level_exit() -> void:
		prepare_calls += 1

	func _run() -> void:
		var tree := get_tree()
		GameManager.reset_run_progress()
		GameManager.reset_transient_state()
		InputManager.force_unblock_all()
		MusicManager.clear_game_pause()

		var dialog_owner := Node.new()
		dialog_owner.name = "TransitionSmokeDialogOwner"
		add_child(dialog_owner)
		GameManager.begin_dialog(dialog_owner)
		InputManager.block_input("transition smoke", dialog_owner)
		GameManager.set_dream_flag(&"temporary_theme_flag", "persist_across_level")
		GameManager.set_checkpoint(LEVEL_05_SCENE, 2, {"seed": true})
		GameManager.toggle_pause()
		_assert_true(GameManager.is_paused and tree.paused, "转场前测试场景必须处于暂停状态")
		_assert_true(MusicManager.is_paused_by_game(), "暂停事件必须在转场前送达 MusicManager")

		SceneTransitionManager.request_scene_change(TITLE_SCENE, self)
		var title_loaded := await _wait_for_scene(TITLE_SCENE)
		_assert_true(title_loaded, "必须能真实切换到 TitleScreen")
		if not title_loaded:
			await _finish(dialog_owner)
			return

		_assert_equal(prepare_calls, 1, "有效转场必须调用传入 source 的退出钩子一次")
		_assert_false(InputManager.is_input_blocked, "有效转场必须清空输入锁")
		_assert_false(GameManager.is_dialog_active, "有效转场必须清空对话 owner")
		_assert_true(not GameManager.is_paused and not tree.paused, "有效转场必须同时恢复管理器与 SceneTree 暂停")
		_assert_false(MusicManager.is_paused_by_game(), "有效转场必须清理音乐暂停状态")
		_assert_equal(GameManager.get_dream_flag(&"temporary_theme_flag"), "persist_across_level", "普通关卡转场必须保留同一局梦境状态")
		_assert_equal(GameManager.checkpoint_stage, 2, "普通关卡转场必须保留同一局检查点")

		var title := tree.current_scene
		_assert_true(title != null and title.has_method("_on_start_game"), "TitleScreen 必须暴露已连接的正式开始回调")
		if title == null or not title.has_method("_on_start_game"):
			await _finish(dialog_owner)
			return
		title.call("_on_start_game")
		var main_entry_loaded := await _wait_for_scene(MAIN_ENTRY_SCENE)
		_assert_true(main_entry_loaded, "TitleScreen 正式开始入口必须真实切换到 MainEntry")
		if not main_entry_loaded:
			await _finish(dialog_owner)
			return

		_assert_equal(GameManager.run_mode, GlobalDefine.RunMode.FORMAL, "正式开始入口必须设置正式运行模式")
		_assert_true(GameManager.dream_runtime_state.is_empty(), "正式开始入口必须清空上一局梦境状态")
		_assert_equal(GameManager.checkpoint_scene_path, LEVEL_01_SCENE, "正式开始入口必须用首关检查点替换上一局检查点")
		_assert_equal(GameManager.checkpoint_stage, 0, "正式开始入口必须清空上一局检查点阶段")
		_assert_true(GameManager.checkpoint_data.is_empty(), "正式开始入口必须清空上一局检查点数据")

		SceneTransitionManager.request_scene_change(LEVEL_03_SCENE, tree.current_scene)
		_assert_true(await _wait_for_scene(LEVEL_03_SCENE), "必须能真实进入 Level 03")
		SceneTransitionManager.request_scene_change(LEVEL_04_SCENE, tree.current_scene)
		_assert_true(await _wait_for_scene(LEVEL_04_SCENE), "Level 03 必须能真实相邻切换到 Level 04")
		SceneTransitionManager.request_scene_change(LEVEL_05_SCENE, tree.current_scene)
		_assert_true(await _wait_for_scene(LEVEL_05_SCENE), "Level 04 必须能真实相邻切换到 Level 05")

		await _finish(dialog_owner)

	func _wait_for_scene(scene_path: String) -> bool:
		for _frame: int in range(MAX_WAIT_FRAMES):
			await get_tree().process_frame
			var current := get_tree().current_scene
			if (
				not SceneTransitionManager.is_transitioning
				and is_instance_valid(current)
				and current.scene_file_path == scene_path
			):
				return true
		return false

	func _finish(dialog_owner: Node) -> void:
		var tree := get_tree()
		var current := tree.current_scene
		if is_instance_valid(current) and current.has_method("prepare_for_level_exit"):
			current.call("prepare_for_level_exit")
		InputManager.force_unblock_all()
		GameManager.reset_transient_state()
		GameManager.reset_run_progress()
		MusicManager.clear_game_pause()
		MusicManager.stop_bgm(0.0)
		SFXManager.stop_all()
		if is_instance_valid(dialog_owner):
			dialog_owner.queue_free()
		if is_instance_valid(current):
			current.queue_free()
		await tree.process_frame
		await tree.process_frame
		for _frame: int in range(10):
			await tree.process_frame
		var remaining_tweens := tree.get_processed_tweens()
		_assert_equal(remaining_tweens.size(), 0, "转场测试清理后不得残留 SceneTree Tween")

		if failures.is_empty():
			print("[TRANSITION SMOKE] PASS — %d assertions" % assertion_count)
			_schedule_quit(0)
			return
		for failure: String in failures:
			push_error("[TRANSITION SMOKE] %s" % failure)
		print("[TRANSITION SMOKE] FAIL — %d failures / %d assertions" % [failures.size(), assertion_count])
		_schedule_quit(1)

	func _schedule_quit(exit_code: int) -> void:
		_pending_exit_code = exit_code
		_quit_timer = Timer.new()
		_quit_timer.name = "TransitionSmokeQuitTimer"
		_quit_timer.one_shot = true
		_quit_timer.process_mode = Node.PROCESS_MODE_ALWAYS
		_quit_timer.timeout.connect(_quit_after_run, CONNECT_ONE_SHOT)
		add_child(_quit_timer)
		_quit_timer.start(EXIT_SETTLE_SECONDS)

	func _quit_after_run() -> void:
		get_tree().quit(_pending_exit_code)

	func _assert_true(condition: bool, message: String) -> void:
		assertion_count += 1
		if not condition:
			failures.append(message)

	func _assert_false(condition: bool, message: String) -> void:
		_assert_true(not condition, message)

	func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
		assertion_count += 1
		if actual != expected:
			failures.append("%s（实际=%s，期望=%s）" % [message, actual, expected])


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_initialize_runner")


func _initialize_runner() -> void:
	_disable_inactive_mcp_game_helper()
	var monitor := TransitionMonitor.new()
	monitor.name = "TransitionSmokeMonitor"
	get_tree().root.add_child.call_deferred(monitor)
	monitor.start.call_deferred()


func _disable_inactive_mcp_game_helper() -> void:
	if EngineDebugger.is_active():
		return
	var helper := get_node_or_null("/root/_mcp_game_helper")
	if is_instance_valid(helper):
		helper.free()
