# Lua lifecycle and Context

[Back to the English home page](../../README_EN.md) | [中文](../zh/03-lua-and-context.md)

An API v3 Lua entry must return a table. Keep state local and avoid creating globals.

## Lifecycle

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
    -- Optional light cleanup; the host rolls content and subscriptions back.
end

return M
```

### OnLoad(Context)

The Context starts in `Loading`. You may:

- Subscribe to events.
- Stage content definitions through `Context.Content`.
- Read or change mod storage values that have not been flushed.
- Log and inspect manifest information.

Do not perform operations that require Active state here: paying bills, adding/removing items, changing tasks, showing UI, or explicitly calling `Storage:Flush()`. They return `InvalidState`.

After `OnLoad` returns `true`, the host validates and atomically commits subscriptions, content, and storage. Returning `false`, raising a Lua error, or failing commit rolls the complete Context back.

The API v2 compatibility loader also accepts `OnInit(dir, Context)`, but new code must use `OnLoad(Context)`.

### OnModEvent(Context, Event)

Only subscribed events are delivered. The Context is `Active`, so runtime mutation services may be called here. See the [event guide](05-events.md).

### OnUnload(Context)

Called when the mod is disabled/unloaded or its world exits. The host then removes subscriptions, rolls back content, shuts down the Context, and persists dirty storage during a normal unload. Do not stage new content here and do not assume world Actors are still valid.

## Context methods and services

| Member | Purpose |
| --- | --- |
| `Context:GetInfo()` | Complete `FBaseInstallModInfo` |
| `Context:GetModId()` | Manifest ID |
| `Context:GetModVersion()` | Manifest version |
| `Context:GetAPIVersion()` | API version |
| `Context:GetState()` | `Loading`, `Active`, `Failed`, or `Unloading` |
| `Context:MakeQualifiedId(LocalId)` | Produces `ModId:LocalId` |
| `Context:HasPermission(Name)` | Whether the capability was granted |
| `Context:Log(Message)` | Writes a log line associated with the mod |
| `Context.Events` | Event subscriptions |
| `Context.Content` | Content definitions and registration |
| `Context.Economy` | Economy snapshot and bill payment |
| `Context.Storage` | Private mod string storage |
| `Context.Inventory` | Player inventory |
| `Context.Tasks` | Player task progress |
| `Context.UI` | Ordinary player notifications |

`SourceDirectory` is host-owned absolute-directory metadata. It does not grant arbitrary file access; manifest Lua has no `io`.

## Results

Most operations return `FBaseInstallModResult`:

| Field | Meaning |
| --- | --- |
| `bSuccess` | Whether the call succeeded |
| `Code` | `None`, `InvalidArgument`, `InvalidId`, `InvalidState`, `AlreadyExists`, `NotFound`, `PermissionDenied`, or `InternalError` |
| `Message` | Failure explanation |
| `Value` | Optional string result |

Safe helper:

```lua
local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "ModAPI returned no result")
    end
end
```

Count reads return `FBaseInstallModIntegerResponse`; inspect `bSuccess`, `Error`, and `Value`. Economy reads return `FBaseInstallModEconomySnapshot`; inspect `bSuccess`, `Error`, `Balance`, and `Bills`.

## Restricted environment

Manifest mods receive safe Lua basics plus read-only `math`, `string`, `table`, `utf8`, `print`, and `Context`. These globals are unavailable:

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

Do not copy API v1 code directly into `v3.lua`. Use public services for supported work; wait for a new public API for unsupported work instead of bypassing the sandbox.

## Content transactions

Each `ContentId` is local to the mod and is qualified as `ModId:ContentId` at commit. A local ID:

- Is 1–128 characters.
- Allows letters, numbers, `.`, `_`, `-`, and `/`.
- Cannot start/end with `/`, contain `..`, or contain `:`.

Every `ContentId` in one transaction must be unique. A collision with host content fails unless the definition has `bPatchExisting=true` and the manifest has both `content.register` and `content.patch`.

The host manages commit, rollback, and layered-patch replay. Do not manually remove registry entries in `OnUnload`.

## Encoding and maintainability

- Use UTF-8.
- End the entry with `return M`.
- Declare constants and state as `local`.
- Do not depend on the absolute mod-folder path.
- Check every external-call result and log actionable failures.
- Avoid frequent writes from Tick-like events; consume discrete business events.
