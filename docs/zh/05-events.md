# 事件 API 与宿主蓝图接入

[返回中文首页](../../README.md) | [English](../en/05-events.md)

MOD 通过 `Context.Events` 订阅稳定事件。事件只传 ID、字符串、数字和布尔值，不传 Actor、PlayerController、GameState 或其他内部 UObject。

## MOD 作者用法

```lua
function M.OnLoad(Context)
    local a = Context.Events:Subscribe("order.picked_up")
    local b = Context.Events:Subscribe("economy.bill_created")
    return a.bSuccess and b.bSuccess
end

function M.OnModEvent(Context, Event)
    if Event.EventName == "order.picked_up" then
        Context:Log("Picked up order " .. tostring(Event.Payload.SubjectId))
    end
end
```

可用方法：

- `Subscribe(EventName)`：返回 `FBaseInstallModResult`。
- `Unsubscribe(EventName)`
- `UnsubscribeAll()`
- `IsSubscribed(EventName)`

事件名称最长 128 字符，只能使用字母、数字、`.`、`_`、`-`、`:`，必须全小写并包含 `.` 或 `:`。自定义事件建议使用 `com.author.mod:event_name`。

## Event 结构

| 字段 | 含义 |
| --- | --- |
| `EventName` | 事件名 |
| `Payload.SubjectId` | 主要对象稳定 ID |
| `Payload.InstigatorId` | 发起者稳定 ID |
| `Payload.StringValues` | 文本键值 |
| `Payload.NumberValues` | 数字键值 |
| `Payload.BoolValues` | 布尔键值 |
| `Sequence` | 当前事件总线单调递增序号 |
| `RealTimeSeconds` | 广播时的真实时间秒 |
| `bIsServer` | 是否来自服务器权威世界 |
| `bIsDedicatedServer` | 是否 Dedicated Server |

Payload 键固定使用小写 `snake_case`。不要把 Sequence 当成跨存档或跨进程永久 ID。

## 内建事件总表

### 生命周期

| 事件 | 谁广播 | 正确时机 | Payload |
| --- | --- | --- | --- |
| `game.save_loaded` | 蓝图/存档业务 | 所有存档模块恢复成功后 | 建议：`slot_name`、`save_version`、`is_new_game` |
| `game.world_ready` | 蓝图/启动业务 | GameState、Manager、存档均可用后 | 建议：`map_name` |
| `game.local_player_ready` | 本地客户端蓝图 | Controller、Pawn、玩家 Context 均绑定后 | `SubjectId=player_id` |
| `game.morning_started` | 服务器/单机蓝图 | 新一天和账单初始化完成、开店前 | 建议：`day`、`season`、`weekday` |
| `game.shop_opened` | 服务器/单机蓝图 | 营业状态修改成功后 | 建议：`day` |
| `game.day_ending` | 服务器/单机蓝图 | 日结开始前，只广播一次 | 建议：`day` |
| `game.day_ended` | 服务器/单机蓝图 | 日结、奖励和存档完成后 | 建议：`day`、`gross_income`、`expenses`、`net_income` |
| `game.world_teardown` | C++ 自动 | MultiBaseController EndPlay | `map_name`、`reason` |

推荐顺序：

```text
save_loaded → world_ready → local_player_ready
→ morning_started → shop_opened
→ day_ending → day_ended → world_teardown
```

### 经济

| 事件 | 谁广播 | Payload |
| --- | --- | --- |
| `economy.money_changed` | C++，MultiGameState 权威改钱成功后 | `SubjectId=shared_shop`; `old_balance`、`new_balance`、`delta`、`reason` |
| `economy.bill_created` | C++，账单 Add 成功后 | `SubjectId=bill_type`; `bill_type`、可选 `bill_key`、`amount`、`outstanding_amount` |
| `economy.bill_paid` | C++，扣款和账单更新完成后 | `SubjectId=bill_type`; `bill_type`、`amount`、`remaining_amount`、`new_balance` |

支付成功会同时产生一次 `economy.money_changed` 和一次 `economy.bill_paid`。MOD 若同时订阅两者必须避免重复奖励。

### 订单和饮品

| 事件/蓝图节点 | 时机 | Payload |
| --- | --- | --- |
| `order.placed` / `Notify Order Placed` | 顾客订单成功加入权威订单数据后 | `SubjectId=order_id`、`InstigatorId=customer_id`、`customer_id`、`drink_id`、`total_price`、`is_delivery_order` |
| `order.submitted` / `Notify Order Submitted` | 玩家出单校验通过且订单已标记提交后 | `SubjectId=order_id`、`InstigatorId=player_id`、`player_id`、`drink_id`、`is_perfect_order` |
| `order.picked_up` / `Notify Order Picked Up` | 顾客实际拿走出单物品后 | `SubjectId=order_id`、`InstigatorId=customer_id`、`customer_id`、`player_id`、`drink_id` |
| `drink.created` / `Notify Drink Created` | 蓝图 Control 完成饮品实例数据初始化后 | `SubjectId=drink_instance_id`、`InstigatorId=player_id`、`drink_id`、`player_id`、`quality` |

这三个订单事件分别表示“顾客刚下单”“玩家完成出单”“顾客拿单”，不能互相替代。

### 物品摆放

`item.placed` 由 C++ 在服务器 `Dispatch_PutOnTableOrLand` 权威摆放成功后自动广播：

- `SubjectId=actor_uid`
- `InstigatorId=player_index` 的字符串
- String：`item_id`、`target_id`
- Number：`player_index`、`x`、`y`、`z`、`pitch`、`yaw`、`roll`
- Bool：`placed_on_actor`

它是通用“手持物品放在桌面或地面”事件，不等同于家具建造完成。

## 当前明确没有的事件

不要订阅或在蓝图添加：

- `game.shop_closed`：当前没有停止接单业务点。
- `drink.served`：顾客拿单使用 `order.picked_up`。
- `furniture.placed`：当前 `item.placed` 不是专用家具完成事件。
- `furniture.removed`：当前不需要。

## 给游戏开发者的蓝图清单

C++ 已自动处理经济、`item.placed` 和 `game.world_teardown`。蓝图只需要在真实业务成功点补：

- `game.save_loaded`
- `game.world_ready`
- `game.local_player_ready`
- `game.morning_started`
- `game.shop_opened`
- `game.day_ending`
- `game.day_ended`
- `Notify Order Placed`
- `Notify Order Submitted`
- `Notify Order Picked Up`
- `Notify Drink Created`

没有 Payload 的核心事件优先使用 `Notify Core Mod Event` 并选择枚举。有业务数据时使用 `Notify Mod Event With Payload` 或对应专用节点。所有权威业务只在服务器成功分支广播一次；不要在客户端 OnRep、UI 刷新、Tick 或失败分支重复广播。

事件广播返回 false 只表示世界/Subsystem/参数不满足，不应阻断原游戏逻辑。
