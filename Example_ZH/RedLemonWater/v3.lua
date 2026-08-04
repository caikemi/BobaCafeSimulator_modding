local M = {
    id = "RedLemonWater",
}

function M.OnLoad(Context)
    local style = Context.Content:MakeDrinkStyleDefinition()
    style.ContentId = "red_lemon_water_style"
    style.LiquidId = "Drink.LemonWater"
    style.PrimaryColor = Context.Content:MakeColor(1.0, 0.0, 0.0, 1.0)
    style.SecondaryColor = Context.Content:MakeColor(1.0, 0.0, 0.0, 1.0)
    style.bPatchExisting = true

    local result = Context.Content:RegisterDrinkStyle(style)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "Could not stage lemon-water style patch")
    end

    Context:Log("Staged reversible red LemonWater style patch.")
    return true
end

return M
