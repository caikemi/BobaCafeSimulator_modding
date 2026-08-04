# UE5.6 模型资产 MOD PAK 打包教程

[返回中文首页](README.md) | [English](Model_PAK_Packaging_EN.md) | [家具内容 API](docs/zh/04-content-api.md)

本教程用于包含 Static Mesh、材质和贴图的 BaseInstall API v3 家具包。最终 MOD 使用 `mod.json + v3.lua` 注册家具；PAK 由宿主在 Lua 入口前自动挂载，不再从脚本手动 Mount 或 LoadObject。多人加入时，兼容检查会在 `ClientTravel` 前预挂载客户端启用的资产 PAK。

Epic 官方参考：[Cooking Content and Creating Chunks](https://dev.epicgames.com/documentation/en-us/unreal-engine/cooking-content-and-creating-chunks-in-unreal-engine?application_version=5.6) 和 [Packaging Your Project](https://dev.epicgames.com/documentation/en-us/unreal-engine/packaging-your-project?application_version=5.6)。

## 最终目录

```text
MyDecorationMod/
├── mod.json
├── v3.lua
├── MyDecorationMod.pak
├── ShaderArchive-MyDecorationProject_Chunk1001-PCD3D_SM5-PCD3D_SM5.ushaderbytecode
├── ShaderArchive-MyDecorationProject_Chunk1001-PCD3D_SM6-PCD3D_SM6.ushaderbytecode
├── preview.png
└── SM_MyDecoration.png
```

Lua、JSON 和 PNG 是松散文件。模型、材质、材质实例和贴图必须 Cook 后进入 PAK。ShaderArchive 既在 PAK 中，也要提取一份同名松散文件放在 MOD 根目录；不要重命名 ShaderArchive。

## 1. 创建 UE5.6 作者项目

1. 使用与游戏一致的 Unreal Engine 5.6。
2. Games → Blank → Blueprint → Desktop。
3. 项目和路径使用英文，例如 `MyDecorationProject`。
4. 每个资产包使用独立项目名/Chunk ID，减少 ShaderArchive 名称冲突。

不同引擎版本或平台 Cook 的资产不保证兼容。

## 2. 整理 Content

```text
MyDecorationProject/
├── MyDecorationProject.uproject
├── Config/
└── Content/
    └── MyDecorationPack/
        ├── PAL_MyDecorationPack
        ├── SM_MyDecoration
        ├── M_MyDecoration
        ├── MI_MyDecoration
        └── T_MyDecoration_Color
```

磁盘 `Content/MyDecorationPack/SM_MyDecoration.uasset` 的运行时对象路径是：

```text
/Game/MyDecorationPack/SM_MyDecoration.SM_MyDecoration
```

路径来自 Content 内目录和资产名，不来自 PAK 文件名或最终 MOD 文件夹名。

确保模型材质槽、材质实例父级、贴图引用正确，资源已保存且没有未修复 Redirector。所有依赖尽量留在自己的英文目录。

## 3. 创建 PrimaryAssetLabel

在 `Content/MyDecorationPack/` 右键创建 `PrimaryAssetLabel` Data Asset，命名 `PAL_MyDecorationPack`，设置：

| 选项 | 推荐 |
| --- | --- |
| Priority | 1 |
| Chunk ID | 1001（每包唯一） |
| Cook Rule | Always Cook |
| Label Assets in My Directory | 开启 |
| Is Runtime Label | 开启 |

不要创建 Blueprint 子类。Project Settings → Game → Asset Manager 中确认扫描 `PrimaryAssetLabel` 和 `/Game`；Tools → Audit → Asset Audit 中确认目标 Chunk 含模型、材质、贴图和 Label。

## 4. Windows Shader 格式

Project Settings → Platforms → Windows：

```text
Default RHI                    = DirectX 12
D3D12 Targeted Shader Formats = SM5, SM6
D3D11 Targeted Shader Formats = SM5
```

## 5. Packaging 设置

Project Settings → Project → Packaging：

| 选项 | 值 |
| --- | --- |
| Use Pak File | 开启 |
| Use Io Store | 关闭 |
| Use Zen Store | 关闭 |
| Generate Chunks | 开启 |
| Create compressed cooked packages | 开启 |
| Share Material Shader Code | 开启 |
| Shared Material Native Libraries | 关闭 |
| Cook everything in project content | 关闭 |
| Additional Asset Directories to Cook | `/Game/MyDecorationPack` |

当前加载流程需要传统 `.pak`，不是 `.utoc/.ucas`。游戏发布包也必须使用兼容的非 IoStore 配置。

```ini
[/Script/UnrealEd.ProjectPackagingSettings]
UsePakFile=True
bUseIoStore=False
bUseZenStore=False
bGenerateChunks=True
bCompressed=True
bShareMaterialShaderCode=True
bSharedMaterialNativeLibraries=False
bCookAll=False
+DirectoriesToAlwaysCook=(Path="/Game/MyDecorationPack")
```

已有同名 section 时编辑原 section。

## 6. Cook 和打包

编辑器使用 `Platforms → Windows → Package Project`。只点 Cook Content 不等于完成 Chunk PAK。

```powershell
$UE_ROOT = "C:\Path\To\UE_5.6"
$PROJECT = "C:\Path\To\MyDecorationProject\MyDecorationProject.uproject"

& "$UE_ROOT\Engine\Build\BatchFiles\RunUAT.bat" `
  "-ScriptsForProject=$PROJECT" BuildCookRun `
  -nop4 -utf8output -nocompileeditor -skipbuildeditor `
  -cook "-project=$PROJECT" `
  "-unrealexe=$UE_ROOT\Engine\Binaries\Win64\UnrealEditor-Cmd.exe" `
  -platform=Win64 -installed -stage -package -clean `
  -pak -compressed -manifests -nocompile -nocompileuat
```

使用干净输出目录。结果通常在：

```text
Saved/StagedBuilds/Windows/MyDecorationProject/Content/Paks/
├── pakchunk0-Windows.pak
└── pakchunk1001-Windows.pak
```

复制目标 Chunk，不要复制 pakchunk0。PAK 可重命名为 `MyDecorationMod.pak`。

## 7. 提取 ShaderArchive

```powershell
$UE_ROOT = "C:\Path\To\UE_5.6"
$PAK = "C:\Path\To\pakchunk1001-Windows.pak"
$OUTPUT = "C:\Path\To\ExtractedShaders"

New-Item -ItemType Directory -Force -Path $OUTPUT
& "$UE_ROOT\Engine\Binaries\Win64\UnrealPak.exe" `
  $PAK -Extract $OUTPUT '-Filter=ShaderArchive-*.ushaderbytecode'
```

把 SM5、SM6 文件原名复制到 MOD 根目录。PAK 可重命名，ShaderArchive 不可重命名。

## 8. 编写 v3 清单

```json
{
  "schemaVersion": 1,
  "id": "com.author.my_decoration",
  "name": "My Decoration Pack",
  "version": "1.0.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": ["content.register"],
  "dependencies": []
}
```

## 9. 注册家具

```lua
local M = {}

function M.OnLoad(Context)
    local f = Context.Content:MakeFurnitureDefinition()
    f.ContentId = "my_decoration"
    f.ItemId = "Mod_MyDecoration"
    f.DisplayName = "我的装饰"
    f.Description = "一个自定义家具。"
    f.CategoryTag = "购买.装饰.家具"
    f.MeshObjectPath =
        "/Game/MyDecorationPack/SM_MyDecoration.SM_MyDecoration"
    f.PreviewImageRelativePath = "SM_MyDecoration.png"
    f.ActorClassPath =
        "/Script/Engine.Blueprint'/Game/2Game/Blueprint/商店饰品/BP_家具2100随意放置.BP_家具2100随意放置'"
    f.BoxClassPath =
        "/Script/Engine.Blueprint'/Game/1Game/Blueprint/AI/BP/货物包裹/BP_货物包裹建筑.BP_货物包裹建筑'"
    f.PurchasePrice = 50
    f.UnlockLevel = 0
    f.BoxHeight = 50
    f.BoxType = 2
    f.bShowInShop = true

    local result = Context.Content:RegisterFurniture(f)
    if not result.bSuccess then
        error(tostring(result.Message))
    end
    return true
end

return M
```

宿主提交时适配到 BaseInstall 物品表。不要使用 `UE`、`MOD.GAA.LoadObject`、手动 Mount PAK 或 `FItemDataRuntime`。完整示例：[AnimalDecorationAssetPack](Example_ZH/AnimalDecorationAssetPack/)。

## 10. 检查 PAK

```powershell
$UE_ROOT = "C:\Path\To\UE_5.6"
$PAK = "C:\Path\To\MyDecorationMod.pak"
& "$UE_ROOT\Engine\Binaries\Win64\UnrealPak.exe" $PAK -List
```

应看到模型 `.uasset/.uexp`、材质、贴图、可能的 `.ubulk` 和 ShaderArchive。挂载点应保留 `<ProjectName>/Content/`，映射到 `/Game/...`。

## 11. 游戏验收

1. 放到 `BobaCafeSimulator/Mods/MyDecorationMod/`。
2. 启用后测试商店、购买、包裹、放置和存档恢复。
3. 禁用确认家具条目回滚。
4. 再启用确认不重复。
5. 与其他家具 MOD 同时测试 ID 和加载顺序。

## 常见问题

- PAK 挂载但模型不存在：检查对象路径、大小写、Chunk 和是否误用 pakchunk0。
- 模型无材质：检查依赖同 Chunk、Share Material Shader Code、两个松散 ShaderArchive、文件名和 IoStore 残留。
- 只有 `.utoc/.ucas`：关闭 Use Io Store，对干净目录重新打包。
- `Missing shader resource`：通常是共享 Shader Code/ShaderArchive/包装模式问题。
- Editor/PIE 提示 Unversioned Content：正式验收优先使用与发布版一致的 packaged build，不要求普通玩家修改控制台变量。
