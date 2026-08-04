# NewDrinkPumpkin (API v3)

[Back to examples](../README.md) | [中文](../../Example_ZH/NewDrinkPumpkin/)

Registers “Pumpkin Juice” as DrinkId `5201`, output `Drink.PumpkinJuice`, with a perfect ratio of 0.83–1.0.

Current entry: `mod.json → v3.lua`. Permission: `content.register`. `5201.png` is a path relative to the mod. On commit, the host automatically adds the new owned recipe; no `EvAddDrink` call is needed.

`main.lua` is retained only for legacy API v1 game builds. New authors should use `v3.lua`.
