# ============================================================
# SwordEnergy.gd — Boss 剑气弹幕
# 朝玩家方向飞行，撞墙消失，对玩家造成伤害
# ============================================================
extends Area2D

var _velocity: Vector2 = Vector2.ZERO
var _damage: int = 0
var _lifetime: float = 0.0
var _max_lifetime: float = 0.0
var _damage_instigator: Node2D = null

@onready var _sprite: Sprite2D = $Sprite

func setup(target_pos: Vector2, dmg: int, speed: float, max_lifetime: float, instigator: Node2D = null) -> void:
	_damage = dmg
	_max_lifetime = max_lifetime
	_damage_instigator = instigator
	var dir = (target_pos - global_position).normalized()
	_velocity = dir * speed
	rotation = dir.angle()

## 按指定方向初始化（用于扇形散布，瞄准方向而非固定点）
func setup_by_dir(dir: Vector2, dmg: int, speed: float, max_lifetime: float, instigator: Node2D = null) -> void:
	_damage = dmg
	_max_lifetime = max_lifetime
	_damage_instigator = instigator
	_velocity = dir.normalized() * speed
	rotation = dir.angle()


## 直接伤害来源仍是剑气自身；反击等需要追溯攻击者的系统通过此接口取得发起者。
func get_damage_instigator() -> Node2D:
	return _damage_instigator if is_instance_valid(_damage_instigator) else null

func set_color(col: Color) -> void:
	if _sprite:
		_sprite.modulate = col

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += _velocity * delta
	_lifetime += delta
	if _lifetime > _max_lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# 只检测玩家层（collision_mask=4），剑气穿过所有地形
	if body == GameManager.player_ref:
		if body.has_method("take_damage"):
			var kb = (body.global_position - global_position).normalized()
			body.take_damage(_damage, kb, self)
		queue_free()
