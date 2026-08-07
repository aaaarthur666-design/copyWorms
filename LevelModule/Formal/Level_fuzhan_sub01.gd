extends Node
class_name LevelFuzhanSub01

const LEVEL_02_03_PATH := "res://LevelModule/Formal/Level_02_03.tscn"
const FUZHAN_01_PATH := "res://LevelModule/Formal/Level_fuzhan_01.tscn"
const FUZHAN_02_PATH := "res://LevelModule/Formal/Level_fuzhan_02.tscn"
const LEVEL_02_BGM_PATH := "res://Assets/Music/2 test-2.ogg"
const NIGHTFALL_BGM_PATH := "res://Assets/Music/Nightfall.mp3"

const KEY_STARTED := "memory_recovery_started"
const KEY_RESUME_REALITY := "level0203_resume_reality"
const KEY_RETURN_REASON := "memory_return_reason"
const KEY_CURRENT_AREA := "memory_current_area"
const KEY_FUZHAN_01_COLLECTED := "fuzhan_01_collected"
const KEY_FUZHAN_02_COLLECTED := "fuzhan_02_collected"
const KEY_FUZHAN_01_COMPLETE := "fuzhan_01_complete"
const KEY_FUZHAN_02_COMPLETE := "fuzhan_02_complete"
const KEY_MEMORY_FRAGMENTS := "memory_fragments"
const KEY_CORE_STABILIZED := "core_memory_anchor_stabilized"

const REQUIRED_PER_AREA := 3
const REQUIRED_TOTAL := 6
const KILLS_PER_DROP := 10
const DROP_TYPES: Array[String] = ["Mooncake", "Har Gow", "Kapok Flower", "Awakening Lion", "Siu Mai", "Palm-Leaf Fan"]

const RETURN_NONE := ""
const RETURN_FUZHAN_01_COMPLETE := "fuzhan_01_complete"
const RETURN_FUZHAN_01_FAILED := "fuzhan_01_failed"
const RETURN_FUZHAN_02_COMPLETE := "fuzhan_02_complete"
const RETURN_FUZHAN_02_FAILED := "fuzhan_02_failed"

const WAKE_MONOLOGUE := "...This ceiling again.\nThe rift in the dream, the shadows, and that message.\n\nI thought if I rebuilt the old street, I could return to Grandpa.\nBut I can't even reach the herbal tea shop.\n\nMaybe the dream isn't the incomplete part.\nMaybe my memories are."
const FUZHAN_01_COMPLETE_REALITY := "I'm back.\nBut those memories haven't scattered.\n\nThey're still here.\nAs if I carried them out of the dream in the palm of my hand."
const FUZHAN_01_FAILED_REALITY := "...Awake again.\nThe feeling I just recovered is fading.\n\nNo.\nThis isn't something I can finish by casually picking up a few objects.\nI have to go back in.\nUntil these memories truly stabilize."
const FUZHAN_02_COMPLETE_REALITY := "...I'm back.\nBut this time is different.\n\nI didn't wake up empty-handed.\nI brought back everything I had almost forgotten.\n\nHe's there in those tiny memories.\nNow I can finally go see him."
const FUZHAN_02_FAILED_REALITY := "It isn't enough.\nI almost remembered just now.\n\nThose things are right in front of me.\nI can't stop here."

const FUZHAN_01_ENTER_TEXT := "Xiguan Dream: Memory Recovery Mode\n\nTarget Area 01: level_fuzhan_01\nObjective: defeat hostile entities and recover 3 childhood memory fragments.\n\nMap structure preserved.\nDeeper memories await restoration..."
const FUZHAN_02_ENTER_TEXT := "Xiguan Dream: Memory Recovery Mode\n\nTarget Area 02: level_fuzhan_02\nSource map: Level_02_01\nObjective: defeat hostile entities and recover 3 childhood memory fragments.\n\nTotal progress: 3 / 6\nSynchronizing memory core..."

const FUZHAN_01_INTRO := "This place is the same as before.\nThe Manchu windows, the attic, the light on the old street.\n\nThis time, I'm not here to hide.\nI'm going to recover those scattered childhood memories, one by one.\n\nOnly then can I truly stand before Grandpa."
const FUZHAN_02_INTRO := "This is another path.\nI used to run this way to find Grandpa.\n\nThree more.\nOnce I recover three more memory fragments, I can see him.\n\nNot an empty shell.\nI'll see him carrying everything I truly remember."

const FUZHAN_01_DROP_READY := "Memory fluctuation increasing.\nChildhood memory condensing...\n\nChildhood memory fragment manifested.\nRecover it."
const FUZHAN_02_DROP_READY := "A memory echo is approaching.\nChildhood memory condensing...\n\nChildhood memory fragment manifested.\nRecover it."

const FUZHAN_01_COMPLETE_FIELD := "That's enough.\nI've recovered the memories of this part of the old street.\n\nThere are other places.\nMore things I almost forgot."
const FUZHAN_02_COMPLETE_FIELD := "I've finally collected them all. Nothing can stop me now."

const FUZHAN_01_FAILED_FIELD := "Consciousness stability declining.\nMemory recovery interrupted."
const FUZHAN_02_FAILED_FIELD := "Consciousness stability declining.\nMemory recovery interrupted in the second target area."


static func ensure_state() -> Dictionary:
	var flags := GameManager.dream_runtime_flags
	if not flags.has(KEY_STARTED):
		flags[KEY_STARTED] = false
	if not flags.has(KEY_RESUME_REALITY):
		flags[KEY_RESUME_REALITY] = false
	if not flags.has(KEY_RETURN_REASON):
		flags[KEY_RETURN_REASON] = RETURN_NONE
	if not flags.has(KEY_CURRENT_AREA):
		flags[KEY_CURRENT_AREA] = 1
	if not flags.has(KEY_FUZHAN_01_COLLECTED):
		flags[KEY_FUZHAN_01_COLLECTED] = 0
	if not flags.has(KEY_FUZHAN_02_COLLECTED):
		flags[KEY_FUZHAN_02_COLLECTED] = 0
	if not flags.has(KEY_FUZHAN_01_COMPLETE):
		flags[KEY_FUZHAN_01_COMPLETE] = false
	if not flags.has(KEY_FUZHAN_02_COMPLETE):
		flags[KEY_FUZHAN_02_COMPLETE] = false
	_recalculate_total(flags)
	GameManager.dream_runtime_flags = flags
	return flags


static func start_flow() -> void:
	var flags := ensure_state()
	flags[KEY_STARTED] = true
	flags[KEY_CURRENT_AREA] = current_target_area()
	GameManager.dream_runtime_flags = flags


static func should_resume_reality() -> bool:
	return bool(ensure_state().get(KEY_RESUME_REALITY, false))


static func consume_return_reason() -> String:
	var flags := ensure_state()
	var reason := str(flags.get(KEY_RETURN_REASON, RETURN_NONE))
	flags[KEY_RETURN_REASON] = RETURN_NONE
	flags[KEY_RESUME_REALITY] = false
	GameManager.dream_runtime_flags = flags
	return reason


static func current_target_area() -> int:
	var flags := ensure_state()
	if not bool(flags.get(KEY_FUZHAN_01_COMPLETE, false)):
		return 1
	if not bool(flags.get(KEY_FUZHAN_02_COMPLETE, false)):
		return 2
	return 0


static func area_scene_path(area: int) -> String:
	return FUZHAN_01_PATH if area == 1 else FUZHAN_02_PATH


static func enter_text(area: int) -> String:
	return FUZHAN_01_ENTER_TEXT if area == 1 else FUZHAN_02_ENTER_TEXT


static func intro_text(area: int) -> String:
	return FUZHAN_01_INTRO if area == 1 else FUZHAN_02_INTRO


static func drop_ready_text(area: int) -> String:
	return FUZHAN_01_DROP_READY if area == 1 else FUZHAN_02_DROP_READY


static func field_complete_text(area: int) -> String:
	return FUZHAN_01_COMPLETE_FIELD if area == 1 else FUZHAN_02_COMPLETE_FIELD


static func field_failed_text(area: int) -> String:
	return FUZHAN_01_FAILED_FIELD if area == 1 else FUZHAN_02_FAILED_FIELD


static func area_collected(area: int) -> int:
	var flags := ensure_state()
	return int(flags.get(KEY_FUZHAN_01_COLLECTED if area == 1 else KEY_FUZHAN_02_COLLECTED, 0))


static func total_fragments() -> int:
	return int(ensure_state().get(KEY_MEMORY_FRAGMENTS, 0))


static func add_fragment(area: int) -> int:
	var flags := ensure_state()
	var key := KEY_FUZHAN_01_COLLECTED if area == 1 else KEY_FUZHAN_02_COLLECTED
	var value := mini(int(flags.get(key, 0)) + 1, REQUIRED_PER_AREA)
	flags[key] = value
	if value >= REQUIRED_PER_AREA:
		if area == 1:
			flags[KEY_FUZHAN_01_COMPLETE] = true
		else:
			flags[KEY_FUZHAN_02_COMPLETE] = true
	_recalculate_total(flags)
	if int(flags[KEY_MEMORY_FRAGMENTS]) >= REQUIRED_TOTAL:
		flags[KEY_CORE_STABILIZED] = true
	GameManager.dream_runtime_flags = flags
	return value


static func can_open_config() -> bool:
	var flags := ensure_state()
	return int(flags.get(KEY_MEMORY_FRAGMENTS, 0)) >= REQUIRED_TOTAL \
		and bool(flags.get(KEY_FUZHAN_01_COMPLETE, false)) \
		and bool(flags.get(KEY_FUZHAN_02_COMPLETE, false))


static func request_return_to_reality(area: int, completed: bool) -> void:
	var flags := ensure_state()
	flags[KEY_RESUME_REALITY] = true
	if area == 1:
		flags[KEY_RETURN_REASON] = RETURN_FUZHAN_01_COMPLETE if completed else RETURN_FUZHAN_01_FAILED
	else:
		flags[KEY_RETURN_REASON] = RETURN_FUZHAN_02_COMPLETE if completed else RETURN_FUZHAN_02_FAILED
	flags[KEY_CURRENT_AREA] = current_target_area()
	GameManager.dream_runtime_flags = flags


static func reality_return_text(reason: String) -> String:
	match reason:
		RETURN_FUZHAN_01_COMPLETE:
			return FUZHAN_01_COMPLETE_REALITY
		RETURN_FUZHAN_01_FAILED:
			return FUZHAN_01_FAILED_REALITY
		RETURN_FUZHAN_02_COMPLETE:
			return FUZHAN_02_COMPLETE_REALITY
		RETURN_FUZHAN_02_FAILED:
			return FUZHAN_02_FAILED_REALITY
	return ""


static func free_chat_prompt() -> String:
	var total := total_fragments()
	if can_open_config():
		return "CodeBuddy: Memory samples complete. Enter /config to open the configuration editor."
	if current_target_area() == 2:
		return "CodeBuddy: Second target area ready.\nCurrent progress: %d / 6.\nEnter /memory to access level_fuzhan_02." % total
	return "CodeBuddy: Childhood Memory Restoration Process ready.\nCurrent progress: %d / 6.\nEnter /memory to access a memory-recovery combat area.\nThe configuration editor will unlock after you recover 6 childhood memory fragments." % total


static func config_locked_prompt() -> String:
	var total := total_fragments()
	var area := current_target_area()
	var area_name := "level_fuzhan_01" if area == 1 else "level_fuzhan_02"
	return "CodeBuddy: Insufficient memory anchors.\nThe configuration editor is not yet available.\nComplete the Childhood Memory Restoration Process first: %d / 6.\n\nHint: enter /memory to access %s." % [total, area_name]


static func memory_launch_prompt(area: int) -> String:
	var area_name := "level_fuzhan_01" if area == 1 else "level_fuzhan_02"
	return "CodeBuddy: Initiating Memory Recovery Mode.\nTarget area: %s.\nObjective: recover 3 childhood memory fragments." % area_name


static func ide_speakers_for_stage(default_speakers: Array[String]) -> Array[String]:
	if not bool(ensure_state().get(KEY_STARTED, false)):
		return default_speakers
	if can_open_config():
		return ["System", "CodeBuddy", "Ming", "CodeBuddy", "Ming", "CodeBuddy", "System"]
	if bool(ensure_state().get(KEY_FUZHAN_01_COMPLETE, false)):
		return ["System", "CodeBuddy", "Ming", "CodeBuddy", "Ming", "CodeBuddy", "System"]
	return ["CodeBuddy"]


static func ide_texts_for_stage(default_texts: Array[String]) -> Array[String]:
	var flags := ensure_state()
	if not bool(flags.get(KEY_STARTED, false)):
		return default_texts
	if can_open_config():
		return [
			"Memory Recovery Complete.\nRecovered Memory Fragments: 6 / 6.\nCore Area Access: Unlocked.",
			"Childhood Memory Restoration Process complete.\n6 stable memory samples detected.\nGeneration fidelity for the core area, “Herbal Tea Shop,” has increased.",
			"Finally. I can see Grandpa now? Nothing else is going to interfere this time, right?",
			"You may now enter the deeper dream.\nHowever, please note:\nOnce you enter, you will be unable to leave.\nAs requested, I have sealed the environment.\nThere is no way back.",
			"I don't care.\nLet me see him!\nDon't let anything from the outside interfere this time! Let me reach Grandpa without anything getting in the way!",
			"Understood.\nThe configuration editor is now available.\nYou may continue modifying the dream parameters.\nAfter recompilation, you will enter the core area: Herbal Tea Shop.",
			"Configuration editor unlocked.\nAwaiting input...",
		]
	if bool(flags.get(KEY_FUZHAN_01_COMPLETE, false)):
		return [
			"Area 01 Memory Recovery Complete.\nRecovered Memory Fragments: 3 / 6.",
			"Recovery complete in first target area, level_fuzhan_01.\nThe first half of your childhood memories has stabilized.\nHowever, the core path to the herbal tea shop remains locked.",
			"There's still another half, right?",
			"Yes.\nThe remaining memory samples are located in the second target area: level_fuzhan_02.\n\nThis area corresponds to a deeper path through your childhood.\nIts source map is Level_02_01.\nThe map structure will remain unchanged after entry.\nHowever, hostile entities may be stronger.",
			"I have to go back there again...",
			"Second target area ready.\nObjective: recover 3 more childhood memory fragments.\nOnce complete, the entrance to the deeper dream will open.\nYou will then be able to modify the configuration and proceed to the “Herbal Tea Shop.”",
			"Target Area 02: level_fuzhan_02\nSource Map: Level_02_01\nRequired Memory Fragments: 3 / 3\nPreparing Local Dream Viewport...",
		]
	var reason := str(flags.get(KEY_RETURN_REASON, RETURN_NONE))
	if reason == RETURN_FUZHAN_01_FAILED:
		return ["Consciousness interruption detected.\nMemory samples in level_fuzhan_01 have not fully stabilized.\nPlease re-enter the area and recover 3 childhood memory fragments."]
	if reason == RETURN_FUZHAN_02_FAILED:
		return ["Recovery failure detected in level_fuzhan_02.\nMemory samples in the current area have not fully stabilized.\nPlease re-enter and recover 3 childhood memory fragments."]
	return default_texts


static func ide_speakers_for_return_reason(reason: String) -> Array[String]:
	match reason:
		RETURN_FUZHAN_01_FAILED, RETURN_FUZHAN_02_FAILED:
			return ["CodeBuddy"]
	return []


static func ide_texts_for_return_reason(reason: String) -> Array[String]:
	match reason:
		RETURN_FUZHAN_01_FAILED:
			return ["Consciousness interruption detected.\nMemory samples in level_fuzhan_01 have not fully stabilized.\nPlease re-enter the area and recover 3 childhood memory fragments."]
		RETURN_FUZHAN_02_FAILED:
			return ["Recovery failure detected in level_fuzhan_02.\nMemory samples in the current area have not fully stabilized.\nPlease re-enter and recover 3 childhood memory fragments."]
	return []


static func apply_core_flags() -> void:
	var flags := ensure_state()
	flags["memory_fragments"] = REQUIRED_TOTAL
	flags["core_memory_anchor_stabilized"] = true
	flags["fuzhan_01_complete"] = true
	flags["fuzhan_02_complete"] = true
	flags["core_area"] = "herbal_tea_shop"
	GameManager.dream_runtime_flags = flags


static func _recalculate_total(flags: Dictionary) -> void:
	flags[KEY_MEMORY_FRAGMENTS] = int(flags.get(KEY_FUZHAN_01_COLLECTED, 0)) + int(flags.get(KEY_FUZHAN_02_COLLECTED, 0))
