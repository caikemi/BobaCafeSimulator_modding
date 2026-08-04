# 奶茶店模拟器 Mod 开发文档

[中文](README.md) | [English](README_EN.md)

这是面向 MOD 作者的 BaseInstall API v3 正式文档。新 MOD 应使用 `mod.json`、`apiVersion: 3` 和受限 Lua 入口；不要再直接访问 `UE`、`GAA`、PlayerController、GameState 或游戏内部注册表。

v3 的核心原则：

- 只开放稳定的 `Context` 服务，并由 `mod.json` 显式申请权限。
- 饮品、颜色、加料规则和家具在 `OnLoad` 中暂存，整包成功后一次提交。
- 加载失败、禁用或卸载会回滚 MOD 自己的内容；多个覆盖 MOD 按剩余加载层重放。
- 没有订阅者或没有安装 MOD 时，原游戏逻辑保持不变。
- 无 `mod.json` 的旧 MOD 仍可走 API v1 兼容路径，但不享受 v3 的沙箱、权限和回滚保证。

## 从这里开始

1. [五分钟快速开始](docs/zh/01-getting-started.md)
2. [mod.json 清单与权限](docs/zh/02-manifest.md)
3. [Lua 生命周期与 Context](docs/zh/03-lua-and-context.md)
4. [饮品、颜色、规则和家具 API](docs/zh/04-content-api.md)
5. [事件名称、Payload 与宿主接入点](docs/zh/05-events.md)
6. [Economy、Storage、Inventory、Tasks、UI](docs/zh/06-runtime-services.md)
7. [Blueprint/DataAsset MOD](docs/zh/07-blueprint-data-assets.md)
8. [API v1/v2 迁移](docs/zh/08-legacy-migration.md)
9. [Steam 创意工坊发布](docs/zh/09-workshop.md)
10. [排错与发布前检查](docs/zh/10-troubleshooting.md)
11. [饮品、液体、原料与图标 ID 参考](docs/zh/11-id-reference.md)
12. [UE5.6 模型资产 PAK 打包教程](Model_PAK_Packaging_ZH.md)

## 可直接使用的示例

所有官方 v3 示例都带 `mod.json`，实际入口由 `entry` 指向 `v3.lua`。

| 示例 | 展示内容 |
| --- | --- |
| [NewDrinkPumpkin](Example_ZH/NewDrinkPumpkin/) | 注册新饮品和完美液体比例 |
| [NewDrinkPumpkinOrange](Example_ZH/NewDrinkPumpkinOrange/) | 依赖、饮品、杯子加料规则和颜色 |
| [RedLemonWater](Example_ZH/RedLemonWater/) | 用 `content.patch` 可回滚地修改已有颜色 |
| [AnimalDecorationAssetPack](Example_ZH/AnimalDecorationAssetPack/) | PAK、ShaderArchive 和四件家具 |
| [AutoPayDailyBill](Example_ZH/AutoPayDailyBill/) | 事件、经济服务和命名空间存储 |

完整索引见 [Example_ZH](Example_ZH/README.md)。

## 最小目录

```text
MyMod/
├── mod.json
├── v3.lua
├── preview.png          # 推荐，可选
└── MyContent.pak       # 只有资产 MOD 需要
```

`mod.json`：

```json
{
  "schemaVersion": 1,
  "id": "com.author.my_mod",
  "name": "My Mod",
  "version": "1.0.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": [],
  "dependencies": []
}
```

`v3.lua`：

```lua
local M = {}

function M.OnLoad(Context)
    Context:Log("Loaded " .. Context:GetModId())
    return true
end

return M
```

把整个 `MyMod` 文件夹放到：

```text
游戏根目录/BobaCafeSimulator/Mods/
```

然后在游戏 MOD 菜单中启用并重新进入游戏验证。

## 当前能力与边界

已公开：事件、饮品、饮品样式、杯子加物品规则、家具、账单读取/支付、MOD 存储、背包查询/增删、任务进度、普通玩家提示，以及 Blueprint/DataAsset 入口类型。

当前尚未公开：任意 Widget 创建、任意文件/网络访问、内部 UObject、通用液体加液体/复杂混合规则、运行时本地化服务、音乐播放注册表、完整联机 MOD 清单握手，以及 Dedicated Server 独立 Lua 目录加载器。文档中的“未支持”表示不要依赖旧内部接口绕过。

## 版本说明

本文档以游戏当前的 BaseInstall API v3 实现和仓库内已验证 MOD 为准。若示例与旧帖子冲突，以本仓库的 v3 文档、`mod.json` 和 `v3.lua` 为准。
