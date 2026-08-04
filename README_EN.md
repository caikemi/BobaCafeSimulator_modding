# Boba Cafe Simulator Modding Documentation

[中文](README.md) | [English](README_EN.md)

This is the official BaseInstall API v3 documentation for mod authors. New mods should use `mod.json`, `apiVersion: 3`, and a restricted Lua entry point. Do not directly access `UE`, `GAA`, PlayerController, GameState, or internal game registries.

The v3 contract is built around these rules:

- Only stable `Context` services are exposed, and every capability is requested explicitly in `mod.json`.
- Drinks, styles, cup rules, and furniture are staged in `OnLoad` and committed as one transaction.
- A failed load, disable, or unload rolls the mod's content back; layered patches from remaining mods are replayed.
- With no subscribing mod, the original game logic is unchanged.
- Mods without `mod.json` still use the API v1 compatibility path, but do not receive v3 sandboxing, permissions, or rollback guarantees.

## Start here

1. [Five-minute quick start](docs/en/01-getting-started.md)
2. [The mod.json manifest and permissions](docs/en/02-manifest.md)
3. [Lua lifecycle and Context](docs/en/03-lua-and-context.md)
4. [Drink, style, rule, and furniture API](docs/en/04-content-api.md)
5. [Events, payloads, and host integration points](docs/en/05-events.md)
6. [Economy, Storage, Inventory, Tasks, and UI](docs/en/06-runtime-services.md)
7. [Blueprint/DataAsset mods](docs/en/07-blueprint-data-assets.md)
8. [Migrating API v1/v2 mods](docs/en/08-legacy-migration.md)
9. [Publishing to the Steam Workshop](docs/en/09-workshop.md)
10. [Troubleshooting and release checklist](docs/en/10-troubleshooting.md)
11. [Drink, liquid, ingredient, and icon ID reference](docs/en/11-id-reference.md)
12. [UE5.6 model-asset PAK packaging guide](Model_PAK_Packaging_EN.md)

## Ready-to-use examples

Every official v3 example includes `mod.json`, whose `entry` selects `v3.lua`.

| Example | What it demonstrates |
| --- | --- |
| [NewDrinkPumpkin](Example_EN/NewDrinkPumpkin/) | A new drink and a perfect-liquid ratio |
| [NewDrinkPumpkinOrange](Example_EN/NewDrinkPumpkinOrange/) | Dependencies, a drink, a cup-add-item rule, and a style |
| [RedLemonWater](Example_EN/RedLemonWater/) | A reversible existing-style patch with `content.patch` |
| [AnimalDecorationAssetPack](Example_EN/AnimalDecorationAssetPack/) | A PAK, ShaderArchives, and four furniture definitions |
| [AutoPayDailyBill](Example_EN/AutoPayDailyBill/) | Events, economy services, and namespaced storage |

See [Example_EN](Example_EN/README.md) for the complete index.

## Minimal folder

```text
MyMod/
├── mod.json
├── v3.lua
├── preview.png          # recommended, optional
└── MyContent.pak       # asset mods only
```

`mod.json`:

```json
{
  "schemaVersion": 1,
  "id": "com.author.my_mod",
  "name": "My Mod",
  "version": "1.0.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": [],
  "dependencies": []
}
```

`v3.lua`:

```lua
local M = {}

function M.OnLoad(Context)
    Context:Log("Loaded " .. Context:GetModId())
    return true
end

return M
```

Place the complete `MyMod` folder under:

```text
GameRoot/BobaCafeSimulator/Mods/
```

Enable it in the in-game Mods menu and re-enter the game to verify it.

## Current capabilities and boundaries

Public now: events; drinks; drink styles; cup-add-item rules; furniture; bill read/payment; namespaced mod storage; inventory query/add/remove; task progress; ordinary player notifications; and Blueprint/DataAsset entry types.

Not public yet: arbitrary Widget creation, arbitrary file/network access, internal UObjects, general liquid-plus-liquid or complex mix rules, a runtime localization service, the music playback registry, the complete multiplayer mod-list handshake, or a standalone Dedicated Server Lua-directory loader. “Not supported” means a new mod must not bypass the API by using old internal interfaces.

## Version note

These documents follow the current BaseInstall API v3 implementation and the verified mods in the game repository. If an old post conflicts with this repository, follow the v3 documentation, `mod.json`, and `v3.lua` here.
