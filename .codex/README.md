# HackathonGame 项目级 Godot AI / MCP

## 作用域

仓库根目录的 `.codex/config.toml` 是项目级配置。Codex 只在当前仓库被信任并作为当前项目使用时加载它；它不会自动影响其他仓库。不要为了本项目把 `godot-ai` 条目复制到用户级 `~/.codex/config.toml`，否则该条目可能在其他项目中也可见。

同一台主机上的桌面端 Codex、Codex CLI 和 Codex IDE 扩展会在进入本项目时共享这份项目配置；ChatGPT 网页端不读取本地 `.codex/config.toml`。其他 MCP 客户端不继承 Codex 的工具白名单，必须分别配置权限。

项目作用域只限制 Codex 自动加载这份配置，不等于给正在运行的 MCP 服务建立项目沙箱。若另一个本地客户端被手工指向同一回环端口，或同一服务出现多个 Godot 编辑器会话，它仍可能看到该服务。任何写入前都要读取 `editor_state`、`godot://sessions` 与 `godot://project/info`，核对 `project_name = HackathonGame`、当前场景与项目路径，并显式激活正确会话；不得仅凭端口号或“最近打开”推断目标项目。

本文件和 `.codex/config.toml` 不保存密钥，应与项目一起纳入 Git。密钥、令牌和个人客户端凭据只能保存在环境变量、系统凭据存储或用户级配置中。

官方依据：<https://learn.chatgpt.com/docs/extend/mcp?surface=cli>

## 组成与版本

- `.codex/config.toml`：Codex 客户端的项目级连接、工具白名单和审批策略。
- `addons/godot_ai/`：随项目版本化的 Godot AI 编辑器插件。
- `project.godot`：启用插件，并注册仅供编辑器联动使用的 `_mcp_game_helper`。
- `AGENTS.md` 与 `.agents/skills/hackathongame-project/SKILL.md`：任务授权、正式场景保护和验证规则。

截至 2026-08-25，上游 Godot AI 最新稳定版与本仓库插件基线均为 `3.2.0`，插件与服务器必须严格保持同一版本。Godot AI 使用 `uv`/`uvx` 启动 `godot-ai==3.2.0` Python 服务器；本配置不依赖 Node.js 或 npm。`required = false` 使 Godot 编辑器未启动时的普通仓库任务不会因此启动失败。

本项目目标引擎锁定为 Godot 4.6 与 GL Compatibility，不锁定补丁版本；本机继续使用当前已安装的 4.6 补丁版本。不能把“更新到最新”解释为自动升级到其他次版本；后续引擎迁移需要单独授权，并重新验证 API、导入结果、正式主线、视觉效果和导出。

插件升级必须作为一次受审查的项目基础设施修改完成：同步替换 `addons/godot_ai/`、核对许可证和上游版本、重新审计 `.codex/config.toml` 的工具列表、确认插件与服务器版本一致，并验证导出时仍会移除 `_mcp_game_helper`。不要把个人编辑器中的一键自更新当作团队升级流程。

## 跨电脑部署基线

仓库本身携带插件和 Codex 项目配置，不依赖提交者电脑的绝对路径或用户级 MCP 配置。新电脑应满足以下条件：

1. 使用 Godot `4.6.x` 打开仓库并保持 GL Compatibility；不要因插件 README 推荐更新版本而迁移项目引擎。
2. 安装 `uv`，确保 `uvx` 能被从图形界面启动的 Godot 找到。首次启动需要从 PyPI 下载 `godot-ai==3.2.0` 及其 Python 依赖，因此需要临时网络访问并可能比后续启动慢；离线电脑应在联网时先完成一次缓存预热。
3. 保持 `127.0.0.1:8000` 可用，并让插件 HTTP 端口与 `.codex/config.toml` 的 URL 一致。若因端口冲突必须改端口，应在该电脑的 Godot AI 设置和项目配置中同步调整；不要改成局域网或公网地址。
4. 在 Codex 中信任并从仓库根目录打开项目，使 `.codex/config.toml` 生效；不需要也不应复制到 `~/.codex/config.toml`。其他 MCP 客户端必须单独建立等价白名单。
5. 等 Godot AI 面板显示插件与服务器均为 `3.2.0` 后，新开 Codex 任务或重连 MCP，再核对项目名、项目路径、会话和只读工具。

macOS、Windows 与 Linux 的 `uvx` 路径由插件在本机发现，不写入仓库；Windows 使用 `uvx.exe`/`pythonw.exe` 的专用启动路径。游戏运行和导出不要求 MCP 服务在线：Godot AI 是编辑器插件，导出钩子会从导出快照移除 `_mcp_game_helper`。因此没有安装 Codex 或 `uv` 的玩家电脑不受影响，但开发电脑若缺少 `uv` 将无法使用 MCP。

升级提交必须包含 `addons/godot_ai/` 下所有新增文件及其上游 UID 文件。若 Git 状态仍显示该目录内有未跟踪文件，升级尚未具备跨电脑可复制性，不得仅提交 `plugin.cfg` 或已有文件的修改。

## 权限边界

- `.codex/config.toml` 中的 `enabled_tools` 是 Codex 客户端白名单；以该文件为唯一清单，不在本文复制一份容易漂移的列表。
- `default_tools_approval_mode = "writes"` 表示非只读工具仍需审批；工具可见不等于当前任务获得修改授权。
- MCP 权限按工具控制，不按目录控制。服务端不会自动区分 `Formal/`、`Backup/` 和测试目录，正式内容仍受 `AGENTS.md`、Project Skill 和当前任务范围约束。
- Godot AI 服务可以向其他本地客户端公布比 Codex 白名单更大的工具面。每个非 Codex 客户端都要建立等价的显式白名单；Godot AI 的域排除只能作为补充防线，不能替代客户端白名单。
- Godot AI 3.2.0 的 `node_manage` 把删除、复制、重命名、移动、重设父节点与分组添加/移除打包在同一个工具中。除非任务明确需要，不得调用分组写入操作。
- Godot AI 3.2.0 的 `tileset_manage` 只有 TileSet 图集读取能力。不得声称已开放或验证 TileSet 写入；TileMap 写入与 TileSet 读取必须分开描述。
- Godot AI 3.2.0 新增 `custom_manage` 及可提升为独立 MCP 工具的第三方注册入口。本项目当前没有注册自定义工具，因此 `.codex/config.toml` 有意不开放 `custom_manage`；引入自定义工具必须先审查来源、参数校验、写入标记、撤销能力与超时，再单独调整白名单。

## 网络与隐私

MCP 传输必须保持在 `http://127.0.0.1:8000/mcp`，不得配置局域网或公网监听。这里的“回环限定”只描述 MCP 接入地址，不代表插件完全离线：Godot AI 会检查 GitHub 更新，并且遥测在未设置偏好时默认启用。

若任务要求零遥测，可在 Godot AI 设置中关闭 Telemetry，或使用 `GODOT_AI_DISABLE_TELEMETRY=true`；修改后需要重启插件/编辑器并重新核对。不要在仓库中保存任何遥测标识、认证信息或网络密钥。

## 隔离测试与清理

MCP 写入测试必须位于与正式场景链无依赖关系的隔离路径。测试结束后：

1. 若它不是明确批准的长期回归夹具，删除测试场景、截图、日志和重复许可证副本。
2. 若要保留为回归夹具，必须明确命名、纳入 Git，并证明正式场景、Autoload 和配置资源均不依赖它。
3. 删除前先让 Godot 编辑器离开目标场景，避免编辑器把已删除场景重新保存。

## 验证清单

每次配置、插件或权限变更后至少确认：

1. 当前仓库根目录和 Godot 项目均为 HackathonGame。
2. 编辑器版本属于 Godot 4.6 分支，插件与服务器版本一致。
3. 服务只监听 `127.0.0.1`，没有远程主机放行。
4. 编辑器状态和会话列表只指向 HackathonGame；多会话时已经显式激活正确会话。
5. Codex 实际工具集合与 `.codex/config.toml` 完全一致，没有额外工具。
6. 写入审批仍为 `writes`，并通过只读状态、场景树和日志检查。
7. 已如实报告 `node_manage` 的打包操作、TileSet 只读限制和 `custom_manage` 的默认禁用状态。
8. `addons/godot_ai/` 与官方发布包一致，且该目录没有遗漏的未跟踪升级文件。
9. `git diff --check` 通过，最终 Git 状态只包含预期文件。
