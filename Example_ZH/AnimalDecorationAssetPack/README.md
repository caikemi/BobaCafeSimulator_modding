# AnimalDecorationAssetPack（API v3）

[返回示例索引](../README.md) | [English](../../Example_EN/AnimalDecorationAssetPack/) | [PAK 教程](../../Model_PAK_Packaging_ZH.md)

这是当前游戏 MOD 实例的公开版本，包含四件家具、模型 PAK、SM5/SM6 ShaderArchive 和商店预览图。

`mod.json → v3.lua`，权限为 `content.register`。Lua 使用 `MakeFurnitureDefinition/RegisterFurniture`，宿主在入口前自动挂载 PAK，并在提交时适配到 BaseInstall 物品表。

`main.lua` 是旧 API v1 参考，不是当前入口。不要从新脚本复制手动挂载、LoadObject 或内部 `FItemDataRuntime` 调用。
