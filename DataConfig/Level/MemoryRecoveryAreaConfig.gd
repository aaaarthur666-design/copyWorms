class_name MemoryRecoveryAreaConfig
extends Resource

## 记忆回收副本的区域级运行参数。场景只选择配置资源，不再自行标定数值。

@export_category("Identity And Flow")
@export_range(1, 2, 1) var area_index: int = 1
@export_file("*.tscn") var scene_path: String = ""
@export var spawn_node_path: NodePath = ^"SpawnPoints/AtticSpawn"
@export var use_override_spawn_position: bool = false
@export var override_spawn_position: Vector2 = Vector2.ZERO
@export var fallback_spawn_position: Vector2 = Vector2(140, 550)

@export_category("Camera")
@export var camera_limit_left: int = 0
@export var camera_limit_right: int = 5328
@export var camera_limit_top: int = -500
@export var camera_limit_bottom: int = 640
@export var camera_zoom: Vector2 = Vector2.ONE
@export_range(0.1, 20.0, 0.1) var camera_lerp_speed: float = 2.5

@export_category("Enemy Spawning")
@export var enemy_spawn_y: float = 540.0
@export var enemy_spawn_x_range: Vector2 = Vector2(260.0, 5000.0)
@export var allow_upper_lantern_spawns: bool = false
@export_range(1, 100, 1) var max_alive_enemies: int = 4
@export_range(0.05, 60.0, 0.05) var enemy_spawn_interval: float = 3.0

@export_category("Memory Drop Spawning")
@export var drop_spawn_y: float = 560.0
## Vector2.ZERO 表示固定使用 drop_spawn_y。
@export var drop_spawn_y_range: Vector2 = Vector2.ZERO
@export var drop_spawn_x_range: Vector2 = Vector2(260.0, 5000.0)
