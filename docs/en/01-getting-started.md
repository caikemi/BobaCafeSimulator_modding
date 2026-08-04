# Five-minute quick start

[Back to the English home page](../../README_EN.md) | [中文](../zh/01-getting-started.md)

This tutorial creates an API v3 mod that needs no PAK and verifies that the host can discover, load, and commit it.

## 1. Create the folder

```text
BobaCafeSimulator/Mods/HelloBoba/
├── mod.json
├── v3.lua
└── preview.png     # optional; 256×256 is recommended
```

Use letters, numbers, underscores, and hyphens for the folder name. The stable identity is `mod.json.id`; do not change it after publishing.

## 2. Write the manifest

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

This example uses no protected service, so `permissions` is empty. Do not request `*`; wildcard permissions are rejected.

## 3. Write the entry point

```lua
local M = {}

function M.OnLoad(Context)
    Context:Log("Hello from " .. Context:GetModId())
    return true
end

return M
```

The host commits the Context only after `OnLoad` returns `true`. A Lua error, `false` return, or staged-content validation failure rolls the complete load back.

## 4. Install and verify

1. Copy the complete `HelloBoba` folder under the game's `BobaCafeSimulator/Mods/`.
2. Start the game and enable it in the Mods menu.
3. Re-enter a game world where mods are loaded.
4. Open the log and search for `Hello from com.example.hello_boba`.
5. Disable the mod, enter again, and confirm that no behavior remains.

## 5. Add an event

Add `ui.notify` to `permissions`:

```json
"permissions": ["ui.notify"]
```

Replace the Lua with:

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
        local shown = Context.UI:ShowNotification(0, "A new day has started")
        if not shown.bSuccess then
            Context:Log("Notification failed: " .. tostring(shown.Message))
        end
    end
end

return M
```

Runtime mutations belong in `OnModEvent` or another Active-stage callback, not in `OnLoad`. If the host Blueprint has not emitted `game.morning_started` at the successful start-of-morning point, this callback will not fire; see the [event documentation](05-events.md).

## 6. Choose the next step

- Add a drink or furniture: [Content API](04-content-api.md)
- Read bills, pay automatically, or save state: [Runtime services](06-runtime-services.md)
- Build a model asset pack: [PAK packaging guide](../../Model_PAK_Packaging_EN.md)
- Use Blueprint/DataAssets: [Blueprint asset guide](07-blueprint-data-assets.md)

## Minimum release checklist

- `mod.json` is valid UTF-8 JSON and smaller than 256 KiB.
- `entry` exists, ends in `.lua`, and stays inside the mod directory.
- Only capabilities actually used are requested.
- Every registration call checks `bSuccess`.
- Test with no save, a new save, a loaded save, disabled, and re-enabled states.
- Do not treat `networkPolicy` as a completed handshake guarantee yet; multiplayer authors must still state host/client installation requirements explicitly.
