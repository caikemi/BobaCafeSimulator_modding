-- ==========================================================================
-- Mod 列表元数据
-- 游戏扫描 Mods 菜单时不会执行 Lua，而是直接读取下面的 key = "value" 字面量。
-- 默认字段使用英文；当前文化为 zh/ja 时会优先读取对应后缀字段。
-- ==========================================================================
name           = "Localized Pumpkin Juice"
description    = "Adds a pumpkin juice recipe and demonstrates localized Mod metadata and drink text."
name_zh        = "本地化南瓜汁示例"
description_zh = "添加南瓜汁配方，并演示 Mod 信息和饮品文本的多语言支持。"
name_ja        = "ローカライズかぼちゃジュース例"
description_ja = "かぼちゃジュースのレシピを追加し、Mod情報とドリンク表示の多言語対応を実演します。"
version        = "1.0.0"
author         = "yiming"

-- 获取两位语言代码，例如 zh-Hans-CN -> zh、ja-JP -> ja。
local function GetGameLanguage()
    local language = "en"
    if UE and UE.UKismetInternationalizationLibrary then
        local culture = UE.UKismetInternationalizationLibrary.GetCurrentCulture()
        if culture then
            language = string.sub(tostring(culture), 1, 2):lower()
        end
    end

    local supported = {
        en = true,
        zh = true,
        ja = true,
    }
    return supported[language] and language or "en"
end

local CurrentLanguage = GetGameLanguage()

local MetadataText = {
    en = { Name = name,    Description = description },
    zh = { Name = name_zh, Description = description_zh },
    ja = { Name = name_ja, Description = description_ja },
}
local CurrentMetadata = MetadataText[CurrentLanguage] or MetadataText.en

local M = {
    id          = "LocalizedPumpkinDrink",
    name        = CurrentMetadata.Name,
    description = CurrentMetadata.Description,
    version     = version,
    author      = author,
}

-- 饮品运行时文本；未提供的语言统一回退到英文。
local DrinkText = {
    en = {
        DisplayName = "Pumpkin Juice",
        Tutorial    = "Put a pumpkin into the juicer to make pumpkin juice.",
        GetWay      = "Added by the localization example Mod.",
    },
    zh = {
        DisplayName = "南瓜汁（本地化示例）",
        Tutorial    = "将南瓜放入榨汁机，制作南瓜汁。",
        GetWay      = "由本地化示例 Mod 添加。",
    },
    ja = {
        DisplayName = "かぼちゃジュース",
        Tutorial    = "かぼちゃをジューサーに入れて、かぼちゃジュースを作ります。",
        GetWay      = "ローカライズ例のModで追加されます。",
    },
}

local function AddLocalizedDrink()
    local World = MOD.Playercontroller:GetWorld()
    local Registry = UE.UBoBaFunction.GetDrinkRegistryWS(World)
    if not Registry then
        if MOD and MOD.Logger then
            MOD.Logger.LogScreen("找不到 UDrinkRegistryWorldSubsystem", 5, 1, 0, 0, 1)
        end
        return
    end

    local Text = DrinkText[CurrentLanguage] or DrinkText.en
    local D = UE.FDrinkData()
    D.ID = 5290
    D.DisplayName = Text.DisplayName
    D.DrinkType = UE.EDrinkType.FruitTea

    -- 全年可售。
    D.Season:Add(UE.EGBSeason.Spring)
    D.Season:Add(UE.EGBSeason.Summer)
    D.Season:Add(UE.EGBSeason.Autumn)
    D.Season:Add(UE.EGBSeason.Winter)

    D.ImagePath = dir .. "5290.png"
    D.Value:Add("S", 8.0)
    D.Value:Add("M", 10.0)
    D.Value:Add("L", 12.0)
    D.DrinkWaterFName = "Drink.PumpkinJuice"

    D.CanSweet = {}
    D.CanSweet:Add("Sweet10")
    D.CanSweet:Add("Sweet7")
    D.CanSweet:Add("Sweet5")
    D.CanSweet:Add("Sweet3")
    D.CanSweet:Add("Sweet0")

    D.CanTemperature = {}
    D.CanTemperature:Add("Hot")
    D.CanTemperature:Add("Normal")
    D.CanTemperature:Add("SmallIce")
    D.CanTemperature:Add("Ice")

    local PerfectNeed = UE.FPerfectNeed()
    PerfectNeed.WaterName = "Drink.PumpkinJuice"
    PerfectNeed.MinPercent = 0.83
    PerfectNeed.MaxPercent = 1.00
    D.PerfectNeed:Add(PerfectNeed)

    D.ShowTutorialsItemID:Add(1106) -- 榨汁机工具
    D.ShowTutorialsItemID:Add(1033) -- 南瓜
    D.MakeNeedTutorialText = Text.Tutorial
    D.ShowGetWayText = Text.GetWay

    D.UnlockedItemID = {}
    D.UnlockedItemID:Add("Pumpkin")

    Registry:RegisterDrinkData(D.ID, D)

    local GameState = UE.UGameplayStatics.GetGameState(World)
    if GameState then
        GameState:EvAddDrink(D.ID)
    end

    if MOD and MOD.Logger then
        MOD.Logger.LogScreen(("Mod [%s] 已注册饮品：%s (%d)"):format(M.name, Text.DisplayName, D.ID), 5, 0, 1, 0, 1)
    end
end

function M.OnInit()
    AddLocalizedDrink()
end

return M
