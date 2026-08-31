# ============================================================
# Level02Data.gd - 关卡2文案/谜题数据资源类
# 所有关卡2叙事文案、IDE对话、配置谜题、触发参数统一入此
# 在编辑器中创建 .tres 实例填入具体内容（Level02Data.tres）
# ============================================================
class_name Level02Data
extends Resource

@export_category("Dream Attic")
@export_multiline var attic_intro_text: String = ""
@export_multiline var window_text_l2: String = ""

@export_category("Dream Street")
@export_multiline var rattan_chair_monologue: String = ""
@export var street_enemy_spawn_points: Array[Vector2] = []

@export_category("Cliff Loop")
@export_multiline var cliff_first_sight_text: String = ""
@export var interference_fall_threshold: int = 1
@export var dream_phone_echo_sender: String = "来自：妈妈"
@export_multiline var dream_phone_echo_text: String = ""
@export var wake_hold_required: float = 1.5

@export_category("Reality Room")
@export_multiline var wake_up_monologue: String = ""
@export var reality_phone_sender: String = "来自：妈妈"
@export_multiline var reality_phone_content: String = ""
@export_multiline var reality_phone_monologue: String = ""

@export_category("IDE Chat")
## 与 ide_texts 一一对应: "System" / "CodeBuddy" / "Ming"
@export var ide_speakers: Array[String] = []
@export_multiline var ide_texts: Array[String] = []

@export_category("Config Puzzle")
@export var config_item_ids: Array[String] = []
@export var config_item_labels: Array[String] = []
@export var config_initial_values: Array[String] = []
@export var config_target_values: Array[String] = []
## UI 显示用中文文案（与 initial/target_values 一一对应；为空时回退到 values 本身）
@export var config_initial_display: Array[String] = []
@export var config_target_display: Array[String] = []
@export var config_success_feedbacks: Array[String] = []
@export var recompilation_lines: Array[String] = []
@export_multiline var compile_success_text: String = ""
@export_multiline var bed_unlocked_text: String = ""

@export_category("Audio Hooks")
## 音效资源路径挂点：资源不存在时安全跳过，不阻断流程
@export var sfx_phone_vibrate_path: String = ""
@export var sfx_electric_noise_path: String = ""

@export_category("Ending")
@export var next_level_path: String = "res://LevelModule/Formal/Level_03.tscn"

@export_category("Shared Tuning")
@export var dream_move_speed_multiplier: float = 1.0
@export var narrative_input_timeout: float = 30.0
@export var narrative_input_arm_delay: float = 0.3
@export var narrative_poll_interval: float = 0.05
@export var interaction_cooldown: float = 0.3
@export var interaction_recovery_threshold: float = 0.5
@export var interaction_fallback_radius: float = 120.0
@export var interference_pulse_duration: float = 0.6
@export var interference_dim_duration: float = 1.5
@export var ide_line_delay: float = 1.2
@export var free_chat_reply_delay: float = 0.4
@export var memory_launch_prepare_delay: float = 0.45
@export var memory_launch_intro_hold_duration: float = 2.2

@export_category("Attic And Street Tuning")
@export var attic_camera_left: int = 0
@export var attic_camera_bottom: int = 640
@export var attic_transition_fade_duration: float = 0.8
@export var street_entry_position: Vector2 = Vector2(435, 550)
@export var street_enemy_max_count: int = 5
@export var single_paper_spawn_offset: Vector2 = Vector2(300, 0)
@export var next_street_segment_path: String = "res://LevelModule/Formal/Level_02_01.tscn"

@export_category("Street Segment 01 Tuning")
@export var segment_01_next_level_path: String = "res://LevelModule/Formal/Level_02_02.tscn"
@export var segment_01_map_left: int = 0
@export var segment_01_map_right: int = 4464
@export var segment_01_spawn_position: Vector2 = Vector2(140, 550)
@export var segment_01_exit_trigger_position: Vector2 = Vector2(4336, 460)
@export var segment_01_exit_trigger_size: Vector2 = Vector2(120, 360)
@export var segment_01_camera_top: int = 56
@export var segment_01_camera_bottom: int = 616
@export var segment_01_camera_zoom: Vector2 = Vector2(1.5, 1.5)
@export var segment_01_camera_lerp_speed: float = 2.5
@export var segment_01_enemy_ground_y: float = 540.0
@export var segment_01_enemy_upper_y: float = 356.0
@export var segment_01_paper_spawn_interval: int = 700
@export var segment_01_lantern_spawn_interval: int = 1000
@export var segment_01_paper_upper_spawn_x: Array[float] = [3200.0, 3900.0]
@export var segment_01_lantern_upper_spawn_x: Array[float] = [3200.0, 4000.0]
@export var segment_01_whiteout_duration: float = 4.0
@export var segment_01_whiteout_fade_duration: float = 0.8

@export_category("Vertical Segment 02 Tuning")
@export_multiline var segment_02_intro_text: String = ""
@export var segment_02_intro_delay: float = 2.0
@export var segment_02_next_level_path: String = "res://LevelModule/Formal/Level_02_03.tscn"
@export var segment_02_map_left: int = 0
@export var segment_02_map_right: int = 1474
@export var segment_02_spawn_position: Vector2 = Vector2(138, 546)
@export var segment_02_exit_trigger_position: Vector2 = Vector2(1399.6136, -498.6906)
@export var segment_02_exit_trigger_size: Vector2 = Vector2(64.7636, 93.5474)
@export var segment_02_camera_top: int = -835
@export var segment_02_camera_bottom: int = 638
@export var segment_02_camera_zoom: Vector2 = Vector2(1.5, 1.5)
@export var segment_02_camera_lerp_speed: float = 2.5
@export var segment_02_enemy_detect_range_cap: float = 500.0
@export var segment_02_paper_spawn_positions: Array[Vector2] = []
@export var segment_02_lantern_spawn_positions: Array[Vector2] = []

@export_category("Cliff Segment 03 Tuning")
@export var segment_03_player_spawn_fallback: Vector2 = Vector2(32, 512)
@export var segment_03_camera_left: int = 0
@export var segment_03_camera_right: int = 1136
@export var segment_03_camera_top: int = 0
@export var segment_03_camera_bottom: int = 640
@export var segment_03_camera_zoom: Vector2 = Vector2(1.5, 1.5)
@export var segment_03_camera_lerp_speed: float = 2.5
@export var shadow_max_alive: int = 8
@export var shadow_max_onscreen: int = 6
@export var shadow_spawn_interval: float = 1.5
@export var interference_move_multiplier: float = 0.55
@export var death_guard_health: int = 10
@export var final_blackout_fade_duration: float = 0.8
@export var final_blackout_duration: float = 4.0
@export var reality_move_multiplier: float = 0.5
@export var shadow_onscreen_distance: float = 700.0
@export var shadow_positive_side_chance: float = 0.5
@export var shadow_spawn_distance_min: float = 150.0
@export var shadow_spawn_distance_max: float = 300.0
@export var shadow_spawn_min_x: float = 50.0
@export var shadow_spawn_max_x: float = 420.0
@export var shadow_spawn_y: float = 336.0
@export var wake_hold_decay_multiplier: float = 2.0
@export var wake_transition_hold_duration: float = 0.6
@export var wake_transition_fade_duration: float = 1.0
@export var interference_invincibility_duration: float = 999.0
@export var fall_reset_fade_in_duration: float = 0.5
@export var fall_reset_fade_out_duration: float = 0.3
@export var cliff_safe_spawn_fallback: Vector2 = Vector2(232, 440)
@export var reality_player_spawn: Vector2 = Vector2(1512, 608)
@export var reality_bgm_fade_duration: float = 1.0
@export var reality_camera_zoom: Vector2 = Vector2(2.0, 2.0)
@export var reality_camera_lerp_speed: float = 2.5

@export_category("Recompile Tuning")
@export var recompile_line_interval: float = 0.45
@export var recompile_finish_delay: float = 1.0
@export var dream_version: String = "2.0"
@export_multiline var rebuilt_dream_transition_text: String = ""
@export var rebuilt_dream_hold_duration: float = 2.5

@export_category("Memory Recovery Tuning")
@export var memory_area_01: MemoryRecoveryAreaConfig
@export var memory_area_02: MemoryRecoveryAreaConfig
@export_file("*.tscn") var memory_return_scene_path: String = "res://LevelModule/Formal/Level_02_03.tscn"
@export var memory_bgm_fade_duration: float = 1.0
@export var memory_player_move_speed_multiplier: float = 1.0
@export var memory_death_guard_health: int = 1
@export var memory_death_guard_invincibility_duration: float = 999.0
@export_range(0.0, 1.0, 0.01) var memory_positive_spawn_side_chance: float = 0.5
@export var memory_fragments_per_area: int = 3
@export var memory_total_fragments: int = 6
@export var memory_kills_per_drop: int = 10
@export var memory_drop_types: Array[String] = ["月饼", "虾饺", "木棉", "醒狮", "烧卖", "蒲葵扇"]
@export var memory_lantern_spawn_weight: int = 1
@export var memory_paper_spawn_weight: int = 4
@export var memory_upper_enemy_y: float = 356.0
@export var memory_upper_enemy_chance: float = 0.35
@export var memory_enemy_spawn_distance_min: float = 220.0
@export var memory_enemy_spawn_distance_max: float = 460.0
@export var memory_drop_spawn_edge_margin: float = 80.0
@export var memory_narrative_timeout: float = 30.0
