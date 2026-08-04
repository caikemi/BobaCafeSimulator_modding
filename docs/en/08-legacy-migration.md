# Migrating API v1 / v2 mods to v3

[Back to the English home page](../../README_EN.md) | [中文](../zh/08-legacy-migration.md)

A legacy mod without `mod.json` still uses the privileged API v1 compatibility path, so existing player-made mods do not automatically stop working because v3 exists. Compatibility is not a recommendation: legacy mods depend directly on internal objects and load order, with no manifest permissions, sandbox, transaction rollback, or stable-interface guarantee.

## Version comparison

| Capability | API v1 (no manifest) | API v2 | API v3 |
| --- | --- | --- | --- |
| Entry | `main.lua` / `OnInit` | `mod.json` + `OnLoad` | `mod.json` + `OnLoad` |
| UE/internal objects | Direct privileged access | unavailable | unavailable |
| Permissions | none | Events/Economy/Storage | complete v3 table |
| Content transaction | none | public asset staging | drink/style/rule/furniture adapters and rollback |
| Player services | internal calls | none | Inventory/Tasks/UI |
| Failure behavior | may leave partial state | Context rollback | Context + internal registry rollback |
| Recommended for new work | no | compatibility only | yes |

API v2 manifests and scripts remain supported. A mod that only uses Events, Economy, and Storage may stay on v2; new features or a new release should use API 3.

## Manifest migration

Add this at the legacy mod root:

```json
{
  "schemaVersion": 1,
  "id": "com.author.old_mod",
  "name": "Old Mod",
  "version": "2.0.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": ["content.register"],
  "dependencies": []
}
```

You may keep legacy `main.lua` for older game builds while the current manifest explicitly selects `v3.lua`. Do not simply rename old code: the manifest environment has no internal globals.

## Lifecycle migration

Legacy:

```lua
local M = { id = "OldMod", name = "Old Mod" }

function M.OnInit()
    -- Direct MOD.Playercontroller / UE access
end

return M
```

v3:

```lua
local M = {}

function M.OnLoad(Context)
    -- Subscribe and stage content
    return true
end

function M.OnModEvent(Context, Event)
    -- Active-stage runtime behavior
end

return M
```

Move name, ID, version, and permissions into `mod.json`. The absolute `dir` is no longer a general file-access mechanism.

## Common replacements

| Legacy approach | v3 approach |
| --- | --- |
| Find DrinkRegistry and `RegisterDrinkData` | `Context.Content:RegisterDrink` |
| Direct `RegisterDrinkStyle` overwrite | Public style + `bPatchExisting=true` + `content.patch` |
| Internal `RegisterCupAddItemRule` | Public `RegisterCupAddItemRule` |
| `GameState:EvAddDrink` | remove; the host syncs owned recipes |
| Build `FItemDataRuntime` / BaseInstall tables | `RegisterFurniture` |
| Read MultiGameState money/bills | `Context.Economy:GetSnapshot` |
| Direct bill deduction | `Context.Economy:TryPayBill` |
| Direct inventory component changes | `Context.Inventory` |
| Direct task-system changes | `Context.Tasks:AddProgress` |
| Create arbitrary Widgets | no equivalent yet; only `Context.UI:ShowNotification` |
| Read/write custom files | `Context.Storage` |
| Timer-poll internal readiness | subscribe to `game.world_ready` or a precise business event |
| Manually mount PAK | remove; host mounts before entry |
| Manually remove/restore registries | remove; transaction rollback handles it |

## Drink migration mapping

Map old `FDrinkData` fields to `FBaseInstallModDrinkDefinition`:

- `ID` → `DrinkId`
- `DisplayName` → `DisplayName`
- `Season` → `Seasons`
- `ImagePath = dir .. file` → `ImageRelativePath = file`
- `Value["S/M/L"]` → `SmallPrice/MediumPrice/LargePrice`
- `DrinkWaterFName` → `OutputLiquidId`
- `NeedItemID` → `RequiredItemIds`
- `PerfectNeed` → `PerfectLiquids`
- `PerfectNeedItem` → `PerfectItems`
- `ShowTutorialsItemID` → `TutorialItemIds`
- `MakeNeedTutorialText` → `TutorialText`
- `ShowGetWayText` → `AcquisitionText`
- `UnlockedItemID` → `UnlockedItemGroups`

See the migrated NewDrinkPumpkin and NewDrinkPumpkinOrange examples.

## Furniture migration

Keep the original PAK, ShaderArchives, images, and `/Game/...Asset.Asset` paths. Remove manual mount, LoadObject, and internal ItemData construction; use `MakeFurnitureDefinition` + `RegisterFurniture`.

See [AnimalDecorationAssetPack](../../Example_EN/AnimalDecorationAssetPack/).

## Legacy capabilities without a v3 replacement yet

### CustomBGM

`BaseInstallModMusicAsset` is not connected to the internal playback registry, and v3 does not expose arbitrary MP3/file/internal Audio APIs. Legacy CustomBGM may continue as API v1 compatibility content, but must not be given a fake v3 manifest.

### Runtime localization

The manifest has one `name`, and there is no public culture query, string-table registration, or runtime localization service yet. Legacy LocalizedPumpkinDrink may continue through v1. v3 content may provide one display text, but cannot safely switch languages within the same Lua mod yet.

## Migration acceptance checklist

- No `UE`, `GAA`, `MOD.Playercontroller`, `io`, `os`, or `require` remains in v3.lua.
- The manifest requests only permissions actually called.
- Every registration result checks `bSuccess`.
- Disable removes new content and restores patched content.
- Repeated enable does not duplicate registration or rewards.
- Test new/load-save and standalone/multiplayer authority paths appropriate to the mod.
