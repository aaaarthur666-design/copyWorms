extends Resource
class_name BossDecisionProfile

## 单个 Boss 阶段的距离分段与动作权重。
## 动作名必须是：IDLE / APPROACH / RETREAT / RANGED / MELEE / EVADE / JUMP / HOVER。

@export_group("距离分段")
@export var far_distance: float = 500.0
@export var mid_distance: float = 250.0
## 设为 0 表示该阶段没有“中近距”分段，mid 之后直接进入 close。
@export var near_distance: float = 120.0
@export var hover_chance: float = 0.0

@export_group("远距动作")
@export var far_actions: PackedStringArray = PackedStringArray(["APPROACH", "RANGED", "IDLE"])
@export var far_weights: PackedFloat32Array = PackedFloat32Array([0.55, 0.30, 0.15])

@export_group("中距动作")
@export var mid_actions: PackedStringArray = PackedStringArray(["RANGED", "APPROACH", "IDLE"])
@export var mid_weights: PackedFloat32Array = PackedFloat32Array([0.50, 0.25, 0.25])

@export_group("中近距动作")
@export var near_actions: PackedStringArray = PackedStringArray(["APPROACH", "RANGED", "MELEE", "IDLE"])
@export var near_weights: PackedFloat32Array = PackedFloat32Array([0.40, 0.30, 0.15, 0.15])

@export_group("贴身动作")
@export var close_actions: PackedStringArray = PackedStringArray(["MELEE", "RANGED", "RETREAT"])
@export var close_weights: PackedFloat32Array = PackedFloat32Array([0.50, 0.30, 0.20])
