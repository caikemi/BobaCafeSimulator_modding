# NewDrinkPumpkinOrange（API v3）

[返回示例索引](../README.md) | [English](../../Example_EN/NewDrinkPumpkinOrange/)

注册 DrinkId `5200` 的“南瓜橙橙”、`Drink.PumpkinJuice + 1103 → Drink.PumpkinOrange` 杯子加料规则和橙色样式。

清单精确依赖 `NewDrinkPumpkin =2.0.0`，必须先启用南瓜汁示例。当前入口是 `v3.lua`，权限为 `content.register`。

这个示例展示同一事务包含多个定义；任意一项失败时配方、规则和颜色都不会部分发布。`main.lua` 仅为旧 API v1 保留。
