local M = { id = "NewWaterBucketItem" }

local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "Item registration returned no result")
    end
end

function M.OnLoad(Context)
    local item = Context.Content:MakeItemDefinition()
    item.ContentId = "new_water_bucket_20000"
    item.ItemId = "Mod_NewWaterBucket_20000"
    item.TemplateItemId = "1022"
    item.DisplayName = "MOD 20L 水桶 / MOD 20L Water Bucket"
    item.Description = "独立大容量纯净水桶，可向杯子和容器补水。 / Independent large purified-water bucket."
    item.CategoryTag = "购买.商品.材料"
    item.PurchasePrice = 8
    item.UnlockLevel = 0
    item.bShowInShop = true
    item.ShopSortPriority = -100
    item.bPatchExisting = false

    -- 沿用模板的 Actor、配送箱、图标和其余 Function，无需资源 PAK。
    -- SDK 提供对应未 Cook 源模板；在含父类的匹配 SDK 中 Cook 后才可启用：
    -- item.ActorClassPath = "/Game/Mods/MyWaterBucket/BP_MyWaterBucket.BP_MyWaterBucket_C"

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

    require_success(Context.Content:RegisterItem(item))
    Context:Log("Staged independent water bucket Mod_NewWaterBucket_20000 from template 1022.")
    return true
end

return M
