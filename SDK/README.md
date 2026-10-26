# 容器子蓝图源模板 / Container child-Blueprint source templates

这里包含两份实际创建并重载验证过的 UE5.6.1 子蓝图，以及创建脚本。它不是完整、可独立运行的游戏 SDK；需要包含兼容游戏父蓝图和 BaseInstall 原生模块的制作工程。

This folder contains two actual UE5.6.1 child Blueprint source assets and their creation script. It is a template kit, not a complete standalone game SDK. Use an authoring project containing the compatible game parent assets and native BaseInstall modules.

- `Content/Mods/MyWaterBucket/BP_MyWaterBucket.uasset` inherits `BP_1022水桶`, ItemId `Mod_NewWaterBucket_20000`.
- `Content/Mods/MyLiquidContainer/BP_MyLiquidContainer.uasset` inherits `BP_液体容器`, ItemId `Mod_NewLiquidContainer_20000`.
- `Tools/CreateModContainerBlueprints.py` creates missing examples in such a project and checks existing examples without overwriting them.

将 Content 下的目录按原包路径导入制作工程，保留父类调用。它们是未 Cook 的编辑器源资产，不能直接放进运行游戏，也不能改后缀当作 PAK。默认 Lua 示例沿用游戏已有类，无需这些资产；启用自定义 ActorClassPath 前需完成 Cook 与独立资源打包。

Import the Content hierarchy at its original package paths in the authoring project and preserve parent calls. These are uncooked editor assets, not runtime PAKs. The default Lua examples reuse game classes and do not need them. Cook and package the custom classes before enabling their ActorClassPath overrides.

[中文教程](../docs/zh/13-new-items.md) | [English guide](../docs/en/13-new-items.md)

## 宿主与身份 / Host and identity

源模板默认 ItemID 是演示值，不是所有 Mod 的固定 ID。新版宿主会在直接配送时保留 Lua 注册的所购独立 ItemId，并在 BeginPlay 后应用初始内容、读档时保留剩余量。仅复制这些源资产或更新 API 插件不能替代游戏宿主的商店枚举/配送接入。制作工程也应包含 2026-10-26 功能基线，无需修改或发布原版父蓝图。

Source-template default ItemIDs are examples, not fixed IDs for every mod. The updated host preserves the independently registered purchased ItemId for direct deliveries, initializes new contents after BeginPlay, and retains remaining contents on load. Copying these assets or updating only the API plugin cannot replace the game's shop-enumeration/delivery integration. Use an authoring host with the 2026-10-26 feature baseline; do not modify or redistribute built-in parents.
