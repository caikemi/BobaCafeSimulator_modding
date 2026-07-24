-- AI translation notice: explanatory text in this English example was translated
-- with AI and may contain inaccurate wording. Chinese localization values,
-- GameplayTags, and UE object paths are intentional runtime data and are preserved.

-- ==========================================================================
-- Animal Decoration Asset Pack: model PAK + dynamic furniture registration
--
-- This example demonstrates how to:
-- 1. Mount the PAK and shared shader libraries from the current directory when
--    the Mod initializes.
-- 2. Load Static Meshes by their cooked UE object paths.
-- 3. Create FItemDataRuntime values and register four decorations in the
--    furniture store.
-- 4. Assign a separate store preview image to every decoration.
-- 5. Use English as the default text and provide Simplified Chinese localization.
--
-- New authors will normally only need to change:
-- ASSET_ROOT, ITEM_TAG_NAME, and entries in DECORATION_ITEMS.
-- ==========================================================================

-- ==========================================================================
-- Mods-list metadata
--
-- The game reads the key = "value" literals below directly while scanning the
-- Mods menu.
-- Default fields must use English. A Chinese culture prefers fields ending in _zh.
-- ==========================================================================
name           = "Animal Decoration Asset Pack"
description    = "Adds four animal-themed furniture decorations: a dog, an elephant, and two rocking horses."
name_zh        = "动物装饰资产包"
description_zh = "添加4款动物主题家具装饰：小狗摆件、大象摆件以及两款木马摆件。"
version        = "1.2.0"
author         = "yiming"

-- Return the two-letter language code used by the game. For example,
-- zh-Hans-CN becomes zh.
-- This example provides English and Chinese only; every other language falls
-- back to English.
local function GetGameLanguage()
    local Language = "en"

    if UE and UE.UKismetInternationalizationLibrary then
        local Culture = UE.UKismetInternationalizationLibrary.GetCurrentCulture()
        if Culture then
            Language = string.sub(tostring(Culture), 1, 2):lower()
        end
    end

    return Language == "zh" and "zh" or "en"
end

local CURRENT_LANGUAGE = GetGameLanguage()

local MOD_METADATA = {
    en = {
        Name = name,
        Description = description,
    },
    zh = {
        Name = name_zh,
        Description = description_zh,
    },
}

local CurrentMetadata = MOD_METADATA[CURRENT_LANGUAGE] or MOD_METADATA.en

local M = {
    id          = "AnimalDecorationAssetPack",
    name        = CurrentMetadata.Name,
    description = CurrentMetadata.Description,
    version     = version,
    author      = author,
}

-- GameplayTag for the furniture-store item category.
-- To use another store category, change this to a valid GameplayTag that already
-- exists in the game. The current Chinese value is a runtime identifier and must
-- not be translated.
local ITEM_TAG_NAME = "购买.装饰.家具"

-- Root UE asset path after cooking.
--
-- The meshes in this example's PAK were cooked from:
-- Content/AddMeshTestMod1/
-- Their runtime object paths must therefore continue to use:
-- /Game/AddMeshTestMod1/
--
-- Renaming the PAK does not change its internal asset paths. New authors should
-- replace this value with the folder from their own blank project. For example,
-- assets under Content/MyDecorationPack/ use /Game/MyDecorationPack.
local ASSET_ROOT = "/Game/AddMeshTestMod1"

-- Furniture items to register.
--
-- ItemID:
--   Unique runtime item ID. Different Mods must not use the same ID.
--
-- MeshName:
--   Static Mesh asset name inside the PAK, excluding its path and .uasset suffix.
--
-- TextureName:
--   Store preview image in the Mod folder. Every item can use a different image.
--
-- Text:
--   In-game item name and description. English is the default; zh is used in a
--   Chinese culture.
local DECORATION_ITEMS = {
    {
        ItemID = "Mod_AnimalDecoration_Dog_01",
        MeshName = "SM_ToyDog_01",
        TextureName = "SM_ToyDog_01.png",
        Text = {
            en = {
                DisplayName = "Dog Decoration",
                Description = "A dog-themed furniture decoration from the Animal Decoration Asset Pack.",
            },
            zh = {
                DisplayName = "小狗装饰摆件",
                Description = "动物装饰资产包中的小狗主题家具摆件。",
            },
        },
    },
    {
        ItemID = "Mod_AnimalDecoration_Elephant_01",
        MeshName = "SM_ToyElephant_01",
        TextureName = "SM_ToyElephant_01.png",
        Text = {
            en = {
                DisplayName = "Elephant Decoration",
                Description = "An elephant-themed furniture decoration from the Animal Decoration Asset Pack.",
            },
            zh = {
                DisplayName = "大象装饰摆件",
                Description = "动物装饰资产包中的大象主题家具摆件。",
            },
        },
    },
    {
        ItemID = "Mod_AnimalDecoration_Horse_01",
        MeshName = "SM_ToyHorse_01",
        TextureName = "SM_ToyHorse_01.png",
        Text = {
            en = {
                DisplayName = "Rocking Horse Decoration I",
                Description = "The first rocking horse furniture decoration in the Animal Decoration Asset Pack.",
            },
            zh = {
                DisplayName = "木马装饰摆件（款式一）",
                Description = "动物装饰资产包中的第一款木马家具摆件。",
            },
        },
    },
    {
        ItemID = "Mod_AnimalDecoration_Horse_02",
        MeshName = "SM_ToyHorse_02",
        TextureName = "SM_ToyHorse_02.png",
        Text = {
            en = {
                DisplayName = "Rocking Horse Decoration II",
                Description = "The second rocking horse furniture decoration in the Animal Decoration Asset Pack.",
            },
            zh = {
                DisplayName = "木马装饰摆件（款式二）",
                Description = "动物装饰资产包中的第二款木马家具摆件。",
            },
        },
    },
}

-- Return item text for the current language. Fall back to English when no
-- corresponding translation exists.
local function GetLocalizedItemText(ItemDefinition)
    return ItemDefinition.Text[CURRENT_LANGUAGE] or ItemDefinition.Text.en
end

-- Register one furniture item.
local function RegisterDecorationItem(ItemSubsystem, ItemTag, ItemDefinition)
    -- UE object-path format:
    -- /Game/AssetDirectory/AssetName.AssetName
    local MeshPath =
        ASSET_ROOT .. "/" .. ItemDefinition.MeshName .. "." .. ItemDefinition.MeshName

    -- A dynamically mounted PAK does not rely on Asset Registry enumeration.
    -- Load the mesh directly by its full object path.
    -- LoadObject returning nil normally means:
    -- 1. ASSET_ROOT or MeshName is incorrect;
    -- 2. The mesh was not included in the target Chunk/PAK;
    -- 3. The PAK did not mount successfully.
    local MountedMesh = MOD.GAA.LoadObject("StaticMesh'" .. MeshPath .. "'")
    if not MountedMesh then
        error("Animal decoration mesh failed to load: " .. MeshPath)
    end

    local ItemText = GetLocalizedItemText(ItemDefinition)
    local NewItemData = UE.FItemDataRuntime()

    -- ItemIndex: runtime item ID. It must match the first argument passed to
    -- RegisterItemData.
    NewItemData.ItemIndex = ItemDefinition.ItemID

    -- DisplayName / Description: localized text shown in the store and item UI.
    NewItemData.DisplayName = ItemText.DisplayName
    NewItemData.Description = ItemText.Description

    -- ItemTag: determines the store category in which the item appears.
    NewItemData.ItemTag = ItemTag

    -- Functions is the key/value map read by the furniture system. Each key has
    -- a fixed meaning and must not be renamed arbitrarily.

    -- Mesh: Static Mesh object path used by the furniture. It must exactly match
    -- the path inside the PAK.
    NewItemData.Functions:Add("Mesh", MeshPath)

    -- Painting: whether this is wall-mounted furniture. 0 means floor placement;
    -- 1 means wall placement.
    NewItemData.Functions:Add("Painting", "0")

    -- Show: whether the item appears in the furniture store. 1 shows it; 0 hides it.
    NewItemData.Functions:Add("Show", "1")

    -- UnlockLevel: player level required to buy the item. 0 makes it available
    -- from the start of the game.
    NewItemData.Functions:Add("UnlockLevel", "0")

    -- Value: purchase price in the furniture store.
    NewItemData.Functions:Add("Value", "50")

    -- TexturePath: preview image in the store list.
    -- This image is an ordinary PNG in the Mod folder and does not go into the PAK.
    -- Each item reads the independent image configured in DECORATION_ITEMS.
    NewItemData.Functions:Add(
        "TexturePath",
        UE.UModFilesystemLib.Join(MOD.ModDir, ItemDefinition.TextureName)
    )

    -- ClassPath: furniture Actor class spawned after purchase.
    -- This uses the game's general-purpose freely placeable furniture class.
    -- The Chinese object path is runtime data and must not be translated.
    NewItemData.Functions:Add(
        "ClassPath",
        "/Script/Engine.Blueprint'/Game/2Game/Blueprint/商店饰品/BP_家具2100随意放置.BP_家具2100随意放置'"
    )

    -- BoxClassPath: package-box Actor class used for delivery and carrying after
    -- the item is purchased. This object path must not be translated.
    NewItemData.Functions:Add(
        "BoxClassPath",
        "/Script/Engine.Blueprint'/Game/1Game/Blueprint/AI/BP/货物包裹/BP_货物包裹建筑.BP_货物包裹建筑'"
    )

    -- BoxHigh: height parameter used when the package box spawns or is placed.
    NewItemData.Functions:Add("BoxHigh", "50")

    -- BoxType: package-box category. 2 means a building/furniture package.
    NewItemData.Functions:Add("BoxType", "2")

    -- Write the complete runtime data to ItemDataSubsystem.
    -- An existing ItemID is overwritten, so every Mod should use independent IDs.
    ItemSubsystem:RegisterItemData(ItemDefinition.ItemID, NewItemData)

    print(
        "Animal decoration registered: "
            .. ItemText.DisplayName
            .. " -> "
            .. MeshPath
    )
end

-- Get the item subsystem, resolve the store category Tag, and then register
-- every furniture item in the configuration table.
local function RegisterAnimalDecorations()
    local CurrentWorld = MOD.GAA.WorldUtils:GetCurrentWorld()
    local ItemSubsystem = UE.UModFilesystemLib.GetItemDataSubsystem(CurrentWorld)
    if not ItemSubsystem then
        error("Animal Decoration Asset Pack could not get ItemDataSubsystem")
    end

    -- FNameToGameplayTag arguments:
    -- 1. ITEM_TAG_NAME: GameplayTag name to find.
    -- 2. false: placeholder required by UnLua for the bValid output parameter;
    --    it cannot be omitted.
    -- 3. false: do not let the engine print an additional error when the Tag is
    --    not found; the code below reports one consistently.
    local ItemTag, bTagValid = UE.UGB_FunctionLibary.FNameToGameplayTag(
        ITEM_TAG_NAME,
        false,
        false
    )

    if not bTagValid then
        error("Invalid item GameplayTag: " .. ITEM_TAG_NAME)
    end

    for _, ItemDefinition in ipairs(DECORATION_ITEMS) do
        RegisterDecorationItem(ItemSubsystem, ItemTag, ItemDefinition)
    end
end

-- Mod initialization entry point.
-- Called once when the game enables this Mod. It mounts the assets and registers
-- all four furniture items.
function M.OnInit()
    local CurrentWorld = MOD.GAA.WorldUtils:GetCurrentWorld()
    if not CurrentWorld then
        error("Animal Decoration Asset Pack could not get the current World")
    end

    -- UE Editor/PIE rejects cooked content that has no embedded engine version
    -- by default. Enable this console variable only for PIE testing; a packaged
    -- game does not need it.
    if UE.UGB_FunctionLibary.IsRunPIE(CurrentWorld) then
        UE.UKismetSystemLibrary.ExecuteConsoleCommand(
            CurrentWorld,
            "s.AllowUnversionedContentInEditor 1",
            nil
        )
    end

    -- Mount every .pak in the current Mod folder.
    -- The common loader also finds and opens the ShaderArchive-*.ushaderbytecode
    -- matching the current RHI in this directory. Call it before loading meshes.
    UE.UModFilesystemLib.MountPaksInDirectory(MOD.ModDir)

    RegisterAnimalDecorations()
end

return M
