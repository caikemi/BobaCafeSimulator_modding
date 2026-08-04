# API v1 / v2 迁移到 v3

[返回中文首页](../../README.md) | [English](../en/08-legacy-migration.md)

旧 MOD 没有 `mod.json` 时仍走 API v1 高权限兼容路径，所以原来能用的玩家 MOD不会因为 v3 出现而自动失效。但兼容不等于推荐：旧 MOD直接依赖内部对象和加载顺序，没有清单权限、沙箱、事务回滚或稳定接口保证。

## 版本区别

| 能力 | API v1（无清单） | API v2 | API v3 |
| --- | --- | --- | --- |
| 入口 | `main.lua` / `OnInit` | `mod.json` + `OnLoad` | `mod.json` + `OnLoad` |
| UE/内部对象 | 高权限直接访问 | 不提供 | 不提供 |
| 权限 | 无 | Events/Economy/Storage | 完整 v3 权限表 |
| 内容事务 | 无 | 公共资产暂存 | 饮品/样式/规则/家具适配与回滚 |
| 玩家服务 | 内部调用 | 无 | Inventory/Tasks/UI |
| 失败行为 | 可能留下部分状态 | Context 回滚 | Context + 内部注册表回滚 |
| 新项目推荐 | 否 | 仅兼容 | 是 |

API v2 清单和脚本仍受支持。若只使用 Events、Economy、Storage，可以保持 v2；新功能或新发布应升级 `apiVersion` 为 3。

## 清单迁移

在旧 MOD 根目录加入：

```json
{
  "schemaVersion": 1,
  "id": "com.author.old_mod",
  "name": "Old Mod",
  "version": "2.0.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": ["content.register"],
  "dependencies": []
}
```

建议保留旧 `main.lua` 供老游戏版本使用，但让当前清单明确指向 `v3.lua`。不要把旧代码原样改名为 `v3.lua`；清单环境没有内部全局。

## 生命周期迁移

旧：

```lua
local M = { id = "OldMod", name = "Old Mod" }

function M.OnInit()
    -- 直接读取 MOD.Playercontroller / UE
end

return M
```

新：

```lua
local M = {}

function M.OnLoad(Context)
    -- 订阅和暂存内容
    return true
end

function M.OnModEvent(Context, Event)
    -- Active 阶段运行时行为
end

return M
```

名称、ID、版本和权限移到 `mod.json`。绝对目录 `dir` 不再作为通用文件入口。

## 常见内部调用替换

| 旧做法 | v3 做法 |
| --- | --- |
| 查找 DrinkRegistry 并 `RegisterDrinkData` | `Context.Content:RegisterDrink` |
| `RegisterDrinkStyle` 直接覆盖 | `RegisterDrinkStyle` + `bPatchExisting=true` + `content.patch` |
| `RegisterCupAddItemRule` 内部调用 | 公共 `RegisterCupAddItemRule` |
| `GameState:EvAddDrink` | 删除；宿主自动同步拥有配方 |
| 构造 `FItemDataRuntime` / BaseInstall 表 | `RegisterFurniture` |
| 直接读 MultiGameState 钱/账单 | `Context.Economy:GetSnapshot` |
| 直接调用扣款 | `Context.Economy:TryPayBill` |
| 直接改背包组件 | `Context.Inventory` |
| 直接改任务系统 | `Context.Tasks:AddProgress` |
| 自建任意 Widget | 当前无等价；只可 `Context.UI:ShowNotification` |
| 自己读写配置文件 | `Context.Storage` |
| Timer 轮询内部对象是否就绪 | 订阅 `game.world_ready` 或准确业务事件 |
| 手工挂载 PAK | 删除；宿主在入口前挂载 |
| 手工卸载/恢复注册表 | 删除；事务自动回滚 |

## 饮品迁移要点

旧 `FDrinkData` 字段需要映射到 `FBaseInstallModDrinkDefinition`：

- `ID` → `DrinkId`
- `DisplayName` → `DisplayName`
- `Season` → `Seasons`
- `ImagePath = dir .. file` → `ImageRelativePath = file`
- `Value["S/M/L"]` → `SmallPrice/MediumPrice/LargePrice`
- `DrinkWaterFName` → `OutputLiquidId`
- `NeedItemID` → `RequiredItemIds`
- `PerfectNeed` → `PerfectLiquids`
- `PerfectNeedItem` → `PerfectItems`
- `ShowTutorialsItemID` → `TutorialItemIds`
- `MakeNeedTutorialText` → `TutorialText`
- `ShowGetWayText` → `AcquisitionText`
- `UnlockedItemID` → `UnlockedItemGroups`

参考已迁移示例 NewDrinkPumpkin 和 NewDrinkPumpkinOrange。

## 家具迁移要点

保留原 PAK、ShaderArchive、图片和 `/Game/...Asset.Asset` 路径；删除 Lua 中的手动挂载、LoadObject 和内部 ItemData 构造，改为 `MakeFurnitureDefinition` + `RegisterFurniture`。

参考 [AnimalDecorationAssetPack](../../Example_ZH/AnimalDecorationAssetPack/)。

## 暂时不能迁移的旧能力

### CustomBGM

`BaseInstallModMusicAsset` 尚未连接内部播放注册表，v3 也不开放任意 MP3/文件/内部 Audio API。旧 CustomBGM 可以继续作为 API v1 兼容 MOD 使用，但不应添加一个虚假的 v3 清单。

### 运行时本地化

清单只有一个 `name`，当前没有公开 culture 查询、字符串表注册或运行时本地化服务。旧 LocalizedPumpkinDrink 可继续走 v1；v3 内容可以直接填写一种显示文本，但还不能在同一 Lua MOD 内按语言安全切换。

## 迁移验收

- v3.lua 中搜索不到 `UE`、`GAA`、`MOD.Playercontroller`、`io`、`os`、`require`。
- 清单只申请脚本实际调用的权限。
- 所有注册结果检查 `bSuccess`。
- 禁用后新增内容消失、覆盖内容恢复。
- 多次启用不会重复注册或累计奖励。
- 新存档/读档、单机/联机权威端均按 MOD 声明测试。
