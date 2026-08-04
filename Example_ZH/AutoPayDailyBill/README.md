# AutoPayDailyBill（API v3）

[返回示例索引](../README.md) | [English](../../Example_EN/AutoPayDailyBill/)

服务器在 `game.morning_started` 时读取经济快照，并按水费、电费、租金、工资顺序支付余额足够的账单。处理后的事件序号写入 MOD 私有存储。

当前入口是 `mod.json → v3.lua`。同目录的 `main.lua` 只为旧 API v1 游戏版本保留，不是当前示例代码。

所需权限：

- `economy.read`
- `economy.pay-bills`
- `storage.write`

前置条件：游戏蓝图已在每日账单初始化完成后广播 `game.morning_started`。支付只在服务器权威端执行；Tax 当前只能读取，不能通过公共接口支付。

此示例是开发参考。真实发布版应说明支付顺序、余额策略和联机安装要求。
