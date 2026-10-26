local M = { id = "NewLiquidContainerItem" }

local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "Item registration returned no result")
    end
end

function M.OnLoad(Context)
    local item = Context.Content:MakeItemDefinition()
    item.ContentId = "new_liquid_container_20000"
    item.ItemId = "Mod_NewLiquidContainer_20000"
    item.TemplateItemId = "3015"
    item.DisplayName = "MOD 20L 液体容器 / MOD 20L Liquid Container"
    item.Description = "独立大容量液体容器，初始为空。 / Independent large liquid container, initially empty."
    item.CategoryTag = "购买.商品.工具"
    item.PurchasePrice = 30
    item.UnlockLevel = 0
    item.bShowInShop = true
    item.ShopSortPriority = -100
    item.bPatchExisting = false

    -- 3015 的真实商店类是 BP_设施3015_水容器_Child，自动保留其初始化和配送配置。
    -- SDK 提供对应未 Cook 源模板；在含父类的匹配 SDK 中 Cook 后才可启用：
    -- item.ActorClassPath = "/Game/Mods/MyLiquidContainer/BP_MyLiquidContainer.BP_MyLiquidContainer_C"

    local container = Context.Content:MakeContainerItemSettings()
    container.bOverrideMaxCapacity = true
    container.MaxCapacity = 20000
    container.bOverrideInitialCapacity = true
    container.InitialCapacity = 0
    -- “只允许给杯子添加”仅水桶支持，液体容器不能启用此覆盖。
    container.bOverrideOnlyAllowCupAddition = false
    container.bOnlyAllowCupAddition = false
    container.bOverrideCupLiquidType = true
    container.CupLiquidType = "Drink.PureWater"
    container.bOverrideColor = true
    container.Color = Context.Content:MakeColor(0.2, 0.6, 1, 1)
    item.Container = container

    require_success(Context.Content:RegisterItem(item))
    Context:Log("Staged independent liquid container Mod_NewLiquidContainer_20000 from template 3015.")
    return true
end

return M
