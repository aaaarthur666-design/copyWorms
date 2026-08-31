extends Resource
class_name DreamRuntimeState

## 跨关卡运行时状态的单一入口。已知键做类型校验，未知键仍保留，
## 以兼容赛题发布后临时增加的实验状态。
const VALUE_TYPES: Dictionary = {
	&"player_damage_reduction": TYPE_BOOL,
	&"base_jump_height": TYPE_INT,
	&"allow_external_signal": TYPE_BOOL,
	&"dream_version": TYPE_STRING,
	&"erosion_value": TYPE_FLOAT,
	&"player_health": TYPE_INT,
	&"player_max_health": TYPE_INT,
	&"memory_recovery_started": TYPE_BOOL,
	&"level0203_resume_reality": TYPE_BOOL,
	&"memory_return_reason": TYPE_STRING,
	&"memory_current_area": TYPE_INT,
	&"fuzhan_01_collected": TYPE_INT,
	&"fuzhan_02_collected": TYPE_INT,
	&"fuzhan_01_complete": TYPE_BOOL,
	&"fuzhan_02_complete": TYPE_BOOL,
	&"memory_fragments": TYPE_INT,
	&"core_memory_anchor_stabilized": TYPE_BOOL,
	&"core_area": TYPE_STRING,
}

var _values: Dictionary = {}


func replace_from(values: Dictionary, report_error: bool = true) -> bool:
	var validated: Dictionary = {}
	for raw_key: Variant in values:
		var key := StringName(str(raw_key))
		var normalized: Variant = _normalize_value(key, values[raw_key], report_error)
		if normalized == null and values[raw_key] != null:
			return false
		validated[key] = normalized
	_values = validated
	return true


func merge_from(values: Dictionary, report_error: bool = true) -> bool:
	var merged: Dictionary = _values.duplicate(true)
	for raw_key: Variant in values:
		merged[StringName(str(raw_key))] = values[raw_key]
	return replace_from(merged, report_error)


func set_value(key: StringName, value: Variant, report_error: bool = true) -> bool:
	var normalized: Variant = _normalize_value(key, value, report_error)
	if normalized == null and value != null:
		return false
	_values[key] = normalized
	return true


func get_value(key: StringName, fallback: Variant = null) -> Variant:
	return _values.get(key, fallback)


func has_value(key: StringName) -> bool:
	return _values.has(key)


func erase_value(key: StringName) -> void:
	_values.erase(key)


func is_empty() -> bool:
	return _values.is_empty()


func to_dictionary() -> Dictionary:
	return _values.duplicate(true)


func clear() -> void:
	_values.clear()


func incoming_damage_multiplier() -> float:
	return 0.5 if bool(get_value(&"player_damage_reduction", false)) else 1.0


func has_enhanced_jump() -> bool:
	return int(get_value(&"base_jump_height", 10)) > 50


func erosion_value() -> float:
	return float(get_value(&"erosion_value", 0.0))


func _normalize_value(key: StringName, value: Variant, report_error: bool) -> Variant:
	if not VALUE_TYPES.has(key):
		return value
	var expected: int = int(VALUE_TYPES[key])
	if expected == TYPE_FLOAT and typeof(value) == TYPE_INT:
		return float(value)
	if typeof(value) != expected:
		if report_error:
			push_error("[DreamRuntimeState] '%s' 类型错误：期望 %s，实际 %s" % [
				key,
				type_string(expected),
				type_string(typeof(value)),
			])
		return null
	return value
