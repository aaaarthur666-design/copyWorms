# ============================================================
# Level04Data.gd - 关卡4「维度侵蚀与空间崩塌」数据类
# 单坐标空间: 起始地(0-1200) + 战斗区(1200-2400) + 渗透区(2400-4800) + 撕裂区(4800-9600) + 终焉之域(9600-12800)
# ============================================================
extends Resource
class_name Level04Data

# ---- 阶段0: 起始地 ----
@export var anchor_narrative: String = "The override protocol has been initiated.\nBut the system won't let me leave so easily.\n\nThese ruins that appeared from nowhere aren't the old street.\nThey're the final barricade I built with my own hands when I fled from reality."
@export var first_contact_text: String = "[color=red][SYSTEM] Exit navigation signal detected.\nInitiating dimensional corruption—homomorphic heterogeneous defense.[/color]"

# ---- 阶段1: 境域置换 —— 半对半空间硬切 ----
@export var domain_swap_text: String = "[color=cyan]System overwriting physics engine.\nDimensional stability ahead has been completely lost.\nAbandon the exit route.[/color]"
@export var surface_enemy_count: int = 5
@export var surface_enemy_spawn_points: Array[Vector2] = []

# ---- 阶段2: 异质渗透 ----
@export var infiltration_text: String = ""
@export var infiltration_enemy_count: int = 6
@export var infiltration_enemy_spawn_points: Array[Vector2] = []

# ---- 阶段3: 空间撕裂 ----
@export var space_tear_text: String = "[color=crimson][SYSTEM] Maximum alert: target approaching matrix boundary.\nDeploy all defensive resources.\nExecute spatial rupture.[/color]"
@export var tear_enemy_count: int = 8
@export var tear_enemy_spawn_points: Array[Vector2] = []

# ---- 空间碎片（类似记忆光团，全局坐标） ----
@export var tear_fragment_1_pos: Vector2 = Vector2(6200, 480)
@export var tear_fragment_2_pos: Vector2 = Vector2(8200, 420)
@export var tear_fragment_1_text: String = "[color=cyan](Residual data):\nThese are coordinate fragments from the old street's arcades.\nThe world is tearing apart the few memories that remain.\nI can't let only static models survive.[/color]"
@export var tear_fragment_2_text: String = "[color=cyan](Residual data):\nMom's voice...\nShe's still waiting for me to come home.\nThe neighbors are still there too.\nThe real old street isn't waiting here for me to preserve it.\nIt is disappearing in reality.\nI can't stop here.[/color]"

# ---- 阶段4: 终焉之域 ----
@export var final_domain_text: String = "[color=white](System silent)\nEvery lie, every defense, and every gentle prison has collapsed onto this final platform.\nThe exit is just ahead.[/color]"
@export var boss_entrance_text: String = "[color=red][SYSTEM] Unable to prevent user exit.\nInitiating terminal sequence.\nDeploying core defense program.[/color]"
@export var override_protocol_text: String = "> User_Ming_Override_Protocol: Phase_Final.\n> Target: REAL_EXIT.\n> Ming: The dream I built... I will end it with my own hands.\n> Press Enter to Continue"

# ---- 敌人刷新点（Surface/Infiltration/Tear 阶段） ----
@export var cleaner_spawn_points: Array[Vector2] = []
@export var security_spawn_points: Array[Vector2] = []

# ---- 转场 ----
@export var next_level_path: String = ""
