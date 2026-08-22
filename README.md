# 织梦者（Dreamweaver）

> HackathonGame · Godot 4.6.2 · 2D 横版动作叙事游戏
> 岭南文化 × 赛博未来 × 梦境撕裂

## 游戏简介

《织梦者》是一款以岭南文化与赛博朋克碰撞融合为主题的 2D 动作叙事游戏。玩家扮演岭南青年阿明，穿梭于被数字侵蚀撕裂的梦境世界，在岭南旧梦与赛博蜃境之间推进剧情、战斗并追查侵蚀源头，最终面对花旦 Boss。

## 核心特色

- 双世界叙事：岭南古风与赛博未来交错呈现。
- 横版探索与战斗：移动、跳跃、近战、技能、敌人 AI 与 Boss 多阶段战斗。
- Pixelwork 地图运行时：由项目专用数据和脚本拼接地图层、碰撞与关卡节点。
- 剧情交互：终端、记忆复战、配置注入与跨关卡状态共同驱动流程。
- 视觉效果：侵蚀、Glitch、RGB 色散、代码雨、警告屏障与 Shader 特效。
- 事件驱动架构：跨模块通信以 `EventBus` 和 `GameManager` 为核心。

## 技术基线

| 项目 | 当前基线 |
|---|---|
| 引擎 | Godot 4.6.2 |
| 渲染器 | GL Compatibility |
| 脚本语言 | GDScript |
| 基准视口 | 1280×720，`canvas_items` 拉伸 |
| 主场景 | `res://UI/TitleScreen.tscn` |
| 架构 | 事件驱动、状态机、Builder 与 Resource 配置 |
| Godot AI | 3.1.5，项目级 MCP 配置 |

当前游戏内容规模（排除 `LevelModule/Backup/`、Godot AI 插件及 Agent/MCP 工具文件）：

| 类型 | 数量 |
|---|---:|
| GDScript | 83 |
| 场景 | 38 |
| Resource 配置 | 20 |
| Shader | 8 |

## 主线流程

`TitleScreen → MainEntry → Level_01 → Level_02 → Level_02_01 → Level_02_02 → Level_02_03 → Level_03 → Level_04 → Level_05 → Level_final → TitleScreen`

当前前半段由 `MainEntry` 托管，后半段存在整树切换流程。该现状及其风险以 [TECHNICAL_ARCHITECTURE_REPORT.md](TECHNICAL_ARCHITECTURE_REPORT.md) 为准。

## 项目结构

```text
HackathonGame/
├─ .agents/skills/        Project Skill 与 11 个 Godot 专项 Skill
├─ .codex/                项目级 Codex / Godot AI MCP 配置与说明
├─ addons/godot_ai/       Godot AI 3.1.5 编辑器插件
├─ Global/                事件、全局状态、输入、转场与音频
├─ LevelModule/
│  ├─ Formal/             正式关卡、FSM、Builder 与关卡数据
│  ├─ Backup/             历史参考，不得成为正式运行依赖
│  └─ Scenes/             Pixelwork 地图数据与运行时
├─ PlayerModule/Formal/   玩家基类、三种角色形态与相机
├─ EnemyModule/Formal/    敌人基类、普通敌人与花旦 Boss
├─ DataConfig/            玩家、敌人、关卡与技能 Resource
├─ UI/                    标题页、MainEntry、HUD 与按键设置
├─ Tools/                 弹体、交互物、伤害与视觉工具
├─ Assets/                图像、动画、音频、视频与 UI 素材
├─ Resources/             共享资源
├─ project.godot          Godot 项目入口
└─ TECHNICAL_ARCHITECTURE_REPORT.md
```

## Agent、Skill 与 MCP 协作

仓库内的 Agent 工作必须先遵守 [AGENTS.md](AGENTS.md)，并在每个任务中首先使用项目专用入口：

- `hackathongame-project`：加载项目上下文、锁定 Godot 4.6.2、判断授权边界并选择验证方式。

当前随仓库保留 11 个 Godot 专项 Skill：

- 语言与结构：`godot-gdscript`、`godot-nodes-scenes`、`godot-signals-groups`、`godot-resources`
- 2D 行为：`godot-2d-movement`、`godot-physics`、`godot-animation`
- 表现层：`godot-ui-control`、`godot-audio`、`godot-shaders`
- 构建：`godot-export`

本项目不为 3D 场景装配、C#/.NET、在线网络同步或 TileMap/TileSet 作者工作提供专项 Skill 路由。Pixelwork 地图任务由 Project Skill 先检查项目自定义数据和运行时，不套用通用地图作者流程。

Godot AI MCP 使用仓库内的 `.codex/config.toml`，只在受信任的当前项目中由 Codex 自动加载；它不应复制到用户级配置。当前服务器通过 `uv`/`uvx` 启动，不依赖 Node.js 或 npm。完整的作用域、权限、会话核对、写入审批和隐私说明见 [.codex/README.md](.codex/README.md)。

MCP 工具可见不代表自动获得正式内容修改权限。任何正式写入仍受 `AGENTS.md`、Project Skill、当前任务授权和会话身份核对约束。

## 本地开发

1. 安装 Godot 4.6.2 标准版。
2. 使用 Godot 编辑器导入或打开仓库根目录。
3. 确认渲染器为 GL Compatibility。
4. 从 `project.godot` 配置的标题场景启动项目。

涉及 GDScript、场景或 Resource 的修改，应使用准确的 Godot 4.6.2 执行 headless 主场景与受影响场景验证。Shader、动画、音频和视觉布局还需要真实图形环境或人工画面/试听检查。

## 文档入口

- [AGENTS.md](AGENTS.md)：仓库级工作规则、授权与保护边界。
- [.agents/skills/hackathongame-project/SKILL.md](.agents/skills/hackathongame-project/SKILL.md)：每个项目任务的强制入口。
- [TECHNICAL_ARCHITECTURE_REPORT.md](TECHNICAL_ARCHITECTURE_REPORT.md)：唯一架构文档、当前实现、风险与验证基线。
- [.codex/README.md](.codex/README.md)：项目级 Godot AI / MCP 配置与协作说明。

README 只用于项目介绍和开发入口；实现与架构判断以当前代码、场景、资源、`project.godot` 和技术架构报告为准。

## 许可证

本项目仅供学习与竞赛用途。

Made with Godot 4.6.2
