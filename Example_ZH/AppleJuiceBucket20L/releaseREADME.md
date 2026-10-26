# 苹果汁桶（20L） / Apple Juice Bucket (20L)

版本 / Version：1.0.0

新增一件独立商店商品“苹果汁桶（20L）”。新购时装满 20L 苹果汁，只允许向杯子添加，外壳为深绿色。原版水桶保持原有行为。

Adds an independent shop product, Apple Juice Bucket (20L). A newly purchased bucket contains 20 liters of apple juice, pours only into cups, and has a dark green exterior. The built-in bucket keeps its original behavior. The in-game product name and description are supplied in Chinese.

## 规格 / Specifications

| 项目 / Setting | 内容 / Value |
| --- | --- |
| 商品名称 / Product name | 苹果汁桶（20L） |
| 最大容量 / Maximum capacity | 20L / 20000mL |
| 新购初始内容 / Initial contents | 20L 苹果汁 / 20L apple juice (`Drink.AppleJuice`) |
| 使用限制 / Pouring restriction | 只允许向杯子添加 / Cups only |
| 外壳颜色 / Exterior color | 深绿色，线性 RGBA `(0.012, 0.085, 0.026, 1)` / Dark green, linear RGBA |
| 商店分类 / Shop category | 购买.商品.材料 / Goods → Ingredients |
| 价格与解锁 / Price and unlock | 沿用当前游戏原版桶装矿泉水 / Inherited from the current built-in bottled-water bucket |
| 当前发布模板参考 / Current template snapshot | 价格 `2.5`，解锁等级 `33` / Price `2.5`, unlock level `33` |
| 模板 / Template | `1022` / `BP_1022水桶` |
| 独立物品 ID / Independent ItemId | `Mod_AppleJuiceBucket_20000` |

## 安装和使用 / Installation and use

将整个 `AppleJuiceBucket20L` 目录按游戏现有 MOD 安装方式放置，在游戏 MOD 列表中启用，然后进入存档。到商品材料分类购买“苹果汁桶（20L）”；满足原版桶装矿泉水的解锁条件后可购买。拿起水桶向杯子添加苹果汁。

Install the complete `AppleJuiceBucket20L` folder using the game's normal mod installation method, enable it in the mod list, then enter your save. Purchase 苹果汁桶（20L） under Goods → Ingredients after meeting the original bottled-water bucket's unlock requirement. Pick it up and pour apple juice into a cup.

脚本的 `PurchasePrice=-1`、`UnlockLevel=-1` 会继承实际游戏模板；上表记录当前发布模板参考值，后续模板变化时随游戏更新。

The script keeps `PurchasePrice=-1` and `UnlockLevel=-1` to inherit the actual game template. The table records the current release values; future template changes are inherited.

需要提供 `RegisterItem` 的 API v3 游戏版本。此包使用 `mod.json` 和 `v3.lua`，不包含旧 `main.lua` 入口。附带商品图标 `icon.png` 和工坊封面 `preview.png`；沿用游戏已有蓝图、模型、材质与配送方式，无需资源 PAK。

Requires an API v3 game build exposing `RegisterItem`. The entry is `v3.lua` through `mod.json`; there is no legacy `main.lua`. A product icon (`icon.png`) and Workshop cover (`preview.png`) are included. Existing game Blueprints, model, materials, and delivery behavior are reused, so no asset PAK is required.

新购水桶只在服务器首次创建时装满；保存后重新进入保留已经使用的剩余量，不会再次补满。使用包含本物品的存档时保持 MOD 启用；若暂时禁用，重新启用后再加载，不要在缺少该物品的状态下覆盖唯一存档。

New buckets are filled once on first creation by the server. Loading a save preserves the remaining quantity without refilling it. Keep the mod enabled for saves containing this product. If disabled temporarily, re-enable it before loading and do not overwrite your only save while the item is unavailable.

## 联机 / Multiplayer

主机和所有客户端安装相同版本。清单设置为 `side: both`、`networkPolicy: exact-match`；现有房间检查比较 Mod ID 与加载顺序并预挂载 PAK，尚不比较版本或内容哈希，仍需人工保证版本与内容一致。

The host and every client need the same version. The manifest uses `side: both` and `networkPolicy: exact-match`; the existing room check compares Mod IDs and load order and pre-mounts PAKs, but does not compare versions or content hashes. Matching versions and contents still require manual verification.

## 发布资料 / Publishing files

`WorkshopDescription_ZH.md` 和 `WorkshopDescription_EN.md` 提供可用的中英文商品说明。此目录不绑定既有工坊条目；发布由作者在游戏上传界面手动完成。

`WorkshopDescription_ZH.md` and `WorkshopDescription_EN.md` contain ready-to-use publishing descriptions. This folder is not bound to an existing Workshop entry; authors publish manually through the game's upload interface.

## 图像来源 / Image provenance

商品图标和封面中的物品图原样导出自游戏实际模板，是原版模型图示；游戏内外壳由本 Mod 动态材质设置为深绿色。未使用未通过检查的离屏截图，也没有重新绘制或替换模型。

The icon and product image on the cover are exported from the real game template and show the original model colors. In-game dynamic materials apply the dark green exterior. No model replacement or unverified off-screen capture is included.

`release_data.json` 提供模板原始商店行、继承的价格/等级/类路径及本包配置快照；运行时以 `v3.lua` 和游戏当前模板为准。

`release_data.json` records the original shop row, inherited price/unlock/class paths and this package's settings for publishing review. Runtime behavior comes from `v3.lua` and the game's current template.

## 游戏接口要求 / Host feature requirement

需要包含本轮新增物品接口以及仅杯加液校验的游戏构建。工程源码已接入客户端交互和服务器水量消息校验；使用前需正常完成游戏编译。只声明 API v3 而没有这些功能的旧游戏构建不能保证完整行为。

Requires a game build with RegisterItem and Cup-only interaction checks, including the authority-side bucket liquid-message validation. Compile the updated host before use; an older build that merely identifies itself as API v3 may lack these features.

## 商店与购买修复基线 / Shop and purchase fix baseline

需包含 2026-10-26 真实模板补缺、运行时商店 ID 枚举、直接配送保留购买 ItemId 及 BeginPlay 一次初始化/精确存档的宿主构建；仅有 API v3 或 RegisterItem 不足。游戏构建更新并重启后应新购买验证，旧原版 ID 商品不会自动转换。

Requires the host's 2026-10-26 template completion, runtime shop-ID enumeration, purchased-ID preservation for direct delivery, and once-only BeginPlay initialization/precise-save fixes. API v3 or RegisterItem alone is insufficient. Restart the updated host and make a new purchase; old built-in-ID products are not converted automatically.

真实商店蓝图与送货事件、容量/类型/颜色及内存存档恢复自动化已通过；手动 PIE 搜索/加购/出液、真实磁盘存档、现有客户端和晚加入仍须独立验收。房间比较 Mod ID 与顺序，尚不比较版本/内容哈希。

Actual shop-Blueprint and delivery-event automation passed for identity, capacity/type/color, and in-memory restoration. Manual PIE search/cart/dispensing, disk-save re-entry, connected clients, and late join still require separate acceptance. Room checks compare Mod IDs/order, not versions/content hashes.
