# Content API: drinks, styles, cup rules, and furniture

[Back to the English home page](../../README_EN.md) | [中文](../zh/04-content-api.md)

All content registration requires `content.register` and may only run during the Loading-stage `OnLoad`. Definitions are staged first and enter the internal registries only after the complete mod succeeds.

## Common pattern

```lua
local M = {}

local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "ModAPI returned no result")
    end
end

function M.OnLoad(Context)
    -- Make...Definition → fill fields → Register...
    return true
end

return M
```

Every `ContentId` in a mod must be unique. Leave `bPatchExisting` false for new content. Set it true only when changing existing content and request `content.patch` as well.

## Registering a drink

```lua
local drink = Context.Content:MakeDrinkDefinition()
drink.ContentId = "pumpkin_juice_recipe"
drink.DrinkId = 5201
drink.DisplayName = "Pumpkin Juice"
drink.DrinkType = "FruitTea"
drink.ImageRelativePath = "5201.png"
drink.SmallPrice = 8
drink.MediumPrice = 10
drink.LargePrice = 12
drink.OutputLiquidId = "Drink.PumpkinJuice"

local perfect = Context.Content:MakeLiquidRatioDefinition()
perfect.LiquidId = "Drink.PumpkinJuice"
perfect.MinRatio = 0.83
perfect.MaxRatio = 1.0
drink.PerfectLiquids:Add(perfect)

drink.TutorialItemIds:Add(1106)
drink.TutorialItemIds:Add(1033)
drink.TutorialText = "Juice the pumpkin"
drink.AcquisitionText = "Obtained from a mod"
drink.UnlockedItemGroups:Add("Pumpkin")

require_success(Context.Content:RegisterDrink(drink))
```

### FBaseInstallModDrinkDefinition

| Field | Type/default | Meaning |
| --- | --- | --- |
| `ContentId` | FName | Required unique local content ID |
| `DrinkId` | int / 0 | Game recipe ID; required and non-conflicting for a new recipe |
| `DisplayName` | text | In-game display name |
| `DrinkType` | `MilkTea` | `MilkTea`, `FruitTea`, `Coffee`, `SweetSoup`, or `IceCream` |
| `Seasons` | all four | `Spring`, `Summer`, `Autumn`, `Winter` |
| `ImageRelativePath` | string | Image path relative to the mod root |
| `SmallPrice` | 0 | Non-negative S price |
| `MediumPrice` | 0 | Non-negative M price |
| `LargePrice` | 0 | Non-negative L price |
| `OutputLiquidId` | FName | Finished liquid, such as `Drink.PumpkinJuice` |
| `RequiredItemIds` | int array | Required item IDs; repeated IDs mean multiple units |
| `SweetnessOptions` | all | `Sweet10`, `Sweet7`, `Sweet5`, `Sweet3`, `Sweet0` |
| `TemperatureOptions` | all | `Hot`, `Normal`, `SmallIce`, `Ice` |
| `PerfectLiquids` | ratio array | Liquid IDs and perfect ratio ranges from 0 to 1 |
| `PerfectItems` | map | Item-ID string to required count, for example `"1103" → 4` |
| `TutorialItemIds` | int array | Ordered recipe tutorial icons |
| `TutorialText` | text | Preparation instructions |
| `AcquisitionText` | text | How the recipe is obtained |
| `UnlockedItemGroups` | FName array | Item groups unlocked with the recipe |
| `bPatchExisting` | false | Whether to patch an existing DrinkId |

To customize seasons, sweetness, or temperature, assign an empty table before adding values:

```lua
drink.Seasons = {}
drink.Seasons:Add("Summer")
drink.TemperatureOptions = {}
drink.TemperatureOptions:Add("Ice")
```

After a new drink commits, the host automatically synchronizes it into the existing owned-recipe data. Authors neither need nor should call the old `EvAddDrink`. Unload removes only recipes first added by that mod and never deletes an existing host recipe.

Use a project-reserved range for new drink IDs; current examples use 5200/5201. Coordinate with other public mods before publishing because the API is not a global ID-allocation service.

## Registering a drink style

```lua
local style = Context.Content:MakeDrinkStyleDefinition()
style.ContentId = "pumpkin_orange_style"
style.LiquidId = "Drink.PumpkinOrange"
style.DrinkId = 5200
style.DisplayName = "Pumpkin Orange"
style.PrimaryColor = Context.Content:MakeColor(1.0, 0.58, 0.12, 1.0)
style.SecondaryColor = Context.Content:MakeColor(1.0, 0.58, 0.12, 1.0)
require_success(Context.Content:RegisterDrinkStyle(style))
```

Color components are RGBA 0–1. Fields:

- `ContentId`: transaction-unique ID.
- `LiquidId`: style registry key.
- `DrinkId`: associated recipe ID.
- `DisplayName`: style display name.
- `PrimaryColor`, `SecondaryColor`: the two liquid layers.
- `bPatchExisting`: patch an existing style.

Patch only the existing Lemon Water colors:

```lua
local style = Context.Content:MakeDrinkStyleDefinition()
style.ContentId = "red_lemon_water_style"
style.LiquidId = "Drink.LemonWater"
style.PrimaryColor = Context.Content:MakeColor(1, 0, 0, 1)
style.SecondaryColor = Context.Content:MakeColor(1, 0, 0, 1)
style.bPatchExisting = true
require_success(Context.Content:RegisterDrinkStyle(style))
```

This needs both `content.register` and `content.patch`. Disabling restores the original style; if several mods patch the same key, remaining layers are replayed in order.

## Registering a cup-add-item rule

The current public rule is “current cup liquid + one newly added item → result liquid”:

```lua
local rule = Context.Content:MakeCupAddItemRuleDefinition()
rule.ContentId = "pumpkin_juice_plus_orange"
rule.CurrentLiquidId = "Drink.PumpkinJuice"
rule.AddedItemId = "1103"
rule.ResultLiquidId = "Drink.PumpkinOrange"
require_success(Context.Content:RegisterCupAddItemRule(rule))
```

Fields are `ContentId`, `CurrentLiquidId`, `AddedItemId`, `ResultLiquidId`, and `bPatchExisting`.

v3 does not currently expose liquid-plus-liquid or arbitrary complex perfect-mix registration. Do not bypass this by accessing internal drink registries from manifest Lua.

## Registering furniture

The host handles resource PAKs and ShaderArchives before the Lua entry. Lua submits only the stable furniture definition:

```lua
local furniture = Context.Content:MakeFurnitureDefinition()
furniture.ContentId = "dog_01"
furniture.ItemId = "Mod_AnimalDecoration_Dog_01"
furniture.DisplayName = "Dog Decoration"
furniture.Description = "A dog-themed furniture piece."
furniture.CategoryTag = "购买.装饰.家具"
furniture.MeshObjectPath = "/Game/AddMeshTestMod1/SM_ToyDog_01.SM_ToyDog_01"
furniture.PreviewImageRelativePath = "SM_ToyDog_01.png"
furniture.ActorClassPath =
    "/Script/Engine.Blueprint'/Game/2Game/Blueprint/商店饰品/BP_家具2100随意放置.BP_家具2100随意放置'"
furniture.BoxClassPath =
    "/Script/Engine.Blueprint'/Game/1Game/Blueprint/AI/BP/货物包裹/BP_货物包裹建筑.BP_货物包裹建筑'"
furniture.PurchasePrice = 50
furniture.UnlockLevel = 0
furniture.BoxHeight = 50
furniture.BoxType = 2
furniture.bShowInShop = true
furniture.bAllowPainting = false
require_success(Context.Content:RegisterFurniture(furniture))
```

### FBaseInstallModFurnitureDefinition

| Field | Default | Meaning |
| --- | --- | --- |
| `ContentId` | empty | Unique local content ID |
| `ItemId` | empty | Internal item registry key; unique for new furniture |
| `DisplayName` | empty | Store/item display name |
| `Description` | empty | Description |
| `CategoryTag` | `购买.装饰.家具` | Item category |
| `MeshObjectPath` | empty | Cooked `/Game/.../Asset.Asset` object path |
| `PreviewImageRelativePath` | empty | Preview image under the mod root |
| `ActorClassPath` | empty | Placed Actor class |
| `BoxClassPath` | empty | Store delivery-box class |
| `PurchasePrice` | 0 | Non-negative price |
| `UnlockLevel` | 0 | Non-negative unlock level |
| `BoxHeight` | 50 | Package height |
| `BoxType` | 2 | Host package type |
| `bShowInShop` | true | Show in the shop |
| `bAllowPainting` | false | Allow painting |
| `ExtraFunctions` | map | Host-defined extra string parameters |
| `bPatchExisting` | false | Patch an existing ItemId |

At commit, the host adapts this definition to BaseInstall's internal item data. Mods must not depend on `FItemDataRuntime` or `UGB_ItemDataSubsystem`. See the [model-asset PAK guide](../../Model_PAK_Packaging_EN.md) for Cook, PAK, and ShaderArchive steps.

## Rollback semantics

- Add: unload deletes the entry created by the mod.
- Patch: unload restores the previous value.
- Layered patches: removing a middle layer replays the remaining layers from the base value.
- Failed load: if any definition fails, none of the mod's content is published.
- Base game: with no content mod, original behavior is unchanged.
