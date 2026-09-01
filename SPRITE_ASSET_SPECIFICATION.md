# HackathonGame 序列帧资产完整规格与 Harness 参数基线

> 数据冻结日期：2026-08-31
> 目标项目：Godot 4.6、2D 横屏动作冒险、GL Compatibility
> 配套机器清单：`SPRITE_ASSET_MANIFEST.json`

## 1. 文档目的

这份文档不是新的美术方案，也不改变项目现有资产形式。它把当前项目真正使用的角色与怪物序列帧、裁切顺序、尺寸、帧率、循环方式、透明边界、锚点、碰撞体和代码中的硬编码假设全部固化下来，作为序列帧 Harness 的项目适配输入。地图继续由现有方案处理；本文只覆盖人物、怪物和一个现有 NPC 的序列帧，以及与它们直接相关的辅助图片。

机器清单是逐帧事实源：每一帧都含源矩形、网格坐标、透明包围盒、Alpha 覆盖率、质心、底边、边缘接触、颜色和哈希。本文用于人工评审与实施；Harness 应直接读取 JSON，不应从 Markdown 反向解析。

### 1.1 审计方法与可信边界

- 静态读取了当前工作树中的 `.tscn`、`.gd`、`.tres`、PNG 与 `.png.import`；正式场景和运行资源均未修改。
- 对所有 `Assets/Sprites` PNG 做了像素级 Alpha、包围盒、基线、质心、触边、颜色和文件哈希分析。
- 通过已连接的 Godot MCP 激活了 `project@5f63` 会话；编辑器报告项目名 `HackathonGame`、Godot `4.6.2-stable`、状态 ready、未运行，当前打开 `Enemy_BossHuadan.tscn`。场景树和 Sprite 属性与磁盘数据一致，并完成了 2D 视口截图核对。仓库契约仍锁定 4.6 分支，不锁定补丁版本。
- 未在此仓库发现序列帧 Harness 源码，因此清单采用独立 JSON，不假设具体 Web 框架或生图 API。
- PNG 的像素统计能发现空白、裁切、漂移和配色异常，但不能单独证明角色身份、服装、肢体和动作语义连续；这些仍保留人工验收。

## 2. 当前资产总览

- 角色资产集：**9** 套（8 个独立动画角色场景 + 1 套嵌入式 NPC）。
- 去重后的动画定义：**35** 个；动画帧槽：**406** 个。
- `Assets/Sprites` 物理 PNG：**37** 个，合计 **5138847 bytes**。
- 正在使用的序列帧源图：**34** 张；脚本专用辅助图：**2** 张；未引用候选图：**1** 张。
- 当前规格不是统一 128×128：实际单元格包含 64×64、128×128、256×256，以及 Boss 悬空动作的一张 1024×1024 整图。
- 37 张 PNG 的 Godot 导入参数完全一致：`compress/mode=0`、不生成 mipmap、`fix_alpha_border=true`、不预乘 Alpha、`size_limit=0`。

### 2.1 角色矩阵

| 资产 ID | 角色 | 类型 | 动作 | 单元格 | 场景 |
|---|---|---|---|---|---|
| `boss_huadan` | 花旦 Boss | `boss_enemy` | attack, defeated, dizziness, hang_in_air, idle, walk | 1024×1024, 128×128, 256×256 | `res://EnemyModule/Formal/Enemy_BossHuadan.tscn` |
| `cyber_bull` | 赛博冲撞兽 | `common_enemy` | idle, walk, attack | 64×64 | `res://EnemyModule/Formal/Enemy_CyberBull.tscn` |
| `cyber_wolf` | 赛博狼人 | `common_enemy` | idle, walk, attack | 128×128 | `res://EnemyModule/Formal/Enemy_CyberWolf.tscn` |
| `grandpa_npc` | 爷爷 NPC | `npc` | idle | 64×64 | `res://LevelModule/Formal/Level_03.tscn<br>res://LevelModule/Formal/Level_05.tscn` |
| `lantern_ghost` | 灯笼鬼 | `common_enemy` | attack, idle | 64×64 | `res://EnemyModule/Formal/Enemy_LanternGhost.tscn` |
| `paper_effigy` | 纸符人 | `common_enemy` | idle, walk, attack | 128×128 | `res://EnemyModule/Formal/Enemy_PaperEffigy.tscn` |
| `player_warrior_base` | 基础战士 | `player` | idle, jump, walk | 128×128 | `res://PlayerModule/Formal/Player_Warrior.tscn` |
| `player_warrior_cyber` | 赛博战士 | `player` | attack, attack_in_air, defeated, hit, idle, jump, walk | 128×128 | `res://PlayerModule/Formal/Player_Warrior_Cyber.tscn` |
| `player_warrior_lingnan` | 岭南战士 | `player` | attack, attack_in_air, defeated, hit, idle, jump, walk | 128×128 | `res://PlayerModule/Formal/Player_Warrior_Lingnan.tscn` |

## 3. Harness 必须遵守的全局输出契约

| 项目 | 固定值/规则 |
|---|---|
| 输出文件 | PNG、RGBA、透明背景；候选图先进入 staging，验收后才覆盖原路径 |
| 视角 | 严格横版侧视；源图默认面向右侧，Godot 通过 `flip_h` 映射左侧 |
| 像素采样 | 项目默认纹理过滤值 0（Nearest）；禁止生成后做平滑缩放或 JPEG 中转 |
| 帧中心 | `AnimatedSprite2D.centered=true`；源单元格中心是局部原点，角色落脚通过透明留白与 Sprite offset 对齐 |
| 表格装配 | 必须读取 `frame_order[].source_region_px`；不得只按帧数猜测从左到右、从上到下 |
| 空白格 | `unused_source_cells` 可以透明；`frame_order` 中引用的格子不可透明 |
| 导入 | `compress/mode=0`、`mipmaps/generate=false`、`process/fix_alpha_border=true`、`process/premult_alpha=false`、`process/size_limit=0` |
| 路径 | 使用 `res://`，大小写与磁盘完全一致；目录名中的空格和中文都是当前契约的一部分 |
| 资产形式 | 保持现有 SpriteFrames + PNG 图集；不引入骨骼动画、瓦片化角色或本地模型部署要求 |
| 生成粒度 | 一次任务只生成一个角色的一个动作；完成单动作质检后再装配图集 |

### 3.1 Harness 的最小任务对象

每个生成任务至少从 JSON 读取以下字段：

```text
character.id
character.style_tags + dominant_palette_from_used_frames
character.source_facing_direction
character.runtime_transform + collision_contract
animation.name
animation.canonical_sheet_resource_path
animation.sheet_size_px + cell_size_px + grid_columns_rows
animation.frame_count + frame_order + unused_source_cells
animation.runtime_effective_fps + runtime_effective_loop
animation.quality_metrics
character.runtime_contracts
```

生成模型可以改变画面内容，但装配器不能擅自改变这些工程参数。

## 4. 逐角色完整规格

### 4.1 花旦 Boss（`boss_huadan`）

- 场景：`res://EnemyModule/Formal/Enemy_BossHuadan.tscn`
- 脚本：`res://EnemyModule/Formal/Enemy_BossHuadan.gd`
- 配置：`res://DataConfig/Enemy/BossHuadanConfig.tres`
- 源朝向：`right`；镜像规则：right-facing source; flip_h mirrors to face left。
- 场景 Sprite 变换：`{"position_px":[0,0],"offset_px":[0,0],"scale":[1.2,1.2],"centered":true}`。
- 运行时 Sprite 变换：`{"default_offset_px":[0,10],"default_scale":[1.2,1.2],"animation_scale_overrides":{"hang_in_air":[0.14,0.14]},"notes":["stun recovery briefly resets offset to [0,0]; normal animation update restores [0,10]"]}`。
- 碰撞契约：`{"shape":"RectangleShape2D","size_px":[80,160],"position_px":[0,0],"melee_hitbox_size_px":[120,200],"melee_hitbox_position_px":{"right":[65,0],"left":[-65,0]}}`。
- 主要颜色：#000000, #FFFFFF, #010101, #110E16, #2B3D4B, #010000, #27101E, #F7FCFB, #2E3C4E, #2E3E4A
- 风格标签：Chinese opera martial-dan warrior, teal magenta and gold armor, back flags and long polearm, side-view pixel art, large boss silhouette

**状态到动作映射**

| 状态 | 动作 |
|---|---|
| `IDLE` | `idle` |
| `APPROACH` | `walk` |
| `RETREAT` | `walk` |
| `RANGED` | `idle` |
| `MELEE_ACTIVE` | `attack` |
| `MELEE_INACTIVE` | `walk` |
| `EVADE` | `walk` |
| `JUMP` | `walk` |
| `HOVER` | `hang_in_air` |
| `STUN` | `dizziness` |
| `DEAD` | `defeated` |

**动作与图集参数**

| 动作 | 源图 | 图集 / 单元格 / 网格 | 帧序（列,行） | 场景→运行 FPS | 循环 | 运行时长度 | 底边与包围盒 | 异常 |
|---|---|---|---|---:|---|---:|---|---|
| `attack` | `res://Assets/Sprites/boss_huadan/boss攻击.png` | 1024×1024 / 256×256 / 4×4 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) (0,3) (1,3) (2,3) (3,3) | 15→15 | false→false | 1.067s | bottom 184..184; bbox [59,59,241,184] | — |
| `defeated` | `res://Assets/Sprites/boss_huadan/boss眩晕.png` | 1024×768 / 256×256 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 5→6 | true→false | 2s | bottom 183..187; bbox [72,70,191,187] | — |
| `dizziness` | `res://Assets/Sprites/boss_huadan/boss眩晕.png` | 1024×768 / 256×256 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 5→6 | true→false | 2s | bottom 183..187; bbox [72,70,191,187] | — |
| `hang_in_air` | `res://Assets/Sprites/boss_huadan/boss悬空.png` | 1024×1024 / 1024×1024 / 1×1 | (0,0) | 1→1 | true→true | 1s | bottom 964..964; bbox [141,60,868,964] | — |
| `idle` | `res://Assets/Sprites/boss_huadan/boss待机.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 6→6 | true→true | 2s | bottom 120..122; bbox [10,8,108,122] | — |
| `walk` | `res://Assets/Sprites/boss_huadan/boss行走.png` | 512×384 / 128×128 / 4×3 | (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) | 10→10 | true→true | 0.9s | bottom 119..122; bbox [11,5,109,122] | — |

**运行时硬约束**

- hang_in_air is one 1024x1024 frame and must use scale 0.14
- dizziness and defeated are forced to 6 fps non-loop at runtime
- stun holds the final dizziness frame
- melee hit timing uses config fps 12 rather than SpriteFrames fps 15

**逐帧质检说明**

- `attack`：运行时根节点底边 79.2..79.2 px；最小透明边距 `{"left":59,"top":59,"right":15,"bottom":72}`；相邻 Alpha 质心最大位移 40.362 px；未用格 `[]`。
- `defeated`：运行时根节点底边 78.0..82.8 px；最小透明边距 `{"left":72,"top":70,"right":65,"bottom":69}`；相邻 Alpha 质心最大位移 8.247 px；未用格 `[]`。
- `dizziness`：运行时根节点底边 78.0..82.8 px；最小透明边距 `{"left":72,"top":70,"right":65,"bottom":69}`；相邻 Alpha 质心最大位移 8.247 px；未用格 `[]`。
- `hang_in_air`：运行时根节点底边 64.68..64.68 px；最小透明边距 `{"left":141,"top":60,"right":156,"bottom":60}`；相邻 Alpha 质心最大位移 0.0 px；未用格 `[]`。
- `idle`：运行时根节点底边 79.2..81.6 px；最小透明边距 `{"left":10,"top":8,"right":20,"bottom":6}`；相邻 Alpha 质心最大位移 1.396 px；未用格 `[]`。
- `walk`：运行时根节点底边 78.0..81.6 px；最小透明边距 `{"left":11,"top":5,"right":19,"bottom":6}`；相邻 Alpha 质心最大位移 3.63 px；未用格 `[[0,0],[1,0],[3,2]]`。

每一帧的矩形、bbox、四边留白、Alpha、质心、颜色与 SHA-256 位于 JSON 的该角色 `animations[].frame_order[]`。

### 4.2 赛博冲撞兽（`cyber_bull`）

- 场景：`res://EnemyModule/Formal/Enemy_CyberBull.tscn`
- 脚本：`res://EnemyModule/Formal/Enemy_CyberBull.gd`
- 配置：`res://DataConfig/Enemy/CyberBullConfig.tres`
- 源朝向：`right`；镜像规则：right-facing source; flip_h mirrors to face left。
- 场景 Sprite 变换：`{"position_px":[0,0],"offset_px":[0,-12],"scale":[1,1],"centered":true}`。
- 运行时 Sprite 变换：`{"default_offset_px":[0,-12],"default_scale":[1,1],"animation_scale_overrides":{}}`。
- 碰撞契约：`{"shape":"RectangleShape2D","size_px":[48,44],"position_px":[0,-4]}`。
- 主要颜色：#E5F3F3, #E5F4F5, #E1F0F2, #E5F2F3, #EBF5F5, #A60184, #EBF6F8, #A4027B, #AE0185, #A5028E
- 风格标签：compact cyber beast, orange-brown armor, side-view pixel art, wide low silhouette

**状态到动作映射**

| 状态 | 动作 |
|---|---|
| `IDLE` | `idle` |
| `PATROL` | `walk` |
| `CHASE_MOVING` | `walk` |
| `CHASE_STILL` | `idle` |
| `ATTACK` | `attack` |
| `HURT` | `idle` |
| `DEAD` | `idle` |
| `CHARGE_WINDUP` | `attack` |
| `CHARGING` | `attack` |

**动作与图集参数**

| 动作 | 源图 | 图集 / 单元格 / 网格 | 帧序（列,行） | 场景→运行 FPS | 循环 | 运行时长度 | 底边与包围盒 | 异常 |
|---|---|---|---|---:|---|---:|---|---|
| `idle` | `res://Assets/Sprites/monster_cyber2/赛博怪物2待机.png` | 256×192 / 64×64 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 8→8 | true→true | 1.5s | bottom 49..53; bbox [5,11,57,53] | — |
| `walk` | `res://Assets/Sprites/monster_cyber2/赛博怪物2行走.png` | 256×192 / 64×64 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 10→10 | true→true | 1.2s | bottom 49..53; bbox [5,11,57,53] | — |
| `attack` | `res://Assets/Sprites/monster_cyber2/赛博怪物2攻击.png` | 256×192 / 64×64 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 15→15 | false→false | 0.8s | bottom 51..52; bbox [5,11,57,52] | — |

**运行时硬约束**

- source art faces right; flip_h is enabled when facing left
- charge windup and charging both reuse attack

**逐帧质检说明**

- `idle`：运行时根节点底边 5.0..9.0 px；最小透明边距 `{"left":5,"top":11,"right":7,"bottom":11}`；相邻 Alpha 质心最大位移 1.013 px；未用格 `[]`。
- `walk`：运行时根节点底边 5.0..9.0 px；最小透明边距 `{"left":5,"top":11,"right":7,"bottom":11}`；相邻 Alpha 质心最大位移 1.013 px；未用格 `[]`。
- `attack`：运行时根节点底边 7.0..8.0 px；最小透明边距 `{"left":5,"top":11,"right":7,"bottom":12}`；相邻 Alpha 质心最大位移 4.365 px；未用格 `[]`。

每一帧的矩形、bbox、四边留白、Alpha、质心、颜色与 SHA-256 位于 JSON 的该角色 `animations[].frame_order[]`。

### 4.3 赛博狼人（`cyber_wolf`）

- 场景：`res://EnemyModule/Formal/Enemy_CyberWolf.tscn`
- 脚本：`res://EnemyModule/Formal/Enemy_CyberWolf.gd`
- 配置：`res://DataConfig/Enemy/CyberWolfConfig.tres`
- 源朝向：`right`；镜像规则：right-facing source; flip_h mirrors to face left。
- 场景 Sprite 变换：`{"position_px":[0,0],"offset_px":[0,-24],"scale":[1,1],"centered":true}`。
- 运行时 Sprite 变换：`{"default_offset_px":[0,-24],"default_scale":[1,1],"animation_scale_overrides":{}}`。
- 碰撞契约：`{"shape":"RectangleShape2D","size_px":[36,60],"position_px":[0,-12]}`。
- 主要颜色：#0A0A29, #06081E, #090925, #0D0E31, #0D0B2F, #06081C, #171541, #070923, #1F254A, #252666
- 风格标签：cyan cyber wolf, dark mechanical body, side-view pixel art, lean upright silhouette

**状态到动作映射**

| 状态 | 动作 |
|---|---|
| `IDLE` | `idle` |
| `PATROL` | `walk` |
| `CHASE_MOVING` | `walk` |
| `CHASE_STILL` | `idle` |
| `ATTACK` | `attack` |
| `HURT` | `idle` |
| `DEAD` | `idle` |

**动作与图集参数**

| 动作 | 源图 | 图集 / 单元格 / 网格 | 帧序（列,行） | 场景→运行 FPS | 循环 | 运行时长度 | 底边与包围盒 | 异常 |
|---|---|---|---|---:|---|---:|---|---|
| `idle` | `res://Assets/Sprites/monster_cyber1/赛博怪物1待机.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 8→8 | true→true | 1.5s | bottom 108..108; bbox [20,24,88,108] | — |
| `walk` | `res://Assets/Sprites/monster_cyber1/赛博怪物1行走.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 10→10 | true→true | 1.2s | bottom 106..108; bbox [18,22,99,108] | — |
| `attack` | `res://Assets/Sprites/monster_cyber1/赛博怪物1攻击.png` | 512×512 / 128×128 / 4×4 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) (0,3) (1,3) (2,3) (3,3) | 18→18 | false→false | 0.889s | bottom 106..108; bbox [18,20,128,108] | 触边=right:4,5,14,15 |

**运行时硬约束**

- attack remains selected only while attack_animation_duration=0.4 seconds
- source art faces right; flip_h is enabled when facing left

**逐帧质检说明**

- `idle`：运行时根节点底边 20.0..20.0 px；最小透明边距 `{"left":20,"top":24,"right":40,"bottom":20}`；相邻 Alpha 质心最大位移 1.619 px；未用格 `[]`。
- `walk`：运行时根节点底边 18.0..20.0 px；最小透明边距 `{"left":18,"top":22,"right":29,"bottom":20}`；相邻 Alpha 质心最大位移 3.627 px；未用格 `[]`。
- `attack`：运行时根节点底边 18.0..20.0 px；最小透明边距 `{"left":18,"top":20,"right":0,"bottom":20}`；相邻 Alpha 质心最大位移 19.66 px；未用格 `[]`。

每一帧的矩形、bbox、四边留白、Alpha、质心、颜色与 SHA-256 位于 JSON 的该角色 `animations[].frame_order[]`。

### 4.4 爷爷 NPC（`grandpa_npc`）

- 场景：`res://LevelModule/Formal/Level_03.tscn`；`res://LevelModule/Formal/Level_05.tscn`
- 脚本：无独立角色脚本
- 配置：无独立配置
- 源朝向：`right`；镜像规则：both embedded instances mirror with negative scale.x。
- 场景 Sprite 变换：`{"position_px":[0,0],"offset_px":[0,0],"scale":[-1.7187505,1.7187505],"centered":true}`。
- 运行时 Sprite 变换：`{"default_offset_px":[0,0],"default_scale":[-1.7187505,1.7187505],"animation_scale_overrides":{}}`。
- 碰撞契约：`null`。
- 主要颜色：#19181F, #2F2D34, #E6EBEC, #E4ECEE, #E5A06D, #E2E9EB, #E29E6D, #29282E, #E4A271, #16161C
- 风格标签：elderly Lingnan NPC, small side-view pixel art, neutral standing idle

**状态到动作映射**

| 状态 | 动作 |
|---|---|
| `AUTOPLAY` | `idle` |

**动作与图集参数**

| 动作 | 源图 | 图集 / 单元格 / 网格 | 帧序（列,行） | 场景→运行 FPS | 循环 | 运行时长度 | 底边与包围盒 | 异常 |
|---|---|---|---|---:|---|---:|---|---|
| `idle` | `res://Assets/Sprites/grandpa/爷爷待机.png` | 256×192 / 64×64 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 8→8 | true→true | 1.5s | bottom 51..51; bbox [24,12,40,51] | — |

**运行时硬约束**

- the same SpriteFrames definition is duplicated in Level_03 and Level_05
- there is no standalone Grandpa scene

**逐帧质检说明**

- `idle`：运行时根节点底边 32.656..32.656 px；最小透明边距 `{"left":24,"top":12,"right":24,"bottom":13}`；相邻 Alpha 质心最大位移 0.561 px；未用格 `[]`。

每一帧的矩形、bbox、四边留白、Alpha、质心、颜色与 SHA-256 位于 JSON 的该角色 `animations[].frame_order[]`。

### 4.5 灯笼鬼（`lantern_ghost`）

- 场景：`res://EnemyModule/Formal/Enemy_LanternGhost.tscn`
- 脚本：`res://EnemyModule/Formal/Enemy_LanternGhost.gd`
- 配置：`res://DataConfig/Enemy/LanternGhostConfig.tres`
- 源朝向：`right`；镜像规则：right-facing source; flip_h mirrors to face left。
- 场景 Sprite 变换：`{"position_px":[0,0],"offset_px":[0,-16],"scale":[1,1],"centered":true}`。
- 运行时 Sprite 变换：`{"default_offset_px":[0,-16],"default_scale":[1,1],"animation_scale_overrides":{}}`。
- 碰撞契约：`{"shape":"RectangleShape2D","size_px":[32,40],"position_px":[0,0]}`。
- 主要颜色：#4C1016, #861726, #471117, #851A25, #49131A, #AE2329, #441017, #B1252B, #53151A, #4E0F15
- 风格标签：Lingnan lantern spirit, warm orange glow, small floating side-view pixel art

**状态到动作映射**

| 状态 | 动作 |
|---|---|
| `IDLE` | `idle` |
| `PATROL` | `idle` |
| `CHASE` | `idle` |
| `ATTACK` | `attack` |
| `HURT` | `idle` |
| `DEAD` | `idle` |

**动作与图集参数**

| 动作 | 源图 | 图集 / 单元格 / 网格 | 帧序（列,行） | 场景→运行 FPS | 循环 | 运行时长度 | 底边与包围盒 | 异常 |
|---|---|---|---|---:|---|---:|---|---|
| `attack` | `res://Assets/Sprites/monster_Lingnan2/岭南怪物2攻击.png` | 256×192 / 64×64 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 14→14 | false→false | 0.857s | bottom 46..61; bbox [13,10,49,61] | — |
| `idle` | `res://Assets/Sprites/monster_Lingnan2/岭南怪物2待机.png` | 256×192 / 64×64 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 8→8 | true→true | 1.5s | bottom 58..62; bbox [20,10,46,62] | — |

**运行时硬约束**

- no walk animation is required by current code
- source art faces right; flip_h is enabled when facing left

**逐帧质检说明**

- `attack`：运行时根节点底边 -2.0..13.0 px；最小透明边距 `{"left":13,"top":10,"right":15,"bottom":3}`；相邻 Alpha 质心最大位移 7.401 px；未用格 `[]`。
- `idle`：运行时根节点底边 10.0..14.0 px；最小透明边距 `{"left":20,"top":10,"right":18,"bottom":2}`；相邻 Alpha 质心最大位移 1.108 px；未用格 `[]`。

每一帧的矩形、bbox、四边留白、Alpha、质心、颜色与 SHA-256 位于 JSON 的该角色 `animations[].frame_order[]`。

### 4.6 纸符人（`paper_effigy`）

- 场景：`res://EnemyModule/Formal/Enemy_PaperEffigy.tscn`
- 脚本：`res://EnemyModule/Formal/Enemy_PaperEffigy.gd`
- 配置：`res://DataConfig/Enemy/PaperEffigyConfig.tres`
- 源朝向：`right`；镜像规则：right-facing source; flip_h mirrors to face left。
- 场景 Sprite 变换：`{"position_px":[0,0],"offset_px":[0,-24],"scale":[1,1],"centered":true}`。
- 运行时 Sprite 变换：`{"default_offset_px":[0,-24],"default_scale":[1,1],"animation_scale_overrides":{}}`。
- 碰撞契约：`{"shape":"RectangleShape2D","size_px":[36,60],"position_px":[0,-12]}`。
- 主要颜色：#FEFEFF, #FFFFFF, #FEFEFE, #F9FAFC, #C0C3CA, #F9FAFB, #FAFBFC, #C0C3C8, #BCC0C6, #BABEC4
- 风格标签：pale paper talisman humanoid, muted cream and red, side-view pixel art, thin upright silhouette

**状态到动作映射**

| 状态 | 动作 |
|---|---|
| `IDLE` | `idle` |
| `PATROL` | `walk` |
| `CHASE_MOVING` | `walk` |
| `CHASE_STILL` | `idle` |
| `ATTACK` | `attack` |
| `HURT` | `idle` |
| `DEAD` | `idle` |

**动作与图集参数**

| 动作 | 源图 | 图集 / 单元格 / 网格 | 帧序（列,行） | 场景→运行 FPS | 循环 | 运行时长度 | 底边与包围盒 | 异常 |
|---|---|---|---|---:|---|---:|---|---|
| `idle` | `res://Assets/Sprites/monster_lingnan1/岭南怪物1待机.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 8→8 | true→true | 1.5s | bottom 104..104; bbox [36,22,96,104] | 路径大小写错误 |
| `walk` | `res://Assets/Sprites/monster_lingnan1/岭南怪物1行走.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 10→10 | true→true | 1.2s | bottom 102..104; bbox [36,20,96,104] | 路径大小写错误 |
| `attack` | `res://Assets/Sprites/monster_lingnan1/岭南怪物1攻击.png` | 512×512 / 128×128 / 4×4 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) (0,3) (1,3) (2,3) (3,3) | 18→18 | false→false | 0.889s | bottom 104..104; bbox [12,18,126,104] | 路径大小写错误 |

**运行时硬约束**

- attack remains selected only while attack_animation_duration=0.4 seconds
- all three scene texture paths currently use the wrong directory case monster_lingnan1

**逐帧质检说明**

- `idle`：运行时根节点底边 16.0..16.0 px；最小透明边距 `{"left":36,"top":22,"right":32,"bottom":24}`；相邻 Alpha 质心最大位移 2.673 px；未用格 `[]`。
- `walk`：运行时根节点底边 14.0..16.0 px；最小透明边距 `{"left":36,"top":20,"right":32,"bottom":24}`；相邻 Alpha 质心最大位移 3.604 px；未用格 `[]`。
- `attack`：运行时根节点底边 16.0..16.0 px；最小透明边距 `{"left":12,"top":18,"right":2,"bottom":24}`；相邻 Alpha 质心最大位移 21.803 px；未用格 `[]`。

每一帧的矩形、bbox、四边留白、Alpha、质心、颜色与 SHA-256 位于 JSON 的该角色 `animations[].frame_order[]`。

### 4.7 基础战士（`player_warrior_base`）

- 场景：`res://PlayerModule/Formal/Player_Warrior.tscn`
- 脚本：`res://PlayerModule/Formal/Player_Warrior.gd`
- 配置：`res://DataConfig/Player/WarriorConfig.tres`
- 源朝向：`right`；镜像规则：right-facing source; flip_h mirrors to face left。
- 场景 Sprite 变换：`{"position_px":[0,0.5],"offset_px":[0,0],"scale":[1,1],"centered":true}`。
- 运行时 Sprite 变换：`{"default_offset_px":[0,-10],"default_scale":[1,1],"animation_scale_overrides":{}}`。
- 碰撞契约：`{"shape":"RectangleShape2D","size_px":[50,60],"position_px":[0,0]}`。
- 主要颜色：#121E42, #2B4372, #131F42, #111F42, #111E3F, #2A426F, #2B4371, #2C4574, #28426F, #111D3E
- 风格标签：slim dark-clothed warrior, side-view pixel art, small readable silhouette

**状态到动作映射**

| 状态 | 动作 |
|---|---|
| `IDLE` | `idle` |
| `RUN` | `walk` |
| `JUMP` | `jump` |
| `FALL` | `jump` |
| `DASH` | `idle` |
| `ATTACK` | `attack->idle fallback` |
| `SKILL` | `idle` |
| `HURT` | `idle` |
| `DEAD` | `idle` |

**动作与图集参数**

| 动作 | 源图 | 图集 / 单元格 / 网格 | 帧序（列,行） | 场景→运行 FPS | 循环 | 运行时长度 | 底边与包围盒 | 异常 |
|---|---|---|---|---:|---|---:|---|---|
| `idle` | `res://Assets/Sprites/player Ani/人物待机.png` | 512×512 / 128×128 / 4×4 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 6→6 | true→true | 2s | bottom 108..108; bbox [46,26,80,108] | — |
| `jump` | `res://Assets/Sprites/player Ani/人物跳跃.png` | 512×512 / 128×128 / 4×4 | (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 7→7 | true→true | 1.571s | bottom 98..108; bbox [38,24,93,108] | — |
| `walk` | `res://Assets/Sprites/player Ani/人物行走.png` | 512×512 / 128×128 / 4×4 | (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) (0,3) (1,3) (2,3) (3,3) | 6→6 | true→true | 2.333s | bottom 108..108; bbox [46,25,82,108] | — |

**运行时硬约束**

- falling with vertical speed below 400 locks jump frame index 4
- ground attack state lasts 0.35 seconds; air attack state lasts 0.45 seconds
- normal hit is requested 0.1 seconds after animation start
- attack, hit and defeated sequences are absent and fall back to idle

**逐帧质检说明**

- `idle`：运行时根节点底边 34.0..34.0 px；最小透明边距 `{"left":46,"top":26,"right":48,"bottom":20}`；相邻 Alpha 质心最大位移 0.908 px；未用格 `[[0,3],[1,3],[2,3],[3,3]]`。
- `jump`：运行时根节点底边 24.0..34.0 px；最小透明边距 `{"left":38,"top":24,"right":35,"bottom":20}`；相邻 Alpha 质心最大位移 5.735 px；未用格 `[[0,0],[0,3],[1,3],[2,3],[3,3]]`。
- `walk`：运行时根节点底边 34.0..34.0 px；最小透明边距 `{"left":46,"top":25,"right":46,"bottom":20}`；相邻 Alpha 质心最大位移 3.709 px；未用格 `[[0,0],[1,0]]`。

每一帧的矩形、bbox、四边留白、Alpha、质心、颜色与 SHA-256 位于 JSON 的该角色 `animations[].frame_order[]`。

### 4.8 赛博战士（`player_warrior_cyber`）

- 场景：`res://PlayerModule/Formal/Player_Warrior_Cyber.tscn`
- 脚本：`res://PlayerModule/Formal/Player_Warrior_Cyber.gd`
- 配置：`res://DataConfig/Player/WarriorConfig.tres`
- 源朝向：`right`；镜像规则：right-facing source; flip_h mirrors to face left。
- 场景 Sprite 变换：`{"position_px":[0,0],"offset_px":[0,0],"scale":[1,1],"centered":true}`。
- 运行时 Sprite 变换：`{"default_offset_px":[0,-10],"default_scale":[1,1],"animation_scale_overrides":{}}`。
- 碰撞契约：`{"shape":"RectangleShape2D","size_px":[50,60],"position_px":[0,0]}`。
- 主要颜色：#161230, #161433, #1D1B3D, #171536, #1E1C3E, #1B1736, #13102F, #1B1C3E, #A8B9CE, #A4B6CB
- 风格标签：black and cyan cyber warrior, electric blue highlights, side-view pixel art, compact athletic silhouette

**状态到动作映射**

| 状态 | 动作 |
|---|---|
| `IDLE` | `idle` |
| `RUN` | `walk` |
| `JUMP` | `jump` |
| `FALL` | `jump` |
| `DASH` | `idle` |
| `ATTACK_GROUND` | `attack` |
| `ATTACK_AIR` | `attack_in_air` |
| `SKILL` | `attack` |
| `HURT` | `hit` |
| `DEAD` | `defeated` |

**动作与图集参数**

| 动作 | 源图 | 图集 / 单元格 / 网格 | 帧序（列,行） | 场景→运行 FPS | 循环 | 运行时长度 | 底边与包围盒 | 异常 |
|---|---|---|---|---:|---|---:|---|---|
| `attack` | `res://Assets/Sprites/player_cyber Ani/赛博人物攻击.png` | 512×256 / 128×128 / 4×2 | (0,0) (2,0) (1,1) (2,1) (3,1) | 18→18 | false→false | 0.278s | bottom 106..106; bbox [38,14,126,106] | — |
| `attack_in_air` | `res://Assets/Sprites/player_cyber Ani/赛博人物空中攻击.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (0,1) (3,0) (2,0) | 5→18 | false→false | 0.278s | bottom 100..102; bbox [2,9,124,102] | — |
| `defeated` | `res://Assets/Sprites/player_cyber Ani/赛博人物失败.png` | 512×512 / 128×128 / 4×4 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) (0,3) (1,3) (2,3) (3,3) | 12→12 | false→false | 1.333s | bottom 106..110; bbox [28,26,115,110] | — |
| `hit` | `res://Assets/Sprites/player_cyber Ani/赛博人物受击.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 12→12 | true→true | 1s | bottom 106..107; bbox [25,26,110,107] | — |
| `idle` | `res://Assets/Sprites/player_cyber Ani/赛博人物待机.png` | 512×512 / 128×128 / 4×4 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) (0,3) (1,3) (2,3) (3,3) | 8→8 | true→true | 2s | bottom 106..106; bbox [40,25,102,106] | — |
| `jump` | `res://Assets/Sprites/player_cyber Ani/赛博人物跳跃.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 6→6 | true→true | 2s | bottom 98..106; bbox [1,21,102,106] | — |
| `walk` | `res://Assets/Sprites/player_cyber Ani/赛博人物行走.png` | 512×512 / 128×128 / 4×4 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) (0,3) (1,3) (2,3) (3,3) | 5→5 | true→true | 3.2s | bottom 106..106; bbox [40,25,111,106] | — |

**运行时硬约束**

- falling with vertical speed below 400 locks jump frame index 4
- attack frame index 2 is hard-frozen for charge and several skill paths
- attack_in_air is forced to 18 fps
- normal cyber hit occurs about 0.2 seconds after animation start: 0.1 base windup plus 0.1 subclass delay
- ground attack state lasts 0.35 seconds; air attack state lasts 0.45 seconds
- defeated stops on its last frame

**逐帧质检说明**

- `attack`：运行时根节点底边 32.0..32.0 px；最小透明边距 `{"left":38,"top":14,"right":2,"bottom":22}`；相邻 Alpha 质心最大位移 12.82 px；未用格 `[[1,0],[3,0],[0,1]]`。
- `attack_in_air`：运行时根节点底边 26.0..28.0 px；最小透明边距 `{"left":2,"top":9,"right":4,"bottom":26}`；相邻 Alpha 质心最大位移 24.464 px；未用格 `[[1,1],[2,1],[3,1],[0,2],[1,2],[2,2],[3,2]]`。
- `defeated`：运行时根节点底边 32.0..36.0 px；最小透明边距 `{"left":28,"top":26,"right":13,"bottom":18}`；相邻 Alpha 质心最大位移 3.606 px；未用格 `[]`。
- `hit`：运行时根节点底边 32.0..33.0 px；最小透明边距 `{"left":25,"top":26,"right":18,"bottom":21}`；相邻 Alpha 质心最大位移 4.168 px；未用格 `[]`。
- `idle`：运行时根节点底边 32.0..32.0 px；最小透明边距 `{"left":40,"top":25,"right":26,"bottom":22}`；相邻 Alpha 质心最大位移 1.556 px；未用格 `[]`。
- `jump`：运行时根节点底边 24.0..32.0 px；最小透明边距 `{"left":1,"top":21,"right":26,"bottom":22}`；相邻 Alpha 质心最大位移 5.396 px；未用格 `[]`。
- `walk`：运行时根节点底边 32.0..32.0 px；最小透明边距 `{"left":40,"top":25,"right":17,"bottom":22}`；相邻 Alpha 质心最大位移 3.314 px；未用格 `[]`。

每一帧的矩形、bbox、四边留白、Alpha、质心、颜色与 SHA-256 位于 JSON 的该角色 `animations[].frame_order[]`。

### 4.9 岭南战士（`player_warrior_lingnan`）

- 场景：`res://PlayerModule/Formal/Player_Warrior_Lingnan.tscn`
- 脚本：`res://PlayerModule/Formal/Player_Warrior_Lingnan.gd`
- 配置：`res://DataConfig/Player/WarriorConfig.tres`
- 源朝向：`right`；镜像规则：right-facing source; flip_h mirrors to face left。
- 场景 Sprite 变换：`{"position_px":[0,0],"offset_px":[0,0],"scale":[1,1],"centered":true}`。
- 运行时 Sprite 变换：`{"default_offset_px":[0,-10],"default_scale":[1,1],"animation_scale_overrides":{}}`。
- 碰撞契约：`{"shape":"RectangleShape2D","size_px":[50,60],"position_px":[0,0]}`。
- 主要颜色：#F5ECCD, #F3E8C8, #F6ECCB, #F4EACA, #F7EECE, #131A23, #1D1D32, #F8EECE, #1B1A2E, #2E314A
- 风格标签：Lingnan folk warrior, cream red and teal garments, side-view pixel art, compact human silhouette

**状态到动作映射**

| 状态 | 动作 |
|---|---|
| `IDLE` | `idle` |
| `RUN` | `walk` |
| `JUMP` | `jump` |
| `FALL` | `jump` |
| `DASH` | `idle` |
| `ATTACK_GROUND` | `attack` |
| `ATTACK_AIR` | `attack_in_air` |
| `SKILL` | `attack` |
| `HURT` | `hit` |
| `DEAD` | `defeated` |

**动作与图集参数**

| 动作 | 源图 | 图集 / 单元格 / 网格 | 帧序（列,行） | 场景→运行 FPS | 循环 | 运行时长度 | 底边与包围盒 | 异常 |
|---|---|---|---|---:|---|---:|---|---|
| `attack` | `res://Assets/Sprites/player_lingnan Ani/岭南人物攻击.png` | 512×256 / 128×128 / 4×2 | (1,0) (2,0) (0,1) (1,1) (2,1) | 20→20 | false→false | 0.25s | bottom 102..102; bbox [26,28,120,102] | — |
| `attack_in_air` | `res://Assets/Sprites/player_lingnan Ani/岭南人物空中攻击.png` | 512×256 / 128×128 / 4×2 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) | 10→18 | false→false | 0.444s | bottom 102..111; bbox [17,15,127,111] | 空白帧=7 |
| `defeated` | `res://Assets/Sprites/player_lingnan Ani/岭南人物失败.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 8→8 | false→false | 1.5s | bottom 102..105; bbox [24,30,114,105] | — |
| `hit` | `res://Assets/Sprites/player_lingnan Ani/岭南人物受击.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 10→10 | false→false | 1.2s | bottom 102..102; bbox [29,30,99,102] | — |
| `idle` | `res://Assets/Sprites/player_lingnan Ani/岭南人物待机.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 8→8 | true→true | 1.5s | bottom 102..102; bbox [48,30,90,102] | — |
| `jump` | `res://Assets/Sprites/player_lingnan Ani/岭南人物跳跃.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 6→6 | true→true | 2s | bottom 92..102; bbox [31,25,96,102] | — |
| `walk` | `res://Assets/Sprites/player_lingnan Ani/岭南人物行走.png` | 512×384 / 128×128 / 4×3 | (0,0) (1,0) (2,0) (3,0) (0,1) (1,1) (2,1) (3,1) (0,2) (1,2) (2,2) (3,2) | 8→8 | true→true | 1.5s | bottom 102..102; bbox [48,29,97,102] | — |

**运行时硬约束**

- falling with vertical speed below 400 locks jump frame index 4
- CHARGE_FREEZE_FRAME is hard-coded to attack frame index 2
- attack_in_air is forced to 18 fps
- normal hit is requested 0.1 seconds after animation start
- ground attack state lasts 0.35 seconds; air attack state lasts 0.45 seconds
- defeated stops on its last frame

**逐帧质检说明**

- `attack`：运行时根节点底边 28.0..28.0 px；最小透明边距 `{"left":26,"top":28,"right":8,"bottom":26}`；相邻 Alpha 质心最大位移 22.968 px；未用格 `[[0,0],[3,0],[3,1]]`。
- `attack_in_air`：运行时根节点底边 28.0..37.0 px；最小透明边距 `{"left":17,"top":15,"right":1,"bottom":17}`；相邻 Alpha 质心最大位移 17.212 px；未用格 `[]`。
- `defeated`：运行时根节点底边 28.0..31.0 px；最小透明边距 `{"left":24,"top":30,"right":14,"bottom":23}`；相邻 Alpha 质心最大位移 7.366 px；未用格 `[]`。
- `hit`：运行时根节点底边 28.0..28.0 px；最小透明边距 `{"left":29,"top":30,"right":29,"bottom":26}`；相邻 Alpha 质心最大位移 5.305 px；未用格 `[]`。
- `idle`：运行时根节点底边 28.0..28.0 px；最小透明边距 `{"left":48,"top":30,"right":38,"bottom":26}`；相邻 Alpha 质心最大位移 1.681 px；未用格 `[]`。
- `jump`：运行时根节点底边 18.0..28.0 px；最小透明边距 `{"left":31,"top":25,"right":32,"bottom":26}`；相邻 Alpha 质心最大位移 6.595 px；未用格 `[]`。
- `walk`：运行时根节点底边 28.0..28.0 px；最小透明边距 `{"left":48,"top":29,"right":31,"bottom":26}`；相邻 Alpha 质心最大位移 2.601 px；未用格 `[]`。

每一帧的矩形、bbox、四边留白、Alpha、质心、颜色与 SHA-256 位于 JSON 的该角色 `animations[].frame_order[]`。

## 5. 当前问题与 Harness 处置规则

| ID | 等级 | 资产 | 已确认问题 | Harness 处置 |
|---|---|---|---|---|
| `SPR-001` | **error** | `player_warrior_lingnan/attack_in_air` | Used frame index 7 at source cell [3,1] is fully transparent. | Reject a regenerated sequence containing any blank used frame; replace or intentionally remove the frame and update frame_count. |
| `SPR-002` | **error** | `paper_effigy/all` | Scene paths use monster_lingnan1 but the disk directory is monster_Lingnan1. | Emit canonical case-exact res:// paths and fail path-case validation before Linux/Web export. |
| `SPR-003` | **error** | `boss_huadan/attack` | SpriteFrames uses 15 fps, but melee hit and lock timing uses boss_attack_fps=12, hit_frame=9 and total_frames=16. Visual duration is 1.067 s; gameplay hit is at 0.75 s and lock ends at 1.333 s. | Treat timing as an explicit integration decision; do not infer gameplay timing from sheet fps. |
| `SPR-004` | **warning** | `cyber_wolf/attack and paper_effigy/attack` | Each visual has 16 frames at 18 fps (0.889 s), while code selects attack for only attack_animation_duration=0.4 s. | Place the readable contact pose within the first 0.4 s or change runtime timing separately. |
| `SPR-005` | **warning** | `cyber_bull/idle and walk` | The two PNG files are byte-for-byte identical, so movement has no distinct walk cycle. | Generate a distinct walk cycle while preserving the 64x64, 12-frame, 4x3 contract. |
| `SPR-006` | **warning** | `player_warrior_cyber/hit` | The hit animation is configured to loop even though it represents a transient state. | Preserve current behavior for compatibility unless the integration task explicitly changes the loop flag. |
| `SPR-007` | **warning** | `player_warrior_base` | Only idle, walk and jump exist. ATTACK resolves to idle fallback; HURT and DEAD are also mapped to idle. | Do not claim full action coverage for the base player. Add actions only through a separately approved scene integration change. |
| `SPR-008` | **warning** | `cyber_wolf/attack` | Frames 4, 5, 14 and 15 touch the right cell edge, creating crop risk. | New outputs should keep at least 1 transparent pixel on every cell edge; current frames are legacy exceptions. |
| `SPR-009` | **info** | `monster_cyber1/赛博怪物1跳跃.png` | A 512x384, 12-cell jump sheet exists but no current SpriteFrames resource references it. | Keep it as an unused candidate; do not add it to the scene automatically. |
| `SPR-010` | **info** | `boss_huadan/dizziness and defeated` | Both animation names use the same sheet, same cells and same runtime playback parameters. | Allow aliasing, but do not count the two names as two independent generated motions. |
| `SPR-011` | **info** | `multiple player and boss sheets` | Several animations skip cells or use non-row-major order. Empty/unused cells are part of the current file format. | Consume frame_order/source_region_px from this manifest; never infer order from frame_count alone. |
| `SPR-012` | **info** | `grandpa_npc` | Identical SpriteFrames data is embedded separately in Level_03 and Level_05. | A texture replacement affects both, but a SpriteFrames edit must be applied to both owner scenes unless the project later creates a shared NPC scene. |

### 5.1 需要优先解决的四个阻塞点

1. **岭南空中攻击第 7 号帧为空白。** 这是现成数据错误，不是模型风格问题；Harness 必须在组装前拦截。
2. **纸符人资源路径大小写不一致。** Windows 上可能正常，Linux/Web 导出可能失效；清单同时保留场景原路径和规范路径。
3. **Boss 攻击的视觉 FPS 与判定 FPS 不一致。** 单纯换图无法解决，生成时必须让 0.75 秒附近仍是可读命中姿态，或另开代码调整任务。
4. **赛博狼/纸符人完整攻击时长 0.889 秒，但运行时只保留 0.4 秒。** 新序列的关键动作必须压进前 7 帧左右；否则后半段永远看不到。

## 6. 共享视觉与资产缺口

### 6.1 同一序列帧被多个数值配置复用

| 变体 | 配置 | 实际场景/资产 | 调色 |
|---|---|---|---|
| `street_slime_variant` | `res://DataConfig/Enemy/StreetSlimeConfig.tres` | `res://EnemyModule/Formal/Enemy_LanternGhost.tscn` / `lantern_ghost` | `null` |
| `shadow_variant` | `res://DataConfig/Enemy/ShadowConfig.tres` | `res://EnemyModule/Formal/Enemy_LanternGhost.tscn` / `lantern_ghost` | `[0,0,0,0.9]` |
| `cleaner_variant` | `res://DataConfig/Enemy/CleanerConfig.tres` | `res://EnemyModule/Formal/Enemy_CyberWolf.tscn` / `cyber_wolf` | `[[0.3,0.35,0.4,0.95],[0.3,0.3,0.35,0.95],[0.2,0.15,0.35,0.95]]` |
| `security_variant` | `res://DataConfig/Enemy/SecurityConfig.tres` | `res://EnemyModule/Formal/Enemy_CyberWolf.tscn` / `cyber_wolf` | `[0.9,0.15,0.15,0.95]` |

这些名称不是独立美术资产。尤其 `StreetSlimeConfig` 实际加载的是灯笼鬼场景，Cleaner/Security 实际复用赛博狼并通过 `modulate` 改色。Harness 不应把配置文件数量当成待生成人物数量。

### 6.2 明确缺口

- `enemy_slime`：placeholder_only。No AnimatedSprite2D or SpriteFrames exists. It appears in TestArena, not as a dedicated current sequence asset.
- `base_player_missing_actions`：partial_sequence_set。Runtime safely falls back to idle for absent named animations except attack_in_air, which is checked before use.

## 7. 全部 Sprite PNG 登记表

状态含义：`sequence_used` 为当前 SpriteFrames 使用；`script_auxiliary` 为脚本直接加载的技能图；`unused_candidate` 为存在但未接入。路径以规范大小写列出。

| 状态 | 规范资源路径 | 尺寸 | 字节 | 可见覆盖率 | 可见 RGB 数 | 使用帧数 | SHA-256 前 12 位 |
|---|---|---:|---:|---:|---:|---:|---|
| `sequence_used` | `res://Assets/Sprites/boss_huadan/boss待机.png` | 512×384 | 152957 | 0.323 | 128 | 12 | `9ea495012d3f` |
| `sequence_used` | `res://Assets/Sprites/boss_huadan/boss悬空.png` | 1024×1024 | 917190 | 0.363 | 139155 | 1 | `5264bd6a34df` |
| `sequence_used` | `res://Assets/Sprites/boss_huadan/boss攻击.png` | 1024×1024 | 269777 | 0.092 | 128 | 16 | `29ecb78cf716` |
| `sequence_used` | `res://Assets/Sprites/boss_huadan/boss眩晕.png` | 1024×768 | 204042 | 0.083 | 128 | 24 | `eb59d056b66b` |
| `sequence_used` | `res://Assets/Sprites/boss_huadan/boss行走.png` | 512×384 | 168525 | 0.339 | 128 | 9 | `4fb64f077df6` |
| `sequence_used` | `res://Assets/Sprites/grandpa/爷爷待机.png` | 256×192 | 14166 | 0.107 | 112 | 24 | `86782a9b34e9` |
| `sequence_used` | `res://Assets/Sprites/monster_Lingnan1/岭南怪物1待机.png` | 512×384 | 35645 | 0.129 | 120 | 12 | `da76ab5d4f05` |
| `sequence_used` | `res://Assets/Sprites/monster_Lingnan1/岭南怪物1攻击.png` | 512×512 | 52463 | 0.141 | 127 | 16 | `5977eb2845fb` |
| `sequence_used` | `res://Assets/Sprites/monster_Lingnan1/岭南怪物1行走.png` | 512×384 | 37554 | 0.122 | 124 | 12 | `62da5fd04197` |
| `sequence_used` | `res://Assets/Sprites/monster_Lingnan2/岭南怪物2待机.png` | 256×192 | 18065 | 0.148 | 128 | 12 | `b47d725dbe6d` |
| `sequence_used` | `res://Assets/Sprites/monster_Lingnan2/岭南怪物2攻击.png` | 256×192 | 20548 | 0.148 | 128 | 12 | `ea2e881b774d` |
| `sequence_used` | `res://Assets/Sprites/monster_cyber1/赛博怪物1待机.png` | 512×384 | 57620 | 0.191 | 128 | 12 | `9504a6dafd7c` |
| `sequence_used` | `res://Assets/Sprites/monster_cyber1/赛博怪物1攻击.png` | 512×512 | 87136 | 0.186 | 129 | 16 | `5889cf21d197` |
| `sequence_used` | `res://Assets/Sprites/monster_cyber1/赛博怪物1行走.png` | 512×384 | 71168 | 0.192 | 128 | 12 | `9edc7ff21b7c` |
| `unused_candidate` | `res://Assets/Sprites/monster_cyber1/赛博怪物1跳跃.png` | 512×384 | 63012 | 0.177 | 128 | 0 | `acf1893bbf8d` |
| `sequence_used` | `res://Assets/Sprites/monster_cyber2/赛博怪物2待机.png` | 256×192 | 29494 | 0.305 | 123 | 12 | `88bd43663b1a` |
| `sequence_used` | `res://Assets/Sprites/monster_cyber2/赛博怪物2攻击.png` | 256×192 | 29482 | 0.298 | 122 | 12 | `dc6c39b6c1a4` |
| `sequence_used` | `res://Assets/Sprites/monster_cyber2/赛博怪物2行走.png` | 256×192 | 29494 | 0.305 | 123 | 12 | `88bd43663b1a` |
| `sequence_used` | `res://Assets/Sprites/player Ani/人物待机.png` | 512×512 | 50981 | 0.104 | 116 | 12 | `aa786806e1a1` |
| `sequence_used` | `res://Assets/Sprites/player Ani/人物行走.png` | 512×512 | 42300 | 0.100 | 124 | 14 | `ee91edbcc630` |
| `sequence_used` | `res://Assets/Sprites/player Ani/人物跳跃.png` | 512×512 | 46790 | 0.101 | 120 | 11 | `4487f04126da` |
| `script_auxiliary` | `res://Assets/Sprites/player_cyber Ani/技能二.png` | 2132×1302 | 877298 | 0.186 | 115385 | 0 | `f23e0969f595` |
| `script_auxiliary` | `res://Assets/Sprites/player_cyber Ani/技能二1.png` | 2848×1600 | 1258610 | 0.136 | 135654 | 0 | `8a4590fbc4ef` |
| `sequence_used` | `res://Assets/Sprites/player_cyber Ani/赛博人物受击.png` | 512×384 | 62068 | 0.111 | 128 | 12 | `bfaf94f6d86b` |
| `sequence_used` | `res://Assets/Sprites/player_cyber Ani/赛博人物失败.png` | 512×512 | 73421 | 0.101 | 128 | 16 | `500c86747f8b` |
| `sequence_used` | `res://Assets/Sprites/player_cyber Ani/赛博人物待机.png` | 512×512 | 51915 | 0.108 | 128 | 16 | `3ddf1d98a9ab` |
| `sequence_used` | `res://Assets/Sprites/player_cyber Ani/赛博人物攻击.png` | 512×256 | 34013 | 0.110 | 127 | 5 | `e1357c3f0b57` |
| `sequence_used` | `res://Assets/Sprites/player_cyber Ani/赛博人物空中攻击.png` | 512×384 | 53926 | 0.129 | 128 | 5 | `fcee473af1c5` |
| `sequence_used` | `res://Assets/Sprites/player_cyber Ani/赛博人物行走.png` | 512×512 | 64115 | 0.100 | 128 | 16 | `453ebd937d0a` |
| `sequence_used` | `res://Assets/Sprites/player_cyber Ani/赛博人物跳跃.png` | 512×384 | 49631 | 0.100 | 128 | 12 | `369144d7fc7e` |
| `sequence_used` | `res://Assets/Sprites/player_lingnan Ani/岭南人物受击.png` | 512×384 | 38194 | 0.091 | 123 | 12 | `cb5f569c15c8` |
| `sequence_used` | `res://Assets/Sprites/player_lingnan Ani/岭南人物失败.png` | 512×384 | 39339 | 0.086 | 127 | 12 | `f5df39541aae` |
| `sequence_used` | `res://Assets/Sprites/player_lingnan Ani/岭南人物待机.png` | 512×384 | 32412 | 0.085 | 117 | 12 | `ad2fc05655ce` |
| `sequence_used` | `res://Assets/Sprites/player_lingnan Ani/岭南人物攻击.png` | 512×256 | 22739 | 0.097 | 124 | 5 | `510b67f22e2b` |
| `sequence_used` | `res://Assets/Sprites/player_lingnan Ani/岭南人物空中攻击.png` | 512×256 | 23122 | 0.103 | 127 | 8 | `22f40378cd89` |
| `sequence_used` | `res://Assets/Sprites/player_lingnan Ani/岭南人物行走.png` | 512×384 | 29156 | 0.079 | 116 | 12 | `ba993526dc90` |
| `sequence_used` | `res://Assets/Sprites/player_lingnan Ani/岭南人物跳跃.png` | 512×384 | 30479 | 0.083 | 123 | 12 | `9cb6e3d114f5` |

### 7.1 资源级特殊情况

- `赛博怪物2待机.png` 与 `赛博怪物2行走.png` 文件哈希相同，是完全相同的文件内容。
- `赛博怪物1跳跃.png` 当前未被任何 SpriteFrames 或脚本引用。
- `技能二.png`（2132×1302）与 `技能二1.png`（2848×1600）是赛博角色脚本专用技能图片，不是序列帧图集；不得按 128×128 切片。
- 纸符人三个物理文件位于 `monster_Lingnan1`，场景引用却写成 `monster_lingnan1`。

## 8. Harness 自动验收规则

- **error / `VAL-001`**：Output must be PNG RGBA with transparent background, exact sheet dimensions, exact cell size and exact used source regions from the selected animation record.
- **error / `VAL-002`**：Every used frame must contain at least one visible pixel; unused cells may remain fully transparent.
- **error / `VAL-003`**：Resource paths must match disk case exactly and stay under res://Assets/Sprites/.
- **error / `VAL-004`**：Player jump must contain a valid frame index 4 because falling code freezes that frame.
- **error / `VAL-005`**：Cyber and Lingnan player attack must contain a valid, readable frame index 2 because charge/skill code freezes that frame.
- **warning / `VAL-006`**：New frames should keep at least one fully transparent pixel on all four cell edges; flag edge contact as crop risk.
- **warning / `VAL-007`**：For grounded idle/walk frames, compare bottom_y and effective_root_bottom_y against this manifest; investigate drift above 2 px unless the action intentionally leaves the ground.
- **warning / `VAL-008`**：Report adjacent alpha-centroid shifts and compare with quality_metrics.max_adjacent_centroid_shift_px; large jumps require visual review.
- **warning / `VAL-009`**：Preserve runtime_effective_fps and runtime_effective_loop, including code overrides; scene values alone are insufficient.
- **manual / `VAL-010`**：Review silhouette, costume, face, weapon/limb count, light direction and palette identity against the character reference sheets. Pixel statistics cannot prove identity continuity.

### 8.1 推荐的单动作处理顺序

1. 从 `characters[id]` 选择角色，再从 `animations[name]` 选择动作；禁止用文件名猜尺寸。
2. 锁定参考角色图、源朝向、单元格、帧数、帧序、运行时 FPS、循环方式和硬编码关键帧。
3. 生图模型只输出单帧候选或等宽帧带；装配器负责透明处理、尺寸归一和精确落格。
4. 逐帧执行空白、Alpha 边界、bbox、底边、质心、颜色与尺寸检查；错误项直接拒绝，warning 进入人工复核。
5. 用相邻帧 A/B 预览和整段循环预览检查身份、服装、肢体、武器、动作方向与速度。
6. 候选图集先写 staging；通过后再替换目标 PNG，并让 Godot 重导入。
7. 在对应正式场景的副本或隔离检查场景中播放全部动作；本次文档任务没有执行替换或场景写入。

### 8.2 当前项目的建议处理优先级

| 优先级 | 工作 | 原因 |
|---|---|---|
| P0 | 修复/重生成岭南 `attack_in_air`；修正纸符人路径大小写 | 当前存在确定性错误 |
| P0 | 固化赛博/岭南玩家 `attack` 的第 2 帧和 `jump` 的第 4 帧 | 代码会直接冻结这些帧 |
| P1 | 生成真正的 CyberBull `walk` | 当前与 idle 完全相同 |
| P1 | 把 CyberWolf/PaperEffigy 攻击关键姿态放进前 0.4 秒 | 当前运行时看不到完整 16 帧 |
| P1 | 对 Boss attack 明确 12/15 FPS 的最终契约 | 判定与视觉不同步 |
| P2 | 决定基础战士是否补 attack/hit/defeated | 当前允许 idle 降级，不阻塞现有运行 |
| P2 | 决定 Slime 是否需要正式序列帧 | 当前只有占位矩形，且主要出现在测试场景 |

## 9. JSON 清单结构与读取约定

顶层字段：

- `project_contract`：引擎、视口、过滤、坐标和统一导入参数。
- `summary`：覆盖数量与文件统计。
- `characters[]`：角色级场景、脚本、配置、变换、碰撞、状态映射、风格、调色板和动作。
- `characters[].animations[]`：图集、单元格、帧序、场景参数、运行时有效参数和聚合质检值。
- `characters[].animations[].frame_order[]`：逐帧规范数据；这是 Harness 装配与验收的核心。
- `visual_variants_using_shared_art[]`：数值配置与实际视觉的复用关系。
- `asset_gaps[]`：没有正式序列帧或动作不完整的对象。
- `known_issues[]`：当前资产已确认异常。
- `harness_validation_rules[]`：自动/人工验证规则。
- `texture_registry[]`：37 张物理 PNG 的完整登记、导入参数、像素指标、哈希和实际引用。

建议 Harness 使用 `id + animation.name` 作为稳定任务键，不要使用中文文件名作为业务主键；中文路径只作为 Godot 输出目标。

## 10. 变更与复审规则

- 任何 PNG、SpriteFrames、动画状态映射、运行时 FPS、Sprite offset/scale 或碰撞尺寸变化后，都应重新生成 JSON 与本文。
- 若只换画面、不改工程格式，必须保持目标动画的 sheet/cell/grid/frame_order 不变。
- 若确需改变帧数、帧序或文件尺寸，那已经是集成改动，必须同步修改 `.tscn`/脚本并单独验证，不能作为 Harness 的隐式行为。
- 本文没有替代 `TECHNICAL_ARCHITECTURE_REPORT.md`；它只描述序列帧美术输入与运行时接口，不建立新的架构契约。
