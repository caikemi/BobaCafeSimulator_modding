# Event API and host Blueprint integration

[Back to the English home page](../../README_EN.md) | [中文](../zh/05-events.md)

Mods subscribe through `Context.Events`. Events contain stable IDs, strings, numbers, and booleans—never Actors, PlayerControllers, GameState, or other internal UObjects.

## Mod-author usage

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

Methods:

- `Subscribe(EventName)`: returns `FBaseInstallModResult`.
- `Unsubscribe(EventName)`
- `UnsubscribeAll()`
- `IsSubscribed(EventName)`

An event name is at most 128 characters, uses only letters, numbers, `.`, `_`, `-`, and `:`, is lower-case, and contains `.` or `:`. Use `com.author.mod:event_name` for custom events.

## Event structure

| Field | Meaning |
| --- | --- |
| `EventName` | Event name |
| `Payload.SubjectId` | Stable ID of the primary subject |
| `Payload.InstigatorId` | Stable ID of the initiator |
| `Payload.StringValues` | String map |
| `Payload.NumberValues` | Number map |
| `Payload.BoolValues` | Boolean map |
| `Sequence` | Monotonically increasing sequence on the current bus |
| `RealTimeSeconds` | Real-time seconds at broadcast |
| `bIsServer` | Whether the event came from an authoritative server world |
| `bIsDedicatedServer` | Whether that world is a Dedicated Server |

Payload keys use lower-case `snake_case`. A Sequence is not a persistent ID across saves or processes.

## Built-in event table

### Lifecycle

| Event | Producer | Correct point | Payload |
| --- | --- | --- | --- |
| `game.save_loaded` | Blueprint/save flow | After every save module restores successfully | Suggested: `slot_name`, `save_version`, `is_new_game` |
| `game.world_ready` | Blueprint/startup flow | After GameState, managers, and save state are usable | Suggested: `map_name` |
| `game.local_player_ready` | Local client Blueprint | After Controller, Pawn, and player Context are bound | `SubjectId=player_id` |
| `game.morning_started` | Server/standalone Blueprint | After the new day and bills initialize, before opening | Suggested: `day`, `season`, `weekday` |
| `game.shop_opened` | Server/standalone Blueprint | After the open state succeeds | Suggested: `day` |
| `game.day_ending` | Server/standalone Blueprint | Once, before day-end calculation | Suggested: `day` |
| `game.day_ended` | Server/standalone Blueprint | After settlement, rewards, and save finish | Suggested: `day`, `gross_income`, `expenses`, `net_income` |
| `game.world_teardown` | Automatic C++ | MultiBaseController EndPlay | `map_name`, `reason` |

Recommended order:

```text
save_loaded → world_ready → local_player_ready
→ morning_started → shop_opened
→ day_ending → day_ended → world_teardown
```

### Economy

| Event | Producer | Payload |
| --- | --- | --- |
| `economy.money_changed` | C++ after an authoritative MultiGameState money change | `SubjectId=shared_shop`; `old_balance`, `new_balance`, `delta`, `reason` |
| `economy.bill_created` | C++ after a bill Add succeeds | `SubjectId=bill_type`; `bill_type`, optional `bill_key`, `amount`, `outstanding_amount` |
| `economy.bill_paid` | C++ after charge and bill update complete | `SubjectId=bill_type`; `bill_type`, `amount`, `remaining_amount`, `new_balance` |

A successful payment emits both one `economy.money_changed` and one `economy.bill_paid`. A mod subscribing to both must avoid duplicate rewards.

### Orders and drinks

| Event / Blueprint node | Point | Payload |
| --- | --- | --- |
| `order.placed` / `Notify Order Placed` | After the customer order enters authoritative order data | `SubjectId=order_id`, `InstigatorId=customer_id`, `customer_id`, `drink_id`, `total_price`, `is_delivery_order` |
| `order.submitted` / `Notify Order Submitted` | After player submission validates and the order is marked submitted | `SubjectId=order_id`, `InstigatorId=player_id`, `player_id`, `drink_id`, `is_perfect_order` |
| `order.picked_up` / `Notify Order Picked Up` | After the customer physically takes the submitted item | `SubjectId=order_id`, `InstigatorId=customer_id`, `customer_id`, `player_id`, `drink_id` |
| `drink.created` / `Notify Drink Created` | After Blueprint Control finishes drink-instance initialization | `SubjectId=drink_instance_id`, `InstigatorId=player_id`, `drink_id`, `player_id`, `quality` |

These mean “customer placed,” “player submitted,” and “customer picked up.” They are distinct stages.

### Item placement

`item.placed` is emitted automatically by C++ after authoritative server success in `Dispatch_PutOnTableOrLand`:

- `SubjectId=actor_uid`
- `InstigatorId` is the player-index string
- Strings: `item_id`, `target_id`
- Numbers: `player_index`, `x`, `y`, `z`, `pitch`, `yaw`, `roll`
- Boolean: `placed_on_actor`

It means a held item was put on a table or the ground, not that furniture construction completed.

## Events that explicitly do not exist

Do not subscribe to or add Blueprint calls for:

- `game.shop_closed`: there is no stop-taking-orders business point yet.
- `drink.served`: customer pickup is `order.picked_up`.
- `furniture.placed`: current `item.placed` is not a furniture-completion event.
- `furniture.removed`: not needed currently.

## Blueprint checklist for game developers

C++ already handles economy, `item.placed`, and `game.world_teardown`. Blueprints only need these at real success points:

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

Prefer `Notify Core Mod Event` with its enum for payload-free core events. Use `Notify Mod Event With Payload` or the dedicated node for business data. Emit authoritative actions once on the server success branch; do not duplicate them from client OnRep, UI refresh, Tick, or failure branches.

A false broadcast result means the world, subsystem, or arguments were unsuitable. It must never block original game logic.
