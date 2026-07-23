# 🃏 《奶茶店模拟器 - 重生之我在冰堡甜城当店长》 Modding 示例 (BobaCafeSimulator Modding Example)

_这是一个使用 **Lua 语言** 编写的 Mod 示例.
[中文](README.md)   | [English](README_EN.md)  

---

## 📚 快速导航

- [工作原理概述](#overview)
- [Mod 文件夹结构](#folder-structure)
- [`main.lua` 的 `M` 结构](#m-struct)
- [奶茶配方数据说明](#drink-data)
- [完整南瓜橙橙示例](#drink-example)
- [三种混合规则说明](#mix-rules)
- [修改已有饮品颜色完整示例](#drink-color-example)
- [模型 PAK 与装饰品示例](#decoration-asset-example)
- [自定义背景音乐示例](#custom-bgm-example)
- [每天自动支付账单示例](#auto-pay-bill-example)
- [本地化（多语言支持）](#localization)（[直接打开 Example_ZH 本地化示例](Example_ZH/LocalizedPumpkinDrink/)）
- [上传 Steam 创意工坊](#workshop-upload)
- [联系方式](#contact)
- [社区准则](#community-rules)
- [ID 参考表（液体/饮品、小料、教程图标）](#id-appendix)

---

<a id="overview"></a>
## 🧩 工作原理概述

游戏会自动扫描并读取以下位置的 Mod：

- `游戏根目录/BobaCafeSimulator/Mods` 📁  
- 从 **Steam 创意工坊** 订阅的物品文件夹 🛠️

当找到入口文件 `main.lua` 时，即可在 **Mods** 菜单中识别、管理并加载该 Mod；`preview.png` 用作推荐的 Mod 预览图。

---

### ⚙️ 规则一：加载与执行
- 进入游戏约 **1 秒** 后，按 Mod 路径顺序加载并依次执行：  
  ```lua
  M.OnInit()   -- 初始化时执行一次
  ```

### 🧠 规则二：全局访问
- `UE`：全局变量，可访问 Unreal Engine 暴露的函数集合。  
- `M`：当前 Mod 的信息结构（会在主界面 Mods 列表中显示）。
- `dir`：当前 Mod 的绝对路径。
---

<a id="folder-structure"></a>
## 📁 Mod 文件夹结构

将 Mod 放入 `游戏根目录/BobaCafeSimulator/Mods/` 目录即可在游戏内识别。

```
BobaCafeSimulator/
└── Mods/
    └── MyMod/   --下面全都不能是中文
        ├── main.lua       # Mod 逻辑（Lua 编写）
        └── preview.png    # 预览图（256×256，正方形）
```

👉 [示例 Mod ](Example_ZH/)

---

<a id="m-struct"></a>
## 🧾 `main.lua` 的 `M` 结构

`local M = {}` 建议包含：

| 字段 | 类型 | 说明 |
|---|---|---|
| `id` | string | Mod 唯一 ID（英文，作为 Key） |
| `name` | string | 显示名称 |
| `description` | string | 描述 |
| `version` | string | 版本号 |
| `author` | string | 作者 |

> ✅ 你可以在 `M` 旁自由声明本地状态/变量，供 Mod 内部使用。

---

<a id="drink-data"></a>
## 🖼️ 奶茶配方添加/替换（示例）

`FDrinkData` 是一条完整的饮品配方数据。下表列出了新手在 `main.lua` 中可填写的所有字段；不使用的可选字段可保留默认值。

> 💡 自定义饮品 ID 建议使用 `5200–5999`，避免与游戏内置配方冲突。配方目前应使用已有的原料、工具和配方逻辑进行组合。

| 字段 | UE 类型 | 默认值 | Lua 填写示例 | 用途 |
|---|---|---|---|---|
| `ID` | `int32` | `0` | `D.ID = 5200` | 饮品配方的唯一 ID，建议必填。 |
| `DisplayName` | `FText` | 空 | `D.DisplayName = "南瓜橙橙"` | 配方界面和游戏内显示的饮品名称。 |
| `DrinkType` | `EDrinkType` | `MilkTea` | `D.DrinkType = UE.EDrinkType.FruitTea` | 饮品分类；果汁/果茶必须显式设为 `FruitTea`。 |
| `Season` | `TArray<EGBSeason>` | 空数组 | `D.Season:Add(UE.EGBSeason.Spring)` | 可售季节。空数组可能导致配方不在任何季节出现。 |
| `ImagePath` | `FString` | 空 | `D.ImagePath = dir .. "5200.png"` | 配方图片路径，通常放在 Mod 目录内。 |
| `Value` | `TMap<FName, float>` | `S/M/L = 0` | `D.Value:Add("M", 10.0)` | `S`/`M`/`L` 杯型的售价。 |
| `DrinkWaterFName` | `FName` | 空 | `D.DrinkWaterFName = "Drink.PumpkinOrange"` | 完成配方时要匹配的最终液体类型名。 |
| `CanSweet` | `TArray<FName>` | 全部甜度 | `D.CanSweet:Add("Sweet5")` | 顾客可点的甜度。要自定义时先写 `D.CanSweet = {}`。 |
| `CanTemperature` | `TArray<FName>` | 全部温度 | `D.CanTemperature:Add("Ice")` | 顾客可点的温度。要自定义时先写 `D.CanTemperature = {}`。 |
| `NeedItemID` | `TArray<int32>` | 空数组 | `D.NeedItemID:Add(1103)` | 配方需要的小料/物品 ID。同一 ID 重复添加表示需要多份。 |
| `ShowTutorialsItemID` | `TArray<int32>` | 空数组 | `D.ShowTutorialsItemID:Add(1106)` | 配方教程栏中依次显示的工具/原料图标。 |
| `PerfectNeed` | `TArray<FPerfectNeed>` | 空数组 | 见下方“完美配方”示例 | 判定完美配方时需要的液体类型和占比区间。 |
| `PerfectNeedItem` | `TMap<FName, int32>` | 空 | `D.PerfectNeedItem:Add("1103", 4)` | 完美配方所需的小料 ID 及数量。 |
| `HideGetWay` | `bool` | `false` | `D.HideGetWay = true` | 是否隐藏正常的配方获取途径。 |
| `HideGetWayText` | `FText` | 空 | `D.HideGetWayText = "继续探索后解锁"` | `HideGetWay = true` 时显示的提示文本。 |
| `ShowGetWayText` | `FText` | 空 | `D.ShowGetWayText = "由 Mod 获得"` | 配方界面显示的获取方式。 |
| `MakeNeedTutorialText` | `FText` | 空 | `D.MakeNeedTutorialText = "榨汁后加入橙子片"` | 配方界面的主制作教程。 |
| `MakeNeedTutorialExtraText` | `TArray<FName>` | 空数组 | `D.MakeNeedTutorialExtraText:Add("SomeTextKey")` | 制作教程中的额外文本 Key。 |
| `UnlockProgress` | `int32` | `0` | `D.UnlockProgress = 10` | 解锁配方所需的进度数值。 |
| `UnlockProgressType` | `FName` | 空 | `D.UnlockProgressType = "FName"` | 解锁判定方式，填 `FName` 或 `Tag`。 |
| `UnlockProgressFName` | `FName` | 空 | `D.UnlockProgressFName = "ProgressKey"` | 按 FName 进度解锁时使用的 Key。 |
| `UnlockProgressTag` | `FName` | 空 | `D.UnlockProgressTag = "Progress.Tag"` | 按 Gameplay Tag 进度解锁时使用的 Tag 名。 |
| `UnlockedItemID` | `TArray<FName>` | 空数组 | `D.UnlockedItemID:Add("Pumpkin")` | 解锁该配方后一并解锁的物品类型。 |
| `Function` | `TMap<FName, FName>` | 空 | `D.Function:Add("Key", "Value")` | 为扩展逻辑保留的额外标记键值。 |

### `DrinkType` 的全部可选值

| Lua 值 | 显示名称 | 说明 |
|---|---|---|
| `UE.EDrinkType.None` | 无 | 不归入具体饮品类型。 |
| `UE.EDrinkType.MilkTea` | 奶茶 | 奶茶类；也是 `FDrinkData` 的默认值。 |
| `UE.EDrinkType.FruitTea` | 果茶 | 果茶、果汁类。 |
| `UE.EDrinkType.Coffee` | 咖啡 | 咖啡类。 |
| `UE.EDrinkType.SweetSoup` | 糖水 | 糖水、甜汤类。 |
| `UE.EDrinkType.IceCream` | 冰淇淋 | 冰淇淋类。 |

### 季节、甜度与温度可选值

- 季节：`Spring`、`Summer`、`Autumn`、`Winter`
- 甜度：`Sweet10`、`Sweet7`、`Sweet5`、`Sweet3`、`Sweet0`
- 温度：`Hot`、`Normal`、`SmallIce`、`Ice`

全年可售的果汁可以这样填写：

```lua
D.DrinkType = UE.EDrinkType.FruitTea
D.Season:Add(UE.EGBSeason.Spring)
D.Season:Add(UE.EGBSeason.Summer)
D.Season:Add(UE.EGBSeason.Autumn)
D.Season:Add(UE.EGBSeason.Winter)
```

### 完美配方的液体占比

`FPerfectNeed` 的 `WaterName`、`MinPercent`、`MaxPercent` 三个字段都应填写。例如，南瓜汁在杯中的占比需要介于 83% 和 100% 之间：

```lua
local PN = UE.FPerfectNeed()
PN.WaterName = "Drink.PumpkinJuice"
PN.MinPercent = 0.83
PN.MaxPercent = 1.00
D.PerfectNeed:Add(PN)
```

### 解锁与奖励字段

- 不使用进度解锁时，`UnlockProgress`、`UnlockProgressType`、`UnlockProgressFName`、`UnlockProgressTag` 保留默认值即可。
- `UnlockProgressType = "FName"` 时填写 `UnlockProgressFName`；`UnlockProgressType = "Tag"` 时填写 `UnlockProgressTag`。
- `UnlockedItemID` 已知可用值包括：`Watermelon`、`Orange`、`Tea`、`Pot`、`Milk`、`Pumpkin`、`Boba`、`PaperCup`、`Coffee`。

---

<a id="drink-example"></a>
## ✅ 完整可运行示例：添加一个配方南瓜橙橙（`main.lua`）

```lua
-- 必填信息：会显示在 Mods 界面
local M = {
    id          = "NewDrinkPumpkinOrange",
    name        = "增加配方南瓜橙橙",
    description = "增加配方南瓜橙橙",
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
    D.ID = 5200  --建议使用5200-5999
    --名称
    D.DisplayName = "南瓜橙橙"
    --饮品类型（FDrinkData 默认是 MilkTea，果汁需要显式覆盖）
    D.DrinkType = UE.EDrinkType.FruitTea
    --可售季节：全年
    D.Season:Add(UE.EGBSeason.Spring)
    D.Season:Add(UE.EGBSeason.Summer)
    D.Season:Add(UE.EGBSeason.Autumn)
    D.Season:Add(UE.EGBSeason.Winter)
    --图片路径
    D.ImagePath = dir .. "5200.png" --你的Mod目录的图片

    -- 价格（S/M/L）
    D.Value:Add("S", 8.0)
    D.Value:Add("M", 10.0)
    D.Value:Add("L", 12.0)
    -- 配方里完成需要的水类型
    D.DrinkWaterFName = "Drink.PumpkinOrange"  --新的液体类型
    -- 配方里完成需要的物品 四个橙子片
    D.NeedItemID:Add(1103)
    D.NeedItemID:Add(1103)
    D.NeedItemID:Add(1103)
    D.NeedItemID:Add(1103)

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
    D.PerfectNeedItem:Add("1103",4)
    ------------------------------------------------------------------

    --提示图标 配方栏的那个小图标
    D.ShowTutorialsItemID:Add(1106) --榨汁机
    D.ShowTutorialsItemID:Add(1033) --南瓜
    D.ShowTutorialsItemID:Add(1103) --橙子片
    --教程 配方界面点开后显示的教程
    D.MakeNeedTutorialText = "榨汁南瓜汁，然后加四个橙子片"

    -- 显示获取方式 配方界面点开后显示的解锁方式
    D.ShowGetWayText = "MOD获得"

    --获得配方之后解锁的物品类型 目前有 Watermelon(西瓜) Orange(橙子) Tea(茶) Pot(煮东西相关）
    --Milk(奶相关 大瓶一箱奶) Pumpkin(南瓜) Boba(珍珠) PaperCup(纸杯,热的需要) Coffee(奶茶)
    D.UnlockedItemID = {}
    D.UnlockedItemID:Add("Pumpkin")
    D.UnlockedItemID:Add("Orange")


    -- 3) 单个液体 + 单个液体的变化规则（这个配方不需要）
    -- 示例：纯净水 + 咖啡 = 南瓜汁（仅演示接口，所以保持注释）
    ------------------------------------------------------------
    -- R:RegisterCupAddWaterRule(
    --     "Drink.PureWater",       -- CurrentType（杯中原液体）
    --     "Drink.Coffee",          -- AddWaterType（新加入的液体）
    --     "Drink.PumpkinJuice"     -- ToWaterType（结果液体）
    -- )

    ------------------------------------------------------------
    -- 4) 单个液体 + 单个物品的变化规则：南瓜汁 + 橙子片 = 南瓜橙橙
    ------------------------------------------------------------
    R:RegisterCupAddItemRule(
        "Drink.PumpkinJuice",      -- CurrentType（杯中原液体）
        "1103",                    -- AddItemType（新加入的橙子片）
        "Drink.PumpkinOrange"      -- ToWaterType（结果液体）
    )

    ------------------------------------------------------------
    -- 5) 多个液体 + 多个物品的完美混合规则
    -- 南瓜汁 + 橙汁 + 橙子片 + 柠檬片 = 南瓜橙橙
    ------------------------------------------------------------
    local MixRule = UE.FPerfectMixRule()
    MixRule.RequiredWaterTypes:Add("Drink.PumpkinJuice") -- 南瓜汁
    MixRule.RequiredWaterTypes:Add("Drink.OrangeJuice")  -- 橙汁
    MixRule.RequiredItemIDs:Add(1103)                     -- 橙子片
    MixRule.RequiredItemIDs:Add(1102)                     -- 柠檬片
    MixRule.OutputWaterType = "Drink.PumpkinOrange"      -- 命中后的结果液体
    R:AddOverridePerfectMixRule(MixRule)

    ------------------------------------------------------------
    -- 6) 饮品颜色
    ------------------------------------------------------------
    local S = UE.FDrinkStyle()
    S.DisplayName = "南瓜橙橙" --需要和配方名称一致
    -- 橙棕配色建议（可调）：亮 → 深
    S.Color1 = UE.FLinearColor(1.00, 0.58, 0.12, 1.0)  -- 明橙棕
    S.Color2 = UE.FLinearColor(1.00, 0.58, 0.12, 1.0)  -- 明橙棕
    R:RegisterDrinkStyle("Drink.PumpkinOrange", S) --前面填饮品的液体类型DrinkWaterFName


    -- 注册（覆盖写入）系统
    R:RegisterDrinkData(D.ID, D)

    --直接增加到已经有的配方（不解锁）
    local GS = UE.UGameplayStatics.GetGameState(World) or nil  -- AGameStateBase*
    if GS then
        GS:EvAddDrink(D.ID)
    end

    if MOD and MOD.Logger then MOD.Logger.LogScreen("已注册：南瓜橙橙(5200)", 5,0,1,0,1) end --日志
end


function M.OnInit()
    --初始化
    if MOD and MOD.Logger then  MOD.Logger.LogScreen(("Mod [%s] 开始加载"):format(M.name), 5,1,1,0,1) end --日志
    add_new_drink()
end


return M
```

<a id="mix-rules"></a>
### 三种混合规则如何选择

| 需求 | 接口 | 匹配方式 |
|---|---|---|
| 单个液体 + 新加入的单个液体 | `RegisterCupAddWaterRule` | 匹配 `CurrentType + AddWaterType`，得到 `ToWaterType`。 |
| 单个液体 + 新加入的单个物品 | `RegisterCupAddItemRule` | 匹配 `CurrentType + AddItemType`，得到 `ToWaterType`。 |
| 多个液体 + 多个物品 | `FPerfectMixRule` + `AddOverridePerfectMixRule` | 检查杯中是否包含规则要求的所有液体类型和物品 ID。 |

`FPerfectMixRule` 有三个可填字段：

| 字段 | 类型 | 用途 |
|---|---|---|
| `RequiredWaterTypes` | `TArray<FName>` | 必须包含的液体类型列表。 |
| `RequiredItemIDs` | `TArray<int32>` | 必须包含的物品 ID 列表。 |
| `OutputWaterType` | `FName` | 全部要求命中后输出的结果液体。 |

> 注意：完美混合规则只检查“是否包含”，不检查液体百分比。重复添加同一个物品 ID 也不会变成数量要求；例如把 `1103` 写两次，仍然只表示“需要包含橙子片”。如果杯中还有额外液体或小料，不会阻止规则命中。

如果同时命中多条规则，系统会优先选择需求类型更多、更具体的规则。`OutputWaterType` 还应有对应的 `FDrinkStyle`，并与配方的 `DrinkWaterFName` 保持一致。


---

<a id="drink-color-example"></a>
## 🎨 完整可运行示例：修改已有饮品颜色（红色柠檬水）

这个示例将已有柠檬水 `Drink.LemonWater` 的两层液体颜色都改为红色，不会替换柠檬水的配方数据。

```text
RedLemonWater/
└── main.lua
```

实现时需要注意：

1. 先用 `GetDrinkStyle` 读取服务器已初始化的完整样式，再只修改 `Color1` 和 `Color2`。这样可以保留原样式中的 `DrinkID`、显示名称和图标。
2. 所有 Mod 的 `OnInit` 是同步执行的。示例先延迟 1 秒，如果饮品注册表或柠檬水样式还没就绪，就继续重试，避免受 Mod 列表加载顺序影响。
3. `FLinearColor` 的 RGBA 分量使用 `0.0–1.0`；`UE.FLinearColor(1.0, 0.0, 0.0, 1.0)` 表示不透明红色。

`main.lua` 完整内容：

```lua
local M = {
    id          = "RedLemonWater",
    name        = "红色柠檬水",
    description = "将柠檬水的两层液体颜色修改为红色",
    version     = "1.0.0",
    author      = "yiming",
}

local DRINK_STYLE_KEY = "Drink.LemonWater"
local RETRY_DELAY_SECONDS = 1
local MAX_RETRY_COUNT = 60

local retry_count = 0
local try_apply_red_color

local function log_screen(message, red, green, blue)
    if MOD and MOD.Logger then
        MOD.Logger.LogScreen(message, 5, red, green, blue, 1)
    end
end

local function schedule_retry(reason)
    retry_count = retry_count + 1

    if retry_count == 1 or retry_count % 5 == 0 then
        log_screen(
            string.format("[%s] 等待饮品数据初始化：%s（%d/%d）", M.id, reason, retry_count, MAX_RETRY_COUNT),
            1, 1, 0
        )
    end

    if retry_count >= MAX_RETRY_COUNT then
        log_screen(
            string.format("[%s] 修改失败：等待 %s 超时", M.id, DRINK_STYLE_KEY),
            1, 0, 0
        )
        return
    end

    MOD.GAA.TimerManager:AddTimer(RETRY_DELAY_SECONDS, M, function()
        try_apply_red_color()
    end)
end

try_apply_red_color = function()
    local pc = MOD and MOD.Playercontroller or nil
    if not pc or not pc.GetWorld then
        schedule_retry("PlayerController 未就绪")
        return
    end

    local world = pc:GetWorld()
    local registry = world and UE.UBoBaFunction.GetDrinkRegistryWS(world) or nil
    if not registry then
        schedule_retry("DrinkRegistryWorldSubsystem 未就绪")
        return
    end

    -- 先读取服务器初始化后的完整样式，只覆盖颜色，保留 DrinkID、名称和 Icon。
    local found, style = registry:GetDrinkStyle(DRINK_STYLE_KEY)
    if not found or not style then
        schedule_retry(DRINK_STYLE_KEY .. " 尚未注册")
        return
    end

    local red = UE.FLinearColor(1.0, 0.0, 0.0, 1.0)
    style.Color1 = red
    style.Color2 = red

    registry:RegisterDrinkStyle(DRINK_STYLE_KEY, style)

    log_screen(
        string.format("[%s] 已将 %s 的 Color1/Color2 修改为红色", M.id, DRINK_STYLE_KEY),
        0, 1, 0
    )
end

function M.OnInit()
    log_screen(string.format("Mod [%s] 开始加载", M.name), 0, 1, 1)

    -- 所有 Mod 的 OnInit 同步执行；延迟后写入，避免受 Mod 列表先后顺序影响。
    MOD.GAA.TimerManager:AddTimer(RETRY_DELAY_SECONDS, M, function()
        try_apply_red_color()
    end)
end

return M
```

要修改其他已有饮品，替换 `DRINK_STYLE_KEY` 和颜色值即可：

```lua
local new_color_1 = UE.FLinearColor(1.0, 0.2, 0.2, 1.0)
local new_color_2 = UE.FLinearColor(0.6, 0.0, 0.0, 1.0)
style.Color1 = new_color_1
style.Color2 = new_color_2
```

如果希望两层液体保持同色，就让 `Color1` 和 `Color2` 使用同一个 `FLinearColor`。


---

<a id="decoration-asset-example"></a>
## 🪑 模型 PAK 与装饰品示例

模型、材质和贴图不能直接作为普通文件交给游戏读取，需要先使用与游戏一致的 **UE5.6** 空白项目完成 Cook 和 PAK 打包。

- [查看模型 PAK 完整打包教程](Model_PAK_Packaging_ZH.md)
- [打开动物装饰资产包完整示例](Example_ZH/AnimalDecorationAssetPack/)
- [直接查看完整 `main.lua`](Example_ZH/AnimalDecorationAssetPack/main.lua)

### 最简单的制作流程

1. 使用 UE5.6 创建一个英文名称的空白蓝图项目。
2. 在项目的 `Content` 下创建独立英文目录，例如 `Content/MyDecorationPack/`。
3. 把模型、材质、材质实例和贴图放在该目录中，并确认 Static Mesh 已经设置材质槽。
4. 在同一目录创建 `PrimaryAssetLabel` 数据资产，设置 `Chunk ID = 1001`、`Cook Rule = Always Cook`，并开启 `Label Assets in My Directory` 和 `Is Runtime Label`。
5. 在 Packaging 中开启 Pak、Chunk 和共享 Shader，关闭 IoStore，然后打包 Windows。
6. 复制 `pakchunk1001-Windows.pak`，并从中提取 SM5、SM6 两个 `ShaderArchive-*.ushaderbytecode`。
7. 参考完整示例修改 `ASSET_ROOT`、物品 ID、模型名称、文本和每件家具的预览图片。

项目中的位置关系：

```text
MyDecorationProject/
├── MyDecorationProject.uproject
├── Config/
└── Content/
    └── MyDecorationPack/
        ├── PAL_MyDecorationPack.uasset
        ├── SM_MyDecoration.uasset
        ├── M_MyDecoration.uasset
        ├── MI_MyDecoration.uasset
        └── T_MyDecoration_Color.uasset
```

`PrimaryAssetLabel` 是 UE 内容浏览器中的数据资产，应与它管理的模型、材质和贴图放在同一目录。它不是放在 `Config`、项目根目录或游戏 `Mods` 目录中的文件。

### Lua 最小注册流程

假设模型位于：

```text
Content/MyDecorationPack/SM_MyDecoration.uasset
```

运行时对象路径就是：

```text
/Game/MyDecorationPack/SM_MyDecoration.SM_MyDecoration
```

下面代码只展示一件地面装饰品的核心注册流程。正式使用时还需要保留完整示例中的 PAK 挂载、PIE 检查、错误处理、中英文文本和 Shader 说明。

```lua
local M = {
    id = "MyDecorationMod",
    name = "My Decoration Mod",
    description = "Adds one custom furniture decoration.",
    version = "1.0.0",
    author = "YourName",
}

local ASSET_ROOT = "/Game/MyDecorationPack"
local ITEM_ID = "Mod_MyDecoration_01"
local MESH_NAME = "SM_MyDecoration"
local PREVIEW_IMAGE = "SM_MyDecoration.png"

local function RegisterOneDecoration()
    local World = MOD.GAA.WorldUtils:GetCurrentWorld()
    local ItemSubsystem = UE.UModFilesystemLib.GetItemDataSubsystem(World)
    if not ItemSubsystem then
        error("Could not get ItemDataSubsystem")
    end

    local ItemTag, bTagValid = UE.UGB_FunctionLibary.FNameToGameplayTag(
        "购买.装饰.家具",
        false,
        false
    )
    if not bTagValid then
        error("Invalid furniture GameplayTag")
    end

    local MeshPath = ASSET_ROOT .. "/" .. MESH_NAME .. "." .. MESH_NAME
    if not MOD.GAA.LoadObject("StaticMesh'" .. MeshPath .. "'") then
        error("Mesh failed to load: " .. MeshPath)
    end

    local ItemData = UE.FItemDataRuntime()
    ItemData.ItemIndex = ITEM_ID
    ItemData.DisplayName = "My Decoration"
    ItemData.Description = "A custom furniture decoration."
    ItemData.ItemTag = ItemTag

    ItemData.Functions:Add("Mesh", MeshPath)
    ItemData.Functions:Add("Painting", "0")
    ItemData.Functions:Add("Show", "1")
    ItemData.Functions:Add("UnlockLevel", "0")
    ItemData.Functions:Add("Value", "50")
    ItemData.Functions:Add(
        "TexturePath",
        UE.UModFilesystemLib.Join(MOD.ModDir, PREVIEW_IMAGE)
    )
    ItemData.Functions:Add(
        "ClassPath",
        "/Script/Engine.Blueprint'/Game/2Game/Blueprint/商店饰品/BP_家具2100随意放置.BP_家具2100随意放置'"
    )
    ItemData.Functions:Add(
        "BoxClassPath",
        "/Script/Engine.Blueprint'/Game/1Game/Blueprint/AI/BP/货物包裹/BP_货物包裹建筑.BP_货物包裹建筑'"
    )
    ItemData.Functions:Add("BoxHigh", "50")
    ItemData.Functions:Add("BoxType", "2")

    ItemSubsystem:RegisterItemData(ITEM_ID, ItemData)
end

function M.OnInit()
    -- 必须先挂载 PAK 和 Shader 库，再按对象路径加载模型。
    UE.UModFilesystemLib.MountPaksInDirectory(MOD.ModDir)
    RegisterOneDecoration()
end

return M
```

完整示例还演示了：

- 四个模型分别注册为四个物品。
- 每件物品使用独立 PNG 预览图。
- Mod 元数据默认英文，并提供中文本地化。
- 游戏内物品名称和说明的英文回退与中文本地化。
- `Functions` 中每个家具字段的具体含义。
- Editor/PIE 加载 Cooked Content 的处理方式。

最终 Mod 文件夹至少应包含：

```text
MyDecorationMod/
├── main.lua
├── MyDecorationMod.pak
├── ShaderArchive-项目名_Chunk1001-PCD3D_SM5-PCD3D_SM5.ushaderbytecode
├── ShaderArchive-项目名_Chunk1001-PCD3D_SM6-PCD3D_SM6.ushaderbytecode
├── preview.png
└── SM_MyDecoration.png
```

---

<a id="custom-bgm-example"></a>
## 🎵 自定义背景音乐（CustomBGM 示例）

该示例会将 Mod 根目录里的 MP3 组成播放列表，在所有 Mod 加载完成后播放，曲目结束后自动换下一首并循环。

- [打开完整示例](Example_ZH/CustomBGM/)
- [查看 `main.lua`](Example_ZH/CustomBGM/main.lua)
- [查看简短备忘](Example_ZH/CustomBGM/使用说明.txt)

```text
Example_ZH/CustomBGM/
├── main.lua
├── 使用说明.txt
├── 1.mp3       # 自己放入，示例不附带音乐
└── 2.mp3
```

### 简单制作方法

1. 将 `Example_ZH/CustomBGM` 复制到 `游戏根目录\BobaCafeSimulator\Mods\CustomBGM\`。
2. 把自己制作或已获授权的 `.mp3` 直接放在 `CustomBGM` 根目录，不要放进子文件夹。
3. 需要时修改 `main.lua` 顶部的 `priority`、`SHUFFLE` 和 `VOLUME_MULTIPLIER`。
4. 在游戏 **Mods** 菜单中启用，重新进入游戏。

| 参数 | 作用 |
|---|---|
| `priority` | 多个 BGM Mod 同时启用时，数字越大越优先。 |
| `SHUFFLE` | `true` 随机播放，`false` 按文件名顺序播放。 |
| `VOLUME_MULTIPLIER` | Mod 的额外音量倍率，仍受游戏音乐音量设置控制。 |

核心调用：

```lua
playerController:RegisterBackgroundMusicMod(M.id, M.priority, start_background_music)
playerController:PlayModBackgroundMusicFromDirectory(MOD.ModDir, SHUFFLE, VOLUME_MULTIPLIER)
```

### 接口与播放规则

- `RegisterBackgroundMusicMod(modId, priority, callback)` 只负责注册背景音乐提供者。所有 Mod 加载完成后，系统按 `priority` 从高到低调用回调；同优先级时，后加载的 Mod 优先。
- 回调成功启动音乐后应返回 `true`。返回 `false` 时，系统会继续尝试下一个 BGM Mod。
- `PlayModBackgroundMusicFromDirectory` 只扫描 Mod 根目录直接包含的 `.mp3`，不会递归扫描子文件夹。
- 曲目结束后自动播放下一首，整轮播放完成后继续循环。
- 当前 Mod 没有可播放的 MP3 时，会继续尝试下一个 BGM Mod；所有提供者都失败时，回退到游戏默认 BGM。

> 上传 Steam 创意工坊时，只能包含你自己创作、允许再分发或已获得明确授权的音乐。

---

<a id="auto-pay-bill-example"></a>
## 💳 每天自动支付账单（AutoPayDailyBill 示例）

该示例使用每日早晨 Mod Hook，在服务器上按“水费 → 电费 → 租金 → 工资”的顺序支付账单。**只有服务器安装并启用该 Mod 时有效，普通客户端安装不会执行扣款。**

- [打开完整示例](Example_ZH/AutoPayDailyBill/)
- [查看 `main.lua`](Example_ZH/AutoPayDailyBill/main.lua)

```text
Example_ZH/AutoPayDailyBill/
└── main.lua
```

### 简单制作方法

1. 将 `Example_ZH/AutoPayDailyBill` 复制到 `游戏根目录\BobaCafeSimulator\Mods\AutoPayDailyBill\`。
2. 在游戏 **Mods** 菜单中启用，重新进入游戏。
3. 看到“已注册每日早晨回调”日志后，每次进入新一天的早晨都会自动检查账单。
4. 如果要改变支付优先级，调整 `main.lua` 中 `BILL_SEQUENCE` 的顺序。

核心调用：

```lua
playerController:RegisterDailyMorningModHook(M.id, on_daily_morning)
```

回调函数格式：

```lua
local function on_daily_morning(playerController, dayNumber)
    if not playerController or not playerController:HasAuthority() then
        return
    end

    -- 每天早晨需要执行的服务器逻辑
end
```

### 默认支付顺序

| 顺序 | 账单 | `Bill` 字段 | `BillType` |
|---:|---|---|---|
| 1 | 水费 | `WaterRate` | `WaterRate` |
| 2 | 电费 | `Utility` | `Utility` |
| 3 | 租金 | `Rent` | `Rent` |
| 4 | 工资 | `Payroll` | `Payroll` |

余额不足以支付当前项目时，示例会停止本次支付，不会跳过它继续支付后面的项目。如果要改变优先级，只调整 `BILL_SEQUENCE` 中四个项目的顺序。

### 自动支付流程

每成功支付一笔，示例会依次：

1. `TrySpendAllPlayerMoneyForAutoPayMod(amount)` 通过自动账单专用接口扣除共享金钱；传入的是大于零的支出金额。
2. `AddPaidBillToDayData(BillType, amount)` 把支付记录写入当天 `DayData`。
3. 清空对应账单字段，然后通过 `SetServerBill` 同步账单。
4. `AddPlayerTaskByTagName` 给“任务.支付1笔账单”进度加 `1`。
5. 全部支付结束后显示一次汇总提示。

> `TrySpendAllPlayerMoneyForAutoPayMod` 是普通的服务端权限函数，不是 Server RPC。它会在 C++ 内再次检查 `HasAuthority()`、金额必须大于 `0`、金额必须是有限数值且服务器余额必须足够；客户端调用不会转发到服务器，也不能通过传入负数增加金钱。
>
> 账单和共享金钱是服务器状态，不要删除 `HasAuthority()`、`PlayerIndex` 和 API 完整性检查，否则多人游戏可能重复扣款或产生不同步。Mod 示例不要改用任何通用的加减钱 RPC。

---

<a id="localization"></a>
## 🌐 本地化（多语言支持）

奶茶 Mod 的本地化分为两层：

1. **Mods 菜单元数据**：`name`、`description` 以及 `name_zh`、`description_zh` 等语言后缀字段。
2. **游戏内饮品文本**：`FDrinkData.DisplayName`、`MakeNeedTutorialText`、`ShowGetWayText` 等运行时字段。

完整可运行示例位于：

- [Example_ZH/LocalizedPumpkinDrink/](Example_ZH/LocalizedPumpkinDrink/)
- [直接查看 main.lua](Example_ZH/LocalizedPumpkinDrink/main.lua)

```text
Example_ZH/LocalizedPumpkinDrink/
├── main.lua
├── 5290.png
└── preview.png
```

### Mods 菜单名称与描述

Mods 菜单扫描阶段不会执行 Lua，而是直接从 `main.lua` 中读取字符串字面量。因此默认文本和各语言文本应明确写成：

```lua
name           = "Localized Pumpkin Juice"
description    = "Adds a localized pumpkin juice recipe."
name_zh        = "本地化南瓜汁示例"
description_zh = "添加一个支持多语言显示的南瓜汁配方。"
name_ja        = "ローカライズかぼちゃジュース例"
description_ja = "多言語表示に対応したかぼちゃジュースを追加します。"
```

默认字段 `name`、`description` 用作英文回退。语言后缀使用两位代码，例如：

- `zh`：中文
- `en`：英文，使用默认字段
- `ja`：日文
- 还可以继续添加 `fr`、`de`、`es`、`ru` 等字段

### 游戏内饮品文本

运行时通过 `GetCurrentCulture()` 获取当前文化代码，再从饮品翻译表中选择文本：

```lua
local DrinkText = {
    en = {
        DisplayName = "Pumpkin Juice",
        Tutorial = "Put a pumpkin into the juicer to make pumpkin juice.",
        GetWay = "Added by the localization example Mod.",
    },
    zh = {
        DisplayName = "南瓜汁（本地化示例）",
        Tutorial = "将南瓜放入榨汁机，制作南瓜汁。",
        GetWay = "由本地化示例 Mod 添加。",
    },
    ja = {
        DisplayName = "かぼちゃジュース",
        Tutorial = "かぼちゃをジューサーに入れてジュースを作ります。",
        GetWay = "ローカライズ例のModで追加されます。",
    },
}
```

示例当前支持中文、英文、日文；其他语言自动回退到英文。新增语言时，需要同时补充 Mods 菜单的 `name_xx`/`description_xx` 和运行时 `DrinkText.xx`。

---

<a id="workshop-upload"></a>
## 🛠️ 上传 Steam 创意工坊

下面是 Windows 环境下从准备文件到首次发布、后续更新的完整流程。本游戏的 Steam App ID 是 **`3683770`**。Valve 官方参考：[SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) 和 [Steam Workshop Implementation Guide](https://partner.steamgames.com/doc/features/workshop/implementation?l=schinese)。

开始前请确认：

- 上传使用的 Steam 账号可以正常登录，并拥有本游戏。
- Steam 账号没有创意工坊/社区功能限制。
- 已经准备好可在本地游戏中正常运行的 Mod。
- Windows 资源管理器已开启“查看 → 显示 → 文件扩展名”，避免把 VDF/BAT 误存为 `.vdf.txt` 或 `.bat.txt`。

### 第 1 步：下载并初始化 SteamCMD

1. 在 C 盘建立一个纯英文目录：`C:\SteamCMD\`。
2. 从 Valve 官方 SteamCMD 页面下载 Windows 版 `steamcmd.zip`。
3. 将 ZIP 里的文件解压到 `C:\SteamCMD\`，确认存在 `C:\SteamCMD\steamcmd.exe`。
4. 双击 `steamcmd.exe`。首次启动会下载和更新必要文件，看到 `Steam>` 提示符后输入 `quit` 退出。

> SteamCMD 需要联网并登录你自己的 Steam 账号。不要把密码或 Steam Guard 验证码写入 `.bat`、VDF 或上传到仓库。

### 第 2 步：整理待上传的 Mod

建议先建立专用的上传目录，路径和文件名使用英文：

```text
D:\BobaWorkshop\
├── Mods\
│   └── LocalizedPumpkinDrink\
│       ├── main.lua
│       ├── preview.png
│       └── 5290.png
└── Upload\
    ├── LocalizedPumpkinDrink.vdf
    └── upload_LocalizedPumpkinDrink.bat
```

上传前逐项检查：

1. 把 `LocalizedPumpkinDrink` 复制到 `游戏根目录\BobaCafeSimulator\Mods\`，在游戏的 **Mods** 菜单中启用。
2. 进入游戏确认 Mod 能加载，配方、图片和文本都正常。
3. `contentfolder` 指向的文件夹里必须直接看到 `main.lua`，不能变成 `LocalizedPumpkinDrink\LocalizedPumpkinDrink\main.lua`。
4. `preview.png` 建议使用 256×256 正方形 PNG，并确认能正常打开。

### 第 3 步：创建上传配置 VDF

在 `D:\BobaWorkshop\Upload\` 中新建纯文本文件 `LocalizedPumpkinDrink.vdf`，使用 **UTF-8** 编码保存，并填入：

```vdf
"workshopitem"
{
    "appid"            "3683770"
    "publishedfileid"  "0"
    "contentfolder"    "D:\\BobaWorkshop\\Mods\\LocalizedPumpkinDrink"
    "previewfile"      "D:\\BobaWorkshop\\Mods\\LocalizedPumpkinDrink\\preview.png"
    "visibility"       "2"
    "title"            "本地化南瓜汁示例"
    "description"      "演示奶茶配方与 Mod 信息的多语言支持。"
    "changenote"       "v1.0.0"
}
```

VDF 字段说明：

| 字段 | 怎么填 |
|---|---|
| `appid` | 固定填 `3683770`。 |
| `publishedfileid` | 首次发布填 `0`；成功后 SteamCMD 会自动写回创意工坊物品 ID。 |
| `contentfolder` | 待上传的 Mod 文件夹绝对路径。VDF 中的 Windows 路径使用双反斜杠 `\\`。 |
| `previewfile` | 创意工坊预览图的绝对路径。 |
| `visibility` | `0` 公开，`1` 仅好友，`2` 私密，`3` 不列出。建议首次填 `2`，测试完成后再改为 `0`。 |
| `title` | 创意工坊页面标题。 |
| `description` | 创意工坊页面描述。 |
| `changenote` | 本次发布/更新说明，例如 `v1.0.0 首次发布`。 |

### 第 4 步：创建一键上传批处理

在 `D:\BobaWorkshop\Upload\` 中新建 `upload_LocalizedPumpkinDrink.bat`，确认文件后缀是 `.bat` 而不是 `.bat.txt`，填入下面内容，只替换 `YourSteamAccount` 为你的 Steam 登录账号：

```bat
@echo off
setlocal
set "STEAMCMD=C:\SteamCMD\steamcmd.exe"
set "VDF=D:\BobaWorkshop\Upload\LocalizedPumpkinDrink.vdf"

"%STEAMCMD%" +login YourSteamAccount +workshop_build_item "%VDF%" +quit

echo.
echo SteamCMD 已结束，请检查上方是否有 ERROR。
pause
```

`pause` 会让窗口保留，方便查看上传结果。如果 SteamCMD 或 VDF 位于其他路径，只修改对应的 `set` 行。

### 第 5 步：首次发布

1. 确认 VDF 中的 `publishedfileid` 是 `0`。
2. 双击 `upload_LocalizedPumpkinDrink.bat`。
3. 按 SteamCMD 提示输入密码；如果开启了 Steam Guard，再输入本次的验证码。
4. 等待上传结束，检查窗口中没有 `ERROR` 或 `Failed`。
5. 用文本编辑器重新打开 VDF。上传成功后，`publishedfileid` 会从 `0` 变为一串数字；请备份这份 VDF。
6. 把这串数字填到下面地址的末尾，打开你的创意工坊页面：

   `https://steamcommunity.com/sharedfiles/filedetails/?id=创意工坊物品ID`

7. 首次发布可能需要在页面上接受 Steam 创意工坊法律协议；未接受时，物品可能处于隐藏状态。
8. 测试没问题后，将 VDF 的 `visibility` 改为 `0`并再上传一次，然后在创意工坊页面确认对外可见。

### 第 6 步：更新已发布的 Mod

1. 修改 `contentfolder` 中的 `main.lua`、图片或其他资源。
2. 在本地 Mods 目录里测试新版本。
3. 修改 VDF 的 `changenote`。
4. **保留 SteamCMD 已写入的 `publishedfileid`，不要改回 `0`**。改回 `0` 会尝试创建另一个新条目。
5. 再次双击同一个上传 BAT，SteamCMD 会根据 `publishedfileid` 更新原条目。

### 第 7 步：订阅验收

1. 在创意工坊页面点击“订阅”。
2. 等待 Steam 客户端的下载页面显示创意工坊内容已下载，再启动游戏。
3. 在游戏 **Mods** 菜单中启用该 Mod，重新进入游戏验证。

已订阅文件通常位于：

`[Steam 安装目录]\steamapps\workshop\content\3683770\[创意工坊物品ID]\`

### 常见问题排查

| 现象 | 优先检查 |
|---|---|
| SteamCMD 报找不到 VDF/图片 | BAT 中的 `VDF` 路径、VDF 中的 `previewfile` 是否为存在的绝对路径。 |
| 订阅后 Mods 菜单找不到 | 进入数字 ID 缓存目录，确认其中直接存在 `main.lua`，没有多套一层文件夹。 |
| 配方图片不显示 | 检查 `ImagePath = dir .. "图片名.png"` 与实际文件名的大小写和后缀。 |
| 上传成功但页面不公开 | 检查 `visibility`，并打开物品页接受创意工坊法律协议。 |
| 修改后却创建了新物品 | 更新时不能把 `publishedfileid` 重置为 `0`；使用上一次成功上传后的 VDF。 |
| 需要查更详细的错误 | 查看 Steam 目录下的 `logs\Workshop_log.txt` 和 `workshopbuilds\depot_build_3683770.log`。 |

---

<a id="contact"></a>
## 📮 更多API接口以及扩展：联系方式
- 官方QQ群（联系群主）：722792074  
- Email：yangyiming780@foxmail.com  
- Steam 社区留言 / Git issues

---

<a id="community-rules"></a>
## 🛡️ 社区准则（简要）
1. 🚫 禁止违法、政治敏感、色情、暴恐等内容。  
2. 🚫 禁止恶意侮辱、引战对立、影射现实人物的内容。  
3. 🚫 禁止未获授权使用受版权保护的资源。  
4. 🚫 禁止以 Mod 形式引导广告、募捐或付费。
   
若在 Steam 创意工坊发布且违反以上条目，可能被直接删除并封禁相关创作者权限。

---

<a id="id-appendix"></a>
## 📚 附录：ID 参考表

每条记录都单独占一行，可直接按 `ID`、`FName`、`名称`、`Color1`、`Color2` 查找。日志中的 `ID:0` 记录按原值保留。

### 当前液体/饮品 ID、名称与颜色

基础液体的 `FName` 可直接填写到配方的液体类型字段中；没有预置 `FName` 的成品饮品以 `—` 表示。

> `Drink.Honey`（蜂蜜）也是可用于配方的原料液体 FName；当前颜色清单中没有单独的“蜂蜜”记录。

| ID | FName | 名称 | Color1 | Color2 |
|---:|---|---|---|---|
| 0 | `Drink.Syrup` | 糖浆 | `R=1 G=0.857 B=0.078 A=1` | `R=1 G=0.907 B=0.143 A=1` |
| 0 | `Drink.PumpkinJuice` | 南瓜汁 | `R=0.644 G=0.28 B=0 A=1` | `R=0.585 G=0.275 B=0 A=1` |
| 0 | `Drink.HotMilk` | 烤奶 | `R=0.637 G=0.861 B=0.765 A=1` | `R=0.852 G=0.798 B=0.616 A=1` |
| 0 | `Drink.PineappleJuice` | 菠萝汁 | `R=1 G=0.678 B=0 A=1` | `R=1 G=0.887 B=0 A=1` |
| 0 | `Drink.JackfruitJuice` | 菠萝蜜汁 | `R=1 G=0.816 B=0.233 A=1` | `R=1 G=0.902 B=0.291 A=1` |
| 0 | `Drink.AppleJuice` | 苹果汁 | `R=0.9 G=0.599 B=0.245 A=1` | `R=0.8 G=0.506 B=0.194 A=1` |
| 0 | `Drink.PeachJuice` | 桃汁 | `R=1 G=0.321 B=0.465 A=1` | `R=1 G=0.431 B=0.58 A=1` |
| 0 | `Drink.MangoJuice` | 芒果汁 | `R=1 G=0.643 B=0 A=1` | `R=1 G=0.539 B=0 A=1` |
| 0 | `Drink.BananaJuice` | 香蕉汁 | `R=1 G=0.871 B=0 A=1` | `R=1 G=0.792 B=0 A=1` |
| 0 | `Drink.StrawberryJuice` | 草莓汁 | `R=1 G=0.168 B=0.258 A=1` | `R=1 G=0.161 B=0.193 A=1` |
| 0 | `Drink.PomegranateJuice` | 石榴汁 | `R=0.8 G=0.074 B=0.092 A=1` | `R=0.599 G=0.066 B=0.066 A=1` |
| 0 | `Drink.CoconutMilk` | 椰奶 | `R=1 G=1 B=1 A=1` | `R=1 G=1 B=1 A=1` |
| 0 | `Drink.FruitJelly` | 果冻汁 | `R=0.021 G=0.9 B=0.032 A=1` | `R=0.198 G=1 B=0.061 A=1` |
| 0 | `Drink.MagmaJelly` | 岩浆果冻汁 | `R=1 G=0.11 B=0.453 A=1` | `R=1 G=0.102 B=0.202 A=1` |
| 0 | `Drink.GhostWater` | 幽灵水 | `R=0.8 G=0.9 B=1 A=0.5` | `R=0.7 G=0.95 B=1 A=1` |
| 0 | `Drink.RustyIronWater` | 生锈铁水 | `R=0.5 G=0.205 B=0.153 A=0.7` | `R=0.432 G=0.275 B=0.17 A=1` |
| 0 | `Drink.HotWater` | 热水 | `R=0.382 G=0.965 B=1 A=1` | `R=0.622 G=0.866 B=0.96 A=1` |
| 0 | `Drink.PureWater` | 纯净水 | `R=0.311 G=0.848 B=1 A=1` | `R=0.624 G=0.863 B=0.956 A=1` |
| 0 | `Drink.SashimiGreenTea` | 生鱼片绿茶 | `R=0.553 G=0.564 B=0.128 A=1` | `R=0.408 G=0.46 B=0.11 A=1` |
| 0 | — | 酸奶 | `R=0.95 G=0.95 B=0.716 A=1` | `R=1 G=1 B=0.859 A=1` |
| 5001 | — | 柠檬水 | `R=1 G=0.604 B=0.049 A=1` | `R=1 G=0.604 B=0.049 A=1` |
| 5002 | `Drink.WatermelonJuice` | 西瓜汁 | `R=0.672 G=0.08 B=0.071 A=1` | `R=0.672 G=0.064 B=0.055 A=1` |
| 5003 | — | 暴打鲜橙 | `R=0.991 G=0.391 B=0.047 A=1` | `R=0.964 G=0.391 B=0.094 A=1` |
| 5006 | `Drink.SqueezeOrangeJuice` | 榨橙汁 | `R=1 G=0.261 B=0 A=1` | `R=1 G=0.226 B=0 A=1` |
| 5005 | `Drink.Milk` | 牛奶 | `R=1 G=0.967 B=0.905 A=1` | `R=1 G=0.972 B=0.918 A=1` |
| 5007 | `Drink.GreenTea` | 绿茶 | `R=0.223 G=0.297 B=0.086 A=1` | `R=0.234 G=0.31 B=0.095 A=1` |
| 5014 | `Drink.Coffee` | 热咖啡 | `R=0.05 G=0.014 B=0.004 A=1` | `R=0.068 G=0.019 B=0.005 A=1` |
| 5032 | `Drink.MilkTea` | 奶茶 | `R=0.356 G=0.212 B=0.09 A=1` | `R=0.373 G=0.191 B=0.037 A=1` |
| 5008 | — | 柠檬绿茶 | `R=0.553 G=0.564 B=0.128 A=1` | `R=0.408 G=0.46 B=0.11 A=1` |
| 5009 | — | 西瓜冰茶 | `R=0.701 G=0.286 B=0.196 A=1` | `R=0.701 G=0.296 B=0.216 A=1` |
| 5011 | — | 西瓜果奶 | `R=1 G=0.422 B=0.246 A=1` | `R=1 G=0.455 B=0.27 A=1` |
| 5013 | — | 香橙柠檬 | `R=1 G=0.836 B=0.155 A=1` | `R=1 G=0.63 B=0.097 A=1` |
| 5015 | — | 南瓜茶茶 | `R=0.401 G=0.21 B=0.059 A=1` | `R=0.46 G=0.242 B=0.015 A=1` |
| 5016 | — | 南瓜牛乳 | `R=0.661 G=0.504 B=0.24 A=1` | `R=0.627 G=0.395 B=0.179 A=1` |
| 5019 | — | 芋圆奶茶 | `R=0.453 G=0.265 B=0.321 A=1` | `R=0.353 G=0.266 B=0.411 A=1` |
| 5020 | — | 茉莉奶绿 | `R=0.695 G=0.7 B=0.303 A=1` | `R=0.779 G=0.95 B=0.437 A=1` |
| 5021 | — | 芋泥奶茶 | `R=0.516 G=0.397 B=0.595 A=1` | `R=0.76 G=0.574 B=0.365 A=1` |
| 5022 | — | 芋泥啵啵 | `R=0.576 G=0.454 B=0.658 A=1` | `R=0.658 G=0.378 B=0.44 A=1` |
| 5023 | — | 布丁奶茶 | `R=0.668 G=0.475 B=0.256 A=1` | `R=0.714 G=0.615 B=0.172 A=1` |
| 5024 | — | 奥奥奶茶 | `R=0.484 G=0.34 B=0.177 A=1` | `R=0.391 G=0.318 B=0.276 A=1` |
| 5025 | — | 红豆奶茶 | `R=0.717 G=0.411 B=0.214 A=1` | `R=0.568 G=0.338 B=0.338 A=1` |
| 5026 | — | 红豆奶布丁 | `R=0.716 G=0.381 B=0.16 A=1` | `R=0.565 G=0.337 B=0.337 A=1` |
| 5027 | — | 双拼奶茶 | `R=0.356 G=0.212 B=0.089 A=1` | `R=0.371 G=0.191 B=0.037 A=1` |
| 5028 | — | 椰果奶茶 | `R=0.76 G=0.6 B=0.42 A=1` | `R=0.9 G=0.9 B=0.95 A=1` |
| 5029 | — | 三拼霸气奶茶 | `R=0.76 G=0.6 B=0.42 A=1` | `R=0.1 G=0.1 B=0.1 A=1` |
| 5030 | — | 芝士奶盖奶茶 | `R=0.6 G=0.7 B=0.4 A=1` | `R=1 G=0.98 B=0.9 A=1` |
| 5031 | — | 奥奥芝士奶茶 | `R=0.761 G=0.597 B=0.418 A=1` | `R=0.543 G=0.405 B=0.358 A=1` |
| 5033 | — | 红气桂枣暖奶茶 | `R=0.6 G=0.239 B=0.149 A=1` | `R=0.741 G=0.567 B=0.218 A=1` |
| 5034 | — | 黑糖珍珠奶茶 | `R=0.356 G=0.212 B=0.089 A=1` | `R=0.523 G=0.327 B=0.21 A=1` |
| 5035 | — | 烤奶牛乳茶 | `R=1 G=0.965 B=0.905 A=1` | `R=0.685 G=0.95 B=0.662 A=1` |
| 5036 | — | 西瓜啵啵 | `R=1 G=0.3 B=0.35 A=1` | `R=1 G=0.9 B=0.9 A=1` |
| 5037 | — | 芋圆葡萄 | `R=0.45 G=0.25 B=0.55 A=1` | `R=0.65 G=0.5 B=0.75 A=1` |
| 5038 | — | 满杯百香果 | `R=0.9 G=0.8 B=0.2 A=1` | `R=0.429 G=0.502 B=0.283 A=1` |
| 5039 | — | 菠萝菠萝蜜 | `R=0.95 G=0.9 B=0.1 A=1` | `R=1 G=0.8 B=0.2 A=1` |
| 5040 | — | 苹果桃桃 | `R=1 G=0.7 B=0.75 A=1` | `R=0.9 G=0.8 B=0.4 A=1` |
| 5041 | — | 桃桃芒芒 | `R=0.97 G=0.726 B=0.767 A=1` | `R=1 G=0.82 B=0.387 A=1` |
| 5042 | — | 蓝莓果粒茶 | `R=0.259 G=0.233 B=0.5 A=1` | `R=0.285 G=0.215 B=0.4 A=1` |
| 5043 | — | 蜜桃甘露 | `R=1 G=0.623 B=0.686 A=1` | `R=0.981 G=1 B=0.634 A=1` |
| 5044 | — | 蜜桃绿茶 | `R=0.6 G=0.7 B=0.4 A=1` | `R=1 G=0.7 B=0.75 A=1` |
| 5045 | — | 百香菠萝 | `R=1 G=0.768 B=0.21 A=1` | `R=0.794 G=0.964 B=0.775 A=1` |
| 5046 | — | 茉莉青提 | `R=0.65 G=0.85 B=0.35 A=1` | `R=0.6 G=0.7 B=0.4 A=1` |
| 5047 | — | 薄荷绿茶 | `R=0.2 G=0.8 B=0.5 A=1` | `R=0.6 G=0.7 B=0.4 A=1` |
| 5048 | — | 石榴汁 | `R=0.8 G=0.1 B=0.15 A=1` | `R=0.9 G=0.2 B=0.25 A=1` |
| 5049 | — | 葡萄冻冻 | `R=0.45 G=0.25 B=0.55 A=1` | `R=1 G=0.7 B=0.98 A=0.5` |
| 5050 | — | 鲜芒果百香 | `R=1 G=0.783 B=0.262 A=1` | `R=0.915 G=0.965 B=0.571 A=1` |
| 5051 | — | 青梅冰茶 | `R=0.5 G=0.6 B=0.2 A=1` | `R=0.8 G=0.7 B=0.4 A=1` |
| 5052 | — | 阳光青提 | `R=0.65 G=0.85 B=0.35 A=1` | `R=0.9 G=0.95 B=0.8 A=1` |
| 5053 | — | 超级水果茶 | `R=0.9 G=0.5 B=0.2 A=1` | `R=0.8 G=0.9 B=0.2 A=1` |
| 5054 | — | 蜂蜜柚子茶 | `R=0.95 G=0.7 B=0.1 A=1` | `R=1 G=0.882 B=0.29 A=1` |
| 5055 | — | 拿铁 | `R=0.35 G=0.2 B=0.1 A=1` | `R=0.398 G=0.272 B=0.187 A=1` |
| 5056 | — | 椰椰拿铁 | `R=0.429 G=0.264 B=0.153 A=1` | `R=0.397 G=0.286 B=0.213 A=1` |
| 5057 | — | 葡萄美式 | `R=0.061 G=0.013 B=0.025 A=1` | `R=0.068 G=0.019 B=0.005 A=1` |
| 5058 | — | 茉莉拿铁 | `R=0.397 G=0.27 B=0.188 A=1` | `R=0.499 G=0.582 B=0.332 A=1` |
| 5059 | — | 苹果拿铁 | `R=0.397 G=0.285 B=0.211 A=1` | `R=0.967 G=0.588 B=0.505 A=1` |
| 5060 | — | 橙橙美式 | `R=0.151 G=0.073 B=0.037 A=1` | `R=0.148 G=0.084 B=0.021 A=1` |
| 5061 | — | 黄油拿铁 | `R=0.397 G=0.27 B=0.188 A=1` | `R=0.509 G=0.446 B=0.227 A=1` |
| 5062 | — | 蜜桃拿铁 | `R=0.397 G=0.27 B=0.188 A=1` | `R=0.564 G=0.395 B=0.423 A=1` |
| 5063 | — | 芒芒牛乳 | `R=1 G=0.767 B=0.207 A=1` | `R=0.832 G=0.832 B=0.576 A=1` |
| 5064 | — | 生椰杨枝甘露 | `R=1 G=0.735 B=0.099 A=1` | `R=0.95 G=0.95 B=0.602 A=1` |
| 5065 | — | 杨枝甘露 | `R=1 G=0.738 B=0.1 A=1` | `R=0.947 G=0.947 B=0.386 A=1` |
| 5066 | — | 桃胶牛乳 | `R=0.95 G=0.95 B=0.572 A=1` | `R=0.88 G=0.668 B=0.243 A=1` |
| 5067 | — | 西瓜椰椰 | `R=1 G=0.3 B=0.35 A=1` | `R=0.95 G=0.95 B=0.744 A=1` |
| 5068 | — | 生椰柠檬撞奶 | `R=0.95 G=0.95 B=0.562 A=1` | `R=0.95 G=0.898 B=0.173 A=1` |
| 5069 | — | 芋圆椰椰 | `R=0.95 G=0.95 B=0.92 A=1` | `R=0.658 G=0.52 B=0.75 A=1` |
| 5070 | — | 芒芒西米露 | `R=1 G=0.75 B=0.15 A=1` | `R=1 G=0.845 B=0.509 A=1` |
| 5071 | — | 牛油果西米露 | `R=0.56 G=0.75 B=0.306 A=1` | `R=0.985 G=1 B=0.634 A=1` |
| 5072 | — | 黑糖啵啵奶茶 | `R=0.762 G=0.428 B=0.263 A=1` | `R=0.55 G=0.304 B=0.181 A=1` |
| 5073 | — | 荧光柠檬水 | `R=0.867 G=1 B=0.172 A=1` | `R=0.675 G=1 B=0.178 A=1` |
| 5074 | — | 曼德拉草绿茶 | `R=0.066 G=0.65 B=0.155 A=1` | `R=0.245 G=0.6 B=0.191 A=1` |
| 5075 | — | 岩浆西瓜触手 | `R=0.95 G=0 B=0.012 A=1` | `R=1 G=0.278 B=0.12 A=1` |
| 5076 | — | 荧光曼德拉草柠檬 | `R=0.153 G=1 B=0.118 A=1` | `R=0.472 G=0.8 B=0.038 A=1` |
| 5077 | — | 幽灵烤奶 | `R=0.8 G=0.723 B=0.517 A=1` | `R=0.439 G=0.907 B=1 A=1` |
| 5078 | — | 铁锈绿茶 | `R=0.14 G=0.5 B=0.151 A=1` | `R=0.439 G=0.22 B=0.073 A=1` |
| 5079 | — | 幽灵曼德拉草 | `R=0.582 G=1 B=0.835 A=1` | `R=0.109 G=0.5 B=0.123 A=1` |
| 5080 | — | 铁锈蜜桃 | `R=0.832 G=0.443 B=0.443 A=1` | `R=0.432 G=0.21 B=0.062 A=1` |
| 5081 | — | 幽灵芒芒 | `R=1 G=0.633 B=0.119 A=1` | `R=0.345 G=0.891 B=1 A=1` |
| 5082 | — | 蝙蝠干美式 | `R=0.273 G=0.151 B=0.076 A=1` | `R=0.047 G=0.047 B=0.047 A=1` |
| 5083 | — | 深渊绿茶 | `R=0.408 G=0.65 B=0.166 A=1` | `R=0.7 G=0.442 B=0.425 A=1` |
| 5084 | — | 鬼火烤奶 | `R=1 G=0.892 B=0.664 A=1` | `R=1 G=0.068 B=0.064 A=1` |
| 5085 | — | 盘丝洞幽灵水 | `R=0.394 G=0.85 B=0.787 A=1` | `R=0.154 G=1 B=0.323 A=1` |
| 5086 | — | 克苏鲁触手杯 | `R=0.1 G=0.3 B=0.25 A=1` | `R=0.6 G=0 B=0.8 A=1` |
| 5087 | — | 盘丝洞葡萄茶 | `R=0.343 G=0.074 B=0.45 A=1` | `R=0.418 G=0.9 B=0.489 A=1` |
| 5088 | — | 蝙蝠椰椰 | `R=0.61 G=1 B=0.911 A=1` | `R=0.095 G=0.06 B=0.025 A=1` |
| 5089 | — | 幽灵奶芋圆 | `R=0.622 G=0.471 B=0.85 A=1` | `R=0.366 G=0.951 B=1 A=1` |
| 5090 | — | 冰火二重奏 | `R=0 G=0.543 B=1 A=1` | `R=1 G=0.005 B=0 A=1` |
| 5091 | — | 曼德拉生化西瓜汁 | `R=0.8 G=0.2 B=0.4 A=1` | `R=0.48 G=1 B=0.415 A=1` |
| 5092 | — | 蘑菇脏脏茶 | `R=0.227 G=0.096 B=0.04 A=1` | `R=0.5 G=0.316 B=0.171 A=1` |
| 5093 | — | 果冻粘液烤奶 | `R=0 G=1 B=0.031 A=1` | `R=0.219 G=0.9 B=0.347 A=1` |
| 5094 | — | 剧毒沼泽柠檬水 | `R=0.863 G=1 B=0.108 A=1` | `R=0.887 G=0.402 B=1 A=1` |
| 5095 | — | 深渊凝视 | `R=0.5 G=0 B=1 A=1` | `R=0.98 G=0.127 B=1 A=1` |
| 5096 | — | 岩浆熔岩饮 | `R=1 G=0.003 B=0 A=1` | `R=0.1 G=0.021 B=0 A=1` |
| 5097 | — | 蝙蝠拿铁 | `R=0.373 G=0.267 B=0.183 A=1` | `R=0.18 G=0.1 B=0.05 A=1` |
| 5098 | — | 阴暗孢子拿铁 | `R=0.175 G=0.112 B=0.081 A=1` | `R=0.447 G=0.162 B=0.7 A=1` |
| 5099 | — | 蝙蝠荒原奶茶 | `R=1 G=1 B=1 A=1` | `R=1 G=1 B=1 A=1` |
| 5100 | — | 沼泽冻冻 | `R=0.2 G=0.3 B=0.2 A=1` | `R=0.2 G=1 B=0.1 A=1` |
| 5101 | — | 炼狱苦水 | `R=0 G=0 B=0 A=1` | `R=1 G=0.3 B=0 A=1` |
| 5102 | — | 致幻真菌牛乳 | `R=0.8 G=0.4 B=0.8 A=1` | `R=0 G=0.5 B=1 A=1` |
| 5103 | — | 深渊诱捕蜜酿 | `R=0.079 G=0 B=0.1 A=1` | `R=0.926 G=1 B=0 A=1` |
| 5104 | — | 虚空黑洞 | `R=0 G=0.017 B=1 A=1` | `R=0.007 G=0 B=0.5 A=1` |
| 5105 | — | 银河星尘露 | `R=0 G=0.471 B=1 A=1` | `R=0.309 G=0 B=1 A=1` |
| 5106 | — | 贤者之石特调 | `R=0.7 G=0.138 B=0.001 A=1` | `R=0.546 G=1 B=0 A=1` |
| 5108 | `Drink.CherryJuice` | 车厘子汁 | `R=0.7 G=0.1 B=0.15 A=1` | `R=0.7 G=0.1 B=0.15 A=1` |
| 5107 | — | 红宝石橙汁 | `R=0.95 G=0.35 B=0.1 A=1` | `R=1 G=0.6 B=0.05 A=1` |
| 5109 | — | 红运牛乳 | `R=0.92 G=0.75 B=0.8 A=1` | `R=0.96 G=0.96 B=0.92 A=1` |
| 5110 | — | 美式糖葫芦 | `R=0.18 G=0.1 B=0.05 A=1` | `R=0.85 G=0.1 B=0.1 A=1` |
| 5111 | — | 爆竹奶茶 | `R=0.65 G=0.75 B=0.55 A=1` | `R=1 G=0.2 B=0.2 A=1` |
| 5112 | — | 爆红车厘子 | `R=0.7 G=0.05 B=0.15 A=1` | `R=1 G=0.2 B=0.2 A=1` |
| 5113 | — | 爆裂糖葫芦 | `R=0.7 G=0.05 B=0.15 A=1` | `R=0.85 G=0.1 B=0.1 A=1` |
| 5114 | — | 香蕉牛乳 | `R=0.982 G=0.807 B=0.371 A=1` | `R=0.982 G=0.807 B=0.371 A=1` |
| 5115 | — | 草莓牛乳 | `R=0.991 G=0.479 B=0.474 A=1` | `R=0.991 G=0.815 B=0.753 A=1` |
| 5116 | — | 薄荷巧克力拿铁 | `R=0.558 G=0.397 B=0.216 A=1` | `R=0.716 G=0.839 B=0.658 A=1` |
| 5117 | — | 苹果茉莉 | `R=0.839 G=0.839 B=0.515 A=1` | `R=0.839 G=0.831 B=0.509 A=1` |
| 5118 | — | 香蕉拿铁 | `R=0.88 G=0.571 B=0.216 A=1` | `R=0.982 G=0.839 B=0.558 A=1` |
| 5119 | — | 香蕉绿茶 | `R=0.597 G=0.624 B=0.153 A=1` | `R=0.839 G=0.839 B=0.434 A=1` |
| 5120 | — | 超级酸奶捞 | `R=1 G=1 B=1 A=1` | `R=1 G=1 B=1 A=1` |
| 5121 | — | 草莓酸奶 | `R=0.982 G=0.672 B=0.651 A=1` | `R=0.973 G=0.905 B=0.847 A=1` |
| 5122 | — | 香蕉酸奶 | `R=0.991 G=0.913 B=0.651 A=1` | `R=0.991 G=0.913 B=0.651 A=1` |
| 5123 | — | 薄荷奶绿 | `R=0.223 G=0.497 B=0.086 A=1` | `R=0.552 G=0.694 B=0.301 A=1` |
| 5124 | — | 茉莉绿茶 | `R=0.73 G=0.768 B=0.258 A=1` | `R=0.738 G=0.784 B=0.275 A=1` |
| 5125 | — | 红苹果奶绿 | `R=0.665 G=0.745 B=0.279 A=1` | `R=0.88 G=0.896 B=0.701 A=1` |
| 5126 | — | 苹果牛乳 | `R=0.991 G=0.871 B=0.565 A=1` | `R=0.991 G=0.905 B=0.658 A=1` |

### 当前小料 ID

```text
1102 柠檬片
1103 橙子片
1105 纯净水工具
1106 榨汁机工具
1107 珍珠
1108 小票
7001 芋圆
7002 茉莉花酱
7003 芋泥
7004 啵啵
7005 布丁
7006 奥奥
7007 桃胶
7008 紫米露
7009 芒果丁
7010 牛油果丁
7011 蜜桃丁
7012 菠萝丁
7013 蓝莓
7014 黄油
7015 红豆
7016 黑糖
7017 冻冻
7018 柚子粒
7019 青梅
7020 蜂蜜
7021 百香果
7022 芝士奶盖
7023 红枣干
7024 桂圆干
7025 椰果
7026 剥皮青提
7027 剥皮葡萄
7028 薄荷
7029 西米露
7030 荧光柠檬片
7031 墓地蘑菇
7032 蝙蝠干
7033 曼德拉草片
7034 蜘蛛丝
7035 深渊之眼
7036 岩浆触手片
7037 贤者之石
7038 鬼火
7039 星辰棱石
7040 果冻粘液
7041 岩浆果冻粘液
7042 幽灵水
7043 生锈铁水
7044 爆竹
7045 糖葫芦
7046 丘比特糖浆
7047 味觉失忆粉
7048 完美滤镜香精
7049 生鱼片
7050 骷髅鱼骨粉
```

### 教程提示图标 ID

下表用于 `D.ShowTutorialsItemID:Add(ID)`。

```text
1004 西瓜
1005 橙子
1007 牛奶
1008 绿茶
1010 煮锅
1012 榨汁机
1028 研磨器
1029 咖啡豆
1030 咖啡冲泡机
1033 南瓜
1036 苹果
1040 桃子
1045 草莓
1047 菠萝
1054 香蕉
1092 菠萝蜜
1093 芒果
1094 石榴
1105 纯净水工具
1106 榨汁机工具
1116 椰奶
1142 离心机
1143 8J特级车厘子
1175 酸奶机
3033 输液器
```
