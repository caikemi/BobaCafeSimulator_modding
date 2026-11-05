# Game-version declaration for mods with PAKs

[English home](../../README_EN.md) | [中文](../zh/15-pak-game-version.md) | [PAK packaging guide](../../Model_PAK_Packaging_EN.md)

This rule applies to game builds containing the 2026-11-06 loading-check update. The current host project's `ProjectVersion` is `2.17`; the same displayed version does not prove an older build contains this check.

## Required declaration

If a `.pak` exists anywhere inside the mod folder, the first effective statement in the actual Lua entry must declare the game version against which the author validated the mod:

```lua
local game_version = "2.17"

local M = {}
function M.OnLoad(Context)
    return true
end
return M
```

- With `mod.json`, put it in the file selected by `entry`, such as `v3.lua`. An unused `main.lua` does not satisfy the requirement.
- Without `mod.json`, the legacy loader selects the first existing entry in this order: `LuaMain.lua`, `main.lua`, `init.lua`.
- Blank lines, a UTF-8 BOM, ordinary comments and Lua long comments may precede the declaration. The declaration must be the first effective statement on its own line. Single/double quotes, optional `local`, a trailing semicolon and an ordinary trailing comment are supported.
- Use a string literal. Computed values, assignments inside functions, another field name or text inside comments/strings do not count. Entry text is limited to 1 MiB.
- The complete string must exactly match the game's current `ProjectVersion`. Wildcards and ranges are unsupported; `2.17`, `2.17.0` and `v2.17` are different declarations.
- The mod's own `version` and its `apiVersion` serve different purposes and do not replace `game_version`.
- Pure Lua mods without bundled PAKs do not need this declaration. PNG, JSON and ShaderArchive files alone do not count as PAKs.

## Host behavior

The host recursively scans the mod's files on disk with a case-insensitive extension check. A `.pak` or `.PAK` at the root or in a subfolder triggers the requirement. Reading the declaration never executes Lua, loads a DLL or asset, or mounts a PAK.

On the first main-menu entry, the existing Mod-error consumption flow checks the actual enabled list and reports every failed mod together, including its name, stable ID, recognizable Workshop ID and reason. Reading consumes the message; the initial menu check does not repeat in the same GameInstance. Starting a game checks again, and the host's actual PAK mounting entry also rechecks.

A missing declaration or version mismatch blocks that attempt to enter a game. Enabled states remain unchanged. The host does not unsubscribe, delete files, rewrite the author's declaration or silently continue. Players can disable the named mods or wait for updated releases.

## Author updates and validation

Do not merely change the number to suppress the message. First validate resource dependencies, Blueprint parent classes and property layouts against the target game version, platform and compatible UE version. Re-cook/repackage where required, confirm loading and content registration, then update the declaration and publish.

A matching declaration is the author's compatibility claim, not proof of asset safety. Existing checks for known-bad PAK size/content fingerprints, known-bad DLL build identifiers and blocked PAK filename prefixes still apply. Renaming files, changing the mod version or adding this declaration cannot bypass known-bad content protection.

The host interface checks before mounting. A legacy DLL that independently downloads/mounts external content and bypasses that interface cannot be fully controlled by directory scanning. This rule is not a native-code sandbox and does not turn an Unreal serialization crash into a recoverable Lua exception.
