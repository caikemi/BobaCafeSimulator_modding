# 独立大容量水桶 / Independent large water bucket

[中文教程](../../docs/zh/13-new-items.md) | [English guide](../../docs/en/13-new-items.md)

此 MOD 新增 `Mod_NewWaterBucket_20000`，从实际商店物品 `1022`（桶装矿泉水，`BP_1022水桶`）复制完整默认数据，不覆盖原版 `1022`。默认最大容量 `20000`，新买水桶初始装满 `20000` 的 `Drink.PureWater`，允许给杯子和容器补水，并覆盖水桶颜色。沿用模板 Actor、配送箱和图标，无需额外 PAK。

This mod adds `Mod_NewWaterBucket_20000` by copying built-in item `1022` (the `BP_1022水桶` bottled-water bucket). It preserves the original item. New buckets hold up to `20000` and start with `20000` of `Drink.PureWater`, can refill cups and containers, and receive a color override. Existing game classes, packaging, and icons are reused; no asset PAK is needed.

将此目录完整安装并启用；需要包含 `RegisterItem` 的游戏版本。联机双方安装同版本 MOD，`exact-match` 目前没有完整清单握手。`InitialCapacity` 只初始化新物品，读档不会把已经使用的水桶重新装满；仍需按教程完成存档、现有客户端与晚加入验收。

Install and enable the complete folder in a game build exposing `RegisterItem`. All multiplayer peers need the same mod version; `exact-match` does not yet provide a complete manifest handshake. `InitialCapacity` applies to newly created items and must not refill saved buckets. Save/load and multiplayer acceptance checks remain required.

脚本内已检查注册返回值。修改 `v3.lua` 后重新加载 MOD。说明书 SDK 提供对应蓝图源模板与 `Tools/CreateModContainerBlueprints.py`，在含父类的官方 SDK 中 Cook 后才可启用注释中的子类路径；未 Cook 的源 `.uasset` 不能直接当作游戏资源 PAK。

The script checks the registration result. Reload after editing `v3.lua`. Source templates and `Tools/CreateModContainerBlueprints.py` are supplied in the manual's SDK; cook them in the matching official SDK with the parent assets before enabling the commented class path. Uncooked source `.uasset` files are not a runtime resource PAK.

## 宿主功能基线 / Host feature baseline

使用包含 2026-10-26 模板补缺、运行时商店枚举、直接配送独立 ID 及初始内容/存档修复的游戏构建，仅声明 API v3 不足。先更新宿主并重启，再新购买验证；旧的原版 ID 商品保持原状态。现有房间检查比较 ID/顺序，不比较版本/内容哈希。

Use a game build with the 2026-10-26 template-completion, runtime-catalog, independent-delivery-ID, and initial-content/save fixes; API v3 alone is insufficient. Update/restart the host, then make a new purchase. Old built-in-ID products retain their state. The room check compares IDs/order, not versions/content hashes.
