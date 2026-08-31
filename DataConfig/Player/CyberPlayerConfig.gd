extends Resource
class_name CyberPlayerConfig

## 赛博形态专属玩法参数。纯视觉纹理裁切、颜色和粒子段数仍由表现代码负责。

@export_group("控制")
@export var action_deceleration: float = 600.0
@export var blocked_action_deceleration: float = 900.0
@export var normal_attack_hit_delay: float = 0.1

@export_group("长按普攻突进")
@export var attack_hold_threshold: float = 0.18
@export var dash_cooldown: float = 3.0
@export var dash_windup_time: float = 0.2
@export var dash_speed: float = 1200.0
@export var dash_duration: float = 0.25
@export var dash_hit_radius: float = 70.0
@export var dash_path_hit_radius: float = 75.0
@export var dash_damage: int = 30
@export var dash_damage_type: int = 1
@export_range(0.0, 1.0, 0.01) var dash_crit_chance: float = 0.15
@export var dash_afterimage_interval: float = 0.04
@export var dash_action_time_bonus: float = 0.1
@export var dash_invincible_bonus: float = 0.3
@export var dash_camera_shake_strength: float = 5.0
@export var dash_camera_shake_duration: float = 0.12

@export_group("蓄力剑气")
@export var skill_cooldown: float = 4.0
@export var skill_charge_tier_1: float = 0.2
@export var skill_charge_tier_2: float = 0.5
@export var skill_projectile_counts: Array[int] = [1, 3, 5]
@export var skill_action_duration: float = 0.6
@export var skill_projectile_damage: int = 19
@export var skill_projectile_damage_type: int = 1
@export var skill_projectile_speed: float = 800.0
@export var skill_projectile_distance: float = 600.0
@export_range(0.0, 1.0, 0.01) var skill_projectile_crit_chance: float = 0.15
@export var skill_projectile_homing_delay: float = 0.25
@export var skill_spread_degrees: float = 60.0
@export var skill_projectile_vertical_spacing: float = 8.0
@export var skill_projectile_spawn_offset: Vector2 = Vector2(25, -10)
@export var skill_camera_shake_strength: float = 6.0
@export var skill_camera_shake_duration: float = 0.15

@export_group("招架反击")
@export var counter_window: float = 2.0
@export var counter_cooldown: float = 5.0
@export var counter_front_offset: float = 64.0
@export var counter_stab_distance: float = 92.0
@export var counter_pose_target_height: float = 66.0
@export var counter_camera_zoom: float = 1.18
@export var counter_invincible_bonus: float = 1.0
@export var counter_action_duration: float = 1.1
@export var counter_open_delay: float = 0.16
@export var counter_first_hit_delay: float = 0.30
@export var counter_second_hit_delay: float = 0.36
@export var counter_stab_duration: float = 0.20
@export var counter_missing_target_delay: float = 0.12
@export var counter_manual_dash_wait_bonus: float = 0.08
@export var counter_first_damage: int = 18
@export var counter_second_damage: int = 22
@export var counter_damage_type: int = 1
@export_range(0.0, 1.0, 0.01) var counter_crit_chance: float = 0.15
@export var counter_first_shake_strength: float = 10.0
@export var counter_first_shake_duration: float = 0.18
@export var counter_second_shake_strength: float = 12.0
@export var counter_second_shake_duration: float = 0.20
@export var counter_manual_shake_strength: float = 9.0
@export var counter_manual_shake_duration: float = 0.16
@export var counter_hitstop_duration: float = 0.045
@export var counter_hitstop_time_scale: float = 0.08
@export var counter_direction_match_score_multiplier: float = 0.45
