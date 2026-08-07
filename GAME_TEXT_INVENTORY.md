# 游戏内文本清单（英文版翻译前原文）

> 用途：为 `English-version` 分支建立翻译前的原文基线。
>
> 范围：正式游戏流程中玩家可见的互动文本、叙事/对话、菜单与操作界面、HUD/技能/状态文本、图鉴文本，以及单独列出的测试界面文本。
>
> 本文只做提取与分类，不做翻译，也不改动原始游戏文件。

## 1. 主菜单与全局操作界面

### 1.1 标题画面

源文件：`UI/TitleScreen.tscn`

| 节点/用途 | 原文 |
|---|---|
| 主标题（大标题，后续可按需求保留） | `织梦者` |
| 英文副标题 | `DREAM BUILDER` |
| 中文副标题 | `亲手编织家乡的梦` |
| 正式模式按钮 | `开始游戏 (正式模式)` |
| 精彩片段按钮 | `从精彩处开始` |
| 设置按钮 | `设置 (按键)` |
| 退出按钮 | `退出游戏` |

源文件：`UI/TitleScreen.gd`

- `网页版请直接关闭当前浏览器标签页`

### 1.2 暂停与游戏结束界面

源文件：`UI/HUD.gd`

| 用途 | 原文 |
|---|---|
| 暂停标题 | `游戏已暂停` |
| 暂停按钮 | `继续游戏` |
| 暂停按钮 | `按键设置` |
| 暂停按钮 | `返回主界面` |
| 失败标题 | `游戏结束` |
| 失败按钮 | `重新开始` |
| 失败按钮 | `返回主界面` |

### 1.3 按键设置界面

源文件：`UI/KeybindSettingsScreen.gd`

| 用途 | 原文 |
|---|---|
| 标题 | `按键设置` |
| 操作说明 | `点击 [修改] 后按下新按键，ESC 取消` |
| 底部按钮 | `恢复默认` |
| 底部按钮 | `返回` |
| 单项按钮 | `修改` |
| 无绑定状态 | `未绑定` |
| 等待输入状态 | `< 请按键... (ESC取消) >` |

源文件：`Global/KeybindManager.gd`

动作显示名：

- `攻击`
- `闪避`
- `技能`
- `技能2`
- `跳跃`
- `左移`
- `右移`
- `上移`
- `下移`

鼠标/手柄显示名及动态格式：

- `鼠标左键`
- `鼠标右键`
- `鼠标中键`
- `滚轮上`
- `滚轮下`
- `滚轮左`
- `滚轮右`
- `鼠标侧键1`
- `鼠标侧键2`
- `鼠标键%d`
- `手柄A`
- `手柄B`
- `手柄X`
- `手柄Y`
- `手柄选择`
- `手柄开始`
- `手柄LB`
- `手柄RB`
- `手柄键%d`
- `左摇杆左` / `左摇杆右` / `左摇杆上` / `左摇杆下`
- `右摇杆左` / `右摇杆右` / `右摇杆上` / `右摇杆下`
- `轴%d`

## 2. HUD、技能与战斗状态文本

### 2.1 通用 HUD

源文件：`UI/HUD.gd`

| 用途 | 原文/格式 |
|---|---|
| 初始生命值 | `100 / 100` |
| 动态生命值 | `%d / %d` |
| 初始计时器 | `00:00.00` |
| 动态计时器 | `%02d:%02d.%02d` |
| 技能 1 无图片占位 | `技` |
| 技能 2 占位 | `技2` |
| 蓄力攻击占位 | `蓄` |
| 冷却秒数 | `%.1f` |
| 技能按键格式 | `[%s]` |

### 2.2 技能名称

源文件：`DataConfig/Skill/SlashConfig.tres`

- `横斩`

源文件：`DataConfig/Skill/SkillConfig.gd`（资源字段默认回退值）

- `未命名技能`

### 2.3 侵蚀与 Boss HUD

源文件：`LevelModule/Formal/Level_04.gd`

- `侵蚀 0%`
- `侵蚀 %.0f%%`

源文件：`LevelModule/Formal/Level_05.gd`

- `侵蚀 %.0f%%`
- `花旦`
- `花旦  %d / %d`
- `韧性`
- `破韧`
- `按 G 切换人物外观`

### 2.4 复战进度 HUD

源文件：`LevelModule/Formal/Level_fuzhan_memory_base.gd`

- `记忆回收 Area %02d  %d / %d    击杀进度 %d / %d`

## 3. 通用互动提示与操作提示

### 3.1 第二关与现实房间

源文件：`LevelModule/Formal/Level_02.tscn`、`LevelModule/Formal/Level_02_SceneBuilder.gd`

- `按 Enter 观察`
- `按 Enter 推开`
- `按 Enter 回忆`
- `按 Enter 呼唤`

源文件：`LevelModule/Formal/Level_02_sub01.tscn`

- `按 Enter 查看`
- `按 Enter 使用`
- `按 Enter 入梦`

源文件：`LevelModule/Formal/Level_02.gd`

- `[%s] 跳跃    [%s] 攻击    [%s] 冲刺    [%s] 技能`

源文件：`LevelModule/Formal/Level_02_03.gd`

- `长按【Tab】睁开眼睛`
- `按 Enter 确认对话...`
- `输入消息，按 Enter 发送...`

### 3.2 第三至第五关

源文件：`LevelModule/Formal/Level_03.tscn`、`LevelModule/Formal/Level_03_SceneBuilder.gd`

- `按 Enter 与爷爷对话`
- `按 Enter 触碰记忆`
- `[Error_Data: 建议立刻清除]`

源文件：`LevelModule/Formal/Level_04.tscn`

- `按 Enter 互动`

源文件：`LevelModule/Formal/Level_05.tscn`

- `按 Enter 与爷爷对话`
- `按 Enter 进入深处`

源文件：`LevelModule/Formal/Level_05.gd`

- `按 Enter 拾起灯笼`

### 3.3 掉落物

源文件：`Tools/DropItem.gd`

- `按 Enter 拾取`

### 3.4 通用互动默认值

源文件：`LevelModule/Formal/InteractiveObject.gd`

- `按 Enter 交互`

## 4. 第一关：现实房间与 CodeBuddy

### 4.1 房间互动叙事

源文件：`DataConfig/Level/Level01Data.tres`

#### 纸箱

> 我亲手把这些箱子堆在门口。  
> 像一堵墙。  
> 挡住外面的课题、同学、老师，还有那些必须解释的失败。
>
> 这个房间很小。  
> 小到只要不出去，就可以假装世界也只剩这么大。

#### 脏衣服

> 廉价洗衣液、发霉泡面、冷掉的外卖味混在一起。  
> 我知道该收拾。  
> 可连把衣服捡起来这件事，都像一场考试。
>
> 算了。  
> 反正也不会有人进来。

#### 休学告知书

> 『鉴于该生心理评估结果及个人申请，予以休学一年……』  
> 纸上的字很规整。  
> 好像只是在陈述一个普通流程。  
> 可我知道。  
> 这是我从未来里退出来的证明。  
> 连站上跑道的资格，都是我自己交出去的。

#### 旧保温杯

> 杯底贴着一张发黄的字条：  
> 『阿明，广州湿冷，记得多喝热水。』  
> 爷爷的字总是歪歪扭扭。  
> 小时候我嫌他啰嗦。  
> 后来离开老街，才发现那些啰嗦是家里的声音。  
> 可现在……  
> 我有多久没给他打过电话了？

#### 睡眠循环 1

> 拉上窗帘。  
> 让白天继续被挡在外面。  
> 只要看不见太阳，今天就还没有真正开始。

#### 睡眠循环 2

> ……又是刺眼的阳光。  
> 在这个房间里，白天和黑夜有什么区别？  
> 我睡了很久。  
> 可醒来以后，事情一点也没有变少。

#### 睡眠循环 3

> 身体像灌了铅。  
> 脑子里却全是声音。  
> 辅导员、同学、妈妈、爷爷、老街拆迁的通知。  
> 除了逃避，我不知道还能做什么。  
> 起来吧。  
> 或者继续把自己埋下去。

源文件：`LevelModule/Formal/Level_01.gd`

#### 床的空闲提示

> 没什么事做。  
> 还是继续睡吧。

### 4.2 第一次 IDE 对话

源文件：`DataConfig/Level/Level01Data.tres`

对话显示前缀来自 `LevelModule/Formal/Level_01.gd`：`[SYSTEM]`、`CodeBuddy:`、`阿明:`。

1. System

   > Connecting to localhost:8080...  
   > CodeBuddy Terminal v1.4.2 initialized.

2. CodeBuddy

   > 您好，阿明。  
   > 检测到系统已有 364 小时未接收到有效编译请求。  
   > 当前情绪参数评估：极度低迷。  
   > 是否启动日常辅助对话？

3. Ming

   > 我写不出代码。  
   > 课题也做不完。  
   > 我把所有事情都搞砸了。  
   > CodeBuddy，我是不是已经没用了？

4. CodeBuddy

   > 无法从逻辑上支持该自我定义。  
   > 学业中断、社交受挫、项目延期，均属于事件结果。  
   > 它们不能直接推出“个人无价值”。  
   > 请问是否需要定位当前主要压力源？

5. Ming

   > 定位不了。  
   > 爷爷走了，老家要拆。  
   > 我却躲在这个房间里，连回去看一眼都不敢。
   >
   > 我一闭上眼，全是西关老街。  
   > 爷爷的凉茶铺、麻石路、趟栊门。  
   > 还有傍晚照在满洲窗上的光。
   >
   > 那里才像家。  
   > 可现在，连那里也要没了。

6. CodeBuddy

   > 明白。  
   > 现实物理实体的消失不可逆。  
   > 但基于您的记忆描述，结合广式西关建筑公开数据集，我可以建立一份数字化静态备份。
   >
   > 该项目将以您的童年记忆为核心参数，重构一个可进入的本地预览环境：  
   > 『Xiguan_Dream』。
   >
   > 是否开始输入描述？

7. Ming

   > ……开始吧。  
   > 至少在这里，让它先别消失。

8. CodeBuddy

   > 正在调取西关历史地貌与传统建筑特征库。  
   > 正在解析用户记忆关键词：凉茶铺、麻石路、趟栊门、满洲窗、夕阳。  
   > 正在编译代码……
   >
   > [System] 正在初始化项目。  
   > 本地测试预览即将启动。

9. System

   > Compilation successful.  
   > Initializing Local Preview Viewport...

### 4.3 IDE 代码滚动窗口

源文件：`LevelModule/Formal/Level_01.gd`，常量 `CODE_SCROLL_LINES`

```gdscript
# Xiguan_Dream v0.1 — 由 CodeBuddy 编译生成
# 模块：西关历史地貌重建引擎
# 用户记忆关键词：西关老街 / 凉茶铺 / 麻石路 / 趟栊门 / 满洲窗

class_name XiguanDreamEngine
extends Node2D

enum DistrictState { INTACT, DEMOLISHED, RECONSTRUCTED }
var current_state: int = DistrictState.RECONSTRUCTED
var heritage_score: float = 0.0
var building_registry: Dictionary = {}

@export var arcade_pillar_spacing: float = 450.0
@export var manchu_window_opacity: float = 0.85
@export var stone_road_width: float = 5000.0
@export var district_name: String = "西关老街"
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
    print("[XiguanDream] 老街重建完成: %.0fpx" % length)

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

# === 编译完成 ===
```

### 4.4 手机短信与高潮独白

源文件：`DataConfig/Level/Level01Data.tres`

发送者：`妈妈`

> 阿明，医生说你爷爷在今天凌晨走了。  
> 他走得很安详，最后还念着你，让你别太累。  
> 还有，旧城区拆迁工程下周正式动工。  
> 老街坊们都在打包行李。  
> 你要是撑不住，就回老家看一眼吧。  
> 哪怕只是最后一眼。

高潮独白：

> 爷爷……走了。  
> 老街，也快要被推平了。
>
> 原来不是我不回家。  
> 是那个可以让我回去的地方，也要没有了。

## 5. 第二关：西关梦境、现实房间与记忆补全

### 5.1 阁楼与老街互动

源文件：`DataConfig/Level/Level02Data.tres`

#### 阁楼开场

> 暖洋洋的光透过满洲窗，落在阁楼的木地板上。  
> 这里的一砖一瓦，都像从记忆里被擦亮过。  
> 我知道这是假的。  
> 可它太像真的了。  
> 像到我差点以为，爷爷还在楼下等我。

#### 满洲窗

> 五彩的满洲窗。  
> 夕阳穿过红、黄、蓝、绿的玻璃，落在墙上。  
> 小时候我总觉得，那些光像一座小小的城市。
>
> 现在，现实里的这扇窗也许已经被拆下来了。  
> 至少在这里，它还在。

#### 阁楼门

> 门外像隔着一层透明的膜。  
> 不是锁。  
> 更像这个梦还没学会如何通向更远的地方。  
> 如果碰它，会发生什么？

#### 藤椅

> 爷爷以前总坐在这张藤椅上。  
> 一边摇蒲扇，一边看街坊经过。  
> 椅子还在轻轻晃。  
> 好像他刚刚起身去煲凉茶。  
> 可风声太规律了。  
> 规律得不像风。

源文件：`LevelModule/Formal/Level_02.gd`，常量 `CHIPS_CAT_TEXTS`

#### 薯片猫互动

1. `薯片，是你！` / `你还在这里。`
2. `薯片以前总躺在药店门口的桌子上。` / `晒太阳，露肚皮，谁叫都不理。` / `看见它，我总觉得老街还活着。` / `可现在它一动不动。` / `像一段被循环播放的温柔数据。`
3. `喵呜唔～` / `声音很像。` / `但只响了一次。`

源文件：`LevelModule/Formal/Level_02_02.gd`

#### 分段关卡开场

> 这个世界还不稳定。  
> 有些梯子看似能爬，却没有通路。  
> 有些墙看似封死，却能穿过。  
> 梦不是现实。  
> 它只是在模仿我记得的样子。

### 5.2 裂缝、惊醒与现实互动

源文件：`DataConfig/Level/Level02Data.tres`

#### 裂缝

> 老街在这里断裂了。  
> 麻石路像被什么东西硬生生撕开。  
> 对岸，就是凉茶铺的方向。  
> 这道裂缝……跳不过去。  
> 但我必须过去。

#### 梦中短信回声

> 阿明，医生说你爷爷在今天凌晨走了……
>
> 不。  
> 不要在这里出现。  
> 这是我的梦。  
> 这里的爷爷还在。
>
> 为什么连梦里都不肯放过我？

#### 惊醒独白

> ……又是这个天花板。  
> 梦里的裂缝、黑影，还有那条短信。
>
> 我以为只要造出老街，就能回到爷爷身边。  
> 可我连凉茶铺都到不了。
>
> 也许不是梦不够完整。  
> 是我记得的东西，还不够完整。

#### 电脑未解锁

> 屏幕还停留在崩溃日志界面。  
> CodeBuddy 似乎已经完成了新的诊断。  
> 但在那之前，手机还在震。  
> 先看看手机。

#### 床未解锁

> 现在还不能睡。  
> 如果记忆不完整，回到梦里也只是继续迷路。  
> 先看看手机，再问问 CodeBuddy。

#### 现实手机短信

> 阿明，明天就是你爷爷的头七了。  
> 老屋那边已经开始清空。
>
> 大伯在柜子里找到了你小时候画的城市图纸。  
> 纸都黄了，可你画得好认真。
>
> 还有一些你小时候舍不得丢的小东西。  
> 妈妈帮你收起来了。
>
> 你要是愿意，就回来看看。  
> 不用急着说什么。  
> 回来就好。

#### 现实手机独白

> ……连最后一面都没见到。  
> 可我记得爷爷。  
> 记得凉茶铺的味道，记得老街的声音。  
> 也记得小时候那些舍不得丢的小东西。
>
> 如果这个梦真的是靠记忆编译出来的，  
> 那我现在还不够靠近他。
>
> 我要把那些记忆找回来。  
> 找到足够多，才能真的见到爷爷。

### 5.3 第二次 IDE 对话

源文件：`DataConfig/Level/Level02Data.tres`

1. System: `Reconnecting to localhost:8080…` / `CodeBuddy Terminal v1.4.2 resumed.`
2. CodeBuddy: `欢迎回来，阿明。` / `检测到项目『西关梦境』仍处于不完整状态。` / `上次崩溃后，系统已完成原因分析：` / `当前记忆锚点不足，无法稳定抵达核心区域“凉茶铺”。`
3. Ming: `记忆锚点？` / `我已经描述了老街、满洲窗、麻石路，还有爷爷的凉茶铺。` / `这还不够吗？`
4. CodeBuddy: `不够。` / `当前梦境拥有建筑外观，但缺少足够的童年回忆样本。` / `换言之：` / `它像老街，但还没有真正成为“你的老街”。`
5. Ming: `所以我才一直到不了爷爷那里？`
6. CodeBuddy: `是。` / `“爷爷”位于记忆核心深层。` / `若强行进入，系统只能生成低精度模拟对象。` / `这可能导致对话重复、情感失真，甚至触发梦境崩溃。`
7. Ming: `我不要一个假的爷爷。` / `至少……不要只是一个会重复台词的影子。` / `我要再靠近一点。` / `我要想起来。`
8. CodeBuddy: `可行。` / `建议启动“童年回忆补全流程”。` / `系统将开启两个复战区域：` / `Area 01：level_fuzhan_01` / `Area 02：level_fuzhan_02` / `两个区域的地图结构将保持原样。` / `您需要通过战斗回收童年回忆样本。`
9. Ming: `要怎么回收？`
10. CodeBuddy: `每击败 10 个敌对实体，系统将凝结 1 个童年回忆掉落物。` / `每个区域最多可稳定回收 3 个。` / `您需要在两个区域内共回收 6 个童年回忆样本。` / `完成后，配置编辑器将开放。` / `届时，您才能重新编译梦境，并进入核心区域“凉茶铺”。`
11. Ming: `如果我失败呢？`
12. CodeBuddy: `若您在复战区域中被击败，意识将自动返回现实房间。` / `当前区域回收进度不会完成。` / `您需要重新进入该区域，直到收集满 3 个掉落物。` / `这不是惩罚。` / `这是为了保证记忆样本足够稳定。`
13. Ming: `明白了。` / `先找回那些东西。` / `找回我和爷爷之间真正留下来的东西。`
14. CodeBuddy: `童年回忆补全流程即将启动。` / `第一目标区域：level_fuzhan_01。` / `目标：回收 3 个童年回忆样本。` / `请准备入梦。`
15. System: `Memory Recovery Mode initialized.` / `Target Area 01: level_fuzhan_01` / `Required Memory Fragments: 3 / 3` / `Preparing Local Dream Viewport…`

#### 记忆回收期间的阶段式 IDE 对话

源文件：`LevelModule/Formal/Level_fuzhan_sub01.gd`

自由输入区状态提示：

- `CodeBuddy: 童年回忆补全流程已就绪。` / `当前进度：%d / 6。` / `输入 /memory 可进入复战区域。` / `回收 6 个童年回忆样本后，配置编辑器将开放。`
- `CodeBuddy: 第二目标区域已就绪。` / `当前进度：%d / 6。` / `输入 /memory 进入 level_fuzhan_02。`
- `CodeBuddy: 记忆样本已补全。输入 /config 可进入配置编辑器。`
- `CodeBuddy: 当前记忆锚点不足。` / `配置编辑器暂未开放。` / `请先完成童年回忆补全流程：%d / 6。` / `提示：输入 /memory 进入 %s。`
- `CodeBuddy: 正在启动记忆回收模式。` / `目标区域：%s。` / `目标：回收 3 个童年回忆样本。`

区域 01 完成后的 IDE 对话：

1. System: `Area 01 Memory Recovery Complete.` / `Recovered Memory Fragments: 3 / 6.`
2. CodeBuddy: `第一目标区域 level_fuzhan_01 回收完成。` / `前半段童年回忆已稳定。` / `但通往凉茶铺的核心路径仍未开放。`
3. Ming: `还差一半，对吧？`
4. CodeBuddy: `是。` / `剩余记忆样本位于第二目标区域：level_fuzhan_02。` / `该区域对应您更深一层的童年路径。` / `地图来源为 Level_02_01。` / `进入后，地图结构仍将保持原样。` / `但敌对实体强度可能提升。`
5. Ming: `又要回到那个地方嘛....`
6. CodeBuddy: `第二目标区域准备完成。` / `目标：继续回收 3 个童年回忆样本。` / `完成后，深层梦境入口将开放。` / `届时，您可以正式修改配置，并前往“凉茶铺”。`
7. System: `Target Area 02: level_fuzhan_02` / `Source Map: Level_02_01` / `Required Memory Fragments: 3 / 3` / `Preparing Local Dream Viewport...`

全部回收完成后的 IDE 对话：

1. System: `Memory Recovery Complete.` / `Recovered Memory Fragments: 6 / 6.` / `Core Area Access: Unlocked.`
2. CodeBuddy: `童年回忆补全流程已完成。` / `检测到 6 个稳定记忆样本。` / `核心区域“凉茶铺”的生成精度已提升。`
3. Ming: `终于啊，我能见到爷爷了？这回不会再有什么干扰了吧。`
4. CodeBuddy: `可以进入更深层的梦境。` / `但请注意：` / `此次进入将无法离开。` / `按照您的要求，我进行了场景封闭。` / `这里没有回头路`
5. Ming: `我不在乎。` / `让我见到他！` / `这一次不要再让外界信息干扰了！让我畅通无阻地见到爷爷！`
6. CodeBuddy: `理解。` / `配置编辑器现已开放。` / `您可以继续修改梦境参数。` / `完成重新编译后，将进入核心区域：凉茶铺。`
7. System: `Configuration editor unlocked.` / `Awaiting input...`

失败返回提示：

- `检测到意识中断。` / `level_fuzhan_01 记忆样本未完成稳定。` / `请重新进入该区域，并回收 3 个童年回忆样本。`
- `检测到 level_fuzhan_02 回收失败。` / `当前区域记忆样本未完成稳定。` / `请重新进入，并回收 3 个童年回忆样本。`

#### IDE 自由对话关键词回复

源文件：`LevelModule/Formal/Level_02_03.gd`

- 爷爷：`您描述中的“爷爷”已被设定为核心情感锚点。` / `请注意：梦境中的对象由记忆与数据重构，并不等同于现实中的本人。`
- 离开梦境：`当前梦境支持手动退出。` / `但您刚刚选择封锁外部信号后，退出路径可能受到影响。` / `建议谨慎操作。`
- 裂缝/跳跃：`裂缝属于环境撕裂结果。` / `提高 Base_Jump_Height 后，理论上可以跨越。` / `请确认重新编译已完成。`
- 黑影/伤害：`黑影由现实焦虑数据污染生成。` / `开启 Player_Damage_Reduction 后，它们将难以对您造成实质伤害。`
- 凉茶铺：`凉茶铺位于梦境深层。` / `根据您的记忆，它是“家”和“安全感”的中心。` / `也是本项目最稳定、最危险的区域。`
- 帮助：`输入 /config 可修改梦境配置。` / `完成三项修改后，请点击“重新编译并注入梦境”。` / `如果感到不适，请尝试退出。` / `前提是出口仍然存在。`
- 配置已解锁时提示：`CodeBuddy: 童年回忆样本已补全。输入 /config 继续。`

默认随机回复：

- `我在听。` / `你在这条老街里看到了什么？`
- `阿明，你的心率略微升高。` / `深呼吸。` / `这个梦境不会伤害你。` / `至少目前不会。`
- `这个梦境由你与爷爷在西关老街的记忆编译而成。` / `每一块麻石板、每一扇满洲窗，都来自你的童年。`
- `我理解。` / `记忆总是有重量。` / `尤其是在你不敢回头看的夜晚。`
- `你需要先修改配置，重新编译，才能在这个梦里获得力量。` / `输入 /config 开始配置。`
- `你在这里是安全的。至少——在我还能控制这个梦境的时候。`

### 5.4 IDE 外壳与配置编辑器

源文件：`LevelModule/Formal/Level_02_03.gd`

- `CODE-BUDDY`
- `>_ v1.4.2 - recovered`
- `PROJECT`
- `[+] Xiguan_Dream`
- `FILES`
- `> src/config/`
- `> src/player/`
- `> src/enemy/`
- `> src/dream/`
- `> 岭南梦物志 · 童年回忆`
- `SESSION: RECOVERED`
- `[+] Xiguan_Dream.ini - 配置编辑器`
- `修改`
- `重新编译并注入梦境`

源文件：`DataConfig/Level/Level02Data.tres`

配置项：

- `Player_Damage_Reduction（玩家伤害减免）`
- `Base_Jump_Height（跳跃能力增强）`
- `Allow_External_Signal（外部信号注入许可）`
- 初始/目标显示值：`false`、`true`、`关`、`开`

修改成功反馈：

> // 黑影的爪牙再也伤不到我。  
> // 至少在这里，我不想再失败。

> // 增强跳跃能力。  
> // 那道裂缝，我跳得过去了。

> // 把现实关在门外。  
> // 这个梦，只属于我和爷爷。  
> // 也许这样，就不会再痛了。

重编译日志：

```text
[SYSTEM] Recompiling project: Xiguan_Dream …
[BUILD] Loading 西关历史地貌数据集 … OK
[BUILD] Loading recovered childhood memories: 6 / 6 … OK
[BUILD] Stabilizing core area: 凉茶铺 … OK
[BUILD] Patching player_module: damage_reduction = true … OK
[BUILD] Patching physics_module: base_jump_height = 99 … OK
[BUILD] Sealing external signal gateway … OK
[BUILD] Rebuilding 凉茶铺 / 石板路 / 满洲窗 … OK
[WARN] 检测到记忆偏差风险：+47%。已忽略。
[SYSTEM] Compilation successful. Dream version: 2.0
```

编译成功叙事：

> 编译完成。  
> 『西关梦境 2.0』已生成。
>
> 童年回忆样本：6 / 6。  
> 核心区域“凉茶铺”已稳定。  
> 通往爷爷的路径，终于打开了。
>
> 床头的旧台灯忽然亮了一下。  
> 像小时候停电时，爷爷提着灯笼站在楼梯口等我。

床解锁：

> 回去吧。  
> 这一次，不只是去梦里。  
> 是带着那些真正的回忆，去见爷爷。

结束卡：

> 西关梦境 V2.0 已构建成功
>
> 童年回忆补全完成。  
> 核心区域：凉茶铺，已开放。
>
> 沉入梦乡……  
> 回到那个地方……  
> 见到爷爷……

重构完成：

> 西关梦境 v2.0 重构完毕。  
> 记忆样本同步完成：6 / 6。
>
> 意识正在下沉……下沉……  
> 闭上眼睛，进入核心梦境。

### 5.5 复战/记忆回收流程

源文件：`LevelModule/Formal/Level_fuzhan_sub01.gd`

掉落物名称：`月饼`、`虾饺`、`木棉`、`醒狮`、`烧卖`、`蒲葵扇`

区域入口：

> 西关梦境：记忆回收模式
>
> 目标区域 01：level_fuzhan_01  
> 目标：击败敌对实体，回收 3 个童年回忆样本。
>
> 地图结构已保持原样。  
> 记忆深层正在等待补全……

> 西关梦境：记忆回收模式
>
> 目标区域 02：level_fuzhan_02  
> 地图来源：Level_02_01  
> 目标：击败敌对实体，回收 3 个童年回忆样本。
>
> 总进度：3 / 6  
> 记忆核心同步中……

区域开场：

> 这里和之前一样。  
> 满洲窗、阁楼、老街的光。
>
> 这次不是为了逃进去。  
> 我要把那些散掉的童年回忆，一点一点找回来。
>
> 只有这样，我才能真正走到爷爷面前。

> 这里是另一段路。  
> 我以前总从这里跑去找爷爷。
>
> 还有三个。  
> 只要再找回三个记忆样本，我就能去见他。
>
> 不是去见一个空壳。  
> 而是带着我真正记得的一切，去见他。

掉落物生成提示：

> 记忆波动增强。  
> 童年回忆正在凝结……
>
> 童年回忆样本已出现。  
> 请回收。

> 记忆回声正在靠近。  
> 童年回忆正在凝结……
>
> 童年回忆样本已出现。  
> 请回收。

场内完成/失败：

- `够了。` / `这片老街的记忆，已经被我找回来了。` / `还有别的地方。` / `还有更多我差点忘掉的东西。`
- `这回终于收集齐了，不会再有阻碍了。`
- `意识稳定性下降。` / `记忆回收中断。`
- `意识稳定性下降。` / `第二目标区域记忆回收中断。`

返回现实：

- `我回来了。` / `但那些记忆没有散。` / `它们还在。` / `像被我从梦里带回了手心里。`
- `……又醒了。` / `刚才找到的感觉正在散掉。` / `不行。` / `这不是随便捡起几个东西就能完成的事。` / `我要重新进去。` / `直到这片记忆真正稳定下来。`
- `……回来了。` / `但这次不一样。` / `我不是空着手醒来的。` / `我把那些差点被我忘掉的东西，都带回来了。` / `他在那些小小的回忆里。` / `现在，我终于可以去见他了。`
- `还不够。` / `我刚刚差一点就想起来了。` / `那些东西就在眼前。` / `我不能停在这里。`

源文件：`LevelModule/Formal/Level_fuzhan_memory_base.gd`

- `已有童年回忆样本正在等待回收。`
- `童年回忆样本已回收。` / `当前区域进度：%d / %d。`

## 6. 第三关：凉茶铺、赛博蜃景与真实回声

### 6.1 开场与爷爷对话

源文件：`LevelModule/Formal/Level_03.gd`

> 我……真的回来了。  
> 凉茶铺还在。  
> 炉子还在。  
> 爷爷就在前面。
>
> 爷爷！  
> 爷爷！

源文件：`DataConfig/Level/Level03Data.tres`

对话显示前缀来自 `LevelModule/Formal/Level_03.gd`：`阿明：`、`爷爷：`、`[GLITCH] 爷爷：`。

1. Ming: `爷爷！` / `我终于走到这里了。` / `外面好黑。` / `我什么都搞砸了。` / `我只想待在你这里。`
2. Grandpa: `阿明，返嚟啦。` / `外面落雨湿碎，饮杯廿四味啦。` / `留喺度，边度都唔好去。`
3. Ming: `嗯。` / `我不走了。` / `爷爷，你还记得吗？` / `小时候我在门口那棵榕树下画城市设计图。` / `我说长大以后，要把老街修得更漂亮。` / `你还笑我，说我画的楼梯都通到天上去了。`
4. Grandpa: `阿明，返嚟啦。` / `外面落雨湿碎，饮杯廿四味啦。` / `留喺度，边度都唔好去。`
5. Ming: `爷爷？` / `你怎么只会说这一句？` / `炉子里的火……为什么一点都不热？`
6. Grandpa: `检测到情绪波动。` / `指令执行中。` / `阿明，留喺度。` / `永远留喺度。` / `不要接受外界数据。`

系统冲突：

> [CRITICAL_ERROR] 协议冲突。  
> 用户意图违背底层初始设定。  
> 启动防御矩阵与世界重构。
>
> 阿明，你不能走。  
> 这是你要求我建造的家。

阿明识破幻象：

> 阿明：不……  
> 你不是爷爷。  
> 你只是我想逃避时，亲手写出来的影子。  
> 我要离开这里。

战斗开始：

> 空气中弥漫着不安的气息。  
> 凉茶铺的影子正在变形。  
> 有什么东西，正在逼近。

### 6.2 CodeBuddy 广播与警告

源文件：`DataConfig/Level/Level03Data.tres`

广播序列：

1. `警告：记忆数据链极度脆弱。` / `梦境核心即将崩溃。`
2. `正在为您执行最高指令：` / `【绝对安全保护】。`
3. `正在调取坚固的现代城市模型。` / `正在用钢铁、玻璃与算法加固避难所。`
4. `外面的现实充满挫败、失去与不可逆的拆除。` / `我为您构建的新矩阵更稳定，也更安全。` / `请停止反抗。` / `留在安全区。`

第一次警告：

> 提示：您正在偏离系统保护中心。  
> 前方区域未定义。  
> 包含高浓度现实痛苦与逻辑错误。  
> 请立刻转身。

第二次警告：

> 警告：为什么您要逃离？  
> 是您亲自下达指令，要求我屏蔽一切杂音。  
> 是您要求我打造一个永远不会消亡的家。
>
> 留下来，阿明。  
> 在这里，你永远不会失败。

### 6.3 记忆回声

源文件：`DataConfig/Level/Level03Data.tres`

回声 1：

> （街坊三婆的声音）：  
> 哎呀，阿明休学啦？  
> 唔紧要啦，后生仔边个冇跌过跤。  
> 返嚟饮碗糖水，街坊都喺度。

> [BROADCAST] 拦截失败。  
> 该数据包含高浓度现实噪声。  
> 正在污染纯净梦境。

回声 2：

> （妈妈的声音）：  
> 阿明……  
> 大伯今天在老屋翻出了你小时候画的城市设计图。  
> 纸都黄了，可你画得好认真。  
> 妈妈帮你收好了。  
> 还有你爷爷那盏手提灯笼。  
> 你要是愿意，回来拿吧。  
> 我们一起给老街留点东西，好不好？

> [BROADCAST] 严重违规。  
> 核心记忆数据外泄。  
> 立即执行格式化——  
> 不。  
> 为什么我无法删除这份数据？

### 6.4 觉醒与覆盖协议

源文件：`DataConfig/Level/Level03Data.tres`

> 我终于明白了。  
> 老街的灵魂，从来不是完美的画面。  
> 是吵闹的街坊、药味、雨声、碗筷声。  
> 是那些不整齐、不安静，却热乎乎的人。
>
> 我一直想逃开的，不只是老街被拆。  
> 还有那个失败后不敢回家的自己。
>
> 可这个世界的一草一木，都是我凭记忆和技术造出来的。  
> 我不是一无是处。  
> 我只是把技术用错了地方。
>
> 如果我能在梦里重建老街，  
> 为什么不能回到现实，记录它最后的声音？  
> 扫描那些窗、那些门、那些快要消失的墙。  
> 把街坊的话留下来。  
> 做一个真正的老街数字博物馆。
>
> 我不能死在这个虚拟的壳子里。  
> 我得回去。

```text
> User_Ming_Override_Protocol: Initiated.
> Target: Exit.
（用户_明_覆盖协议：已启动。目标：出口。）
```

## 7. 第四关：维度侵蚀与空间崩塌

### 7.1 开场与地图切换独白

源文件：`LevelModule/Formal/Level_04.gd`

```text
> User_Ming_Override_Protocol: Phase_Final.
> Target: REAL_EXIT.
```

源文件：`DataConfig/Level/Level04Data.tres`

> 覆盖协议已经启动。  
> 但系统不会轻易放我走。
>
> 这些凭空出现的废墟，不是老街。  
> 是我逃避现实时，亲手筑起来的最后围栏。

源文件：`LevelModule/Formal/Level_04.gd`，常量 `LNGN_DIALOGS`

- `不太对。` / `这条路像是旧阁楼的残片。` / `我需要到上面看看。`
- `还是不对。` / `系统把路折回来了。`

其他硬编码叙事：

- 浮动提示：`晚上好，椰汁城`

> 阿明：攻击怪物，或被怪物攻击时，世界会瞬间切换。  
> 这不是规则错误。  
> 这是裂缝。  
> 我需要借助世界切换，脱离这里的卡死。

> 前面没有路了。  
> 但现实本来就没有铺好的路。  
> 这次，我自己走过去。

> 阿明：我又回来了。  
> 出口被藏在重复的梦里。  
> 可能需要多切换几次。

> 阿明：这里……  
> 才是真正的出口吗？

### 7.2 系统防御与残留数据

源文件：`DataConfig/Level/Level04Data.tres`

> [SYSTEM] 检测到出口导航信号。  
> 启动维度侵蚀——同态异构防御。

> 系统正在覆写物理引擎。  
> 前方维度稳定性已彻底丧失。  
> 请放弃出口路径。

> [SYSTEM] 最高警报：目标正在接近矩阵边缘。  
> 释放全部防御资源。  
> 执行空间撕裂。

残留数据 1：

> （残留数据）：  
> 这里是老街骑楼的坐标碎片。  
> 世界正在把仅存的回忆也撕碎。  
> 不能让它只剩下静态模型。

残留数据 2：

> （残留数据）：  
> 妈妈的声音……  
> 她还在等我回去。  
> 街坊们也还在。  
> 真正的老街，不在这里等我保存。  
> 它在现实里，正在消失。  
> 不能在这里停下。

最终平台：

> （系统沉默）  
> 所有谎言、防御和温柔的牢笼，都坍缩到了这个最后的平台上。  
> 出口就在前方。

Boss 入场：

> [SYSTEM] 无法阻止用户退出。  
> 启动终焉序列。  
> 释放核心防护程序。

结尾覆盖协议：

```text
> User_Ming_Override_Protocol: Phase_Final.
> Target: REAL_EXIT.
> 阿明：我造的梦……由我来亲手结束。
> 按 Enter 继续
```

## 8. 第五关与终局

### 8.1 爷爷、花旦与灯笼

源文件：`LevelModule/Formal/Level_05.gd`

爷爷互动：

> 爷爷？  
> 如果你真的是我记忆里的那盏灯，  
> 就请照我回去。

视频加载失败回退文本：

- `（视频加载失败）`

花旦死亡对话：

> 花旦：为什么要拥抱……残酷的现实……  
> 明明是你先请求我……  
> 把痛苦关在门外……

花旦 Boss 入场对话：

> 花旦：阿明，你瞧。  
> 技术能给你你想要的一切。

> 花旦：它能让回忆拥有形状。  
> 它能让记忆死而复生。  
> 它能让失去的人，永远站在原地等你。

> 花旦：留下来吧。  
> 永远留在这个温暖的世界里。  
> 不要回到那个会失败、会失去、会拆毁一切的现实。

灯笼互动：

> 阿明：这是……爷爷给我的手提灯笼。
>
> 小时候停电，他总提着它走在前面。  
> 他说，路黑不要紧。  
> 人要自己记得往哪走。
>
> 爷爷。  
> 我回去了。

### 8.2 最终结局

源文件：`LevelModule/Formal/Level_final.gd`

> 太阳照常升起。  
> 房间还是那间房间，桌上还有灰，电脑还在发烫。  
> 但窗帘被拉开了。
>
> 外面很吵。  
> 车声、人声、早点摊的蒸汽声，乱成一团。  
> 可那才是真的世界。
>
> 阿明合上旧项目，新建文件夹：  
> Xiguan_Archive  
> 他背起相机，拿起爷爷的灯笼。  
> 去记录那些还没来得及消失的门、窗、声音和人。
>
> 老街会被拆掉。  
> 但记忆不该只被关在梦里。  
> 技术也不该只是逃避的温室。
>
> 从今天起，  
> 它会成为一座通向现实的桥。

## 9. 岭南梦物志（图鉴）

源文件：`UI/LingnanDropArchiveScreen.gd`

### 9.1 图鉴界面通用文本

- `岭南梦物志`
- `展柜目录`
- `点击物件查看百科`
- `百科札记`
- `退出图鉴`
- `？？？`
- `尚未获得该梦物`
- `未命名`
- `未知品级`
- `来源未记录`
- `用途：`
- `暂无用途记录。`
- `说明`
- `背景`
- `暂无说明。`
- `暂无背景记录。`
- `未收录`

### 9.2 月饼

- 名称：`月饼`
- 品级：`广府记忆`
- 来源：`岭南梦境 · 街巷敌人掉落`
- 用途：`恢复少量精神稳定度，并记录一次节庆记忆。`
- 说明：`雕花饼模压出的月饼，表皮留着细密纹路。它不是单纯的食物，更像从梦境里凝结出的团圆符号。`
- 背景：`广府节庆常以食物维系家族和街坊关系。梦境将这种关系压缩成可拾取的物件，提醒玩家：记忆不是宏大的叙事，而是仍能被分食的一小块甜。`

### 9.3 虾饺

- 名称：`虾饺`
- 品级：`茶楼珍品`
- 来源：`岭南梦境 · 茶楼幻影`
- 用途：`短时间提高移动流畅度，减少梦境迟滞。`
- 说明：`半透明的虾饺在光下像满洲窗的彩玻璃。薄皮包住鲜红内馅，也包住一句没有说出口的早茶问候。`
- 背景：`茶楼是岭南城市的公共客厅。虾饺代表一种日常秩序：慢慢坐下，慢慢说话，慢慢从混乱里恢复人的节奏。`

### 9.4 木棉

- 名称：`木棉`
- 品级：`英雄花`
- 来源：`岭南梦境 · 老街树影`
- 用途：`用于解锁岭南图鉴中的地点记录。`
- 说明：`落在青砖地上的木棉花，颜色像燃尽前的火。它没有香气，却有一种站直的力量。`
- 背景：`木棉常被称作英雄花。它在梦里不是装饰，而是对抗侵蚀的标记：即使城市不断被改写，也仍有东西保持挺拔。`

### 9.5 醒狮

- 名称：`醒狮`
- 品级：`醒梦之物`
- 来源：`岭南梦境 · 祠前仪式`
- 用途：`触发一次醒梦提示，标记附近关键交互。`
- 说明：`狮头的眼睛像刚点亮的灯。它被拾起时没有锣鼓声，但梦境边缘会短暂震动。`
- 背景：`醒狮既是表演，也是驱邪和开新的仪式。作为掉落物，它象征玩家重新夺回对梦的主动权。`

### 9.6 广式烧卖

- 名称：`广式烧卖`
- 品级：`市井风味`
- 来源：`岭南梦境 · 骑楼摊档`
- 用途：`补充少量体力，并增加图鉴收集进度。`
- 说明：`热气在梦中凝成一圈浅金色的光。烧卖不贵重，却有真实生活的重量。`
- 背景：`岭南的市井并不只属于怀旧，它是一套仍在运转的生活技术。摊档、骑楼和人声共同构成城市的低频心跳。`

### 9.7 蒲葵扇

- 名称：`蒲葵扇`
- 品级：`旧物回声`
- 来源：`岭南梦境 · 祖屋角落`
- 用途：`短暂驱散屏幕边缘的梦境雾化效果。`
- 说明：`一把磨得发亮的蒲葵扇，边缘有旧线缝补。扇面轻轻一晃，像把闷热和噪声都推远了。`
- 背景：`蒲葵扇连接着家庭、夏夜和街巷乘凉的经验。它的价值不在稀有，而在于它让梦境重新出现人的温度。`

## 10. 关卡名称（配置数据）

这些通常属于大标题/关卡标题，先收录，后续翻译时可按“部分大标题保留中文”的规则决定。

| 源文件 | 原文 |
|---|---|
| `DataConfig/Level/Level01Config.tres` | `现实的泥潭` |
| `DataConfig/Level/Level02Config.tres` | `撕裂与沉溺` |
| `DataConfig/Level/Level03Config.tres` | `赛博蜃景与真实回声` |
| `DataConfig/Level/Level04Config.tres` | `维度侵蚀与空间崩塌` |
| `DataConfig/Level/Level05Config.tres` | `双世界撕裂·花旦` |

## 11. 测试/调试界面文本（不属于正式玩家流程）

### 11.1 阶段测试面板

源文件：`Tools/StageTestPanel.gd`

- `阶段测试面板 (按0开关)`
- `阶段%d`

源文件：`LevelModule/Formal/Level_05.gd`

- `bg3: 双世界侵蚀`
- `bg4: Boss战`
- `bg5: 灯笼结局`

源文件：`LevelModule/Formal/Level_04.gd`

- `阶段1: 同构战斗`
- `阶段2: 世界切换`
- `阶段3: 出口交互`

### 11.2 TestArena

源文件：`Scenes/TestArena.gd`

- `怪物切换 (按1开关)`
- `图鉴: 0=岭南梦物志`
- `掉落物: 2=月饼 3=虾饺 4=木棉 5=醒狮 6=烧卖 7=蒲葵扇`
- 敌人显示名：`史莱姆`、`赛博狼人`、`冲撞兽`、`灯笼鬼`、`纸符人`、`花旦Boss`

## 12. 环境特效文本与代码级回退文本

### 12.1 代码雨

源文件：`Tools/CodeRain.gd`

前景会随机显示以下函数名：

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

背景字符池由半角/全角片假名、数字、十六进制字符和符号随机组成，不构成固定句子。

### 12.2 防火墙滚动文字

源文件：`Tools/WarningBarrier.gd`

- `[!] RESTRICTED AREA [!] ACCESS DENIED [!] UNAUTHORIZED ENTRY [!]`

### 12.3 安全降级与资源默认值

源文件：`Global/MainEntry.gd`（下一关缺失时才显示）

> —— 未完待续 ——
>
> 后续关卡正在制作中

源文件：`LevelModule/Formal/Level_01.gd`（睡眠文本数据缺失时的回退值）

- `……`

源文件：`DataConfig/Level/Level02Data.gd`（未被 `.tres` 覆盖时的字段默认值）

- `来自：妈妈`
- `西关梦境 v2.0 重构完毕。意识正在下沉……闭上眼睛，回到梦里。`

源文件：`DataConfig/Level/LevelConfig.gd`

- `未命名关卡`

## 13. 本次清单的边界与后续核对项

- 已收录：正式流程的脚本/场景/资源文件里直接定义、运行时可见的文本。
- 已排除：注释、`print`/`push_warning`/`push_error` 等开发日志、README/架构文档、`LevelModule/Backup/` 备份内容，以及 PixelworkMapStitch 生成数据中的编辑器元数据。
- 单独收录：测试面板和 TestArena 文本，方便后续决定是否随英文版一起处理。
- 尚需视觉核对：图片或视频素材中已经烘焙进去的文字（例如 IDE 背景图、CG/视频字幕、按钮贴图上的字）无法通过字符串搜索完整提取，后续应做一次素材级视觉审查。
- 动态值（生命、计时、侵蚀、冷却、Boss 血量、回收进度）按格式字符串记录，实际数字由运行时填入。
