# 自停式液体容器（100L） / Auto-stop Liquid Container (100L)

版本 / Version：1.0.0

新增一件独立商店商品“自停式液体容器（100L）”。新购时为空，最多可盛放 100L 液体，接满杯子后自动停止。深绿色外壳与苹果汁桶统一，保留原版大容量自停式容器的模型、配送和自停行为。

Adds an independent shop product, Auto-stop Liquid Container (100L). New containers arrive empty, hold up to 100 liters, and stop dispensing automatically when the cup is full. The dark green exterior matches the apple juice bucket. The original large auto-stop container's mesh, delivery, and auto-stop behavior are retained. The in-game name and description are supplied in Chinese.

## 规格 / Specifications

| 项目 / Setting | 内容 / Value |
| --- | --- |
| 商品名称 / Product name | 自停式液体容器（100L） |
| 最大容量 / Maximum capacity | 100L / 100000mL |
| 新购初始内容 / Initial contents | 空 / Empty |
| 出液行为 / Dispensing | 沿用原版接满杯子自动停止 / Original cup-full auto-stop behavior |
| 液体类型 / Liquid type | 不强制指定；随实际装入液体 / Not forced; determined by the liquid actually added |
| 外壳颜色 / Exterior color | 深绿色，线性 RGBA `(0.012, 0.085, 0.026, 1)` / Dark green, linear RGBA |
| 商店分类 / Shop category | 购买.商品.材料 / Goods → Ingredients |
| 价格与解锁 / Price and unlock | 沿用当前原版大容量自停式液体容器 / Inherited from the current built-in large auto-stop container |
| 当前发布模板参考 / Current template snapshot | 价格 `100`，解锁等级 `60` / Price `100`, unlock level `60` |
| 模板 / Template | `3045` / `BP_设施3045_大容量自停式液体容器` |
| 独立物品 ID / Independent ItemId | `Mod_AutoStopLiquidContainer_100000` |

## 安装和使用 / Installation and use

将整个 `AutoStopLiquidContainer100L` 目录按游戏现有 MOD 安装方式放置，在游戏 MOD 列表启用后进入存档。到商品材料分类购买“自停式液体容器（100L）”；满足原版大容量自停式容器的解锁条件后可购买。按原版方式加入液体和接杯，自停行为由原版模板保留。

Install the complete `AutoStopLiquidContainer100L` folder using the game's normal mod installation method, enable it, then enter your save. Buy 自停式液体容器（100L） under Goods → Ingredients after meeting the original large auto-stop container's unlock requirement. Fill and dispense using the original interactions; auto-stop comes from the original template.

脚本保留 `PurchasePrice=-1`、`UnlockLevel=-1` 继承实际游戏模板；上表记录当前发布模板参考值，后续模板变化时随游戏更新。

The script retains `PurchasePrice=-1` and `UnlockLevel=-1` to inherit the actual game template. The table records current release values; future template changes are inherited.

需要提供 `RegisterItem` 的 API v3 游戏版本。此包只使用 `mod.json` 与 `v3.lua`，没有旧 `main.lua` 入口。附带商品图标 `icon.png` 和工坊封面 `preview.png`；沿用原版蓝图、模型、材质和配送类，无需资源 PAK。

Requires an API v3 game build exposing `RegisterItem`. The package uses `mod.json` and `v3.lua` without a legacy `main.lua`. A product icon (`icon.png`) and Workshop cover (`preview.png`) are included. Existing Blueprints, mesh, materials, and delivery classes are reused; no asset PAK is required.

颜色仅通过动态材质修改 `StaticMesh` 第 `0` 槽的向量参数 `Param`，不修改原材质资产。不会强制改变容器实际装入的液体类型，也不启用水桶专用的“只允许给杯子添加”覆盖。原版容器保持原有规格。

The exterior color changes vector parameter `Param` on `StaticMesh` material slot `0` through a runtime dynamic material instance, preserving the material asset. The mod does not force the actual liquid type or enable the bucket-only cup-addition restriction. Built-in containers retain their original specifications.

新购容器只在服务器首次创建时设为空。保存重进保留已经装入的数量和类型，不会清空或重填。使用包含本物品的存档时保持 MOD 启用；若暂时禁用，重新启用后再加载，不要在缺少该物品的状态下覆盖唯一存档。

New containers are initialized empty only on first creation by the server. Loading a save retains stored quantity and type without clearing or refilling. Keep the mod enabled for saves containing this product. If disabled temporarily, re-enable it before loading and do not overwrite your only save while the item is unavailable.

## 联机 / Multiplayer

主机和所有客户端安装相同版本。清单使用 `side: both` 与 `networkPolicy: exact-match`；现有房间检查比较 Mod ID 与加载顺序并预挂载 PAK，尚不比较版本或内容哈希，仍需人工保证版本与内容一致。

The host and all clients need the same version. The manifest uses `side: both` and `networkPolicy: exact-match`; the existing room check compares Mod IDs and load order and pre-mounts PAKs, but does not compare versions or content hashes. Matching versions and contents still require manual verification.

## 发布资料 / Publishing files

`WorkshopDescription_ZH.md` 和 `WorkshopDescription_EN.md` 提供中英文商品说明。此目录不绑定既有工坊条目；发布由作者在游戏上传界面手动完成。

`WorkshopDescription_ZH.md` and `WorkshopDescription_EN.md` contain publishing descriptions. This folder is not bound to an existing Workshop entry; authors publish manually through the game's upload interface.

## 图像来源 / Image provenance

商品图标和封面中的物品图原样导出自游戏实际模板，是原版模型图示；游戏内外壳由本 Mod 动态材质设置为深绿色。未使用未通过检查的离屏截图，也没有重新绘制或替换模型。

The icon and product image on the cover are exported from the real game template and show the original model colors. In-game dynamic materials apply the dark green exterior. No model replacement or unverified off-screen capture is included.

`release_data.json` 提供模板原始商店行、继承的价格/等级/类路径及本包配置快照；运行时以 `v3.lua` 和游戏当前模板为准。

`release_data.json` records the original shop row, inherited price/unlock/class paths and this package's settings for publishing review. Runtime behavior comes from `v3.lua` and the game's current template.

## 商店与购买修复基线 / Shop and purchase fix baseline

需包含 2026-10-26 真实模板补缺、运行时商店 ID 枚举、直接配送保留购买 ItemId 及 BeginPlay 一次初始化/精确存档的宿主构建；仅有 API v3 或 RegisterItem 不足。游戏构建更新并重启后应新购买验证，旧原版 ID 商品不会自动转换。

Requires the host's 2026-10-26 template completion, runtime shop-ID enumeration, purchased-ID preservation for direct delivery, and once-only BeginPlay initialization/precise-save fixes. API v3 or RegisterItem alone is insufficient. Restart the updated host and make a new purchase; old built-in-ID products are not converted automatically.

真实商店蓝图与送货事件、容量/类型/颜色及内存存档恢复自动化已通过；手动 PIE 搜索/加购/出液、真实磁盘存档、现有客户端和晚加入仍须独立验收。房间比较 Mod ID 与顺序，尚不比较版本/内容哈希。

Actual shop-Blueprint and delivery-event automation passed for identity, capacity/type/color, and in-memory restoration. Manual PIE search/cart/dispensing, disk-save re-entry, connected clients, and late join still require separate acceptance. Room checks compare Mod IDs/order, not versions/content hashes.
