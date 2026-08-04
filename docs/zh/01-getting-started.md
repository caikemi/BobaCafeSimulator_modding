# 五分钟快速开始

[返回中文首页](../../README.md) | [English](../en/01-getting-started.md)

本教程创建一个不依赖 PAK 的 API v3 MOD，并确认宿主能够识别、加载和提交它。

## 1. 创建目录

```text
BobaCafeSimulator/Mods/HelloBoba/
├── mod.json
├── v3.lua
└── preview.png     # 可选，推荐 256×256
```

目录名建议只使用英文字母、数字、下划线和连字符。真正的稳定身份来自 `mod.json.id`，不要在发布后更改。

## 2. 编写清单

```json
{
  "schemaVersion": 1,
  "id": "com.example.hello_boba",
  "name": "Hello Boba",
  "version": "1.0.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": [],
  "dependencies": []
}
```

这个示例没有使用受保护服务，所以 `permissions` 为空。不要为了方便申请 `*`；清单会拒绝通配符。

## 3. 编写入口

```lua
local M = {}

function M.OnLoad(Context)
    Context:Log("Hello from " .. Context:GetModId())
    return true
end

return M
```

`OnLoad` 返回 `true` 后，宿主才提交 Context。如果脚本抛错、返回 `false`，或者任何暂存内容校验失败，整个加载会回滚。

## 4. 安装并验证

1. 把整个 `HelloBoba` 文件夹复制到游戏的 `BobaCafeSimulator/Mods/`。
2. 启动游戏，在 Mods 菜单启用它。
3. 重新进入需要加载 MOD 的游戏世界。
4. 打开日志，搜索 `Hello from com.example.hello_boba`。
5. 禁用 MOD 后再次进入，确认没有残留行为。

## 5. 增加一个事件

在 `permissions` 中加入 `ui.notify`：

```json
"permissions": ["ui.notify"]
```

然后替换 Lua：

```lua
local M = {}

function M.OnLoad(Context)
    local result = Context.Events:Subscribe("game.morning_started")
    if not result.bSuccess then
        Context:Log("Subscribe failed: " .. tostring(result.Message))
        return false
    end
    return true
end

function M.OnModEvent(Context, Event)
    if Event.EventName == "game.morning_started" then
        local shown = Context.UI:ShowNotification(0, "新的一天开始了")
        if not shown.bSuccess then
            Context:Log("Notification failed: " .. tostring(shown.Message))
        end
    end
end

return M
```

运行时写操作必须放在 `OnModEvent` 等 Active 阶段，而不是 `OnLoad`。如果项目蓝图尚未在早晨业务成功点广播 `game.morning_started`，这个回调不会发生；事件接入状态见[事件文档](05-events.md)。

## 6. 选择下一步

- 添加饮品或家具：[内容 API](04-content-api.md)
- 读账单、自动缴费或保存状态：[运行时服务](06-runtime-services.md)
- 制作包含模型的资产包：[PAK 打包教程](../../Model_PAK_Packaging_ZH.md)
- 使用蓝图/DataAsset：[蓝图资产文档](07-blueprint-data-assets.md)

## 发布前最小检查

- `mod.json` 是 UTF-8、合法 JSON，且小于 256 KiB。
- `entry` 存在、以 `.lua` 结尾，并位于 MOD 目录内部。
- 只申请实际使用的权限。
- 所有注册调用都检查 `bSuccess`。
- 在无存档、新存档、读档、禁用和重新启用条件下各测试一次。
- 联机 MOD 不要把 `networkPolicy` 当作已完成的握手保证；当前仍需作者明确说明主机和客户端安装要求。
