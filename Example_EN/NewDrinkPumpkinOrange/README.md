# NewDrinkPumpkinOrange (API v3)

[Back to examples](../README.md) | [中文](../../Example_ZH/NewDrinkPumpkinOrange/)

Registers “Pumpkin Orange” as DrinkId `5200`, a `Drink.PumpkinJuice + 1103 → Drink.PumpkinOrange` cup-add-item rule, and an orange style.

The manifest has the exact dependency `NewDrinkPumpkin =2.0.0`; enable Pumpkin Juice first. Current entry is `v3.lua`, with `content.register`.

It demonstrates several definitions in one transaction: if any fails, recipe, rule, and style are not partially published. `main.lua` is legacy API v1 only.
