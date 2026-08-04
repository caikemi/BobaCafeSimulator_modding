# Runtime services: Economy, Storage, Inventory, Tasks, and UI

[Back to the English home page](../../README_EN.md) | [中文](../zh/06-runtime-services.md)

These services constrain common tasks behind stable, validated interfaces. Check every result. A granted permission does not guarantee that state, authority, player index, or business data is valid.

## Economy

### GetSnapshot()

Requires `economy.read`:

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

A snapshot is a current read, not an event-stream guarantee. Subscribe to economy events to react to changes.

### TryPayBill(BillType, Amount)

Requires `economy.pay-bills`, an Active Context, server authority, and a finite positive amount.

Supported `BillType` values:

- `WaterRate`
- `Utility`
- `Rent`
- `Payroll`

`Tax` is readable in the snapshot, but the current public payment API does not accept `Tax`.

```lua
local paid = Context.Economy:TryPayBill("Utility", 50)
if not paid.bSuccess then
    Context:Log("Payment failed: " .. tostring(paid.Message))
end
```

The host reuses MultiGameState's atomic charge and bill-update flow. A successful payment emits `economy.money_changed` and `economy.bill_paid`.

Complete example: [AutoPayDailyBill](../../Example_EN/AutoPayDailyBill/).

## Storage

Each mod has isolated string key/value storage:

```text
Saved/Mods/Data/<ModId>/storage.json
```

The complete JSON is capped at 64 KiB. A mod cannot read another namespace or arbitrary files through this service.

| Method | Permission | Result |
| --- | --- | --- |
| `GetString(Key, DefaultValue)` | `storage.read` | `FBaseInstallModResult.Value` |
| `SetString(Key, Value)` | `storage.write` | result |
| `Remove(Key)` | `storage.write` | `Value` is `"true"` or `"false"` |
| `GetKeys()` | `storage.read` | sorted string array |
| `Flush()` | `storage.write` | explicitly persists while Active |

A key is at most 128 characters and uses letters, numbers, `.`, `_`, `-`, and `/`. It cannot start/end with `/` or contain `..`.

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

Set/Remove may run in `OnLoad`. A successful Context commit writes atomically; a failed load does not persist. Once Active, `Flush` is available, and normal unload also persists dirty data. The service writes a temporary file and replaces the target to avoid partial output.

Storage holds strings only. A mod may encode compact data itself, still within the total quota. Manifest Lua has no JSON module or file API; do not assume `require` exists.

## Inventory

### GetItemCount(PlayerIndex, ItemId)

Requires `inventory.read` and returns `FBaseInstallModIntegerResponse`:

```lua
local response = Context.Inventory:GetItemCount(0, "SomeItem")
if response.bSuccess then
    Context:Log("Count: " .. tostring(response.Value))
else
    Context:Log("Read failed: " .. tostring(response.Error))
end
```

`PlayerIndex >= 0` and `ItemId` must be non-empty.

### GrantItem / RemoveItems

Require `inventory.write`, an Active Context, server authority, and Count from 1–100:

```lua
local grant = Context.Inventory:GrantItem(0, "SomeItem", 1)
local removed = Context.Inventory:RemoveItems(0, "SomeItem", 2)

if removed.bSuccess then
    Context:Log("Actually removed: " .. tostring(removed.Value))
end
```

`RemoveItems.Value` is the actual removed count. Do not assume all requested units existed.

## Tasks

`AddProgress(PlayerIndex, TaskTag, Count, bSetCount)` requires `tasks.write`, Active state, and server authority.

- `PlayerIndex >= 0`.
- `TaskTag` must be a Gameplay Tag already registered by the host.
- `Count` is 1–100000.
- `bSetCount=false` adds; `true` sets the value to Count.

```lua
local result = Context.Tasks:AddProgress(
    0,
    "任务.制作饮品",
    1,
    false
)
```

The Tag above shows the call shape only. Test a real current-game Tag before release; the public API cannot dynamically register task tags.

## UI

`ShowNotification(PlayerIndex, Message)` requires `ui.notify` and Active state. The message must be non-empty and at most 512 characters:

```lua
local shown = Context.UI:ShowNotification(0, "Mod reward granted")
if not shown.bSuccess then
    Context:Log(tostring(shown.Message))
end
```

The service only reuses the game's ordinary player notification and Client RPC. It does not expose arbitrary Widgets, input capture, HUD injection, or UI-class loading.

## Active-stage combined example

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
            Context.UI:ShowNotification(0, "Daily item granted")
        end
    end

    Context.Storage:SetString("daily/last_event", tostring(Event.Sequence))
    Context.Storage:Flush()
end
```

The manifest must include the actually used `inventory.read`, `inventory.write`, `ui.notify`, and `storage.write`. Never ship the placeholder ItemId/TaskTag from this example.
