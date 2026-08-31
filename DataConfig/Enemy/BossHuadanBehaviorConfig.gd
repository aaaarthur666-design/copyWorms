extends Resource
class_name BossHuadanBehaviorConfig

@export_group("阶段决策")
## 下标 0 为占位，1-4 对应 Boss 四个阶段。
@export var phase_profiles: Array[BossDecisionProfile] = []
@export var player_stationary_speed: float = 30.0
@export var approaching_player_bias: float = 0.25
@export var fleeing_player_bias: float = -0.25
@export var ambient_jump_chance: float = 0.08

@export_group("战斗节奏")
@export var kite_entry_retreat_duration: float = 0.5
@export var kite_exit_chance: float = 0.5
@export var kite_retry_duration_multiplier: float = 0.7
@export var kite_melee_distance: float = 120.0
@export var kite_ranged_distance: float = 250.0

@export_group("反应式行为")
@export var phase4_reactive_chance_multiplier: float = 0.5
@export var skill_reactive_chance_multiplier: float = 0.8
@export var fleeing_distance_delta: float = 30.0
@export var fleeing_speed_threshold: float = 50.0
@export var fleeing_reactive_chance_multiplier: float = 0.5
@export var reactive_action_lock: float = 0.2
@export var evade_duration: float = 0.3
@export var evade_action_lock: float = 0.3

@export_group("空中与悬停")
@export var airborne_sword_delay: float = 0.15
@export var landing_grace_time: float = 0.08
@export var hover_activation_delay: float = 0.1
@export var hover_horizontal_speed_multiplier: float = 0.3
@export var hover_horizontal_acceleration_multiplier: float = 2.0
@export var hover_rise_speed: float = 400.0
@export var hover_first_sword_delay: float = 0.2
@export var forced_hover_airborne_time: float = 0.2
@export var forced_hover_action_lock: float = 0.2

@export_group("动作持续与移动")
@export var approach_duration: float = 1.0
@export var retreat_duration: float = 0.8
@export var idle_duration: float = 0.4
@export var approach_stop_distance: float = 100.0
@export var approach_speed_multiplier: float = 0.85
@export var normal_retreat_distance: float = 280.0
@export var kite_retreat_distance: float = 400.0
@export var normal_retreat_speed_multiplier: float = 0.7
@export var kite_retreat_speed_multiplier: float = 1.2
@export var ranged_action_lock: float = 0.5
@export var melee_approach_distance: float = 80.0
@export var evade_speed_multiplier: float = 1.5
@export var jump_action_lock: float = 0.2
@export var airborne_horizontal_speed_multiplier: float = 0.8
@export var movement_acceleration_multiplier: float = 3.0

@export_group("剑气生成")
@export var ground_projectile_count: int = 1
@export var empowered_projectile_count: int = 3
@export var projectile_spread_angles: PackedFloat32Array = PackedFloat32Array([-0.21, 0.0, 0.21])
@export var projectile_forward_offset: float = 60.0
@export var projectile_vertical_start: float = -30.0
@export var projectile_vertical_step: float = 30.0
@export var melee_projectile_vertical_direction: float = -0.3
@export var melee_projectile_forward_offset: float = 50.0
@export var melee_projectile_vertical_offset: float = -20.0
@export var melee_hitbox_offset: float = 65.0

@export_group("召唤")
@export var minion_positive_side_chance: float = 0.5
