local M = { id = "AutoStopLiquidContainer100L" }

local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "Auto-stop liquid container registration returned no result")
    end
end

function M.OnLoad(Context)
    local item = Context.Content:MakeItemDefinition()
    item.ContentId = "auto_stop_liquid_container_100l"
    item.ItemId = "Mod_AutoStopLiquidContainer_100000"
    item.TemplateItemId = "3045"
    item.DisplayName = "自停式液体容器（100L）"
    item.Description = "100L（100000mL）自停式液体容器，新购时为空，接满杯子后自动停止。深绿色外壳，保留原大容量自停式容器的模型、配送、自停行为及购买价格和解锁等级；独立商品，不修改原版容器。"
    item.CategoryTag = "购买.商品.材料"
    item.PurchasePrice = -1
    item.UnlockLevel = -1
    item.bShowInShop = true
    item.ShopSortPriority = 0
    item.PreviewImageRelativePath = "icon.png"
    item.bPatchExisting = false

    -- 3045 是原版大容量自停式模板；保留其蓝图、模型、配送与自停逻辑。
    local container = Context.Content:MakeContainerItemSettings()
    container.bOverrideMaxCapacity = true
    container.MaxCapacity = 100000
    container.bOverrideInitialCapacity = true
    container.InitialCapacity = 0
    container.bOverrideOnlyAllowCupAddition = false
    container.bOverrideCupLiquidType = false
    container.bOverrideColor = true
    container.Color = Context.Content:MakeColor(0.012, 0.085, 0.026, 1)
    item.Container = container

    require_success(Context.Content:RegisterItem(item))
    Context:Log("Staged AutoStopLiquidContainer100L: Mod_AutoStopLiquidContainer_100000.")
    return true
end

return M
