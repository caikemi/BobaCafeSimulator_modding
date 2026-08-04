# Blueprint / DataAsset MOD

[返回中文首页](../../README.md) | [English](../en/07-blueprint-data-assets.md)

BaseInstall API v3 提供稳定的蓝图入口和内容 DataAsset 类型，让资产作者不必继承游戏内部 PlayerController、GameState 或 Actor。普通 Lua MOD 不需要这些类型；只有使用兼容 BaseInstallAPI 作者插件/SDK 的 UE5.6 项目才可创建它们。

## BaseInstallBlueprintMod

创建一个 Blueprint Class，父类选择 `BaseInstallBlueprintMod`。可实现：

| 事件 | 调用时机 |
| --- | --- |
| `OnLoad(ModContext)` | 内容提交前；Context 为 Loading |
| `OnWorldReady(Event)` | 宿主广播 `game.world_ready` 时 |
| `OnModEvent(Event)` | 已订阅的其他事件到达时 |
| `OnUnload()` | 禁用/卸载时 |

使用 `GetContext` 获取 Context，并调用与 Lua 相同的 Events、Content、Economy、Storage、Inventory、Tasks、UI 服务。权限和状态限制完全相同。

建议蓝图流程：

```text
OnLoad
├─ GetContext
├─ Events → Subscribe("game.morning_started")
├─ Content → RegisterContentAsset(...)（可选）
└─ 不在这里调用背包/任务/UI/缴费写操作

OnModEvent
├─ 判断 EventName
└─ 在 Active 阶段调用获准的运行时服务
```

`OnWorldReady` 是生命周期便利事件。若还希望同一个 `game.world_ready` 进入普通 `OnModEvent`，仍可订阅它。

## 内容资产基类

`BaseInstallModContentAsset` 是公开 PrimaryDataAsset 基类：

| 字段 | 说明 |
| --- | --- |
| `ContentId` | MOD 内局部 ID |
| `DisplayName` | 显示名 |
| `Description` | 多行说明 |
| `Icon` | 软引用图标 |
| `PublicTags` | 对外元数据标签 |
| `SchemaVersion` | 当前默认 1 |

运行时限定 ID 为 `ModId:ContentId`。

## BaseInstallModDrinkAsset

核心字段是 v3 `Definition`（`FBaseInstallModDrinkDefinition`）。提交时：

- 若 `Definition.ContentId` 为空，使用资产基类 `ContentId`。
- 若 `Definition.DisplayName` 为空，使用资产基类 `DisplayName`。
- 其余饮品字段从 `Definition` 读取。

资产上的 `Prices`、`OutputLiquidId`、`RequiredIngredientIds`、`RequiredLiquids`、`SweetnessOptions`、`TemperatureOptions` 是早期/编辑便利字段；当前 v3 内部适配器不会自动把它们合并到 `Definition`。新资产必须完整填写 `Definition`，不要依赖便利字段回填。

## BaseInstallModFurnitureAsset

核心字段也是 v3 `Definition`。提交时可从资产字段回填：

- `ContentId`、`DisplayName`、`Description`
- `ItemId` 为空时使用 `ContentId`
- `ActorClass` → `ActorClassPath`
- `PreviewMesh` → `MeshObjectPath`
- `PurchasePrice`（仅当 Definition 价格不大于 0）

`PlacementType` 当前是公共元数据，BaseInstall 适配器没有独立使用它。实际包裹、Actor、分类与摆放行为仍以 `Definition` 字段和宿主现有家具类为准。

## BaseInstallModMusicAsset

公开字段包括 `Sound`、`Volume`、`Weight`、`bLoop`、`Situations`。当前它可以进入公共内容表，但尚未接入游戏内部音乐播放注册表。

因此：

- 可以制作资产用于未来兼容或宿主自定义扩展。
- 不能把它当作当前 v3 可播放音乐接口。
- 旧 CustomBGM 的高权限 MP3/内部调用没有 v3 等价接口。

## BaseInstallModDefinitionAsset

该资产描述一组蓝图/数据内容：

| 字段 | 说明 |
| --- | --- |
| `ModId` | 必须与包清单 ID 一致 |
| `Version` | 必须与包清单版本一致 |
| `APIVersion` | 新内容填 3 |
| `ExecutionSide` | Client / Server / Both |
| `NetworkPolicy` | LocalOnly / ServerRequired / ExactMatch |
| `GrantedPermissions` | 仅宿主实际授予的权限 |
| `EntryClass` | `BaseInstallBlueprintMod` 子类 |
| `ContentAssets` | 要在同一事务暂存的公开内容资产 |

激活顺序：

```text
宿主加载/校验包清单
→ 挂载 PAK
→ 加载 Definition
→ 暂存 ContentAssets
→ 创建 EntryClass 并调用 OnLoad
→ 提交 Context
→ Active
```

任何步骤失败都会回滚。

## 当前加载边界

`Activate Mod Definition` 和 `Deactivate Mod` 是宿主侧蓝图节点。当前 Lua MOD 目录加载器的主要入口仍是 `mod.json.entry`；外部 PAK 中任意 `BaseInstallModDefinitionAsset` 不应被假定为会自动发现。若游戏的 Mods 菜单/加载蓝图要支持纯 DataAsset 包，必须在校验清单和挂载 PAK 后明确加载该 Definition 并调用 `Activate Mod Definition`。

`mod.json` 对发布包仍是权威清单。不要只发布一个 Definition 而省略清单，除非该内容是游戏开发者内置并由宿主直接激活。

## 打包建议

- 使用与游戏一致的 UE5.6 和作者 SDK/plugin 版本。
- 不引用游戏私有 C++ Struct 或蓝图内部变量。
- 所有引用使用 Soft Object/Class Reference，资源放在自己的 `/Game/<Pack>/` 路径。
- Definition、EntryClass 和 ContentAssets 进入同一个 Chunk PAK。
- 清单权限与 Definition 的 GrantedPermissions 保持一致；宿主应以清单为准。
- 在禁用/重新启用和多个覆盖资产的场景测试回滚。
