# 🃏 "Boba Cafe Simulator - Reborn as the Manager of Ice Castle Sweet City" Modding Examples

_These Mod examples are written in **Lua**._

[中文](README.md) | [English](README_EN.md)

> [!IMPORTANT]
> This English documentation and the files under `Example_EN` were translated with AI and may contain inaccurate wording. If anything is unclear or conflicts with the game behavior, refer to the [original Chinese documentation](README.md).

---

## 📚 Quick navigation

- [How it works](#overview)
- [Mod folder structure](#folder-structure)
- [The `M` structure in `main.lua`](#m-struct)
- [Drink recipe data](#drink-data)
- [Complete Pumpkin Orange example](#drink-example)
- [The three mixing rules](#mix-rules)
- [Complete example: changing an existing drink's color](#drink-color-example)
- [Model PAK and decoration example](#decoration-asset-example)
- [Custom background music example](#custom-bgm-example)
- [Automatic daily bill payment example](#auto-pay-bill-example)
- [Localization (multilingual support)](#localization) ([open the `Example_EN` localization example](Example_EN/LocalizedPumpkinDrink/))
- [Uploading to the Steam Workshop](#workshop-upload)
- [Contact](#contact)
- [Community guidelines](#community-rules)
- [ID reference (liquids/drinks, toppings, and tutorial icons)](#id-appendix)

---

<a id="overview"></a>
## 🧩 How it works

The game automatically scans for and reads Mods from:

- `GameRoot/BobaCafeSimulator/Mods` 📁
- Item folders subscribed to through the **Steam Workshop** 🛠️

When an entry file named `main.lua` is found, the game can recognize, manage, and load that Mod from the **Mods** menu. `preview.png` is the recommended Mod preview image.

---

### ⚙️ Rule 1: loading and execution

- About **1 second** after entering the game, Mods are loaded in path order and the following function is called for each one:

  ```lua
  M.OnInit()   -- Runs once during initialization
  ```

### 🧠 Rule 2: global access

- `UE`: a global variable that provides access to the functions exposed by Unreal Engine.
- `M`: the current Mod's information structure, shown in the Mods list on the main menu.
- `dir`: the absolute path of the current Mod.

---

<a id="folder-structure"></a>
## 📁 Mod folder structure

Place a Mod under `GameRoot/BobaCafeSimulator/Mods/` so the game can recognize it.

```text
BobaCafeSimulator/
└── Mods/
    └── MyMod/           # This path and everything below it must not use Chinese names
        ├── main.lua     # Mod logic, written in Lua
        └── preview.png  # Preview image (256×256, square)
```

👉 [Example Mods](Example_EN/)

---

<a id="m-struct"></a>
## 🧾 The `M` structure in `main.lua`

`local M = {}` should normally contain:

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique Mod ID (English; used as the key) |
| `name` | string | Display name |
| `description` | string | Description |
| `version` | string | Version number |
| `author` | string | Author |

> ✅ You may freely declare local state or variables next to `M` for use within your Mod.

---

<a id="drink-data"></a>
## 🖼️ Adding or replacing a drink recipe

`FDrinkData` represents one complete drink recipe. The table below lists every field a beginner may set in `main.lua`; optional fields you do not use may keep their default values.

> 💡 Use IDs in the `5200–5999` range for custom drinks to avoid conflicts with built-in recipes. At present, recipes should combine existing ingredients, tools, and recipe logic.

| Field | UE type | Default | Lua example | Purpose |
|---|---|---|---|---|
| `ID` | `int32` | `0` | `D.ID = 5200` | Unique drink-recipe ID; normally required. |
| `DisplayName` | `FText` | Empty | `D.DisplayName = "Pumpkin Orange"` | Drink name shown in the recipe UI and in game. |
| `DrinkType` | `EDrinkType` | `MilkTea` | `D.DrinkType = UE.EDrinkType.FruitTea` | Drink category. Juice and fruit tea must explicitly use `FruitTea`. |
| `Season` | `TArray<EGBSeason>` | Empty array | `D.Season:Add(UE.EGBSeason.Spring)` | Seasons in which the drink can be sold. An empty array may prevent the recipe from appearing in every season. |
| `ImagePath` | `FString` | Empty | `D.ImagePath = dir .. "5200.png"` | Recipe image path, usually inside the Mod folder. |
| `Value` | `TMap<FName, float>` | `S/M/L = 0` | `D.Value:Add("M", 10.0)` | Sale price for the `S`, `M`, and `L` cup sizes. |
| `DrinkWaterFName` | `FName` | Empty | `D.DrinkWaterFName = "Drink.PumpkinOrange"` | Final liquid type that must match when completing the recipe. |
| `CanSweet` | `TArray<FName>` | All sweetness levels | `D.CanSweet:Add("Sweet5")` | Sweetness levels customers may order. Assign `D.CanSweet = {}` before adding a custom set. |
| `CanTemperature` | `TArray<FName>` | All temperatures | `D.CanTemperature:Add("Ice")` | Temperatures customers may order. Assign `D.CanTemperature = {}` before adding a custom set. |
| `NeedItemID` | `TArray<int32>` | Empty array | `D.NeedItemID:Add(1103)` | Topping/item IDs required by the recipe. Add the same ID repeatedly to require multiple units. |
| `ShowTutorialsItemID` | `TArray<int32>` | Empty array | `D.ShowTutorialsItemID:Add(1106)` | Tool/ingredient icons shown in sequence in the recipe tutorial bar. |
| `PerfectNeed` | `TArray<FPerfectNeed>` | Empty array | See the perfect-recipe example below | Required liquid types and percentage ranges for a perfect recipe. |
| `PerfectNeedItem` | `TMap<FName, int32>` | Empty | `D.PerfectNeedItem:Add("1103", 4)` | Topping ID and quantity required for a perfect recipe. |
| `HideGetWay` | `bool` | `false` | `D.HideGetWay = true` | Whether to hide the normal way to obtain the recipe. |
| `HideGetWayText` | `FText` | Empty | `D.HideGetWayText = "Unlocks as you continue exploring"` | Hint shown when `HideGetWay = true`. |
| `ShowGetWayText` | `FText` | Empty | `D.ShowGetWayText = "Obtained from a Mod"` | How the recipe was obtained, shown in the recipe UI. |
| `MakeNeedTutorialText` | `FText` | Empty | `D.MakeNeedTutorialText = "Juice, then add orange slices"` | Main preparation instructions in the recipe UI. |
| `MakeNeedTutorialExtraText` | `TArray<FName>` | Empty array | `D.MakeNeedTutorialExtraText:Add("SomeTextKey")` | Extra text keys used by the preparation tutorial. |
| `UnlockProgress` | `int32` | `0` | `D.UnlockProgress = 10` | Progress value required to unlock the recipe. |
| `UnlockProgressType` | `FName` | Empty | `D.UnlockProgressType = "FName"` | Unlock check type: `FName` or `Tag`. |
| `UnlockProgressFName` | `FName` | Empty | `D.UnlockProgressFName = "ProgressKey"` | Key used for an FName-based progress unlock. |
| `UnlockProgressTag` | `FName` | Empty | `D.UnlockProgressTag = "Progress.Tag"` | Gameplay Tag name used for a Tag-based progress unlock. |
| `UnlockedItemID` | `TArray<FName>` | Empty array | `D.UnlockedItemID:Add("Pumpkin")` | Item types unlocked along with this recipe. |
| `Function` | `TMap<FName, FName>` | Empty | `D.Function:Add("Key", "Value")` | Extra key/value flags reserved for extended logic. |

### All `DrinkType` values

| Lua value | Display category | Description |
|---|---|---|
| `UE.EDrinkType.None` | None | Does not belong to a specific drink category. |
| `UE.EDrinkType.MilkTea` | Milk tea | Milk-tea drinks; also the default value of `FDrinkData`. |
| `UE.EDrinkType.FruitTea` | Fruit tea | Fruit tea and juice. |
| `UE.EDrinkType.Coffee` | Coffee | Coffee drinks. |
| `UE.EDrinkType.SweetSoup` | Sweet soup | Sweet beverages and dessert soups. |
| `UE.EDrinkType.IceCream` | Ice cream | Ice-cream products. |

### Season, sweetness, and temperature values

- Seasons: `Spring`, `Summer`, `Autumn`, `Winter`
- Sweetness: `Sweet10`, `Sweet7`, `Sweet5`, `Sweet3`, `Sweet0`
- Temperature: `Hot`, `Normal`, `SmallIce`, `Ice`

For example, configure a juice that is available all year as follows:

```lua
D.DrinkType = UE.EDrinkType.FruitTea
D.Season:Add(UE.EGBSeason.Spring)
D.Season:Add(UE.EGBSeason.Summer)
D.Season:Add(UE.EGBSeason.Autumn)
D.Season:Add(UE.EGBSeason.Winter)
```

### Liquid percentages for a perfect recipe

Set all three `FPerfectNeed` fields: `WaterName`, `MinPercent`, and `MaxPercent`. For example, to require pumpkin juice to make up between 83% and 100% of the cup:

```lua
local PN = UE.FPerfectNeed()
PN.WaterName = "Drink.PumpkinJuice"
PN.MinPercent = 0.83
PN.MaxPercent = 1.00
D.PerfectNeed:Add(PN)
```

### Unlock and reward fields

- If you are not using a progress-based unlock, leave `UnlockProgress`, `UnlockProgressType`, `UnlockProgressFName`, and `UnlockProgressTag` at their defaults.
- When `UnlockProgressType = "FName"`, set `UnlockProgressFName`; when `UnlockProgressType = "Tag"`, set `UnlockProgressTag`.
- Known `UnlockedItemID` values include `Watermelon`, `Orange`, `Tea`, `Pot`, `Milk`, `Pumpkin`, `Boba`, `PaperCup`, and `Coffee`.

---

<a id="drink-example"></a>
## ✅ Complete runnable example: add a Pumpkin Orange recipe (`main.lua`)

```lua
-- Required metadata shown in the Mods menu
local M = {
    id          = "NewDrinkPumpkinOrange",
    name        = "Add Pumpkin Orange Recipe",
    description = "Adds a Pumpkin Orange recipe",
    version     = "1.0.0",
    author      = "yiming",

}

local function add_new_drink()
    local World = MOD.Playercontroller:GetWorld()
    local R = UE.UBoBaFunction.GetDrinkRegistryWS(World)
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("Could not find UDrinkRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end
    -- 1) Register the drink data (the override layer takes priority)
    local D = UE.FDrinkData()
    D.ID = 5200  -- Recommended range: 5200-5999
    -- Name
    D.DisplayName = "Pumpkin Orange"
    -- Drink category (FDrinkData defaults to MilkTea, so juice must override it explicitly)
    D.DrinkType = UE.EDrinkType.FruitTea
    -- Available all year
    D.Season:Add(UE.EGBSeason.Spring)
    D.Season:Add(UE.EGBSeason.Summer)
    D.Season:Add(UE.EGBSeason.Autumn)
    D.Season:Add(UE.EGBSeason.Winter)
    -- Image path
    D.ImagePath = dir .. "5200.png" -- An image in your Mod directory

    -- Prices (S/M/L)
    D.Value:Add("S", 8.0)
    D.Value:Add("M", 10.0)
    D.Value:Add("L", 12.0)
    -- Required final liquid type
    D.DrinkWaterFName = "Drink.PumpkinOrange"  -- New liquid type
    -- Required recipe items: four orange slices
    D.NeedItemID:Add(1103)
    D.NeedItemID:Add(1103)
    D.NeedItemID:Add(1103)
    D.NeedItemID:Add(1103)

    -- Sweetness levels customers may order
    D.CanSweet = {}
    D.CanSweet:Add("Sweet10")
    D.CanSweet:Add("Sweet7")
    D.CanSweet:Add("Sweet5")
    D.CanSweet:Add("Sweet3")
    D.CanSweet:Add("Sweet0")

    -- Temperatures customers may order
    D.CanTemperature = {}
    D.CanTemperature:Add("Hot")
    D.CanTemperature:Add("Normal")
    D.CanTemperature:Add("SmallIce")
    D.CanTemperature:Add("Ice")

    -- Perfect-recipe requirements ------------------------------------------
    -- Requires pumpkin juice to make up 0.83-1.00 of the cup
    local PN = UE.FPerfectNeed()
    PN.WaterName  = "Drink.PumpkinJuice"
    PN.MinPercent = 0.83
    PN.MaxPercent = 1.00
    D.PerfectNeed:Add(PN)
    -- Perfect-recipe items: four orange slices
    D.PerfectNeedItem:Add("1103",4)
    ------------------------------------------------------------------

    -- Tutorial icons shown in the recipe bar
    D.ShowTutorialsItemID:Add(1106) -- Juicer
    D.ShowTutorialsItemID:Add(1033) -- Pumpkin
    D.ShowTutorialsItemID:Add(1103) -- Orange slice
    -- Tutorial shown after opening the recipe panel
    D.MakeNeedTutorialText = "Make pumpkin juice, then add four orange slices"

    -- Acquisition method shown after opening the recipe panel
    D.ShowGetWayText = "Obtained from a Mod"

    -- Item types unlocked with the recipe. Available values currently include
    -- Watermelon, Orange, Tea, Pot, Milk, Pumpkin, Boba, PaperCup, and Coffee.
    D.UnlockedItemID = {}
    D.UnlockedItemID:Add("Pumpkin")
    D.UnlockedItemID:Add("Orange")


    -- 3) Single liquid + newly added liquid rule (not needed by this recipe)
    -- Example: pure water + coffee = pumpkin juice (kept commented as an API demonstration)
    ------------------------------------------------------------
    -- R:RegisterCupAddWaterRule(
    --     "Drink.PureWater",       -- CurrentType (liquid already in the cup)
    --     "Drink.Coffee",          -- AddWaterType (newly added liquid)
    --     "Drink.PumpkinJuice"     -- ToWaterType (resulting liquid)
    -- )

    ------------------------------------------------------------
    -- 4) Single liquid + newly added item: pumpkin juice + orange slice = Pumpkin Orange
    ------------------------------------------------------------
    R:RegisterCupAddItemRule(
        "Drink.PumpkinJuice",      -- CurrentType (liquid already in the cup)
        "1103",                    -- AddItemType (newly added orange slice)
        "Drink.PumpkinOrange"      -- ToWaterType (resulting liquid)
    )

    ------------------------------------------------------------
    -- 5) Multiple liquids + multiple items: perfect mix rule
    -- Pumpkin juice + orange juice + orange slice + lemon slice = Pumpkin Orange
    ------------------------------------------------------------
    local MixRule = UE.FPerfectMixRule()
    MixRule.RequiredWaterTypes:Add("Drink.PumpkinJuice") -- Pumpkin juice
    MixRule.RequiredWaterTypes:Add("Drink.OrangeJuice")  -- Orange juice
    MixRule.RequiredItemIDs:Add(1103)                    -- Orange slice
    MixRule.RequiredItemIDs:Add(1102)                    -- Lemon slice
    MixRule.OutputWaterType = "Drink.PumpkinOrange"      -- Resulting liquid on match
    R:AddOverridePerfectMixRule(MixRule)

    ------------------------------------------------------------
    -- 6) Drink color
    ------------------------------------------------------------
    local S = UE.FDrinkStyle()
    S.DisplayName = "Pumpkin Orange" -- Must match the recipe name
    -- Suggested orange-brown palette (adjustable): light → dark
    S.Color1 = UE.FLinearColor(1.00, 0.58, 0.12, 1.0)  -- Bright orange-brown
    S.Color2 = UE.FLinearColor(1.00, 0.58, 0.12, 1.0)  -- Bright orange-brown
    R:RegisterDrinkStyle("Drink.PumpkinOrange", S) -- Use the recipe's DrinkWaterFName


    -- Register with the override system
    R:RegisterDrinkData(D.ID, D)

    -- Add directly to the existing recipe list without an unlock requirement
    local GS = UE.UGameplayStatics.GetGameState(World) or nil  -- AGameStateBase*
    if GS then
        GS:EvAddDrink(D.ID)
    end

    if MOD and MOD.Logger then MOD.Logger.LogScreen("Registered: Pumpkin Orange (5200)", 5,0,1,0,1) end -- Log
end


function M.OnInit()
    -- Initialize
    if MOD and MOD.Logger then MOD.Logger.LogScreen(("Mod [%s] is loading"):format(M.name), 5,1,1,0,1) end -- Log
    add_new_drink()
end


return M
```

<a id="mix-rules"></a>
### Choosing between the three mixing rules

| Requirement | API | Match behavior |
|---|---|---|
| One liquid + one newly added liquid | `RegisterCupAddWaterRule` | Matches `CurrentType + AddWaterType` and produces `ToWaterType`. |
| One liquid + one newly added item | `RegisterCupAddItemRule` | Matches `CurrentType + AddItemType` and produces `ToWaterType`. |
| Multiple liquids + multiple items | `FPerfectMixRule` + `AddOverridePerfectMixRule` | Checks whether the cup contains every liquid type and item ID required by the rule. |

`FPerfectMixRule` has three configurable fields:

| Field | Type | Purpose |
|---|---|---|
| `RequiredWaterTypes` | `TArray<FName>` | Liquid types that must be present. |
| `RequiredItemIDs` | `TArray<int32>` | Item IDs that must be present. |
| `OutputWaterType` | `FName` | Resulting liquid when all requirements match. |

> Note: a perfect mix rule checks only whether a required type is present; it does not check liquid percentages. Adding the same item ID twice does not create a quantity requirement. For example, listing `1103` twice still only means that an orange slice must be present. Extra liquids or toppings in the cup do not prevent the rule from matching.

If several rules match, the system prefers the more specific rule with more required types. `OutputWaterType` should also have a corresponding `FDrinkStyle` and must agree with the recipe's `DrinkWaterFName`.

---

<a id="drink-color-example"></a>
## 🎨 Complete runnable example: change an existing drink's color (Red Lemon Water)

This example changes both liquid layers of the existing `Drink.LemonWater` to red without replacing the Lemon Water recipe data.

```text
RedLemonWater/
└── main.lua
```

Important implementation details:

1. Call `GetDrinkStyle` to read the complete server-initialized style first, then change only `Color1` and `Color2`. This preserves the existing `DrinkID`, display name, and icon.
2. Every Mod's `OnInit` runs synchronously. The example waits one second and keeps retrying if the drink registry or Lemon Water style is not ready, so it does not depend on Mod-list load order.
3. `FLinearColor` RGBA components use the `0.0–1.0` range. `UE.FLinearColor(1.0, 0.0, 0.0, 1.0)` is opaque red.

Complete `main.lua`:

```lua
local M = {
    id          = "RedLemonWater",
    name        = "Red Lemon Water",
    description = "Changes both liquid layers of Lemon Water to red",
    version     = "1.0.0",
    author      = "yiming",
}

local DRINK_STYLE_KEY = "Drink.LemonWater"
local RETRY_DELAY_SECONDS = 1
local MAX_RETRY_COUNT = 60

local retry_count = 0
local try_apply_red_color

local function log_screen(message, red, green, blue)
    if MOD and MOD.Logger then
        MOD.Logger.LogScreen(message, 5, red, green, blue, 1)
    end
end

local function schedule_retry(reason)
    retry_count = retry_count + 1

    if retry_count == 1 or retry_count % 5 == 0 then
        log_screen(
            string.format("[%s] Waiting for drink data: %s (%d/%d)", M.id, reason, retry_count, MAX_RETRY_COUNT),
            1, 1, 0
        )
    end

    if retry_count >= MAX_RETRY_COUNT then
        log_screen(
            string.format("[%s] Update failed: timed out waiting for %s", M.id, DRINK_STYLE_KEY),
            1, 0, 0
        )
        return
    end

    MOD.GAA.TimerManager:AddTimer(RETRY_DELAY_SECONDS, M, function()
        try_apply_red_color()
    end)
end

try_apply_red_color = function()
    local pc = MOD and MOD.Playercontroller or nil
    if not pc or not pc.GetWorld then
        schedule_retry("PlayerController is not ready")
        return
    end

    local world = pc:GetWorld()
    local registry = world and UE.UBoBaFunction.GetDrinkRegistryWS(world) or nil
    if not registry then
        schedule_retry("DrinkRegistryWorldSubsystem is not ready")
        return
    end

    -- Read the complete server-initialized style first. Change only the colors
    -- so the existing DrinkID, display name, and Icon are preserved.
    local found, style = registry:GetDrinkStyle(DRINK_STYLE_KEY)
    if not found or not style then
        schedule_retry(DRINK_STYLE_KEY .. " is not registered yet")
        return
    end

    local red = UE.FLinearColor(1.0, 0.0, 0.0, 1.0)
    style.Color1 = red
    style.Color2 = red

    registry:RegisterDrinkStyle(DRINK_STYLE_KEY, style)

    log_screen(
        string.format("[%s] Changed Color1/Color2 of %s to red", M.id, DRINK_STYLE_KEY),
        0, 1, 0
    )
end

function M.OnInit()
    log_screen(string.format("Mod [%s] is loading", M.name), 0, 1, 1)

    -- Every Mod's OnInit runs synchronously. Delay the write to avoid depending
    -- on the order of Mods in the list.
    MOD.GAA.TimerManager:AddTimer(RETRY_DELAY_SECONDS, M, function()
        try_apply_red_color()
    end)
end

return M
```

To change another existing drink, replace `DRINK_STYLE_KEY` and the color values:

```lua
local new_color_1 = UE.FLinearColor(1.0, 0.2, 0.2, 1.0)
local new_color_2 = UE.FLinearColor(0.6, 0.0, 0.0, 1.0)
style.Color1 = new_color_1
style.Color2 = new_color_2
```

To keep both liquid layers the same color, assign the same `FLinearColor` to `Color1` and `Color2`.

---

<a id="decoration-asset-example"></a>
## 🪑 Model PAK and decoration example

The game cannot read models, materials, and textures as ordinary loose files. They must first be cooked and packaged into a PAK using a blank **UE5.6** project that matches the game.

- [Read the complete Model PAK packaging guide](Model_PAK_Packaging_EN.md)
- [Open the complete Animal Decoration Asset Pack example](Example_EN/AnimalDecorationAssetPack/)
- [View its complete `main.lua`](Example_EN/AnimalDecorationAssetPack/main.lua)

### Simplest production workflow

1. Create a blank Blueprint project with an English name in UE5.6.
2. Create a dedicated English-named folder under `Content`, such as `Content/MyDecorationPack/`.
3. Put the models, materials, material instances, and textures in that folder, and make sure each Static Mesh has the correct material slots assigned.
4. Create a `PrimaryAssetLabel` data asset in the same folder. Set `Chunk ID = 1001`, `Cook Rule = Always Cook`, and enable `Label Assets in My Directory` and `Is Runtime Label`.
5. In the Mod authoring project's Packaging settings, enable Pak, Chunk generation, and shared shaders; disable IoStore; then package for Windows.
6. Copy `pakchunk1001-Windows.pak`, then extract both the SM5 and SM6 `ShaderArchive-*.ushaderbytecode` files from it.
7. Using the complete example as a reference, update `ASSET_ROOT`, item IDs, mesh names, text, and the preview image for each furniture item.

> **Important compatibility note:** the released base game must also have IoStore disabled. When repackaging the base game, use a new empty output directory; do not overwrite only the new `.pak` files in an old release directory that still contains `.utoc/.ucas` files. Otherwise, models may load while their material shader library fails to open, producing default gray or black materials. Regular Mod authors only need to disable IoStore in their Mod authoring project and use an official game build that supports traditional PAK Mods.

Project layout:

```text
MyDecorationProject/
├── MyDecorationProject.uproject
├── Config/
└── Content/
    └── MyDecorationPack/
        ├── PAL_MyDecorationPack.uasset
        ├── SM_MyDecoration.uasset
        ├── M_MyDecoration.uasset
        ├── MI_MyDecoration.uasset
        └── T_MyDecoration_Color.uasset
```

A `PrimaryAssetLabel` is a data asset in the UE Content Browser. Keep it in the same folder as the models, materials, and textures it manages. It does not belong under `Config`, the project root, or the game's `Mods` directory.

### Minimal Lua registration flow

Suppose the mesh is located at:

```text
Content/MyDecorationPack/SM_MyDecoration.uasset
```

Its runtime object path is:

```text
/Game/MyDecorationPack/SM_MyDecoration.SM_MyDecoration
```

The code below shows only the core registration flow for one floor decoration. Production code should retain the complete example's PAK mounting, PIE checks, error handling, English/Chinese text, and shader notes.

```lua
local M = {
    id = "MyDecorationMod",
    name = "My Decoration Mod",
    description = "Adds one custom furniture decoration.",
    version = "1.0.0",
    author = "YourName",
}

local ASSET_ROOT = "/Game/MyDecorationPack"
local ITEM_ID = "Mod_MyDecoration_01"
local MESH_NAME = "SM_MyDecoration"
local PREVIEW_IMAGE = "SM_MyDecoration.png"

local function RegisterOneDecoration()
    local World = MOD.GAA.WorldUtils:GetCurrentWorld()
    local ItemSubsystem = UE.UModFilesystemLib.GetItemDataSubsystem(World)
    if not ItemSubsystem then
        error("Could not get ItemDataSubsystem")
    end

    -- This GameplayTag is a runtime identifier and must not be translated.
    local ItemTag, bTagValid = UE.UGB_FunctionLibary.FNameToGameplayTag(
        "购买.装饰.家具",
        false,
        false
    )
    if not bTagValid then
        error("Invalid furniture GameplayTag")
    end

    local MeshPath = ASSET_ROOT .. "/" .. MESH_NAME .. "." .. MESH_NAME
    if not MOD.GAA.LoadObject("StaticMesh'" .. MeshPath .. "'") then
        error("Mesh failed to load: " .. MeshPath)
    end

    local ItemData = UE.FItemDataRuntime()
    ItemData.ItemIndex = ITEM_ID
    ItemData.DisplayName = "My Decoration"
    ItemData.Description = "A custom furniture decoration."
    ItemData.ItemTag = ItemTag

    ItemData.Functions:Add("Mesh", MeshPath)
    ItemData.Functions:Add("Painting", "0")
    ItemData.Functions:Add("Show", "1")
    ItemData.Functions:Add("UnlockLevel", "0")
    ItemData.Functions:Add("Value", "50")
    ItemData.Functions:Add(
        "TexturePath",
        UE.UModFilesystemLib.Join(MOD.ModDir, PREVIEW_IMAGE)
    )
    ItemData.Functions:Add(
        "ClassPath",
        "/Script/Engine.Blueprint'/Game/2Game/Blueprint/商店饰品/BP_家具2100随意放置.BP_家具2100随意放置'"
    )
    ItemData.Functions:Add(
        "BoxClassPath",
        "/Script/Engine.Blueprint'/Game/1Game/Blueprint/AI/BP/货物包裹/BP_货物包裹建筑.BP_货物包裹建筑'"
    )
    ItemData.Functions:Add("BoxHigh", "50")
    ItemData.Functions:Add("BoxType", "2")

    ItemSubsystem:RegisterItemData(ITEM_ID, ItemData)
end

function M.OnInit()
    -- Mount the PAK and shader libraries before loading any mesh by object path.
    UE.UModFilesystemLib.MountPaksInDirectory(MOD.ModDir)
    RegisterOneDecoration()
end

return M
```

The complete example also demonstrates:

- Registering four meshes as four separate items.
- Using a separate PNG preview image for every item.
- Using English as the default Mod metadata with Chinese localization.
- Falling back to English for in-game item names and descriptions, with Chinese localization.
- The meaning of each furniture field in `Functions`.
- Loading cooked content in Editor/PIE.

The final Mod folder must contain at least:

```text
MyDecorationMod/
├── main.lua
├── MyDecorationMod.pak
├── ShaderArchive-ProjectName_Chunk1001-PCD3D_SM5-PCD3D_SM5.ushaderbytecode
├── ShaderArchive-ProjectName_Chunk1001-PCD3D_SM6-PCD3D_SM6.ushaderbytecode
├── preview.png
└── SM_MyDecoration.png
```

---

<a id="custom-bgm-example"></a>
## 🎵 Custom background music (`CustomBGM` example)

This example builds a playlist from MP3 files in the Mod root directory. It starts after all Mods have loaded, advances automatically when a track ends, and loops the playlist.

> **Platform limitation: CustomBGM currently supports Windows only. It does not work on Mac/macOS.**

- [Open the complete example](Example_EN/CustomBGM/)
- [View `main.lua`](Example_EN/CustomBGM/main.lua)
- [Read the short instructions](Example_EN/CustomBGM/Instructions.txt)

```text
Example_EN/CustomBGM/
├── main.lua
├── Instructions.txt
├── 1.mp3       # Add your own; the example does not include music
└── 2.mp3
```

### Simple setup

1. Copy `Example_EN/CustomBGM` to `GameRoot\BobaCafeSimulator\Mods\CustomBGM\`.
2. Put `.mp3` files you created or are authorized to use directly in the `CustomBGM` root. Do not place them in subfolders.
3. If needed, edit `priority`, `SHUFFLE`, and `VOLUME_MULTIPLIER` near the top of `main.lua`.
4. Enable the Mod in the game's **Mods** menu and re-enter the game.

| Parameter | Purpose |
|---|---|
| `priority` | When several BGM Mods are enabled, a larger number has higher priority. |
| `SHUFFLE` | `true` plays randomly; `false` follows filename order. |
| `VOLUME_MULTIPLIER` | Additional volume multiplier for this Mod. The game's music-volume setting still applies. |

Core calls:

```lua
playerController:RegisterBackgroundMusicMod(M.id, M.priority, start_background_music)
playerController:PlayModBackgroundMusicFromDirectory(MOD.ModDir, SHUFFLE, VOLUME_MULTIPLIER)
```

### API and playback rules

- `RegisterBackgroundMusicMod(modId, priority, callback)` only registers a background-music provider. After all Mods load, the system invokes callbacks from highest to lowest `priority`; for equal priorities, the later-loaded Mod wins.
- Return `true` from the callback after music starts successfully. If it returns `false`, the system tries the next BGM Mod.
- `PlayModBackgroundMusicFromDirectory` scans only `.mp3` files directly in the Mod root and does not recurse into subfolders.
- When one track ends, the next starts automatically. The playlist loops after a complete pass.
- If this Mod has no playable MP3 files, the system tries the next BGM Mod. If every provider fails, it falls back to the game's default BGM.

> Only include music you created, are allowed to redistribute, or have explicit permission to use when uploading to the Steam Workshop.

---

<a id="auto-pay-bill-example"></a>
## 💳 Automatic daily bill payment (`AutoPayDailyBill` example)

This example uses the daily-morning Mod Hook to pay bills on the server in the order water → utilities → rent → payroll. **It works only when the server has installed and enabled the Mod. Installing it on a regular client does not execute payments.**

- [Open the complete example](Example_EN/AutoPayDailyBill/)
- [View `main.lua`](Example_EN/AutoPayDailyBill/main.lua)

```text
Example_EN/AutoPayDailyBill/
└── main.lua
```

### Simple setup

1. Copy `Example_EN/AutoPayDailyBill` to `GameRoot\BobaCafeSimulator\Mods\AutoPayDailyBill\`.
2. Enable the Mod in the game's **Mods** menu and re-enter the game.
3. After the "Daily morning callback registered" log appears, bills are checked automatically every morning of a new day.
4. To change payment priority, reorder the entries in `BILL_SEQUENCE` in `main.lua`.

Core call:

```lua
playerController:RegisterDailyMorningModHook(M.id, on_daily_morning)
```

Callback signature:

```lua
local function on_daily_morning(playerController, dayNumber)
    if not playerController or not playerController:HasAuthority() then
        return
    end

    -- Server logic to run every morning
end
```

### Default payment order

| Order | Bill | `Bill` field | `BillType` |
|---:|---|---|---|
| 1 | Water | `WaterRate` | `WaterRate` |
| 2 | Utilities | `Utility` | `Utility` |
| 3 | Rent | `Rent` | `Rent` |
| 4 | Payroll | `Payroll` | `Payroll` |

If the balance cannot cover the current bill, the example stops this payment pass. It does not skip the bill and continue with lower-priority ones. To change priority, only reorder the four entries in `BILL_SEQUENCE`.

### Automatic payment flow

For each bill paid successfully, the example:

1. Calls `TrySpendAllPlayerMoneyForAutoPayMod(amount)` to deduct shared money through the dedicated automatic-bill API. `amount` is a positive expense.
2. Calls `AddPaidBillToDayData(BillType, amount)` to record the payment in that day's `DayData`.
3. Clears the corresponding bill field, then synchronizes the bill through `SetServerBill`.
4. Calls `AddPlayerTaskByTagName` to add `1` to the `任务.支付1笔账单` task. This string is a runtime GameplayTag name and must not be translated.
5. Shows one summary notification after all payments finish.

> `TrySpendAllPlayerMoneyForAutoPayMod` is an ordinary authority-only server function, not a Server RPC. Its C++ implementation checks `HasAuthority()` again, requires an amount greater than `0`, requires a finite numeric value, and requires enough server-side balance. A client call is not forwarded to the server, and a negative value cannot be used to add money.
>
> Bills and shared money are server state. Do not remove the `HasAuthority()`, `PlayerIndex`, or API-integrity checks, or multiplayer games may deduct money more than once or become desynchronized. Do not replace these calls with a general-purpose add/subtract-money RPC in a Mod example.

---

<a id="localization"></a>
## 🌐 Localization (multilingual support)

Boba Cafe Mods have two localization layers:

1. **Mods-menu metadata**: `name`, `description`, and language-suffixed fields such as `name_zh` and `description_zh`.
2. **In-game drink text**: runtime fields such as `FDrinkData.DisplayName`, `MakeNeedTutorialText`, and `ShowGetWayText`.

The complete runnable example is located at:

- [Example_EN/LocalizedPumpkinDrink/](Example_EN/LocalizedPumpkinDrink/)
- [View `main.lua`](Example_EN/LocalizedPumpkinDrink/main.lua)

```text
Example_EN/LocalizedPumpkinDrink/
├── main.lua
├── 5290.png
└── preview.png
```

### Mods-menu name and description

The Mods-menu scanner does not execute Lua. It reads string literals directly from `main.lua`, so default and localized text must be written explicitly:

```lua
name           = "Localized Pumpkin Juice"
description    = "Adds a localized pumpkin juice recipe."
name_zh        = "本地化南瓜汁示例"
description_zh = "添加一个支持多语言显示的南瓜汁配方。"
name_ja        = "ローカライズかぼちゃジュース例"
description_ja = "多言語表示に対応したかぼちゃジュースを追加します。"
```

The default `name` and `description` fields are the English fallback. Language suffixes use two-letter codes, for example:

- `zh`: Chinese
- `en`: English, using the default fields
- `ja`: Japanese
- You may also add fields for `fr`, `de`, `es`, `ru`, and other languages

### In-game drink text

At runtime, call `GetCurrentCulture()` to get the current culture code, then select text from the drink translation table:

```lua
local DrinkText = {
    en = {
        DisplayName = "Pumpkin Juice",
        Tutorial = "Put a pumpkin into the juicer to make pumpkin juice.",
        GetWay = "Added by the localization example Mod.",
    },
    zh = {
        DisplayName = "南瓜汁（本地化示例）",
        Tutorial = "将南瓜放入榨汁机，制作南瓜汁。",
        GetWay = "由本地化示例 Mod 添加。",
    },
    ja = {
        DisplayName = "かぼちゃジュース",
        Tutorial = "かぼちゃをジューサーに入れてジュースを作ります。",
        GetWay = "ローカライズ例のModで追加されます。",
    },
}
```

The example currently supports Chinese, English, and Japanese. Every other language falls back to English. When adding a language, add both the Mods-menu `name_xx`/`description_xx` fields and the runtime `DrinkText.xx` table.

---

<a id="workshop-upload"></a>
## 🛠️ Uploading to the Steam Workshop

This section covers the complete Windows workflow from preparing files through the first release and later updates. The game's Steam App ID is **`3683770`**. Official Valve references: [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) and the [Steam Workshop Implementation Guide](https://partner.steamgames.com/doc/features/workshop/implementation).

Before starting, verify that:

- The Steam account used for uploading can sign in and owns the game.
- The account has no Workshop or Community feature restrictions.
- The Mod already runs correctly in the local game.
- Windows File Explorer has **View → Show → File name extensions** enabled so VDF/BAT files are not accidentally saved as `.vdf.txt` or `.bat.txt`.

### Step 1: download and initialize SteamCMD

1. Create an English-only directory on drive C: `C:\SteamCMD\`.
2. Download the Windows `steamcmd.zip` from Valve's official SteamCMD page.
3. Extract its files to `C:\SteamCMD\` and confirm that `C:\SteamCMD\steamcmd.exe` exists.
4. Double-click `steamcmd.exe`. On first launch it downloads and updates required files. Once the `Steam>` prompt appears, enter `quit`.

> SteamCMD needs network access and signs in to your own Steam account. Never put your password or Steam Guard code in a `.bat` file, VDF, or repository.

### Step 2: organize the Mod for upload

Create a dedicated upload directory and use English path and file names:

```text
D:\BobaWorkshop\
├── Mods\
│   └── LocalizedPumpkinDrink\
│       ├── main.lua
│       ├── preview.png
│       └── 5290.png
└── Upload\
    ├── LocalizedPumpkinDrink.vdf
    └── upload_LocalizedPumpkinDrink.bat
```

Before uploading, check every item:

1. Copy `LocalizedPumpkinDrink` to `GameRoot\BobaCafeSimulator\Mods\` and enable it in the game's **Mods** menu.
2. Enter the game and confirm that the Mod, recipe, images, and text all work.
3. The folder referenced by `contentfolder` must contain `main.lua` directly. Do not accidentally create `LocalizedPumpkinDrink\LocalizedPumpkinDrink\main.lua`.
4. Use a square 256×256 PNG for `preview.png` and confirm that it opens correctly.
5. For a model-asset Mod, include the `.pak` and both SM5 and SM6 `.ushaderbytecode` files. Do not upload `.utoc/.ucas`.
6. For CustomBGM, clearly state in both the Mod description and Workshop page that it supports Windows only and is unavailable on Mac/macOS.

### Step 3: create the upload VDF

Create the plain-text file `D:\BobaWorkshop\Upload\LocalizedPumpkinDrink.vdf`, save it as **UTF-8**, and enter:

```vdf
"workshopitem"
{
    "appid"            "3683770"
    "publishedfileid"  "0"
    "contentfolder"    "D:\\BobaWorkshop\\Mods\\LocalizedPumpkinDrink"
    "previewfile"      "D:\\BobaWorkshop\\Mods\\LocalizedPumpkinDrink\\preview.png"
    "visibility"       "2"
    "title"            "Localized Pumpkin Juice Example"
    "description"      "Demonstrates multilingual drink recipes and Mod metadata."
    "changenote"       "v1.0.0"
}
```

VDF fields:

| Field | Value |
|---|---|
| `appid` | Always `3683770`. |
| `publishedfileid` | Use `0` for the first release. SteamCMD writes the Workshop item ID back after a successful upload. |
| `contentfolder` | Absolute path of the Mod folder to upload. Windows paths in VDF use doubled backslashes: `\\`. |
| `previewfile` | Absolute path of the Workshop preview image. |
| `visibility` | `0` public, `1` friends only, `2` private, `3` unlisted. Start with `2`; change to `0` after testing. |
| `title` | Workshop page title. |
| `description` | Workshop page description. |
| `changenote` | Release/update notes, such as `v1.0.0 Initial release`. |

### Step 4: create a one-click upload batch file

Create `D:\BobaWorkshop\Upload\upload_LocalizedPumpkinDrink.bat`. Confirm that the extension is `.bat`, not `.bat.txt`. Paste the following and replace only `YourSteamAccount` with your Steam login name:

```bat
@echo off
setlocal
set "STEAMCMD=C:\SteamCMD\steamcmd.exe"
set "VDF=D:\BobaWorkshop\Upload\LocalizedPumpkinDrink.vdf"

"%STEAMCMD%" +login YourSteamAccount +workshop_build_item "%VDF%" +quit

echo.
echo SteamCMD has finished. Check the output above for ERROR messages.
pause
```

`pause` keeps the window open so you can inspect the result. If SteamCMD or the VDF is elsewhere, change only the corresponding `set` line.

### Step 5: first release

1. Confirm that `publishedfileid` is `0` in the VDF.
2. Double-click `upload_LocalizedPumpkinDrink.bat`.
3. Enter your password when SteamCMD prompts. If Steam Guard is enabled, enter the current verification code as well.
4. Wait for the upload to finish and verify that the window contains no `ERROR` or `Failed`.
5. Reopen the VDF in a text editor. After a successful upload, `publishedfileid` changes from `0` to a numeric ID. Back up this VDF.
6. Append the number to this address and open your Workshop page:

   `https://steamcommunity.com/sharedfiles/filedetails/?id=WorkshopItemID`

7. The first release may require accepting the Steam Workshop legal agreement on the page. The item may remain hidden until you accept it.
8. After testing, change `visibility` to `0`, upload once more, and verify on the Workshop page that the item is public.

### Step 6: update a published Mod

1. Update `main.lua`, images, or other resources in `contentfolder`.
2. Test the new version in the local Mods directory.
3. Update `changenote` in the VDF.
4. **Keep the `publishedfileid` written by SteamCMD. Do not reset it to `0`.** Resetting it attempts to create a separate item.
5. Double-click the same upload BAT. SteamCMD updates the existing item identified by `publishedfileid`.

### Step 7: subscription acceptance test

1. Click **Subscribe** on the Workshop page.
2. Wait until the Steam client's Downloads page says the Workshop content has downloaded, then launch the game.
3. Enable the Mod in the game's **Mods** menu, re-enter the game, and verify it.

Subscribed files are normally located at:

`[SteamInstallDirectory]\steamapps\workshop\content\3683770\[WorkshopItemID]\`

### Troubleshooting

| Symptom | Check first |
|---|---|
| SteamCMD cannot find the VDF/image | Verify the `VDF` path in the BAT and that `previewfile` in the VDF is an existing absolute path. |
| The Mods menu cannot find the subscribed Mod | Open the numeric-ID cache directory and confirm that it directly contains `main.lua`, without an extra nested folder. |
| The recipe image does not appear | Verify that `ImagePath = dir .. "ImageName.png"` matches the actual filename, case, and extension. |
| Upload succeeds but the page is not public | Check `visibility`, then open the item page and accept the Workshop legal agreement. |
| An update creates a new item | Never reset `publishedfileid` to `0` during an update. Use the VDF from the last successful upload. |
| More detailed errors are needed | Check `logs\Workshop_log.txt` and `workshopbuilds\depot_build_3683770.log` under the Steam directory. |

---

<a id="contact"></a>
## 📮 More APIs and extensions: contact

- Official QQ group (contact the group owner): 722792074
- Email: yangyiming780@foxmail.com
- Steam Community messages / Git issues

---

<a id="community-rules"></a>
## 🛡️ Community guidelines (summary)

1. 🚫 No illegal, politically sensitive, pornographic, violent, or terrorist content.
2. 🚫 No malicious insults, inflammatory conflict, or content alluding to real people.
3. 🚫 Do not use copyrighted assets without authorization.
4. 🚫 Do not use Mods to direct users to advertising, donations, or paid content.

Workshop items that violate these rules may be removed and the creator's publishing privileges may be suspended.

---

<a id="id-appendix"></a>
## 📚 Appendix: ID reference

Each record occupies one line and can be searched by `ID`, `FName`, name, `Color1`, or `Color2`. Log entries with `ID:0` are preserved as recorded.

### Current liquid/drink IDs, names, and colors

Base-liquid `FName` values can be used directly in a recipe's liquid-type fields. A finished drink without a predefined `FName` is shown as `—`.

> `Drink.Honey` is also a valid ingredient-liquid FName for recipes. The current color list does not contain a separate Honey record.

| ID | FName | Name | Color1 | Color2 |
|---:|---|---|---|---|
| 0 | `Drink.Syrup` | Syrup | `R=1 G=0.857 B=0.078 A=1` | `R=1 G=0.907 B=0.143 A=1` |
| 0 | `Drink.PumpkinJuice` | Pumpkin Juice | `R=0.644 G=0.28 B=0 A=1` | `R=0.585 G=0.275 B=0 A=1` |
| 0 | `Drink.HotMilk` | Baked Milk | `R=0.637 G=0.861 B=0.765 A=1` | `R=0.852 G=0.798 B=0.616 A=1` |
| 0 | `Drink.PineappleJuice` | Pineapple Juice | `R=1 G=0.678 B=0 A=1` | `R=1 G=0.887 B=0 A=1` |
| 0 | `Drink.JackfruitJuice` | Jackfruit Juice | `R=1 G=0.816 B=0.233 A=1` | `R=1 G=0.902 B=0.291 A=1` |
| 0 | `Drink.AppleJuice` | Apple Juice | `R=0.9 G=0.599 B=0.245 A=1` | `R=0.8 G=0.506 B=0.194 A=1` |
| 0 | `Drink.PeachJuice` | Peach Juice | `R=1 G=0.321 B=0.465 A=1` | `R=1 G=0.431 B=0.58 A=1` |
| 0 | `Drink.MangoJuice` | Mango Juice | `R=1 G=0.643 B=0 A=1` | `R=1 G=0.539 B=0 A=1` |
| 0 | `Drink.BananaJuice` | Banana Juice | `R=1 G=0.871 B=0 A=1` | `R=1 G=0.792 B=0 A=1` |
| 0 | `Drink.StrawberryJuice` | Strawberry Juice | `R=1 G=0.168 B=0.258 A=1` | `R=1 G=0.161 B=0.193 A=1` |
| 0 | `Drink.PomegranateJuice` | Pomegranate Juice | `R=0.8 G=0.074 B=0.092 A=1` | `R=0.599 G=0.066 B=0.066 A=1` |
| 0 | `Drink.CoconutMilk` | Coconut Milk | `R=1 G=1 B=1 A=1` | `R=1 G=1 B=1 A=1` |
| 0 | `Drink.FruitJelly` | Fruit Jelly Juice | `R=0.021 G=0.9 B=0.032 A=1` | `R=0.198 G=1 B=0.061 A=1` |
| 0 | `Drink.MagmaJelly` | Magma Jelly Juice | `R=1 G=0.11 B=0.453 A=1` | `R=1 G=0.102 B=0.202 A=1` |
| 0 | `Drink.GhostWater` | Ghost Water | `R=0.8 G=0.9 B=1 A=0.5` | `R=0.7 G=0.95 B=1 A=1` |
| 0 | `Drink.RustyIronWater` | Rusty Iron Water | `R=0.5 G=0.205 B=0.153 A=0.7` | `R=0.432 G=0.275 B=0.17 A=1` |
| 0 | `Drink.HotWater` | Hot Water | `R=0.382 G=0.965 B=1 A=1` | `R=0.622 G=0.866 B=0.96 A=1` |
| 0 | `Drink.PureWater` | Purified Water | `R=0.311 G=0.848 B=1 A=1` | `R=0.624 G=0.863 B=0.956 A=1` |
| 0 | `Drink.SashimiGreenTea` | Sashimi Green Tea | `R=0.553 G=0.564 B=0.128 A=1` | `R=0.408 G=0.46 B=0.11 A=1` |
| 0 | `Drink.Yogurt` | Yogurt | `R=0.95 G=0.95 B=0.716 A=1` | `R=1 G=1 B=0.859 A=1` |
| 5001 | — | Lemon Water | `R=1 G=0.604 B=0.049 A=1` | `R=1 G=0.604 B=0.049 A=1` |
| 5002 | `Drink.WatermelonJuice` | Watermelon Juice | `R=0.672 G=0.08 B=0.071 A=1` | `R=0.672 G=0.064 B=0.055 A=1` |
| 5003 | — | Smashed Fresh Orange | `R=0.991 G=0.391 B=0.047 A=1` | `R=0.964 G=0.391 B=0.094 A=1` |
| 5006 | `Drink.SqueezeOrangeJuice` | Fresh-Squeezed Orange Juice | `R=1 G=0.261 B=0 A=1` | `R=1 G=0.226 B=0 A=1` |
| 5005 | `Drink.Milk` | Milk | `R=1 G=0.967 B=0.905 A=1` | `R=1 G=0.972 B=0.918 A=1` |
| 5007 | `Drink.GreenTea` | Green Tea | `R=0.223 G=0.297 B=0.086 A=1` | `R=0.234 G=0.31 B=0.095 A=1` |
| 5014 | `Drink.Coffee` | Hot Coffee | `R=0.05 G=0.014 B=0.004 A=1` | `R=0.068 G=0.019 B=0.005 A=1` |
| 5032 | `Drink.MilkTea` | Milk Tea | `R=0.356 G=0.212 B=0.09 A=1` | `R=0.373 G=0.191 B=0.037 A=1` |
| 5008 | — | Lemon Green Tea | `R=0.553 G=0.564 B=0.128 A=1` | `R=0.408 G=0.46 B=0.11 A=1` |
| 5009 | — | Watermelon Iced Tea | `R=0.701 G=0.286 B=0.196 A=1` | `R=0.701 G=0.296 B=0.216 A=1` |
| 5011 | — | Watermelon Fruit Milk | `R=1 G=0.422 B=0.246 A=1` | `R=1 G=0.455 B=0.27 A=1` |
| 5013 | — | Orange Lemon | `R=1 G=0.836 B=0.155 A=1` | `R=1 G=0.63 B=0.097 A=1` |
| 5015 | — | Pumpkin Tea | `R=0.401 G=0.21 B=0.059 A=1` | `R=0.46 G=0.242 B=0.015 A=1` |
| 5016 | — | Pumpkin Milk | `R=0.661 G=0.504 B=0.24 A=1` | `R=0.627 G=0.395 B=0.179 A=1` |
| 5019 | — | Taro Ball Milk Tea | `R=0.453 G=0.265 B=0.321 A=1` | `R=0.353 G=0.266 B=0.411 A=1` |
| 5020 | — | Jasmine Milk Green Tea | `R=0.695 G=0.7 B=0.303 A=1` | `R=0.779 G=0.95 B=0.437 A=1` |
| 5021 | — | Taro Paste Milk Tea | `R=0.516 G=0.397 B=0.595 A=1` | `R=0.76 G=0.574 B=0.365 A=1` |
| 5022 | — | Taro Paste Boba | `R=0.576 G=0.454 B=0.658 A=1` | `R=0.658 G=0.378 B=0.44 A=1` |
| 5023 | — | Pudding Milk Tea | `R=0.668 G=0.475 B=0.256 A=1` | `R=0.714 G=0.615 B=0.172 A=1` |
| 5024 | — | Ao-Ao Milk Tea | `R=0.484 G=0.34 B=0.177 A=1` | `R=0.391 G=0.318 B=0.276 A=1` |
| 5025 | — | Red Bean Milk Tea | `R=0.717 G=0.411 B=0.214 A=1` | `R=0.568 G=0.338 B=0.338 A=1` |
| 5026 | — | Red Bean Milk Pudding | `R=0.716 G=0.381 B=0.16 A=1` | `R=0.565 G=0.337 B=0.337 A=1` |
| 5027 | — | Double-Topping Milk Tea | `R=0.356 G=0.212 B=0.089 A=1` | `R=0.371 G=0.191 B=0.037 A=1` |
| 5028 | — | Coconut Jelly Milk Tea | `R=0.76 G=0.6 B=0.42 A=1` | `R=0.9 G=0.9 B=0.95 A=1` |
| 5029 | — | Supreme Triple-Topping Milk Tea | `R=0.76 G=0.6 B=0.42 A=1` | `R=0.1 G=0.1 B=0.1 A=1` |
| 5030 | — | Cheese-Foam Milk Tea | `R=0.6 G=0.7 B=0.4 A=1` | `R=1 G=0.98 B=0.9 A=1` |
| 5031 | — | Ao-Ao Cheese Milk Tea | `R=0.761 G=0.597 B=0.418 A=1` | `R=0.543 G=0.405 B=0.358 A=1` |
| 5033 | — | Red Date and Longan Warm Milk Tea | `R=0.6 G=0.239 B=0.149 A=1` | `R=0.741 G=0.567 B=0.218 A=1` |
| 5034 | — | Brown Sugar Boba Milk Tea | `R=0.356 G=0.212 B=0.089 A=1` | `R=0.523 G=0.327 B=0.21 A=1` |
| 5035 | — | Baked-Milk Tea | `R=1 G=0.965 B=0.905 A=1` | `R=0.685 G=0.95 B=0.662 A=1` |
| 5036 | — | Watermelon Boba | `R=1 G=0.3 B=0.35 A=1` | `R=1 G=0.9 B=0.9 A=1` |
| 5037 | — | Taro Ball Grape | `R=0.45 G=0.25 B=0.55 A=1` | `R=0.65 G=0.5 B=0.75 A=1` |
| 5038 | — | Full-Cup Passion Fruit | `R=0.9 G=0.8 B=0.2 A=1` | `R=0.429 G=0.502 B=0.283 A=1` |
| 5039 | — | Pineapple Jackfruit | `R=0.95 G=0.9 B=0.1 A=1` | `R=1 G=0.8 B=0.2 A=1` |
| 5040 | — | Apple Peach | `R=1 G=0.7 B=0.75 A=1` | `R=0.9 G=0.8 B=0.4 A=1` |
| 5041 | — | Peach Mango | `R=0.97 G=0.726 B=0.767 A=1` | `R=1 G=0.82 B=0.387 A=1` |
| 5042 | — | Blueberry Fruit Tea | `R=0.259 G=0.233 B=0.5 A=1` | `R=0.285 G=0.215 B=0.4 A=1` |
| 5043 | — | Peach Nectar | `R=1 G=0.623 B=0.686 A=1` | `R=0.981 G=1 B=0.634 A=1` |
| 5044 | — | Peach Green Tea | `R=0.6 G=0.7 B=0.4 A=1` | `R=1 G=0.7 B=0.75 A=1` |
| 5045 | — | Passion Fruit Pineapple | `R=1 G=0.768 B=0.21 A=1` | `R=0.794 G=0.964 B=0.775 A=1` |
| 5046 | — | Jasmine Green Grape | `R=0.65 G=0.85 B=0.35 A=1` | `R=0.6 G=0.7 B=0.4 A=1` |
| 5047 | — | Mint Green Tea | `R=0.2 G=0.8 B=0.5 A=1` | `R=0.6 G=0.7 B=0.4 A=1` |
| 5048 | — | Pomegranate Juice | `R=0.8 G=0.1 B=0.15 A=1` | `R=0.9 G=0.2 B=0.25 A=1` |
| 5049 | — | Grape Jelly | `R=0.45 G=0.25 B=0.55 A=1` | `R=1 G=0.7 B=0.98 A=0.5` |
| 5050 | — | Fresh Mango Passion Fruit | `R=1 G=0.783 B=0.262 A=1` | `R=0.915 G=0.965 B=0.571 A=1` |
| 5051 | — | Green Plum Iced Tea | `R=0.5 G=0.6 B=0.2 A=1` | `R=0.8 G=0.7 B=0.4 A=1` |
| 5052 | — | Sunshine Green Grape | `R=0.65 G=0.85 B=0.35 A=1` | `R=0.9 G=0.95 B=0.8 A=1` |
| 5053 | — | Super Fruit Tea | `R=0.9 G=0.5 B=0.2 A=1` | `R=0.8 G=0.9 B=0.2 A=1` |
| 5054 | — | Honey Pomelo Tea | `R=0.95 G=0.7 B=0.1 A=1` | `R=1 G=0.882 B=0.29 A=1` |
| 5055 | — | Latte | `R=0.35 G=0.2 B=0.1 A=1` | `R=0.398 G=0.272 B=0.187 A=1` |
| 5056 | — | Coconut Latte | `R=0.429 G=0.264 B=0.153 A=1` | `R=0.397 G=0.286 B=0.213 A=1` |
| 5057 | — | Grape Americano | `R=0.061 G=0.013 B=0.025 A=1` | `R=0.068 G=0.019 B=0.005 A=1` |
| 5058 | — | Jasmine Latte | `R=0.397 G=0.27 B=0.188 A=1` | `R=0.499 G=0.582 B=0.332 A=1` |
| 5059 | — | Apple Latte | `R=0.397 G=0.285 B=0.211 A=1` | `R=0.967 G=0.588 B=0.505 A=1` |
| 5060 | — | Orange Americano | `R=0.151 G=0.073 B=0.037 A=1` | `R=0.148 G=0.084 B=0.021 A=1` |
| 5061 | — | Butter Latte | `R=0.397 G=0.27 B=0.188 A=1` | `R=0.509 G=0.446 B=0.227 A=1` |
| 5062 | — | Peach Latte | `R=0.397 G=0.27 B=0.188 A=1` | `R=0.564 G=0.395 B=0.423 A=1` |
| 5063 | — | Mango Milk | `R=1 G=0.767 B=0.207 A=1` | `R=0.832 G=0.832 B=0.576 A=1` |
| 5064 | — | Coconut Mango Pomelo Sago | `R=1 G=0.735 B=0.099 A=1` | `R=0.95 G=0.95 B=0.602 A=1` |
| 5065 | — | Mango Pomelo Sago | `R=1 G=0.738 B=0.1 A=1` | `R=0.947 G=0.947 B=0.386 A=1` |
| 5066 | — | Peach Gum Milk | `R=0.95 G=0.95 B=0.572 A=1` | `R=0.88 G=0.668 B=0.243 A=1` |
| 5067 | — | Watermelon Coconut | `R=1 G=0.3 B=0.35 A=1` | `R=0.95 G=0.95 B=0.744 A=1` |
| 5068 | — | Coconut Lemon Milk | `R=0.95 G=0.95 B=0.562 A=1` | `R=0.95 G=0.898 B=0.173 A=1` |
| 5069 | — | Taro Ball Coconut | `R=0.95 G=0.95 B=0.92 A=1` | `R=0.658 G=0.52 B=0.75 A=1` |
| 5070 | — | Mango Sago | `R=1 G=0.75 B=0.15 A=1` | `R=1 G=0.845 B=0.509 A=1` |
| 5071 | — | Avocado Sago | `R=0.56 G=0.75 B=0.306 A=1` | `R=0.985 G=1 B=0.634 A=1` |
| 5072 | — | Brown Sugar Boba Milk Tea | `R=0.762 G=0.428 B=0.263 A=1` | `R=0.55 G=0.304 B=0.181 A=1` |
| 5073 | — | Glowing Lemon Water | `R=0.867 G=1 B=0.172 A=1` | `R=0.675 G=1 B=0.178 A=1` |
| 5074 | — | Mandrake Green Tea | `R=0.066 G=0.65 B=0.155 A=1` | `R=0.245 G=0.6 B=0.191 A=1` |
| 5075 | — | Magma Watermelon Tentacles | `R=0.95 G=0 B=0.012 A=1` | `R=1 G=0.278 B=0.12 A=1` |
| 5076 | — | Glowing Mandrake Lemon | `R=0.153 G=1 B=0.118 A=1` | `R=0.472 G=0.8 B=0.038 A=1` |
| 5077 | — | Ghost Baked Milk | `R=0.8 G=0.723 B=0.517 A=1` | `R=0.439 G=0.907 B=1 A=1` |
| 5078 | — | Rust Green Tea | `R=0.14 G=0.5 B=0.151 A=1` | `R=0.439 G=0.22 B=0.073 A=1` |
| 5079 | — | Ghost Mandrake | `R=0.582 G=1 B=0.835 A=1` | `R=0.109 G=0.5 B=0.123 A=1` |
| 5080 | — | Rusty Peach | `R=0.832 G=0.443 B=0.443 A=1` | `R=0.432 G=0.21 B=0.062 A=1` |
| 5081 | — | Ghost Mango | `R=1 G=0.633 B=0.119 A=1` | `R=0.345 G=0.891 B=1 A=1` |
| 5082 | — | Dried-Bat Americano | `R=0.273 G=0.151 B=0.076 A=1` | `R=0.047 G=0.047 B=0.047 A=1` |
| 5083 | — | Abyss Green Tea | `R=0.408 G=0.65 B=0.166 A=1` | `R=0.7 G=0.442 B=0.425 A=1` |
| 5084 | — | Will-o'-the-Wisp Baked Milk | `R=1 G=0.892 B=0.664 A=1` | `R=1 G=0.068 B=0.064 A=1` |
| 5085 | — | Spider Cave Ghost Water | `R=0.394 G=0.85 B=0.787 A=1` | `R=0.154 G=1 B=0.323 A=1` |
| 5086 | — | Cthulhu Tentacle Cup | `R=0.1 G=0.3 B=0.25 A=1` | `R=0.6 G=0 B=0.8 A=1` |
| 5087 | — | Spider Cave Grape Tea | `R=0.343 G=0.074 B=0.45 A=1` | `R=0.418 G=0.9 B=0.489 A=1` |
| 5088 | — | Bat Coconut | `R=0.61 G=1 B=0.911 A=1` | `R=0.095 G=0.06 B=0.025 A=1` |
| 5089 | — | Ghost Milk with Taro Balls | `R=0.622 G=0.471 B=0.85 A=1` | `R=0.366 G=0.951 B=1 A=1` |
| 5090 | — | Ice and Fire Duet | `R=0 G=0.543 B=1 A=1` | `R=1 G=0.005 B=0 A=1` |
| 5091 | — | Mandrake Mutant Watermelon Juice | `R=0.8 G=0.2 B=0.4 A=1` | `R=0.48 G=1 B=0.415 A=1` |
| 5092 | — | Dirty Mushroom Tea | `R=0.227 G=0.096 B=0.04 A=1` | `R=0.5 G=0.316 B=0.171 A=1` |
| 5093 | — | Jelly Slime Baked Milk | `R=0 G=1 B=0.031 A=1` | `R=0.219 G=0.9 B=0.347 A=1` |
| 5094 | — | Toxic Swamp Lemon Water | `R=0.863 G=1 B=0.108 A=1` | `R=0.887 G=0.402 B=1 A=1` |
| 5095 | — | Gaze of the Abyss | `R=0.5 G=0 B=1 A=1` | `R=0.98 G=0.127 B=1 A=1` |
| 5096 | — | Magma Lava Drink | `R=1 G=0.003 B=0 A=1` | `R=0.1 G=0.021 B=0 A=1` |
| 5097 | — | Bat Latte | `R=0.373 G=0.267 B=0.183 A=1` | `R=0.18 G=0.1 B=0.05 A=1` |
| 5098 | — | Dark Spore Latte | `R=0.175 G=0.112 B=0.081 A=1` | `R=0.447 G=0.162 B=0.7 A=1` |
| 5099 | — | Bat Wasteland Milk Tea | `R=1 G=1 B=1 A=1` | `R=1 G=1 B=1 A=1` |
| 5100 | — | Swamp Jelly | `R=0.2 G=0.3 B=0.2 A=1` | `R=0.2 G=1 B=0.1 A=1` |
| 5101 | — | Infernal Bitter Water | `R=0 G=0 B=0 A=1` | `R=1 G=0.3 B=0 A=1` |
| 5102 | — | Hallucinogenic Mushroom Milk | `R=0.8 G=0.4 B=0.8 A=1` | `R=0 G=0.5 B=1 A=1` |
| 5103 | — | Abyssal Trap Honey Brew | `R=0.079 G=0 B=0.1 A=1` | `R=0.926 G=1 B=0 A=1` |
| 5104 | — | Void Black Hole | `R=0 G=0.017 B=1 A=1` | `R=0.007 G=0 B=0.5 A=1` |
| 5105 | — | Galactic Stardust Dew | `R=0 G=0.471 B=1 A=1` | `R=0.309 G=0 B=1 A=1` |
| 5106 | — | Philosopher's Stone Special | `R=0.7 G=0.138 B=0.001 A=1` | `R=0.546 G=1 B=0 A=1` |
| 5108 | `Drink.CherryJuice` | Premium Cherry Juice | `R=0.7 G=0.1 B=0.15 A=1` | `R=0.7 G=0.1 B=0.15 A=1` |
| 5107 | — | Ruby Orange Juice | `R=0.95 G=0.35 B=0.1 A=1` | `R=1 G=0.6 B=0.05 A=1` |
| 5109 | — | Lucky Red Milk | `R=0.92 G=0.75 B=0.8 A=1` | `R=0.96 G=0.96 B=0.92 A=1` |
| 5110 | — | Candied Hawthorn Americano | `R=0.18 G=0.1 B=0.05 A=1` | `R=0.85 G=0.1 B=0.1 A=1` |
| 5111 | — | Firecracker Milk Tea | `R=0.65 G=0.75 B=0.55 A=1` | `R=1 G=0.2 B=0.2 A=1` |
| 5112 | — | Explosive Red Cherry | `R=0.7 G=0.05 B=0.15 A=1` | `R=1 G=0.2 B=0.2 A=1` |
| 5113 | — | Explosive Candied Hawthorn | `R=0.7 G=0.05 B=0.15 A=1` | `R=0.85 G=0.1 B=0.1 A=1` |
| 5114 | — | Banana Milk | `R=0.982 G=0.807 B=0.371 A=1` | `R=0.982 G=0.807 B=0.371 A=1` |
| 5115 | — | Strawberry Milk | `R=0.991 G=0.479 B=0.474 A=1` | `R=0.991 G=0.815 B=0.753 A=1` |
| 5116 | — | Mint Chocolate Latte | `R=0.558 G=0.397 B=0.216 A=1` | `R=0.716 G=0.839 B=0.658 A=1` |
| 5117 | — | Apple Jasmine | `R=0.839 G=0.839 B=0.515 A=1` | `R=0.839 G=0.831 B=0.509 A=1` |
| 5118 | — | Banana Latte | `R=0.88 G=0.571 B=0.216 A=1` | `R=0.982 G=0.839 B=0.558 A=1` |
| 5119 | — | Banana Green Tea | `R=0.597 G=0.624 B=0.153 A=1` | `R=0.839 G=0.839 B=0.434 A=1` |
| 5120 | — | Super Yogurt Bowl | `R=1 G=1 B=1 A=1` | `R=1 G=1 B=1 A=1` |
| 5121 | — | Strawberry Yogurt | `R=0.982 G=0.672 B=0.651 A=1` | `R=0.973 G=0.905 B=0.847 A=1` |
| 5122 | — | Banana Yogurt | `R=0.991 G=0.913 B=0.651 A=1` | `R=0.991 G=0.913 B=0.651 A=1` |
| 5123 | — | Mint Milk Green Tea | `R=0.223 G=0.497 B=0.086 A=1` | `R=0.552 G=0.694 B=0.301 A=1` |
| 5124 | — | Jasmine Green Tea | `R=0.73 G=0.768 B=0.258 A=1` | `R=0.738 G=0.784 B=0.275 A=1` |
| 5125 | — | Red Apple Milk Green Tea | `R=0.665 G=0.745 B=0.279 A=1` | `R=0.88 G=0.896 B=0.701 A=1` |
| 5126 | — | Apple Milk | `R=0.991 G=0.871 B=0.565 A=1` | `R=0.991 G=0.905 B=0.658 A=1` |

### Current topping IDs

```text
1102 Lemon Slice
1103 Orange Slice
1105 Purified Water Tool
1106 Juicer Tool
1107 Boba
1108 Receipt
7001 Taro Ball
7002 Jasmine Jam
7003 Taro Paste
7004 Popping Boba
7005 Pudding
7006 Ao-Ao
7007 Peach Gum
7008 Purple Rice
7009 Diced Mango
7010 Diced Avocado
7011 Diced Peach
7012 Diced Pineapple
7013 Blueberry
7014 Butter
7015 Red Bean
7016 Brown Sugar
7017 Jelly
7018 Pomelo Pulp
7019 Green Plum
7020 Honey
7021 Passion Fruit
7022 Cheese Foam
7023 Dried Red Date
7024 Dried Longan
7025 Coconut Jelly
7026 Peeled Green Grape
7027 Peeled Grape
7028 Mint
7029 Sago
7030 Glowing Lemon Slice
7031 Graveyard Mushroom
7032 Dried Bat
7033 Mandrake Slice
7034 Spider Silk
7035 Eye of the Abyss
7036 Magma Tentacle Slice
7037 Philosopher's Stone
7038 Will-o'-the-Wisp
7039 Star Prism
7040 Jelly Slime
7041 Magma Jelly Slime
7042 Ghost Water
7043 Rusty Iron Water
7044 Firecracker
7045 Candied Hawthorn
7046 Cupid Syrup
7047 Taste-Amnesia Powder
7048 Perfect-Filter Flavoring
7049 Sashimi
7050 Skeleton Fishbone Powder
```

### Tutorial icon IDs

Use these values with `D.ShowTutorialsItemID:Add(ID)`.

```text
1004 Watermelon
1005 Orange
1007 Milk
1008 Green Tea
1010 Cooking Pot
1012 Juicer
1028 Grinder
1029 Coffee Beans
1030 Coffee Brewer
1033 Pumpkin
1036 Apple
1040 Peach
1045 Strawberry
1047 Pineapple
1054 Banana
1092 Jackfruit
1093 Mango
1094 Pomegranate
1105 Purified Water Tool
1106 Juicer Tool
1116 Coconut Milk
1142 Centrifuge
1143 Premium 8J Cherry
1175 Yogurt Maker
3033 Infusion Device
```
