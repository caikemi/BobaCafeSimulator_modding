-- 必填信息：会显示在 Mods 界面
local M = {
    id          = "NewDrinkPumpkin",
    name        = "增加配方南瓜汁",
    description = "增加配方南瓜汁",
    version     = "1.0.0",
    author      = "yiming",

}

local function add_new_drink()
    local World = MOD.Playercontroller:GetWorld()
    local R = UE.UBoBaFunction.GetDrinkRegistryWS(World)
    if not R then
        if MOD and MOD.Logger then MOD.Logger.LogScreen("找不到 UDrinkRegistryWorldSubsystem", 5,1,0,0,1) end
        return
    end
    -- 1) 注册饮品数据（覆盖层优先）
    local D = UE.FDrinkData()
    D.ID = 5201  --建议使用5200-5999
    --名称
    D.DisplayName = "南瓜汁"
    --饮品类型（FDrinkData 默认是 MilkTea，果汁需要显式覆盖）
    D.DrinkType = UE.EDrinkType.FruitTea
    --可售季节：全年
    D.Season:Add(UE.EGBSeason.Spring)
    D.Season:Add(UE.EGBSeason.Summer)
    D.Season:Add(UE.EGBSeason.Autumn)
    D.Season:Add(UE.EGBSeason.Winter)
    --图片路径
    D.ImagePath = dir .. "5201.png" --你的Mod目录的图片

    -- 价格（S/M/L）
    D.Value:Add("S", 8.0)
    D.Value:Add("M", 10.0)
    D.Value:Add("L", 12.0)
    -- 配方里完成需要的水类型
    D.DrinkWaterFName = "Drink.PumpkinJuice"  --新的液体类型
    -- 配方里完成需要的物品 比如四个橙子片
    -- D.NeedItemID:Add(1103)
    -- D.NeedItemID:Add(1103)
    -- D.NeedItemID:Add(1103)
    -- D.NeedItemID:Add(1103)

    -- 客户会点的甜度
    D.CanSweet = {}
    D.CanSweet:Add("Sweet10")
    D.CanSweet:Add("Sweet7")
    D.CanSweet:Add("Sweet5")
    D.CanSweet:Add("Sweet3")
    D.CanSweet:Add("Sweet0")

    -- 客户会点的温度
    D.CanTemperature = {}
    D.CanTemperature:Add("Hot")
    D.CanTemperature:Add("Normal")
    D.CanTemperature:Add("SmallIce")
    D.CanTemperature:Add("Ice")

    -- 完美需求 -----------------------------------------------------------
    --（需要南瓜汁>0.83-1.00）
    local PN = UE.FPerfectNeed()
    PN.WaterName  = "Drink.PumpkinJuice"
    PN.MinPercent = 0.83
    PN.MaxPercent = 1.00
    D.PerfectNeed:Add(PN)
    -- 完美配方需求物品  橙子片4个
    -- D.PerfectNeedItem:Add("1103",4)
    ------------------------------------------------------------------

    --提示图标 配方栏的那个小图标
    D.ShowTutorialsItemID:Add(1106) --榨汁机
    D.ShowTutorialsItemID:Add(1033) --南瓜
    -- D.ShowTutorialsItemID:Add(1103) --橙子片
    --教程 配方界面点开后显示的教程
    D.MakeNeedTutorialText = "榨汁南瓜汁"

    -- 显示获取方式 配方界面点开后显示的解锁方式
    D.ShowGetWayText = "MOD获得"

    --获得配方之后解锁的物品类型 目前有 Watermelon(西瓜) Orange(橙子) Tea(茶) Pot(煮东西相关）
    --Milk(奶相关 大瓶一箱奶) Pumpkin(南瓜) Boba(珍珠) PaperCup(纸杯,热的需要) Coffee(奶茶)
    D.UnlockedItemID = {}
    D.UnlockedItemID:Add("Pumpkin")
    -- D.UnlockedItemID:Add("Orange")


    --两种液体混合模式（这个配方不需要）：
    -- 3) （其他）加“加液体后变化”的规则：纯净水 + 咖啡= 南瓜汁 （开玩笑的加法） 目前配方不需要
    -- ------------------------------------------------------------
    -- R:RegisterCupAddWaterRule(
    --     "Drink.PureWater",    -- CurrentType（杯中原液体）
    --     "Drink.Coffee", -- AddWaterType（加入的液体）
    --     "Drink.PumpkinJuice"  -- ToWaterType（结果）
    -- )

    -- ------------------------------------------------------------
    -- -- 4) “加物体后变化”的规则：南瓜汁 + 橙子片 = 南瓜橙橙
    -- ------------------------------------------------------------
    -- R:RegisterCupAddItemRule(
    --     "Drink.PumpkinJuice",      -- CurrentType（杯中原液体）南瓜汁
    --     "1103",         -- AddItemType（加入的小料类型）橙子片
    --     "Drink.PumpkinOrange" --变成的液体类型- 南瓜橙橙
    -- )

    -- ------------------------------------------------------------
    -- -- 5) 饮品颜色   --南瓜汁 在游戏中有颜色
    -- ------------------------------------------------------------
    -- local S = UE.FDrinkStyle()
    -- S.DisplayName = "南瓜橙橙" --需要和配方名称一致
    -- -- 橙棕配色建议（可调）：亮 → 深
    -- S.Color1 = UE.FLinearColor(1.00, 0.58, 0.12, 1.0)  -- 明橙棕
    -- S.Color2 = UE.FLinearColor(1.00, 0.58, 0.12, 1.0)  -- 明橙棕
    -- R:RegisterDrinkStyle("Drink.PumpkinOrange", S) --填饮品的类型


    -- 注册（覆盖写入）系统
    R:RegisterDrinkData(D.ID, D)

    --直接增加到已经有的配方（不解锁）
    local GS = UE.UGameplayStatics.GetGameState(World) or nil  -- AGameStateBase*
    if GS then
        GS:EvAddDrink(D.ID)
    end


end


function M.OnInit()
    --初始化
    add_new_drink()
end

return M
-- 附录：当前液体/饮品 ID、名称与颜色表
-- 格式：ID / Name（名称）/ Color1 RGBA / Color2 RGBA
-- 日志中的 ID 0 项按原值保留
-- ID:0 Name：糖浆 Color1:R=1 G=0.857 B=0.078 A=1 Color2:R=1 G=0.907 B=0.143 A=1
-- ID:0 Name：南瓜汁 Color1:R=0.644 G=0.28 B=0 A=1 Color2:R=0.585 G=0.275 B=0 A=1
-- ID:0 Name：烤奶 Color1:R=0.637 G=0.861 B=0.765 A=1 Color2:R=0.852 G=0.798 B=0.616 A=1
-- ID:0 Name：菠萝汁 Color1:R=1 G=0.678 B=0 A=1 Color2:R=1 G=0.887 B=0 A=1
-- ID:0 Name：菠萝蜜汁 Color1:R=1 G=0.816 B=0.233 A=1 Color2:R=1 G=0.902 B=0.291 A=1
-- ID:0 Name：苹果汁 Color1:R=0.9 G=0.599 B=0.245 A=1 Color2:R=0.8 G=0.506 B=0.194 A=1
-- ID:0 Name：桃汁 Color1:R=1 G=0.321 B=0.465 A=1 Color2:R=1 G=0.431 B=0.58 A=1
-- ID:0 Name：芒果汁 Color1:R=1 G=0.643 B=0 A=1 Color2:R=1 G=0.539 B=0 A=1
-- ID:0 Name：香蕉汁 Color1:R=1 G=0.871 B=0 A=1 Color2:R=1 G=0.792 B=0 A=1
-- ID:0 Name：草莓汁 Color1:R=1 G=0.168 B=0.258 A=1 Color2:R=1 G=0.161 B=0.193 A=1
-- ID:0 Name：石榴汁 Color1:R=0.8 G=0.074 B=0.092 A=1 Color2:R=0.599 G=0.066 B=0.066 A=1
-- ID:0 Name：椰奶 Color1:R=1 G=1 B=1 A=1 Color2:R=1 G=1 B=1 A=1
-- ID:0 Name：果冻汁 Color1:R=0.021 G=0.9 B=0.032 A=1 Color2:R=0.198 G=1 B=0.061 A=1
-- ID:0 Name：岩浆果冻汁 Color1:R=1 G=0.11 B=0.453 A=1 Color2:R=1 G=0.102 B=0.202 A=1
-- ID:0 Name：幽灵水 Color1:R=0.8 G=0.9 B=1 A=0.5 Color2:R=0.7 G=0.95 B=1 A=1
-- ID:0 Name：生锈铁水 Color1:R=0.5 G=0.205 B=0.153 A=0.7 Color2:R=0.432 G=0.275 B=0.17 A=1
-- ID:0 Name：热水 Color1:R=0.382 G=0.965 B=1 A=1 Color2:R=0.622 G=0.866 B=0.96 A=1
-- ID:0 Name：纯净水 Color1:R=0.311 G=0.848 B=1 A=1 Color2:R=0.624 G=0.863 B=0.956 A=1
-- ID:0 Name：生鱼片绿茶 Color1:R=0.553 G=0.564 B=0.128 A=1 Color2:R=0.408 G=0.46 B=0.11 A=1
-- ID:0 Name：酸奶 Color1:R=0.95 G=0.95 B=0.716 A=1 Color2:R=1 G=1 B=0.859 A=1
-- ID:5001 Name：柠檬水 Color1:R=1 G=0.604 B=0.049 A=1 Color2:R=1 G=0.604 B=0.049 A=1
-- ID:5002 Name：西瓜汁 Color1:R=0.672 G=0.08 B=0.071 A=1 Color2:R=0.672 G=0.064 B=0.055 A=1
-- ID:5003 Name：暴打鲜橙 Color1:R=0.991 G=0.391 B=0.047 A=1 Color2:R=0.964 G=0.391 B=0.094 A=1
-- ID:5006 Name：榨橙汁 Color1:R=1 G=0.261 B=0 A=1 Color2:R=1 G=0.226 B=0 A=1
-- ID:5005 Name：牛奶 Color1:R=1 G=0.967 B=0.905 A=1 Color2:R=1 G=0.972 B=0.918 A=1
-- ID:5007 Name：绿茶 Color1:R=0.223 G=0.297 B=0.086 A=1 Color2:R=0.234 G=0.31 B=0.095 A=1
-- ID:5014 Name：热咖啡 Color1:R=0.05 G=0.014 B=0.004 A=1 Color2:R=0.068 G=0.019 B=0.005 A=1
-- ID:5032 Name：奶茶 Color1:R=0.356 G=0.212 B=0.09 A=1 Color2:R=0.373 G=0.191 B=0.037 A=1
-- ID:5008 Name：柠檬绿茶 Color1:R=0.553 G=0.564 B=0.128 A=1 Color2:R=0.408 G=0.46 B=0.11 A=1
-- ID:5009 Name：西瓜冰茶 Color1:R=0.701 G=0.286 B=0.196 A=1 Color2:R=0.701 G=0.296 B=0.216 A=1
-- ID:5011 Name：西瓜果奶 Color1:R=1 G=0.422 B=0.246 A=1 Color2:R=1 G=0.455 B=0.27 A=1
-- ID:5013 Name：香橙柠檬 Color1:R=1 G=0.836 B=0.155 A=1 Color2:R=1 G=0.63 B=0.097 A=1
-- ID:5015 Name：南瓜茶茶 Color1:R=0.401 G=0.21 B=0.059 A=1 Color2:R=0.46 G=0.242 B=0.015 A=1
-- ID:5016 Name：南瓜牛乳 Color1:R=0.661 G=0.504 B=0.24 A=1 Color2:R=0.627 G=0.395 B=0.179 A=1
-- ID:5019 Name：芋圆奶茶 Color1:R=0.453 G=0.265 B=0.321 A=1 Color2:R=0.353 G=0.266 B=0.411 A=1
-- ID:5020 Name：茉莉奶绿 Color1:R=0.695 G=0.7 B=0.303 A=1 Color2:R=0.779 G=0.95 B=0.437 A=1
-- ID:5021 Name：芋泥奶茶 Color1:R=0.516 G=0.397 B=0.595 A=1 Color2:R=0.76 G=0.574 B=0.365 A=1
-- ID:5022 Name：芋泥啵啵 Color1:R=0.576 G=0.454 B=0.658 A=1 Color2:R=0.658 G=0.378 B=0.44 A=1
-- ID:5023 Name：布丁奶茶 Color1:R=0.668 G=0.475 B=0.256 A=1 Color2:R=0.714 G=0.615 B=0.172 A=1
-- ID:5024 Name：奥奥奶茶 Color1:R=0.484 G=0.34 B=0.177 A=1 Color2:R=0.391 G=0.318 B=0.276 A=1
-- ID:5025 Name：红豆奶茶 Color1:R=0.717 G=0.411 B=0.214 A=1 Color2:R=0.568 G=0.338 B=0.338 A=1
-- ID:5026 Name：红豆奶布丁 Color1:R=0.716 G=0.381 B=0.16 A=1 Color2:R=0.565 G=0.337 B=0.337 A=1
-- ID:5027 Name：双拼奶茶 Color1:R=0.356 G=0.212 B=0.089 A=1 Color2:R=0.371 G=0.191 B=0.037 A=1
-- ID:5028 Name：椰果奶茶 Color1:R=0.76 G=0.6 B=0.42 A=1 Color2:R=0.9 G=0.9 B=0.95 A=1
-- ID:5029 Name：三拼霸气奶茶 Color1:R=0.76 G=0.6 B=0.42 A=1 Color2:R=0.1 G=0.1 B=0.1 A=1
-- ID:5030 Name：芝士奶盖奶茶 Color1:R=0.6 G=0.7 B=0.4 A=1 Color2:R=1 G=0.98 B=0.9 A=1
-- ID:5031 Name：奥奥芝士奶茶 Color1:R=0.761 G=0.597 B=0.418 A=1 Color2:R=0.543 G=0.405 B=0.358 A=1
-- ID:5033 Name：红气桂枣暖奶茶 Color1:R=0.6 G=0.239 B=0.149 A=1 Color2:R=0.741 G=0.567 B=0.218 A=1
-- ID:5034 Name：黑糖珍珠奶茶 Color1:R=0.356 G=0.212 B=0.089 A=1 Color2:R=0.523 G=0.327 B=0.21 A=1
-- ID:5035 Name：烤奶牛乳茶 Color1:R=1 G=0.965 B=0.905 A=1 Color2:R=0.685 G=0.95 B=0.662 A=1
-- ID:5036 Name：西瓜啵啵 Color1:R=1 G=0.3 B=0.35 A=1 Color2:R=1 G=0.9 B=0.9 A=1
-- ID:5037 Name：芋圆葡萄 Color1:R=0.45 G=0.25 B=0.55 A=1 Color2:R=0.65 G=0.5 B=0.75 A=1
-- ID:5038 Name：满杯百香果 Color1:R=0.9 G=0.8 B=0.2 A=1 Color2:R=0.429 G=0.502 B=0.283 A=1
-- ID:5039 Name：菠萝菠萝蜜 Color1:R=0.95 G=0.9 B=0.1 A=1 Color2:R=1 G=0.8 B=0.2 A=1
-- ID:5040 Name：苹果桃桃 Color1:R=1 G=0.7 B=0.75 A=1 Color2:R=0.9 G=0.8 B=0.4 A=1
-- ID:5041 Name：桃桃芒芒 Color1:R=0.97 G=0.726 B=0.767 A=1 Color2:R=1 G=0.82 B=0.387 A=1
-- ID:5042 Name：蓝莓果粒茶 Color1:R=0.259 G=0.233 B=0.5 A=1 Color2:R=0.285 G=0.215 B=0.4 A=1
-- ID:5043 Name：蜜桃甘露 Color1:R=1 G=0.623 B=0.686 A=1 Color2:R=0.981 G=1 B=0.634 A=1
-- ID:5044 Name：蜜桃绿茶 Color1:R=0.6 G=0.7 B=0.4 A=1 Color2:R=1 G=0.7 B=0.75 A=1
-- ID:5045 Name：百香菠萝 Color1:R=1 G=0.768 B=0.21 A=1 Color2:R=0.794 G=0.964 B=0.775 A=1
-- ID:5046 Name：茉莉青提 Color1:R=0.65 G=0.85 B=0.35 A=1 Color2:R=0.6 G=0.7 B=0.4 A=1
-- ID:5047 Name：薄荷绿茶 Color1:R=0.2 G=0.8 B=0.5 A=1 Color2:R=0.6 G=0.7 B=0.4 A=1
-- ID:5048 Name：石榴汁 Color1:R=0.8 G=0.1 B=0.15 A=1 Color2:R=0.9 G=0.2 B=0.25 A=1
-- ID:5049 Name：葡萄冻冻 Color1:R=0.45 G=0.25 B=0.55 A=1 Color2:R=1 G=0.7 B=0.98 A=0.5
-- ID:5050 Name：鲜芒果百香 Color1:R=1 G=0.783 B=0.262 A=1 Color2:R=0.915 G=0.965 B=0.571 A=1
-- ID:5051 Name：青梅冰茶 Color1:R=0.5 G=0.6 B=0.2 A=1 Color2:R=0.8 G=0.7 B=0.4 A=1
-- ID:5052 Name：阳光青提 Color1:R=0.65 G=0.85 B=0.35 A=1 Color2:R=0.9 G=0.95 B=0.8 A=1
-- ID:5053 Name：超级水果茶 Color1:R=0.9 G=0.5 B=0.2 A=1 Color2:R=0.8 G=0.9 B=0.2 A=1
-- ID:5054 Name：蜂蜜柚子茶 Color1:R=0.95 G=0.7 B=0.1 A=1 Color2:R=1 G=0.882 B=0.29 A=1
-- ID:5055 Name：拿铁 Color1:R=0.35 G=0.2 B=0.1 A=1 Color2:R=0.398 G=0.272 B=0.187 A=1
-- ID:5056 Name：椰椰拿铁 Color1:R=0.429 G=0.264 B=0.153 A=1 Color2:R=0.397 G=0.286 B=0.213 A=1
-- ID:5057 Name：葡萄美式 Color1:R=0.061 G=0.013 B=0.025 A=1 Color2:R=0.068 G=0.019 B=0.005 A=1
-- ID:5058 Name：茉莉拿铁 Color1:R=0.397 G=0.27 B=0.188 A=1 Color2:R=0.499 G=0.582 B=0.332 A=1
-- ID:5059 Name：苹果拿铁 Color1:R=0.397 G=0.285 B=0.211 A=1 Color2:R=0.967 G=0.588 B=0.505 A=1
-- ID:5060 Name：橙橙美式 Color1:R=0.151 G=0.073 B=0.037 A=1 Color2:R=0.148 G=0.084 B=0.021 A=1
-- ID:5061 Name：黄油拿铁 Color1:R=0.397 G=0.27 B=0.188 A=1 Color2:R=0.509 G=0.446 B=0.227 A=1
-- ID:5062 Name：蜜桃拿铁 Color1:R=0.397 G=0.27 B=0.188 A=1 Color2:R=0.564 G=0.395 B=0.423 A=1
-- ID:5063 Name：芒芒牛乳 Color1:R=1 G=0.767 B=0.207 A=1 Color2:R=0.832 G=0.832 B=0.576 A=1
-- ID:5064 Name：生椰杨枝甘露 Color1:R=1 G=0.735 B=0.099 A=1 Color2:R=0.95 G=0.95 B=0.602 A=1
-- ID:5065 Name：杨枝甘露 Color1:R=1 G=0.738 B=0.1 A=1 Color2:R=0.947 G=0.947 B=0.386 A=1
-- ID:5066 Name：桃胶牛乳 Color1:R=0.95 G=0.95 B=0.572 A=1 Color2:R=0.88 G=0.668 B=0.243 A=1
-- ID:5067 Name：西瓜椰椰 Color1:R=1 G=0.3 B=0.35 A=1 Color2:R=0.95 G=0.95 B=0.744 A=1
-- ID:5068 Name：生椰柠檬撞奶 Color1:R=0.95 G=0.95 B=0.562 A=1 Color2:R=0.95 G=0.898 B=0.173 A=1
-- ID:5069 Name：芋圆椰椰 Color1:R=0.95 G=0.95 B=0.92 A=1 Color2:R=0.658 G=0.52 B=0.75 A=1
-- ID:5070 Name：芒芒西米露 Color1:R=1 G=0.75 B=0.15 A=1 Color2:R=1 G=0.845 B=0.509 A=1
-- ID:5071 Name：牛油果西米露 Color1:R=0.56 G=0.75 B=0.306 A=1 Color2:R=0.985 G=1 B=0.634 A=1
-- ID:5072 Name：黑糖啵啵奶茶 Color1:R=0.762 G=0.428 B=0.263 A=1 Color2:R=0.55 G=0.304 B=0.181 A=1
-- ID:5073 Name：荧光柠檬水 Color1:R=0.867 G=1 B=0.172 A=1 Color2:R=0.675 G=1 B=0.178 A=1
-- ID:5074 Name：曼德拉草绿茶 Color1:R=0.066 G=0.65 B=0.155 A=1 Color2:R=0.245 G=0.6 B=0.191 A=1
-- ID:5075 Name：岩浆西瓜触手 Color1:R=0.95 G=0 B=0.012 A=1 Color2:R=1 G=0.278 B=0.12 A=1
-- ID:5076 Name：荧光曼德拉草柠檬 Color1:R=0.153 G=1 B=0.118 A=1 Color2:R=0.472 G=0.8 B=0.038 A=1
-- ID:5077 Name：幽灵烤奶 Color1:R=0.8 G=0.723 B=0.517 A=1 Color2:R=0.439 G=0.907 B=1 A=1
-- ID:5078 Name：铁锈绿茶 Color1:R=0.14 G=0.5 B=0.151 A=1 Color2:R=0.439 G=0.22 B=0.073 A=1
-- ID:5079 Name：幽灵曼德拉草 Color1:R=0.582 G=1 B=0.835 A=1 Color2:R=0.109 G=0.5 B=0.123 A=1
-- ID:5080 Name：铁锈蜜桃 Color1:R=0.832 G=0.443 B=0.443 A=1 Color2:R=0.432 G=0.21 B=0.062 A=1
-- ID:5081 Name：幽灵芒芒 Color1:R=1 G=0.633 B=0.119 A=1 Color2:R=0.345 G=0.891 B=1 A=1
-- ID:5082 Name：蝙蝠干美式 Color1:R=0.273 G=0.151 B=0.076 A=1 Color2:R=0.047 G=0.047 B=0.047 A=1
-- ID:5083 Name：深渊绿茶 Color1:R=0.408 G=0.65 B=0.166 A=1 Color2:R=0.7 G=0.442 B=0.425 A=1
-- ID:5084 Name：鬼火烤奶 Color1:R=1 G=0.892 B=0.664 A=1 Color2:R=1 G=0.068 B=0.064 A=1
-- ID:5085 Name：盘丝洞幽灵水 Color1:R=0.394 G=0.85 B=0.787 A=1 Color2:R=0.154 G=1 B=0.323 A=1
-- ID:5086 Name：克苏鲁触手杯 Color1:R=0.1 G=0.3 B=0.25 A=1 Color2:R=0.6 G=0 B=0.8 A=1
-- ID:5087 Name：盘丝洞葡萄茶 Color1:R=0.343 G=0.074 B=0.45 A=1 Color2:R=0.418 G=0.9 B=0.489 A=1
-- ID:5088 Name：蝙蝠椰椰 Color1:R=0.61 G=1 B=0.911 A=1 Color2:R=0.095 G=0.06 B=0.025 A=1
-- ID:5089 Name：幽灵奶芋圆 Color1:R=0.622 G=0.471 B=0.85 A=1 Color2:R=0.366 G=0.951 B=1 A=1
-- ID:5090 Name：冰火二重奏 Color1:R=0 G=0.543 B=1 A=1 Color2:R=1 G=0.005 B=0 A=1
-- ID:5091 Name：曼德拉生化西瓜汁 Color1:R=0.8 G=0.2 B=0.4 A=1 Color2:R=0.48 G=1 B=0.415 A=1
-- ID:5092 Name：蘑菇脏脏茶 Color1:R=0.227 G=0.096 B=0.04 A=1 Color2:R=0.5 G=0.316 B=0.171 A=1
-- ID:5093 Name：果冻粘液烤奶 Color1:R=0 G=1 B=0.031 A=1 Color2:R=0.219 G=0.9 B=0.347 A=1
-- ID:5094 Name：剧毒沼泽柠檬水 Color1:R=0.863 G=1 B=0.108 A=1 Color2:R=0.887 G=0.402 B=1 A=1
-- ID:5095 Name：深渊凝视 Color1:R=0.5 G=0 B=1 A=1 Color2:R=0.98 G=0.127 B=1 A=1
-- ID:5096 Name：岩浆熔岩饮 Color1:R=1 G=0.003 B=0 A=1 Color2:R=0.1 G=0.021 B=0 A=1
-- ID:5097 Name：蝙蝠拿铁 Color1:R=0.373 G=0.267 B=0.183 A=1 Color2:R=0.18 G=0.1 B=0.05 A=1
-- ID:5098 Name：阴暗孢子拿铁 Color1:R=0.175 G=0.112 B=0.081 A=1 Color2:R=0.447 G=0.162 B=0.7 A=1
-- ID:5099 Name：蝙蝠荒原奶茶 Color1:R=1 G=1 B=1 A=1 Color2:R=1 G=1 B=1 A=1
-- ID:5100 Name：沼泽冻冻 Color1:R=0.2 G=0.3 B=0.2 A=1 Color2:R=0.2 G=1 B=0.1 A=1
-- ID:5101 Name：炼狱苦水 Color1:R=0 G=0 B=0 A=1 Color2:R=1 G=0.3 B=0 A=1
-- ID:5102 Name：致幻真菌牛乳 Color1:R=0.8 G=0.4 B=0.8 A=1 Color2:R=0 G=0.5 B=1 A=1
-- ID:5103 Name：深渊诱捕蜜酿 Color1:R=0.079 G=0 B=0.1 A=1 Color2:R=0.926 G=1 B=0 A=1
-- ID:5104 Name：虚空黑洞 Color1:R=0 G=0.017 B=1 A=1 Color2:R=0.007 G=0 B=0.5 A=1
-- ID:5105 Name：银河星尘露 Color1:R=0 G=0.471 B=1 A=1 Color2:R=0.309 G=0 B=1 A=1
-- ID:5106 Name：贤者之石特调 Color1:R=0.7 G=0.138 B=0.001 A=1 Color2:R=0.546 G=1 B=0 A=1
-- ID:5108 Name：车厘子汁 Color1:R=0.7 G=0.1 B=0.15 A=1 Color2:R=0.7 G=0.1 B=0.15 A=1
-- ID:5107 Name：红宝石橙汁 Color1:R=0.95 G=0.35 B=0.1 A=1 Color2:R=1 G=0.6 B=0.05 A=1
-- ID:5109 Name：红运牛乳 Color1:R=0.92 G=0.75 B=0.8 A=1 Color2:R=0.96 G=0.96 B=0.92 A=1
-- ID:5110 Name：美式糖葫芦 Color1:R=0.18 G=0.1 B=0.05 A=1 Color2:R=0.85 G=0.1 B=0.1 A=1
-- ID:5111 Name：爆竹奶茶 Color1:R=0.65 G=0.75 B=0.55 A=1 Color2:R=1 G=0.2 B=0.2 A=1
-- ID:5112 Name：爆红车厘子 Color1:R=0.7 G=0.05 B=0.15 A=1 Color2:R=1 G=0.2 B=0.2 A=1
-- ID:5113 Name：爆裂糖葫芦 Color1:R=0.7 G=0.05 B=0.15 A=1 Color2:R=0.85 G=0.1 B=0.1 A=1
-- ID:5114 Name：香蕉牛乳 Color1:R=0.982 G=0.807 B=0.371 A=1 Color2:R=0.982 G=0.807 B=0.371 A=1
-- ID:5115 Name：草莓牛乳 Color1:R=0.991 G=0.479 B=0.474 A=1 Color2:R=0.991 G=0.815 B=0.753 A=1
-- ID:5116 Name：薄荷巧克力拿铁 Color1:R=0.558 G=0.397 B=0.216 A=1 Color2:R=0.716 G=0.839 B=0.658 A=1
-- ID:5117 Name：苹果茉莉 Color1:R=0.839 G=0.839 B=0.515 A=1 Color2:R=0.839 G=0.831 B=0.509 A=1
-- ID:5118 Name：香蕉拿铁 Color1:R=0.88 G=0.571 B=0.216 A=1 Color2:R=0.982 G=0.839 B=0.558 A=1
-- ID:5119 Name：香蕉绿茶 Color1:R=0.597 G=0.624 B=0.153 A=1 Color2:R=0.839 G=0.839 B=0.434 A=1
-- ID:5120 Name：超级酸奶捞 Color1:R=1 G=1 B=1 A=1 Color2:R=1 G=1 B=1 A=1
-- ID:5121 Name：草莓酸奶 Color1:R=0.982 G=0.672 B=0.651 A=1 Color2:R=0.973 G=0.905 B=0.847 A=1
-- ID:5122 Name：香蕉酸奶 Color1:R=0.991 G=0.913 B=0.651 A=1 Color2:R=0.991 G=0.913 B=0.651 A=1
-- ID:5123 Name：薄荷奶绿 Color1:R=0.223 G=0.497 B=0.086 A=1 Color2:R=0.552 G=0.694 B=0.301 A=1
-- ID:5124 Name：茉莉绿茶 Color1:R=0.73 G=0.768 B=0.258 A=1 Color2:R=0.738 G=0.784 B=0.275 A=1
-- ID:5125 Name：红苹果奶绿 Color1:R=0.665 G=0.745 B=0.279 A=1 Color2:R=0.88 G=0.896 B=0.701 A=1
-- ID:5126 Name：苹果牛乳 Color1:R=0.991 G=0.871 B=0.565 A=1 Color2:R=0.991 G=0.905 B=0.658 A=1
-- 附录：当前小料 ID 表
-- 1102 柠檬片
-- 1103 橙子片
-- 1105 纯净水工具
-- 1106 榨汁机工具
-- 1107 珍珠
-- 1108 小票
-- 7001 芋圆
-- 7002 茉莉花酱
-- 7003 芋泥
-- 7004 啵啵
-- 7005 布丁
-- 7006 奥奥
-- 7007 桃胶
-- 7008 紫米露
-- 7009 芒果丁
-- 7010 牛油果丁
-- 7011 蜜桃丁
-- 7012 菠萝丁
-- 7013 蓝莓
-- 7014 黄油
-- 7015 红豆
-- 7016 黑糖
-- 7017 冻冻
-- 7018 柚子粒
-- 7019 青梅
-- 7020 蜂蜜
-- 7021 百香果
-- 7022 芝士奶盖
-- 7023 红枣干
-- 7024 桂圆干
-- 7025 椰果
-- 7026 剥皮青提
-- 7027 剥皮葡萄
-- 7028 薄荷
-- 7029 西米露
-- 7030 荧光柠檬片
-- 7031 墓地蘑菇
-- 7032 蝙蝠干
-- 7033 曼德拉草片
-- 7034 蜘蛛丝
-- 7035 深渊之眼
-- 7036 岩浆触手片
-- 7037 贤者之石
-- 7038 鬼火
-- 7039 星辰棱石
-- 7040 果冻粘液
-- 7041 岩浆果冻粘液
-- 7042 幽灵水
-- 7043 生锈铁水
-- 7044 爆竹
-- 7045 糖葫芦
-- 7046 丘比特糖浆
-- 7047 味觉失忆粉
-- 7048 完美滤镜香精
-- 7049 生鱼片
-- 7050 骷髅鱼骨粉
-- 7051 巧克力

-- 附录：教程提示图标 ID 表（由配方日志去重）
-- 1004 西瓜
-- 1005 橙子
-- 1007 牛奶
-- 1008 绿茶
-- 1010 煮锅
-- 1012 榨汁机
-- 1028 研磨器
-- 1029 咖啡豆
-- 1030 咖啡冲泡机
-- 1033 南瓜
-- 1036 苹果
-- 1040 桃子
-- 1045 草莓
-- 1047 菠萝
-- 1054 香蕉
-- 1092 菠萝蜜
-- 1093 芒果
-- 1094 石榴
-- 1105 纯净水工具
-- 1106 榨汁机工具
-- 1116 椰奶
-- 1142 离心机
-- 1143 8J特级车厘子
-- 1175 酸奶机
-- 3033 输液器
