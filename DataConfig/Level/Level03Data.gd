# ============================================================
# Level03Data.gd - 关卡3数据类
# 新布局: 凉茶铺(0-1200) + 岭南街巷(1200-2400) + 过渡走廊(2400-3600) + 赛博城(3600-15600)
# ============================================================
extends Resource
class_name Level03Data

@export_category("开场与通用交互")
@export_multiline var opening_narrative_text: String = ""
@export var intro_narrative_delay: float = 0.5
@export var intro_fade_duration: float = 1.5
@export var narrative_input_timeout: float = 30.0
@export var narrative_input_arm_delay: float = 0.3
@export var narrative_poll_interval: float = 0.05
@export var interaction_cooldown: float = 0.3
@export var interaction_recovery_threshold: float = 0.5
@export var interaction_fallback_radius: float = 120.0

@export_category("玩家与摄像机")
@export var camera_zoom: Vector2 = Vector2(1.75, 1.75)
@export var initial_camera_left: int = 0
@export var initial_camera_right: int = 2120
@export var initial_camera_top: int = 168
@export var initial_camera_bottom: int = 608
@export var cyber_camera_left: int = 1728
@export var cyber_camera_right: int = 6816
@export var cyber_camera_top: int = 168
@export var cyber_camera_bottom: int = 608
@export var cyber_player_scene_path: String = "res://PlayerModule/Formal/Player_Warrior_Cyber.tscn"
@export var cyber_player_spawn: Vector2 = Vector2(2048, 576)

# ---- 阶段1: 凉茶铺对话 ----
@export var grandpa_dialogues: Array[Dictionary] = []
@export var grandpa_glitch_text: String = ""
@export var ming_realization_text: String = ""
@export var grandpa_glitch_dialogue_index: int = 4
@export var grandpa_indicator_dialogue_index: int = 4
@export var grandpa_indicator_fade_alpha: float = 0.15
@export var grandpa_indicator_tween_duration: float = 0.3
@export var level_bgm_fade_duration: float = 1.0

# ---- 阶段2: 岭南街巷战斗 ----
@export var lingnan_enemy_count: int = 5
@export var lingnan_enemy_spawn_points: Array[Vector2] = []
@export var rush_enemy_spawn: Vector2 = Vector2(680, 540)
@export var rush_enemy_detect_range: float = 1000.0
@export_multiline var lingnan_combat_intro_text: String = ""

# ---- 阶段3: 世界异化 ----
@export var codebuddy_broadcast_lines: Array[String] = []
@export var world_shift_shake_duration: float = 3.0
@export var world_shift_reveal_delay: float = 2.0
@export var world_shift_glitch_rise_duration: float = 2.0
@export var world_shift_background_dim_duration: float = 3.0
@export var world_shift_background_color: Color = Color(0.55, 0.58, 0.65, 1.0)
@export var shake_strength: float = 16.0
@export var shake_samples_per_second: float = 20.0
@export var shake_sample_duration: float = 0.05
@export var shake_recovery_duration: float = 0.1

# ---- 阶段4: 赛博城探索 ----
@export var ai_warning_1_text: String = ""
@export var ai_warning_2_text: String = ""
@export var enemy_max_alive: int = 6
@export var enemy_max_onscreen: int = 4
@export var enemy_spawn_interval: float = 5.0
@export var corridor_enemy_spawn_points: Array[Vector2] = []
@export var dynamic_onscreen_distance: float = 700.0
@export var dynamic_spawn_positive_side_chance: float = 0.7
@export var dynamic_spawn_distance_min: float = 400.0
@export var dynamic_spawn_distance_max: float = 600.0
@export var dynamic_spawn_min_x: float = 4100.0
@export var dynamic_spawn_max_x: float = 6700.0
@export var dynamic_spawn_y: float = 540.0
@export var knockback_reverse_force: float = 350.0
@export_range(0.0, 1.0, 0.01) var player_damage_multiplier: float = 0.5

# ---- 阶段5: 异常数据光团（全局坐标，赛博城偏移+3600后） ----
@export var memory_echo_1_pos: Vector2 = Vector2(5384, 550)
@export var memory_echo_2_pos: Vector2 = Vector2(6560, 544)
@export var memory_echo_1_subtitle: String = ""
@export var memory_echo_1_codebuddy: String = ""
@export var memory_echo_2_subtitle: String = ""
@export var memory_echo_2_codebuddy: String = ""
@export var required_memory_echoes: int = 2
@export var glitch_ambient_intensity: float = 0.04
@export var glitch_spike_intensity: float = 0.8
@export var glitch_decay_duration: float = 2.0

# ---- 阶段6: 觉醒 ----
@export var awakening_monologue: String = ""
@export var override_protocol_text: String = ""
@export var next_level_path: String = "res://LevelModule/Formal/Level_04.tscn"
@export var awakening_cyber_fade_color: Color = Color(0.3, 0.3, 0.35, 1.0)
@export var awakening_cyber_fade_duration: float = 1.5

# ---- 敌人刷新点（赛博阶段，全局坐标已偏移+3600） ----
@export var cleaner_spawn_points: Array[Vector2] = []
@export var security_spawn_points: Array[Vector2] = []
