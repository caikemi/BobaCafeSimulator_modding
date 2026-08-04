local M = {
    id = "NewDrinkPumpkinOrange",
}

local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "ModAPI returned no result")
    end
end

function M.OnLoad(Context)
    local drink = Context.Content:MakeDrinkDefinition()
    drink.ContentId = "pumpkin_orange_recipe"
    drink.DrinkId = 5200
    drink.DisplayName = "Pumpkin Orange"
    drink.DrinkType = "FruitTea"
    drink.ImageRelativePath = "5200.png"
    drink.SmallPrice = 8
    drink.MediumPrice = 10
    drink.LargePrice = 12
    drink.OutputLiquidId = "Drink.PumpkinOrange"
    drink.RequiredItemIds:Add(1103)
    drink.RequiredItemIds:Add(1103)
    drink.RequiredItemIds:Add(1103)
    drink.RequiredItemIds:Add(1103)

    local perfect = Context.Content:MakeLiquidRatioDefinition()
    perfect.LiquidId = "Drink.PumpkinJuice"
    perfect.MinRatio = 0.83
    perfect.MaxRatio = 1.0
    drink.PerfectLiquids:Add(perfect)
    drink.PerfectItems:Add("1103", 4)

    drink.TutorialItemIds:Add(1106)
    drink.TutorialItemIds:Add(1033)
    drink.TutorialItemIds:Add(1103)
    drink.TutorialText = "Juice the pumpkin, then add four orange slices."
    drink.AcquisitionText = "Obtained from a mod"
    drink.UnlockedItemGroups:Add("Pumpkin")
    drink.UnlockedItemGroups:Add("Orange")
    require_success(Context.Content:RegisterDrink(drink))

    local rule = Context.Content:MakeCupAddItemRuleDefinition()
    rule.ContentId = "pumpkin_juice_plus_orange"
    rule.CurrentLiquidId = "Drink.PumpkinJuice"
    rule.AddedItemId = "1103"
    rule.ResultLiquidId = "Drink.PumpkinOrange"
    require_success(Context.Content:RegisterCupAddItemRule(rule))

    local style = Context.Content:MakeDrinkStyleDefinition()
    style.ContentId = "pumpkin_orange_style"
    style.LiquidId = "Drink.PumpkinOrange"
    style.DrinkId = 5200
    style.DisplayName = "Pumpkin Orange"
    style.PrimaryColor = Context.Content:MakeColor(1.0, 0.58, 0.12, 1.0)
    style.SecondaryColor = Context.Content:MakeColor(1.0, 0.58, 0.12, 1.0)
    require_success(Context.Content:RegisterDrinkStyle(style))

    Context:Log("Staged pumpkin orange recipe, cup rule, and style.")
    return true
end

return M
