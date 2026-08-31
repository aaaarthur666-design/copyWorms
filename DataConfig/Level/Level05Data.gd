extends Resource
class_name Level05Data

@export_group("角色与通用流程")
@export var cyber_player_scene_path: String = "res://PlayerModule/Formal/Player_Warrior_Cyber.tscn"
@export var lingnan_player_scene_path: String = "res://PlayerModule/Formal/Player_Warrior_Lingnan.tscn"
@export var initial_corruption: float = 0.35
@export var intro_fade_duration: float = 1.5
@export var dialog_close_cooldown: float = 0.4
@export var manual_corruption_step: float = 0.05

@export_group("bg3 双世界")
@export var bg3_player_position: Vector2 = Vector2(-1603, 380)
@export var bg3_camera_top: int = 80
@export var bg3_camera_bottom: int = 648
@export var bg3_camera_zoom: float = 1.33
@export var world_swap_shake_strength: float = 8.0
@export var world_swap_shake_duration: float = 0.25
@export var dual_world_ground_spawn_points: Array[Vector2] = []
@export var dual_world_special_spawn_points: Array[Vector2] = []

@export_group("双角色战斗")
@export var dual_character_max_health: int = 100
@export var layer_swap_cooldown: float = 1.2
@export var low_health_hint_threshold: int = 50
@export var skin_hint_text: String = "按 G 切换人物外观"
@export var skin_hint_hold_duration: float = 3.0
@export var skin_hint_fade_duration: float = 1.0

@export_group("Boss 区域")
@export var boss_player_position: Vector2 = Vector2(931, 5037)
@export var boss_camera_left: int = 620
@export var boss_camera_right: int = 1710
@export var boss_camera_top: int = 4512
@export var boss_checkpoint_camera_top: int = 4509
@export var boss_camera_bottom: int = 5135
@export var boss_camera_zoom: float = 1.33
@export var boss_checkpoint_camera_zoom: float = 1.5
@export var boss_checkpoint_stage: int = 4
@export var boss_scene_path: String = "res://EnemyModule/Formal/Enemy_BossHuadan.tscn"
@export var boss_spawn_position: Vector2 = Vector2(1300, 5037)
@export var boss_intro_dialogues: Array[String] = []
@export var boss_death_dialogues: Array[String] = []
@export var boss_death_lantern_y_min: float = 5000.0
@export var boss_death_lantern_y_max: float = 5077.0
@export var boss_death_music_path: String = "res://Assets/Music/lv6.ogg"
@export var boss_death_music_fade_duration: float = 2.0
@export var boss_death_shake_strength: float = 22.0
@export var boss_death_shake_duration: float = 0.8
@export var boss_death_time_scale: float = 0.25
@export var boss_death_recovery_delay: float = 1.5

@export_group("视频演出")
@export var huadan_video_path: String = "res://Assets/huadan-CG.ogv"
@export var grandpa_video_path: String = "res://Assets/视频演出.ogv"
@export var video_volume_db: float = -80.0
@export var huadan_video_fade_duration: float = 0.5
@export var grandpa_video_fade_duration: float = 1.0
@export var ending_black_hold_duration: float = 1.5
@export var ending_level_path: String = "res://LevelModule/Formal/Level_final.tscn"
@export var video_load_failure_text: String = "（视频加载失败）"

@export_group("结局区域")
@export var bg5_player_position: Vector2 = Vector2(569, 8076)
@export var bg5_camera_left: int = 200
@export var bg5_camera_right: int = 2200
@export var bg5_camera_top: int = 7448
@export var bg5_camera_bottom: int = 8300
@export var bg5_camera_zoom: float = 1.33
@export var bg5_music_path: String = "res://Assets/Music/lv6.ogg"
@export var bg5_music_fade_duration: float = 1.5
@export var bg5_move_speed_multiplier: float = 0.5
@export var lantern_position_offset: Vector2 = Vector2(0, 15)
@export var lantern_interaction_radius: float = 130.0
@export var lantern_prompt_text: String = "按 Enter 拾起灯笼"
@export var lantern_dialogues: Array[String] = []
@export var grandpa_prompt_dialogues: Array[String] = []

@export_group("侵蚀")
@export var erosion_max: float = 100.0
@export var erosion_rate: float = 0.7
@export var erosion_kill_reduction: float = 15.0

@export_group("HUD")
@export var boss_bar_max_width: float = 400.0
