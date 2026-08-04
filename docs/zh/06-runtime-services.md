# 运行时服务：Economy、Storage、Inventory、Tasks、UI

[返回中文首页](../../README.md) | [English](../en/06-runtime-services.md)

这些服务把常见需求限制在稳定、可校验的接口内。每次调用都要检查结果；拥有权限不代表状态、服务器权威、玩家索引或业务数据一定有效。

## Economy

### GetSnapshot()

需要 `economy.read`：

```lua
local snapshot = Context.Economy:GetSnapshot()
if not snapshot.bSuccess then
    Context:Log("Economy read failed: " .. tostring(snapshot.Error))
    return
end

local balance = snapshot.Balance
local water = snapshot.Bills.WaterRate
local utility = snapshot.Bills.Utility
local rent = snapshot.Bills.Rent
local payroll = snapshot.Bills.Payroll
local tax = snapshot.Bills.Tax
```

快照字段都是当前读取值，不是事件流保证。要响应变化请订阅经济事件。

### TryPayBill(BillType, Amount)

需要 `economy.pay-bills`，Context 必须 Active，只能在服务器权威端执行，金额必须是有限正数。

支持的 `BillType`：

- `WaterRate`
- `Utility`
- `Rent`
- `Payroll`

`Tax` 可以在快照中读取，但当前公共支付接口不接受 `Tax`。

```lua
local paid = Context.Economy:TryPayBill("Utility", 50)
if not paid.bSuccess then
    Context:Log("Payment failed: " .. tostring(paid.Message))
end
```

宿主复用 MultiGameState 的原子扣款和账单更新逻辑。成功支付会产生 `economy.money_changed` 和 `economy.bill_paid`。

完整示例：[AutoPayDailyBill](../../Example_ZH/AutoPayDailyBill/)。

## Storage

每个 MOD 有独立的字符串键值存储：

```text
Saved/Mods/Data/<ModId>/storage.json
```

总 JSON 大小上限 64 KiB。MOD 不能通过这个服务读取别人的命名空间或任意文件。

| 方法 | 权限 | 返回 |
| --- | --- | --- |
| `GetString(Key, DefaultValue)` | `storage.read` | `FBaseInstallModResult.Value` |
| `SetString(Key, Value)` | `storage.write` | result |
| `Remove(Key)` | `storage.write` | `Value` 为 `"true"` 或 `"false"` |
| `GetKeys()` | `storage.read` | 排序后的字符串数组 |
| `Flush()` | `storage.write` | Active 时主动落盘 |

Key 最长 128 字符，仅允许字母、数字、`.`、`_`、`-`、`/`；禁止首尾 `/` 和 `..`。

```lua
local current = Context.Storage:GetString("autopay/last_sequence", "0")
if current.bSuccess then
    Context:Log("Last sequence: " .. current.Value)
end

local set = Context.Storage:SetString("autopay/last_sequence", "42")
if not set.bSuccess then
    Context:Log(tostring(set.Message))
end
```

`OnLoad` 中可以 Set/Remove。成功提交时宿主原子写盘；加载失败时不会落盘。Active 后可以主动 `Flush`，正常卸载也会持久化脏数据。文件先写临时文件再替换，避免半写入。

Storage 只存字符串；复杂数据由 MOD 自己编码为短字符串，但仍受总配额限制。清单 Lua 没有 JSON 模块或文件 API，不要假定 `require` 可用。

## Inventory

### GetItemCount(PlayerIndex, ItemId)

需要 `inventory.read`。返回 `FBaseInstallModIntegerResponse`：

```lua
local response = Context.Inventory:GetItemCount(0, "SomeItem")
if response.bSuccess then
    Context:Log("Count: " .. tostring(response.Value))
else
    Context:Log("Read failed: " .. tostring(response.Error))
end
```

`PlayerIndex >= 0` 且 `ItemId` 非空。

### GrantItem / RemoveItems

需要 `inventory.write`，Context Active，服务器权威，单次 Count 为 1–100：

```lua
local grant = Context.Inventory:GrantItem(0, "SomeItem", 1)
local removed = Context.Inventory:RemoveItems(0, "SomeItem", 2)

if removed.bSuccess then
    Context:Log("Actually removed: " .. tostring(removed.Value))
end
```

`RemoveItems` 的 `Value` 是实际移除数量。不要假定请求数量一定全部存在。

## Tasks

`AddProgress(PlayerIndex, TaskTag, Count, bSetCount)` 需要 `tasks.write`、Active Context 和服务器权威。

- `PlayerIndex >= 0`
- `TaskTag` 必须是宿主已经注册的 Gameplay Tag。
- `Count` 为 1–100000。
- `bSetCount=false` 表示增加；`true` 表示设置为 Count。

```lua
local result = Context.Tasks:AddProgress(
    0,
    "任务.制作饮品",
    1,
    false
)
```

文档中的 Tag 只是调用形状示例。发布 MOD 前必须用当前游戏实际存在的 Tag 测试；公共 API 当前不能动态注册任务 Tag。

## UI

`ShowNotification(PlayerIndex, Message)` 需要 `ui.notify` 和 Active Context。消息不能为空，最长 512 字符：

```lua
local shown = Context.UI:ShowNotification(0, "MOD 奖励已发放")
if not shown.bSuccess then
    Context:Log(tostring(shown.Message))
end
```

该服务只复用游戏已有的普通玩家提示和 Client RPC。它不开放任意 Widget、输入捕获、HUD 注入或 UI 类加载。

## Active 阶段组合示例

```lua
function M.OnLoad(Context)
    return Context.Events:Subscribe("game.morning_started").bSuccess
end

function M.OnModEvent(Context, Event)
    if Event.EventName ~= "game.morning_started" then
        return
    end

    local count = Context.Inventory:GetItemCount(0, "SomeItem")
    if count.bSuccess and count.Value == 0 then
        local grant = Context.Inventory:GrantItem(0, "SomeItem", 1)
        if grant.bSuccess then
            Context.UI:ShowNotification(0, "已发放每日物品")
        end
    end

    Context.Storage:SetString("daily/last_event", tostring(Event.Sequence))
    Context.Storage:Flush()
end
```

清单必须包含实际使用的 `inventory.read`、`inventory.write`、`ui.notify`、`storage.write`。不要复制示例里的假 ItemId/TaskTag 到发布版。
