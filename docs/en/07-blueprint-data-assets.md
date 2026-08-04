# Blueprint / DataAsset mods

[Back to the English home page](../../README_EN.md) | [中文](../zh/07-blueprint-data-assets.md)

BaseInstall API v3 provides stable Blueprint entry and content DataAsset types so asset authors do not inherit internal game PlayerControllers, GameState, or Actors. Ordinary Lua mods do not need these types. An UE5.6 project needs a compatible BaseInstallAPI authoring plugin/SDK to create them.

## BaseInstallBlueprintMod

Create a Blueprint Class whose parent is `BaseInstallBlueprintMod`. It can implement:

| Event | Called |
| --- | --- |
| `OnLoad(ModContext)` | Before content commit; Context is Loading |
| `OnWorldReady(Event)` | When the host emits `game.world_ready` |
| `OnModEvent(Event)` | When another subscribed event arrives |
| `OnUnload()` | On disable/unload |

Use `GetContext` to access the same Events, Content, Economy, Storage, Inventory, Tasks, and UI services as Lua. Permissions and state restrictions are identical.

Recommended flow:

```text
OnLoad
├─ GetContext
├─ Events → Subscribe("game.morning_started")
├─ Content → RegisterContentAsset(...) (optional)
└─ Do not mutate inventory/tasks/UI/bill payment here

OnModEvent
├─ inspect EventName
└─ call permitted runtime services while Active
```

`OnWorldReady` is a lifecycle convenience. Subscribe to `game.world_ready` as well if it should also enter ordinary `OnModEvent`.

## Content-asset base

`BaseInstallModContentAsset` is the public PrimaryDataAsset base:

| Field | Meaning |
| --- | --- |
| `ContentId` | Local ID within the mod |
| `DisplayName` | Display name |
| `Description` | Multiline description |
| `Icon` | Soft icon reference |
| `PublicTags` | Public metadata tags |
| `SchemaVersion` | Currently defaults to 1 |

At runtime the ID is qualified as `ModId:ContentId`.

## BaseInstallModDrinkAsset

The primary field is the v3 `Definition` (`FBaseInstallModDrinkDefinition`). At commit:

- Empty `Definition.ContentId` falls back to the base asset `ContentId`.
- Empty `Definition.DisplayName` falls back to the base `DisplayName`.
- Every other drink field comes from `Definition`.

The asset also has early/editor-convenience fields named `Prices`, `OutputLiquidId`, `RequiredIngredientIds`, `RequiredLiquids`, `SweetnessOptions`, and `TemperatureOptions`. The current v3 host adapter does not automatically merge those into `Definition`. Fill `Definition` completely for new assets.

## BaseInstallModFurnitureAsset

The v3 `Definition` is also primary. These asset fields may fill empty definition values:

- `ContentId`, `DisplayName`, and `Description`
- Empty `ItemId` uses `ContentId`
- `ActorClass` → `ActorClassPath`
- `PreviewMesh` → `MeshObjectPath`
- `PurchasePrice` when the definition price is not positive

`PlacementType` is currently public metadata; the BaseInstall adapter does not consume it separately. Package, Actor, category, and placement behavior still come from `Definition` and existing host furniture classes.

## BaseInstallModMusicAsset

Public fields are `Sound`, `Volume`, `Weight`, `bLoop`, and `Situations`. The asset can enter the public content table, but is not connected to the game's internal music playback registry yet.

Therefore:

- It may be authored for future compatibility or a custom host extension.
- It is not a working v3 music-playback API today.
- The privileged MP3/internal calls from legacy CustomBGM have no v3 equivalent.

## BaseInstallModDefinitionAsset

This asset describes one Blueprint/data content group:

| Field | Meaning |
| --- | --- |
| `ModId` | Must match the package manifest ID |
| `Version` | Must match the package manifest version |
| `APIVersion` | Use 3 for new content |
| `ExecutionSide` | Client / Server / Both |
| `NetworkPolicy` | LocalOnly / ServerRequired / ExactMatch |
| `GrantedPermissions` | Only capabilities actually granted by the host |
| `EntryClass` | `BaseInstallBlueprintMod` subclass |
| `ContentAssets` | Public assets staged in the same transaction |

Activation order:

```text
Host loads and validates package manifest
→ mounts PAK
→ loads Definition
→ stages ContentAssets
→ creates EntryClass and calls OnLoad
→ commits Context
→ Active
```

Any failure rolls the operation back.

## Current loading boundary

`Activate Mod Definition` and `Deactivate Mod` are host-side Blueprint nodes. The current Lua directory loader primarily uses `mod.json.entry`; do not assume an arbitrary `BaseInstallModDefinitionAsset` in an external PAK is auto-discovered. To support pure DataAsset packages, the game's Mods menu/loader Blueprint must explicitly load the Definition after manifest validation and PAK mount, then call `Activate Mod Definition`.

`mod.json` remains authoritative for a distributed package. Do not publish only a Definition without a manifest unless it is developer-built content activated directly by the host.

## Packaging recommendations

- Use the same UE5.6 and authoring SDK/plugin version as the game.
- Do not reference private game C++ structs or Blueprint internal variables.
- Use Soft Object/Class References and place resources under a unique `/Game/<Pack>/` path.
- Put Definition, EntryClass, and ContentAssets in the same Chunk PAK.
- Keep manifest permissions and Definition GrantedPermissions aligned; the host should treat the manifest as authoritative.
- Test rollback after disable/re-enable and with multiple patched assets.
