# ============================================================
# Level04Data.gd - 关卡4「维度侵蚀与空间崩塌」数据类
# 单坐标空间: 起始地(0-1200) + 战斗区(1200-2400) + 渗透区(2400-4800) + 撕裂区(4800-9600) + 终焉之域(9600-12800)
# ============================================================
extends Resource
class_name Level04Data

@export_category("角色与通用流程")
@export var cyber_player_scene_path: String = "res://PlayerModule/Formal/Player_Warrior_Cyber.tscn"
@export var lingnan_player_scene_path: String = "res://PlayerModule/Formal/Player_Warrior_Lingnan.tscn"
@export var intro_fade_duration: float = 1.5
@export var interaction_fallback_radius: float = 120.0
@export var narrative_input_arm_delay: float = 0.3
@export var narrative_poll_interval: float = 0.05
@export var floating_text_duration: float = 1.5
@export_multiline var opening_protocol_text: String = ""
@export_multiline var guide_text: String = ""
@export_multiline var wall_block_text: String = ""

# ---- 阶段0: 起始地 ----
@export var anchor_narrative: String = "[color=goldenrod]前方的空间似乎不太稳定……空气中弥漫着异常的能量波动。[/color]"

# ---- 阶段1: 境域置换 —— 半对半空间硬切 ----
@export var surface_enemy_count: int = 5
@export var surface_enemy_spawn_points: Array[Vector2] = []
@export var stage_1_camera_top: int = -696
@export var stage_1_intro_pan_target: Vector2 = Vector2(1733, 318)
@export var world_swap_cooldown: float = 0.8
@export var lingnan_camera_top: int = 904
@export var lingnan_intro_pan_target: Vector2 = Vector2(1581, 1320)
@export var lingnan_enemy_spawn_points: Array[Vector2] = []
@export var lingnan_swap_dialogues: Array[String] = []
@export var post_swap_dialogue_delay: float = 1.0
@export_multiline var cyber_return_dialogue: String = ""
@export var stage_1_enemy_swap_progress: int = 2
@export var swap_glitch_base_strength: float = 0.5
@export var swap_glitch_strength_per_swap: float = 0.08
@export var swap_glitch_max_strength: float = 1.0
@export var swap_glitch_base_duration: float = 0.25
@export var swap_glitch_duration_per_swap: float = 0.04
@export var swap_flash_duration: float = 0.3
@export var stage_1_test_player_position: Vector2 = Vector2(400, 550)
@export var stage_3_test_player_offset: Vector2 = Vector2(-60, 0)

# ---- 阶段2: 异质渗透 ----
@export_multiline var stage_2_entry_text: String = ""
@export var stage_2_transition_fade_duration: float = 0.3
@export var stage_2_lingnan_camera_left: int = 0
@export var stage_2_lingnan_camera_right: int = 7472
@export var stage_2_lingnan_camera_top: int = 4000
@export var stage_2_lingnan_camera_bottom: int = 5032
@export var stage_2_cyber_camera_top: int = 6504
@export var stage_2_cyber_camera_bottom: int = 7542
@export var stage_2_lantern_spawn_points: Array[Vector2] = []
@export var stage_2_paper_spawn_points: Array[Vector2] = []
@export var stage_2_wolf_spawn_points: Array[Vector2] = []
@export var stage_2_bull_spawn_points: Array[Vector2] = []
@export var fall_death_delay: float = 1.0
@export var fall_detection_map_min_y: float = 6800.0
@export var fall_death_y: float = 7540.0
@export var enemy_vertical_reachability: float = 160.0

@export var override_protocol_text: String = "[SYSTEM] 维度崩塌已完成 — 终焉序列启动\n按 Enter 继续"

# ---- 转场 ----
@export var next_level_path: String = ""
@export var stage_3_transition_fade_duration: float = 0.5
@export var camera_pan_travel_duration: float = 0.5
@export var camera_pan_hold_duration: float = 2.5

@export_category("Gameplay Tuning")
@export var cyber_teleport: Vector2 = Vector2(2298, -75)
@export var hurt_swap_delay: float = 0.28
@export var lingnan_swap_positions: Array[Vector2] = [Vector2(524, 2060), Vector2(3564, 2073), Vector2(1631, 1316)]
@export var stage_2_spawn: Vector2 = Vector2(242, 4333)
@export var stage_2_map_offset: float = 2500.0
@export var stage_2_swap_interval_min: float = 5.0
@export var stage_2_swap_interval_max: float = 12.0
@export var stage_2_warning_time: float = 2.5
@export var erosion_max: float = 100.0
@export var erosion_rate: float = 0.7
@export var erosion_kill_reduction: float = 15.0
@export var narrative_input_timeout: float = 30.0
