# ============================================================
# EnemyBase.gd - 敌人基类
# 定义所有敌人的公共接口与默认行为
# 子类只需重写对应虚函数，禁止修改此文件
# ============================================================
extends CharacterBody2D
class_name EnemyBase

# 配置引用
@export var config: EnemyConfig = null

# 状态变量
var current_state: int = GlobalDefine.EnemyState.IDLE
var current_health: int = 0
var max_health: int = 0
var is_facing_right: bool = false
var is_dead: bool = false

# 冷却计时器
var attack_cooldown_timer: float = 0.0
var patrol_wait_timer: float = 0.0
var stun_timer: float = 0.0
var _post_attack_pause: float = 0.0  # 攻击后停止追踪的短暂暂停

# 巡逻相关
var patrol_start_pos: Vector2 = Vector2.ZERO
var patrol_direction: int = 1

# 目标引用（通过GM获取，不直接引用节点）
var target: Node2D = null

# 残血闪烁（独立节点，不绑定敌人模型）
var _low_hp_blink: ColorRect = null
var _blink_timer: float = 0.0

# 待机/行走音效计时器（周期性有概率播放）
var _idle_walk_sfx_timer: float = 0.0

# ---- 生命周期（子类不要重写，用虚函数扩展） ----

func _ready() -> void:
	_ensure_config()
	_apply_config()
	_setup_visual()
	_setup_collision()
	patrol_start_pos = global_position
	GameManager.register_enemy(self)
	_on_ready()

func _apply_config() -> void:
	max_health = config.max_health
	current_health = max_health

func _ensure_config() -> void:
	if config:
		return
	var default_path := _get_default_config_path()
	if default_path != "" and ResourceLoader.exists(default_path):
		config = load(default_path) as EnemyConfig
	if config:
		return
	push_error("[EnemyBase] 敌人配置加载失败，使用 EnemyConfig 安全默认值: %s" % default_path)
	config = EnemyConfig.new()

func _setup_visual() -> void:
	var sprite = ColorRect.new()
	sprite.name = "PlaceholderSprite"
	sprite.color = _get_placeholder_color()
	sprite.size = _get_placeholder_size()
	sprite.position = -sprite.size / 2
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sprite)

	# 残血闪烁边框（独立节点，浮在模型上方，初始隐藏）
	_low_hp_blink = ColorRect.new()
	_low_hp_blink.name = "LowHPBlink"
	_low_hp_blink.color = Color(1, 0, 0, 0)  # 红色，初始透明
	_low_hp_blink.size = _get_placeholder_size() + Vector2(6, 6)
	_low_hp_blink.position = -_low_hp_blink.size / 2
	_low_hp_blink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_low_hp_blink)

func _setup_collision() -> void:
	# 碰撞层分离：敌人用第2层，只与第1层（地形）碰撞
	collision_layer = GlobalDefine.Collision.ENEMY
	collision_mask = GlobalDefine.Collision.TERRAIN

	var col = CollisionShape2D.new()
	col.name = "CollisionShape"
	var shape = RectangleShape2D.new()
	shape.size = _get_collision_size()
	col.shape = shape
	add_child(col)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_update_timers(delta)
	_update_low_hp_blink(delta)
	_apply_gravity(delta)
	_update_target()
	_handle_ai(delta)
	# 攻击锁定：完成此次攻击前禁止水平移动（冲撞类攻击性移动由子类 _is_attack_locked 排除）
	if _is_attack_locked():
		velocity.x = 0.0
	move_and_slide()
	_update_facing()
	_update_idle_walk_sfx(delta)
	_on_physics_process(delta)

func _update_timers(delta: float) -> void:
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta
	if patrol_wait_timer > 0:
		patrol_wait_timer -= delta
	if stun_timer > 0:
		stun_timer -= delta
	if _post_attack_pause > 0:
		_post_attack_pause -= delta

func _apply_gravity(delta: float) -> void:
	if stun_timer > 0:
		return
	var grav = config.gravity
	if not is_on_floor():
		velocity.y += grav * delta

func _update_target() -> void:
	# 对话/叙事期间不锁定玩家
	if GameManager.is_dialog_active:
		target = null
		return
	# 通过GM获取玩家引用，不直接引用节点
	target = GameManager.player_ref
	if target and not is_instance_valid(target):
		target = null

func _update_facing() -> void:
	if stun_timer > 0:
		return
	# 攻击锁定：完成此次攻击前禁止转向
	if _is_attack_locked():
		return
	if velocity.x > config.velocity_facing_threshold:
		is_facing_right = true
		scale.x = 1
	elif velocity.x < -config.velocity_facing_threshold:
		is_facing_right = false
		scale.x = -1

# ---- 残血闪烁 ----

func _update_low_hp_blink(delta: float) -> void:
	if not _low_hp_blink:
		return

	var hp_ratio = float(current_health) / float(max_health)
	var low_health_ratio := config.low_health_ratio
	if hp_ratio > low_health_ratio or hp_ratio <= 0:
		_low_hp_blink.color.a = 0
		return

	_blink_timer += delta
	# 闪烁频率随血量降低而加快
	var blink_speed = lerpf(config.low_health_blink_slow_interval, config.low_health_blink_fast_interval, 1.0 - hp_ratio / low_health_ratio)
	if _blink_timer >= blink_speed:
		_blink_timer = 0.0
		if _low_hp_blink.color.a > 0.1:
			_low_hp_blink.color.a = 0.1
		else:
			_low_hp_blink.color.a = 0.8

# ---- 待机/行走音效（有概率周期播放） ----

func _update_idle_walk_sfx(delta: float) -> void:
	# 跨bg隔离：玩家不存在或距离过远时严禁播放（防lv4/5多bg区域互相串音）
	var player = GameManager.player_ref
	if not player or not is_instance_valid(player):
		return
	if global_position.distance_to(player.global_position) > config.idle_sfx_max_distance:
		return
	# 攻击/受击/stun 状态下不播放环境音
	if stun_timer > 0:
		_idle_walk_sfx_timer = 0.0
		return
	if current_state == GlobalDefine.EnemyState.ATTACK or current_state == GlobalDefine.EnemyState.HURT:
		_idle_walk_sfx_timer = 0.0
		return
	_idle_walk_sfx_timer -= delta
	if _idle_walk_sfx_timer > 0.0:
		return
	# 到达间隔：按概率播放，并重置下一轮随机间隔
	_idle_walk_sfx_timer = randf_range(config.idle_sfx_interval_min, config.idle_sfx_interval_max)
	if randf() < config.idle_sfx_chance:
		SFXManager.play_pitched(SFXManager.SFX.ENEMY_IDLE_WALK, config.idle_sfx_pitch_min, config.idle_sfx_pitch_max, 0.0)

# ---- AI 状态机 ----

func _handle_ai(delta: float) -> void:
	if stun_timer > 0:
		velocity.x = move_toward(velocity.x, 0, config.stunned_deceleration * delta)
		return

	match current_state:
		GlobalDefine.EnemyState.IDLE:
			_ai_idle(delta)
		GlobalDefine.EnemyState.PATROL:
			_ai_patrol(delta)
		GlobalDefine.EnemyState.CHASE:
			_ai_chase(delta)
		GlobalDefine.EnemyState.ATTACK:
			_ai_attack(delta)
		GlobalDefine.EnemyState.HURT:
			_ai_hurt(delta)

func _ai_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, config.movement_deceleration * delta)
	if patrol_wait_timer <= 0:
		patrol_wait_timer = config.patrol_wait_time
		_change_state(GlobalDefine.EnemyState.PATROL)
	if _can_detect_target():
		_change_state(GlobalDefine.EnemyState.CHASE)

func _ai_patrol(delta: float) -> void:
	var speed = config.move_speed
	velocity.x = patrol_direction * speed

	# 巡逻范围检测
	var dist_from_start = global_position.x - patrol_start_pos.x
	var wander = config.wander_radius
	if abs(dist_from_start) > wander:
		patrol_direction *= -1
		_change_state(GlobalDefine.EnemyState.IDLE)

	if _can_detect_target():
		_change_state(GlobalDefine.EnemyState.CHASE)

func _ai_chase(delta: float) -> void:
	if not target or not is_instance_valid(target):
		_change_state(GlobalDefine.EnemyState.IDLE)
		return

	# 攻击锁定：完成此次攻击前禁止移动与转向
	if _is_attack_locked():
		velocity.x = 0.0
		return

	var dist = global_position.distance_to(target.global_position)
	var attack_range = config.attack_range

	if dist <= attack_range:
		# 到达攻击范围，减速停下
		velocity.x = move_toward(velocity.x, 0, config.movement_deceleration * delta)
		if _can_attack_target():
			_change_state(GlobalDefine.EnemyState.ATTACK)
			return
	else:
		var dir = signf(target.global_position.x - global_position.x)
		var speed = config.move_speed
		var multiplier = config.chase_speed_multiplier
		velocity.x = dir * speed * multiplier

	if not _can_detect_target():
		_change_state(GlobalDefine.EnemyState.IDLE)
		return

func _ai_attack(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, config.movement_deceleration * delta)
	if attack_cooldown_timer <= 0 and target and is_instance_valid(target):
		_perform_attack()
		attack_cooldown_timer = config.attack_cooldown
		# 攻击锁定：完成此次攻击前禁止转向与移动（不再后退制造间距）
		_post_attack_pause = config.post_attack_pause
		velocity.x = 0.0
		return  # 保持 ATTACK 状态，攻击动作完成前不进入决策
	# 攻击锁定结束后才切回 CHASE
	if _post_attack_pause <= 0:
		_change_state(GlobalDefine.EnemyState.CHASE)

func _ai_hurt(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, config.movement_deceleration * delta)
	if is_on_floor() and abs(velocity.x) < 10:
		_change_state(GlobalDefine.EnemyState.IDLE)

func _change_state(new_state: int) -> void:
	if is_dead and new_state != GlobalDefine.EnemyState.DEAD:
		return
	if current_state == new_state:
		return
	current_state = new_state

# ---- 检测 ----

func _can_detect_target() -> bool:
	if not target or not is_instance_valid(target):
		return false
	# 对话/叙事期间敌人不可锁定玩家
	if GameManager.is_dialog_active:
		return false
	var detect_range = config.detect_range
	return global_position.distance_to(target.global_position) <= detect_range

func _can_attack_target() -> bool:
	if not target or not is_instance_valid(target):
		return false
	var attack_range = config.attack_range
	return global_position.distance_to(target.global_position) <= attack_range

# ---- 攻击 ----

func _perform_attack() -> void:
	_on_attack()

# ---- 伤害与死亡 ----

func take_damage(damage: int, knockback_dir: Vector2 = Vector2.ZERO, source: Node = null, raw_damage: int = -1) -> void:
	if is_dead:
		return
	var incoming_raw := damage if raw_damage < 0 else raw_damage
	damage = maxi(damage, 0)
	if damage == 0:
		return

	current_health = maxi(current_health - damage, 0)


	if knockback_dir != Vector2.ZERO:
		var resist = config.knockback_resistance
		# 击退：水平为主，向上分量较小（防止飞出屏幕）
		var kb_x = knockback_dir.x * config.hurt_knockback_horizontal * (1.0 - resist)
		var kb_y = -config.hurt_knockback_vertical * (1.0 - resist)
		velocity = Vector2(kb_x, kb_y)
		stun_timer = config.hurt_stun_time

	SFXManager.play_pitched(SFXManager.SFX.ENEMY_HURT, config.hurt_sfx_pitch_min, config.hurt_sfx_pitch_max)
	EventBus.emit(GlobalDefine.EventName.ENEMY_HURT, {
		"enemy": self,
		"damage": damage,
		"current_health": current_health
	})
	EventBus.emit(GlobalDefine.EventName.DAMAGE_APPLIED, {
		"target": self,
		"source": source,
		"raw_damage": incoming_raw,
		"damage": damage,
		"current_health": current_health,
	})

	if current_health <= 0:
		die()
	else:
		_change_state(GlobalDefine.EnemyState.HURT)

func die() -> void:
	if is_dead:
		return
	_change_state(GlobalDefine.EnemyState.DEAD)
	is_dead = true
	GameManager.unregister_enemy(self)
	set_physics_process(false)
	# 白闪：致命伤害命中反馈
	modulate = Color(5, 5, 5, 1)
	EventBus.emit(GlobalDefine.EventName.ENEMY_DIED, {
		"enemy": self,
		"exp_reward": config.exp_reward
	})
	_on_die()
	# EventBus 同步完成全部回调后，再开始淡出与释放。
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), config.death_fade_duration)
	tween.tween_callback(queue_free)

# ---- 占位视觉（子类可重写） ----

func _get_placeholder_color() -> Color:
	return Color(0.9, 0.3, 0.3)  # 红色

func _get_placeholder_size() -> Vector2:
	return Vector2(40, 40)

func _get_collision_size() -> Vector2:
	return Vector2(36, 36)

# ---- 取值器 ----

func _get_move_speed() -> float:
	return config.move_speed

# ---- 虚函数（子类重写点，不要修改基类源码） ----

## 攻击锁定判定：返回 true 时禁止转向与水平移动
## 子类重写以纳入各自的攻击动作锁定条件（前摇/连击/冲撞等）
func _is_attack_locked() -> bool:
	return _post_attack_pause > 0

## 节点就绪后的初始化
func _on_ready() -> void:
	pass

## 子类返回对应的权威 .tres。生成器在 add_child() 前注入的 config 仍优先。
func _get_default_config_path() -> String:
	return ""

## 每帧物理更新后
func _on_physics_process(_delta: float) -> void:
	pass

## 攻击时触发
func _on_attack() -> void:
	pass

## 死亡时触发
func _on_die() -> void:
	pass
