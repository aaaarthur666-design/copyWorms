# ============================================================
# Enemy_BossHuadan.gd — 花旦 BOSS
# 完全自定义决策树AI，不使用 EnemyBase 默认行为
# ============================================================
extends EnemyBase
class_name Enemy_BossHuadan

# ---- 行为枚举 ----
enum BossAction { IDLE, APPROACH, RETREAT, RANGED, MELEE, EVADE, JUMP, HOVER }

# ---- 阶段枚举 ----

# ---- 当前状态 ----
var _current_action: int = BossAction.IDLE
var _action_timer: float = 0.0
var _evaluate_timer: float = 0.0
var _ranged_cd: float = 0.0
var _melee_cd: float = 0.0
var _evade_cd: float = 0.0
var _evade_dir: float = 0.0
var _evade_timer: float = 0.0
var _current_phase: int = 1
var _prev_phase: int = 1                 # 阶段切换前的旧阶段（用于参数插值）
var _phase_blend_t: float = 1.0          # 阶段插值进度 0→1（1=完全在新阶段）
var _melee_elapsed: float = 0.0
var _melee_active: bool = false
var _melee_hit_done: bool = false       # hitbox已激活标记（控制hitbox开关时序）
var _melee_damage_dealt: bool = false   # 本次攻击已造成伤害标记（防多次命中，与hitbox时序分离）
var _action_lock: float = 0.0  # 攻击/闪避动作锁，防止决策树打断动画
var _move_timeout: float = 0.0           # 移动行为持续锁（APPROACH/RETREAT/IDLE），防抖动
var _airborne_time: float = 0.0          # 离地计时（悬停触发判断用，规避起跳当帧 is_on_floor 仍 true）
var _jump_cd: float = 0.0
var _is_jumping: bool = false  # 跳跃中标记（落地后清除）

# ---- 进入三阶段首次悬停后的增益/减益 ----
var _phase3_hover_triggered: bool = false  # 是否已触发过进入三阶段的首次悬停
var _phase3_buff_active: bool = false      # 首次悬停结束后增益是否生效（防御↑攻击↓）

# ---- Phase 3 悬停系统 ----
var _is_hovering: bool = false
var _hover_timer: float = 0.0
var _hover_sword_timer: float = 0.0
var _hover_global_cd: float = 0.0       # 悬停全局冷却，防止连续上天
var _hover_rising: bool = false         # 悬停上升中（渐变上升而非瞬移）
var _hover_target_y: float = 0.0        # 悬停目标高度

const SPRITE_SCALE: float = 1.2  # 统一放大倍率
const HOVER_SPRITE_SCALE: float = 0.14  # 悬空帧(1024x1024)缩放，匹配idle帧(128x128)的视觉尺寸
var _last_player_state: int = 0
var _last_player_dist: float = 0.0   # 追踪玩家距离变化（判断跑路）
var _player_skill_watchdog: float = 0.0
var _sprite: AnimatedSprite2D = null

# ---- 战斗节奏（近身压制 ↔ 远程拉扯） ----
enum CombatTempo { MELEE_PRESSURE, RANGED_KITE }
var _tempo: int = CombatTempo.MELEE_PRESSURE
var _tempo_damage_accum: int = 0        # 近战节奏下累计受伤
var _tempo_kite_timer: float = 0.0      # 拉扯剩余时间

# ---- 空中剑气（Phase 1-2 飞空时释放一次） ----
var _air_sword_fired: bool = false

# ---- 参数 ----

# ---- 近战攻击盒 ----
var _melee_hitbox: Area2D = null

# ---- 剑气场景 ----
var _sword_scene: PackedScene = null
var _sword_pool: Array[Node2D] = []

# ---- 召唤小怪场景（悬空时随机召唤1-6只） ----
var _minion_scenes: Array[PackedScene] = []
var _spawned_minions: Array[Node2D] = []  # 已召唤的小怪（Boss死亡时清除）
var _minion_reward_given: bool = false    # 是否已发放全灭小怪奖励

# ---- 韧性 / 眩晕 ----
var toughness: float = 0.0
var max_toughness: float = 0.0
var _poise_broken: bool = false
var _pending_poise_stun_on_land: bool = false
var _lingnan_stun_immune_timer: float = 0.0
var _huadan_stun_timer: float = 0.0
var _behavior: BossHuadanBehaviorConfig = null

func _get_default_config_path() -> String:
	return "res://DataConfig/Enemy/BossHuadanConfig.tres"

func _on_ready() -> void:
	super._on_ready()
	_behavior = config.boss_behavior
	if not _behavior:
		_behavior = load("res://DataConfig/Enemy/BossHuadanBehaviorConfig.tres") as BossHuadanBehaviorConfig
	if not _behavior:
		push_error("[BossHuadan] BossHuadanBehaviorConfig 缺失，Boss 行为无法安全初始化")
		_behavior = BossHuadanBehaviorConfig.new()
	max_health = config.max_health
	current_health = max_health
	max_toughness = config.boss_max_toughness
	toughness = max_toughness
	_sprite = get_node_or_null("Sprite") as AnimatedSprite2D
	if _sprite:
		# 仅当 .tscn 未提供 SpriteFrames 时才运行时构建（fallback）
		if not _sprite.sprite_frames or not _sprite.sprite_frames.has_animation("idle"):
			_sprite.sprite_frames = _build_sprite_frames()
		_sprite.offset = Vector2(0, 10)
		_sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
		if _sprite.sprite_frames:
			if _sprite.sprite_frames.has_animation("dizziness"):
				_sprite.sprite_frames.set_animation_loop("dizziness", false)
				_sprite.sprite_frames.set_animation_speed("dizziness", 6.0)
			if _sprite.sprite_frames.has_animation("defeated"):
				_sprite.sprite_frames.set_animation_loop("defeated", false)
				_sprite.sprite_frames.set_animation_speed("defeated", 6.0)
		_sprite.play("idle")
	_melee_hitbox = get_node_or_null("MeleeHitbox")
	if _melee_hitbox:
		_melee_hitbox.monitoring = false
		for c in _melee_hitbox.get_children():
			if c is CollisionShape2D:
				c.disabled = true
		# 连接近战命中信号（之前未连接，导致近战永远不造成伤害）
		if not _melee_hitbox.body_entered.is_connected(_on_melee_body_entered):
			_melee_hitbox.body_entered.connect(_on_melee_body_entered)
	_sword_scene = load("res://EnemyModule/Formal/SwordEnergy.tscn") if ResourceLoader.exists("res://EnemyModule/Formal/SwordEnergy.tscn") else null
	# 预加载召唤小怪场景（CyberWolf + PaperEffigy）
	for path in ["res://EnemyModule/Formal/Enemy_CyberWolf.tscn", "res://EnemyModule/Formal/Enemy_PaperEffigy.tscn"]:
		if ResourceLoader.exists(path):
			_minion_scenes.append(load(path))
	is_facing_right = false
	# 订阅敌人死亡事件（检测召唤小怪全灭）
	EventBus.subscribe(GlobalDefine.EventName.ENEMY_DIED, self, "_on_minion_died")

## 覆写基类：跳过 PlaceholderSprite（使用场景中的 AnimatedSprite2D）
func _setup_visual() -> void:
	pass  # Boss 不使用低血量闪烁 ColorRect，改为四阶段贴图红色滤镜

## 禁用基类低血量闪烁（Boss 用阶段红色滤镜替代）
func _update_low_hp_blink(_delta: float) -> void:
	pass

## 运行时构建 SpriteFrames（仅当 .tscn 未提供时的 fallback）
func _build_sprite_frames() -> SpriteFrames:
	var sf = SpriteFrames.new()
	sf.remove_animation("default")
	_add_sliced_anim(sf, "idle", "res://Assets/Sprites/boss_huadan/boss待机.png", 4, 3, 128, 128, 6.0, true)
	_add_sliced_anim(sf, "walk", "res://Assets/Sprites/boss_huadan/boss行走.png", 4, 3, 128, 128, 10.0, true)
	_add_sliced_anim(sf, "attack", "res://Assets/Sprites/boss_huadan/boss攻击.png", 4, 4, 256, 256, 12.0, false)
	_add_single_anim(sf, "hang_in_air", "res://Assets/Sprites/boss_huadan/boss悬空.png", 1.0, true)
	_add_sliced_anim(sf, "dizziness", "res://Assets/Sprites/boss_huadan/boss眩晕.png", 4, 3, 256, 256, 6.0, false)
	_add_sliced_anim(sf, "defeated", "res://Assets/Sprites/boss_huadan/boss眩晕.png", 4, 3, 256, 256, 6.0, false)
	return sf

## 添加单帧动画（用于 hang_in_air 等单图资源）
func _add_single_anim(sf: SpriteFrames, anim_name: String, tex_path: String, speed: float, loop: bool) -> void:
	var tex = load(tex_path) as Texture2D
	if not tex:
		printerr("[BossHuadan] 无法加载纹理: %s" % tex_path)
		return
	sf.add_animation(anim_name)
	sf.set_animation_speed(anim_name, speed)
	sf.set_animation_loop(anim_name, loop)
	sf.add_frame(anim_name, tex)

func _add_sliced_anim(sf: SpriteFrames, anim_name: String, tex_path: String, cols: int, rows: int, fw: int, fh: int, speed: float, loop: bool) -> void:
	var tex = load(tex_path) as Texture2D
	if not tex:
		printerr("[BossHuadan] 无法加载纹理: %s" % tex_path)
		return
	sf.add_animation(anim_name)
	sf.set_animation_speed(anim_name, speed)
	sf.set_animation_loop(anim_name, loop)
	for row in range(rows):
		for col in range(cols):
			var at = AtlasTexture.new()
			at.atlas = tex
			at.region = Rect2(col * fw, row * fh, fw, fh)
			sf.add_frame(anim_name, at)

func _get_collision_size() -> Vector2:
	return Vector2(80, 160)

func _get_placeholder_color() -> Color:
	return Color(0.9, 0.2, 0.5, 0.6)

func _get_placeholder_size() -> Vector2:
	return Vector2(160, 320)


# ============================================================
# 受击打断 — 玩家击中 Boss 时取消当前攻击动作（不影响已发射剑气）
# ============================================================

func take_damage(damage: int, knockback_dir: Vector2 = Vector2.ZERO, source: Node = null, raw_damage: int = -1) -> void:
	var incoming_raw := damage if raw_damage < 0 else raw_damage
	# 进入三阶段首次悬停结束后，防御力增加（受伤减免）
	if _phase3_buff_active:
		damage = max(1, int(round(damage * config.boss_phase_3_defense_multiplier)))
	super.take_damage(damage, knockback_dir, source, incoming_raw)
	if is_dead:
		return
	_apply_toughness_damage(float(damage))
	# Phase 1 可打断，Phase 2+ 霸体
	if not is_dead and _current_phase <= 1 and (_current_action == BossAction.MELEE or _current_action == BossAction.RANGED):
		_cancel_attack()
	# 近战压制节奏下累计受伤达阈值 → 切换到拉扯逃离
	if not is_dead and _tempo == CombatTempo.MELEE_PRESSURE:
		_tempo_damage_accum += damage
		if _tempo_damage_accum >= config.boss_tempo_damage_threshold:
			_enter_kite_mode()

func _apply_toughness_damage(amount: float) -> void:
	if _poise_broken:
		return
	toughness = maxf(0.0, toughness - amount)
	if toughness <= 0.0:
		_poise_broken = true
		_pending_poise_stun_on_land = true
		_cancel_attack()
		if is_on_floor():
			_enter_huadan_stun(config.boss_poise_break_stun_time)

func apply_lingnan_bagua_stun(duration: float = -1.0) -> bool:
	if duration < 0.0:
		duration = config.boss_lingnan_stun_time
	if is_dead or _lingnan_stun_immune_timer > 0:
		return false
	_enter_huadan_stun(duration)
	_lingnan_stun_immune_timer = config.boss_lingnan_stun_immunity
	return true

func _enter_huadan_stun(duration: float) -> void:
	_cancel_attack()
	_is_hovering = false
	_hover_rising = false
	_is_jumping = false
	_pending_poise_stun_on_land = false
	_current_action = BossAction.IDLE
	_action_lock = 0.0
	_huadan_stun_timer = maxf(_huadan_stun_timer, duration)
	stun_timer = maxf(stun_timer, duration)
	velocity.x = 0.0
	if _sprite and _sprite.sprite_frames and _sprite.sprite_frames.has_animation("dizziness"):
		_sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
		_sprite.offset = Vector2(0, 10)
		_sprite.frame = 0
		_sprite.play("dizziness")

func _cancel_attack() -> void:
	_current_action = BossAction.IDLE
	_melee_active = false
	_melee_elapsed = 0.0
	_melee_hit_done = false
	_melee_damage_dealt = false
	_action_lock = 0.0
	_activate_melee_hitbox(false)
	# 中断时立即切回 idle 动画（stun 期间 _update_anim 不会被调用）
	if _sprite and is_instance_valid(_sprite) and _sprite.animation == "attack":
		_sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
		_sprite.offset = Vector2(0, 0)
		_sprite.play("idle")


# ============================================================
# 阶段系统
# ============================================================

func _detect_phase() -> void:
	var new_phase = 1
	if current_health <= config.boss_phase_health[4]:
		new_phase = 4
	elif current_health <= config.boss_phase_health[3]:
		new_phase = 3
	elif current_health <= config.boss_phase_health[2]:
		new_phase = 2
	if new_phase != _current_phase:
		_prev_phase = _current_phase
		_current_phase = new_phase
		_phase_blend_t = 0.0  # 开始参数过渡
		print("[BossHuadan] 进入阶段 %d (HP=%d)" % [_current_phase, current_health])
		# 进入三阶段立刻触发一次悬停释放剑气（仅首次）
		if new_phase == 3 and not _phase3_hover_triggered and is_on_floor() and not _is_hovering:
			_phase3_hover_triggered = true
			_force_enter_hover()
		# 进入四阶段：贴图增加红色滤镜
		if new_phase == 4 and _sprite:
			var tw = create_tween()
			tw.tween_property(_sprite, "modulate", Color(1.4, 0.6, 0.6, 1.0), 1.0).set_trans(Tween.TRANS_SINE)

## 阶段参数插值：在 prev_phase 与 current_phase 之间按 _phase_blend_t 线性插值
## 避免阶段切换时移速/伤害/CD 等参数阶跃突变
func _blendf(a: float, b: float) -> float:
	return lerpf(a, b, _phase_blend_t)

func _blendi(a: int, b: int) -> int:
	return int(round(lerpf(a, b, _phase_blend_t)))

func _get_speed() -> float:
	return _blendf(config.boss_phase_speed[_prev_phase], config.boss_phase_speed[_current_phase])

func _get_jump_velocity() -> float:
	return _blendf(config.boss_phase_jump[_prev_phase], config.boss_phase_jump[_current_phase])

func _get_ranged_dmg() -> int:
	var dmg = _blendi(config.boss_phase_ranged_damage[_prev_phase], config.boss_phase_ranged_damage[_current_phase])
	if _phase3_buff_active:
		dmg = max(1, int(round(dmg * config.boss_phase_3_attack_multiplier)))
	return dmg

func _get_melee_dmg() -> int:
	var dmg = _blendi(config.boss_phase_melee_damage[_prev_phase], config.boss_phase_melee_damage[_current_phase])
	if _phase3_buff_active:
		dmg = max(1, int(round(dmg * config.boss_phase_3_attack_multiplier)))
	return dmg

func _get_cd_mult() -> float:
	return _blendf(config.boss_phase_cooldown_multiplier[_prev_phase], config.boss_phase_cooldown_multiplier[_current_phase])

func _get_best_dist() -> float:
	return _blendf(config.boss_phase_best_distance[_prev_phase], config.boss_phase_best_distance[_current_phase])

func _get_evade_chance() -> float:
	return _blendf(config.boss_phase_evade_chance[_prev_phase], config.boss_phase_evade_chance[_current_phase])

## 进入拉扯逃离模式：中断当前攻击，后撤 + 剑气拉扯一段时间
func _enter_kite_mode() -> void:
	_tempo = CombatTempo.RANGED_KITE
	_tempo_kite_timer = config.boss_tempo_kite_duration
	_tempo_damage_accum = 0
	# 中断当前近战攻击
	if _melee_active:
		_melee_active = false
		_melee_elapsed = 0.0
		_melee_hit_done = false
		_melee_damage_dealt = false
		_activate_melee_hitbox(false)
	_current_action = BossAction.RETREAT
	_move_timeout = _behavior.kite_entry_retreat_duration
	_action_lock = 0.0

## 玩家行为权重：正值=玩家靠近（偏向近战），负值=玩家远离（偏向远程）
func _get_player_approach_bias() -> float:
	if not target or not is_instance_valid(target): return 0.0
	var dx = target.global_position.x - global_position.x
	var player_vx = target.velocity.x
	if abs(player_vx) < _behavior.player_stationary_speed: return 0.0
	# dx>0 玩家在右侧，player_vx<0 玩家向左移动（朝Boss） = 靠近
	# dx<0 玩家在左侧，player_vx>0 玩家向右移动（朝Boss） = 靠近
	# 即：signf(dx) 和 signf(player_vx) 符号相反 = 玩家朝Boss移动
	if signf(dx) != signf(player_vx):
		return _behavior.approaching_player_bias
	else:
		return _behavior.fleeing_player_bias


# ============================================================
# 主循环 — 完全替代 EnemyBase AI
# ============================================================

func _physics_process(delta: float) -> void:
	if is_dead: return

	# 基类计时器更新（stun_timer 等）
	_update_timers(delta)
	_update_low_hp_blink(delta)
	_update_target()
	if _lingnan_stun_immune_timer > 0:
		_lingnan_stun_immune_timer = maxf(0.0, _lingnan_stun_immune_timer - delta)
	if _pending_poise_stun_on_land and is_on_floor():
		_enter_huadan_stun(config.boss_poise_break_stun_time)
	if _huadan_stun_timer > 0:
		_huadan_stun_timer = maxf(0.0, _huadan_stun_timer - delta)
		if _huadan_stun_timer > 0:
			stun_timer = maxf(stun_timer, _huadan_stun_timer)
		else:
			stun_timer = 0.0

	# STAGGER：受击硬直期间停止一切行为
	if _huadan_stun_timer > 0:
		velocity.x = move_toward(velocity.x, 0, config.stunned_deceleration * delta)
		velocity.y += config.gravity * delta
		_hold_huadan_stun_animation()
		move_and_slide()
		return
	if stun_timer > 0:
		velocity.x = move_toward(velocity.x, 0, config.stunned_deceleration * delta)
		velocity.y += config.gravity * delta
		_hold_huadan_stun_animation()
		move_and_slide()
		return

	# 冷却更新
	_ranged_cd = maxf(0, _ranged_cd - delta)
	_melee_cd = maxf(0, _melee_cd - delta)
	_evade_cd = maxf(0, _evade_cd - delta)
	_evade_timer = maxf(0, _evade_timer - delta)
	_action_lock = maxf(0, _action_lock - delta)
	_move_timeout = maxf(0, _move_timeout - delta)
	_jump_cd = maxf(0, _jump_cd - delta)
	_hover_global_cd = maxf(0, _hover_global_cd - delta)
	# 战斗节奏：拉扯模式计时
	if _tempo == CombatTempo.RANGED_KITE:
		_tempo_kite_timer -= delta
		if _tempo_kite_timer <= 0:
			# 拉扯结束：50/50 回到近身压制 或 继续拉扯（短一些）
			if randf() < _behavior.kite_exit_chance:
				_tempo = CombatTempo.MELEE_PRESSURE
			else:
				_tempo_kite_timer = config.boss_tempo_kite_duration * _behavior.kite_retry_duration_multiplier
	# 离地计时（规避起跳当帧 is_on_floor 仍 true 的问题）
	if is_on_floor():
		_airborne_time = 0.0
		_air_sword_fired = false  # 落地重置空中剑气标记
	else:
		_airborne_time += delta
	# Phase 1-2：空中释放一次剑气后落地（Phase 3+ 由悬停系统接管）
	if _current_phase < 3 and _is_jumping and _airborne_time > _behavior.airborne_sword_delay and not _air_sword_fired:
		_fire_sword()
		_air_sword_fired = true

	# 跳跃落地检测（起跳宽限：_airborne_time>0.08 才算真离地，避免起跳当帧误清除）
	if _is_jumping and _airborne_time > _behavior.landing_grace_time and is_on_floor():
		_is_jumping = false
		_airborne_time = 0.0
		if _current_action == BossAction.JUMP or _current_action == BossAction.HOVER:
			_current_action = BossAction.IDLE
			_action_lock = 0.0

	# Phase 3+ 悬停触发：起跳后真正离地即激活（用 _airborne_time 判断，不依赖 _current_action==JUMP）
	if _current_phase >= 3 and _is_jumping and _airborne_time > _behavior.hover_activation_delay and not _is_hovering:
		_enter_hover()
		# 立刻进入悬停循环（跳过后续决策树和_execute_action）
		if target and is_instance_valid(target):
			velocity.x = move_toward(
				velocity.x,
				signf(target.global_position.x - global_position.x) * _get_speed() * _behavior.hover_horizontal_speed_multiplier,
				_get_speed() * _behavior.hover_horizontal_acceleration_multiplier * delta
			)
		velocity.y = 0.0
		_update_facing()
		if _sprite: _update_anim()
		move_and_slide()
		return

	# 近战攻击计时与命中窗口（第 10~14 帧判定，一次攻击只造成一次伤害）
	if _melee_active:
		_melee_elapsed += delta
		var hit_time: float = config.boss_melee_hit_frame / config.boss_attack_fps
		var total_time: float = config.boss_melee_total_frames / config.boss_attack_fps
		if _melee_elapsed >= hit_time and not _melee_hit_done:
			_activate_melee_hitbox(true)
			_melee_hit_done = true
		elif _melee_elapsed >= hit_time + config.boss_melee_hitbox_duration and _melee_hit_done:
			_activate_melee_hitbox(false)
		# hitbox激活期间每帧主动检测重叠（_melee_damage_dealt 确保一次攻击只造成一次伤害）
		if _melee_hit_done and not _melee_damage_dealt and _melee_elapsed < hit_time + config.boss_melee_hitbox_duration:
			_check_melee_overlap()
		if _melee_elapsed >= total_time:
			_melee_active = false
			_melee_elapsed = 0.0
			_melee_hit_done = false
			_melee_damage_dealt = false
			_action_lock = 0.0

	# 阶段检测
	_detect_phase()
	# 阶段插值进度更新（让参数在阶段切换时平滑过渡，避免战斗力突变）
	_phase_blend_t = minf(1.0, _phase_blend_t + delta / config.boss_phase_blend_time)

	# Phase 3 悬停逻辑
	if _is_hovering:
		_hover_timer -= delta
		# 上升阶段：缓慢上升到目标高度
		if _hover_rising:
			velocity.y = -_behavior.hover_rise_speed
			if global_position.y <= _hover_target_y:
				global_position.y = _hover_target_y
				_hover_rising = false
				velocity.y = 0.0
		else:
			velocity.y = 0.0  # 到达目标高度后悬浮
		# 悬停中持续朝向玩家，定期发射 3 发独立瞄准剑气
		if target and is_instance_valid(target):
			velocity.x = move_toward(
				velocity.x,
				signf(target.global_position.x - global_position.x) * _get_speed() * _behavior.hover_horizontal_speed_multiplier,
				_get_speed() * _behavior.hover_horizontal_acceleration_multiplier * delta
			)
		# 上升期间不发射剑气，到达高度后才开始
		if not _hover_rising:
			_hover_sword_timer -= delta
		if _hover_sword_timer <= 0 and target and is_instance_valid(target):
			_fire_sword()
			_hover_sword_timer = config.boss_hover_sword_interval
		if _hover_timer <= 0:
			_is_hovering = false
			_current_action = BossAction.IDLE
			_action_lock = 0.0
			# 进入三阶段首次悬停结束后：防御力增加、攻击力略微降低
			if _phase3_hover_triggered and not _phase3_buff_active:
				_phase3_buff_active = true
				print("[BossHuadan] 首次悬停结束 — 防御↑40%% 攻击↓15%%")
		_update_facing()
		if _sprite: _update_anim()
		velocity.y += config.gravity * delta  # 悬停结束后正常下落（_is_hovering=false后跳过）
		move_and_slide()
		return

	# 反应式覆盖检查（每帧，攻击/闪避期间锁定）
	if _action_lock <= 0:
		_check_reactive_overrides()

	# 定期决策评估（攻击/闪避/移动持续期间锁定）
	_evaluate_timer += delta
	if _evaluate_timer >= config.boss_evaluate_interval:
		_evaluate_timer = 0
		if _action_lock <= 0 and _move_timeout <= 0:
			_run_decision_tree()

	# 执行当前行为
	_execute_action(delta)

	# 近战攻击锁定：melee 期间禁止水平移动
	if _is_attack_locked():
		velocity.x = 0.0

	# 朝向（滞后，防频闪）
	_update_facing()

	# 动画 + 重力
	if _sprite:
		_update_anim()
	velocity.y += config.gravity * delta
	move_and_slide()


func _enter_hover() -> void:
	_is_hovering = true
	_hover_timer = config.boss_hover_duration
	_hover_sword_timer = _behavior.hover_first_sword_delay
	_hover_global_cd = config.boss_hover_cooldown
	_is_jumping = false
	_current_action = BossAction.HOVER
	# 渐变上升到悬停高度（不瞬移）
	_hover_rising = true
	_hover_target_y = global_position.y - config.boss_hover_extra_height
	# 悬空释放剑气时召唤 1-6 只随机小怪
	_spawn_hover_minions()

## 强制进入悬停（进入三阶段时立即触发，跳过跳跃直接上天）
func _force_enter_hover() -> void:
	_is_jumping = true
	_airborne_time = _behavior.forced_hover_airborne_time
	velocity.y = _get_jump_velocity()
	_hover_global_cd = config.boss_hover_cooldown
	_jump_cd = config.boss_jump_cooldown
	_current_action = BossAction.JUMP
	_action_lock = _behavior.forced_hover_action_lock
	print("[BossHuadan] 进入三阶段 — 强制触发悬停释放剑气")

## 悬空时召唤 1-6 只随机小怪
func _spawn_hover_minions() -> void:
	if _minion_scenes.is_empty(): return
	var count = randi_range(config.boss_minion_count_min, config.boss_minion_count_max)
	var parent = get_parent()
	if not parent: return
	var cleaner_config = load("res://DataConfig/Enemy/CleanerConfig.tres") as EnemyConfig
	var effigy_config = load("res://DataConfig/Enemy/PaperEffigyConfig.tres") as EnemyConfig
	for i in count:
		var scene = _minion_scenes[randi() % _minion_scenes.size()]
		var minion = scene.instantiate()
		# 在玩家附近按行为配置的偏移范围生成。
		var base_pos = global_position
		if target and is_instance_valid(target):
			base_pos = target.global_position  # 以玩家位置为基准（Boss在空中，不能用Boss Y）
		var side = 1.0 if randf() < _behavior.minion_positive_side_chance else -1.0
		var offset_x = side * randf_range(config.boss_minion_spawn_offset_min, config.boss_minion_spawn_offset_max)
		var spawn_pos = base_pos + Vector2(offset_x, 0)
		# Y 用玩家当前 Y（地面高度），避免生成在空中或地图外
		spawn_pos.y = base_pos.y
		minion.global_position = spawn_pos
		# 根据小怪类型赋予配置
		var is_cyber_wolf = scene.resource_path.find("CyberWolf") >= 0
		minion.config = cleaner_config if is_cyber_wolf else effigy_config
		parent.add_child(minion)
		if target and is_instance_valid(target):
			minion.target = target
		_spawned_minions.append(minion)
	print("[BossHuadan] 悬空召唤 %d 只小怪" % count)

## Boss死亡时清除所有已召唤的小怪
func _on_die() -> void:
	for minion in _spawned_minions:
		if is_instance_valid(minion):
			GameManager.unregister_enemy(minion)
			minion.queue_free()
	_spawned_minions.clear()

## 召唤小怪死亡回调：全灭后按 Boss 配置回复双血条。
func _on_minion_died(data: Dictionary) -> void:
	if is_dead: return
	if _minion_reward_given: return
	var e = data.get("enemy")
	if not e or not is_instance_valid(e): return
	if e not in _spawned_minions: return
	_spawned_minions.erase(e)
	# 全部小怪被击杀后，按配置回复玩家双血条。
	if _spawned_minions.is_empty():
		_minion_reward_given = true
		var player = GameManager.player_ref
		if player and is_instance_valid(player):
			player.heal(config.boss_minion_clear_heal)
			EventBus.emit(GlobalDefine.EventName.HEALTH_CHANGED, {
				"target": player,
				"current_health": player.current_health,
				"max_health": player.max_health
			})
		# 通知关卡补充岭南人物血量（Level_05 双血条系统）
		var level = GameManager.current_level
		if level and level.has_method("_heal_dual_char"):
			level._heal_dual_char(config.boss_minion_clear_heal)
		print("[BossHuadan] 召唤小怪全灭！玩家双血条各回%d血" % config.boss_minion_clear_heal)


# ============================================================
# 反应式覆盖
# ============================================================

func _check_reactive_overrides() -> void:
	if not target or not is_instance_valid(target): return

	var cur_dist = global_position.distance_to(target.global_position)
	var is_phase34: bool = _current_phase >= 3

	if target.has_method("_change_state"):
		var st = target.get("current_state") if "current_state" in target else 0

		# --- Phase 3-4 反应式剑气：玩家跑/跳/冲刺就挥砍剑气 ---
		if is_phase34 and _ranged_cd <= 0:
			var should_fire = false
			# Phase 4 反应式剑气概率降低（避免全程剑气轰炸）
			var reactive_chance = _behavior.phase4_reactive_chance_multiplier if _current_phase >= 4 else 1.0
			# 玩家跳跃 → 挥剑气（追踪空中目标）
			if st != _last_player_state and (st == GlobalDefine.PlayerState.JUMP or st == GlobalDefine.PlayerState.FALL):
				should_fire = randf() < reactive_chance
			# 玩家冲刺/技能 → 挥剑气（惩罚闪现）
			elif st != _last_player_state and (st == GlobalDefine.PlayerState.DASH or st == GlobalDefine.PlayerState.SKILL):
				should_fire = randf() < _behavior.skill_reactive_chance_multiplier * reactive_chance
			# 玩家跑路（距离拉大且玩家有水平速度） → 挥剑气追击
			elif cur_dist > _last_player_dist + _behavior.fleeing_distance_delta and abs(target.velocity.x) > _behavior.fleeing_speed_threshold:
				should_fire = randf() < _behavior.fleeing_reactive_chance_multiplier * reactive_chance

			if should_fire:
				_fire_sword()
				_ranged_cd = config.boss_ranged_cooldown * _get_cd_mult()
				_action_lock = _behavior.reactive_action_lock
				# 不 return，让后续逻辑可以叠加逼近/闪避
				if _current_action != BossAction.MELEE:
					_current_action = BossAction.RANGED

		# Phase 1-2: 玩家技能/冲刺 → 闪避
		if not is_phase34 and st != _last_player_state:
			_last_player_state = st
			if st == GlobalDefine.PlayerState.SKILL or st == GlobalDefine.PlayerState.DASH:
				if _evade_cd <= 0 and randf() < _get_evade_chance():
					_evade_dir = signf(global_position.x - target.global_position.x)
					if _evade_dir == 0: _evade_dir = 1
					_current_action = BossAction.EVADE
					_evade_timer = _behavior.evade_duration
					_action_lock = _behavior.evade_action_lock
					_evade_cd = config.boss_evade_cooldown * _get_cd_mult()
					return
		else:
			_last_player_state = st

	# 玩家受伤 → 挥剑气追击（不傻追）
	var cur_st = target.get("current_state") if "current_state" in target else 0
	if cur_st == GlobalDefine.PlayerState.HURT:
		if _ranged_cd <= 0:
			_current_action = BossAction.RANGED
		_last_player_dist = cur_dist  # 修复：return 前更新距离，否则跑路判断基准失准
		return

	# 更新距离追踪
	_last_player_dist = cur_dist


# ============================================================
# 决策树
# ============================================================

func _run_decision_tree() -> void:
	if not target or not is_instance_valid(target):
		_current_action = BossAction.IDLE
		return

	var dist = global_position.distance_to(target.global_position)
	var best = _get_best_dist()

	# 全阶段：低概率飞空释放剑气（Phase 3+ 进入持续悬停）
	if _hover_global_cd <= 0 and _jump_cd <= 0 and is_on_floor() and not _is_jumping and randf() < _behavior.ambient_jump_chance:
		_current_action = BossAction.JUMP
		return

	# 拉扯模式：偏向远程，但玩家贴身时允许近战反击
	if _tempo == CombatTempo.RANGED_KITE:
		if dist < _behavior.kite_melee_distance and _melee_cd <= 0:
			# 玩家贴身且近战CD就绪 → 近战反击
			_current_action = BossAction.MELEE
		elif dist < _behavior.kite_ranged_distance and _ranged_cd <= 0:
			# 中近距离 → 剑气反击
			_current_action = BossAction.RANGED
		else:
			_current_action = BossAction.RETREAT
		return

	# 玩家在上方平台：优先跳跃或远程
	var dy = target.global_position.y - global_position.y  # 负 = 玩家在上方
	if dy < -config.boss_jump_height_threshold:
		if is_on_floor() and _jump_cd <= 0 and not _is_jumping:
			_current_action = BossAction.JUMP
			return
		# Phase 3+ 跳跃中 / 悬停中：不覆盖，让悬停系统接管
		if _current_phase >= 3 and (_is_jumping or _is_hovering):
			return
		# 其他情况：拉远距离远程攻击
		_current_action = BossAction.RETREAT if _ranged_cd > 0 else BossAction.RANGED
		return

	# 按阶段路由决策
	_run_phase_decision(dist)

	# 移动类行为设置持续时间，防止每0.3s随机抖动（让Boss有目的地移动）
	match _current_action:
		BossAction.APPROACH: _move_timeout = _behavior.approach_duration
		BossAction.RETREAT:  _move_timeout = _behavior.retreat_duration
		BossAction.IDLE:     _move_timeout = _behavior.idle_duration
		_: _move_timeout = 0.0


func _run_phase_decision(dist: float) -> void:
	var profile := _get_decision_profile()
	if not profile:
		_current_action = BossAction.IDLE
		return
	var roll := randf()
	if profile.hover_chance > 0.0 and _hover_global_cd <= 0 and _jump_cd <= 0 and is_on_floor() and roll < profile.hover_chance:
		_current_action = BossAction.JUMP
		return
	roll = clampf(roll - _get_player_approach_bias(), 0.0, 1.0)
	var actions: PackedStringArray
	var weights: PackedFloat32Array
	if dist > profile.far_distance:
		actions = profile.far_actions
		weights = profile.far_weights
	elif dist > profile.mid_distance:
		actions = profile.mid_actions
		weights = profile.mid_weights
	elif profile.near_distance > 0.0 and dist > profile.near_distance:
		actions = profile.near_actions
		weights = profile.near_weights
	else:
		actions = profile.close_actions
		weights = profile.close_weights
	_current_action = _select_weighted_action(actions, weights, roll)


func _get_decision_profile() -> BossDecisionProfile:
	if _current_phase < 0 or _current_phase >= _behavior.phase_profiles.size():
		return null
	return _behavior.phase_profiles[_current_phase]


func _select_weighted_action(actions: PackedStringArray, weights: PackedFloat32Array, roll: float) -> int:
	if actions.is_empty() or actions.size() != weights.size():
		return BossAction.IDLE
	var cumulative := 0.0
	for i in actions.size():
		cumulative += weights[i]
		if roll < cumulative:
			return _action_from_name(actions[i])
	return _action_from_name(actions[-1])


func _action_from_name(action_name: String) -> int:
	match action_name.to_upper():
		"APPROACH": return BossAction.APPROACH
		"RETREAT": return BossAction.RETREAT
		"RANGED": return BossAction.RANGED
		"MELEE": return BossAction.MELEE
		"EVADE": return BossAction.EVADE
		"JUMP": return BossAction.JUMP
		"HOVER": return BossAction.HOVER
		_: return BossAction.IDLE


# ============================================================
# 行为执行
# ============================================================

func _execute_action(delta: float) -> void:
	var target_vel_x: float = 0.0
	var spd = _get_speed()
	var cd_mult = _get_cd_mult()

	match _current_action:
		BossAction.IDLE:
			pass  # 原地待机

		BossAction.APPROACH:
			# 主动逼近：持续走向玩家，直到进入近战范围（100px内）才停，准备攻击
			if target and is_instance_valid(target):
				var dx = target.global_position.x - global_position.x
				if absf(dx) > _behavior.approach_stop_distance:
					target_vel_x = signf(dx) * spd * _behavior.approach_speed_multiplier
				else:
					_move_timeout = 0.0
					_current_action = BossAction.IDLE

		BossAction.RETREAT:
			# 战术后撤 + 剑气拉扯：退到安全距离，后撤期间持续发射剑气
			if target and is_instance_valid(target):
				var dx = target.global_position.x - global_position.x
				var retreat_max: float = _behavior.kite_retreat_distance if _tempo == CombatTempo.RANGED_KITE else _behavior.normal_retreat_distance
				var retreat_mult: float = _behavior.kite_retreat_speed_multiplier if _tempo == CombatTempo.RANGED_KITE else _behavior.normal_retreat_speed_multiplier
				if absf(dx) < retreat_max:
					target_vel_x = -signf(dx) * spd * retreat_mult
					# 拉扯期间持续剑气（受 CD 限制）
					if _ranged_cd <= 0:
						_fire_sword()
						_ranged_cd = config.boss_ranged_cooldown * cd_mult
				else:
					# 拉扯模式下保持距离继续攻击，普通模式则停止
					if _tempo == CombatTempo.RANGED_KITE:
						if _ranged_cd <= 0:
							_fire_sword()
							_ranged_cd = config.boss_ranged_cooldown * cd_mult
					else:
						_move_timeout = 0.0
						_current_action = BossAction.IDLE

		BossAction.RANGED:
			if _ranged_cd <= 0:
				# 锁定朝向为玩家方向（攻击期间不可转向）
				if target and is_instance_valid(target):
					is_facing_right = (target.global_position.x > global_position.x)
					if _sprite: _sprite.flip_h = not is_facing_right
				_fire_sword()
				_ranged_cd = config.boss_ranged_cooldown * cd_mult
				_action_lock = _behavior.ranged_action_lock

		BossAction.MELEE:
			if _melee_cd <= 0 and not _melee_active:
				# 启动时锁定朝向为玩家方向（攻击期间不可转向，完整完成此次攻击）
				if target and is_instance_valid(target):
					is_facing_right = (target.global_position.x > global_position.x)
					if _sprite: _sprite.flip_h = not is_facing_right
				# 只在攻击启动前逼近一步，动画期间原地不动
				if target and is_instance_valid(target):
					var dx = target.global_position.x - global_position.x
					if absf(dx) > _behavior.melee_approach_distance:
						target_vel_x = signf(dx) * spd
				_melee_elapsed = 0.0
				_melee_hit_done = false
				_melee_active = true
				_melee_cd = config.boss_melee_cooldown * cd_mult
				_action_lock = config.boss_melee_total_frames / config.boss_attack_fps
				# Phase 4: 近战攻击额外发射一道剑气
				if _current_phase >= 4:
					_fire_sword_from_melee()

		BossAction.EVADE:
			target_vel_x = _evade_dir * spd * _behavior.evade_speed_multiplier
			if _evade_timer <= 0:
				_current_action = BossAction.IDLE
				_action_lock = 0.0

		BossAction.JUMP:
			if is_on_floor() and not _is_jumping:
				velocity.y = _get_jump_velocity()
				_is_jumping = true
				_jump_cd = config.boss_jump_cooldown
				_action_lock = _behavior.jump_action_lock
				if target and is_instance_valid(target):
					target_vel_x = signf(target.global_position.x - global_position.x) * spd
			else:
				# 空中：朝玩家方向移动（Phase 3 悬停由 _physics_process 前置处理）
				if target and is_instance_valid(target):
					target_vel_x = signf(target.global_position.x - global_position.x) * spd * _behavior.airborne_horizontal_speed_multiplier

		BossAction.HOVER:
			# 悬停逻辑由 _physics_process 中 _is_hovering 块统一处理
			pass

	# 平滑速度（防瞬移/抖动）
	velocity.x = move_toward(velocity.x, target_vel_x, spd * _behavior.movement_acceleration_multiplier * delta)


# ============================================================
# 剑气发射
# ============================================================

func _fire_sword() -> void:
	if not _sword_scene: return
	if not target or not is_instance_valid(target): return
	var count = _behavior.ground_projectile_count
	if _current_phase >= 3: count = _behavior.empowered_projectile_count
	var dmg = _get_ranged_dmg()
	var base_angle = (target.global_position - global_position).angle()
	# 扇形散布角度（弧度）：3发时 -12°/0°/+12°，形成区域压制
	var spreads = _behavior.projectile_spread_angles
	for i in count:
		var s = _sword_scene.instantiate()
		var ang = base_angle + (spreads[i] if count > 1 else 0.0)
		var dir = Vector2(cos(ang), sin(ang))
		# 生成点沿散布方向偏移，并垂直拉开避免重叠
		var spawn_pos = global_position + Vector2(
			dir.x * _behavior.projectile_forward_offset,
			_behavior.projectile_vertical_start + i * _behavior.projectile_vertical_step
		)
		get_parent().add_child(s)
		s.global_position = spawn_pos
		if s.has_method("setup_by_dir"):
			s.setup_by_dir(dir, dmg, config.boss_projectile_speed, config.boss_projectile_max_lifetime, self)
		else:
			s.setup(target.global_position, dmg, config.boss_projectile_speed, config.boss_projectile_max_lifetime, self)


## Phase 4: 近战攻击时额外发射一道剑气
func _fire_sword_from_melee() -> void:
	if not _sword_scene: return
	if not target or not is_instance_valid(target): return
	var dir = Vector2(1.0 if is_facing_right else -1.0, _behavior.melee_projectile_vertical_direction).normalized()
	var s = _sword_scene.instantiate()
	var spawn_pos = global_position + Vector2(
		dir.x * _behavior.melee_projectile_forward_offset,
		_behavior.melee_projectile_vertical_offset
	)
	get_parent().add_child(s)
	s.global_position = spawn_pos
	s.setup(target.global_position, _get_ranged_dmg(), config.boss_projectile_speed, config.boss_projectile_max_lifetime, self)


# ============================================================
# 近战攻击盒
# ============================================================

func _activate_melee_hitbox(active: bool) -> void:
	if not _melee_hitbox: return
	_melee_hitbox.monitoring = active
	for c in _melee_hitbox.get_children():
		if c is CollisionShape2D:
			c.disabled = not active
	if active:
		# hitbox 覆盖 Boss 自身到前方挥砍范围（偏移 65, 宽度 120 → 覆盖 5~125px）
		_melee_hitbox.position = Vector2(_behavior.melee_hitbox_offset if is_facing_right else -_behavior.melee_hitbox_offset, 0)
	# 关闭由 _physics_process 近战计时统一控制


## hitbox激活期间每帧主动检测重叠玩家（body_entered对"已在范围内"的玩家不触发）
func _check_melee_overlap() -> void:
	if not _melee_hitbox or not _melee_hitbox.monitoring: return
	for body in _melee_hitbox.get_overlapping_bodies():
		_on_melee_body_entered(body)


## 近战命中回调：对玩家造成近战伤害 + 击退
func _on_melee_body_entered(body: Node2D) -> void:
	if is_dead: return
	if not is_instance_valid(body): return
	# 用独立的 _melee_damage_dealt 防多次命中（不再检查 _melee_hit_done，那是hitbox时序标记）
	if not _melee_active or _melee_damage_dealt:
		return
	# 只命中玩家（GameManager.player_ref 或具备 take_damage 的 PlayerBase）
	if body != GameManager.player_ref and not (body is PlayerBase):
		return
	if body.has_method("take_damage"):
		_melee_damage_dealt = true  # 标记已命中，防同次攻击多次触发
		var kb = (body.global_position - global_position).normalized()
		# 击退增强：近战击退更明显
		if kb == Vector2.ZERO:
			kb = Vector2(1.0 if is_facing_right else -1.0, 0.0)
		body.take_damage(_get_melee_dmg(), kb, self)


# ============================================================
# 朝向（滞后死区防频闪）
# ============================================================

func _update_facing() -> void:
	# 近战攻击期间锁定朝向（攻击开始时已锁定方向，完整完成此次攻击前不可转向）
	if _melee_active:
		return
	# 远程攻击动作期间也锁定朝向
	if _current_action == BossAction.RANGED and _action_lock > 0:
		return
	if target and is_instance_valid(target):
		var dx = target.global_position.x - global_position.x
		if dx > config.boss_facing_dead_zone:
			is_facing_right = true
		elif dx < -config.boss_facing_dead_zone:
			is_facing_right = false
	if _sprite:
		_sprite.flip_h = not is_facing_right


# ============================================================
# 动画
# ============================================================

func _update_anim() -> void:
	if not _sprite or not _sprite.sprite_frames: return
	if _huadan_stun_timer > 0:
		_hold_huadan_stun_animation()
		return
	var anim = "idle"
	match _current_action:
		BossAction.IDLE:     anim = "idle"
		BossAction.APPROACH: anim = "walk"
		BossAction.RETREAT:  anim = "walk"
		BossAction.RANGED:   anim = "idle"     # 剑气不播攻击动作，弹体本身是特效
		BossAction.MELEE:    anim = "attack" if _melee_active else "walk"
		BossAction.EVADE:    anim = "walk"
		BossAction.JUMP:     anim = "walk"
		BossAction.HOVER:    anim = "hang_in_air"  # 悬空释放剑气专用帧
	# 悬空帧(1024x1024)需要更小的scale匹配其他动画(128x128/256x256)的视觉尺寸
	if anim == "hang_in_air":
		_sprite.scale = Vector2(HOVER_SPRITE_SCALE, HOVER_SPRITE_SCALE)
	else:
		_sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	_sprite.offset = Vector2(0, 10)
	# 仅在真近战攻击中才重启attack动画（不自动循环）
	if _sprite.animation != anim or (anim == "attack" and not _sprite.is_playing() and _melee_active):
		_sprite.frame = 0
		_sprite.play(anim)

func _hold_huadan_stun_animation() -> void:
	if not _sprite or not _sprite.sprite_frames or not _sprite.sprite_frames.has_animation("dizziness"):
		return
	_sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	_sprite.offset = Vector2(0, 10)
	if _sprite.animation != "dizziness":
		_sprite.frame = 0
		_sprite.play("dizziness")
	var last_frame := _sprite.sprite_frames.get_frame_count("dizziness") - 1
	if last_frame >= 0 and _sprite.frame >= last_frame:
		_sprite.frame = last_frame
		_sprite.pause()

func die() -> void:
	if is_dead:
		return
	_change_state(GlobalDefine.EnemyState.DEAD)
	is_dead = true
	GameManager.unregister_enemy(self)
	set_physics_process(false)
	_activate_melee_hitbox(false)
	_on_die()
	EventBus.emit(GlobalDefine.EventName.ENEMY_DIED, {
		"enemy": self,
		"exp_reward": config.exp_reward
	})
	if _sprite and _sprite.sprite_frames and _sprite.sprite_frames.has_animation("defeated"):
		modulate = Color.WHITE
		_sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
		_sprite.offset = Vector2(0, 10)
		_sprite.play("defeated")
		var frames := _sprite.sprite_frames.get_frame_count("defeated")
		var speed := maxf(_sprite.sprite_frames.get_animation_speed("defeated"), 1.0)
		var wait_time := maxf(float(frames) / speed, 0.5)
		get_tree().create_timer(wait_time).timeout.connect(queue_free)
	else:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 0), config.death_fade_duration)
		tween.tween_callback(queue_free)


# ============================================================
# 无接触伤害（由剑气/近战盒负责）
# ============================================================

func deals_contact_damage() -> bool:
	return false

# ---- 攻击锁定：近战攻击期间禁止转向与移动 ----

func _is_attack_locked() -> bool:
	return _melee_active
