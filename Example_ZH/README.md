# MOD 示例目录

[中文示例](README.md) | [English Examples](../Example_EN/README.md) | [完整中文文档](../README.md)

## 官方 API v3 示例

这些目录都包含 `mod.json` 和 `v3.lua`，并使用公开、受权限控制、可回滚的接口。

| 示例 | 内容 |
| --- | --- |
| [NewDrinkPumpkin](NewDrinkPumpkin/) | 注册南瓜汁配方和完美液体比例 |
| [NewDrinkPumpkinOrange](NewDrinkPumpkinOrange/) | 精确依赖、南瓜橙橙配方、加料规则和颜色 |
| [RedLemonWater](RedLemonWater/) | 可回滚覆盖已有柠檬水颜色 |
| [AnimalDecorationAssetPack](AnimalDecorationAssetPack/) | PAK、ShaderArchive 和四件 BaseInstall 家具 |
| [AutoPayDailyBill](AutoPayDailyBill/) | 事件、经济读取/缴费和 MOD 存储 |

当前入口以 `mod.json.entry` 为准。部分迁移目录保留 `main.lua` 供旧游戏版本兼容；新作者只阅读 `v3.lua`。

## 旧 API v1 兼容示例

| 示例 | 状态 |
| --- | --- |
| [CustomBGM](CustomBGM/) | 旧高权限 Windows MP3 示例；v3 音乐播放尚未公开 |
| [LocalizedPumpkinDrink](LocalizedPumpkinDrink/) | 旧运行时本地化示例；v3 本地化服务尚未公开 |

这两个目录故意没有 `mod.json`，不能作为新 v3 MOD 模板。它们只用于说明旧玩家 MOD 仍可走兼容路径。

## 建议阅读顺序

1. NewDrinkPumpkin
2. NewDrinkPumpkinOrange
3. RedLemonWater
4. AutoPayDailyBill
5. AnimalDecorationAssetPack + [PAK 教程](../Model_PAK_Packaging_ZH.md)
