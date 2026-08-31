# ============================================================
# InputManager.gd - 统一输入管理器 (Autoload, PROCESS_MODE_ALWAYS)
#
# 输入锁由 owner 管理：owner 离树自动释放，嵌套锁按 token 独立计数。
# 旧的 reason-only unblock 仍兼容，但新代码应同时传入 owner。
# ============================================================
extends Node

signal game_action(action: StringName, event: InputEvent)

var is_input_blocked: bool = false
var block_reason: String = ""
var captured_this_frame: StringName = &""

var _pause_allowed: bool = true
var _next_lock_token: int = 1
var _input_locks: Dictionary = {}
var _blocked_actions: Dictionary = {}
var _tracked_owner_ids: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		if _pause_allowed:
			_handle_pause()
		return

	if _should_block_game_input():
		return
	if event is InputEventMouseButton and _is_mouse_over_interactive_gui(event as InputEventMouse):
		return
	if _is_blocked_action_event(event):
		get_viewport().set_input_as_handled()
		return

	var action := _identify_game_action(event)
	if action != &"":
		_emit_action(action, event)


func _should_block_game_input() -> bool:
	_prune_dead_owners()
	return GameManager.is_paused or is_input_blocked or _is_ui_focused()


## 统一供事件分发与玩家每帧轮询使用，避免移动、跳跃或长按技能绕过全局锁。
func is_gameplay_input_blocked() -> bool:
	return _should_block_game_input()


func _is_ui_focused() -> bool:
	var focused := get_viewport().gui_get_focus_owner()
	if focused == null or not (focused is Control):
		return false
	var control := focused as Control
	if not control.is_visible_in_tree():
		get_viewport().gui_release_focus()
		return false
	return true


func _is_mouse_over_interactive_gui(event: InputEventMouse) -> bool:
	var viewport := get_viewport()
	if viewport == null:
		return false
	var mouse_pos := event.global_position
	for child: Node in viewport.get_children():
		if child is Control or child is CanvasLayer:
			if _find_interactive_control_at_pos(child, mouse_pos):
				return true
		elif _find_canvas_layer_gui_at_pos(child, mouse_pos):
			return true
	return false


func _find_interactive_control_at_pos(node: Node, pos: Vector2) -> bool:
	if node is Control:
		var control := node as Control
		if control.is_visible_in_tree() and control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			if control.get_global_rect().has_point(pos):
				return true
	for child: Node in node.get_children():
		if _find_interactive_control_at_pos(child, pos):
			return true
	return false


func _find_canvas_layer_gui_at_pos(node: Node, pos: Vector2) -> bool:
	for child: Node in node.get_children():
		if child is CanvasLayer and _find_interactive_control_at_pos(child, pos):
			return true
		if _find_canvas_layer_gui_at_pos(child, pos):
			return true
	return false


func _emit_action(action: StringName, event: InputEvent) -> void:
	game_action.emit(action, event)
	captured_this_frame = action
	get_viewport().set_input_as_handled()


func _handle_pause() -> void:
	GameManager.toggle_pause()
	get_viewport().set_input_as_handled()


func _identify_game_action(event: InputEvent) -> StringName:
	if event.is_action_pressed("player_attack"):
		return &"player_attack"
	if event.is_action_pressed("player_dash"):
		return &"player_dash"
	if event.is_action_pressed("player_skill"):
		return &"player_skill"
	if event.is_action_pressed("player_skill_2"):
		return &"player_skill_2"
	if event.is_action_pressed("ui_accept"):
		return &"ui_accept"
	return &""


func _is_blocked_action_event(event: InputEvent) -> bool:
	for action: StringName in _blocked_actions:
		if event.is_action_pressed(action):
			return true
	return false


func block_action(action: StringName, reason: String = "", owner: Node = null) -> void:
	var owner_id := _owner_id(owner)
	var owners: Dictionary = _blocked_actions.get(action, {})
	var entry: Dictionary = owners.get(owner_id, {"count": 0, "reason": reason, "owner": weakref(owner) if owner else null})
	entry["count"] = int(entry["count"]) + 1
	entry["reason"] = reason
	owners[owner_id] = entry
	_blocked_actions[action] = owners
	_track_owner(owner)


func unblock_action(action: StringName, owner: Node = null) -> void:
	if not _blocked_actions.has(action):
		return
	if owner == null:
		# 兼容旧调用：未指定 owner 时清除此动作全部锁。
		_blocked_actions.erase(action)
		return
	var owner_id := owner.get_instance_id()
	var owners: Dictionary = _blocked_actions[action]
	if not owners.has(owner_id):
		return
	var entry: Dictionary = owners[owner_id]
	entry["count"] = maxi(int(entry["count"]) - 1, 0)
	if int(entry["count"]) == 0:
		owners.erase(owner_id)
	else:
		owners[owner_id] = entry
	if owners.is_empty():
		_blocked_actions.erase(action)
	else:
		_blocked_actions[action] = owners


func clear_action_blocks() -> void:
	_blocked_actions.clear()


func is_action_blocked(action: StringName) -> bool:
	_prune_dead_owners()
	return _blocked_actions.has(action)


## 返回锁 token，供需要精确配对的系统保存；现有调用可忽略返回值。
func block_input(reason: String, owner: Node = null) -> int:
	var token := _next_lock_token
	_next_lock_token += 1
	_input_locks[token] = {
		"reason": reason,
		"owner_id": _owner_id(owner),
		"owner": weakref(owner) if owner else null,
	}
	_track_owner(owner)
	_refresh_input_lock_state()
	return token


## 优先按 owner + reason 释放最近一把锁；省略 owner 时按 reason 兼容旧调用。
func unblock_input(reason: String = "", owner: Node = null) -> bool:
	_prune_dead_owners()
	var owner_id := _owner_id(owner)
	var matching_token := -1
	var tokens: Array = _input_locks.keys()
	tokens.sort()
	tokens.reverse()
	for token: int in tokens:
		var entry: Dictionary = _input_locks[token]
		if owner and int(entry["owner_id"]) != owner_id:
			continue
		if reason != "" and String(entry["reason"]) != reason:
			continue
		matching_token = token
		break
	if matching_token < 0:
		return false
	_input_locks.erase(matching_token)
	_refresh_input_lock_state()
	return true


## 按 block_input() 返回的 token 精确释放，不影响同 owner 的其他嵌套锁。
func unblock_input_token(token: int) -> bool:
	if not _input_locks.has(token):
		return false
	_input_locks.erase(token)
	_refresh_input_lock_state()
	return true


func release_input_for_owner(owner: Node) -> void:
	if owner == null:
		return
	_release_owner_id(owner.get_instance_id())


func force_unblock_all() -> void:
	_input_locks.clear()
	clear_action_blocks()
	_refresh_input_lock_state()


func set_pause_allowed(allowed: bool) -> void:
	_pause_allowed = allowed


func get_active_locks() -> Array[Dictionary]:
	_prune_dead_owners()
	var result: Array[Dictionary] = []
	for token: int in _input_locks:
		var entry: Dictionary = _input_locks[token].duplicate()
		entry["token"] = token
		result.append(entry)
	return result


func _owner_id(owner: Node) -> int:
	return owner.get_instance_id() if owner and is_instance_valid(owner) else 0


func _track_owner(owner: Node) -> void:
	if owner == null or not is_instance_valid(owner):
		return
	var owner_id := owner.get_instance_id()
	if _tracked_owner_ids.has(owner_id):
		return
	_tracked_owner_ids[owner_id] = true
	owner.tree_exited.connect(_on_lock_owner_tree_exited.bind(owner_id), CONNECT_ONE_SHOT)


func _on_lock_owner_tree_exited(owner_id: int) -> void:
	_release_owner_id(owner_id)
	_tracked_owner_ids.erase(owner_id)


func _release_owner_id(owner_id: int) -> void:
	for token: int in _input_locks.keys():
		if int(_input_locks[token]["owner_id"]) == owner_id:
			_input_locks.erase(token)
	for action: StringName in _blocked_actions.keys():
		var owners: Dictionary = _blocked_actions[action]
		owners.erase(owner_id)
		if owners.is_empty():
			_blocked_actions.erase(action)
		else:
			_blocked_actions[action] = owners
	_refresh_input_lock_state()


func _prune_dead_owners() -> void:
	var stale_ids: Dictionary = {}
	for entry: Dictionary in _input_locks.values():
		if int(entry["owner_id"]) == 0:
			continue
		var owner_ref: WeakRef = entry["owner"] as WeakRef
		if owner_ref == null or owner_ref.get_ref() == null:
			stale_ids[int(entry["owner_id"])] = true
	for owners_value: Variant in _blocked_actions.values():
		var owners: Dictionary = owners_value
		for owner_id: int in owners:
			if owner_id == 0:
				continue
			var owner_ref: WeakRef = owners[owner_id]["owner"] as WeakRef
			if owner_ref == null or owner_ref.get_ref() == null:
				stale_ids[owner_id] = true
	for owner_id: int in stale_ids:
		_release_owner_id(owner_id)


func _refresh_input_lock_state() -> void:
	is_input_blocked = not _input_locks.is_empty()
	block_reason = ""
	if not is_input_blocked:
		return
	var tokens: Array = _input_locks.keys()
	tokens.sort()
	block_reason = String(_input_locks[tokens.back()]["reason"])
