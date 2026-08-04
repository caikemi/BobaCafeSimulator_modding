# 内容 API：饮品、样式、加料规则与家具

[返回中文首页](../../README.md) | [English](../en/04-content-api.md)

所有内容注册都需要 `content.register`，只能在 `OnLoad` 的 Loading 阶段调用。定义先暂存，整个 MOD 成功后才进入内部注册表。

## 通用模式

```lua
local M = {}

local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "ModAPI returned no result")
    end
end

function M.OnLoad(Context)
    -- Make...Definition → 填字段 → Register...
    return true
end

return M
```

同一 MOD 中每个 `ContentId` 必须唯一。注册新内容时不要设置 `bPatchExisting`。修改已有内容时设置为 `true`，并同时申请 `content.patch`。

## 注册饮品

```lua
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
```

### FBaseInstallModDrinkDefinition

| 字段 | 类型/默认值 | 说明 |
| --- | --- | --- |
| `ContentId` | FName | MOD 内唯一内容 ID，必填 |
| `DrinkId` | int / 0 | 游戏配方 ID；新配方必填且不能冲突 |
| `DisplayName` | text | 游戏内显示名 |
| `DrinkType` | `MilkTea` | `MilkTea`、`FruitTea`、`Coffee`、`SweetSoup`、`IceCream` |
| `Seasons` | 四季 | `Spring`、`Summer`、`Autumn`、`Winter` |
| `ImageRelativePath` | string | MOD 根目录内图片相对路径 |
| `SmallPrice` | 0 | S 杯价格，必须非负 |
| `MediumPrice` | 0 | M 杯价格，必须非负 |
| `LargePrice` | 0 | L 杯价格，必须非负 |
| `OutputLiquidId` | FName | 成品液体 ID，例如 `Drink.PumpkinJuice` |
| `RequiredItemIds` | int array | 制作要求的物品 ID；重复添加表示多份 |
| `SweetnessOptions` | 全甜度 | `Sweet10`、`Sweet7`、`Sweet5`、`Sweet3`、`Sweet0` |
| `TemperatureOptions` | 全温度 | `Hot`、`Normal`、`SmallIce`、`Ice` |
| `PerfectLiquids` | ratio array | 完美配方的液体和占比范围 0–1 |
| `PerfectItems` | map | 物品 ID 字符串到所需数量，例如 `"1103" → 4` |
| `TutorialItemIds` | int array | 配方教程图标顺序 |
| `TutorialText` | text | 制作说明 |
| `AcquisitionText` | text | 配方获取方式 |
| `UnlockedItemGroups` | FName array | 获得配方后解锁的物品组 |
| `bPatchExisting` | false | 是否覆盖已有 DrinkId |

要自定义季节/甜度/温度，可以先赋空表再 Add：

```lua
drink.Seasons = {}
drink.Seasons:Add("Summer")
drink.TemperatureOptions = {}
drink.TemperatureOptions:Add("Ice")
```

新饮品提交后，宿主自动同步到现有“拥有的配方”数据。MOD 作者不需要、也不应调用旧 `EvAddDrink`。卸载时只移除该 MOD 首次加入的配方，不会删除宿主原有配方。

建议新饮品 ID 使用项目预留区间；当前示例使用 5200/5201。发布前仍要和其他公开 MOD 协调，API 不提供全球 ID 分配服务。

## 注册饮品样式

```lua
local style = Context.Content:MakeDrinkStyleDefinition()
style.ContentId = "pumpkin_orange_style"
style.LiquidId = "Drink.PumpkinOrange"
style.DrinkId = 5200
style.DisplayName = "南瓜橙橙"
style.PrimaryColor = Context.Content:MakeColor(1.0, 0.58, 0.12, 1.0)
style.SecondaryColor = Context.Content:MakeColor(1.0, 0.58, 0.12, 1.0)
require_success(Context.Content:RegisterDrinkStyle(style))
```

颜色分量是 RGBA 0–1。字段：

- `ContentId`：事务唯一 ID。
- `LiquidId`：样式注册键。
- `DrinkId`：关联配方 ID。
- `DisplayName`：样式显示名。
- `PrimaryColor`、`SecondaryColor`：两层液体颜色。
- `bPatchExisting`：覆盖已有样式。

只修改已有柠檬水颜色：

```lua
local style = Context.Content:MakeDrinkStyleDefinition()
style.ContentId = "red_lemon_water_style"
style.LiquidId = "Drink.LemonWater"
style.PrimaryColor = Context.Content:MakeColor(1, 0, 0, 1)
style.SecondaryColor = Context.Content:MakeColor(1, 0, 0, 1)
style.bPatchExisting = true
require_success(Context.Content:RegisterDrinkStyle(style))
```

这个写法需要 `content.register` 和 `content.patch`。禁用后原样式恢复；若多个 MOD 覆盖同一键，剩余覆盖层会按顺序重放。

## 注册杯子加物品规则

当前公开规则是“杯中当前液体 + 新加入的一个物品 → 结果液体”：

```lua
local rule = Context.Content:MakeCupAddItemRuleDefinition()
rule.ContentId = "pumpkin_juice_plus_orange"
rule.CurrentLiquidId = "Drink.PumpkinJuice"
rule.AddedItemId = "1103"
rule.ResultLiquidId = "Drink.PumpkinOrange"
require_success(Context.Content:RegisterCupAddItemRule(rule))
```

字段是 `ContentId`、`CurrentLiquidId`、`AddedItemId`、`ResultLiquidId` 和 `bPatchExisting`。

v3 当前没有公开“液体 + 液体”或任意复杂完美混合规则注册接口。不要从清单 Lua 访问内部饮品注册表来绕过。

## 注册家具

资源 PAK 和 ShaderArchive 由宿主在 Lua 入口前处理。Lua 只提交稳定的家具定义：

```lua
local furniture = Context.Content:MakeFurnitureDefinition()
furniture.ContentId = "dog_01"
furniture.ItemId = "Mod_AnimalDecoration_Dog_01"
furniture.DisplayName = "小狗装饰摆件"
furniture.Description = "动物装饰资产包中的小狗主题家具摆件。"
furniture.CategoryTag = "购买.装饰.家具"
furniture.MeshObjectPath = "/Game/AddMeshTestMod1/SM_ToyDog_01.SM_ToyDog_01"
furniture.PreviewImageRelativePath = "SM_ToyDog_01.png"
furniture.ActorClassPath =
    "/Script/Engine.Blueprint'/Game/2Game/Blueprint/商店饰品/BP_家具2100随意放置.BP_家具2100随意放置'"
furniture.BoxClassPath =
    "/Script/Engine.Blueprint'/Game/1Game/Blueprint/AI/BP/货物包裹/BP_货物包裹建筑.BP_货物包裹建筑'"
furniture.PurchasePrice = 50
furniture.UnlockLevel = 0
furniture.BoxHeight = 50
furniture.BoxType = 2
furniture.bShowInShop = true
furniture.bAllowPainting = false
require_success(Context.Content:RegisterFurniture(furniture))
```

### FBaseInstallModFurnitureDefinition

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `ContentId` | 空 | MOD 内唯一 ID |
| `ItemId` | 空 | 内部物品注册键；新家具必须唯一 |
| `DisplayName` | 空 | 商店/物品显示名 |
| `Description` | 空 | 说明 |
| `CategoryTag` | `购买.装饰.家具` | 物品分类 |
| `MeshObjectPath` | 空 | Cook 后 `/Game/.../Asset.Asset` 对象路径 |
| `PreviewImageRelativePath` | 空 | MOD 根目录内预览图 |
| `ActorClassPath` | 空 | 放置后的 Actor 类路径 |
| `BoxClassPath` | 空 | 商店配送箱类路径 |
| `PurchasePrice` | 0 | 非负价格 |
| `UnlockLevel` | 0 | 非负解锁等级 |
| `BoxHeight` | 50 | 包裹高度 |
| `BoxType` | 2 | 宿主包裹类型 |
| `bShowInShop` | true | 是否显示在商店 |
| `bAllowPainting` | false | 是否允许涂装 |
| `ExtraFunctions` | map | 宿主定义的额外字符串功能参数 |
| `bPatchExisting` | false | 是否覆盖已有 ItemId |

宿主在提交时把定义适配成 BaseInstall 使用的内部物品数据。MOD 不应引用 `FItemDataRuntime` 或 `UGB_ItemDataSubsystem`。完整 Cook/PAK/ShaderArchive 流程见[模型资产 PAK 教程](../../Model_PAK_Packaging_ZH.md)。

## 回滚语义

- 新增：卸载时删除 MOD 创建的条目。
- 覆盖：卸载时恢复覆盖前值。
- 多层覆盖：移除中间层后，宿主从原值重放剩余层。
- 加载失败：任何一项失败，整个 MOD 内容不发布。
- 原游戏：没有 MOD 或没有内容注册时不改变原逻辑。
