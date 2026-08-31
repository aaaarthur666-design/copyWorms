# ============================================================
# PlayerConfig.gd - 玩家数值配置资源类
# 在编辑器中创建 .tres 实例，填入具体数值
# ============================================================
extends Resource
class_name PlayerConfig

@export_group("基础属性")
@export var max_health: int = 100
@export var move_speed: float = 250.0
@export var ladder_climb_speed: float = 250.0
@export var jump_velocity: float = -650.0          # 初始跳跃速度
@export var jump_hold_gravity_scale: float = 0.35  # 长按跳跃时重力倍率（越小跳越高）
@export var jump_release_gravity_scale: float = 2.5 # 松开跳跃时重力倍率（快速下落）
@export var gravity: float = 1200.0

@export_group("移动手感")
@export var max_jump_hold_time: float = 0.25
@export var jump_velocity_multiplier: float = 1.15
@export var double_jump_velocity_multiplier: float = 0.9
@export var jump_invincible_time: float = 0.18
@export var air_state_threshold: float = 0.05
@export var input_dead_zone: float = 0.1
@export var facing_velocity_threshold: float = 10.0
@export var movement_acceleration_multiplier: float = 10.0
@export var air_attack_acceleration_multiplier: float = 3.0
@export var ground_attack_acceleration_multiplier: float = 5.0
@export var ground_attack_speed_multiplier: float = 0.5
@export var death_deceleration: float = 500.0

@export_group("镜头跟随")
@export var camera_follow_lerp_speed: float = 5.0
@export var camera_deadzone_size: Vector2 = Vector2(10.0, 40.0)
@export var camera_lookahead_offset: float = 80.0
@export var camera_lookahead_lerp: float = 3.0

@export_group("战斗属性")
@export var attack_damage: int = 25
@export var attack_cooldown: float = 0.4
@export var attack_range: float = 80.0              # 增大攻击范围
@export var attack_center_distance: float = 40.0
@export var attack_direction_y_bias: float = -0.2
@export var attack_windup_time: float = 0.1
@export var ground_attack_duration: float = 0.25
@export var air_attack_duration: float = 0.35
@export var hit_camera_shake_strength: float = 4.0
@export var critical_hit_camera_shake_strength: float = 8.0
@export var hit_camera_shake_duration: float = 0.15

@export_group("冲刺属性")
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.8
@export var dash_invincible_bonus: float = 0.3

@export_group("受击与接触伤害")
@export var hurt_invincible_time: float = 1.0
@export var hurt_knockback: float = 300.0
@export var hurt_knockback_vertical: float = -120.0
@export var knockback_duration: float = 0.35
@export var default_contact_damage: int = 8
@export var contact_invincible_time: float = 1.5
@export var contact_knockback_horizontal: float = 300.0
@export var contact_knockback_vertical: float = -200.0
@export var nearby_enemy_push_range: float = 80.0
@export var nearby_enemy_push_force: float = 120.0
@export var nearby_enemy_push_vertical: float = -80.0
@export var nearby_enemy_stun_time: float = 0.3

@export_group("反馈节奏")
@export var invincible_blink_interval: float = 0.08
@export var walk_sfx_interval: float = 0.45
@export var walk_sfx_pitch_min: float = 0.92
@export var walk_sfx_pitch_max: float = 1.08
@export var attack_sfx_pitch_min: float = 0.95
@export var attack_sfx_pitch_max: float = 1.08
@export var hurt_sfx_pitch_min: float = 0.92
@export var hurt_sfx_pitch_max: float = 1.08
@export var skill_sfx_pitch_min: float = 0.95
@export var skill_sfx_pitch_max: float = 1.05
@export var charge_sfx_pitch_min: float = 0.95
@export var charge_sfx_pitch_max: float = 1.08
