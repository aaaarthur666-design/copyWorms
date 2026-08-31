extends Node

class TestListener:
	extends Node

	var label: String = ""
	var shared_order: Array[String] = []
	var call_count: int = 0
	var secondary_call_count: int = 0
	var received_payloads: Array[Dictionary] = []
	var unsubscribe_event: StringName = &""
	var unsubscribe_target: Node = null

	func record(_data: Dictionary) -> void:
		call_count += 1
		received_payloads.append(_data.duplicate(true))
		shared_order.append(label)

	func record_and_unsubscribe(_data: Dictionary) -> void:
		record(_data)
		if unsubscribe_event != &"" and unsubscribe_target:
			EventBus.unsubscribe(unsubscribe_event, unsubscribe_target)

	func record_secondary(_data: Dictionary) -> void:
		secondary_call_count += 1


class DummyEnemy:
	extends Node2D


class TransitionCleanupProbe:
	extends Node

	var prepare_calls: int = 0

	func prepare_for_level_exit() -> void:
		prepare_calls += 1


var _failures: Array[String] = []
var _assertion_count: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_initialize_runner")


func _initialize_runner() -> void:
	_disable_inactive_mcp_game_helper()
	call_deferred("_run")


func _disable_inactive_mcp_game_helper() -> void:
	if EngineDebugger.is_active():
		return
	var helper := get_node_or_null("/root/_mcp_game_helper")
	if is_instance_valid(helper):
		helper.free()


func _run() -> void:
	GameManager.run_mode = GlobalDefine.RunMode.SELF_TEST
	_test_event_bus_persistent_lifecycle()
	_test_event_bus_sync_and_snapshot()
	await _test_event_bus_deferred_and_owner_cleanup()
	await _test_game_manager_lifecycle()
	_test_new_run_reset()
	await _test_enemy_damage_event_pipeline()
	await _test_input_lock_ownership()
	_test_scene_transition_preflight()
	_test_runtime_state()
	_test_damage_calculator()
	_test_config_resources()

	EventBus.clear_all()
	InputManager.force_unblock_all()
	GameManager.reset_transient_state()
	SFXManager.stop_all()
	await get_tree().process_frame
	await get_tree().process_frame

	if _failures.is_empty():
		print("[SELFTEST] PASS — %d assertions" % _assertion_count)
		call_deferred("_quit_after_run", 0)
		return

	for failure: String in _failures:
		push_error("[SELFTEST] %s" % failure)
	print("[SELFTEST] FAIL — %d failures / %d assertions" % [_failures.size(), _assertion_count])
	call_deferred("_quit_after_run", 1)


func _quit_after_run(exit_code: int) -> void:
	get_tree().quit(exit_code)


func _test_event_bus_persistent_lifecycle() -> void:
	var pause_listener_count := EventBus.get_listener_count(GlobalDefine.EventName.GAME_PAUSE)
	var resume_listener_count := EventBus.get_listener_count(GlobalDefine.EventName.GAME_RESUME)
	_assert_true(pause_listener_count >= 2, "MusicManager 与 SFXManager 必须常驻订阅 GAME_PAUSE")
	_assert_true(resume_listener_count >= 2, "MusicManager 与 SFXManager 必须常驻订阅 GAME_RESUME")

	EventBus.clear_transient()
	_assert_equal(
		EventBus.get_listener_count(GlobalDefine.EventName.GAME_PAUSE),
		pause_listener_count,
		"场景级清理不得移除 GAME_PAUSE 应用级订阅"
	)
	_assert_equal(
		EventBus.get_listener_count(GlobalDefine.EventName.GAME_RESUME),
		resume_listener_count,
		"场景级清理不得移除 GAME_RESUME 应用级订阅"
	)
	EventBus.emit(GlobalDefine.EventName.GAME_PAUSE)
	_assert_true(MusicManager.is_paused_by_game(), "场景级清理后暂停事件仍须送达 MusicManager")
	EventBus.emit(GlobalDefine.EventName.GAME_RESUME)
	_assert_false(MusicManager.is_paused_by_game(), "场景级清理后恢复事件仍须送达 MusicManager")

	var event_name: StringName = &"self_test_persistent_lifecycle"
	var transient_listener := TestListener.new()
	transient_listener.name = "TransientListener"
	add_child(transient_listener)
	var persistent_listener := TestListener.new()
	persistent_listener.name = "PersistentListener"
	add_child(persistent_listener)
	_assert_true(
		EventBus.subscribe(event_name, transient_listener, &"record"),
		"EventBus 应接受场景级订阅"
	)
	_assert_true(
		EventBus.subscribe_persistent(event_name, persistent_listener, &"record"),
		"EventBus 应接受应用级订阅"
	)
	_assert_equal(EventBus.get_listener_count(event_name), 2, "两种生命周期的订阅都应登记")
	EventBus.clear_transient()
	_assert_equal(EventBus.get_listener_count(event_name), 1, "场景级清理只能保留应用级订阅")
	EventBus.emit(event_name, {})
	_assert_equal(transient_listener.call_count, 0, "已清理的场景级订阅不得收到事件")
	_assert_equal(persistent_listener.call_count, 1, "应用级订阅必须在场景级清理后继续收取事件")
	EventBus.unsubscribe_all(persistent_listener)
	_assert_equal(EventBus.get_listener_count(event_name), 0, "应用级订阅仍必须支持显式退订")
	transient_listener.queue_free()
	persistent_listener.queue_free()

func _test_event_bus_sync_and_snapshot() -> void:
	EventBus.clear_transient()
	var event_name: StringName = &"self_test_sync_order"
	var order: Array[String] = []
	var first := TestListener.new()
	first.name = "FirstListener"
	first.label = "first"
	first.shared_order = order
	add_child(first)
	var second := TestListener.new()
	second.name = "SecondListener"
	second.label = "second"
	second.shared_order = order
	add_child(second)

	_assert_true(EventBus.subscribe(event_name, first, &"record"), "EventBus 应接受合法订阅")
	_assert_true(EventBus.subscribe(event_name, first, &"record"), "EventBus 重复订阅应幂等成功")
	_assert_equal(EventBus.get_listener_count(event_name), 1, "owner + method 重复订阅不得重复登记")
	_assert_true(EventBus.subscribe(event_name, second, &"record"), "EventBus 应接受第二监听者")
	_assert_true(EventBus.emit(event_name, {"value": 1}), "合法事件应成功发射")
	_assert_equal(order, ["first", "second"], "emit() 必须按订阅顺序同步完成")
	_assert_equal(first.call_count, 1, "emit() 返回前监听者必须已执行")

	EventBus.clear_transient()
	order.clear()
	var snapshot_event: StringName = &"self_test_snapshot"
	first.call_count = 0
	second.call_count = 0
	first.unsubscribe_event = snapshot_event
	first.unsubscribe_target = second
	EventBus.subscribe(snapshot_event, first, &"record_and_unsubscribe")
	EventBus.subscribe(snapshot_event, second, &"record")
	EventBus.emit(snapshot_event, {})
	_assert_equal(order, ["first", "second"], "回调内退订不得破坏当前分发快照")
	order.clear()
	EventBus.emit(snapshot_event, {})
	_assert_equal(order, ["first"], "回调内退订应从下一次发射起生效")

	var selective_event: StringName = &"self_test_selective_unsubscribe"
	first.call_count = 0
	first.secondary_call_count = 0
	EventBus.subscribe(selective_event, first, &"record")
	EventBus.subscribe(selective_event, first, &"record_secondary")
	_assert_equal(EventBus.get_listener_count(selective_event), 2, "同一 owner 可为同一事件登记不同方法")
	EventBus.unsubscribe(selective_event, first, &"record")
	_assert_equal(EventBus.get_listener_count(selective_event), 1, "指定 method 退订只能移除目标回调")
	EventBus.emit(selective_event, {})
	_assert_equal(first.call_count, 0, "指定 method 退订后原回调不得再执行")
	_assert_equal(first.secondary_call_count, 1, "指定 method 退订不得影响同 owner 的其他回调")
	EventBus.unsubscribe(selective_event, first)
	_assert_equal(EventBus.get_listener_count(selective_event), 0, "省略 method 时应移除 owner 在事件下的全部回调")

	var valid_payload := {
		"player": self,
		"damage": 1,
		"current_health": 9,
	}
	_assert_true(EventBus.validate_payload(GlobalDefine.EventName.PLAYER_HURT, valid_payload, false), "核心事件合法 payload 应通过")
	_assert_false(EventBus.validate_payload(GlobalDefine.EventName.PLAYER_HURT, {"player": self}, false), "缺字段 payload 必须被拒绝")
	_assert_false(EventBus.validate_payload(GlobalDefine.EventName.PLAYER_HURT, {"player": self, "damage": 1.0, "current_health": 9}, false), "字段类型错误必须被拒绝")

	first.queue_free()
	second.queue_free()


func _test_event_bus_deferred_and_owner_cleanup() -> void:
	EventBus.clear_transient()
	var deferred_event: StringName = &"self_test_deferred"
	var listener := TestListener.new()
	listener.name = "DeferredListener"
	listener.label = "deferred"
	add_child(listener)
	EventBus.subscribe(deferred_event, listener, &"record")
	var deferred_payload := {"nested": {"value": 1}}
	_assert_true(EventBus.emit_deferred(deferred_event, deferred_payload), "延迟事件应成功入队")
	deferred_payload["nested"]["value"] = 99
	_assert_equal(listener.call_count, 0, "emit_deferred() 不得在调用栈内执行")
	get_tree().paused = true
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().paused = false
	_assert_equal(listener.call_count, 1, "延迟事件应在暂停状态下于后续 process 帧送达")
	_assert_equal(
		listener.received_payloads[0]["nested"]["value"],
		1,
		"延迟事件必须使用入队时的 payload 深拷贝"
	)

	var cleanup_event: StringName = &"self_test_owner_cleanup"
	EventBus.subscribe(cleanup_event, listener, &"record")
	_assert_equal(EventBus.get_listener_count(cleanup_event), 1, "清理测试订阅应已建立")
	listener.queue_free()
	await get_tree().process_frame
	_assert_equal(EventBus.get_listener_count(cleanup_event), 0, "订阅 owner 离树后必须自动清理")

	var cancelled_event: StringName = &"self_test_cancelled_deferred"
	var cancellation_listener := TestListener.new()
	cancellation_listener.name = "CancellationListener"
	add_child(cancellation_listener)
	EventBus.subscribe_persistent(cancelled_event, cancellation_listener, &"record")
	EventBus.emit_deferred(cancelled_event, {})
	EventBus.clear_transient()
	await get_tree().process_frame
	await get_tree().process_frame
	_assert_equal(cancellation_listener.call_count, 0, "场景级清理必须取消尚未投递的延迟事件")
	EventBus.unsubscribe_all(cancellation_listener)
	cancellation_listener.queue_free()
	EventBus.clear_transient()


func _test_game_manager_lifecycle() -> void:
	GameManager.reset_transient_state()
	var enemy := DummyEnemy.new()
	enemy.name = "RegisteredEnemy"
	add_child(enemy)
	GameManager.register_enemy(enemy)
	GameManager.register_enemy(enemy)
	_assert_equal(GameManager.get_enemies().size(), 1, "敌人重复注册必须幂等")
	enemy.queue_free()
	await get_tree().process_frame
	_assert_true(GameManager.get_enemies().is_empty(), "敌人离树后注册表必须自动清理")

	var dialog_owner_a := Node.new()
	dialog_owner_a.name = "DialogOwnerA"
	add_child(dialog_owner_a)
	var dialog_owner_b := Node.new()
	dialog_owner_b.name = "DialogOwnerB"
	add_child(dialog_owner_b)
	GameManager.begin_dialog(dialog_owner_a)
	GameManager.begin_dialog(dialog_owner_a)
	GameManager.begin_dialog(dialog_owner_b)
	_assert_true(GameManager.is_dialog_active, "任一对话 owner 持锁时对话状态必须为真")
	GameManager.end_dialog(dialog_owner_a)
	_assert_true(GameManager.is_dialog_active, "同 owner 嵌套对话只释放一层后仍应激活")
	GameManager.end_dialog(dialog_owner_a)
	_assert_true(GameManager.is_dialog_active, "另一个 owner 仍持有对话状态")
	dialog_owner_b.queue_free()
	await get_tree().process_frame
	_assert_false(GameManager.is_dialog_active, "最后一个对话 owner 离树后必须自动复位")
	dialog_owner_a.queue_free()


func _test_new_run_reset() -> void:
	GameManager.set_dream_flag(&"temporary_theme_flag", "old_run")
	GameManager.set_checkpoint("res://OldRun.tscn", 3, {"value": 1})
	GameManager.is_game_over = true
	GameManager.begin_new_run(GlobalDefine.RunMode.SELF_TEST)
	_assert_equal(GameManager.run_mode, GlobalDefine.RunMode.SELF_TEST, "开始新局必须应用指定运行模式")
	_assert_true(GameManager.dream_runtime_state.is_empty(), "开始新局必须清空上一局梦境状态")
	_assert_equal(GameManager.checkpoint_scene_path, "", "开始新局必须清空上一局检查点场景")
	_assert_equal(GameManager.checkpoint_stage, 0, "开始新局必须清空上一局检查点阶段")
	_assert_true(GameManager.checkpoint_data.is_empty(), "开始新局必须清空上一局检查点数据")
	_assert_false(GameManager.is_game_over, "开始新局必须复位游戏结束状态")


func _test_enemy_damage_event_pipeline() -> void:
	EventBus.clear_transient()
	GameManager.reset_transient_state()
	SFXManager.set_muted(true)
	var damage_listener := TestListener.new()
	damage_listener.name = "DamageListener"
	add_child(damage_listener)
	var death_listener := TestListener.new()
	death_listener.name = "DeathListener"
	add_child(death_listener)
	EventBus.subscribe(GlobalDefine.EventName.DAMAGE_APPLIED, damage_listener, &"record")
	EventBus.subscribe(GlobalDefine.EventName.ENEMY_DIED, death_listener, &"record")

	var enemy := EnemyBase.new()
	enemy.name = "DamagePipelineEnemy"
	var enemy_config := EnemyConfig.new()
	enemy_config.max_health = 10
	enemy_config.exp_reward = 7
	enemy.config = enemy_config
	add_child(enemy)
	enemy.take_damage(12, Vector2.ZERO, self)
	_assert_equal(damage_listener.call_count, 1, "敌人受伤必须同步发射一次 damage_applied")
	var damage_payload: Dictionary = damage_listener.received_payloads[0]
	_assert_equal(damage_payload["source"], self, "damage_applied 必须保留伤害来源")
	_assert_equal(damage_payload["raw_damage"], 12, "普通敌人 raw_damage 应为输入伤害")
	_assert_equal(damage_payload["current_health"], 0, "伤害事件必须包含扣血后的生命值")
	_assert_true(enemy.is_dead, "致死伤害后敌人必须进入死亡标记")
	_assert_equal(enemy.current_state, GlobalDefine.EnemyState.DEAD, "致死伤害后必须先进入 DEAD 状态")
	_assert_equal(death_listener.call_count, 1, "敌人死亡事件必须只发射一次")
	_assert_true(GameManager.get_enemies().is_empty(), "死亡敌人必须立即从全局注册表移除")
	enemy.take_damage(12, Vector2.ZERO, self)
	_assert_equal(death_listener.call_count, 1, "死亡后的重复伤害不得再次广播死亡")

	if is_instance_valid(enemy):
		enemy.config = null
		enemy.queue_free()
	enemy_config = null
	damage_listener.queue_free()
	death_listener.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	EventBus.clear_transient()
	SFXManager.set_muted(false)


func _test_input_lock_ownership() -> void:
	InputManager.force_unblock_all()
	var owner_a := Node.new()
	owner_a.name = "InputOwnerA"
	add_child(owner_a)
	var owner_b := Node.new()
	owner_b.name = "InputOwnerB"
	add_child(owner_b)
	var player_probe := PlayerBase.new()
	Input.action_press("ui_right")
	_assert_true(player_probe._get_input_direction().x > 0.9, "未锁定时玩家方向轮询必须读取输入")
	var polling_token := InputManager.block_input("polling", owner_a)
	_assert_true(InputManager.is_gameplay_input_blocked(), "全局输入锁必须覆盖玩家每帧轮询")
	_assert_equal(player_probe._get_input_direction(), Vector2.ZERO, "锁定时玩家方向轮询必须返回零向量")
	Input.action_release("ui_right")
	InputManager.unblock_input_token(polling_token)
	player_probe.free()
	var token_a_1 := InputManager.block_input("nested", owner_a)
	InputManager.block_input("nested", owner_a)
	var token_b := InputManager.block_input("other", owner_b)
	_assert_equal(InputManager.get_active_locks().size(), 3, "嵌套输入锁必须分别计数")
	_assert_true(InputManager.unblock_input("nested", owner_a), "owner + reason 应释放最近一把匹配锁")
	_assert_equal(InputManager.get_active_locks().size(), 2, "按 owner 释放不得影响其他 owner")
	_assert_true(InputManager.unblock_input_token(token_a_1), "token 应能精确释放对应输入锁")
	_assert_equal(InputManager.get_active_locks().size(), 1, "精确 token 释放后只应剩其他 owner 的锁")
	_assert_true(InputManager.unblock_input_token(token_b), "另一个 token 应可释放")
	_assert_false(InputManager.is_input_blocked, "全部 token 释放后输入应恢复")

	InputManager.block_action(&"player_attack", "nested action", owner_a)
	InputManager.block_action(&"player_attack", "nested action", owner_a)
	InputManager.unblock_action(&"player_attack", owner_a)
	_assert_true(InputManager.is_action_blocked(&"player_attack"), "动作锁嵌套释放一层后仍应生效")
	owner_a.queue_free()
	await get_tree().process_frame
	_assert_false(InputManager.is_action_blocked(&"player_attack"), "动作锁 owner 离树后必须自动释放")
	owner_b.queue_free()


func _test_scene_transition_preflight() -> void:
	var probe := TransitionCleanupProbe.new()
	probe.name = "TransitionCleanupProbe"
	add_child(probe)
	var token := InputManager.block_input("invalid transition", probe)
	GameManager.set_dream_flag(&"temporary_theme_flag", "keep")
	SceneTransitionManager.request_scene_change("res://Tests/SelfTest/DefinitelyMissing.tscn", probe)
	_assert_equal(probe.prepare_calls, 0, "无效转场不得调用当前场景清理钩子")
	_assert_true(InputManager.is_input_blocked, "无效转场不得清除现有输入锁")
	_assert_equal(GameManager.get_dream_flag(&"temporary_theme_flag"), "keep", "无效转场不得重置当前运行状态")
	_assert_false(SceneTransitionManager.is_transitioning, "无效转场不得进入切换中状态")
	InputManager.unblock_input_token(token)
	GameManager.dream_runtime_state.erase_value(&"temporary_theme_flag")
	probe.queue_free()


func _test_runtime_state() -> void:
	var state := DreamRuntimeState.new()
	_assert_true(state.set_value(&"erosion_value", 12), "整数侵蚀值应安全归一化为浮点数")
	_assert_equal(state.erosion_value(), 12.0, "侵蚀值类型化读取应正确")
	_assert_true(state.set_value(&"player_damage_reduction", true), "已知布尔键应接受正确类型")
	_assert_equal(state.incoming_damage_multiplier(), 0.5, "减伤标志应映射为统一倍率")
	_assert_true(state.set_value(&"temporary_theme_flag", "theme"), "未知赛题键应保持向前兼容")
	_assert_equal(state.get_value(&"temporary_theme_flag"), "theme", "未知键应可原样读取")
	_assert_true(state.set_value(&"player_health", 10), "玩家血量应接受整数")
	_assert_false(state.merge_from({"player_health": 20, "erosion_value": "invalid"}, false), "含非法类型的批量状态必须整体拒绝")
	_assert_equal(state.get_value(&"player_health"), 10, "批量状态失败时不得留下部分写入")


func _test_damage_calculator() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var result := DamageCalculator.calculate(100, 20, GlobalDefine.DamageType.PHYSICAL, 1.0, 2.0, rng)
	_assert_equal(result["damage"], 180, "物理伤害、减防和必暴应按统一公式结算")
	_assert_true(bool(result["is_crit"]), "100% 暴击率必须暴击")
	_assert_equal(DamageCalculator.resolve_incoming(21, 0.5), 11, "目标侧减伤必须在扣血前统一取整")
	_assert_equal(DamageCalculator.resolve_incoming(0, 0.5), 0, "零伤害不得被最小伤害抬高")


func _test_config_resources() -> void:
	var errors := ConfigValidator.validate_all()
	for error_text: String in errors:
		print("[CONFIG AUDIT] %s" % error_text)
	_assert_true(errors.is_empty(), "DataConfig 资源结构审计必须全部通过")


func _assert_true(condition: bool, message: String) -> void:
	_assertion_count += 1
	if not condition:
		_failures.append(message)


func _assert_false(condition: bool, message: String) -> void:
	_assert_true(not condition, message)


func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	_assertion_count += 1
	if actual != expected:
		_failures.append("%s（实际=%s，期望=%s）" % [message, actual, expected])
