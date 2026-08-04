# RedLemonWater (API v3)

[Back to examples](../README.md) | [中文](../../Example_ZH/RedLemonWater/)

Reversibly changes both color layers of existing `Drink.LemonWater` to red. It does not replace the drink recipe.

The manifest requests both `content.register` and `content.patch`, while the definition sets `bPatchExisting=true`. Disable restores the original colors; the host replays remaining layers when several mods patch the same key.

This is the minimal official existing-content patch template.
