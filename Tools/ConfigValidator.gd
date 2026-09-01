extends RefCounted
class_name ConfigValidator

## DataConfig 的集中结构校验器。它不修改资源，只验证类型、范围、数组长度和路径。
## 由 Tests/SelfTest/ContractTestRunner.gd 与 Scripts/preflight.ps1 调用。

const PLAYER_CONFIG_PATHS: Array[String] = [
	"res://DataConfig/Player/WarriorConfig.tres",
]
const CYBER_PLAYER_CONFIG_PATH := "res://DataConfig/Player/CyberPlayerConfig.tres"
const LINGNAN_PLAYER_CONFIG_PATH := "res://DataConfig/Player/LingnanPlayerConfig.tres"
const BOSS_BEHAVIOR_CONFIG_PATH := "res://DataConfig/Enemy/BossHuadanBehaviorConfig.tres"

const ENEMY_CONFIG_PATHS: Array[String] = [
	"res://DataConfig/Enemy/StreetSlimeConfig.tres",
	"res://DataConfig/Enemy/SlimeConfig.tres",
	"res://DataConfig/Enemy/ShadowConfig.tres",
	"res://DataConfig/Enemy/SecurityConfig.tres",
	"res://DataConfig/Enemy/PaperEffigyConfig.tres",
	"res://DataConfig/Enemy/LanternGhostConfig.tres",
	"res://DataConfig/Enemy/CyberWolfConfig.tres",
	"res://DataConfig/Enemy/CyberBullConfig.tres",
	"res://DataConfig/Enemy/CleanerConfig.tres",
	"res://DataConfig/Enemy/BossHuadanConfig.tres",
]

const LEVEL_CONFIG_PATHS: Array[String] = [
	"res://DataConfig/Level/Level01Config.tres",
	"res://DataConfig/Level/Level02Config.tres",
	"res://DataConfig/Level/Level03Config.tres",
	"res://DataConfig/Level/Level04Config.tres",
	"res://DataConfig/Level/Level05Config.tres",
]

const SKILL_CONFIG_PATHS: Array[String] = [
	"res://DataConfig/Skill/SlashConfig.tres",
]

const VALID_BOSS_ACTIONS: Array[String] = [
	"IDLE", "APPROACH", "RETREAT", "RANGED", "MELEE", "EVADE", "JUMP", "HOVER",
]


static func validate_all() -> PackedStringArray:
	var errors: Array[String] = []
	_validate_player_configs(errors)
	_validate_enemy_configs(errors)
	_validate_level_configs(errors)
	_validate_level_data(errors)
	_validate_skill_configs(errors)
	return PackedStringArray(errors)


static func _validate_player_configs(errors: Array[String]) -> void:
	for path: String in PLAYER_CONFIG_PATHS:
		var cfg := _load_typed(path, PlayerConfig, errors) as PlayerConfig
		if cfg == null:
			continue
		_require(cfg.max_health > 0, path, "max_health 必须大于 0", errors)
		_require(cfg.move_speed > 0.0, path, "move_speed 必须大于 0", errors)
		_require(cfg.ladder_climb_speed > 0.0, path, "ladder_climb_speed 必须大于 0", errors)
		_require(cfg.gravity > 0.0, path, "gravity 必须大于 0", errors)
		_require(cfg.jump_velocity < 0.0, path, "jump_velocity 必须为向上的负值", errors)
		_require(cfg.attack_damage >= 0, path, "attack_damage 不能为负", errors)
		_require(cfg.attack_cooldown >= 0.0 and cfg.attack_range > 0.0 and cfg.attack_center_distance >= 0.0, path, "攻击冷却、范围或判定中心距离非法", errors)
		_require(cfg.ground_attack_duration > 0.0 and cfg.air_attack_duration > 0.0, path, "攻击动作时长必须大于 0", errors)
		_require(cfg.dash_speed > 0.0 and cfg.dash_duration > 0.0, path, "冲刺速度和时长必须大于 0", errors)
		_require(cfg.input_dead_zone >= 0.0 and cfg.input_dead_zone < 1.0, path, "输入死区必须在 [0, 1)", errors)
		_require(cfg.camera_follow_lerp_speed > 0.0 and cfg.camera_deadzone_size.x >= 0.0 and cfg.camera_deadzone_size.y >= 0.0, path, "镜头跟随速度或死区非法", errors)
		_require(cfg.camera_lookahead_offset >= 0.0 and cfg.camera_lookahead_lerp > 0.0, path, "镜头预判参数非法", errors)
		_require(cfg.jump_hold_gravity_scale > 0.0 and cfg.jump_release_gravity_scale > 0.0, path, "跳跃重力倍率必须大于 0", errors)
		_require(cfg.hurt_invincible_time >= 0.0 and cfg.contact_invincible_time >= 0.0, path, "无敌时长不能为负", errors)
		_require(cfg.nearby_enemy_push_range >= 0.0 and cfg.nearby_enemy_stun_time >= 0.0, path, "近身推离参数不能为负", errors)
		_validate_ordered_pair(path, "walk_sfx_pitch", cfg.walk_sfx_pitch_min, cfg.walk_sfx_pitch_max, errors)
		_validate_ordered_pair(path, "attack_sfx_pitch", cfg.attack_sfx_pitch_min, cfg.attack_sfx_pitch_max, errors)
		_validate_ordered_pair(path, "hurt_sfx_pitch", cfg.hurt_sfx_pitch_min, cfg.hurt_sfx_pitch_max, errors)
		_validate_ordered_pair(path, "skill_sfx_pitch", cfg.skill_sfx_pitch_min, cfg.skill_sfx_pitch_max, errors)
		_validate_ordered_pair(path, "charge_sfx_pitch", cfg.charge_sfx_pitch_min, cfg.charge_sfx_pitch_max, errors)

	var cyber := _load_typed(CYBER_PLAYER_CONFIG_PATH, CyberPlayerConfig, errors) as CyberPlayerConfig
	if cyber:
		_require(cyber.skill_projectile_counts.size() == 3, CYBER_PLAYER_CONFIG_PATH, "蓄力剑气数量必须覆盖三个蓄力档位", errors)
		for count in cyber.skill_projectile_counts:
			_require(count > 0, CYBER_PLAYER_CONFIG_PATH, "剑气数量必须大于 0", errors)
		_require(cyber.skill_charge_tier_1 >= 0.0 and cyber.skill_charge_tier_1 < cyber.skill_charge_tier_2, CYBER_PLAYER_CONFIG_PATH, "蓄力档位阈值顺序错误", errors)
		_require(cyber.skill_projectile_damage >= 0 and cyber.skill_projectile_speed > 0.0 and cyber.skill_projectile_distance > 0.0, CYBER_PLAYER_CONFIG_PATH, "剑气伤害、速度或距离非法", errors)
		_require(cyber.counter_first_damage >= 0 and cyber.counter_second_damage >= 0, CYBER_PLAYER_CONFIG_PATH, "反击伤害不能为负", errors)
		_require(cyber.counter_open_delay + cyber.counter_first_hit_delay + cyber.counter_second_hit_delay <= cyber.counter_action_duration + 0.001, CYBER_PLAYER_CONFIG_PATH, "反击阶段延迟总和超过动作时长", errors)
		_require(cyber.counter_hitstop_time_scale > 0.0 and cyber.counter_hitstop_time_scale <= 1.0, CYBER_PLAYER_CONFIG_PATH, "反击停帧时间倍率必须在 (0, 1]", errors)

	var lingnan := _load_typed(LINGNAN_PLAYER_CONFIG_PATH, LingnanPlayerConfig, errors) as LingnanPlayerConfig
	if lingnan:
		_require(lingnan.charge_threshold_short >= 0.0 and lingnan.charge_threshold_short < lingnan.charge_threshold_big and lingnan.charge_threshold_big <= lingnan.charge_max_time, LINGNAN_PLAYER_CONFIG_PATH, "回旋斩蓄力阈值顺序错误", errors)
		_require(lingnan.small_spin_hits > 0 and lingnan.big_spin_hits >= lingnan.small_spin_hits, LINGNAN_PLAYER_CONFIG_PATH, "回旋斩段数非法", errors)
		_require(lingnan.small_spin_range > 0.0 and lingnan.big_spin_range >= lingnan.small_spin_range, LINGNAN_PLAYER_CONFIG_PATH, "回旋斩范围非法", errors)
		_require(lingnan.bagua_min_range > 0.0 and lingnan.bagua_min_range <= lingnan.bagua_max_range, LINGNAN_PLAYER_CONFIG_PATH, "八卦冲击范围顺序错误", errors)
		_require(lingnan.bagua_min_push_force >= 0.0 and lingnan.bagua_min_push_force <= lingnan.bagua_max_push_force, LINGNAN_PLAYER_CONFIG_PATH, "八卦推力顺序错误", errors)
		_require(lingnan.bagua_shield_max_hp > 0 and lingnan.bagua_enemy_stun_time >= 0.0, LINGNAN_PLAYER_CONFIG_PATH, "八卦护盾或眩晕参数非法", errors)


static func _validate_enemy_configs(errors: Array[String]) -> void:
	for path: String in ENEMY_CONFIG_PATHS:
		var cfg := _load_typed(path, EnemyConfig, errors) as EnemyConfig
		if cfg == null:
			continue
		_require(cfg.max_health > 0, path, "max_health 必须大于 0", errors)
		_require(cfg.move_speed >= 0.0 and cfg.gravity >= 0.0, path, "移动速度和重力不能为负", errors)
		_require(cfg.attack_damage >= 0 and cfg.attack_cooldown >= 0.0, path, "攻击数值不能为负", errors)
		_require(cfg.attack_damage_type >= GlobalDefine.DamageType.PHYSICAL and cfg.attack_damage_type <= GlobalDefine.DamageType.TRUE_DAMAGE, path, "attack_damage_type 越界", errors)
		_require(cfg.idle_sfx_interval_min <= cfg.idle_sfx_interval_max, path, "待机音效间隔顺序错误", errors)
		_require(cfg.idle_sfx_chance >= 0.0 and cfg.idle_sfx_chance <= 1.0, path, "待机音效概率必须在 0..1", errors)
		_require(cfg.jump_interval_min <= cfg.jump_interval_max, path, "跳跃间隔顺序错误", errors)
		_require(cfg.hover_min_distance <= cfg.hover_max_distance, path, "悬停距离顺序错误", errors)
		_require(cfg.knockback_resistance >= 0.0 and cfg.knockback_resistance <= 1.0, path, "击退抗性必须在 0..1", errors)
		_validate_ordered_pair(path, "idle_sfx_pitch", cfg.idle_sfx_pitch_min, cfg.idle_sfx_pitch_max, errors)
		_validate_ordered_pair(path, "hurt_sfx_pitch", cfg.hurt_sfx_pitch_min, cfg.hurt_sfx_pitch_max, errors)
		if path.ends_with("BossHuadanConfig.tres"):
			_validate_boss_config(path, cfg, errors)


static func _validate_boss_config(path: String, cfg: EnemyConfig, errors: Array[String]) -> void:
	var phase_array_sizes: Array[int] = [
		cfg.boss_phase_health.size(),
		cfg.boss_phase_speed.size(),
		cfg.boss_phase_jump.size(),
		cfg.boss_phase_ranged_damage.size(),
		cfg.boss_phase_melee_damage.size(),
		cfg.boss_phase_cooldown_multiplier.size(),
		cfg.boss_phase_best_distance.size(),
		cfg.boss_phase_evade_chance.size(),
	]
	var phase_arrays_valid := true
	for size: int in phase_array_sizes:
		if size < 5:
			phase_arrays_valid = false
		_require(size >= 5, path, "Boss 阶段数组必须覆盖索引 0..4", errors)
	if phase_arrays_valid:
		_require(cfg.boss_phase_health[1] == cfg.max_health, path, "Boss 第一阶段血量必须等于 max_health", errors)
		_require(cfg.boss_phase_health[1] > cfg.boss_phase_health[2] and cfg.boss_phase_health[2] > cfg.boss_phase_health[3] and cfg.boss_phase_health[3] > cfg.boss_phase_health[4], path, "Boss 阶段血量阈值必须严格递减", errors)
		for phase in range(1, 5):
			_require(cfg.boss_phase_speed[phase] > 0.0 and cfg.boss_phase_jump[phase] < 0.0, path, "Boss 第 %d 阶段速度或跳跃值非法" % phase, errors)
			_require(cfg.boss_phase_cooldown_multiplier[phase] > 0.0, path, "Boss 第 %d 阶段冷却倍率必须大于 0" % phase, errors)
			_require(cfg.boss_phase_evade_chance[phase] >= 0.0 and cfg.boss_phase_evade_chance[phase] <= 1.0, path, "Boss 第 %d 阶段闪避概率越界" % phase, errors)
	_require(cfg.boss_minion_count_min <= cfg.boss_minion_count_max, path, "Boss 召唤数量范围顺序错误", errors)
	_require(cfg.boss_minion_spawn_offset_min <= cfg.boss_minion_spawn_offset_max, path, "Boss 召唤偏移范围顺序错误", errors)
	_require(cfg.boss_projectile_speed > 0.0 and cfg.boss_projectile_max_lifetime > 0.0, path, "Boss 剑气速度和寿命必须大于 0", errors)
	_require(cfg.boss_max_toughness > 0.0 and cfg.boss_poise_break_stun_time > 0.0, path, "Boss 韧性或破韧时长非法", errors)
	_require(cfg.boss_behavior != null, path, "boss_behavior 不能为空", errors)
	if cfg.boss_behavior:
		_validate_boss_behavior(BOSS_BEHAVIOR_CONFIG_PATH, cfg.boss_behavior, errors)


static func _validate_boss_behavior(path: String, behavior: BossHuadanBehaviorConfig, errors: Array[String]) -> void:
	_require(behavior.phase_profiles.size() >= 5, path, "phase_profiles 必须覆盖索引 0..4", errors)
	for chance in [behavior.ambient_jump_chance, behavior.kite_exit_chance, behavior.minion_positive_side_chance]:
		_require(chance >= 0.0 and chance <= 1.0, path, "Boss 行为概率必须在 0..1", errors)
	_require(behavior.ground_projectile_count > 0 and behavior.empowered_projectile_count >= behavior.ground_projectile_count, path, "Boss 剑气数量非法", errors)
	_require(behavior.projectile_spread_angles.size() >= behavior.empowered_projectile_count, path, "剑气散布角数量不足", errors)
	if behavior.phase_profiles.size() < 5:
		return
	for phase in range(1, 5):
		var profile := behavior.phase_profiles[phase]
		_require(profile != null, path, "Boss 第 %d 阶段决策配置不能为空" % phase, errors)
		if profile:
			_validate_boss_profile("%s#phase_%d" % [path, phase], profile, errors)


static func _validate_boss_profile(scope: String, profile: BossDecisionProfile, errors: Array[String]) -> void:
	_require(profile.far_distance > profile.mid_distance, scope, "far_distance 必须大于 mid_distance", errors)
	_require(profile.near_distance == 0.0 or (profile.mid_distance > profile.near_distance and profile.near_distance > 0.0), scope, "near_distance 必须为 0 或位于 (0, mid_distance)", errors)
	_require(profile.hover_chance >= 0.0 and profile.hover_chance <= 1.0, scope, "hover_chance 必须在 0..1", errors)
	_validate_weighted_actions(scope + ".far", profile.far_actions, profile.far_weights, errors)
	_validate_weighted_actions(scope + ".mid", profile.mid_actions, profile.mid_weights, errors)
	if profile.near_distance > 0.0:
		_validate_weighted_actions(scope + ".near", profile.near_actions, profile.near_weights, errors)
	_validate_weighted_actions(scope + ".close", profile.close_actions, profile.close_weights, errors)


static func _validate_weighted_actions(scope: String, actions: PackedStringArray, weights: PackedFloat32Array, errors: Array[String]) -> void:
	_require(not actions.is_empty(), scope, "动作数组不能为空", errors)
	_require(actions.size() == weights.size(), scope, "动作与权重数量不一致", errors)
	if actions.size() != weights.size() or actions.is_empty():
		return
	var total := 0.0
	for i in range(actions.size()):
		_require(VALID_BOSS_ACTIONS.has(actions[i]), scope, "未知动作名: %s" % actions[i], errors)
		_require(weights[i] >= 0.0, scope, "动作权重不能为负", errors)
		total += weights[i]
	_require(absf(total - 1.0) <= 0.001, scope, "动作权重总和必须为 1，当前为 %.4f" % total, errors)


static func _validate_level_configs(errors: Array[String]) -> void:
	for path: String in LEVEL_CONFIG_PATHS:
		var cfg := _load_typed(path, LevelConfig, errors) as LevelConfig
		if cfg == null:
			continue
		_require(cfg.level_id != "", path, "level_id 不能为空", errors)
		_require(cfg.camera_limit_left < cfg.camera_limit_right, path, "摄像机左右边界顺序错误", errors)
		_require(cfg.camera_limit_top < cfg.camera_limit_bottom, path, "摄像机上下边界顺序错误", errors)
		_require(ResourceLoader.exists(cfg.player_scene_path), path, "player_scene_path 不存在: %s" % cfg.player_scene_path, errors)


static func _validate_level_data(errors: Array[String]) -> void:
	var level_01 := _load_typed("res://DataConfig/Level/Level01Data.tres", Level01Data, errors) as Level01Data
	if level_01:
		const SCOPE := "Level01Data"
		_validate_parallel_arrays(SCOPE, "IDE 对话", level_01.ide_speakers.size(), level_01.ide_texts.size(), errors)
		_require(level_01.computer_unlock_sleep_count > 0, SCOPE, "解锁睡眠次数必须大于 0", errors)
		_require(level_01.sleep_texts.size() >= level_01.computer_unlock_sleep_count, SCOPE, "睡眠文本数量不足以覆盖解锁次数", errors)
		_require(level_01.code_scroll_speed > 0.0 and level_01.narrative_input_timeout > 0.0, SCOPE, "文本滚动速度和叙事超时必须大于 0", errors)
		_require(level_01.idle_bed_prompt_delay >= 0.0 and level_01.ide_preview_timeout > 0.0, SCOPE, "床提示延迟或 IDE 预览时长非法", errors)
		_require(level_01.move_speed_multiplier > 0.0 and level_01.normal_move_speed_multiplier > 0.0, SCOPE, "移动速度倍率必须大于 0", errors)
		_require(level_01.interaction_cooldown >= 0.0 and level_01.interaction_recovery_threshold >= 0.0, SCOPE, "交互冷却或恢复阈值不能为负", errors)
		_require(level_01.narrative_input_arm_delay >= 0.0 and level_01.narrative_poll_interval > 0.0, SCOPE, "叙事输入轮询参数非法", errors)
		_require(level_01.sleep_blink_count > 0 and level_01.sleep_blink_interval > 0.0, SCOPE, "睡眠闪烁次数和间隔必须大于 0", errors)
		_require(level_01.sleep_blink_alpha_start >= 0.0 and level_01.sleep_blink_alpha_start <= 1.0, SCOPE, "睡眠闪烁起始透明度必须在 0..1", errors)
		_require(level_01.sleep_blink_alpha_step >= 0.0 and level_01.sleep_blink_alpha_start + level_01.sleep_blink_alpha_step * float(level_01.sleep_blink_count - 1) <= 1.0, SCOPE, "睡眠闪烁透明度序列越界", errors)
		_require(level_01.sleep_final_alpha >= 0.0 and level_01.sleep_final_alpha <= 1.0, SCOPE, "最终睡眠透明度必须在 0..1", errors)
		_require(level_01.sleep_blink_dim_duration > 0.0 and level_01.sleep_blink_hold_duration >= 0.0 and level_01.sleep_blink_recover_duration > 0.0, SCOPE, "睡眠闪烁阶段时长非法", errors)
		_require(level_01.sleep_final_interval > 0.0 and level_01.sleep_final_dim_duration > 0.0 and level_01.sleep_final_hold_duration >= 0.0 and level_01.sleep_final_recover_duration > 0.0, SCOPE, "最终睡眠阶段时长非法", errors)
		_require(level_01.final_blackout_duration > 0.0 and level_01.final_blackout_fade_duration > 0.0 and level_01.final_glitch_duration > 0.0, SCOPE, "关卡收尾时长必须大于 0", errors)
		_require(level_01.camera_zoom.x > 0.0 and level_01.camera_zoom.y > 0.0 and level_01.camera_lerp_speed > 0.0, SCOPE, "摄像机缩放和跟随速度必须大于 0", errors)
		_require_resource_path(level_01.next_level_path, SCOPE, "next_level_path", errors)

	var level_02 := _load_typed("res://DataConfig/Level/Level02Data.tres", Level02Data, errors) as Level02Data
	if level_02:
		const SCOPE := "Level02Data"
		_validate_parallel_arrays(SCOPE, "IDE 对话", level_02.ide_speakers.size(), level_02.ide_texts.size(), errors)
		var puzzle_count := level_02.config_item_ids.size()
		_require(puzzle_count > 0, SCOPE, "配置谜题不能为空", errors)
		_require(level_02.config_item_labels.size() == puzzle_count and level_02.config_initial_values.size() == puzzle_count and level_02.config_target_values.size() == puzzle_count and level_02.config_success_feedbacks.size() == puzzle_count, SCOPE, "配置谜题数组长度不一致", errors)
		_require(level_02.config_initial_display.is_empty() or level_02.config_initial_display.size() == puzzle_count, SCOPE, "配置谜题初始显示文本数量不一致", errors)
		_require(level_02.config_target_display.is_empty() or level_02.config_target_display.size() == puzzle_count, SCOPE, "配置谜题目标显示文本数量不一致", errors)
		var seen_ids: Dictionary = {}
		for item_id: String in level_02.config_item_ids:
			_require(not item_id.strip_edges().is_empty(), SCOPE, "配置谜题键不能为空", errors)
			_require(not seen_ids.has(item_id), SCOPE, "配置谜题键重复: %s" % item_id, errors)
			seen_ids[item_id] = true
		_require(not level_02.recompilation_lines.is_empty(), SCOPE, "重编译输出行不能为空", errors)
		_require(level_02.recompile_line_interval > 0.0 and level_02.recompile_finish_delay >= 0.0 and level_02.rebuilt_dream_hold_duration >= 0.0, SCOPE, "重编译阶段时长非法", errors)
		_require(level_02.dream_move_speed_multiplier > 0.0 and level_02.reality_move_multiplier > 0.0, SCOPE, "梦境/现实移动倍率必须大于 0", errors)
		_require(level_02.narrative_input_timeout > 0.0 and level_02.narrative_poll_interval > 0.0, SCOPE, "叙事超时和轮询间隔必须大于 0", errors)
		_require(level_02.interaction_cooldown >= 0.0 and level_02.interaction_fallback_radius > 0.0, SCOPE, "交互冷却或回退半径非法", errors)
		_require(level_02.attic_camera_left < level_02.segment_01_map_right and level_02.attic_camera_bottom > 0, SCOPE, "阁楼摄像机边界非法", errors)
		_require(level_02.attic_transition_fade_duration > 0.0, SCOPE, "阁楼转场时长必须大于 0", errors)
		_require(level_02.street_enemy_max_count > 0 and level_02.street_enemy_max_count <= level_02.street_enemy_spawn_points.size(), SCOPE, "街道敌人数量超过配置点数量", errors)
		_require_resource_path(level_02.next_street_segment_path, SCOPE, "next_street_segment_path", errors)
		_validate_ordered_pair(SCOPE, "segment_01_map", float(level_02.segment_01_map_left), float(level_02.segment_01_map_right), errors)
		_require(level_02.segment_01_map_left < level_02.segment_01_map_right and level_02.segment_01_camera_top < level_02.segment_01_camera_bottom, SCOPE, "街道 01 地图或摄像机边界顺序错误", errors)
		_require(level_02.segment_01_exit_trigger_size.x > 0.0 and level_02.segment_01_exit_trigger_size.y > 0.0, SCOPE, "街道 01 出口触发尺寸必须大于 0", errors)
		_require(level_02.segment_01_camera_zoom.x > 0.0 and level_02.segment_01_camera_zoom.y > 0.0 and level_02.segment_01_camera_lerp_speed > 0.0, SCOPE, "街道 01 摄像机参数非法", errors)
		_require(level_02.segment_01_paper_spawn_interval > 0 and level_02.segment_01_lantern_spawn_interval > 0, SCOPE, "街道 01 敌人生成间隔必须大于 0", errors)
		_require(not level_02.segment_01_paper_upper_spawn_x.is_empty() and not level_02.segment_01_lantern_upper_spawn_x.is_empty(), SCOPE, "街道 01 上层生成点不能为空", errors)
		_require(level_02.segment_01_whiteout_duration > 0.0 and level_02.segment_01_whiteout_fade_duration > 0.0, SCOPE, "街道 01 白屏时长必须大于 0", errors)
		_require_resource_path(level_02.segment_01_next_level_path, SCOPE, "segment_01_next_level_path", errors)
		_require(level_02.segment_02_map_left < level_02.segment_02_map_right and level_02.segment_02_camera_top < level_02.segment_02_camera_bottom, SCOPE, "街道 02 地图或摄像机边界顺序错误", errors)
		_require(level_02.segment_02_exit_trigger_size.x > 0.0 and level_02.segment_02_exit_trigger_size.y > 0.0, SCOPE, "街道 02 出口触发尺寸必须大于 0", errors)
		_require(level_02.segment_02_camera_zoom.x > 0.0 and level_02.segment_02_camera_zoom.y > 0.0 and level_02.segment_02_camera_lerp_speed > 0.0, SCOPE, "街道 02 摄像机参数非法", errors)
		_require(level_02.segment_02_enemy_detect_range_cap > 0.0, SCOPE, "街道 02 敌人侦测范围上限必须大于 0", errors)
		_require(not level_02.segment_02_paper_spawn_positions.is_empty() and not level_02.segment_02_lantern_spawn_positions.is_empty(), SCOPE, "街道 02 敌人生成点不能为空", errors)
		_require_resource_path(level_02.segment_02_next_level_path, SCOPE, "segment_02_next_level_path", errors)
		_require(level_02.segment_03_camera_left < level_02.segment_03_camera_right and level_02.segment_03_camera_top < level_02.segment_03_camera_bottom, SCOPE, "街道 03 摄像机边界顺序错误", errors)
		_require(level_02.segment_03_camera_zoom.x > 0.0 and level_02.segment_03_camera_zoom.y > 0.0 and level_02.segment_03_camera_lerp_speed > 0.0, SCOPE, "街道 03 摄像机参数非法", errors)
		_require(level_02.shadow_max_alive > 0 and level_02.shadow_max_onscreen > 0 and level_02.shadow_max_onscreen <= level_02.shadow_max_alive, SCOPE, "黑影存活/同屏上限非法", errors)
		_require(level_02.shadow_spawn_interval > 0.0 and level_02.shadow_onscreen_distance > 0.0, SCOPE, "黑影生成间隔和同屏距离必须大于 0", errors)
		_require(level_02.shadow_positive_side_chance >= 0.0 and level_02.shadow_positive_side_chance <= 1.0, SCOPE, "黑影正向生成概率必须在 0..1", errors)
		_validate_ordered_pair(SCOPE, "shadow_spawn_distance", level_02.shadow_spawn_distance_min, level_02.shadow_spawn_distance_max, errors)
		_validate_ordered_pair(SCOPE, "shadow_spawn_x", level_02.shadow_spawn_min_x, level_02.shadow_spawn_max_x, errors)
		_require(level_02.wake_hold_required > 0.0 and level_02.wake_hold_decay_multiplier > 0.0, SCOPE, "苏醒按住时长或衰减倍率非法", errors)
		_require(level_02.death_guard_health > 0 and level_02.interference_fall_threshold > 0, SCOPE, "悬崖保底生命或坠落阈值非法", errors)
		_require(level_02.reality_camera_zoom.x > 0.0 and level_02.reality_camera_zoom.y > 0.0 and level_02.reality_camera_lerp_speed > 0.0, SCOPE, "现实房间摄像机参数非法", errors)
		_require(level_02.memory_area_01 != null and level_02.memory_area_02 != null, SCOPE, "两个记忆回收区域配置均不能为空", errors)
		if level_02.memory_area_01:
			_validate_memory_area("MemoryRecoveryArea01", level_02.memory_area_01, level_02.memory_drop_spawn_edge_margin, errors)
		if level_02.memory_area_02:
			_validate_memory_area("MemoryRecoveryArea02", level_02.memory_area_02, level_02.memory_drop_spawn_edge_margin, errors)
		if level_02.memory_area_01 and level_02.memory_area_02:
			_require(level_02.memory_area_01.area_index != level_02.memory_area_02.area_index, SCOPE, "两个记忆区域的 area_index 不能重复", errors)
			_require(level_02.memory_area_01.scene_path != level_02.memory_area_02.scene_path, SCOPE, "两个记忆区域不能指向同一场景", errors)
		_require_resource_path(level_02.memory_return_scene_path, SCOPE, "memory_return_scene_path", errors)
		_require(level_02.memory_fragments_per_area > 0 and level_02.memory_total_fragments == level_02.memory_fragments_per_area * 2, SCOPE, "记忆碎片总数必须等于两个区域目标之和", errors)
		_require(level_02.memory_kills_per_drop > 0, SCOPE, "记忆掉落击杀阈值必须大于 0", errors)
		_require(level_02.memory_drop_types.size() >= level_02.memory_total_fragments, SCOPE, "记忆掉落类型数量不足", errors)
		_require(level_02.memory_lantern_spawn_weight > 0 and level_02.memory_paper_spawn_weight > 0, SCOPE, "记忆敌人权重必须大于 0", errors)
		_validate_ordered_pair(SCOPE, "memory_enemy_spawn_distance", level_02.memory_enemy_spawn_distance_min, level_02.memory_enemy_spawn_distance_max, errors)
		_require(level_02.memory_positive_spawn_side_chance >= 0.0 and level_02.memory_positive_spawn_side_chance <= 1.0, SCOPE, "记忆敌人正向生成概率必须在 0..1", errors)
		_require(level_02.memory_upper_enemy_chance >= 0.0 and level_02.memory_upper_enemy_chance <= 1.0, SCOPE, "上层敌人概率必须在 0..1", errors)
		_require(level_02.memory_drop_spawn_edge_margin >= 0.0 and level_02.memory_narrative_timeout > 0.0, SCOPE, "记忆掉落边距或叙事超时非法", errors)

	var level_03 := _load_typed("res://DataConfig/Level/Level03Data.tres", Level03Data, errors) as Level03Data
	if level_03:
		const SCOPE := "Level03Data"
		_require(level_03.intro_narrative_delay >= 0.0 and level_03.intro_fade_duration > 0.0, SCOPE, "开场延迟或淡入时长非法", errors)
		_require(level_03.narrative_input_timeout > 0.0 and level_03.narrative_poll_interval > 0.0, SCOPE, "叙事超时和轮询间隔必须大于 0", errors)
		_require(level_03.interaction_cooldown >= 0.0 and level_03.interaction_fallback_radius > 0.0, SCOPE, "交互冷却或回退半径非法", errors)
		_require(level_03.camera_zoom.x > 0.0 and level_03.camera_zoom.y > 0.0, SCOPE, "摄像机缩放必须大于 0", errors)
		_require(level_03.initial_camera_left < level_03.initial_camera_right and level_03.initial_camera_top < level_03.initial_camera_bottom, SCOPE, "初始摄像机边界顺序错误", errors)
		_require(level_03.cyber_camera_left < level_03.cyber_camera_right and level_03.cyber_camera_top < level_03.cyber_camera_bottom, SCOPE, "赛博摄像机边界顺序错误", errors)
		_require_resource_path(level_03.cyber_player_scene_path, SCOPE, "cyber_player_scene_path", errors)
		_require_resource_path(level_03.next_level_path, SCOPE, "next_level_path", errors)
		_require(not level_03.grandpa_dialogues.is_empty(), SCOPE, "爷爷对话不能为空", errors)
		_require(level_03.grandpa_glitch_dialogue_index >= 0 and level_03.grandpa_glitch_dialogue_index < level_03.grandpa_dialogues.size(), SCOPE, "爷爷故障对话索引越界", errors)
		_require(level_03.grandpa_indicator_dialogue_index >= 0 and level_03.grandpa_indicator_dialogue_index < level_03.grandpa_dialogues.size(), SCOPE, "爷爷指示器对话索引越界", errors)
		_require(level_03.grandpa_indicator_fade_alpha >= 0.0 and level_03.grandpa_indicator_fade_alpha <= 1.0 and level_03.grandpa_indicator_tween_duration > 0.0, SCOPE, "爷爷故障指示参数非法", errors)
		_require(level_03.lingnan_enemy_count > 0 and level_03.lingnan_enemy_count <= level_03.lingnan_enemy_spawn_points.size(), SCOPE, "岭南敌人数量超过配置点数量", errors)
		_require(level_03.rush_enemy_detect_range > 0.0, SCOPE, "突袭敌人侦测范围必须大于 0", errors)
		_require(not level_03.codebuddy_broadcast_lines.is_empty(), SCOPE, "世界异化广播不能为空", errors)
		_require(level_03.world_shift_shake_duration > 0.0 and level_03.world_shift_reveal_delay >= 0.0, SCOPE, "世界异化震动或揭示延迟非法", errors)
		_require(level_03.world_shift_glitch_rise_duration > 0.0 and level_03.world_shift_background_dim_duration > 0.0, SCOPE, "世界异化渐变时长必须大于 0", errors)
		_require(level_03.shake_strength >= 0.0 and level_03.shake_samples_per_second > 0.0 and level_03.shake_sample_duration > 0.0 and level_03.shake_recovery_duration > 0.0, SCOPE, "世界异化震动采样参数非法", errors)
		_require(level_03.enemy_max_alive > 0 and level_03.enemy_max_onscreen > 0 and level_03.enemy_max_onscreen <= level_03.enemy_max_alive, SCOPE, "赛博敌人存活/同屏上限非法", errors)
		_require(level_03.enemy_spawn_interval > 0.0 and not level_03.corridor_enemy_spawn_points.is_empty(), SCOPE, "赛博敌人生成间隔或走廊点非法", errors)
		_require(level_03.dynamic_onscreen_distance > 0.0, SCOPE, "动态敌人同屏距离必须大于 0", errors)
		_require(level_03.dynamic_spawn_positive_side_chance >= 0.0 and level_03.dynamic_spawn_positive_side_chance <= 1.0, SCOPE, "动态敌人正向生成概率必须在 0..1", errors)
		_validate_ordered_pair(SCOPE, "dynamic_spawn_distance", level_03.dynamic_spawn_distance_min, level_03.dynamic_spawn_distance_max, errors)
		_validate_ordered_pair(SCOPE, "dynamic_spawn_x", level_03.dynamic_spawn_min_x, level_03.dynamic_spawn_max_x, errors)
		_require(
			level_03.knockback_reverse_force >= 0.0
			and level_03.player_damage_multiplier >= 0.0
			and level_03.player_damage_multiplier <= 1.0,
			SCOPE,
			"伤害反向推力或玩家承伤倍率非法",
			errors
		)
		_require(level_03.required_memory_echoes > 0 and level_03.required_memory_echoes <= 2, SCOPE, "记忆光团目标只能在 1..2", errors)
		_require(level_03.glitch_ambient_intensity >= 0.0 and level_03.glitch_spike_intensity >= level_03.glitch_ambient_intensity and level_03.glitch_decay_duration > 0.0, SCOPE, "故障强度或衰减时长非法", errors)
		_require(not level_03.cleaner_spawn_points.is_empty() and not level_03.security_spawn_points.is_empty(), SCOPE, "赛博城正式敌人生成点不能为空", errors)
		_require(level_03.awakening_cyber_fade_duration > 0.0, SCOPE, "觉醒淡出时长必须大于 0", errors)

	var level_04 := _load_typed("res://DataConfig/Level/Level04Data.tres", Level04Data, errors) as Level04Data
	if level_04:
		const SCOPE := "Level04Data"
		_require_resource_path(level_04.cyber_player_scene_path, SCOPE, "cyber_player_scene_path", errors)
		_require_resource_path(level_04.lingnan_player_scene_path, SCOPE, "lingnan_player_scene_path", errors)
		_require_resource_path(level_04.next_level_path, SCOPE, "next_level_path", errors)
		_require(level_04.intro_fade_duration > 0.0 and level_04.floating_text_duration > 0.0, SCOPE, "开场或浮动文字时长必须大于 0", errors)
		_require(level_04.interaction_fallback_radius > 0.0 and level_04.narrative_poll_interval > 0.0, SCOPE, "交互半径或叙事轮询间隔非法", errors)
		_require(level_04.surface_enemy_count > 0 and level_04.surface_enemy_count <= level_04.surface_enemy_spawn_points.size(), SCOPE, "表层敌人数量超过配置点数量", errors)
		_require(level_04.world_swap_cooldown > 0.0 and level_04.hurt_swap_delay >= 0.0, SCOPE, "世界切换冷却或受伤切换延迟非法", errors)
		_require(not level_04.lingnan_enemy_spawn_points.is_empty(), SCOPE, "岭南敌人生成点不能为空", errors)
		_require(level_04.lingnan_swap_positions.size() >= 3, SCOPE, "岭南切换点至少需要 3 个", errors)
		_require(level_04.lingnan_swap_dialogues.size() >= level_04.lingnan_swap_positions.size(), SCOPE, "岭南切换对话数量不足", errors)
		_require(level_04.stage_1_enemy_swap_progress > 0 and level_04.stage_1_enemy_swap_progress <= level_04.surface_enemy_count, SCOPE, "第一阶段敌人切换进度阈值非法", errors)
		_require(level_04.swap_glitch_base_strength >= 0.0 and level_04.swap_glitch_base_strength <= level_04.swap_glitch_max_strength, SCOPE, "切换故障基础强度超过上限", errors)
		_require(level_04.swap_glitch_strength_per_swap >= 0.0 and level_04.swap_glitch_base_duration > 0.0 and level_04.swap_glitch_duration_per_swap >= 0.0 and level_04.swap_flash_duration > 0.0, SCOPE, "切换故障增长或时长非法", errors)
		_require(level_04.stage_2_lingnan_camera_left < level_04.stage_2_lingnan_camera_right and level_04.stage_2_lingnan_camera_top < level_04.stage_2_lingnan_camera_bottom, SCOPE, "第二阶段岭南摄像机边界顺序错误", errors)
		_require(level_04.stage_2_cyber_camera_top < level_04.stage_2_cyber_camera_bottom, SCOPE, "第二阶段赛博摄像机上下边界顺序错误", errors)
		_require(not level_04.stage_2_lantern_spawn_points.is_empty() and not level_04.stage_2_paper_spawn_points.is_empty(), SCOPE, "第二阶段岭南敌人生成点不能为空", errors)
		_require(not level_04.stage_2_wolf_spawn_points.is_empty() and not level_04.stage_2_bull_spawn_points.is_empty(), SCOPE, "第二阶段赛博敌人生成点不能为空", errors)
		_require(level_04.fall_death_delay >= 0.0 and level_04.fall_detection_map_min_y < level_04.fall_death_y, SCOPE, "坠落死亡阈值或延迟非法", errors)
		_require(level_04.enemy_vertical_reachability > 0.0 and level_04.stage_2_map_offset > 0.0, SCOPE, "敌人垂直可达距离或地图偏移必须大于 0", errors)
		_require(level_04.stage_2_transition_fade_duration > 0.0 and level_04.stage_3_transition_fade_duration > 0.0, SCOPE, "阶段转场时长必须大于 0", errors)
		_require(level_04.camera_pan_travel_duration > 0.0 and level_04.camera_pan_hold_duration >= 0.0, SCOPE, "摄像机平移时长非法", errors)
		_require(level_04.stage_2_swap_interval_min > 0.0 and level_04.stage_2_swap_interval_min <= level_04.stage_2_swap_interval_max, SCOPE, "世界切换间隔顺序错误", errors)
		_require(level_04.stage_2_warning_time >= 0.0 and level_04.stage_2_warning_time <= level_04.stage_2_swap_interval_min, SCOPE, "世界切换预警时长超过最短间隔", errors)
		_require(level_04.erosion_max > 0.0 and level_04.erosion_rate >= 0.0 and level_04.erosion_kill_reduction >= 0.0, SCOPE, "侵蚀参数非法", errors)
		_require(level_04.narrative_input_timeout > 0.0, SCOPE, "叙事超时必须大于 0", errors)

	var level_05 := _load_typed("res://DataConfig/Level/Level05Data.tres", Level05Data, errors) as Level05Data
	if level_05:
		const SCOPE := "Level05Data"
		_require_resource_path(level_05.cyber_player_scene_path, SCOPE, "cyber_player_scene_path", errors)
		_require_resource_path(level_05.lingnan_player_scene_path, SCOPE, "lingnan_player_scene_path", errors)
		_require_resource_path(level_05.boss_scene_path, SCOPE, "boss_scene_path", errors)
		_require_resource_path(level_05.ending_level_path, SCOPE, "ending_level_path", errors)
		_require(level_05.initial_corruption >= 0.0 and level_05.initial_corruption <= 1.0, SCOPE, "初始腐化值必须在 0..1", errors)
		_require(level_05.intro_fade_duration > 0.0 and level_05.dialog_close_cooldown >= 0.0, SCOPE, "开场淡入或对话关闭冷却非法", errors)
		_require(level_05.manual_corruption_step > 0.0, SCOPE, "手动腐化步长必须大于 0", errors)
		_require(level_05.bg3_camera_top < level_05.bg3_camera_bottom and level_05.bg3_camera_zoom > 0.0, SCOPE, "双世界摄像机参数非法", errors)
		_require(level_05.world_swap_shake_strength >= 0.0 and level_05.world_swap_shake_duration > 0.0, SCOPE, "双世界切换震动参数非法", errors)
		_require(not level_05.dual_world_ground_spawn_points.is_empty() and not level_05.dual_world_special_spawn_points.is_empty(), SCOPE, "双世界敌人生成点不能为空", errors)
		_require(level_05.dual_character_max_health > 0, SCOPE, "双角色最大生命必须大于 0", errors)
		_require(level_05.low_health_hint_threshold > 0 and level_05.low_health_hint_threshold <= level_05.dual_character_max_health, SCOPE, "低生命提示阈值必须位于 1..最大生命", errors)
		_require(level_05.layer_swap_cooldown > 0.0 and level_05.skin_hint_hold_duration >= 0.0 and level_05.skin_hint_fade_duration > 0.0, SCOPE, "角色切换或提示时长非法", errors)
		_require(level_05.boss_camera_left < level_05.boss_camera_right and level_05.boss_checkpoint_camera_top < level_05.boss_camera_bottom, SCOPE, "Boss 区域摄像机边界顺序错误", errors)
		_require(level_05.boss_camera_zoom > 0.0 and level_05.boss_checkpoint_camera_zoom > 0.0, SCOPE, "Boss 区域摄像机缩放必须大于 0", errors)
		_require(not level_05.boss_intro_dialogues.is_empty() and not level_05.boss_death_dialogues.is_empty(), SCOPE, "Boss 开场/死亡对话不能为空", errors)
		_validate_ordered_pair(SCOPE, "boss_death_lantern_y", level_05.boss_death_lantern_y_min, level_05.boss_death_lantern_y_max, errors)
		_require(level_05.boss_death_music_fade_duration > 0.0 and level_05.boss_death_shake_strength >= 0.0 and level_05.boss_death_shake_duration > 0.0, SCOPE, "Boss 死亡音频或震动参数非法", errors)
		_require(level_05.boss_death_time_scale > 0.0 and level_05.boss_death_time_scale <= 1.0 and level_05.boss_death_recovery_delay >= 0.0, SCOPE, "Boss 死亡慢动作参数非法", errors)
		_require(level_05.huadan_video_fade_duration > 0.0 and level_05.grandpa_video_fade_duration > 0.0 and level_05.ending_black_hold_duration >= 0.0, SCOPE, "视频演出时长非法", errors)
		_require(level_05.bg5_camera_left < level_05.bg5_camera_right and level_05.bg5_camera_top < level_05.bg5_camera_bottom, SCOPE, "结局区域摄像机边界顺序错误", errors)
		_require(level_05.bg5_camera_zoom > 0.0 and level_05.bg5_move_speed_multiplier > 0.0, SCOPE, "结局区域摄像机或移动倍率非法", errors)
		_require(level_05.lantern_interaction_radius > 0.0 and not level_05.lantern_dialogues.is_empty() and not level_05.grandpa_prompt_dialogues.is_empty(), SCOPE, "灯笼交互半径或对话不能为空", errors)
		_require(level_05.erosion_max > 0.0 and level_05.erosion_rate >= 0.0 and level_05.erosion_kill_reduction >= 0.0, SCOPE, "侵蚀参数非法", errors)
		_require(level_05.boss_bar_max_width > 0.0, SCOPE, "Boss 条宽度必须大于 0", errors)

	var level_final := _load_typed("res://DataConfig/Level/LevelFinalData.tres", LevelFinalData, errors) as LevelFinalData
	if level_final:
		const SCOPE := "LevelFinalData"
		_require(level_final.background_size.x > 0.0 and level_final.background_size.y > 0.0, SCOPE, "背景尺寸必须大于 0", errors)
		_require(level_final.interaction_size.x > 0.0 and level_final.interaction_size.y > 0.0, SCOPE, "交互区域尺寸必须大于 0", errors)
		_require_resource_path(level_final.player_scene_path, SCOPE, "player_scene_path", errors)
		_require_resource_path(level_final.title_scene_path, SCOPE, "title_scene_path", errors)
		_require(level_final.player_move_speed_multiplier > 0.0, SCOPE, "玩家移动倍率必须大于 0", errors)
		_require(level_final.camera_limit_left < level_final.camera_limit_right and level_final.camera_limit_top < level_final.camera_limit_bottom, SCOPE, "终局摄像机边界顺序错误", errors)
		_require(level_final.camera_zoom.x > 0.0 and level_final.camera_zoom.y > 0.0 and level_final.camera_lerp_speed > 0.0, SCOPE, "终局摄像机参数非法", errors)
		_require(level_final.ending_fade_duration > 0.0, SCOPE, "结尾淡出时长必须大于 0", errors)


static func _validate_skill_configs(errors: Array[String]) -> void:
	for path: String in SKILL_CONFIG_PATHS:
		var cfg := _load_typed(path, SkillConfig, errors) as SkillConfig
		if cfg == null:
			continue
		_require(cfg.skill_id != "", path, "skill_id 不能为空", errors)
		_require(cfg.damage >= 0, path, "技能伤害不能为负", errors)
		_require(cfg.damage_type >= GlobalDefine.DamageType.PHYSICAL and cfg.damage_type <= GlobalDefine.DamageType.TRUE_DAMAGE, path, "damage_type 越界", errors)
		_require(cfg.cooldown >= 0.0, path, "技能冷却不能为负", errors)
		_require(cfg.crit_chance >= 0.0 and cfg.crit_chance <= 1.0, path, "技能暴击率必须在 0..1", errors)
		_require(cfg.range_x > 0.0 and cfg.range_y > 0.0, path, "技能判定范围必须大于 0", errors)
		_require(cfg.action_duration > 0.0, path, "技能动作时长必须大于 0", errors)
		_require(cfg.projectile_damage >= 0 and cfg.projectile_speed > 0.0 and cfg.projectile_max_distance > 0.0, path, "技能弹体伤害、速度或距离非法", errors)
		_require(cfg.projectile_crit_chance >= 0.0 and cfg.projectile_crit_chance <= 1.0, path, "技能弹体暴击率必须在 0..1", errors)
		_require(cfg.camera_shake_strength >= 0.0 and cfg.camera_shake_duration > 0.0, path, "技能镜头震动参数非法", errors)


static func _validate_memory_area(scope: String, cfg: MemoryRecoveryAreaConfig, edge_margin: float, errors: Array[String]) -> void:
	_require(cfg.area_index == 1 or cfg.area_index == 2, scope, "area_index 必须为 1 或 2", errors)
	_require_resource_path(cfg.scene_path, scope, "scene_path", errors)
	_require(cfg.use_override_spawn_position or not String(cfg.spawn_node_path).is_empty(), scope, "未覆盖出生点时 spawn_node_path 不能为空", errors)
	_require(cfg.camera_limit_left < cfg.camera_limit_right and cfg.camera_limit_top < cfg.camera_limit_bottom, scope, "摄像机边界顺序错误", errors)
	_require(cfg.camera_zoom.x > 0.0 and cfg.camera_zoom.y > 0.0 and cfg.camera_lerp_speed > 0.0, scope, "摄像机缩放或跟随速度非法", errors)
	_validate_ordered_pair(scope, "enemy_spawn_x_range", cfg.enemy_spawn_x_range.x, cfg.enemy_spawn_x_range.y, errors)
	_validate_ordered_pair(scope, "drop_spawn_x_range", cfg.drop_spawn_x_range.x, cfg.drop_spawn_x_range.y, errors)
	_require(cfg.enemy_spawn_x_range.x >= float(cfg.camera_limit_left) and cfg.enemy_spawn_x_range.y <= float(cfg.camera_limit_right), scope, "敌人生成横向范围超出摄像机边界", errors)
	_require(cfg.drop_spawn_x_range.x >= float(cfg.camera_limit_left) + edge_margin and cfg.drop_spawn_x_range.y <= float(cfg.camera_limit_right) - edge_margin, scope, "记忆掉落横向范围没有保留配置边距", errors)
	if cfg.drop_spawn_y_range != Vector2.ZERO:
		_validate_ordered_pair(scope, "drop_spawn_y_range", cfg.drop_spawn_y_range.x, cfg.drop_spawn_y_range.y, errors)
	_require(cfg.max_alive_enemies > 0 and cfg.enemy_spawn_interval > 0.0, scope, "敌人存活上限和生成间隔必须大于 0", errors)


static func _validate_parallel_arrays(scope: String, label: String, first_size: int, second_size: int, errors: Array[String]) -> void:
	_require(first_size == second_size, scope, "%s数组长度不一致" % label, errors)


static func _require_resource_path(path_value: String, scope: String, label: String, errors: Array[String]) -> void:
	_require(not path_value.is_empty() and ResourceLoader.exists(path_value), scope, "%s 不存在: %s" % [label, path_value], errors)


static func _load_typed(path: String, expected_script: Variant, errors: Array[String]) -> Resource:
	if not ResourceLoader.exists(path):
		errors.append("%s: 资源不存在" % path)
		return null
	var resource := load(path)
	if resource == null:
		errors.append("%s: 资源加载失败" % path)
		return null
	if not is_instance_of(resource, expected_script):
		errors.append("%s: 资源类型错误" % path)
		return null
	return resource


static func _require(condition: bool, scope: String, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append("%s: %s" % [scope, message])


static func _validate_ordered_pair(scope: String, label: String, min_value: float, max_value: float, errors: Array[String]) -> void:
	_require(min_value <= max_value, scope, "%s 最小值不能大于最大值" % label, errors)
