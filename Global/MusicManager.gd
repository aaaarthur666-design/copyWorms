# ============================================================
# MusicManager.gd - 全局音乐管理器 (Autoload)
#
# 设计:
#   - 单一主播放器 + 一个可选淡入播放器
#   - transition_id 防止旧 Tween 回调污染新切换
#   - LevelBase 通过 play_level_bgm(level_config) 播放配置 BGM
#   - 关卡脚本仅在阶段内换曲时调用 fade_to()
# ============================================================
extends Node

var _current_bgm_path: String = ""
var _base_volume_db: float = 0.0
var _transition_id: int = 0
var _paused_by_game: bool = false

enum FadeMode {
	NONE,
	CROSSFADE,
	STOP,
}

var _fade_mode: int = FadeMode.NONE
var _fade_transition_id: int = -1
var _fade_duration: float = 0.0
var _fade_elapsed: float = 0.0
var _fade_primary_start_db: float = 0.0
var _fade_secondary_start_db: float = -80.0

var _primary_player: AudioStreamPlayer = null
var _fade_player: AudioStreamPlayer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.subscribe_persistent(GlobalDefine.EventName.GAME_PAUSE, self, "_on_game_pause")
	EventBus.subscribe_persistent(GlobalDefine.EventName.GAME_RESUME, self, "_on_game_resume")


func _exit_tree() -> void:
	_release_audio_resources_for_exit()


func _process(delta: float) -> void:
	_update_fade(delta)


func _on_game_pause(_data: Dictionary = {}) -> void:
	_paused_by_game = true
	_apply_pause_state()


func _on_game_resume(_data: Dictionary = {}) -> void:
	_paused_by_game = false
	_apply_pause_state()


func play_level_bgm(config: LevelConfig, from_position: float = 0.0) -> void:
	if not config:
		return
	if config.bgm_resource:
		play_bgm_from_stream(config.bgm_resource, from_position)
	elif config.bgm_path != "":
		play_bgm(config.bgm_path, from_position)


func play_bgm(stream_path: String, from_position: float = 0.0) -> void:
	var stream := _load_stream(stream_path)
	if not stream:
		return
	if _is_current_or_loaded(stream_path):
		return
	_transition_id += 1
	_cancel_fade()
	_free_player(_fade_player)
	_fade_player = null
	_free_player(_primary_player)
	_primary_player = _make_player(stream, _base_volume_db)
	_bind_primary_finished()
	_primary_player.play(from_position)
	_current_bgm_path = stream_path
	_apply_pause_state()


func restart_bgm(stream_path: String, from_position: float = 0.0) -> void:
	var stream := _load_stream(stream_path)
	if not stream:
		return
	_transition_id += 1
	_cancel_fade()
	_free_player(_fade_player)
	_fade_player = null
	_free_player(_primary_player)
	_primary_player = _make_player(stream, _base_volume_db)
	_bind_primary_finished()
	_primary_player.play(from_position)
	_current_bgm_path = stream_path
	_apply_pause_state()


func play_bgm_from_stream(stream: Resource, from_position: float = 0.0) -> void:
	var audio_stream := stream as AudioStream
	if not audio_stream:
		return
	var key := audio_stream.resource_path
	if key != "" and _is_current_or_loaded(key):
		return
	_transition_id += 1
	_cancel_fade()
	_free_player(_fade_player)
	_fade_player = null
	_free_player(_primary_player)
	_primary_player = _make_player(audio_stream, _base_volume_db)
	_bind_primary_finished()
	_primary_player.play(from_position)
	_current_bgm_path = key
	_apply_pause_state()


func fade_to(stream_path: String, duration: float = 1.0, from_position: float = 0.0) -> void:
	var stream := _load_stream(stream_path)
	if not stream:
		stop_bgm(duration)
		return
	if _is_current(stream_path):
		return

	_transition_id += 1
	var id := _transition_id
	_cancel_fade()
	_free_player(_fade_player)

	_fade_player = _make_player(stream, -80.0)
	_fade_player.play(from_position)
	_current_bgm_path = stream_path
	_apply_pause_state()

	if duration <= 0.0 or not _primary_player or not is_instance_valid(_primary_player):
		_promote_fade_player(id)
		return

	_begin_fade(FadeMode.CROSSFADE, id, duration)


func stop_bgm(fade_duration: float = 0.5) -> void:
	_transition_id += 1
	var id := _transition_id
	_cancel_fade()
	_free_player(_fade_player)
	_fade_player = null

	if not _primary_player or not is_instance_valid(_primary_player):
		_current_bgm_path = ""
		return

	var player := _primary_player
	_current_bgm_path = ""
	if fade_duration <= 0.0:
		_primary_player = null
		_free_player(player)
		return

	_begin_fade(FadeMode.STOP, id, fade_duration)


func set_volume_db(db: float) -> void:
	_base_volume_db = clamp(db, -80.0, 0.0)
	if _primary_player and is_instance_valid(_primary_player):
		_primary_player.volume_db = _base_volume_db


func get_current_bgm() -> String:
	return _current_bgm_path


func is_playing() -> bool:
	return _primary_player != null and is_instance_valid(_primary_player) and _primary_player.playing


func is_paused_by_game() -> bool:
	return _paused_by_game


func clear_game_pause() -> void:
	_paused_by_game = false
	_apply_pause_state()


func _load_stream(stream_path: String) -> AudioStream:
	if stream_path == "" or not ResourceLoader.exists(stream_path):
		push_warning("[MusicManager] BGM 资源不存在: %s" % stream_path)
		return null
	var stream := load(stream_path) as AudioStream
	if not stream:
		push_error("[MusicManager] BGM 加载失败: %s" % stream_path)
	return stream


func _is_current(stream_path: String) -> bool:
	return stream_path != "" and stream_path == _current_bgm_path and is_playing()


func _is_current_or_loaded(stream_path: String) -> bool:
	return stream_path != "" \
		and stream_path == _current_bgm_path \
		and _primary_player != null \
		and is_instance_valid(_primary_player)


func _make_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = "BGMPlayer"
	player.stream = stream
	player.volume_db = volume_db
	player.bus = "Master"
	add_child(player)
	return player


func _bind_primary_finished() -> void:
	if is_instance_valid(_primary_player) and not _primary_player.finished.is_connected(_on_primary_player_finished):
		_primary_player.finished.connect(_on_primary_player_finished)


func _on_primary_player_finished() -> void:
	if is_instance_valid(_primary_player) and _current_bgm_path != "":
		_primary_player.play()


func _begin_fade(mode: int, id: int, duration: float) -> void:
	_fade_mode = mode
	_fade_transition_id = id
	_fade_duration = maxf(duration, 0.001)
	_fade_elapsed = 0.0
	_fade_primary_start_db = _primary_player.volume_db if is_instance_valid(_primary_player) else -80.0
	_fade_secondary_start_db = _fade_player.volume_db if is_instance_valid(_fade_player) else -80.0


func _update_fade(delta: float) -> void:
	if _fade_mode == FadeMode.NONE:
		return
	if _fade_transition_id != _transition_id:
		_cancel_fade()
		return
	_fade_elapsed = minf(_fade_elapsed + maxf(delta, 0.0), _fade_duration)
	var progress := _fade_elapsed / _fade_duration
	var eased := 0.5 - cos(progress * PI) * 0.5
	if is_instance_valid(_primary_player):
		_primary_player.volume_db = lerpf(_fade_primary_start_db, -80.0, eased)
	if _fade_mode == FadeMode.CROSSFADE and is_instance_valid(_fade_player):
		_fade_player.volume_db = lerpf(_fade_secondary_start_db, _base_volume_db, eased)
	if progress < 1.0:
		return
	var completed_mode := _fade_mode
	var completed_id := _fade_transition_id
	_cancel_fade()
	if completed_mode == FadeMode.CROSSFADE:
		_promote_fade_player(completed_id)
	elif completed_mode == FadeMode.STOP:
		var player := _primary_player
		_primary_player = null
		_free_player(player)


func _promote_fade_player(id: int) -> void:
	if id != _transition_id:
		return
	_free_player(_primary_player)
	_primary_player = _fade_player
	_fade_player = null
	if _primary_player and is_instance_valid(_primary_player):
		_primary_player.volume_db = _base_volume_db
		_bind_primary_finished()
	_apply_pause_state()


func _apply_pause_state() -> void:
	for player in [_primary_player, _fade_player]:
		if player and is_instance_valid(player):
			player.stream_paused = _paused_by_game


func _free_player(player: AudioStreamPlayer) -> void:
	if player and is_instance_valid(player):
		player.stop()
		player.stream = null
		player.free()


func _cancel_fade() -> void:
	_fade_mode = FadeMode.NONE
	_fade_transition_id = -1
	_fade_duration = 0.0
	_fade_elapsed = 0.0
	_fade_primary_start_db = 0.0
	_fade_secondary_start_db = -80.0


func _release_audio_resources_for_exit() -> void:
	_transition_id += 1
	_cancel_fade()
	for child: Node in get_children():
		if child is AudioStreamPlayer:
			var player := child as AudioStreamPlayer
			player.stop()
			player.stream = null
	_primary_player = null
	_fade_player = null
	_current_bgm_path = ""
	_paused_by_game = false
