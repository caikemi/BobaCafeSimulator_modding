# 独立大容量液体容器 / Independent large liquid container

[中文教程](../../docs/zh/13-new-items.md) | [English guide](../../docs/en/13-new-items.md)

此 MOD 新增 `Mod_NewLiquidContainer_20000`，从真实商店物品 `3015`（液体容器，`BP_设施3015_水容器_Child`）复制完整默认数据，不修改原版 `3015` 或 `BP_液体容器`。新物品最大容量 `20000`，初始容量为 `0`，初始水类型为 `Drink.PureWater`，并设置 `StaticMesh` 第 `0` 槽的向量参数 `Param`。沿用游戏已有类、图标和配送数据，无需额外 PAK。

This mod adds `Mod_NewLiquidContainer_20000` by copying the actual shop item `3015` (`BP_设施3015_水容器_Child`). It preserves built-in item `3015` and `BP_液体容器`. New containers have capacity `20000`, start empty, use initial liquid type `Drink.PureWater`, and override vector parameter `Param` on `StaticMesh` material slot `0`. Existing classes, icons, and delivery data are reused; no asset PAK is needed.

将此目录完整安装并启用；需要包含 `RegisterItem` 的游戏版本。联机双方安装同版本 MOD，`exact-match` 目前没有完整清单握手。初始容量和初始水类型仅在服务器首次创建时设置，读档应保留已经保存的液体数量和类型；仍需按教程完成运行验收。

Install and enable the complete folder in a build exposing `RegisterItem`. All multiplayer peers need the same mod version; `exact-match` does not yet provide a complete manifest handshake. Initial quantity and initial liquid type apply only to first creation on the server; loading a save must retain saved quantity and type. Runtime acceptance checks remain required.

液体容器没有水桶的“只允许给杯子添加”字段，因此示例保持 `bOverrideOnlyAllowCupAddition=false`。颜色按容器类型自动选择原有材质参数，不修改材质资产。

Liquid containers do not have the bucket-only cup-addition restriction, so `bOverrideOnlyAllowCupAddition` remains false. The host chooses the existing color parameter for the container type without editing material assets.

说明书 SDK 提供对应蓝图源模板与 `Tools/CreateModContainerBlueprints.py`。自建蓝图是可选扩展；纯 Lua 新 ID 已是独立物品。先在含父类的官方 SDK 中 Cook，才可启用注释中的子类路径，不能把未 Cook 的源 `.uasset` 直接放游戏当 PAK。

The manual's SDK supplies source templates and `Tools/CreateModContainerBlueprints.py`. Child Blueprints are optional: the Lua-only new ItemId already creates an independent product. Cook the source templates in the matching official SDK with the parent assets before enabling the commented class path; uncooked `.uasset` files are not a runtime PAK.

## 宿主功能基线 / Host feature baseline

使用包含 2026-10-26 模板补缺、运行时商店枚举、直接配送独立 ID 及初始内容/存档修复的游戏构建，仅声明 API v3 不足。先更新宿主并重启，再新购买验证；旧的原版 ID 商品保持原状态。现有房间检查比较 ID/顺序，不比较版本/内容哈希。

Use a game build with the 2026-10-26 template-completion, runtime-catalog, independent-delivery-ID, and initial-content/save fixes; API v3 alone is insufficient. Update/restart the host, then make a new purchase. Old built-in-ID products retain their state. The room check compares IDs/order, not versions/content hashes.
