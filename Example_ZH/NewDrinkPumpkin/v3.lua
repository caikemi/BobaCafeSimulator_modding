local M = {
    id = "NewDrinkPumpkin",
}

local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "ModAPI returned no result")
    end
end

function M.OnLoad(Context)
    local drink = Context.Content:MakeDrinkDefinition()
    drink.ContentId = "pumpkin_juice_recipe"
    drink.DrinkId = 5201
    drink.DisplayName = "南瓜汁"
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
    drink.TutorialText = "榨汁南瓜汁"
    drink.AcquisitionText = "MOD获得"
    drink.UnlockedItemGroups:Add("Pumpkin")

    require_success(Context.Content:RegisterDrink(drink))
    Context:Log("Staged pumpkin juice recipe 5201.")
    return true
end

return M
