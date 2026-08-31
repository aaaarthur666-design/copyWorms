# ============================================================
# SkillConfig.gd - 技能数值配置资源类
# 在编辑器中创建 .tres 实例，填入具体数值
# ============================================================
extends Resource
class_name SkillConfig

@export_group("基础信息")
@export var skill_name: String = "未命名技能"
@export var skill_id: String = ""
@export var skill_icon: Texture2D = null

@export_group("伤害属性")
@export var damage: int = 30
@export var damage_type: int = 0  # 对应 GlobalDefine.DamageType
@export_range(0.0, 1.0, 0.01) var crit_chance: float = 0.0

@export_group("冷却")
@export var cooldown: float = 3.0

@export_group("范围属性")
@export var range_x: float = 100.0
@export var range_y: float = 80.0
@export var center_offset: Vector2 = Vector2(40, -10)
@export var direction_y_bias: float = -0.2

@export_group("动作节奏")
@export var action_duration: float = 0.5

@export_group("弹体")
@export var projectile_damage: int = 25
@export var projectile_speed: float = 800.0
@export var projectile_max_distance: float = 350.0
@export_range(0.0, 1.0, 0.01) var projectile_crit_chance: float = 0.15
@export var projectile_spawn_offset: Vector2 = Vector2(25, -10)

@export_group("镜头反馈")
@export var camera_shake_strength: float = 6.0
@export var camera_shake_duration: float = 0.15
