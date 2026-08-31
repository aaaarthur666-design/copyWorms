extends Resource
class_name LingnanPlayerConfig

## 岭南形态专属玩法参数。八卦阵线条、颜色等纯表现参数不属于平衡数据。

@export_group("控制与蓄力")
@export var action_deceleration: float = 600.0
@export var skill_cooldown: float = 5.0
@export var charge_threshold_short: float = 0.2
@export var charge_threshold_big: float = 0.6
@export var charge_max_time: float = 1.1
@export var bagua_charge_max_time: float = 3.5
@export var charge_damage_multiplier: float = 0.5

@export_group("长按普攻突进")
@export var attack_hold_threshold: float = 0.18
@export var dash_cooldown: float = 3.5
@export var dash_windup_time: float = 0.2
@export var dash_speed: float = 1000.0
@export var dash_duration: float = 0.2
@export var dash_hit_radius: float = 50.0
@export var dash_path_hit_radius: float = 50.0
@export var dash_damage: int = 25
@export var dash_damage_type: int = 0
@export_range(0.0, 1.0, 0.01) var dash_crit_chance: float = 0.1
@export var dash_afterimage_interval: float = 0.06
@export var dash_action_time_bonus: float = 0.1
@export var dash_invincible_bonus: float = 0.3
@export var dash_camera_shake_strength: float = 4.0
@export var dash_camera_shake_duration: float = 0.1

@export_group("回旋斩")
@export var small_spin_duration: float = 0.2
@export var small_spin_hits: int = 1
@export var small_spin_range: float = 100.0
@export var small_spin_damage: int = 30
@export var big_spin_duration: float = 0.3
@export var big_spin_hits: int = 2
@export var big_spin_range: float = 160.0
@export var big_spin_damage: int = 25
@export var spin_damage_type: int = 0
@export_range(0.0, 1.0, 0.01) var spin_crit_chance: float = 0.1
@export var spin_second_hit_time: float = 0.1
@export var spin_action_time_bonus: float = 0.05
@export var small_spin_camera_shake: float = 3.0
@export var big_spin_camera_shake: float = 5.0
@export var spin_camera_shake_duration: float = 0.15

@export_group("蓄力吸附")
@export var suck_range: float = 800.0
@export var suck_force: float = 520.0
@export var suck_min_distance: float = 10.0
@export var suck_min_strength_ratio: float = 0.2
@export var suck_vertical_ratio: float = 0.5
@export var suck_horizontal_response: float = 10.0
@export var suck_vertical_response: float = 5.0

@export_group("八卦冲击与护盾")
@export var bagua_action_duration: float = 0.35
@export var bagua_min_range: float = 120.0
@export var bagua_max_range: float = 360.0
@export var bagua_min_push_force: float = 420.0
@export var bagua_max_push_force: float = 980.0
@export var bagua_min_falloff: float = 0.25
@export var bagua_vertical_push_ratio: float = 0.35
@export var bagua_enemy_stun_time: float = 0.35
@export var bagua_non_body_displacement: float = 0.04
@export var bagua_huadan_stun_time: float = 3.0
@export var bagua_shield_max_hp: int = 15
@export var bagua_camera_shake_base: float = 4.0
@export var bagua_camera_shake_bonus: float = 5.0
@export var bagua_camera_shake_duration: float = 0.16
