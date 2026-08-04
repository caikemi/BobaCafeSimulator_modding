# 排错与发布前检查

[返回中文首页](../../README.md) | [English](../en/10-troubleshooting.md)

先确认正在测试的是 `mod.json.entry` 指向的文件。许多旧 MOD 同时保留 `main.lua` 和 `v3.lua`，当前版本只执行清单选择的入口。

## MOD 不出现在列表或不加载

检查：

- MOD 文件夹根部直接有 `mod.json`。
- JSON 是 UTF-8、语法合法且小于 256 KiB。
- `id` 只用允许字符，首尾为字母/数字。
- `version` 非空且没有首尾空格。
- `apiVersion` 为 3。
- `entry` 文件存在、是相对 `.lua` 路径、没有 `..`。
- `side` 与当前进程匹配。
- 必需依赖已经先加载为 Active，精确版本一致。

有 `mod.json` 但无效时不会退回 API v1。修复清单，不要删除清单来绕过。

## Lua 报 nil global

若错误涉及 `UE`、`GAA`、`MOD.Playercontroller`、`io`、`os`、`require`、`debug` 或 `load`，说明把 API v1 代码放进了受限入口。按[迁移文档](08-legacy-migration.md)改为 Context 服务。

入口必须 `return M`，生命周期函数应写在返回 table 上。

## PermissionDenied

- 把对应权限加入 `permissions`。
- `bPatchExisting=true` 同时需要 `content.register` 和 `content.patch`。
- 不要申请 `*`，清单会拒绝。
- 权限名必须小写并带命名空间，例如 `inventory.write`。

## InvalidState

通常是在 `OnLoad` 中调用了 Active-only 写操作。移到 `OnModEvent`：

- `TryPayBill`
- `GrantItem` / `RemoveItems`
- `Tasks:AddProgress`
- `UI:ShowNotification`
- `Storage:Flush`

内容注册相反，只能在 `OnLoad`。

## 内容注册失败

### AlreadyExists / collision

- `ContentId` 在同一 MOD 中必须唯一。
- 新 DrinkId、LiquidId、ItemId 不得和宿主或其他 MOD 冲突。
- 真正要修改已有项时使用 `bPatchExisting=true` 和 `content.patch`。
- 不要把本应新增的内容标记为 patch 来隐藏 ID 管理问题。

### 饮品存在但看不到

- 检查 `DrinkId`、`DisplayName`、`OutputLiquidId`。
- 检查 Seasons、SweetnessOptions、TemperatureOptions 是否被误清空。
- 检查 `ImageRelativePath` 文件名和大小写。
- 新饮品由宿主自动同步到拥有配方；不要再调用 `EvAddDrink`。
- 结果液体需要对应样式/转换规则时，确认三者的 LiquidId 完全一致。

### 颜色 patch 无效

- `LiquidId` 必须是实际样式键。
- 设置 `bPatchExisting=true`。
- 清单同时申请两项 content 权限。
- RGBA 使用 0–1，不是 0–255。
- 检查是否有后加载 MOD 覆盖同一键。

### 家具不在商店

- `ItemId` 唯一，`CategoryTag` 正确，`bShowInShop=true`。
- Mesh、ActorClass、BoxClass 的对象路径正确。
- PAK 在 Lua 前已挂载，不要在 `v3.lua` 手动挂载；多人兼容检查通过后还会在 `ClientTravel` 前预挂载资产 PAK。
- 查看提交错误；任意一件家具失败会回滚整包事务。

## 事件没有触发

- `Subscribe` 结果是否成功。
- 拼写是否全小写、带命名空间。
- 该事件是 C++ 自动事件还是仍需蓝图接入。
- 蓝图是否放在真正成功分支，而非 UI/失败/客户端重复分支。
- 权威事件必须由服务器广播。
- 当前不存在 `game.shop_closed`、`drink.served`、`furniture.placed`、`furniture.removed`。

订单阶段不要混用：下单 `order.placed`，玩家出单 `order.submitted`，顾客拿单 `order.picked_up`。

## Economy / Inventory / Tasks / UI 失败

- Context 已 Active。
- 调用端有服务器权威（写操作）。
- PlayerIndex 非负且玩家存在。
- ItemId 存在，Count 在 1–100。
- TaskTag 是已注册 Gameplay Tag，Count 在 1–100000。
- 通知非空且不超过 512 字符。
- 支付类型只用 WaterRate、Utility、Rent、Payroll，金额为正且余额/账单满足宿主规则。

## Storage 失败

- Key 符合字符/长度规则。
- JSON 总大小不超过 64 KiB。
- 读写分别申请权限。
- `Flush` 只在 Active 阶段。
- 若已有 storage.json 被手工改坏，先备份，再修成含 `schemaVersion` 和字符串 `data` 对象的合法 JSON。

## PAK / 模型 / 材质

### 找不到模型

- 使用 UE5.6。
- `MeshObjectPath` 来自 Content 下路径：`/Game/Pack/Asset.Asset`。
- PrimaryAssetLabel 的 Chunk 包含模型及依赖。
- 复制的是目标 Chunk，不是 `pakchunk0`。
- IoStore 已关闭并生成 `.pak`。

### 模型灰色、黑色或缺材质

- 材质和贴图在同一 Chunk。
- `Share Material Shader Code` 已开启。
- SM5/SM6 ShaderArchive 都在 MOD 根目录且没有重命名。
- 游戏发布包和作者包均使用兼容的非 IoStore PAK 流程。
- 不混用旧 `.utoc/.ucas` 输出。

详见 [PAK 打包教程](../../Model_PAK_Packaging_ZH.md)。

## 联机问题

`side` 会跳过不匹配进程。当前房间检查会比较 Mod ID 和加载顺序并预挂载 PAK，但还不比较版本或内容哈希；仍需由工坊说明、服务器规则和人工测试保证双方版本一致。不要把客户端 UI 事件当作服务器权威结果。

## 发布前总清单

- [ ] ID、版本、入口、权限、依赖准确。
- [ ] 中英文 README 与实际功能一致。
- [ ] 没有遗留凭据、绝对开发机路径或调试文件。
- [ ] Lua 语法和 OnLoad 合约测试通过。
- [ ] 新存档、读档、禁用、再启用通过。
- [ ] 新内容和 patch 都验证卸载回滚。
- [ ] 与常见同类 MOD 一起测试加载顺序。
- [ ] PAK 内容、ShaderArchive 和预览图齐全。
- [ ] 工坊页面写明联机要求、依赖和冲突。
- [ ] 没有宣传当前尚未实现的音乐、本地化、任意 UI 或联机握手能力。
