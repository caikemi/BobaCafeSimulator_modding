# Lua 生命周期与 Context

[返回中文首页](../../README.md) | [English](../en/03-lua-and-context.md)

API v3 的 Lua 入口必须返回一个 table。推荐只保留局部状态，不创建全局变量。

## 生命周期

```lua
local M = {}
local loadedEventSequence = 0

function M.OnLoad(Context)
    local result = Context.Events:Subscribe("game.world_ready")
    if not result.bSuccess then
        return false
    end
    return true
end

function M.OnModEvent(Context, Event)
    loadedEventSequence = Event.Sequence
end

function M.OnUnload(Context)
    -- 可做轻量清理；内容和订阅由宿主统一回滚。
end

return M
```

### OnLoad(Context)

Context 初始状态为 `Loading`。这里可以：

- 订阅事件。
- 通过 `Context.Content` 暂存内容定义。
- 读取/修改尚未落盘的 MOD 存储值。
- 写日志和检查清单信息。

这里不能执行需要 Active 的动作：支付账单、给予/移除物品、修改任务、显示 UI、主动 `Storage:Flush()`。这些调用会返回 `InvalidState`。

`OnLoad` 返回 `true` 后，宿主校验并一次性提交订阅、内容和存储。返回 `false`、抛出 Lua 错误或提交失败会回滚整个 Context。

兼容 API v2 的加载器也接受 `OnInit(dir, Context)`，但新代码必须使用 `OnLoad(Context)`。

### OnModEvent(Context, Event)

只接收已订阅的事件。Context 已是 `Active`，运行时写服务可以在这里调用。事件结构见[事件文档](05-events.md)。

### OnUnload(Context)

MOD 禁用、卸载或世界退出时调用。宿主随后会取消订阅、回滚内容、关闭 Context，并按正常卸载流程持久化脏存储。不要在这里创建新内容；也不要依赖世界 Actor 仍然有效。

## Context 方法和服务

| 成员 | 说明 |
| --- | --- |
| `Context:GetInfo()` | 完整 `FBaseInstallModInfo` |
| `Context:GetModId()` | 清单 ID |
| `Context:GetModVersion()` | 清单版本 |
| `Context:GetAPIVersion()` | API 版本 |
| `Context:GetState()` | `Loading`、`Active`、`Failed`、`Unloading` |
| `Context:MakeQualifiedId(LocalId)` | 生成 `ModId:LocalId` |
| `Context:HasPermission(Name)` | 是否获准该权限 |
| `Context:Log(Message)` | 写入带 MOD 身份的日志 |
| `Context.Events` | 事件订阅 |
| `Context.Content` | 内容定义与注册 |
| `Context.Economy` | 经济快照和账单支付 |
| `Context.Storage` | MOD 私有字符串存储 |
| `Context.Inventory` | 玩家背包 |
| `Context.Tasks` | 玩家任务进度 |
| `Context.UI` | 普通玩家提示 |

`SourceDirectory` 是宿主拥有的绝对目录信息，不代表 Lua 获得任意文件访问。清单环境没有 `io`。

## 返回值

多数操作返回 `FBaseInstallModResult`：

| 字段 | 含义 |
| --- | --- |
| `bSuccess` | 是否成功 |
| `Code` | `None`、`InvalidArgument`、`InvalidId`、`InvalidState`、`AlreadyExists`、`NotFound`、`PermissionDenied`、`InternalError` |
| `Message` | 失败说明 |
| `Value` | 可选字符串结果 |

安全写法：

```lua
local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "ModAPI returned no result")
    end
end
```

读取数量使用 `FBaseInstallModIntegerResponse`，检查 `bSuccess`、`Error` 和 `Value`。经济读取使用 `FBaseInstallModEconomySnapshot`，检查 `bSuccess`、`Error`、`Balance` 和 `Bills`。

## 受限环境

清单 MOD 提供安全的 Lua 基础函数，以及只读的 `math`、`string`、`table`、`utf8`、`print` 和 `Context`。以下全局不可用：

```text
UE
GAA
MOD.Playercontroller
PlayerController
io
os
debug
package
require
load
```

因此不要把 API v1 代码直接复制到 `v3.lua`。需要的能力应通过公开服务实现；尚未公开的能力应等待新 API，而不是绕过沙箱。

## 内容事务

每个 `ContentId` 是 MOD 内局部 ID，提交后由宿主限定为 `ModId:ContentId`。局部 ID：

- 1–128 字符。
- 允许字母、数字、`.`、`_`、`-`、`/`。
- 禁止首尾 `/`、`..` 和 `:`。

同一事务内 `ContentId` 必须唯一。新内容与宿主已有 ID 冲突会失败，除非定义设置 `bPatchExisting=true` 且清单同时拥有 `content.register` 和 `content.patch`。

提交、回滚和覆盖层重放都由宿主管理。不要在 `OnUnload` 手动删除注册表条目。

## Lua 编码与可维护性

- 文件使用 UTF-8。
- 入口最后必须 `return M`。
- 把常量和状态声明为 `local`。
- 不要依赖 MOD 文件夹绝对路径。
- 每个外部调用都检查结果并记录具体错误。
- 不在 Tick 风格事件中进行高频写操作；优先消费离散业务事件。
