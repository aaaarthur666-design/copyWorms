extends Resource
class_name LevelFinalData

@export_group("场景布局")
@export var background_size: Vector2 = Vector2(400, 720)
@export var background_color: Color = Color(0.769, 0.6, 0.286, 1.0)
@export var player_spawn: Vector2 = Vector2(320, 616)
@export var interaction_position: Vector2 = Vector2(192, 592)
@export var interaction_size: Vector2 = Vector2(100, 80)

@export_group("玩家与摄像机")
@export var player_scene_path: String = "res://PlayerModule/Formal/Player_Warrior.tscn"
@export var player_move_speed_multiplier: float = 0.2
@export var camera_limit_left: int = 0
@export var camera_limit_right: int = 400
@export var camera_limit_top: int = 314
@export var camera_limit_bottom: int = 640
@export var camera_zoom: Vector2 = Vector2(3.5, 3.5)
@export var camera_lerp_speed: float = 2.5

@export_group("结尾演出")
@export_multiline var ending_text: String = ""
@export var ending_fade_duration: float = 5.0
@export var title_scene_path: String = "res://UI/TitleScreen.tscn"
