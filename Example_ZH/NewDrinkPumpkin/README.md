# NewDrinkPumpkin（API v3）

[返回示例索引](../README.md) | [English](../../Example_EN/NewDrinkPumpkin/)

注册 DrinkId `5201` 的“南瓜汁”，输出液体 `Drink.PumpkinJuice`，并要求完美比例 0.83–1.0。

当前入口：`mod.json → v3.lua`。权限：`content.register`。图片 `5201.png` 使用 MOD 内相对路径。宿主提交后自动把新配方同步到拥有配方，无需 `EvAddDrink`。

`main.lua` 只为旧 API v1 游戏版本保留。新作者应以 `v3.lua` 为模板。
