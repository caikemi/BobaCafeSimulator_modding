local M = { id = "AppleJuiceBucket20L" }

local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "Apple juice bucket registration returned no result")
    end
end

function M.OnLoad(Context)
    local item = Context.Content:MakeItemDefinition()
    item.ContentId = "apple_juice_bucket_20l"
    item.ItemId = "Mod_AppleJuiceBucket_20000"
    item.TemplateItemId = "1022"
    item.DisplayName = "苹果汁桶（20L）"
    item.Description = "20L（20000mL）苹果汁桶，新购时装满苹果汁，只允许向杯子添加。深绿色外壳，购买价格与解锁等级沿用原版桶装矿泉水；独立商品，不修改原版水桶。"
    item.CategoryTag = "购买.商品.材料"
    item.PurchasePrice = -1
    item.UnlockLevel = -1
    item.bShowInShop = true
    item.ShopSortPriority = 0
    item.PreviewImageRelativePath = "icon.png"
    item.bPatchExisting = false

    -- 沿用原版水桶类、配送方式和其余功能参数，新增独立物品 ID。
    local container = Context.Content:MakeContainerItemSettings()
    container.bOverrideMaxCapacity = true
    container.MaxCapacity = 20000
    container.bOverrideInitialCapacity = true
    container.InitialCapacity = 20000
    container.bOverrideOnlyAllowCupAddition = true
    container.bOnlyAllowCupAddition = true
    container.bOverrideCupLiquidType = true
    container.CupLiquidType = "Drink.AppleJuice"
    container.bOverrideColor = true
    container.Color = Context.Content:MakeColor(0.012, 0.085, 0.026, 1)
    item.Container = container

    require_success(Context.Content:RegisterItem(item))
    Context:Log("Staged AppleJuiceBucket20L: Mod_AppleJuiceBucket_20000.")
    return true
end

return M
