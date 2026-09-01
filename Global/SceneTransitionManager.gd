# ============================================================
# SceneTransitionManager.gd - 统一场景切换与全局清理
#
# 职责:
#   1. 预加载目标 PackedScene，并提供整树切换的唯一入口
#   2. 为 MainEntry 托管切换提供同一套全局清理
#   3. 在切换前调用关卡自定义 prepare_for_level_exit()
# ============================================================
extends Node

var is_transitioning: bool = false

enum TransitionPhase {
	IDLE,
	WAIT_TO_CHANGE,
	WAIT_TO_COMPLETE,
}

var _transition_phase: int = TransitionPhase.IDLE
var _transition_target_frame: int = 0
var _pending_scene: PackedScene = null
var _pending_scene_path: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if _transition_phase == TransitionPhase.IDLE:
		return
	if Engine.get_process_frames() < _transition_target_frame:
		return
	var tree := get_tree()
	if tree == null:
		_finish_pending_transition()
		return
	if _transition_phase == TransitionPhase.WAIT_TO_CHANGE:
		var target_scene := _pending_scene
		var scene_path := _pending_scene_path
		_pending_scene = null
		print("[SceneTransitionManager] change_scene_to_packed → ", scene_path)
		var err := tree.change_scene_to_packed(target_scene)
		if err != OK:
			push_warning("[SceneTransitionManager] 切换失败: %s (err=%d)" % [scene_path, err])
			_finish_pending_transition()
			return
		_transition_phase = TransitionPhase.WAIT_TO_COMPLETE
		_transition_target_frame = Engine.get_process_frames() + 1
		return
	_finish_pending_transition()


func _exit_tree() -> void:
	_finish_pending_transition()


func cleanup_for_transition(source: Node = null) -> void:
	_call_prepare_for_exit(source)
	var tree = get_tree()
	if tree != null:
		var current: Node = tree.current_scene
		if current != source:
			_call_prepare_for_exit(current)
		tree.paused = false

	EventBus.clear_transient()
	GameManager.reset_transient_state()
	InputManager.force_unblock_all()
	MusicManager.clear_game_pause()
	SFXManager.stop_all()
	var viewport := get_viewport()
	if viewport != null:
		viewport.gui_release_focus()


func _call_prepare_for_exit(node: Node) -> void:
	if node and is_instance_valid(node) and node.has_method("prepare_for_level_exit"):
		node.call("prepare_for_level_exit")


func request_scene_change(scene_path: String, source: Node = null) -> void:
	if is_transitioning:
		print("[SceneTransitionManager] 忽略重复切换请求: ", scene_path)
		return

	var tree = get_tree()
	if tree == null:
		push_warning("[SceneTransitionManager] SceneTree 不存在，无法切换场景: %s" % scene_path)
		return

	var target_scene := _load_target_scene(scene_path)
	if target_scene == null:
		return

	is_transitioning = true
	cleanup_for_transition(source)
	_pending_scene = target_scene
	_pending_scene_path = scene_path
	_transition_phase = TransitionPhase.WAIT_TO_CHANGE
	_transition_target_frame = Engine.get_process_frames() + 1


func _finish_pending_transition() -> void:
	_transition_phase = TransitionPhase.IDLE
	_transition_target_frame = 0
	_pending_scene = null
	_pending_scene_path = ""
	is_transitioning = false


## 在触碰当前场景状态前完成目标资源验证和加载。
## 返回 null 时 request_scene_change() 保证不执行任何清理。
func _load_target_scene(scene_path: String) -> PackedScene:
	if scene_path == "" or not ResourceLoader.exists(scene_path):
		push_warning("[SceneTransitionManager] 目标场景不存在: %s" % scene_path)
		return null
	var target_scene := load(scene_path) as PackedScene
	if target_scene == null:
		push_warning("[SceneTransitionManager] 目标资源不是可用场景: %s" % scene_path)
		return null
	return target_scene


func request_checkpoint_restart() -> void:
	var tree = get_tree()
	var path := GameManager.checkpoint_scene_path
	if path == "" or not ResourceLoader.exists(path):
		print("[SceneTransitionManager] 无有效检查点，reload_current_scene")
		var fallback_current: Node = null
		if tree != null:
			fallback_current = tree.current_scene
		cleanup_for_transition(fallback_current)
		if tree != null:
			tree.reload_current_scene()
		return

	print("[SceneTransitionManager] 从检查点重新开始: %s (stage=%d)" % [path, GameManager.checkpoint_stage])
	var current: Node = null
	if tree != null:
		current = tree.current_scene
	if current and current.has_method("_switch_to_level"):
		if is_transitioning:
			return
		is_transitioning = true
		await current._switch_to_level(path)
		is_transitioning = false
	else:
		request_scene_change(path, current)
