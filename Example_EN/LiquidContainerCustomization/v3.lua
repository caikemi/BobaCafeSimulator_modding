local M = {
    id = "LiquidContainerCustomization",
}

-- 使用容器原来的容量单位；设为 0 时保留原容量。
local MAX_CAPACITY = 20000

local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "Liquid container registration returned no result")
    end
end

function M.OnLoad(Context)
    local container = Context.Content:MakeLiquidContainerDefinition()
    container.ContentId = "liquid_container_customization"
    container.MaxCapacity = MAX_CAPACITY
    -- 只改 StaticMesh 第 0 个材质槽的向量参数 Param，无需额外资源 PAK。
    container.bOverrideMaterialParam = true
    container.MaterialParam = Context.Content:MakeColor(1, 0.2, 0.1, 1)

    require_success(Context.Content:RegisterLiquidContainer(container))
    Context:Log("Staged liquid container customization; the host applies it when this mod commits.")
    return true
end

return M
