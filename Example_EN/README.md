# Mod example directory

[中文示例](../Example_ZH/README.md) | [English Examples](README.md) | [Complete English documentation](../README_EN.md)

## Official API v3 examples

Every directory below contains `mod.json` and `v3.lua` and uses public, permission-controlled, reversible APIs.

| Example | Content |
| --- | --- |
| [NewDrinkPumpkin](NewDrinkPumpkin/) | Pumpkin Juice recipe and perfect-liquid ratio |
| [NewDrinkPumpkinOrange](NewDrinkPumpkinOrange/) | Exact dependency, recipe, cup rule, and style |
| [RedLemonWater](RedLemonWater/) | Reversible patch of an existing Lemon Water style |
| [AnimalDecorationAssetPack](AnimalDecorationAssetPack/) | PAK, ShaderArchives, and four BaseInstall furniture items |
| [AutoPayDailyBill](AutoPayDailyBill/) | Events, economy read/payment, and mod storage |

The current entry is always selected by `mod.json.entry`. Some migrated directories retain `main.lua` for old game builds; new authors should read only `v3.lua`.

## Legacy API v1 compatibility examples

| Example | Status |
| --- | --- |
| [CustomBGM](CustomBGM/) | Privileged legacy Windows MP3 example; v3 music playback is not public |
| [LocalizedPumpkinDrink](LocalizedPumpkinDrink/) | Legacy runtime-localization example; v3 localization is not public |

Those two directories intentionally have no `mod.json` and are not v3 templates. They only document that old player-made mods can continue through the compatibility path.

## Suggested order

1. NewDrinkPumpkin
2. NewDrinkPumpkinOrange
3. RedLemonWater
4. AutoPayDailyBill
5. AnimalDecorationAssetPack + [PAK guide](../Model_PAK_Packaging_EN.md)

- [NewWaterBucketItem](NewWaterBucketItem/) — Independent shop item and container-settings example.

- [NewLiquidContainerItem](NewLiquidContainerItem/) — Independent shop item and container-settings example.

## Complete release packages

- [AppleJuiceBucket20L](AppleJuiceBucket20L/): full 20L apple juice, cups only, dark green, complete images and publishing files.
- [AutoStopLiquidContainer100L](AutoStopLiquidContainer100L/): empty 100L container, template auto-stop behavior, dark green, complete images and publishing files.

Install each complete folder with a host containing shop-enumeration and purchase-identity fixes; see [the feature baseline](../docs/en/13-new-items.md).
