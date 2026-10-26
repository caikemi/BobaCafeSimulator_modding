# Add independent shop items: water buckets and liquid containers

[中文](../zh/13-new-items.md) | [Complete shop category and class reference](14-shop-reference.md) | [Shared JSON](../reference/shop-reference.json)

This guide requires an API v3 game build exposing `Context.Content:RegisterItem()`. It registers a new `ItemId` and preserves built-in items. The earlier `RegisterLiquidContainer` API patches existing liquid containers globally; use `RegisterItem` for a separate product.

Two introductory examples are provided; section 8 also includes complete 20L apple-juice and 100L auto-stop release packages:

| Example | New ItemId | Verified template ItemId | Actual template Actor class |
| --- | --- | --- | --- |
| [NewWaterBucketItem](../../Example_EN/NewWaterBucketItem/README.md) | `Mod_NewWaterBucket_20000` | `1022`, bottled water | `/Game/2Game/Blueprint/BP_1022水桶.BP_1022水桶_C` |
| [NewLiquidContainerItem](../../Example_EN/NewLiquidContainerItem/README.md) | `Mod_NewLiquidContainer_20000` | `3015`, liquid container | `/Game/2Game/Blueprint/商店货物/BP_设施3015_水容器_Child.BP_设施3015_水容器_Child_C` |

These IDs and paths come from the current project's ten UE-exported DataTables. Item `3015` uses the real shop child of `BP_液体容器`. `TemplateItemId` takes an item ID, not an asset name. Entries without an item Actor class, such as expansion or recipe entries, are not suitable spawnable-item templates.

### Required game build (2026-10-26 feature baseline)

`apiVersion: 3` or the presence of `RegisterItem` does not prove that an older game implements the complete purchase path. Use a game build that actually includes these host fixes:

- Copy the current runtime template and fill missing delivery class, price, unlock level, quantity, and box metadata from the actual shop row. Existing nonempty runtime values take precedence.
- Merge visible runtime item IDs from the current world into the existing goods/ingredients catalog, then reuse its search, cards, icons, cart, and purchase flow.
- Initialize a directly delivered Mod item with the purchased `ItemId`. Genuine delivery wrappers retain their own identity and store the contained item ID separately.
- Apply initial contents once on the server after the new Actor finishes BeginPlay. Save restoration, repeated initialization, and registry refreshes do not refill it.

These are game-host fixes, not a new Lua permission or API version. Authors use the updated game and public Content interface; do not access internal UObjects from Lua or distribute modified `BPFL_Normal`, `BP_AIManager`, or built-in parent Blueprints in a Mod PAK. Restart the editor after updating the SDK/native host, re-enter the game, and make a fresh purchase for validation.

## 1. Folder and manifest

```text
NewWaterBucketItem/
├── mod.json
└── v3.lua
```

```json
{
  "schemaVersion": 1,
  "id": "NewWaterBucketItem",
  "name": "Independent Large Water Bucket",
  "version": "1.0.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": ["content.register"]
}
```

A new independent item needs only `content.register`; leave `bPatchExisting=false`. Patching an existing ItemId additionally requires `content.patch`. Neither beginner example patches built-in items.

`side: both` loads definitions on the host and clients. The existing room check compares Mod IDs and load order and pre-mounts PAKs. The `exact-match` field does not implement a version/content-hash handshake, so it cannot guarantee identical versions or contents; install the same mod version on every peer.

## 2. Copy a template into an independent item

The host copies the complete runtime template, including Functions, use mode, and icon. It fills only missing class paths, delivery, price, level, quantity, and box metadata from the corresponding actual shop row; existing nonempty runtime values take precedence. Typed fields and explicit overrides are then applied. Keep `PurchasePrice=-1` and `UnlockLevel=-1` to inherit rather than duplicating original table constants in Lua.

```lua
local M = {}

function M.OnLoad(Context)
    local item = Context.Content:MakeItemDefinition()
    item.ContentId = "my_bucket"
    item.ItemId = "Mod_MyUniqueBucket"
    item.TemplateItemId = "1022"
    item.DisplayName = "My Water Bucket"
    item.Description = "An independent product; preserves the built-in bucket."
    item.CategoryTag = "购买.商品.材料"
    item.PurchasePrice = 8
    item.UnlockLevel = 0
    item.bShowInShop = true
    item.ShopSortPriority = -100

    local container = Context.Content:MakeContainerItemSettings()
    container.bOverrideMaxCapacity = true
    container.MaxCapacity = 20000
    container.bOverrideInitialCapacity = true
    container.InitialCapacity = 20000
    container.bOverrideOnlyAllowCupAddition = true
    container.bOnlyAllowCupAddition = false
    container.bOverrideCupLiquidType = true
    container.CupLiquidType = "Drink.PureWater"
    container.bOverrideColor = true
    container.Color = Context.Content:MakeColor(0.15, 0.45, 1, 1)
    item.Container = container

    local result = Context.Content:RegisterItem(item)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "Item registration returned no result")
    end
    return true
end

return M
```

Register only during `OnLoad`, while the context is Loading. Success means the definition has been staged; the host publishes it only after the whole mod loads successfully. Check every result and report its `Message` or throw on failure.

`ContentId` is unique within the mod and shares its namespace with drink, furniture, and other definitions. `ItemId` is the separate key used by purchases, spawning, inventory, and saves. Prefix it with your author or mod name to avoid collisions. Keep both IDs stable after release.

## 3. Every item-definition field

| Field | Default and meaning |
| --- | --- |
| `ContentId` | Required; unique within the mod. |
| `ItemId` | Required; the new global item key. Do not reuse built-in `1022` or `3015` for a new product. |
| `TemplateItemId` | Required; an existing item in the current runtime registry, such as `"1022"` or `"3015"`. |
| `DisplayName` | Required, nonempty name for the new product. |
| `Description` | Description of the new product; empty inherits the template description. |
| `CategoryTag` | Empty inherits the template category; a nonempty value must be an existing host tag. |
| `ActorClassPath` | Empty inherits the template class; otherwise use your own existing, cooked child Blueprint. |
| `BoxClassPath` | Empty usually inherits packaging/delivery; for direct-delivery templates it follows a custom Actor class, as explained below. |
| `PreviewImageRelativePath` | Empty inherits the icon; otherwise a relative image path inside the mod folder. |
| `PurchasePrice` | `-1` inherits the template price; an override must be finite and nonnegative. |
| `UnlockLevel` | `-1` inherits the template level; an override must be a nonnegative integer. |
| `bShowInShop` | `true`; whether the item appears in shop filtering. |
| `ShopSortPriority` | `0`; priority within native runtime queries and the additional-runtime-entry batch. Legacy shop static ordering/unlock groups still apply; see below. |
| `ExtraFunctions` | Empty map; overrides supported, known Function keys while preserving the rest of the template map. |
| `Container` | No overrides by default; construct with `MakeContainerItemSettings()` and assign it. |
| `bPatchExisting` | `false`; creates a new independent item. Patches require `content.patch` as well. |

`CategoryTag` selects an actual existing shop category. The bucket example uses `购买.商品.材料`; the liquid-container example uses `购买.商品.工具`. See the [29-category reference](14-shop-reference.md). Preserve the Chinese machine identifiers; do not invent a tag or rename items to control category or sort order.

Sorting scope: the native runtime query orders by `ShopSortPriority → UnlockLevel → ItemId`. The legacy goods/ingredients catalog keeps static-table order, appends additional runtime entries in that order, and then reorders locked products by unlock level. Consequently, `ShopSortPriority` does not guarantee an absolute position across built-in products or unlock groups in every category. It does not change the category or bypass unlocking; verify the final position in the target shop.

`ExtraFunctions` contains actual gameplay parameters, not arbitrary Blueprint variable names. Use only keys supported by the host and consumed by the selected Actor. The reference preserves original table Function keys as evidence; a key used by one Actor is not automatically suitable for every Actor. Prefer explicit fields for price, class paths, visibility, and other exposed settings.

`ModItem.*` is a host-reserved Function namespace and is rejected in `ExtraFunctions`. The host merges template Functions and ExtraFunctions first. Explicit nonnegative price/level overrides, nonempty class-path overrides, and public visibility settings take precedence over conflicting map entries. `PurchasePrice=-1`, `UnlockLevel=-1`, and empty class paths retain the merged result under the inheritance/delivery rules rather than unconditionally replacing it. Both the item Actor and delivery-box classes must be valid `AGB_TakeUpActor` subclasses. A non-Actor data entry or incompatible class cannot serve as a spawnable product.

Templates `1022` and `3015` have `BoxClassPath == ClassPath` and deliver the object itself. When you supply a custom `ActorClassPath` and leave `BoxClassPath` empty for such a template, the delivery class automatically follows the new Actor class so the purchased object is your child. Other templates using a separate packaging class retain their original box. Set `item.BoxClassPath` explicitly when a different delivery class is required.

Purchase initialization uses the independent purchased `ItemId` for a directly delivered instance instead of the bucket's default `1022` or container's default `3045`. A genuine packaging actor retains its own ID and stores the purchased ID as contents; do not replace every wrapper's identity with its contents ID.

## 4. Container settings

Each setting has its own override flag. A false flag preserves the template or Blueprint behavior, regardless of the associated value.

| Flag | Value and default | Behavior |
| --- | --- | --- |
| `bOverrideMaxCapacity=false` | `MaxCapacity=10000` | Maximum capacity in the game's existing units; an override must be finite and positive. |
| `bOverrideInitialCapacity=false` | `InitialCapacity=0` | Initial liquid quantity for a newly created item, set once on the server; does not refill saved items. |
| `bOverrideOnlyAllowCupAddition=false` | `bOnlyAllowCupAddition=false` | Bucket only: controls the bucket's cup-only addition restriction. Liquid containers have no such property; do not enable it for them. |
| `bOverrideCupLiquidType=false` | `CupLiquidType="Drink.PureWater"` | For buckets, overrides the static liquid type added to cups. For liquid containers, sets initial `WaterType` only on first server creation; saved liquid type is preserved on load. |
| `bOverrideColor=false` | `Color=white` | The host selects the existing dynamic-material vector parameter by container type: bucket `Glass Color`, or `Param` on liquid-container `StaticMesh` material slot `0`. |

Build colors with `Context.Content:MakeColor(R, G, B, A)` using finite components. This changes the runtime dynamic material instance, preserves material assets, and needs no material PAK. It is separate from the drink-style API that colors the liquid itself.

The liquid-container example sets maximum capacity `20000`, initial quantity `0`, and keeps `bOverrideOnlyAllowCupAddition=false`. The bucket starts with `20000` out of a maximum `20000`. Do not configure initial quantity above the maximum.

Initial contents apply once after the server's new instance completes BeginPlay. A bucket's `CupLiquidType` is static per-ItemId output configuration and is reapplied on load; a liquid container's current `WaterType` is saved state. On re-entry, static settings such as maximum capacity and color are reapplied. Saved current quantity and liquid type must be restored without refilling from `InitialCapacity`. These semantics are connected in the implementation; PIE, real save/load, and multiplayer acceptance checks below remain required.

New mod containers additionally save native double-precision quantity and actual `WaterType`, avoiding integer truncation in the old Blueprint save path. Restoration disables first-use initialization and writes the precise state after legacy Blueprint restoration. Built-in items and older saves without this extension retain their existing path. The host waits for base data and all enabled mod registrations before loading a save; a failed registration aborts entry and returns to the main menu instead of continuing with missing item classes.

## 5. Author a child Blueprint

Both examples reuse existing game classes and need only Lua and JSON. Create a separate child class when changing the mesh, components, or Blueprint behavior.

Registering a separate ItemId while reusing an existing class already creates a real independent product; a child Blueprint is optional. The manual's SDK supplies these uncooked source templates, which were actually created and verified after reload, plus `SDK/Tools/CreateModContainerBlueprints.py`:

| SDK source asset | Actual parent Blueprint | Default ItemID |
| --- | --- | --- |
| `SDK/Content/Mods/MyWaterBucket/BP_MyWaterBucket.uasset` | `BP_1022水桶` | `Mod_NewWaterBucket_20000` |
| `SDK/Content/Mods/MyLiquidContainer/BP_MyLiquidContainer.uasset` | `BP_液体容器` | `Mod_NewLiquidContainer_20000` |

Run the tool inside the official SDK/current project containing the game parents and native modules. It creates only missing example assets; existing targets are checked for the expected parent and left unchanged, preserving author edits. Actual creation checks confirmed that original parent files kept the same SHA256. The tool does not replace missing parent assets or native modules in a blank project.

```powershell
& '<UE5.6.1-engine>/Engine/Binaries/Win64/UnrealEditor-Cmd.exe' '<SDK-project.uproject>' -run=pythonscript '-script=<SDK-directory>/Tools/CreateModContainerBlueprints.py' -EnablePlugins=PythonScriptPlugin,EditorScriptingUtilities -unattended -NullRHI
```

These are uncooked authoring assets, not files to drop into the game as a PAK. The manual steps below explain authoring a variant yourself. The supplied tool uses the requested bucket and liquid-container base Blueprints; a manually authored variant may instead use the actual shop child when appropriate.

1. Use an authoring project or Mod SDK containing the compatible parent assets and native modules, matching game UE **5.6.1**. A blank project missing the parent assets or `BaseInstall` classes cannot create a valid child; resolve those authoring dependencies first.
2. Create a Child Blueprint from `BP_1022水桶`, or preferably the actual shop template `BP_设施3015_水容器_Child` for a liquid container. Preserve built-in assets and paths.
3. Put the new assets in your own directory, for example `/Game/Mods/MyWaterBucket/` or `/Game/Mods/MyLiquidContainer/`.
4. When overriding Construction, BeginPlay, item initialization, ItemID updates, or save events, preserve the required **Call to Parent Function** and execution order. Otherwise initialization, networking, or save behavior can be lost.
5. Compile and save your own Blueprint. Verify its parent, components, and dependencies in the authoring environment before cooking.

The following paths correspond to source templates supplied in the SDK. Cook, package, and install them using the UE5.6.1 SDK containing their parents before enabling a path. Both Lua-only examples leave these lines commented by default:

```lua
-- Enable after cooking and packaging the supplied SDK source template.
-- item.ActorClassPath = "/Game/Mods/MyWaterBucket/BP_MyWaterBucket.BP_MyWaterBucket_C"
-- item.ActorClassPath = "/Game/Mods/MyLiquidContainer/BP_MyLiquidContainer.BP_MyLiquidContainer_C"
```

## 6. UE5.6.1 cooking, PAKs, and ShaderArchives

1. Keep custom children, meshes, materials, and textures in your own directory and fix Redirectors. Do not distribute modified built-in Blueprint packages.
2. Create a `PrimaryAssetLabel` Data Asset, not a Blueprint subclass. Assign a unique Chunk ID, `Always Cook`, `Label Assets in My Directory`, and `Is Runtime Label`. Use Asset Audit to verify the intended chunk.
3. Match the game's Windows target and supported shader formats; the existing packaging guide uses D3D12 SM5/SM6 and D3D11 SM5.
4. Enable `Use Pak File`, `Generate Chunks`, and `Share Material Shader Code`; disable `Use Io Store`, `Use Zen Store`, and `Shared Material Native Libraries`. Limit cooking to your intended mod directory rather than packaging all game content into the mod.
5. Cook/package Windows content with UE5.6.1. Inspect the output using `UnrealPak.exe <your-pak> -List`. The published mod chunk should contain your `/Game/Mods/...` packages and must not override `BP_1022水桶`, `BP_液体容器`, or the built-in shop child. Parent assets are authoring/cook dependencies, not replacements to redistribute in the mod chunk.
6. Place the actual PAK in the mod root. When including new materials, follow the existing model-PAK guide and also place the generated ShaderArchives in the mod root using their original filenames. Do not create placeholder `.ushaderbytecode` files or rename archives.
7. Keep `mod.json` and `v3.lua` loose. The host mounts resources before Lua executes; the sandbox does not require or permit arbitrary manual Mount/LoadObject. Install the same resource version on every multiplayer peer.

```text
MyCustomItemMod/
├── mod.json
├── v3.lua
├── MyCustomItemMod.pak
└── ShaderArchive-<actual-authoring-project-output>-<format>.ushaderbytecode
```

Consult `Model_PAK_Packaging_EN.md` in the modding manual for the existing detailed asset-packaging settings. Do not copy another project's cooked files or invent ShaderArchive filenames.

## 7. Saves, disabling, and acceptance checks

Saves need the same independent ItemId and a resolvable Actor class. Disabling a mod or removing its PAK can make a custom child unavailable. Re-enable a compatible mod/asset pack with the same IDs before loading the save. Do not overwrite your only save while required mod content is missing.

| Scenario | Pass criteria |
| --- | --- |
| Registration and shop | New ID appears under the intended category; built-in `1022`/`3015` are preserved; price, name, description, unlock, and ordering are correct. |
| Purchase, delivery, placement | Direct deliveries retain the purchased independent ItemId and actual capacity/type; separate wrappers preserve their own ID and contained item ID; built-in items retain their behavior. |
| New-item initialization | Server initializes quantity and initial type only once; clients show the same state. |
| Save, exit, re-entry | Saved current quantity and type return without an InitialCapacity refill; static maximum capacity and color still apply. |
| Child Blueprint | Custom class spawning, parent initialization, components, material instances, and save events work. |
| Existing clients and late join | Host, connected clients, and late joiners agree on ItemId, capacity, type, quantity, and color. |
| Failure and unload | Failed registration does not partially publish content; unloading reverses registry changes; re-enabling resolves saved custom IDs. |

Documentation and table exports are static evidence. Full compilation, automation tests, PIE, real saves, and multiplayer execution are separate validation stages and should be reported separately.

## 8. Complete release examples and validation scope

| Complete example | Template / independent ItemId | Actual state on a new purchase | Current template price / level |
| --- | --- | --- | --- |
| [AppleJuiceBucket20L](../../Example_EN/AppleJuiceBucket20L/README.md) | `1022` / `Mod_AppleJuiceBucket_20000` | Current/max `20000/20000ml`, `Drink.AppleJuice`, cups only, dark-green `Glass Color` | `2.5` / `33` |
| [AutoStopLiquidContainer100L](../../Example_EN/AutoStopLiquidContainer100L/README.md) | `3045` / `Mod_AutoStopLiquidContainer_100000` | Current/max `0/100000ml`, original template auto-stop behavior, dark-green `Param` | `100` / `60` |

Both use `购买.商品.材料`; `PurchasePrice=-1` and `UnlockLevel=-1` inherit the current template. Products below the required player level should appear as locked cards rather than disappear from search. Each complete folder contains `mod.json`, `v3.lua`, `icon.png`, `preview.png`, `release_data.json`, `releaseREADME.md`, both Workshop descriptions, and usage instructions. `release_data.json` is a publishing snapshot; `v3.lua` and the current host template define actual behavior. The packages supply Chinese in-game names; the Chinese and English example directories retain the same item IDs, Lua definitions, and images.

Reusing an existing class is enough to create a separate product; no new Blueprint or asset PAK is required. Do not change the new `ItemId` back to `1022`/`3045` or hard-code a delivery class merely to hide an older host's purchase-identity defect. Update the host and make a new purchase. Incorrect products already generated or saved under a built-in ID have no reliable Mod provenance and keep their previous state; do not bulk-convert built-in water buckets into apple-juice buckets.

As of 2026-10-26, UE5.6.1 compilation/linking and isolated GameWorld regressions have passed for the actual shop Blueprint enumeration, real `Ev服务器创建货物` delivery event, BeginPlay initial contents, and in-memory SaveGame round trip. The delivery test does not repair IDs manually to bypass purchasing. It checks the capacities above, apple-juice type, cup restriction, color, wrapper identity, and restoration of `1234.5ml` without refilling.

These automation results do not replace manual PIE search/cart/dispensing, real disk-save re-entry, connected-client, or late-join checks. Record those results before publishing. Successful registration or spawning the same mesh is not full acceptance.
