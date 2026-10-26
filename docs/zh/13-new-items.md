# 新增独立商店物品：水桶与液体容器

[English](../en/13-new-items.md) | [全部商店分类与类路径](14-shop-reference.md) | [共用 JSON](../reference/shop-reference.json)

本教程面向包含 `Context.Content:RegisterItem()` 的 API v3 游戏构建。它注册新的 `ItemId`，保留原版物品。只修改所有原版液体容器参数的旧 `RegisterLiquidContainer` 与这里的新增物品接口用途不同。

工程提供两个入门示例；另有第 8 节的 20L 苹果汁桶与 100L 自停容器完整发布包：

| 示例 | 新 ItemId | 真实模板 ItemId | 模板实际 Actor 类 |
| --- | --- | --- | --- |
| [NewWaterBucketItem](../../Example_ZH/NewWaterBucketItem/README.md) | `Mod_NewWaterBucket_20000` | `1022` 桶装矿泉水 | `/Game/2Game/Blueprint/BP_1022水桶.BP_1022水桶_C` |
| [NewLiquidContainerItem](../../Example_ZH/NewLiquidContainerItem/README.md) | `Mod_NewLiquidContainer_20000` | `3015` 液体容器 | `/Game/2Game/Blueprint/商店货物/BP_设施3015_水容器_Child.BP_设施3015_水容器_Child_C` |

模板来源是当前工程十张 UE DataTable 的真实导出；`3015` 的商品类是 `BP_液体容器` 的商店子类。`TemplateItemId` 填物品 ID，不填资产名。不要用商店表中没有 Actor 类的扩建、配方等条目作为可生成物品模板。

### 所需游戏构建（2026-10-26 功能基线）

`apiVersion: 3` 或存在 `RegisterItem` 不能证明旧游戏已支持完整购买链。使用实际包含下列宿主修复的游戏构建：

- 模板从当前注册表复制，并从真实商店行补齐缺失的配送类、价格、解锁等级、数量及箱型等字段；已有非空运行时值优先。
- 商品/材料等原有商店入口合并当前世界的可见运行时物品 ID，随后沿用现有搜索、卡片、图标、购物车和购买流程。
- 直接配送本体的 Mod 物品按所购 `ItemId` 初始化；真正的包装箱保留箱子身份，并单独保存包裹内物品 ID。
- 新实例在服务端 BeginPlay 完成后应用一次初始液量；读档、重复初始化和注册表刷新不重新补满。

这些属于游戏宿主实现，不是新的 Lua 权限或 API 版本。玩家只需使用新版游戏与公开 Content 接口；无需在 Lua 访问内部 UObject，也不要把修改过的 `BPFL_Normal`、`BP_AIManager` 或原版父蓝图打进 Mod PAK。更新 SDK/原生宿主后重启编辑器，再重新进入并购买验证。

## 1. 最小目录和清单

```text
NewWaterBucketItem/
├── mod.json
└── v3.lua
```

```json
{
  "schemaVersion": 1,
  "id": "NewWaterBucketItem",
  "name": "独立大容量水桶",
  "version": "1.0.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": ["content.register"]
}
```

新增物品只需要 `content.register`；保持 `bPatchExisting=false`。只有明确要覆盖已经存在的 `ItemId` 时，才设置 `true` 并增加 `content.patch`，两个入门示例均不覆盖原物品。

`side: both` 让主机和客户端分别加载定义。现有房间兼容检查会比较 Mod ID 和加载顺序并预挂载 PAK；`exact-match` 字段尚未实现版本/内容哈希级握手，不能保证双方版本或内容一致，仍须安装同版本 MOD。

## 2. 从模板创建独立物品

`MakeItemDefinition()` 返回公开定义。宿主先从真实注册表复制整个运行时模板（包括 Function、使用模式与图标），再从对应真实商店行仅补缺失的类路径、配送、价格、等级、数量和箱型等字段；已有非空运行时值优先。随后才应用公开字段和明确设置的覆盖。`PurchasePrice=-1`、`UnlockLevel=-1` 可继续继承，无需在 Lua 重写原表常量。

```lua
local M = {}

function M.OnLoad(Context)
    local item = Context.Content:MakeItemDefinition()
    item.ContentId = "my_bucket"
    item.ItemId = "Mod_MyUniqueBucket"
    item.TemplateItemId = "1022"
    item.DisplayName = "我的水桶"
    item.Description = "独立商品，不改变原版水桶。"
    item.CategoryTag = "购买.商品.材料"
    item.PurchasePrice = 8
    item.UnlockLevel = 0
    item.bShowInShop = true
    item.ShopSortPriority = -100

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

    local result = Context.Content:RegisterItem(item)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "Item registration returned no result")
    end
    return true
end

return M
```

注册只允许在 `OnLoad` 的 Loading 阶段进行。成功返回表示定义已暂存；整个 MOD 加载成功后宿主才提交。每个返回值都必须检查，失败时输出 `Message` 或抛出错误，避免发布一个只注册了一部分的内容包。

`ContentId` 是 MOD 内唯一 ID，与饮品、家具等内容共用唯一性约束。`ItemId` 是真正用于购买、生成、库存和存档的独立物品 ID，应带作者或 MOD 前缀，避免与原版和其他 MOD 冲突。发布后保持这两个 ID 稳定。

## 3. 全部物品定义字段

| 字段 | 默认值 / 规则 |
| --- | --- |
| `ContentId` | 必填，MOD 内唯一。 |
| `ItemId` | 必填，新的全局物品注册键；两个示例不用原版 `1022` / `3015` 作为新键。 |
| `TemplateItemId` | 必填，当前真实注册表中存在的模板；例如 `"1022"`、`"3015"`。 |
| `DisplayName` | 必填，新物品显示名，不能为空。 |
| `Description` | 新物品说明；空值沿用模板说明。 |
| `CategoryTag` | 空值沿用模板分类；非空必须是宿主现有 Tag。 |
| `ActorClassPath` | 空值沿用模板 Actor 类；非空可指向已制作并 Cook 的自有派生蓝图。 |
| `BoxClassPath` | 空值通常沿用模板包装 / 配送类；直接配送本体的模板在改 Actor 类时自动跟随新类，详见下文。 |
| `PreviewImageRelativePath` | 空值沿用模板图标；非空为 MOD 目录内图片相对路径。 |
| `PurchasePrice` | `-1` 沿用模板价格；覆盖时为有限非负数。 |
| `UnlockLevel` | `-1` 沿用模板等级；覆盖时为非负整数。 |
| `bShowInShop` | `true`；是否出现在商店筛选结果中。 |
| `ShopSortPriority` | `0`；运行时查询与新增条目追加批次内的排序优先级，越小越靠前；旧商品页仍有静态顺序/解锁分组限制，见下文。 |
| `ExtraFunctions` | 空 map；在保留模板 Function 的基础上覆盖宿主支持的已知键。 |
| `Container` | 默认没有任何覆盖；用 `MakeContainerItemSettings()` 创建后赋给此字段。 |
| `bPatchExisting` | `false`；保持新增独立物品。覆盖已有物品还需 `content.patch`。 |

`CategoryTag` 决定物品属于哪个现有商店分类。水桶例用 `购买.商品.材料`，液体容器例用 `购买.商品.工具`；完整 29 项分类见[商店索引](14-shop-reference.md)。不要通过新建不存在的 Tag 或修改名称来控制分类和排序。

排序边界：原生运行时查询按 `ShopSortPriority → UnlockLevel → ItemId` 排序。旧商品/材料界面保留静态表顺序，只把新增运行时条目按该顺序追加，并会再次按等级排列锁定商品。因此 `ShopSortPriority` 不能保证在所有分类中跨原版商品、解锁分组任意指定绝对位置。它不改变分类，也不绕过解锁；发布前应在目标商店实际确认位置。

`ExtraFunctions` 是真实功能参数，不是任意蓝图变量名。只写当前宿主或对应蓝图已读取、且注册接口允许的 Function 键；索引中的原表 Function 提供查证来源，不代表每个键适用于每种 Actor。已有价格、类路径、显示状态等公开字段优先使用对应字段。

`ModItem.*` 是宿主保留的 Function 命名空间，不能通过 `ExtraFunctions` 写入。宿主先合并模板与 `ExtraFunctions`，再应用显式公开覆盖：非负价格/等级、非空类路径及公开显示设置优先；`PurchasePrice=-1`、`UnlockLevel=-1` 和留空类路径仍按继承/配送规则保留合并结果，不会无条件覆盖 map。Actor 类与配送箱类都必须是有效的 `AGB_TakeUpActor` 派生类，不能用非 Actor 数据或不兼容类凑出一个新商品。

`1022` 和 `3015` 的模板使用 `BoxClassPath == ClassPath`，直接配送物体本身。为这类模板设置自有 `ActorClassPath` 且留空 `BoxClassPath` 时，配送类会自动跟随新 Actor 类，因此实际买到的是你的子类。使用独立包装箱的其他模板仍沿用原箱类；需要特殊配送类时可显式设置 `item.BoxClassPath`。

购买初始化按所购独立 `ItemId` 配置直接配送本体的实例，不再读取水桶的默认 `1022` 或容器默认 `3045` 作为新商品身份。真正包装箱仍保留箱子自身 ID，所购物品 ID 存在包裹内容中；不要无条件把包装箱身份改成内容物 ID。

## 4. 容器专用字段

每个值都有独立覆盖开关。开关为 `false` 时，值不覆盖模板或蓝图行为。

| 开关 | 值及默认值 | 运行含义 |
| --- | --- | --- |
| `bOverrideMaxCapacity=false` | `MaxCapacity=10000` | 最大容量，覆盖时应为有限正数，使用原游戏容量单位。 |
| `bOverrideInitialCapacity=false` | `InitialCapacity=0` | 新物品初始液体数量；只在服务器首次创建时设置，不用于重填读档物品。 |
| `bOverrideOnlyAllowCupAddition=false` | `bOnlyAllowCupAddition=false` | 仅水桶支持。控制水桶的“只允许给杯子添加”；液体容器没有此字段，不能启用该覆盖。 |
| `bOverrideCupLiquidType=false` | `CupLiquidType="Drink.PureWater"` | 对水桶修改静态“给杯子添加的水类型”；对液体容器设置新物品初始 `WaterType`，仅服务器首次创建，读档保留保存类型。 |
| `bOverrideColor=false` | `Color=白色` | 宿主按容器类型选择现有动态材质向量参数：水桶 `Glass Color`，液体容器 `StaticMesh` 第 `0` 槽的 `Param`。 |

颜色用 `Context.Content:MakeColor(R, G, B, A)` 构造，分量必须是有限数值。此颜色接口改运行时动态材质实例，不改原材质资产，也不需要材质资源 PAK。它与修改液体本身颜色的饮品样式接口不同。

液体容器示例使用 `MaxCapacity=20000`、`InitialCapacity=0`，并保持 `bOverrideOnlyAllowCupAddition=false`。水桶示例使用最大容量与初始容量均为 `20000`。初始数量不要大于配置最大容量。

初始液量在服务端新实例 BeginPlay 完成后仅应用一次。水桶的 `CupLiquidType` 是该 ItemId 的静态出液设置，读档会重新应用；液体容器当前 `WaterType` 是实际保存状态。保存后重新进入时，最大容量、颜色等静态配置重新应用，已经保存的当前液体数量和液体类型应恢复原值，不因 `InitialCapacity` 再次补满。此语义已接入实现，仍须完成下方 PIE、真实存档与多人验收，不能仅凭注册成功认定通过。

新 Mod 容器会额外保存原生 double 精度液量和实际 `WaterType`，避免旧容器蓝图保存时取整。恢复时先禁止首次初始化，再在旧蓝图恢复之后写回精确状态。原版物品及没有这份扩展状态的旧存档继续沿用原流程。主机在基础数据就绪、全部已启用 Mod 完成注册后才读档；注册失败会中止进入并返回主菜单，避免缺少物品类时继续保存。

## 5. 自建蓝图派生类

沿用模板类时，这两个示例只需要 Lua 与 JSON。若要改变网格、添加组件或自定义蓝图行为，再创建独立子类。

沿用原类并注册独立 `ItemId`，已经是真正的新物品；自建 Blueprint 是可选扩展。说明书 SDK 附带以下已实际创建并重载验证的未 Cook 源模板，以及 `SDK/Tools/CreateModContainerBlueprints.py`：

| SDK 源资产 | 真实父蓝图 | 默认 ItemID |
| --- | --- | --- |
| `SDK/Content/Mods/MyWaterBucket/BP_MyWaterBucket.uasset` | `BP_1022水桶` | `Mod_NewWaterBucket_20000` |
| `SDK/Content/Mods/MyLiquidContainer/BP_MyLiquidContainer.uasset` | `BP_液体容器` | `Mod_NewLiquidContainer_20000` |

工具在含游戏父资产及原生模块的官方 SDK / 当前工程中执行：缺失时仅创建这两份新资产；同名资产存在时只验证父类并保留已有内容，不覆盖作者修改。实际创建验证确认原始父文件 SHA256 不变。工具不是父资产或原生模块的替代品，空白项目仍不能直接使用缺失的父类。

```powershell
& '<UE5.6.1引擎>/Engine/Binaries/Win64/UnrealEditor-Cmd.exe' '<SDK工程.uproject>' -run=pythonscript '-script=<SDK目录>/Tools/CreateModContainerBlueprints.py' -EnablePlugins=PythonScriptPlugin,EditorScriptingUtilities -unattended -NullRHI
```

源模板是未 Cook 的作者资产，不能直接放游戏当成 PAK。下面说明如何手动派生自己的变体；附带工具使用用户指定的水桶和液体容器基类，手动制作时也可根据需求选择实际商店子类。

1. 使用包含游戏兼容父蓝图及所需原生模块的作者工程 / Mod SDK，并匹配游戏 UE **5.6.1**。空白项目没有父资产或 `BaseInstall` 类时，不能直接创建有效子类；先解决作者环境依赖。
2. 从真实父类创建 Child Blueprint：水桶从 `BP_1022水桶`，液体容器优先从商店模板 `BP_设施3015_水容器_Child`。不要重命名、覆盖或修改原版蓝图。
3. 新资产放进自己的独立目录，例如 `/Game/Mods/MyWaterBucket/` 或 `/Game/Mods/MyLiquidContainer/`。
4. 覆写 Construction、BeginPlay、物品初始化、ItemID 更新或存档事件时，保留需要的 **Call to Parent Function** 与父类执行顺序，避免丢失初始化、联机和读档行为。
5. 编译、保存自己的蓝图，确认父类、组件和依赖都正常。先在作者环境验证，再 Cook。

以下路径对应 SDK 提供的源模板。仍需在含父类的 UE5.6.1 SDK 中完成 Cook、打包和安装，才启用对应路径；两个纯 Lua 示例默认保持这些行注释：

```lua
-- SDK 源模板完成 Cook 和打包后再启用。
-- item.ActorClassPath = "/Game/Mods/MyWaterBucket/BP_MyWaterBucket.BP_MyWaterBucket_C"
-- item.ActorClassPath = "/Game/Mods/MyLiquidContainer/BP_MyLiquidContainer.BP_MyLiquidContainer_C"
```

## 6. UE5.6.1 Cook、PAK 与 ShaderArchive

1. 在作者项目用独立目录保存自有子类、网格、材质和贴图；修复 Redirector。不要把修改后的原版蓝图作为 MOD 发布。
2. 创建 `PrimaryAssetLabel` Data Asset（不是 Blueprint 子类），配置唯一 Chunk ID、`Always Cook`、`Label Assets in My Directory` 和 `Is Runtime Label`。Asset Audit 确认自有目录进入目标 Chunk。
3. Windows 目标保持与游戏一致；需要支持的格式按现有打包指南配置，通常 D3D12 SM5 / SM6、D3D11 SM5。
4. Packaging 开启 `Use Pak File`、`Generate Chunks`、`Share Material Shader Code`，关闭 `Use Io Store`、`Use Zen Store` 与 `Shared Material Native Libraries`。按自己的目录添加 Cook 范围，不要把整个游戏 Content 打进 MOD。
5. 使用 UE5.6.1 Cook / Package Windows 资源。用 `UnrealPak.exe <你的pak> -List` 检查目标 PAK：应包含自有 `/Game/Mods/...` 包，不能包含覆盖原版 `BP_1022水桶`、`BP_液体容器` 或商店子类的包。父类供 Cook 解析依赖，发布 Chunk 不应重新覆盖它。
6. 把目标 PAK 放到 MOD 根目录；包含新材质时，同时按现有模型 PAK 教程把生成的 ShaderArchive 原名文件放在 MOD 根目录，不重命名。不要凭文档示意名创建假的 `.ushaderbytecode`。
7. 保留 `mod.json` 与 `v3.lua` 松散文件。宿主在执行 Lua 前挂载资源；Lua 中不需要也不能绕过沙箱自行 Mount 或 LoadObject。联机每端安装同版本资源。

```text
MyCustomItemMod/
├── mod.json
├── v3.lua
├── MyCustomItemMod.pak
└── ShaderArchive-<作者工程实际生成名>-<格式>.ushaderbytecode
```

更详细的现有资源打包参数可对照说明书 `Model_PAK_Packaging_ZH.md`。不要直接照搬其他项目的 Cook 文件或伪造 ShaderArchive 名称。

## 7. 存档、禁用和验收

存档需要同一个独立 `ItemId` 与可解析的 Actor 类。若用自有子类，禁用 MOD 或移走 PAK 后，该类可能无法解析；先重新启用相同 ID 的兼容 MOD / 资产包，再加载存档。不要在缺少 MOD 内容的状态下保存并覆盖唯一存档。

| 验收场景 | 通过标准 |
| --- | --- |
| 注册与商店 | 新 ID 出现在指定分类，原版 `1022` / `3015` 保持原样；价格、名称、描述、解锁和排序正确。 |
| 购买 / 配送 / 放置 | 直接配送保持所购新 ItemId 和真实容量/液体配置；独立包装箱保留箱子身份与内容物 ID，原版物品不变。 |
| 新物品初始状态 | 服务端只初始化一次容量和初始水类型；客户端显示一致。 |
| 保存 / 退出 / 重进 | 当前液体数量、类型恢复；不被 `InitialCapacity` 重填，静态容量和颜色仍生效。 |
| 派生蓝图 | 自有子类生成、父类初始化、组件、动态材质和读档事件正常。 |
| 已连接客户端 / 晚加入 | 主机、现有客户端与晚加入者看到相同 ItemId、容量、液体类型、数量及颜色。 |
| 失败 / 卸载 | 注册失败没有部分发布；卸载撤回注册覆盖，重新启用后可识别原存档 ID。 |

文档和表导出属于静态证据。完整编译、自动化测试、PIE、真实存档与多人运行各自独立，交付时应分别记录结果。

## 8. 完整发布示例与实际验证范围

| 完整示例 | 模板 / 独立 ItemId | 新购买时的实际状态 | 当前模板价格 / 等级 |
| --- | --- | --- | --- |
| [AppleJuiceBucket20L](../../Example_ZH/AppleJuiceBucket20L/README.md) | `1022` / `Mod_AppleJuiceBucket_20000` | 当前/最大 `20000/20000ml`，`Drink.AppleJuice`，仅杯，深绿色 `Glass Color` | `2.5` / `33` |
| [AutoStopLiquidContainer100L](../../Example_ZH/AutoStopLiquidContainer100L/README.md) | `3045` / `Mod_AutoStopLiquidContainer_100000` | 当前/最大 `0/100000ml`，保留模板自停行为，深绿色 `Param` | `100` / `60` |

两个示例都在 `购买.商品.材料`，`PurchasePrice=-1`、`UnlockLevel=-1` 继承当前模板。未达等级时应显示锁定卡片，不是完全从搜索结果消失。完整目录含 `mod.json`、`v3.lua`、`icon.png`、`preview.png`、`release_data.json`、`releaseREADME.md`、中英文工坊说明和使用说明。`release_data.json` 是发布参考快照，实际定义来自 `v3.lua` 与宿主当前模板。发布包的游戏内商品名为中文；中英文目录使用相同物品 ID、Lua 定义及图片。

直接复用已有类即可创建独立商品，无需新蓝图或资源 PAK。不要为了修复旧宿主而把新 `ItemId` 改回 `1022`/`3045`，也不要只给 Lua 写死原版配送类来掩盖购买身份丢失。先更新宿主，再新购买；此前已按原版 ID 生成或保存的错误商品没有可靠的 Mod 来源标记，会保持原状态，不能批量把原版桶转换成苹果汁桶。

截至 2026-10-26，UE5.6.1 已完成编译/链接，以及隔离 GameWorld 中的真实商店蓝图枚举、真实 `Ev服务器创建货物` 配送、BeginPlay 初始内容和内存 SaveGame 往返回归。配送测试没有通过手动改 ItemID 绕过购买链，已检查上述实际容量、苹果汁类型、仅杯、颜色、包装箱身份及剩余 `1234.5ml` 恢复后不补满。

这些自动化结果不替代手动 PIE 商店搜索/加购/出液、真实磁盘存档重进、已有客户端及晚加入验收。记录每一项实际结果后再发布；不要把“注册成功”或“同一个模型生成了”当作完整通过。
