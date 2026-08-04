# RedLemonWater（API v3）

[返回示例索引](../README.md) | [English](../../Example_EN/RedLemonWater/)

把已有 `Drink.LemonWater` 的两层颜色可回滚地改为红色。它不替换饮品配方。

清单同时申请 `content.register` 和 `content.patch`；定义设置 `bPatchExisting=true`。禁用后原颜色恢复，多个覆盖 MOD 由宿主按剩余层重放。

这是修改已有内容的最小官方模板。
