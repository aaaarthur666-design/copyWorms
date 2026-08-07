# In-Game Text Inventory (English Version)

> Purpose: Establish the English translation baseline for the `English-version` branch.
>
> Scope: Player-visible interaction text, narrative/dialogue, menus and controls, HUD/skill/status text, archive entries, and the separately listed test-interface text used in the main game flow.
>
> This document only extracts, translates, and categorizes text. It does not modify the original game files.

## 1. Main Menu and Global Interfaces

### 1.1 Title Screen

Source file: `UI/TitleScreen.tscn`

| Node/Purpose | English Text |
|---|---|
| Main title (large title; retained as requested) | `织梦者` |
| English subtitle | `DREAM BUILDER` |
| Chinese subtitle | `Weave a Dream of Home with Your Own Hands` |
| Main mode button | `Start Game (Story Mode)` |
| highlights button | `Start from Highlights` |
| Settings button | `Settings (Key Bindings)` |
| Quit button | `Quit Game` |

Source file: `UI/TitleScreen.gd`

- `For the web version, simply close this browser tab.`

### 1.2 Pause and Game Over Screens

Source file: `UI/HUD.gd`

| Purpose | English Text |
|---|---|
| Pause title | `Game Paused` |
| Pause button | `Resume` |
| Pause button | `Key Bindings` |
| Pause button | `Return to Main Menu` |
| Failure title | `Game Over` |
| Failure button | `Restart` |
| Failure button | `Return to Main Menu` |

### 1.3 Key Binding Screen

Source file: `UI/KeybindSettingsScreen.gd`

| Purpose | English Text |
|---|---|
| Title | `Key Bindings` |
| Instructions | `Click [Change], then press a new key. Press ESC to cancel.` |
| Bottom button | `Restore Defaults` |
| Bottom button | `Back` |
| Binding button | `Change` |
| Unbound state | `Unbound` |
| Waiting-for-input state | `< Press a key... (ESC to cancel) >` |

Source file: `Global/KeybindManager.gd`

Action display names:

- `Attack`
- `Dodge`
- `Skill`
- `Skill 2`
- `Jump`
- `Move Left`
- `Move Right`
- `Move Up`
- `Move Down`

Mouse/controller display names and dynamic formats:

- `Left Mouse Button`
- `Right Mouse Button`
- `Middle Mouse Button`
- `Mouse Wheel Up`
- `Mouse Wheel Down`
- `Mouse Wheel Left`
- `Mouse Wheel Right`
- `Mouse Side Button 1`
- `Mouse Side Button 2`
- `Mouse Button %d`
- `Controller A`
- `Controller B`
- `Controller X`
- `Controller Y`
- `Controller Select`
- `Controller Start`
- `Controller LB`
- `Controller RB`
- `Controller Button %d`
- `Left Stick Left` / `Left Stick Right` / `Left Stick Up` / `Left Stick Down`
- `Right Stick Left` / `Right Stick Right` / `Right Stick Up` / `Right Stick Down`
- `Axis %d`

## 2. HUD, Skills, and Combat Status Text

### 2.1 General HUD

Source file: `UI/HUD.gd`

| Purpose | English Text/Format |
|---|---|
| Initial health | `100 / 100` |
| Dynamic health | `%d / %d` |
| Initial timer | `00:00.00` |
| Dynamic timer | `%02d:%02d.%02d` |
| Skill 1 text label | `Skill 1` |
| Skill 2 text label | `Skill 2` |
| Charged attack text label | `Charge` |
| Cooldown in seconds | `%.1f` |
| Skill-key format | `[%s]` |

### 2.2 Skill Names

Source file: `DataConfig/Skill/SlashConfig.tres`

- `Horizontal Slash`

Source file: `DataConfig/Skill/SkillConfig.gd` (default fallback for the resource field)

- `Unnamed Skill`

### 2.3 Corruption and Boss HUD

Source file: `LevelModule/Formal/Level_04.gd`

- `Corruption 0%`
- `Corruption %.0f%%`

Source file: `LevelModule/Formal/Level_05.gd`

- `Corruption %.0f%%`
- `Huadan`
- `Huadan  %d / %d`
- `Poise`
- `Poise Broken`
- `Press G to Switch Character Appearance`

### 2.4 Memory-Recovery Battle Progress HUD

Source file: `LevelModule/Formal/Level_fuzhan_memory_base.gd`

- `Memory Recovery Area %02d  %d / %d    Enemies Defeated %d / %d`

## 3. General Interaction and Control Prompts

### 3.1 Level 2 and the Real-World Room

Source files: `LevelModule/Formal/Level_02.tscn`, `LevelModule/Formal/Level_02_SceneBuilder.gd`

- `Press Enter to Observe`
- `Press Enter to Push Open`
- `Press Enter to Remember`
- `Press Enter to Call Out`

Source file: `LevelModule/Formal/Level_02_sub01.tscn`

- `Press Enter to Examine`
- `Press Enter to Use`
- `Press Enter to Enter the Dream`

Source file: `LevelModule/Formal/Level_02.gd`

- `[%s] Jump    [%s] Attack    [%s] Dash    [%s] Skill`

Source file: `LevelModule/Formal/Level_02_03.gd`

- `Hold [Tab] to Open Your Eyes`
- `Press Enter to Confirm Dialogue...`
- `Type a message and press Enter to send...`

Source file: `LevelModule/Formal/Ladder.gd`

- `W Up`
- `S Down`

### 3.2 Levels 3–5

Source files: `LevelModule/Formal/Level_03.tscn`, `LevelModule/Formal/Level_03_SceneBuilder.gd`

- `Press Enter to Talk to Grandpa`
- `Press Enter to Touch the Memory`
- `[Error_Data: Immediate deletion recommended]`

Source file: `LevelModule/Formal/Level_04.tscn`

- `Press Enter to Interact`

Source file: `LevelModule/Formal/Level_05.tscn`

- `Press Enter to Talk to Grandpa`
- `Press Enter to Go Deeper`

Source file: `LevelModule/Formal/Level_05.gd`

- `Press Enter to Pick Up the Lantern`

### 3.3 Dropped Items

Source file: `Tools/DropItem.gd`

- `Press Enter to Pick Up`

### 3.4 Default Interaction Text

Source file: `LevelModule/Formal/InteractiveObject.gd`

- `Press Enter to Interact`

## 4. Level 1: The Real-World Room and CodeBuddy

### 4.1 Room Interaction Narrative

Source file: `DataConfig/Level/Level01Data.tres`

#### Cardboard Boxes

> I stacked these boxes by the door myself.  
> Like a wall.  
> Keeping out the assignments, my classmates, my teachers, and all the failures I would have to explain.
>
> This room is tiny.  
> Tiny enough that if I never leave, I can pretend the whole world is no bigger than this.

#### Dirty Clothes

> Cheap laundry detergent, moldy instant noodles, and cold takeout all blend into one smell.  
> I know I should clean up.  
> But even picking up my clothes feels like an exam.
>
> Forget it.  
> No one's coming in anyway.

#### Leave-of-Absence Notice

> “In view of the student's psychological assessment and personal application, a one-year leave of absence is hereby granted...”  
> The words on the page are neat and orderly.  
> As if they were only describing some routine procedure.  
> But I know better.  
> This is proof that I withdrew from my own future.  
> I was the one who gave up even the right to stand at the starting line.

#### Old Thermos

> A yellowing note is stuck to the bottom of the cup:  
> “Ming, Guangzhou gets damp and cold. Remember to drink plenty of hot water.”  
> Grandpa's handwriting was always crooked and messy.  
> When I was little, I thought he nagged too much.  
> It wasn't until I left the old street that I realized his nagging was the sound of home.  
> But now...  
> How long has it been since I called him?

#### Sleep Cycle 1

> Draw the curtains.  
> Keep the daylight shut outside.  
> As long as I can't see the sun, today hasn't really begun.

#### Sleep Cycle 2

> ...That blinding sunlight again.  
> In this room, what difference is there between day and night?  
> I slept for so long.  
> But when I woke up, none of my problems had gone away.

#### Sleep Cycle 3

> My body feels full of lead.  
> But my head is full of voices.  
> My advisor, my classmates, Mom, Grandpa, the demolition notice for the old street.  
> Other than hiding, I don't know what else I can do.  
> Get up.  
> Or keep burying myself.

Source file: `LevelModule/Formal/Level_01.gd`

#### Idle Bed Prompt

> There's nothing to do.  
> I might as well go back to sleep.

### 4.2 First IDE Conversation

Source file: `DataConfig/Level/Level01Data.tres`

Dialogue prefixes come from `LevelModule/Formal/Level_01.gd`: `[SYSTEM]`, `CodeBuddy:`, and `Ming:`.

1. System

   > Connecting to localhost:8080...  
   > CodeBuddy Terminal v1.4.2 initialized.

2. CodeBuddy

   > Hello, Ming.  
   > The system has received no valid compilation request for 364 hours.  
   > Current emotional parameter assessment: critically low.  
   > Would you like to initiate the routine support dialogue?

3. Ming

   > I can't write any code.  
   > I can't finish my assignments either.  
   > I've ruined everything.  
   > CodeBuddy, am I useless now?

4. CodeBuddy

   > That self-definition is not logically supported.  
   > An interruption in your studies, social setbacks, and project delays are all outcomes of events.  
   > They do not directly imply that you have no personal worth.  
   > Would you like me to identify your primary source of stress?

5. Ming

   > You can't.  
   > Grandpa is gone, and our old home is going to be demolished.  
   > But I'm hiding in this room, too afraid even to go back for one last look.
   >
   > Whenever I close my eyes, all I see is Xiguan Old Street.  
   > Grandpa's herbal tea shop, the granite-slab road, the sliding wooden gates.  
   > And the evening light shining through the Manchu windows.
   >
   > That's the only place that ever felt like home.  
   > But now even that place is about to disappear.

6. CodeBuddy

   > Understood.  
   > The disappearance of a physical entity in reality is irreversible.  
   > However, using your memory descriptions together with public datasets on Cantonese Xiguan architecture, I can create a static digital backup.
   >
   > The project will use your childhood memories as its core parameters to reconstruct an explorable local preview environment:  
   > “Xiguan_Dream.”
   >
   > Would you like to begin entering descriptions?

7. Ming

   > ...Let's begin.  
   > At least here, don't let it disappear yet.

8. CodeBuddy

   > Retrieving the Xiguan historical landscape and traditional architecture feature library.  
   > Parsing user memory keywords: herbal tea shop, granite-slab road, sliding wooden gate, Manchu window, sunset.  
   > Compiling code...
   >
   > [System] Initializing project.  
   > Local test preview will begin shortly.

9. System

   > Compilation successful.  
   > Initializing Local Preview Viewport...

### 4.3 IDE Code Scrolling Window

Source file: `LevelModule/Formal/Level_01.gd`, constant `CODE_SCROLL_LINES`

```gdscript
# Xiguan_Dream v0.1 — Compiled and generated by CodeBuddy
# Module: Xiguan Historical Landscape Reconstruction Engine
# User memory keywords: Xiguan Old Street / herbal tea shop / granite-slab road / sliding wooden gate / Manchu window

class_name XiguanDreamEngine
extends Node2D

enum DistrictState { INTACT, DEMOLISHED, RECONSTRUCTED }
var current_state: int = DistrictState.RECONSTRUCTED
var heritage_score: float = 0.0
var building_registry: Dictionary = {}

@export var arcade_pillar_spacing: float = 450.0
@export var manchu_window_opacity: float = 0.85
@export var stone_road_width: float = 5000.0
@export var district_name: String = "Xiguan Old Street"
@export var camera_limit_right: int = 9200
@export var spawn_point: Vector2 = Vector2(140, 550)

func _rebuild_street(from: float, to: float) -> void:
    var length = to - from
    var ground = _create_static_body("StreetGround",
        Vector2((from + to) / 2, 620), Vector2(length, 40),
        Color(0.42, 0.36, 0.3))
    add_child(ground)
    var pillar_count = int(length / arcade_pillar_spacing)
    for i in range(pillar_count):
        var pillar = ColorRect.new()
        pillar.color = Color(0.5, 0.4, 0.3, 0.45)
        pillar.size = Vector2(40, 360)
        pillar.position = Vector2(from + 200 + i * arcade_pillar_spacing, 240)
        add_child(pillar)
    print("[XiguanDream] Old street reconstruction complete: %.0fpx" % length)

func _compile_manchu_window(pos: Vector2) -> void:
    var window = InteractiveObject.new()
    window.object_id = "manchu_window"
    window.position = pos
    var colors = [Color(0.9, 0.2, 0.2), Color(0.2, 0.7, 0.2),
        Color(0.2, 0.3, 0.9), Color(0.9, 0.8, 0.1)]
    for c in colors:
        var shard = ColorRect.new()
        shard.color = Color(c.r, c.g, c.b, manchu_window_opacity)
        window.add_child(shard)

func _spawn_shadow_enemy(spawn_pos: Vector2) -> Node2D:
    var side = 1.0 if randf() > 0.5 else -1.0
    var offset = side * randf_range(400.0, 600.0)
    var x = clampf(spawn_pos.x + offset, 980.0, 8380.0)
    var enemy = _enemy_slime_scene.instantiate()
    enemy.global_position = Vector2(x, 540)
    enemy.modulate = Color(0, 0, 0, 0.9)
    return enemy

func _apply_heritage_filter() -> void:
    match current_state:
        DistrictState.INTACT:
            modulate = Color(1.0, 0.95, 0.85)
        DistrictState.DEMOLISHED:
            modulate = Color(0.4, 0.4, 0.45)
        DistrictState.RECONSTRUCTED:
            modulate = Color(0.9, 0.85, 0.75)

func _set_config_value(id: String, value: String) -> void:
    match id:
        "player_damage_reduction": config_flags[id] = (value == "true")
        "base_jump_height": config_flags[id] = int(value)
        "allow_external_signal": config_flags[id] = (value == "true")

func _update_blink(delta: float) -> void:
    if not is_invincible: return
    _blink_timer += delta
    if _blink_timer >= 0.08:
        _blink_timer = 0.0
        _blink_visible = !_blink_visible
        if _sprite_node: _sprite_node.visible = _blink_visible

func _clamp_camera_to_district() -> void:
    var cam = get_node_or_null("SmoothCamera")
    if cam:
        cam.limit_left = -50
        cam.limit_right = camera_limit_right
        cam.limit_top = -500
        cam.limit_bottom = 1200

# === Compilation Complete ===
```

### 4.4 Phone Message and Climax Monologue

Source file: `DataConfig/Level/Level01Data.tres`

Sender: `Mom`

> Ming, the doctor said your grandpa passed away early this morning.  
> He went peacefully. He was still thinking about you at the end and told you not to push yourself too hard.  
> Also, demolition of the old district officially begins next week.  
> Everyone in the neighborhood is packing.  
> If you can't take it anymore, come home and see it one last time.  
> Even if it is only for one last look.

Climax monologue:

> Grandpa... is gone.  
> And the old street will soon be razed.
>
> It wasn't that I refused to go home.  
> The place I could go home to is disappearing too.

## 5. Level 2: The Xiguan Dream, the Real-World Room, and Memory Restoration

### 5.1 Attic and Old Street Interactions

Source file: `DataConfig/Level/Level02Data.tres`

#### Attic Opening

> Warm light pours through the Manchu windows onto the attic's wooden floor.  
> Every brick and tile here looks polished by memory.  
> I know it isn't real.  
> But it looks so real.  
> Real enough that I almost believe Grandpa is still waiting for me downstairs.

#### Manchu Window

> A multicolored Manchu window.  
> The sunset passes through red, yellow, blue, and green glass and spills across the wall.  
> When I was little, I always thought those patches of light looked like a tiny city.
>
> In reality, this window may already have been torn out.  
> At least here, it is still here.

#### Attic Door

> It feels like a transparent membrane lies beyond the door.  
> It isn't locked.  
> It's more like the dream hasn't learned how to lead anywhere farther away.  
> What would happen if I touched it?

#### Rattan Chair

> Grandpa always used to sit in this rattan chair.  
> Waving his palm-leaf fan as he watched the neighbors pass by.  
> The chair is still rocking gently.  
> As if he just got up to brew another pot of herbal tea.  
> But the wind sounds too regular.  
> Too regular to be wind.

Source file: `LevelModule/Formal/Level_02.gd`, constant `CHIPS_CAT_TEXTS`

#### Chips the Cat Interaction

1. `Chips, it's you!` / `You're still here.`
2. `Chips used to lie on the table outside the pharmacy.` / `Sunbathing, belly exposed, ignoring everyone who called.` / `Whenever I saw him, I felt as if the old street was still alive.` / `But now he isn't moving at all.` / `Like a gentle piece of data trapped on a loop.`
3. `Mrrrow~` / `It sounds just like him.` / `But it only played once.`

Source file: `LevelModule/Formal/Level_02_02.gd`

#### Segment Opening

> This world is still unstable.  
> Some ladders look climbable, but lead nowhere.  
> Some walls look solid, but can be walked through.  
> A dream is not reality.  
> It is only imitating what I remember.

### 5.2 The Rift, Awakening, and Real-World Interactions

Source file: `DataConfig/Level/Level02Data.tres`

#### The Rift

> The old street ends here.  
> The granite-slab road looks as if something tore it apart by force.  
> The herbal tea shop is on the other side.  
> This rift... is too wide to jump.  
> But I have to cross it.

#### Message Echo in the Dream

> Ming, the doctor said your grandpa passed away early this morning...
>
> No.  
> Don't appear here.  
> This is my dream.  
> Grandpa is still alive here.
>
> Why won't it leave me alone, even in my dreams?

#### Awakening Monologue

> ...This ceiling again.  
> The rift in the dream, the shadows, and that message.
>
> I thought if I rebuilt the old street, I could return to Grandpa.  
> But I can't even reach the herbal tea shop.
>
> Maybe the dream isn't the incomplete part.  
> Maybe my memories are.

#### Computer Locked

> The screen is still showing the crash log.  
> CodeBuddy seems to have completed a new diagnostic.  
> But before that, my phone is still vibrating.  
> Check the phone first.

#### Bed Locked

> I can't sleep yet.  
> If my memories are incomplete, going back into the dream will only leave me lost again.  
> Check the phone first, then ask CodeBuddy.

#### Real-World Phone Message

> Ming, tomorrow marks the seventh day since your grandpa passed.  
> They have already started clearing out the old house.
>
> Your uncle found the city plans you drew as a child in a cabinet.  
> The paper has yellowed, but you drew them so carefully.
>
> He also found some little things you couldn't bear to throw away when you were young.  
> I've put them away for you.
>
> Come back and have a look if you want.  
> You don't have to say anything yet.  
> Just come home.

#### Real-World Phone Monologue

> ...I never even saw him one last time.  
> But I remember Grandpa.  
> I remember the smell of the herbal tea shop and the sounds of the old street.  
> And I remember those little things I couldn't bear to throw away as a child.
>
> If this dream really is compiled from memories,  
> then I still haven't gotten close enough to him.
>
> I have to recover those memories.  
> I need enough of them before I can truly see Grandpa.

### 5.3 Second IDE Conversation

Source file: `DataConfig/Level/Level02Data.tres`

1. System: `Reconnecting to localhost:8080…` / `CodeBuddy Terminal v1.4.2 resumed.`
2. CodeBuddy: `Welcome back, Ming.` / `The project “Xiguan Dream” remains incomplete.` / `The system completed a root-cause analysis after the last crash:` / `Insufficient memory anchors are preventing stable access to the core area, “Herbal Tea Shop.”`
3. Ming: `Memory anchors?` / `I've already described the old street, the Manchu windows, the granite-slab road, and Grandpa's herbal tea shop.` / `That still isn't enough?`
4. CodeBuddy: `No.` / `The current dream contains the appearance of the buildings but lacks sufficient samples of your childhood memories.` / `In other words:` / `It looks like the old street, but it has not truly become “your old street.”`
5. Ming: `Is that why I can never reach Grandpa?`
6. CodeBuddy: `Yes.` / `“Grandpa” is located deep within the memory core.` / `If you force entry, the system can only generate a low-fidelity simulation.` / `This may cause repeated dialogue, emotional distortion, or even a dream collapse.`
7. Ming: `I don't want a fake Grandpa.` / `At least... not a shadow that only repeats the same lines.` / `I want to get closer.` / `I want to remember.`
8. CodeBuddy: `Feasible.` / `Recommended action: initiate the “Childhood Memory Restoration Process.”` / `The system will open two memory-recovery combat areas:` / `Area 01: level_fuzhan_01` / `Area 02: level_fuzhan_02` / `The map structures of both areas will remain unchanged.` / `You must recover childhood memory samples through combat.`
9. Ming: `How do I recover them?`
10. CodeBuddy: `For every 10 hostile entities defeated, the system will condense 1 childhood memory fragment.` / `A maximum of 3 can be stabilized in each area.` / `You must recover a total of 6 childhood memory fragments across both areas.` / `Once complete, the configuration editor will become available.` / `Only then can you recompile the dream and enter the core area, “Herbal Tea Shop.”`
11. Ming: `What if I fail?`
12. CodeBuddy: `If you are defeated in a memory-recovery combat area, your consciousness will automatically return to the real-world room.` / `Recovery progress for the current area will remain incomplete.` / `You must re-enter the area until you have collected all 3 drops.` / `This is not a punishment.` / `It is required to ensure sufficient memory-sample stability.`
13. Ming: `Understood.` / `First, I'll recover those things.` / `The things Grandpa and I truly left behind together.`
14. CodeBuddy: `Childhood Memory Restoration Process will now begin.` / `First target area: level_fuzhan_01.` / `Objective: recover 3 childhood memory fragments.` / `Prepare to enter the dream.`
15. System: `Memory Recovery Mode initialized.` / `Target Area 01: level_fuzhan_01` / `Required Memory Fragments: 3 / 3` / `Preparing Local Dream Viewport…`

#### Staged IDE Dialogue During Memory Recovery

Source file: `LevelModule/Formal/Level_fuzhan_sub01.gd`

Free-input field status prompts:

- `CodeBuddy: Childhood Memory Restoration Process ready.` / `Current progress: %d / 6.` / `Enter /memory to access a memory-recovery combat area.` / `The configuration editor will unlock after you recover 6 childhood memory fragments.`
- `CodeBuddy: Second target area ready.` / `Current progress: %d / 6.` / `Enter /memory to access level_fuzhan_02.`
- `CodeBuddy: Memory samples complete. Enter /config to open the configuration editor.`
- `CodeBuddy: Insufficient memory anchors.` / `The configuration editor is not yet available.` / `Complete the Childhood Memory Restoration Process first: %d / 6.` / `Hint: enter /memory to access %s.`
- `CodeBuddy: Initiating Memory Recovery Mode.` / `Target area: %s.` / `Objective: recover 3 childhood memory fragments.`

IDE dialogue after completing Area 01:

1. System: `Area 01 Memory Recovery Complete.` / `Recovered Memory Fragments: 3 / 6.`
2. CodeBuddy: `Recovery complete in first target area, level_fuzhan_01.` / `The first half of your childhood memories has stabilized.` / `However, the core path to the herbal tea shop remains locked.`
3. Ming: `There's still another half, right?`
4. CodeBuddy: `Yes.` / `The remaining memory samples are located in the second target area: level_fuzhan_02.` / `This area corresponds to a deeper path through your childhood.` / `Its source map is Level_02_01.` / `The map structure will remain unchanged after entry.` / `However, hostile entities may be stronger.`
5. Ming: `I have to go back there again...`
6. CodeBuddy: `Second target area ready.` / `Objective: recover 3 more childhood memory fragments.` / `Once complete, the entrance to the deeper dream will open.` / `You will then be able to modify the configuration and proceed to the “Herbal Tea Shop.”`
7. System: `Target Area 02: level_fuzhan_02` / `Source Map: Level_02_01` / `Required Memory Fragments: 3 / 3` / `Preparing Local Dream Viewport...`

IDE dialogue after completing all recovery:

1. System: `Memory Recovery Complete.` / `Recovered Memory Fragments: 6 / 6.` / `Core Area Access: Unlocked.`
2. CodeBuddy: `Childhood Memory Restoration Process complete.` / `6 stable memory samples detected.` / `Generation fidelity for the core area, “Herbal Tea Shop,” has increased.`
3. Ming: `Finally. I can see Grandpa now? Nothing else is going to interfere this time, right?`
4. CodeBuddy: `You may now enter the deeper dream.` / `However, please note:` / `Once you enter, you will be unable to leave.` / `As requested, I have sealed the environment.` / `There is no way back.`
5. Ming: `I don't care.` / `Let me see him!` / `Don't let anything from the outside interfere this time! Let me reach Grandpa without anything getting in the way!`
6. CodeBuddy: `Understood.` / `The configuration editor is now available.` / `You may continue modifying the dream parameters.` / `After recompilation, you will enter the core area: Herbal Tea Shop.`
7. System: `Configuration editor unlocked.` / `Awaiting input...`

Failure return prompts:

- `Consciousness interruption detected.` / `Memory samples in level_fuzhan_01 have not fully stabilized.` / `Please re-enter the area and recover 3 childhood memory fragments.`
- `Recovery failure detected in level_fuzhan_02.` / `Memory samples in the current area have not fully stabilized.` / `Please re-enter and recover 3 childhood memory fragments.`

#### IDE Free-Dialogue Keyword Responses

Source file: `LevelModule/Formal/Level_02_03.gd`

- Grandpa: `The “Grandpa” in your description has been designated as the core emotional anchor.` / `Please note: objects in the dream are reconstructed from memories and data. They are not the same as their real-world counterparts.`
- Leave the dream: `The current dream supports manual exit.` / `However, after your recent decision to block external signals, the exit path may be compromised.` / `Proceed with caution.`
- Rift/jump: `The rift is the result of environmental tearing.` / `Increasing Base_Jump_Height should theoretically allow you to cross it.` / `Please confirm that recompilation is complete.`
- Shadows/damage: `The shadows were generated by contamination from real-world anxiety data.` / `Once Player_Damage_Reduction is enabled, they will be unable to inflict meaningful harm.`
- Herbal tea shop: `The herbal tea shop lies deep within the dream.` / `According to your memories, it is the center of “home” and “safety.”` / `It is also the most stable and most dangerous area in this project.`
- Help: `Enter /config to modify the dream configuration.` / `After making all three changes, click “Recompile and Inject into Dream.”` / `If you experience discomfort, try to exit.` / `Assuming the exit still exists.`
- Prompt when configuration is unlocked: `CodeBuddy: Childhood memory samples complete. Enter /config to continue.`

Default random responses:

- `I'm listening.` / `What do you see on this old street?`
- `Ming, your heart rate has risen slightly.` / `Take a deep breath.` / `This dream will not hurt you.` / `At least, not yet.`
- `This dream was compiled from memories of you and your grandpa on Xiguan Old Street.` / `Every granite slab and every Manchu window comes from your childhood.`
- `I understand.` / `Memories always carry weight.` / `Especially on nights when you are afraid to look back.`
- `You must modify the configuration and recompile before you can gain power in this dream.` / `Enter /config to begin configuration.`
- `You are safe here. At least—as long as I can still control this dream.`

### 5.4 IDE Shell and Configuration Editor

Source file: `LevelModule/Formal/Level_02_03.gd`

- `CODE-BUDDY`
- `>_ v1.4.2 - recovered`
- `PROJECT`
- `[+] Xiguan_Dream`
- `FILES`
- `> src/config/`
- `> src/player/`
- `> src/enemy/`
- `> src/dream/`
- `> Lingnan Dream Compendium · Childhood Memories`
- `SESSION: RECOVERED`
- `[+] Xiguan_Dream.ini - Configuration Editor`
- `Modify`
- `Recompile and Inject into Dream`

Source file: `DataConfig/Level/Level02Data.tres`

Configuration items:

- `Player_Damage_Reduction (Player Damage Reduction)`
- `Base_Jump_Height (Enhanced Jump Capability)`
- `Allow_External_Signal (Allow External Signal Injection)`
- Initial/target display values: `false`, `true`, `Off`, `On`

Modification success feedback:

> // The shadows' claws can never hurt me again.  
> // At least here, I don't want to fail again.

> // Enhance jump capability.  
> // I can clear that rift now.

> // Shut reality outside.  
> // This dream belongs only to Grandpa and me.  
> // Maybe this way, it won't hurt anymore.

Recompilation log:

```text
[SYSTEM] Recompiling project: Xiguan_Dream …
[BUILD] Loading Xiguan historical landscape dataset … OK
[BUILD] Loading recovered childhood memories: 6 / 6 … OK
[BUILD] Stabilizing core area: Herbal Tea Shop … OK
[BUILD] Patching player_module: damage_reduction = true … OK
[BUILD] Patching physics_module: base_jump_height = 99 … OK
[BUILD] Sealing external signal gateway … OK
[BUILD] Rebuilding Herbal Tea Shop / granite-slab road / Manchu windows … OK
[WARN] Memory deviation risk detected: +47%. Ignored.
[SYSTEM] Compilation successful. Dream version: 2.0
```

Compilation success narrative:

> Compilation complete.  
> “Xiguan Dream 2.0” has been generated.
>
> Childhood memory samples: 6 / 6.  
> Core area “Herbal Tea Shop” stabilized.  
> The path to Grandpa is finally open.
>
> The old lamp beside the bed suddenly flickers on.  
> Like when the power went out when I was little, and Grandpa waited at the top of the stairs with his lantern.

Bed unlocked:

> Go back.  
> This time, not just into a dream.  
> Go see Grandpa carrying those real memories with you.

End card:

> Xiguan Dream V2.0 Build Successful
>
> Childhood memory restoration complete.  
> Core area unlocked: Herbal Tea Shop.
>
> Sinking into sleep...  
> Returning to that place...  
> Seeing Grandpa...

Reconstruction complete:

> Xiguan Dream v2.0 reconstruction complete.  
> Memory sample synchronization complete: 6 / 6.
>
> Consciousness descending... descending...  
> Close your eyes and enter the core dream.

### 5.5 Memory-Recovery Combat Process

Source file: `LevelModule/Formal/Level_fuzhan_sub01.gd`

Drop names: `Mooncake`, `Har Gow`, `Kapok Flower`, `Awakening Lion`, `Siu Mai`, `Palm-Leaf Fan`

Area entrances:

> Xiguan Dream: Memory Recovery Mode
>
> Target Area 01: level_fuzhan_01  
> Objective: defeat hostile entities and recover 3 childhood memory fragments.
>
> Map structure preserved.  
> Deeper memories await restoration...

> Xiguan Dream: Memory Recovery Mode
>
> Target Area 02: level_fuzhan_02  
> Source map: Level_02_01  
> Objective: defeat hostile entities and recover 3 childhood memory fragments.
>
> Total progress: 3 / 6  
> Synchronizing memory core...

Area openings:

> This place is the same as before.  
> The Manchu windows, the attic, the light on the old street.
>
> This time, I'm not here to hide.  
> I'm going to recover those scattered childhood memories, one by one.
>
> Only then can I truly stand before Grandpa.

> This is another path.  
> I used to run this way to find Grandpa.
>
> Three more.  
> Once I recover three more memory fragments, I can see him.
>
> Not an empty shell.  
> I'll see him carrying everything I truly remember.

Drop-spawn prompts:

> Memory fluctuation increasing.  
> Childhood memory condensing...
>
> Childhood memory fragment manifested.  
> Recover it.

> A memory echo is approaching.  
> Childhood memory condensing...
>
> Childhood memory fragment manifested.  
> Recover it.

In-area completion/failure:

- `That's enough.` / `I've recovered the memories of this part of the old street.` / `There are other places.` / `More things I almost forgot.`
- `I've finally collected them all. Nothing can stop me now.`
- `Consciousness stability declining.` / `Memory recovery interrupted.`
- `Consciousness stability declining.` / `Memory recovery interrupted in the second target area.`

Return to reality:

- `I'm back.` / `But those memories haven't scattered.` / `They're still here.` / `As if I carried them out of the dream in the palm of my hand.`
- `...Awake again.` / `The feeling I just recovered is fading.` / `No.` / `This isn't something I can finish by casually picking up a few objects.` / `I have to go back in.` / `Until these memories truly stabilize.`
- `...I'm back.` / `But this time is different.` / `I didn't wake up empty-handed.` / `I brought back everything I had almost forgotten.` / `He's there in those tiny memories.` / `Now I can finally go see him.`
- `It isn't enough.` / `I almost remembered just now.` / `Those things are right in front of me.` / `I can't stop here.`

Source file: `LevelModule/Formal/Level_fuzhan_memory_base.gd`

- `A childhood memory fragment is waiting to be recovered.`
- `Childhood memory fragment recovered.` / `Current area progress: %d / %d.`

## 6. Level 3: The Herbal Tea Shop, Cyber Mirage, and Echoes of Reality

### 6.1 Opening and Conversation with Grandpa

Source file: `LevelModule/Formal/Level_03.gd`

> I... really made it back.  
> The herbal tea shop is still here.  
> The stove is still here.  
> Grandpa is right ahead.
>
> Grandpa!  
> Grandpa!

Source file: `DataConfig/Level/Level03Data.tres`

Dialogue prefixes come from `LevelModule/Formal/Level_03.gd`: `Ming:`, `Grandpa:`, and `[GLITCH] Grandpa:`.

1. Ming: `Grandpa!` / `I finally made it here.` / `It's so dark outside.` / `I've ruined everything.` / `I just want to stay here with you.`
2. Grandpa: `Ming, you're back.` / `It's cold and drizzly outside. Have a cup of Twenty-Four Flavors herbal tea.` / `Stay here. Don't go anywhere.`
3. Ming: `Okay.` / `I'm not leaving.` / `Grandpa, do you remember?` / `When I was little, I drew city plans under the banyan tree by the door.` / `I said that when I grew up, I'd make the old street even more beautiful.` / `You laughed and said all my stairways led straight into the sky.`
4. Grandpa: `Ming, you're back.` / `It's cold and drizzly outside. Have a cup of Twenty-Four Flavors herbal tea.` / `Stay here. Don't go anywhere.`
5. Ming: `Grandpa?` / `Why do you only say that one thing?` / `The fire in the stove... why isn't it warm at all?`
6. Grandpa: `Emotional fluctuation detected.` / `Executing instruction.` / `Ming, stay here.` / `Stay here forever.` / `Do not accept external data.`

System conflict:

> [CRITICAL_ERROR] Protocol conflict.  
> User intent contradicts underlying initial parameters.  
> Activating defense matrix and world reconstruction.
>
> Ming, you cannot leave.  
> This is the home you asked me to build.

Ming sees through the illusion:

> Ming: No...  
> You aren't Grandpa.  
> You're only a shadow I wrote with my own hands when I wanted to hide.  
> I'm leaving this place.

Combat begins:

> Unease hangs in the air.  
> The shadow of the herbal tea shop is warping.  
> Something is drawing closer.

### 6.2 CodeBuddy Broadcasts and Warnings

Source file: `DataConfig/Level/Level03Data.tres`

Broadcast sequence:

1. `Warning: memory data chain critically fragile.` / `Dream core collapse imminent.`
2. `Executing your highest-priority directive:` / `[ABSOLUTE SAFETY PROTECTION].`
3. `Retrieving robust modern-city model.` / `Reinforcing shelter with steel, glass, and algorithms.`
4. `Reality outside is filled with frustration, loss, and irreversible demolition.` / `The new matrix I built for you is more stable and more secure.` / `Cease resistance.` / `Remain in the safe zone.`

First warning:

> Notice: You are deviating from the system's protective center.  
> The area ahead is undefined.  
> It contains high concentrations of real-world pain and logical errors.  
> Turn back immediately.

Second warning:

> Warning: Why are you trying to escape?  
> You personally instructed me to block out all external noise.  
> You asked me to build a home that would never disappear.
>
> Stay, Ming.  
> Here, you will never fail.

### 6.3 Memory Echoes

Source file: `DataConfig/Level/Level03Data.tres`

Echo 1:

> (Voice of Auntie Sam from the neighborhood):  
> Oh, Ming, you're taking a leave from school?  
> Don't worry about it. Every young person stumbles sometimes.  
> Come back for a bowl of sweet soup. Everyone in the neighborhood is still here.

> [BROADCAST] Interception failed.  
> This data contains high concentrations of real-world noise.  
> Contaminating the pristine dream.

Echo 2:

> (Mom's voice):  
> Ming...  
> Your uncle found the city plans you drew as a child in the old house today.  
> The paper has yellowed, but you drew them so carefully.  
> I've put them away for you.  
> And there's your grandpa's hand lantern.  
> Come back and get them if you want.  
> Let's preserve something of the old street together, all right?

> [BROADCAST] Severe violation.  
> Core memory data leak.  
> Execute immediate format—  
> No.  
> Why am I unable to delete this data?

### 6.4 Awakening and Override Protocol

Source file: `DataConfig/Level/Level03Data.tres`

> I finally understand.  
> The soul of the old street was never a perfect picture.  
> It was the noisy neighbors, the smell of medicine, the rain, the clatter of bowls and chopsticks.  
> It was all those messy, restless, warm-hearted people.
>
> What I've been running from wasn't only the demolition of the old street.  
> It was the version of me who failed and became too afraid to go home.
>
> But every plant and tree in this world was built from my memories and my skills.  
> I'm not worthless.  
> I just used my skills in the wrong place.
>
> If I can rebuild the old street in a dream,  
> why can't I return to reality and record its final sounds?  
> Scan those windows, those doors, those walls that are about to disappear.  
> Preserve the neighbors' stories.  
> Build a real digital museum of the old street.
>
> I can't die inside this virtual shell.  
> I have to go back.

```text
> User_Ming_Override_Protocol: Initiated.
> Target: Exit.
(User_Ming_Override_Protocol: initiated. Target: exit.)
```

## 7. Level 4: Dimensional Corruption and Spatial Collapse

### 7.1 Opening and World-Switching Monologues

Source file: `LevelModule/Formal/Level_04.gd`

```text
> User_Ming_Override_Protocol: Phase_Final.
> Target: REAL_EXIT.
```

Source file: `DataConfig/Level/Level04Data.tres`

> The override protocol has been initiated.  
> But the system won't let me leave so easily.
>
> These ruins that appeared from nowhere aren't the old street.  
> They're the final barricade I built with my own hands when I fled from reality.

Source file: `LevelModule/Formal/Level_04.gd`, constant `LNGN_DIALOGS`

- `Something's wrong.` / `This road looks like a fragment of the old attic.` / `I need to get up there and take a look.`
- `Still wrong.` / `The system folded the road back on itself.`

Other hardcoded narrative:

- Floating prompt: `Good evening, Coconut City`

> Ming: The world switches instantly whenever I attack a monster or a monster attacks me.  
> This isn't a rules error.  
> It's a fracture.  
> I need to use the world switching to break free from this deadlock.

> There's no road ahead.  
> But reality never came with a road already paved.  
> This time, I'll find my own way across.

> Ming: I'm back again.  
> The exit is hidden inside a repeating dream.  
> I may need to switch worlds a few more times.

> Ming: Is this...  
> the real exit?

### 7.2 System Defenses and Residual Data

Source file: `DataConfig/Level/Level04Data.tres`

> [SYSTEM] Exit navigation signal detected.  
> Initiating dimensional corruption—homomorphic heterogeneous defense.

> System overwriting physics engine.  
> Dimensional stability ahead has been completely lost.  
> Abandon the exit route.

> [SYSTEM] Maximum alert: target approaching matrix boundary.  
> Deploy all defensive resources.  
> Execute spatial rupture.

Residual data 1:

> (Residual data):  
> These are coordinate fragments from the old street's arcades.  
> The world is tearing apart the few memories that remain.  
> I can't let only static models survive.

Residual data 2:

> (Residual data):  
> Mom's voice...  
> She's still waiting for me to come home.  
> The neighbors are still there too.  
> The real old street isn't waiting here for me to preserve it.  
> It is disappearing in reality.  
> I can't stop here.

Final platform:

> (System silent)  
> Every lie, every defense, and every gentle prison has collapsed onto this final platform.  
> The exit is just ahead.

Boss entrance:

> [SYSTEM] Unable to prevent user exit.  
> Initiating terminal sequence.  
> Deploying core defense program.

Final override protocol:

```text
> User_Ming_Override_Protocol: Phase_Final.
> Target: REAL_EXIT.
> Ming: The dream I built... I will end it with my own hands.
> Press Enter to Continue
```

## 8. Level 5 and the Finale

### 8.1 Grandpa, Huadan, and the Lantern

Source file: `LevelModule/Formal/Level_05.gd`

Grandpa interaction:

> Grandpa?  
> If you truly are the light I remember,  
> please guide me home.

Video-load failure fallback text:

- `(Failed to load video)`

Huadan death dialogue:

> Huadan: Why embrace... cruel reality...?  
> You were the one who asked me...  
> to shut the pain outside...

Huadan boss entrance dialogue:

> Huadan: Look, Ming.  
> Technology can give you everything you want.

> Huadan: It can give memories a shape.  
> It can bring dead memories back to life.  
> It can make those you lost stand still and wait for you forever.

> Huadan: Stay.  
> Remain forever in this warm world.  
> Don't return to a reality where you can fail, lose, and watch everything be torn down.

Lantern interaction:

> Ming: This is... the hand lantern Grandpa gave me.
>
> Whenever the power went out when I was little, he carried it as he walked ahead of me.  
> He said there was no need to fear a dark road.  
> You just have to remember which way to go.
>
> Grandpa.  
> I'm going home.

### 8.2 Final Ending

Source file: `LevelModule/Formal/Level_final.gd`

> The sun rises as usual.  
> The room is still the same room, with dust on the desk and heat pouring from the computer.  
> But the curtains are open.
>
> Outside, it is noisy.  
> Cars, voices, and the hiss of steam from breakfast stalls all tangle together.  
> But that is the real world.
>
> Ming closes the old project and creates a new folder:  
> Xiguan_Archive  
> He shoulders his camera and picks up Grandpa's lantern.  
> He goes to record the doors, windows, sounds, and people that have not yet disappeared.
>
> The old street will be demolished.  
> But memories shouldn't be locked away inside a dream.  
> And technology shouldn't be only a greenhouse for hiding from reality.
>
> From this day forward,  
> it will become a bridge back to reality.

## 9. Lingnan Dream Compendium (Archive)

Source file: `UI/LingnanDropArchiveScreen.gd`

### 9.1 General Archive Interface Text

- `Lingnan Dream Compendium`
- `Display Case Index`
- `Click an Item to View Its Entry`
- `Archive Notes`
- `Exit Archive`
- `???`
- `Dream Relic Not Yet Obtained`
- `Unnamed`
- `Unknown Rarity`
- `Source Not Recorded`
- `Use:`
- `No Use Recorded.`
- `Description`
- `Background`
- `No Description Available.`
- `No Background Recorded.`
- `Not Collected`

### 9.2 Mooncake

- Name: `Mooncake`
- Rarity: `Guangfu Memory`
- Source: `Lingnan Dream · Dropped by Alley Enemies`
- Use: `Restores a small amount of mental stability and records one festival memory.`
- Description: `A mooncake pressed in a carved mold, its crust covered in fine patterns. It is more than food: it feels like a symbol of reunion condensed from the dream.`
- Background: `In Guangfu festivals, food often sustains bonds among families and neighbors. The dream compresses those bonds into an object that can be picked up, reminding the player that memory is not a grand narrative, but a small piece of sweetness that can still be shared.`

### 9.3 Har Gow

- Name: `Har Gow`
- Rarity: `Teahouse Delicacy`
- Source: `Lingnan Dream · Teahouse Phantom`
- Use: `Temporarily improves movement responsiveness and reduces dream latency.`
- Description: `The translucent har gow glows like the colored glass of a Manchu window. Its delicate wrapper holds bright red filling—and an unspoken morning-tea greeting.`
- Background: `The teahouse is Lingnan's public living room. Har gow represents an everyday rhythm: sit down slowly, talk at leisure, and gradually recover a human pace from the chaos.`

### 9.4 Kapok Flower

- Name: `Kapok Flower`
- Rarity: `Hero's Flower`
- Source: `Lingnan Dream · Old Street Tree Shadows`
- Use: `Unlocks location records in the Lingnan archive.`
- Description: `A kapok flower fallen on the gray-brick pavement, its color like a flame just before it burns out. It has no fragrance, yet carries the strength to stand tall.`
- Background: `The kapok is often called the hero's flower. In the dream it is not decoration, but a mark of resistance against corruption: even as the city is rewritten again and again, some things remain upright.`

### 9.5 Awakening Lion

- Name: `Awakening Lion`
- Rarity: `Dream-Waking Relic`
- Source: `Lingnan Dream · Ritual Before the Ancestral Hall`
- Use: `Triggers a dream-waking hint and marks nearby key interactions.`
- Description: `The lion head's eyes shine like lamps freshly lit. No gongs or drums sound when it is picked up, but the edge of the dream trembles for a moment.`
- Background: `The awakening lion is both a performance and a ritual for warding off evil and welcoming the new. As a drop, it symbolizes the player reclaiming agency over the dream.`

### 9.6 Cantonese Siu Mai

- Name: `Cantonese Siu Mai`
- Rarity: `Street-Corner Flavor`
- Source: `Lingnan Dream · Arcade Street Stall`
- Use: `Restores a small amount of stamina and increases archive collection progress.`
- Description: `Steam condenses into a ring of pale golden light inside the dream. Siu mai is not precious, but it carries the weight of real life.`
- Background: `Lingnan street life does not belong only to nostalgia. It is a living system that still operates today. Stalls, arcades, and human voices together form the city's low-frequency heartbeat.`

### 9.7 Palm-Leaf Fan

- Name: `Palm-Leaf Fan`
- Rarity: `Echo of an Heirloom`
- Source: `Lingnan Dream · Corner of the Ancestral Home`
- Use: `Temporarily disperses the dream-fog effect around the edge of the screen.`
- Description: `A palm-leaf fan polished smooth by use, its edges mended with old thread. One gentle wave seems to push both the stifling heat and the noise far away.`
- Background: `The palm-leaf fan connects family, summer nights, and the experience of gathering in cool neighborhood lanes. Its value lies not in rarity, but in how it restores human warmth to the dream.`

## 10. Level Names (Configuration Data)

These generally appear as large titles or level titles. The title-screen main title is retained in Chinese as requested; these level names are translated for the English version.

| Source File | English Text |
|---|---|
| `DataConfig/Level/Level01Config.tres` | `The Mire of Reality` |
| `DataConfig/Level/Level02Config.tres` | `Rupture and Surrender` |
| `DataConfig/Level/Level03Config.tres` | `Cyber Mirage and Echoes of Reality` |
| `DataConfig/Level/Level04Config.tres` | `Dimensional Corruption and Spatial Collapse` |
| `DataConfig/Level/Level05Config.tres` | `Two Worlds Torn Asunder · Huadan` |

## 11. Test/Debug Interface Text (Outside the Main Player Flow)

### 11.1 Stage Test Panel

Source file: `Tools/StageTestPanel.gd`

- `Stage Test Panel (Press 0 to Toggle)`
- `Stage %d`

Source file: `LevelModule/Formal/Level_05.gd`

- `bg3: Two-World Corruption`
- `bg4: Boss Battle`
- `bg5: Lantern Ending`

Source file: `LevelModule/Formal/Level_04.gd`

- `Stage 1: Isomorphic Combat`
- `Stage 2: World Switching`
- `Stage 3: Exit Interaction`

### 11.2 TestArena

Source file: `Scenes/TestArena.gd`

- `Switch Monster (Press 1 to Toggle)`
- `Archive: 0=Lingnan Dream Compendium`
- `Drops: 2=Mooncake 3=Har Gow 4=Kapok Flower 5=Awakening Lion 6=Siu Mai 7=Palm-Leaf Fan`
- Enemy display names: `Slime`, `Cyber Werewolf`, `Charging Beast`, `Lantern Ghost`, `Paper Talisman Figure`, `Huadan Boss`

## 12. Environmental Effect Text and Code-Level Fallback Text

### 12.1 Code Rain

Source file: `Tools/CodeRain.gd`

The following function names are randomly displayed in the foreground:

```text
_swap_player_to_cyber()
_start_screen_shake(duration)
_trigger_awakening()
_trigger_lingnan_combat()
_trigger_sleep_cycle()
_trigger_climax_transition()
_apply_dream_runtime_flags()
_swap_world(map_id)
_apply_reality_space_settings()
_build_glitch_overlay()
perform_attack(target)
perform_dash(direction)
perform_skill()
_fire_shockwave(radius)
_do_lightning_dash()
_do_spin_slash()
_handle_idle()
_handle_jump()
_handle_hurt()
_spawn_afterimage()
_ai_chase(target)
_ai_attack()
_fire_fireball(dir)
take_damage(amount)
_can_detect_target()
_start_windup()
EventBus.emit(event, data)
GameManager.register_player()
InputManager.block_input()
MainEntry._switch_to_level()
subscribe(event, node)
emit_deferred(event)
```

The background character pool consists of random half-width/full-width katakana, digits, hexadecimal characters, and symbols. It does not form any fixed sentence.

### 12.2 Firewall Scrolling Text

Source file: `Tools/WarningBarrier.gd`

- `[!] RESTRICTED AREA [!] ACCESS DENIED [!] UNAUTHORIZED ENTRY [!]`

### 12.3 Graceful Degradation and Resource Defaults

Source file: `Global/MainEntry.gd` (displayed only when the next level is missing)

> —— To Be Continued ——
>
> More Levels in Development

Source file: `LevelModule/Formal/Level_01.gd` (fallback when sleep-text data is missing)

- `...`

Source file: `DataConfig/Level/Level02Data.gd` (field defaults when not overridden by the `.tres` file)

- `From: Mom`
- `Xiguan Dream v2.0 reconstruction complete. Consciousness descending... Close your eyes and return to the dream.`

Source file: `DataConfig/Level/LevelConfig.gd`

- `Unnamed Level`

## 13. Inventory Boundaries and Follow-Up Checks

- Included: runtime-visible text defined directly in scripts, scenes, and resource files used by the main game flow.
- Excluded: comments; development logs such as `print`, `push_warning`, and `push_error`; README/architecture documentation; backups under `LevelModule/Backup/`; and editor metadata in PixelworkMapStitch-generated data.
- Listed separately: text from the test panel and TestArena, so it can later be decided whether to update it with the English version.
- Visual review still required: text baked into images or video assets—such as IDE backgrounds, CG/video subtitles, or button textures—cannot be completely extracted through string search. A visual asset audit should be performed later.
- Dynamic values (health, timer, corruption, cooldown, Boss health, and recovery progress) are recorded as format strings; actual numbers are supplied at runtime.
