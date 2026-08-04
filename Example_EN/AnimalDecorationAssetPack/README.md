# AnimalDecorationAssetPack (API v3)

[Back to examples](../README.md) | [中文](../../Example_ZH/AnimalDecorationAssetPack/) | [PAK guide](../../Model_PAK_Packaging_EN.md)

This is the public copy of the current game mod: four furniture items, a model PAK, SM5/SM6 ShaderArchives, and store preview images.

`mod.json → v3.lua`, permission `content.register`. Lua uses `MakeFurnitureDefinition/RegisterFurniture`; the host mounts the PAK before entry and adapts definitions into the BaseInstall item registry at commit.

`main.lua` is legacy API v1 reference, not the current entry. Do not copy manual mount, LoadObject, or internal `FItemDataRuntime` calls into new scripts.
