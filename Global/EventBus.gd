# ============================================================
# EventBus.gd - 全局事件中介者 (Autoload)
#
# 契约:
#   - emit() 同步分发；需要跨帧时显式使用 emit_deferred()
#   - 订阅以 owner + method 幂等去重，owner 离树后自动清理
#   - 场景级订阅可批量清理；应用级订阅在 Autoload 生命周期内保留
#   - 分发使用监听快照，允许回调内订阅/退订而不破坏本轮遍历
#   - 核心事件在分发前校验最小 payload 契约
# ============================================================
extends Node

# { StringName: Array[Dictionary{owner_id, owner, callback, method, persistent}] }
var _listeners: Dictionary = {}
var _pending_events: Array[Dictionary] = []
var _tracked_owner_ids: Dictionary = {}

# 只规定所有生产者都必须提供的最小字段；额外字段保持开放。
var _payload_contracts: Dictionary = {
	&"player_spawned": {&"player": TYPE_OBJECT},
	&"player_died": {&"player": TYPE_OBJECT},
	&"player_hurt": {&"player": TYPE_OBJECT, &"damage": TYPE_INT, &"current_health": TYPE_INT},
	&"player_attack_hit": {&"attacker": TYPE_OBJECT, &"target": TYPE_OBJECT, &"damage": TYPE_INT, &"is_crit": TYPE_BOOL},
	&"player_state_changed": {&"player": TYPE_OBJECT, &"state": TYPE_INT},
	&"enemy_spawned": {&"enemy": TYPE_OBJECT},
	&"enemy_died": {&"enemy": TYPE_OBJECT, &"exp_reward": TYPE_INT},
	&"enemy_hurt": {&"enemy": TYPE_OBJECT, &"damage": TYPE_INT, &"current_health": TYPE_INT},
	&"level_loaded": {&"level": TYPE_OBJECT},
	&"level_complete": {&"level": TYPE_OBJECT, &"next_level": TYPE_STRING},
	&"interactive_object_triggered": {&"object_id": TYPE_STRING},
	&"damage_applied": {&"target": TYPE_OBJECT, &"raw_damage": TYPE_INT, &"damage": TYPE_INT, &"current_health": TYPE_INT},
	&"health_changed": {&"target": TYPE_OBJECT, &"current_health": TYPE_INT, &"max_health": TYPE_INT},
}


func _ready() -> void:
	# 暂停菜单或转场期间投递的显式延迟事件也必须能够排空。
	process_mode = Node.PROCESS_MODE_ALWAYS


## 注册场景级订阅。返回 false 表示订阅未建立。
func subscribe(event_name: StringName, owner: Node, method: StringName) -> bool:
	return _subscribe(event_name, owner, method, false)


## 注册应用级订阅。clear_transient() 不会移除；owner 离树或显式退订仍会清理。
func subscribe_persistent(event_name: StringName, owner: Node, method: StringName) -> bool:
	return _subscribe(event_name, owner, method, true)


func _subscribe(event_name: StringName, owner: Node, method: StringName, persistent: bool) -> bool:
	if event_name == &"":
		push_warning("[EventBus] 订阅失败：事件名不能为空")
		return false
	if owner == null or not is_instance_valid(owner):
		push_warning("[EventBus] 订阅失败：owner 已失效 (%s.%s)" % [event_name, method])
		return false
	if not owner.has_method(method):
		push_warning("[EventBus] 订阅失败：%s 缺少方法 %s" % [owner.name, method])
		return false

	var callback := Callable(owner, method)
	if not callback.is_valid():
		push_warning("[EventBus] 订阅失败：Callable 无效 (%s.%s)" % [event_name, method])
		return false

	var owner_id := owner.get_instance_id()
	var listeners: Array = _listeners.get(event_name, [])
	for index: int in listeners.size():
		var item: Dictionary = listeners[index]
		if int(item["owner_id"]) == owner_id and StringName(item["method"]) == method:
			# 相同订阅只能提升为应用级，避免一次普通重复订阅意外降级。
			if persistent and not bool(item.get("persistent", false)):
				item["persistent"] = true
				listeners[index] = item
				_listeners[event_name] = listeners
			return true

	listeners.append({
		"owner_id": owner_id,
		"owner": weakref(owner),
		"callback": callback,
		"method": method,
		"persistent": persistent,
	})
	_listeners[event_name] = listeners
	_track_owner_exit(owner)
	return true


## 取消 owner 对某一事件的订阅。method 为空时移除该 owner 在此事件下的全部回调。
func unsubscribe(event_name: StringName, owner: Node, method: StringName = &"") -> void:
	if owner == null or not _listeners.has(event_name):
		return
	_remove_owner_from_event(event_name, owner.get_instance_id(), method)


## 取消 owner 的全部事件订阅。
func unsubscribe_all(owner: Node) -> void:
	if owner == null:
		return
	_unsubscribe_owner_id(owner.get_instance_id())


## 同步发射。返回 false 表示 payload 不合法；合法但无人订阅仍返回 true。
func emit(event_name: StringName, data: Dictionary = {}) -> bool:
	if not validate_payload(event_name, data):
		return false
	if not _listeners.has(event_name):
		return true

	# 快照保证回调内修改订阅表不会跳过或重复本轮监听者。
	var listeners_snapshot: Array = (_listeners[event_name] as Array).duplicate()
	for item: Dictionary in listeners_snapshot:
		var owner_ref: WeakRef = item["owner"] as WeakRef
		var owner: Object = owner_ref.get_ref() if owner_ref else null
		var callback: Callable = item["callback"] as Callable
		if owner == null or not is_instance_valid(owner) or not callback.is_valid():
			_remove_owner_from_event(event_name, int(item["owner_id"]), StringName(item["method"]))
			continue
		# GDScript 没有 try/catch；引擎会记录单个脚本回调错误，快照遍历仍可继续。
		callback.call(data)
	return true


## 下一 process 帧同步分发队列中的事件。复制 payload，避免调用方随后修改。
func emit_deferred(event_name: StringName, data: Dictionary = {}) -> bool:
	if not validate_payload(event_name, data):
		return false
	_pending_events.append({"event": event_name, "data": data.duplicate(true)})
	return true


func validate_payload(event_name: StringName, data: Dictionary, report_error: bool = true) -> bool:
	var contract: Dictionary = _payload_contracts.get(event_name, {})
	for key: StringName in contract:
		if not data.has(key):
			if report_error:
				push_error("[EventBus] 事件 %s 缺少 payload 字段 '%s'" % [event_name, key])
			return false
		var expected_type: int = int(contract[key])
		if typeof(data[key]) != expected_type:
			if report_error:
				push_error("[EventBus] 事件 %s 字段 '%s' 类型错误：期望 %s，实际 %s" % [
					event_name,
					key,
					type_string(expected_type),
					type_string(typeof(data[key])),
				])
			return false
	return true


func get_listener_count(event_name: StringName) -> int:
	_prune_event(event_name)
	return (_listeners.get(event_name, []) as Array).size()


## 清除场景级订阅及尚未投递的延迟事件，保留应用级订阅。
func clear_transient() -> void:
	for event_name: StringName in _listeners.keys():
		_prune_event(event_name)
		if not _listeners.has(event_name):
			continue
		var persistent_listeners: Array = []
		for item: Dictionary in _listeners[event_name]:
			if bool(item.get("persistent", false)):
				persistent_listeners.append(item)
		if persistent_listeners.is_empty():
			_listeners.erase(event_name)
		else:
			_listeners[event_name] = persistent_listeners
	_pending_events.clear()


## 硬清理所有订阅及延迟事件。通常只用于进程退出或完全重置。
func clear_all() -> void:
	_listeners.clear()
	_pending_events.clear()


func _process(_delta: float) -> void:
	if _pending_events.is_empty():
		return
	var events := _pending_events
	_pending_events = []
	for event: Dictionary in events:
		emit(StringName(event["event"]), event["data"] as Dictionary)


func _track_owner_exit(owner: Node) -> void:
	var owner_id := owner.get_instance_id()
	if _tracked_owner_ids.has(owner_id):
		return
	_tracked_owner_ids[owner_id] = true
	owner.tree_exited.connect(_on_subscriber_tree_exited.bind(owner_id), CONNECT_ONE_SHOT)


func _on_subscriber_tree_exited(owner_id: int) -> void:
	_unsubscribe_owner_id(owner_id)
	_tracked_owner_ids.erase(owner_id)


func _unsubscribe_owner_id(owner_id: int) -> void:
	for event_name: StringName in _listeners.keys():
		_remove_owner_from_event(event_name, owner_id)


func _remove_owner_from_event(event_name: StringName, owner_id: int, method: StringName = &"") -> void:
	if not _listeners.has(event_name):
		return
	var filtered: Array = []
	for item: Dictionary in _listeners[event_name]:
		var owner_matches := int(item["owner_id"]) == owner_id
		var method_matches := method == &"" or StringName(item["method"]) == method
		if not (owner_matches and method_matches):
			filtered.append(item)
	if filtered.is_empty():
		_listeners.erase(event_name)
	else:
		_listeners[event_name] = filtered


func _prune_event(event_name: StringName) -> void:
	if not _listeners.has(event_name):
		return
	var stale_listeners: Array[Dictionary] = []
	for item: Dictionary in _listeners[event_name]:
		var owner_ref: WeakRef = item["owner"] as WeakRef
		var owner: Object = owner_ref.get_ref() if owner_ref else null
		var callback: Callable = item["callback"] as Callable
		if owner == null or not is_instance_valid(owner) or not callback.is_valid():
			stale_listeners.append(item)
	for item: Dictionary in stale_listeners:
		_remove_owner_from_event(event_name, int(item["owner_id"]), StringName(item["method"]))
