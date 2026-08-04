# 发布到 Steam 创意工坊

[返回中文首页](../../README.md) | [English](../en/09-workshop.md)

本游戏 Steam App ID：`3683770`。上传前先在本地 Mods 目录完整测试。Valve 官方参考：[Steam Workshop Implementation Guide](https://partner.steamgames.com/doc/features/workshop/implementation?l=schinese) 和 [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD)。

SteamCMD 需要作者登录 Steam，适合手动发布/测试。不要把密码或 Steam Guard 验证码写入 BAT、VDF 或仓库。

## 1. 准备上传目录

```text
D:/BobaWorkshop/
├── Mods/
│   └── MyMod/
│       ├── mod.json
│       ├── v3.lua
│       ├── preview.png
│       └── 其他资源
└── Upload/
    ├── MyMod.vdf
    └── upload_MyMod.bat
```

`contentfolder` 指向的 `MyMod` 根目录必须直接包含 `mod.json`，不能多套一层同名文件夹。

资产 MOD 还应包含：

- `*.pak`
- SM5 和 SM6 的 `ShaderArchive-*.ushaderbytecode`
- 松散预览图

不要上传开发项目的 `Saved`、`Intermediate`、`DerivedDataCache`、源码凭据或旧 `.utoc/.ucas` 残留。

## 2. 本地验收

1. 复制到 `BobaCafeSimulator/Mods/MyMod/`。
2. 在 Mods 菜单启用。
3. 新存档和读档各测试一次。
4. 禁用并确认内容回滚。
5. 再启用并确认没有重复内容/奖励。
6. 若有依赖，测试缺失依赖和错误版本的报错。
7. 联机内容在主机和客户端同版本条件下测试。

## 3. 创建 VDF

```vdf
"workshopitem"
{
    "appid"            "3683770"
    "publishedfileid"  "0"
    "contentfolder"    "D:\\BobaWorkshop\\Mods\\MyMod"
    "previewfile"      "D:\\BobaWorkshop\\Mods\\MyMod\\preview.png"
    "visibility"       "2"
    "title"            "My Mod"
    "description"      "A BaseInstall API v3 mod."
    "changenote"       "v1.0.0"
}
```

| 字段 | 说明 |
| --- | --- |
| `appid` | 固定 `3683770` |
| `publishedfileid` | 首次 `0`；成功后自动写回 ID |
| `contentfolder` | MOD 根目录绝对路径 |
| `previewfile` | 预览图绝对路径 |
| `visibility` | `0` 公开、`1` 仅好友、`2` 私密、`3` 不列出；首次建议 2 |
| `title` | 工坊标题 |
| `description` | 工坊说明，写清依赖、联机要求和 API 版本 |
| `changenote` | 本次更新说明 |

VDF 使用 UTF-8 保存，Windows 路径在 VDF 中使用双反斜杠。

## 4. 安装和初始化 SteamCMD

1. 下载 Windows SteamCMD 到英文目录，例如 `C:/SteamCMD/`。
2. 首次运行 `steamcmd.exe`，等待自更新。
3. 看到 `Steam>` 后输入 `quit`。

## 5. 上传脚本

```bat
@echo off
setlocal
set "STEAMCMD=C:\SteamCMD\steamcmd.exe"
set "VDF=D:\BobaWorkshop\Upload\MyMod.vdf"

"%STEAMCMD%" +login YourSteamAccount +workshop_build_item "%VDF%" +quit

echo.
echo SteamCMD finished. Check the output for ERROR or Failed.
pause
```

运行时按提示输入密码和 Steam Guard。不要把它们写在 `+login` 后面。

## 6. 首次发布

1. 保持 `publishedfileid "0"`。
2. 执行 BAT。
3. 确认没有 `ERROR` 或 `Failed`。
4. 重新打开 VDF；成功后 `publishedfileid` 会变成数字。备份这份 VDF。
5. 打开 `https://steamcommunity.com/sharedfiles/filedetails/?id=<ID>`。
6. 如提示，接受创意工坊法律协议。
7. 保持私密状态订阅测试；确认后把 `visibility` 改为 `0` 再上传。

## 7. 更新已有物品

1. 修改 contentfolder 中的文件。
2. 更新 `mod.json.version` 和 VDF 的 `changenote`。
3. 本地重新验收。
4. 保留原 `publishedfileid`，不要改回 0。
5. 再次运行同一个 BAT。

把 ID 改回 0 会尝试创建新工坊物品。

## 8. 订阅验收

Steam 客户端可能在游戏启动后才下载刚订阅的内容。先在下载页确认创意工坊内容安装完成，再重启游戏。

常见缓存位置：

```text
<SteamLibrary>/steamapps/workshop/content/3683770/<PublishedFileId>/
```

进入该数字目录，确认根部直接有 `mod.json`。

## 工坊页面必须写清

- MOD ID、版本、API 版本。
- 必需和可选依赖及精确版本。
- 主机/客户端是否都必须安装。
- 新增或覆盖了哪些 DrinkId、LiquidId、ItemId。
- 是否包含 PAK/ShaderArchive。
- 卸载对存档的影响。
- 已知冲突和不支持能力。

当前完整联机清单握手尚未实现，因此 `networkPolicy` 元数据不能代替清晰的工坊安装说明。

## 常见上传问题

| 现象 | 检查 |
| --- | --- |
| 找不到 VDF/预览图 | 使用存在的绝对路径；确认后缀不是 `.txt` |
| 上传成功但游戏找不到 | 工坊 ID 目录根部必须直接有 `mod.json` |
| 更新变成新物品 | 不要把 `publishedfileid` 重置为 0 |
| 页面不公开 | `visibility=0`，并接受法律协议 |
| 订阅后没下载 | 等待 Steam 下载完成并重启游戏 |
| 模型无材质 | 同时上传正确 PAK 和未改名的 SM5/SM6 ShaderArchive |
| 需要详细日志 | 检查 Steam 的 `logs/Workshop_log.txt` 和 workshop build 日志 |
