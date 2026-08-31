# ============================================================
# EnemyConfig.gd - 敌人数值配置资源类
# 在编辑器中创建 .tres 实例，填入具体数值
# ============================================================
extends Resource
class_name EnemyConfig

@export_group("基础属性")
@export var max_health: int = 50
@export var move_speed: float = 100.0
@export var gravity: float = 1200.0
@export var knockback_resistance: float = 0.3

@export_group("战斗属性")
@export var attack_damage: int = 10
@export var attack_damage_type: int = GlobalDefine.DamageType.PHYSICAL
@export var attack_cooldown: float = 1.5
@export var attack_range: float = 40.0
@export var detect_range: float = 300.0

@export_group("行为属性")
@export var patrol_wait_time: float = 2.0
@export var chase_speed_multiplier: float = 1.8
@export var wander_radius: float = 100.0

@export_group("基类反馈")
@export var low_health_ratio: float = 0.3
@export var idle_sfx_interval_min: float = 1.8
@export var idle_sfx_interval_max: float = 3.5
@export var idle_sfx_chance: float = 0.25
@export var idle_sfx_max_distance: float = 1500.0
@export var movement_deceleration: float = 300.0
@export var stunned_deceleration: float = 500.0
@export var stunned_vertical_deceleration: float = 300.0
@export var post_attack_pause: float = 0.7
@export var hurt_knockback_horizontal: float = 250.0
@export var hurt_knockback_vertical: float = 100.0
@export var hurt_stun_time: float = 0.3
@export var velocity_facing_threshold: float = 5.0
@export var animation_move_threshold: float = 10.0
@export var low_health_blink_slow_interval: float = 0.3
@export var low_health_blink_fast_interval: float = 0.08
@export var idle_sfx_pitch_min: float = 0.88
@export var idle_sfx_pitch_max: float = 1.12
@export var hurt_sfx_pitch_min: float = 0.90
@export var hurt_sfx_pitch_max: float = 1.12
@export var death_fade_duration: float = 0.3

@export_group("近战追踪行为")
@export var attack_animation_duration: float = 0.4
@export var combo_pause: float = 0.5
@export var combo_rest_duration: float = 1.0
@export var attack_windup_duration: float = 0.15
@export var chase_direction_threshold: float = 8.0
@export var unreachable_time: float = 1.5
@export var lose_interest_time: float = 3.0
@export var unreachable_height: float = -40.0
@export var facing_dead_zone: float = 5.0

@export_group("跳跃敌人")
@export var jump_velocity: float = -400.0
@export var first_jump_interval_min: float = 1.0
@export var first_jump_interval_max: float = 3.0
@export var jump_interval_min: float = 2.0
@export var jump_interval_max: float = 4.0
@export var jump_chase_speed: float = 150.0
@export var jump_patrol_speed: float = 100.0
@export var attack_range_tolerance: float = 30.0

@export_group("冲撞敌人")
@export var charge_windup_duration: float = 0.35
@export var charge_speed: float = 550.0
@export var charge_duration: float = 0.4
@export var charge_range: float = 180.0
@export var charge_recovery_duration: float = 0.8
@export var charge_cooldown: float = 2.5

@export_group("漂浮远程敌人")
@export var float_amplitude: float = 12.0
@export var float_speed: float = 2.5
@export var float_height_offset: float = 60.0
@export var float_vertical_response: float = 5.0
@export var flying_patrol_speed_multiplier: float = 0.5
@export var projectile_speed: float = 300.0
@export var projectile_max_distance: float = 500.0
@export var projectile_spawn_offset: float = 20.0
@export var hover_min_distance: float = 150.0
@export var hover_max_distance: float = 300.0

@export_group("花旦 Boss")
@export var boss_phase_health: Array[int] = [0, 600, 450, 300, 150]
@export var boss_phase_blend_time: float = 1.5
@export var boss_phase_3_defense_multiplier: float = 0.6
@export var boss_phase_3_attack_multiplier: float = 0.85
@export var boss_hover_duration: float = 10.0
@export var boss_hover_sword_interval: float = 1.0
@export var boss_hover_cooldown: float = 15.0
@export var boss_hover_extra_height: float = 450.0
@export var boss_tempo_kite_duration: float = 3.0
@export var boss_tempo_damage_threshold: int = 90
@export var boss_evaluate_interval: float = 0.3
@export var boss_ranged_cooldown: float = 1.2
@export var boss_melee_cooldown: float = 1.5
@export var boss_evade_cooldown: float = 1.5
@export var boss_facing_dead_zone: float = 30.0
@export var boss_jump_cooldown: float = 3.0
@export var boss_jump_height_threshold: float = 80.0
@export var boss_phase_speed: Array[float] = [0.0, 200.0, 220.0, 250.0, 350.0]
@export var boss_phase_jump: Array[float] = [0.0, -700.0, -720.0, -800.0, -950.0]
@export var boss_phase_ranged_damage: Array[int] = [0, 5, 6, 8, 10]
@export var boss_phase_melee_damage: Array[int] = [0, 10, 12, 15, 18]
@export var boss_phase_cooldown_multiplier: Array[float] = [0.0, 1.0, 0.8, 0.6, 0.6]
@export var boss_phase_best_distance: Array[float] = [0.0, 300.0, 250.0, 200.0, 150.0]
@export var boss_phase_evade_chance: Array[float] = [0.0, 0.7, 0.55, 0.3, 0.15]
@export var boss_projectile_speed: float = 350.0
@export var boss_projectile_max_lifetime: float = 8.0
@export var boss_attack_fps: float = 12.0
@export var boss_melee_hit_frame: int = 9
@export var boss_melee_total_frames: int = 16
@export var boss_melee_hitbox_duration: float = 0.333
@export var boss_max_toughness: float = 360.0
@export var boss_poise_break_stun_time: float = 6.0
@export var boss_lingnan_stun_time: float = 3.0
@export var boss_lingnan_stun_immunity: float = 15.0
@export var boss_minion_count_min: int = 1
@export var boss_minion_count_max: int = 6
@export var boss_minion_spawn_offset_min: float = 150.0
@export var boss_minion_spawn_offset_max: float = 350.0
@export var boss_minion_clear_heal: int = 35
@export var boss_behavior: BossHuadanBehaviorConfig

@export_group("死亡掉落")
@export var exp_reward: int = 10
