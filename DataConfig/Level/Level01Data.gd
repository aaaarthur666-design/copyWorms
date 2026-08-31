# res://DataConfig/Level/Level01Data.gd
class_name Level01Data
extends Resource

@export_category("Obstacle Narrative")
@export_multiline var obstacle_1_text: String = ""
@export_multiline var obstacle_2_text: String = ""

@export_category("Bed Sleep Cycles")
@export var sleep_texts: Array[String] = []

@export_category("AI IDE Dialogues")
## 与 ide_texts 一一对应: "System" / "AI" / "Ming"
@export var ide_speakers: Array[String] = []
## 与 ide_speakers 一一对应，每条对话的文本内容
@export_multiline var ide_texts: Array[String] = []

@export_category("Bedroom Detail Objects")
@export_multiline var notice_text: String = ""
@export_multiline var thermos_text: String = ""

@export_category("Phone Climax")
@export_multiline var phone_sender: String = ""
@export_multiline var phone_content: String = ""
@export_multiline var climax_monologue: String = ""

@export_category("Gameplay Tuning")
@export var code_scroll_speed: float = 0.12
@export var narrative_input_timeout: float = 30.0
@export_multiline var idle_bed_prompt_text: String = "没什么事做。\n还是继续睡吧。"
@export var idle_bed_prompt_delay: float = 2.0
@export var computer_unlock_sleep_count: int = 3
@export var ide_preview_timeout: float = 8.0
@export var move_speed_multiplier: float = 0.5
@export var normal_move_speed_multiplier: float = 1.0
@export var final_blackout_duration: float = 4.0
@export var final_blackout_fade_duration: float = 0.8
@export var final_glitch_duration: float = 2.0
@export var camera_zoom: Vector2 = Vector2(2.0, 2.0)
@export var camera_lerp_speed: float = 2.5
@export var interaction_cooldown: float = 0.3
@export var interaction_recovery_threshold: float = 0.5
@export var narrative_input_arm_delay: float = 0.3
@export var narrative_poll_interval: float = 0.05
@export var obstacle_fade_duration: float = 0.5
@export var sleep_fade_duration: float = 1.0
@export var sleep_blink_count: int = 5
@export var sleep_blink_alpha_start: float = 0.5
@export var sleep_blink_alpha_step: float = 0.08
@export var sleep_blink_interval: float = 2.0
@export var sleep_blink_dim_duration: float = 0.8
@export var sleep_blink_hold_duration: float = 0.3
@export var sleep_blink_recover_duration: float = 0.6
@export var sleep_final_interval: float = 2.0
@export var sleep_final_alpha: float = 0.9
@export var sleep_final_dim_duration: float = 1.2
@export var sleep_final_hold_duration: float = 0.5
@export var sleep_final_recover_duration: float = 0.8
@export var ide_crash_message_duration: float = 1.5
@export var next_level_path: String = "res://LevelModule/Formal/Level_02.tscn"
