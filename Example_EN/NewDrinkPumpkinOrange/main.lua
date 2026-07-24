-- AI translation notice: this English example was translated with AI and may
-- contain inaccurate wording. Refer to the matching file under Example_ZH if needed.

-- Required metadata shown in the Mods menu
local M = {
    id          = "NewDrinkPumpkinOrange",
    name        = "Add Pumpkin Orange Recipe",
    description = "Adds a Pumpkin Orange recipe",
    version     = "1.0.0",
    author      = "yiming",

}

local function add_new_drink()
    local World = MOD.Playercontroller:GetWorld()
    local R = UE.UBoBaFunction.GetDrinkRegistryWS(World)
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("Could not find UDrinkRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end
    -- 1) Register the drink data (the override layer takes priority)
    local D = UE.FDrinkData()
    D.ID = 5200  -- Recommended range: 5200-5999
    -- Name
    D.DisplayName = "Pumpkin Orange"
    -- Drink category (FDrinkData defaults to MilkTea, so juice must override it explicitly)
    D.DrinkType = UE.EDrinkType.FruitTea
    -- Available all year
    D.Season:Add(UE.EGBSeason.Spring)
    D.Season:Add(UE.EGBSeason.Summer)
    D.Season:Add(UE.EGBSeason.Autumn)
    D.Season:Add(UE.EGBSeason.Winter)
    -- Image path
    D.ImagePath = dir .. "5200.png" -- An image in your Mod directory

    -- Prices (S/M/L)
    D.Value:Add("S", 8.0)
    D.Value:Add("M", 10.0)
    D.Value:Add("L", 12.0)
    -- Required final liquid type
    D.DrinkWaterFName = "Drink.PumpkinOrange"  -- New liquid type
    -- Required recipe items: four orange slices
    D.NeedItemID:Add(1103)
    D.NeedItemID:Add(1103)
    D.NeedItemID:Add(1103)
    D.NeedItemID:Add(1103)

    -- Sweetness levels customers may order
    D.CanSweet = {}
    D.CanSweet:Add("Sweet10")
    D.CanSweet:Add("Sweet7")
    D.CanSweet:Add("Sweet5")
    D.CanSweet:Add("Sweet3")
    D.CanSweet:Add("Sweet0")

    -- Temperatures customers may order
    D.CanTemperature = {}
    D.CanTemperature:Add("Hot")
    D.CanTemperature:Add("Normal")
    D.CanTemperature:Add("SmallIce")
    D.CanTemperature:Add("Ice")

    -- Perfect-recipe requirements ------------------------------------------
    -- Requires pumpkin juice to make up 0.83-1.00 of the cup
    local PN = UE.FPerfectNeed()
    PN.WaterName  = "Drink.PumpkinJuice"
    PN.MinPercent = 0.83
    PN.MaxPercent = 1.00
    D.PerfectNeed:Add(PN)
    -- Perfect-recipe items: four orange slices
    D.PerfectNeedItem:Add("1103",4)
    ------------------------------------------------------------------

    -- Tutorial icons shown in the recipe bar
    D.ShowTutorialsItemID:Add(1106) -- Juicer
    D.ShowTutorialsItemID:Add(1033) -- Pumpkin
    D.ShowTutorialsItemID:Add(1103) -- Orange slice
    -- Tutorial shown after opening the recipe panel
    D.MakeNeedTutorialText = "Make pumpkin juice, then add four orange slices"

    -- Acquisition method shown after opening the recipe panel
    D.ShowGetWayText = "Obtained from a Mod"

    -- Item types unlocked with the recipe. Available values currently include
    -- Watermelon, Orange, Tea, Pot, Milk, Pumpkin, Boba, PaperCup, and Coffee.
    D.UnlockedItemID = {}
    D.UnlockedItemID:Add("Pumpkin")
    D.UnlockedItemID:Add("Orange")


    -- Single liquid + newly added liquid rule (not needed by this recipe)
    -- 3) Example: pure water + coffee = pumpkin juice (kept commented as an API demonstration)
    ------------------------------------------------------------
    -- R:RegisterCupAddWaterRule(
    --     "Drink.PureWater",    -- CurrentType (liquid already in the cup)
    --     "Drink.Coffee",       -- AddWaterType (newly added liquid)
    --     "Drink.PumpkinJuice"  -- ToWaterType (resulting liquid)
    -- )

    ------------------------------------------------------------
    -- 4) Single liquid + newly added item: pumpkin juice + orange slice = Pumpkin Orange
    ------------------------------------------------------------
    R:RegisterCupAddItemRule(
        "Drink.PumpkinJuice", -- CurrentType (liquid already in the cup)
        "1103",               -- AddItemType (orange slice)
        "Drink.PumpkinOrange" -- ToWaterType (resulting liquid)
    )

    ------------------------------------------------------------
    -- 5) Drink color
    ------------------------------------------------------------
    local S = UE.FDrinkStyle()
    S.DisplayName = "Pumpkin Orange" -- Must match the recipe name
    -- Suggested orange-brown palette (adjustable): light → dark
    S.Color1 = UE.FLinearColor(1.00, 0.58, 0.12, 1.0)  -- Bright orange-brown
    S.Color2 = UE.FLinearColor(1.00, 0.58, 0.12, 1.0)  -- Bright orange-brown
    R:RegisterDrinkStyle("Drink.PumpkinOrange", S) -- Use the drink's liquid type


    -- Register with the override system
    R:RegisterDrinkData(D.ID, D)

    -- Add directly to the existing recipe list without an unlock requirement
    local GS = UE.UGameplayStatics.GetGameState(World) or nil  -- AGameStateBase*
    if GS then
        GS:EvAddDrink(D.ID)
    end

    if MOD and MOD.Logger then MOD.Logger.LogScreen("Registered: Pumpkin Orange (5200)", 5,0,1,0,1) end -- Log
end


function M.OnInit()
    -- Initialize
    if MOD and MOD.Logger then MOD.Logger.LogScreen(("Mod [%s] is loading"):format(M.name), 5,1,1,0,1) end -- Log
    add_new_drink()
end

return M
-- Appendix: current liquid/drink ID, name, and color table
-- Format: ID / Name / Color1 RGBA / Color2 RGBA
-- ID 0 entries from the log are preserved as recorded
-- ID:0 Name:Syrup Color1:R=1 G=0.857 B=0.078 A=1 Color2:R=1 G=0.907 B=0.143 A=1
-- ID:0 Name:Pumpkin Juice Color1:R=0.644 G=0.28 B=0 A=1 Color2:R=0.585 G=0.275 B=0 A=1
-- ID:0 Name:Baked Milk Color1:R=0.637 G=0.861 B=0.765 A=1 Color2:R=0.852 G=0.798 B=0.616 A=1
-- ID:0 Name:Pineapple Juice Color1:R=1 G=0.678 B=0 A=1 Color2:R=1 G=0.887 B=0 A=1
-- ID:0 Name:Jackfruit Juice Color1:R=1 G=0.816 B=0.233 A=1 Color2:R=1 G=0.902 B=0.291 A=1
-- ID:0 Name:Apple Juice Color1:R=0.9 G=0.599 B=0.245 A=1 Color2:R=0.8 G=0.506 B=0.194 A=1
-- ID:0 Name:Peach Juice Color1:R=1 G=0.321 B=0.465 A=1 Color2:R=1 G=0.431 B=0.58 A=1
-- ID:0 Name:Mango Juice Color1:R=1 G=0.643 B=0 A=1 Color2:R=1 G=0.539 B=0 A=1
-- ID:0 Name:Banana Juice Color1:R=1 G=0.871 B=0 A=1 Color2:R=1 G=0.792 B=0 A=1
-- ID:0 Name:Strawberry Juice Color1:R=1 G=0.168 B=0.258 A=1 Color2:R=1 G=0.161 B=0.193 A=1
-- ID:0 Name:Pomegranate Juice Color1:R=0.8 G=0.074 B=0.092 A=1 Color2:R=0.599 G=0.066 B=0.066 A=1
-- ID:0 Name:Coconut Milk Color1:R=1 G=1 B=1 A=1 Color2:R=1 G=1 B=1 A=1
-- ID:0 Name:Fruit Jelly Juice Color1:R=0.021 G=0.9 B=0.032 A=1 Color2:R=0.198 G=1 B=0.061 A=1
-- ID:0 Name:Magma Jelly Juice Color1:R=1 G=0.11 B=0.453 A=1 Color2:R=1 G=0.102 B=0.202 A=1
-- ID:0 Name:Ghost Water Color1:R=0.8 G=0.9 B=1 A=0.5 Color2:R=0.7 G=0.95 B=1 A=1
-- ID:0 Name:Rusty Iron Water Color1:R=0.5 G=0.205 B=0.153 A=0.7 Color2:R=0.432 G=0.275 B=0.17 A=1
-- ID:0 Name:Hot Water Color1:R=0.382 G=0.965 B=1 A=1 Color2:R=0.622 G=0.866 B=0.96 A=1
-- ID:0 Name:Purified Water Color1:R=0.311 G=0.848 B=1 A=1 Color2:R=0.624 G=0.863 B=0.956 A=1
-- ID:0 Name:Sashimi Green Tea Color1:R=0.553 G=0.564 B=0.128 A=1 Color2:R=0.408 G=0.46 B=0.11 A=1
-- ID:0 Name:Yogurt Color1:R=0.95 G=0.95 B=0.716 A=1 Color2:R=1 G=1 B=0.859 A=1
-- ID:5001 Name:Lemon Water Color1:R=1 G=0.604 B=0.049 A=1 Color2:R=1 G=0.604 B=0.049 A=1
-- ID:5002 Name:Watermelon Juice Color1:R=0.672 G=0.08 B=0.071 A=1 Color2:R=0.672 G=0.064 B=0.055 A=1
-- ID:5003 Name:Smashed Fresh Orange Color1:R=0.991 G=0.391 B=0.047 A=1 Color2:R=0.964 G=0.391 B=0.094 A=1
-- ID:5006 Name:Fresh-Squeezed Orange Juice Color1:R=1 G=0.261 B=0 A=1 Color2:R=1 G=0.226 B=0 A=1
-- ID:5005 Name:Milk Color1:R=1 G=0.967 B=0.905 A=1 Color2:R=1 G=0.972 B=0.918 A=1
-- ID:5007 Name:Green Tea Color1:R=0.223 G=0.297 B=0.086 A=1 Color2:R=0.234 G=0.31 B=0.095 A=1
-- ID:5014 Name:Hot Coffee Color1:R=0.05 G=0.014 B=0.004 A=1 Color2:R=0.068 G=0.019 B=0.005 A=1
-- ID:5032 Name:Milk Tea Color1:R=0.356 G=0.212 B=0.09 A=1 Color2:R=0.373 G=0.191 B=0.037 A=1
-- ID:5008 Name:Lemon Green Tea Color1:R=0.553 G=0.564 B=0.128 A=1 Color2:R=0.408 G=0.46 B=0.11 A=1
-- ID:5009 Name:Watermelon Iced Tea Color1:R=0.701 G=0.286 B=0.196 A=1 Color2:R=0.701 G=0.296 B=0.216 A=1
-- ID:5011 Name:Watermelon Fruit Milk Color1:R=1 G=0.422 B=0.246 A=1 Color2:R=1 G=0.455 B=0.27 A=1
-- ID:5013 Name:Orange Lemon Color1:R=1 G=0.836 B=0.155 A=1 Color2:R=1 G=0.63 B=0.097 A=1
-- ID:5015 Name:Pumpkin Tea Color1:R=0.401 G=0.21 B=0.059 A=1 Color2:R=0.46 G=0.242 B=0.015 A=1
-- ID:5016 Name:Pumpkin Milk Color1:R=0.661 G=0.504 B=0.24 A=1 Color2:R=0.627 G=0.395 B=0.179 A=1
-- ID:5019 Name:Taro Ball Milk Tea Color1:R=0.453 G=0.265 B=0.321 A=1 Color2:R=0.353 G=0.266 B=0.411 A=1
-- ID:5020 Name:Jasmine Milk Green Tea Color1:R=0.695 G=0.7 B=0.303 A=1 Color2:R=0.779 G=0.95 B=0.437 A=1
-- ID:5021 Name:Taro Paste Milk Tea Color1:R=0.516 G=0.397 B=0.595 A=1 Color2:R=0.76 G=0.574 B=0.365 A=1
-- ID:5022 Name:Taro Paste Boba Color1:R=0.576 G=0.454 B=0.658 A=1 Color2:R=0.658 G=0.378 B=0.44 A=1
-- ID:5023 Name:Pudding Milk Tea Color1:R=0.668 G=0.475 B=0.256 A=1 Color2:R=0.714 G=0.615 B=0.172 A=1
-- ID:5024 Name:Ao-Ao Milk Tea Color1:R=0.484 G=0.34 B=0.177 A=1 Color2:R=0.391 G=0.318 B=0.276 A=1
-- ID:5025 Name:Red Bean Milk Tea Color1:R=0.717 G=0.411 B=0.214 A=1 Color2:R=0.568 G=0.338 B=0.338 A=1
-- ID:5026 Name:Red Bean Milk Pudding Color1:R=0.716 G=0.381 B=0.16 A=1 Color2:R=0.565 G=0.337 B=0.337 A=1
-- ID:5027 Name:Double-Topping Milk Tea Color1:R=0.356 G=0.212 B=0.089 A=1 Color2:R=0.371 G=0.191 B=0.037 A=1
-- ID:5028 Name:Coconut Jelly Milk Tea Color1:R=0.76 G=0.6 B=0.42 A=1 Color2:R=0.9 G=0.9 B=0.95 A=1
-- ID:5029 Name:Supreme Triple-Topping Milk Tea Color1:R=0.76 G=0.6 B=0.42 A=1 Color2:R=0.1 G=0.1 B=0.1 A=1
-- ID:5030 Name:Cheese-Foam Milk Tea Color1:R=0.6 G=0.7 B=0.4 A=1 Color2:R=1 G=0.98 B=0.9 A=1
-- ID:5031 Name:Ao-Ao Cheese Milk Tea Color1:R=0.761 G=0.597 B=0.418 A=1 Color2:R=0.543 G=0.405 B=0.358 A=1
-- ID:5033 Name:Red Date and Longan Warm Milk Tea Color1:R=0.6 G=0.239 B=0.149 A=1 Color2:R=0.741 G=0.567 B=0.218 A=1
-- ID:5034 Name:Brown Sugar Boba Milk Tea Color1:R=0.356 G=0.212 B=0.089 A=1 Color2:R=0.523 G=0.327 B=0.21 A=1
-- ID:5035 Name:Baked-Milk Tea Color1:R=1 G=0.965 B=0.905 A=1 Color2:R=0.685 G=0.95 B=0.662 A=1
-- ID:5036 Name:Watermelon Boba Color1:R=1 G=0.3 B=0.35 A=1 Color2:R=1 G=0.9 B=0.9 A=1
-- ID:5037 Name:Taro Ball Grape Color1:R=0.45 G=0.25 B=0.55 A=1 Color2:R=0.65 G=0.5 B=0.75 A=1
-- ID:5038 Name:Full-Cup Passion Fruit Color1:R=0.9 G=0.8 B=0.2 A=1 Color2:R=0.429 G=0.502 B=0.283 A=1
-- ID:5039 Name:Pineapple Jackfruit Color1:R=0.95 G=0.9 B=0.1 A=1 Color2:R=1 G=0.8 B=0.2 A=1
-- ID:5040 Name:Apple Peach Color1:R=1 G=0.7 B=0.75 A=1 Color2:R=0.9 G=0.8 B=0.4 A=1
-- ID:5041 Name:Peach Mango Color1:R=0.97 G=0.726 B=0.767 A=1 Color2:R=1 G=0.82 B=0.387 A=1
-- ID:5042 Name:Blueberry Fruit Tea Color1:R=0.259 G=0.233 B=0.5 A=1 Color2:R=0.285 G=0.215 B=0.4 A=1
-- ID:5043 Name:Peach Nectar Color1:R=1 G=0.623 B=0.686 A=1 Color2:R=0.981 G=1 B=0.634 A=1
-- ID:5044 Name:Peach Green Tea Color1:R=0.6 G=0.7 B=0.4 A=1 Color2:R=1 G=0.7 B=0.75 A=1
-- ID:5045 Name:Passion Fruit Pineapple Color1:R=1 G=0.768 B=0.21 A=1 Color2:R=0.794 G=0.964 B=0.775 A=1
-- ID:5046 Name:Jasmine Green Grape Color1:R=0.65 G=0.85 B=0.35 A=1 Color2:R=0.6 G=0.7 B=0.4 A=1
-- ID:5047 Name:Mint Green Tea Color1:R=0.2 G=0.8 B=0.5 A=1 Color2:R=0.6 G=0.7 B=0.4 A=1
-- ID:5048 Name:Pomegranate Juice Color1:R=0.8 G=0.1 B=0.15 A=1 Color2:R=0.9 G=0.2 B=0.25 A=1
-- ID:5049 Name:Grape Jelly Color1:R=0.45 G=0.25 B=0.55 A=1 Color2:R=1 G=0.7 B=0.98 A=0.5
-- ID:5050 Name:Fresh Mango Passion Fruit Color1:R=1 G=0.783 B=0.262 A=1 Color2:R=0.915 G=0.965 B=0.571 A=1
-- ID:5051 Name:Green Plum Iced Tea Color1:R=0.5 G=0.6 B=0.2 A=1 Color2:R=0.8 G=0.7 B=0.4 A=1
-- ID:5052 Name:Sunshine Green Grape Color1:R=0.65 G=0.85 B=0.35 A=1 Color2:R=0.9 G=0.95 B=0.8 A=1
-- ID:5053 Name:Super Fruit Tea Color1:R=0.9 G=0.5 B=0.2 A=1 Color2:R=0.8 G=0.9 B=0.2 A=1
-- ID:5054 Name:Honey Pomelo Tea Color1:R=0.95 G=0.7 B=0.1 A=1 Color2:R=1 G=0.882 B=0.29 A=1
-- ID:5055 Name:Latte Color1:R=0.35 G=0.2 B=0.1 A=1 Color2:R=0.398 G=0.272 B=0.187 A=1
-- ID:5056 Name:Coconut Latte Color1:R=0.429 G=0.264 B=0.153 A=1 Color2:R=0.397 G=0.286 B=0.213 A=1
-- ID:5057 Name:Grape Americano Color1:R=0.061 G=0.013 B=0.025 A=1 Color2:R=0.068 G=0.019 B=0.005 A=1
-- ID:5058 Name:Jasmine Latte Color1:R=0.397 G=0.27 B=0.188 A=1 Color2:R=0.499 G=0.582 B=0.332 A=1
-- ID:5059 Name:Apple Latte Color1:R=0.397 G=0.285 B=0.211 A=1 Color2:R=0.967 G=0.588 B=0.505 A=1
-- ID:5060 Name:Orange Americano Color1:R=0.151 G=0.073 B=0.037 A=1 Color2:R=0.148 G=0.084 B=0.021 A=1
-- ID:5061 Name:Butter Latte Color1:R=0.397 G=0.27 B=0.188 A=1 Color2:R=0.509 G=0.446 B=0.227 A=1
-- ID:5062 Name:Peach Latte Color1:R=0.397 G=0.27 B=0.188 A=1 Color2:R=0.564 G=0.395 B=0.423 A=1
-- ID:5063 Name:Mango Milk Color1:R=1 G=0.767 B=0.207 A=1 Color2:R=0.832 G=0.832 B=0.576 A=1
-- ID:5064 Name:Coconut Mango Pomelo Sago Color1:R=1 G=0.735 B=0.099 A=1 Color2:R=0.95 G=0.95 B=0.602 A=1
-- ID:5065 Name:Mango Pomelo Sago Color1:R=1 G=0.738 B=0.1 A=1 Color2:R=0.947 G=0.947 B=0.386 A=1
-- ID:5066 Name:Peach Gum Milk Color1:R=0.95 G=0.95 B=0.572 A=1 Color2:R=0.88 G=0.668 B=0.243 A=1
-- ID:5067 Name:Watermelon Coconut Color1:R=1 G=0.3 B=0.35 A=1 Color2:R=0.95 G=0.95 B=0.744 A=1
-- ID:5068 Name:Coconut Lemon Milk Color1:R=0.95 G=0.95 B=0.562 A=1 Color2:R=0.95 G=0.898 B=0.173 A=1
-- ID:5069 Name:Taro Ball Coconut Color1:R=0.95 G=0.95 B=0.92 A=1 Color2:R=0.658 G=0.52 B=0.75 A=1
-- ID:5070 Name:Mango Sago Color1:R=1 G=0.75 B=0.15 A=1 Color2:R=1 G=0.845 B=0.509 A=1
-- ID:5071 Name:Avocado Sago Color1:R=0.56 G=0.75 B=0.306 A=1 Color2:R=0.985 G=1 B=0.634 A=1
-- ID:5072 Name:Brown Sugar Boba Milk Tea Color1:R=0.762 G=0.428 B=0.263 A=1 Color2:R=0.55 G=0.304 B=0.181 A=1
-- ID:5073 Name:Glowing Lemon Water Color1:R=0.867 G=1 B=0.172 A=1 Color2:R=0.675 G=1 B=0.178 A=1
-- ID:5074 Name:Mandrake Green Tea Color1:R=0.066 G=0.65 B=0.155 A=1 Color2:R=0.245 G=0.6 B=0.191 A=1
-- ID:5075 Name:Magma Watermelon Tentacles Color1:R=0.95 G=0 B=0.012 A=1 Color2:R=1 G=0.278 B=0.12 A=1
-- ID:5076 Name:Glowing Mandrake Lemon Color1:R=0.153 G=1 B=0.118 A=1 Color2:R=0.472 G=0.8 B=0.038 A=1
-- ID:5077 Name:Ghost Baked Milk Color1:R=0.8 G=0.723 B=0.517 A=1 Color2:R=0.439 G=0.907 B=1 A=1
-- ID:5078 Name:Rust Green Tea Color1:R=0.14 G=0.5 B=0.151 A=1 Color2:R=0.439 G=0.22 B=0.073 A=1
-- ID:5079 Name:Ghost Mandrake Color1:R=0.582 G=1 B=0.835 A=1 Color2:R=0.109 G=0.5 B=0.123 A=1
-- ID:5080 Name:Rusty Peach Color1:R=0.832 G=0.443 B=0.443 A=1 Color2:R=0.432 G=0.21 B=0.062 A=1
-- ID:5081 Name:Ghost Mango Color1:R=1 G=0.633 B=0.119 A=1 Color2:R=0.345 G=0.891 B=1 A=1
-- ID:5082 Name:Dried-Bat Americano Color1:R=0.273 G=0.151 B=0.076 A=1 Color2:R=0.047 G=0.047 B=0.047 A=1
-- ID:5083 Name:Abyss Green Tea Color1:R=0.408 G=0.65 B=0.166 A=1 Color2:R=0.7 G=0.442 B=0.425 A=1
-- ID:5084 Name:Will-o'-the-Wisp Baked Milk Color1:R=1 G=0.892 B=0.664 A=1 Color2:R=1 G=0.068 B=0.064 A=1
-- ID:5085 Name:Spider Cave Ghost Water Color1:R=0.394 G=0.85 B=0.787 A=1 Color2:R=0.154 G=1 B=0.323 A=1
-- ID:5086 Name:Cthulhu Tentacle Cup Color1:R=0.1 G=0.3 B=0.25 A=1 Color2:R=0.6 G=0 B=0.8 A=1
-- ID:5087 Name:Spider Cave Grape Tea Color1:R=0.343 G=0.074 B=0.45 A=1 Color2:R=0.418 G=0.9 B=0.489 A=1
-- ID:5088 Name:Bat Coconut Color1:R=0.61 G=1 B=0.911 A=1 Color2:R=0.095 G=0.06 B=0.025 A=1
-- ID:5089 Name:Ghost Milk with Taro Balls Color1:R=0.622 G=0.471 B=0.85 A=1 Color2:R=0.366 G=0.951 B=1 A=1
-- ID:5090 Name:Ice and Fire Duet Color1:R=0 G=0.543 B=1 A=1 Color2:R=1 G=0.005 B=0 A=1
-- ID:5091 Name:Mandrake Mutant Watermelon Juice Color1:R=0.8 G=0.2 B=0.4 A=1 Color2:R=0.48 G=1 B=0.415 A=1
-- ID:5092 Name:Dirty Mushroom Tea Color1:R=0.227 G=0.096 B=0.04 A=1 Color2:R=0.5 G=0.316 B=0.171 A=1
-- ID:5093 Name:Jelly Slime Baked Milk Color1:R=0 G=1 B=0.031 A=1 Color2:R=0.219 G=0.9 B=0.347 A=1
-- ID:5094 Name:Toxic Swamp Lemon Water Color1:R=0.863 G=1 B=0.108 A=1 Color2:R=0.887 G=0.402 B=1 A=1
-- ID:5095 Name:Gaze of the Abyss Color1:R=0.5 G=0 B=1 A=1 Color2:R=0.98 G=0.127 B=1 A=1
-- ID:5096 Name:Magma Lava Drink Color1:R=1 G=0.003 B=0 A=1 Color2:R=0.1 G=0.021 B=0 A=1
-- ID:5097 Name:Bat Latte Color1:R=0.373 G=0.267 B=0.183 A=1 Color2:R=0.18 G=0.1 B=0.05 A=1
-- ID:5098 Name:Dark Spore Latte Color1:R=0.175 G=0.112 B=0.081 A=1 Color2:R=0.447 G=0.162 B=0.7 A=1
-- ID:5099 Name:Bat Wasteland Milk Tea Color1:R=1 G=1 B=1 A=1 Color2:R=1 G=1 B=1 A=1
-- ID:5100 Name:Swamp Jelly Color1:R=0.2 G=0.3 B=0.2 A=1 Color2:R=0.2 G=1 B=0.1 A=1
-- ID:5101 Name:Infernal Bitter Water Color1:R=0 G=0 B=0 A=1 Color2:R=1 G=0.3 B=0 A=1
-- ID:5102 Name:Hallucinogenic Mushroom Milk Color1:R=0.8 G=0.4 B=0.8 A=1 Color2:R=0 G=0.5 B=1 A=1
-- ID:5103 Name:Abyssal Trap Honey Brew Color1:R=0.079 G=0 B=0.1 A=1 Color2:R=0.926 G=1 B=0 A=1
-- ID:5104 Name:Void Black Hole Color1:R=0 G=0.017 B=1 A=1 Color2:R=0.007 G=0 B=0.5 A=1
-- ID:5105 Name:Galactic Stardust Dew Color1:R=0 G=0.471 B=1 A=1 Color2:R=0.309 G=0 B=1 A=1
-- ID:5106 Name:Philosopher's Stone Special Color1:R=0.7 G=0.138 B=0.001 A=1 Color2:R=0.546 G=1 B=0 A=1
-- ID:5108 Name:Premium Cherry Juice Color1:R=0.7 G=0.1 B=0.15 A=1 Color2:R=0.7 G=0.1 B=0.15 A=1
-- ID:5107 Name:Ruby Orange Juice Color1:R=0.95 G=0.35 B=0.1 A=1 Color2:R=1 G=0.6 B=0.05 A=1
-- ID:5109 Name:Lucky Red Milk Color1:R=0.92 G=0.75 B=0.8 A=1 Color2:R=0.96 G=0.96 B=0.92 A=1
-- ID:5110 Name:Candied Hawthorn Americano Color1:R=0.18 G=0.1 B=0.05 A=1 Color2:R=0.85 G=0.1 B=0.1 A=1
-- ID:5111 Name:Firecracker Milk Tea Color1:R=0.65 G=0.75 B=0.55 A=1 Color2:R=1 G=0.2 B=0.2 A=1
-- ID:5112 Name:Explosive Red Cherry Color1:R=0.7 G=0.05 B=0.15 A=1 Color2:R=1 G=0.2 B=0.2 A=1
-- ID:5113 Name:Explosive Candied Hawthorn Color1:R=0.7 G=0.05 B=0.15 A=1 Color2:R=0.85 G=0.1 B=0.1 A=1
-- ID:5114 Name:Banana Milk Color1:R=0.982 G=0.807 B=0.371 A=1 Color2:R=0.982 G=0.807 B=0.371 A=1
-- ID:5115 Name:Strawberry Milk Color1:R=0.991 G=0.479 B=0.474 A=1 Color2:R=0.991 G=0.815 B=0.753 A=1
-- ID:5116 Name:Mint Chocolate Latte Color1:R=0.558 G=0.397 B=0.216 A=1 Color2:R=0.716 G=0.839 B=0.658 A=1
-- ID:5117 Name:Apple Jasmine Color1:R=0.839 G=0.839 B=0.515 A=1 Color2:R=0.839 G=0.831 B=0.509 A=1
-- ID:5118 Name:Banana Latte Color1:R=0.88 G=0.571 B=0.216 A=1 Color2:R=0.982 G=0.839 B=0.558 A=1
-- ID:5119 Name:Banana Green Tea Color1:R=0.597 G=0.624 B=0.153 A=1 Color2:R=0.839 G=0.839 B=0.434 A=1
-- ID:5120 Name:Super Yogurt Bowl Color1:R=1 G=1 B=1 A=1 Color2:R=1 G=1 B=1 A=1
-- ID:5121 Name:Strawberry Yogurt Color1:R=0.982 G=0.672 B=0.651 A=1 Color2:R=0.973 G=0.905 B=0.847 A=1
-- ID:5122 Name:Banana Yogurt Color1:R=0.991 G=0.913 B=0.651 A=1 Color2:R=0.991 G=0.913 B=0.651 A=1
-- ID:5123 Name:Mint Milk Green Tea Color1:R=0.223 G=0.497 B=0.086 A=1 Color2:R=0.552 G=0.694 B=0.301 A=1
-- ID:5124 Name:Jasmine Green Tea Color1:R=0.73 G=0.768 B=0.258 A=1 Color2:R=0.738 G=0.784 B=0.275 A=1
-- ID:5125 Name:Red Apple Milk Green Tea Color1:R=0.665 G=0.745 B=0.279 A=1 Color2:R=0.88 G=0.896 B=0.701 A=1
-- ID:5126 Name:Apple Milk Color1:R=0.991 G=0.871 B=0.565 A=1 Color2:R=0.991 G=0.905 B=0.658 A=1
-- Appendix: current topping ID table
-- 1102 Lemon Slice
-- 1103 Orange Slice
-- 1105 Purified Water Tool
-- 1106 Juicer Tool
-- 1107 Boba
-- 1108 Receipt
-- 7001 Taro Ball
-- 7002 Jasmine Jam
-- 7003 Taro Paste
-- 7004 Popping Boba
-- 7005 Pudding
-- 7006 Ao-Ao
-- 7007 Peach Gum
-- 7008 Purple Rice
-- 7009 Diced Mango
-- 7010 Diced Avocado
-- 7011 Diced Peach
-- 7012 Diced Pineapple
-- 7013 Blueberry
-- 7014 Butter
-- 7015 Red Bean
-- 7016 Brown Sugar
-- 7017 Jelly
-- 7018 Pomelo Pulp
-- 7019 Green Plum
-- 7020 Honey
-- 7021 Passion Fruit
-- 7022 Cheese Foam
-- 7023 Dried Red Date
-- 7024 Dried Longan
-- 7025 Coconut Jelly
-- 7026 Peeled Green Grape
-- 7027 Peeled Grape
-- 7028 Mint
-- 7029 Sago
-- 7030 Glowing Lemon Slice
-- 7031 Graveyard Mushroom
-- 7032 Dried Bat
-- 7033 Mandrake Slice
-- 7034 Spider Silk
-- 7035 Eye of the Abyss
-- 7036 Magma Tentacle Slice
-- 7037 Philosopher's Stone
-- 7038 Will-o'-the-Wisp
-- 7039 Star Prism
-- 7040 Jelly Slime
-- 7041 Magma Jelly Slime
-- 7042 Ghost Water
-- 7043 Rusty Iron Water
-- 7044 Firecracker
-- 7045 Candied Hawthorn
-- 7046 Cupid Syrup
-- 7047 Taste-Amnesia Powder
-- 7048 Perfect-Filter Flavoring
-- 7049 Sashimi
-- 7050 Skeleton Fishbone Powder
-- 7051 Chocolate

-- Appendix: tutorial icon ID table (deduplicated from the recipe log)
-- 1004 Watermelon
-- 1005 Orange
-- 1007 Milk
-- 1008 Green Tea
-- 1010 Cooking Pot
-- 1012 Juicer
-- 1028 Grinder
-- 1029 Coffee Beans
-- 1030 Coffee Brewer
-- 1033 Pumpkin
-- 1036 Apple
-- 1040 Peach
-- 1045 Strawberry
-- 1047 Pineapple
-- 1054 Banana
-- 1092 Jackfruit
-- 1093 Mango
-- 1094 Pomegranate
-- 1105 Purified Water Tool
-- 1106 Juicer Tool
-- 1116 Coconut Milk
-- 1142 Centrifuge
-- 1143 Premium 8J Cherry
-- 1175 Yogurt Maker
-- 3033 Infusion Device
