# UE5.6 模型资产 Mod PAK 打包教程

本文适用于《奶茶店模拟器 - 重生之我在冰堡甜城当店长》的 Windows 模型资产 Mod。

完成后，一个模型资产 Mod 通常包含：

```text
MyDecorationMod/
├── main.lua
├── MyDecorationMod.pak
├── ShaderArchive-MyDecorationProject_Chunk1001-PCD3D_SM5-PCD3D_SM5.ushaderbytecode
├── ShaderArchive-MyDecorationProject_Chunk1001-PCD3D_SM6-PCD3D_SM6.ushaderbytecode
├── preview.png
└── SM_MyDecoration.png
```

> `main.lua` 和预览 PNG 是普通文件，不需要放进 PAK。模型、材质、材质实例和贴图需要由 UE Cook 并写入 PAK。

## 1. 创建 UE5.6 空白项目

使用与游戏一致的 **Unreal Engine 5.6**：

1. 打开 UE5.6。
2. 选择“游戏”。
3. 选择“空白”模板。
4. 选择“蓝图”项目。
5. 目标平台选择“桌面”。
6. 项目名称和项目路径使用英文，例如：

```text
MyDecorationProject
```

项目名称最好具有唯一性。项目名和 Chunk ID 会出现在 ShaderArchive 文件名中，使用独立名称可以减少不同 Mod 之间的命名冲突。

Cooked Content 与引擎版本和目标平台相关。使用其他 UE 版本打包的资产不保证能被当前游戏加载。

## 2. 认识项目中的目录位置

空白项目创建完成后，目录结构大致如下：

```text
MyDecorationProject/
├── MyDecorationProject.uproject
├── Config/
│   ├── DefaultEngine.ini
│   └── DefaultGame.ini
├── Content/
│   └── MyDecorationPack/
│       ├── PAL_MyDecorationPack.uasset
│       ├── SM_MyDecoration.uasset
│       ├── M_MyDecoration.uasset
│       ├── MI_MyDecoration.uasset
│       └── T_MyDecoration_Color.uasset
└── Saved/
    └── StagedBuilds/
```

各位置的作用：

| 位置 | 内容 |
|---|---|
| 项目根目录 | `.uproject` 文件 |
| `Config/` | 项目打包、渲染平台和 Asset Manager 设置 |
| `Content/` | UE 内容浏览器中的所有资产 |
| `Content/MyDecorationPack/` | 当前 Mod 的模型、材质、贴图和 PrimaryAssetLabel |
| `Saved/StagedBuilds/` | Cook 和 Package 后生成的 PAK |
| 游戏的 `BobaCafeSimulator/Mods/` | 最终安装并运行 Mod 的位置，不是 UE 项目的资产目录 |

建议每个 Mod 在 `Content` 下建立一个独立英文目录：

```text
Content/MyDecorationPack/
```

对应的运行时 UE 路径是：

```text
/Game/MyDecorationPack/
```

目录名称会写进 Cooked 资产和 PAK。完成打包后，只修改 PAK 文件名不会改变内部资源路径。

## 3. 整理模型、材质和贴图

把当前 Mod 使用的资产放在自己的资源目录中：

```text
Content/MyDecorationPack/
├── SM_MyDecoration
├── M_MyDecoration
├── MI_MyDecoration
├── T_MyDecoration_Color
├── T_MyDecoration_Normal
├── T_MyDecoration_Roughness
└── PAL_MyDecorationPack
```

打包前检查：

- Static Mesh 的材质槽已经指定正确的材质或材质实例。
- 材质实例引用了正确的父材质。
- 材质引用的颜色、法线、粗糙度和金属度贴图都存在。
- 模型、材质和贴图已经全部保存。
- 内容浏览器中没有未修复的重定向器。

如果 PAK 里只有 `SM_*.uasset`，没有材质和贴图，游戏中可能出现模型全黑、默认材质或资源加载失败。

## 4. 创建并放置 PrimaryAssetLabel

`PrimaryAssetLabel` 是一个 **UE 数据资产**，用于告诉 Asset Manager：

- 哪些资产必须 Cook。
- 这些资产属于哪个 Chunk。
- 哪些依赖需要跟随它们进入对应 PAK。

它不是配置文件，也不是文件夹。它应当出现在 UE 内容浏览器中。

在内容浏览器中打开：

```text
Content/MyDecorationPack/
```

然后：

1. 在该目录空白处右键。
2. 选择“杂项”或“高级资产”中的“数据资产”。
3. 数据资产类型选择 `PrimaryAssetLabel`。
4. 命名为：

```text
PAL_MyDecorationPack
```

它在磁盘上的位置是：

```text
项目根目录/Content/MyDecorationPack/PAL_MyDecorationPack.uasset
```

它在 UE 中的资产路径是：

```text
/Game/MyDecorationPack/PAL_MyDecorationPack
```

`PAL_MyDecorationPack` 应和它管理的模型、材质、贴图放在同一个目录。如果模型还包含子目录，`Label Assets in My Directory` 也会递归管理这些子目录。

打开 `PAL_MyDecorationPack`，设置：

| 选项 | 建议值 | 作用 |
|---|---:|---|
| `Priority` | `1` | Chunk 规则优先级 |
| `Chunk ID` | `1001` | 生成 `pakchunk1001-Windows.pak` |
| `Cook Rule` | `Always Cook` | 强制 Cook 被管理的资产 |
| `Label Assets in My Directory` | 开启 | 管理当前目录及其子目录 |
| `Is Runtime Label` | 开启 | 让该标签作为运行时 Primary Asset |

不要创建 `PrimaryAssetLabel` 的 Blueprint 子类。直接创建 `PrimaryAssetLabel` 数据资产。

不同资产包可以使用不同 Chunk ID，例如 `1001`、`1002`、`1101`。不要使用 Chunk `0`，因为没有分配到其他 Chunk 的项目内容默认会进入 `pakchunk0`。

Epic 对 PrimaryAssetLabel 和 Chunk 的说明：

- [Cooking Content and Creating Chunks](https://dev.epicgames.com/documentation/en-us/unreal-engine/cooking-content-and-creating-chunks-in-unreal-engine)
- [Preparing Assets for Chunking](https://dev.epicgames.com/documentation/en-us/unreal-engine/preparing-assets-for-chunking-in-unreal-engine)

## 5. 确认 Asset Manager

打开：

```text
编辑 → 项目设置 → 游戏 → Asset Manager
```

确认 `Primary Asset Types to Scan` 中存在 `PrimaryAssetLabel`，并且扫描目录包含：

```text
/Game
```

通常空白项目已经能够识别 `PrimaryAssetLabel`。如果“工具 → 审核 → Asset Audit”中看不到刚创建的 Chunk，应先检查这里。

可以打开：

```text
工具 → 审核 → Asset Audit
```

点击 `Add Chunks`，确认 Chunk `1001` 中包含：

- `PAL_MyDecorationPack`
- Static Mesh
- 材质和材质实例
- 贴图

## 6. 配置 Windows Shader 格式

打开：

```text
编辑 → 项目设置 → 平台 → Windows
```

建议与游戏保持一致：

```text
Default RHI                   = DirectX 12
D3D12 Targeted Shader Formats = SM5、SM6
D3D11 Targeted Shader Formats = SM5
```

这样打包后通常会生成 SM5 和 SM6 两套 ShaderArchive。游戏会根据玩家当前使用的 RHI 打开对应文件。

## 7. 配置 Packaging

打开：

```text
编辑 → 项目设置 → 项目 → 打包
```

设置：

| 选项 | 值 |
|---|---:|
| `Use Pak File` | 开启 |
| `Use Io Store` | **关闭** |
| `Use Zen Store` | 关闭 |
| `Generate Chunks` | 开启 |
| `Create compressed cooked packages` | 开启 |
| `Share Material Shader Code` | **开启** |
| `Shared Material Native Libraries` | **关闭** |
| `Cook everything in the project content directory` | 关闭 |

当前 Mod 加载器挂载的是 `.pak`，不是 `.utoc/.ucas`，所以必须关闭 IoStore。

`Share Material Shader Code` 必须开启。这样材质 Shader 会写入可单独加载的 ShaderArchive，避免在 Editor/PIE 直接加载内联 Cooked Shader 时发生兼容问题。

在“需要始终 Cook 的其他资产目录”中加入：

```text
/Game/MyDecorationPack
```

对应的 `Config/DefaultGame.ini` 核心内容类似：

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

注意：如果这一节已经存在，应修改现有字段，不要重复创建多个同名配置节。

Epic 对 Pak、IoStore 和 Generate Chunks 的说明：

- [Packaging Your Project](https://dev.epicgames.com/documentation/en-us/unreal-engine/packaging-your-project)
- [Project Packaging Settings](https://dev.epicgames.com/documentation/en-us/unreal-engine/project-section-of-the-unreal-engine-project-settings)

## 8. Cook 并打包 Windows PAK

### 方法一：从编辑器打包

在 UE5.6 顶部菜单选择：

```text
平台 → Windows → 打包项目
```

仅点击“烘焙内容”不等于完成 PAK 打包。最终需要执行 Package，输出独立的 Chunk PAK。

### 方法二：使用 PowerShell

把下面两个路径改成自己的 UE5.6 和空白项目位置：

```powershell
$UE_ROOT = "C:\Path\To\UE_5.6"
$PROJECT = "C:\Path\To\MyDecorationProject\MyDecorationProject.uproject"

& "$UE_ROOT\Engine\Build\BatchFiles\RunUAT.bat" `
  "-ScriptsForProject=$PROJECT" `
  BuildCookRun `
  -nop4 `
  -utf8output `
  -nocompileeditor `
  -skipbuildeditor `
  -cook `
  "-project=$PROJECT" `
  "-unrealexe=$UE_ROOT\Engine\Binaries\Win64\UnrealEditor-Cmd.exe" `
  -platform=Win64 `
  -installed `
  -stage `
  -package `
  -clean `
  -pak `
  -compressed `
  -manifests `
  -nocompile `
  -nocompileuat
```

成功后，通常可以在这里找到 PAK：

```text
项目根目录/
└── Saved/
    └── StagedBuilds/
        └── Windows/
            └── MyDecorationProject/
                └── Content/
                    └── Paks/
                        ├── pakchunk0-Windows.pak
                        └── pakchunk1001-Windows.pak
```

复制你在 PrimaryAssetLabel 中指定的 Chunk：

```text
pakchunk1001-Windows.pak
```

不要把 `pakchunk0-Windows.pak` 当作模型 Mod。

Chunk PAK 可以改成方便识别的文件名：

```text
MyDecorationMod.pak
```

只允许修改 PAK 的文件名，不要修改里面的目录结构。

## 9. 从 PAK 提取 ShaderArchive

共享 Shader 文件虽然已经写入 PAK，但 UE5.6 Editor 动态挂载新 PAK 后不能稳定地直接打开其中新增的 ShaderArchive。

因此需要把对应的 `.ushaderbytecode` 同时提取为普通文件，放在最终 Mod 目录中。

PowerShell 示例：

```powershell
$UE_ROOT = "C:\Path\To\UE_5.6"
$PAK = "C:\Path\To\pakchunk1001-Windows.pak"
$OUTPUT = "C:\Path\To\ExtractedShaders"

New-Item -ItemType Directory -Force -Path $OUTPUT

& "$UE_ROOT\Engine\Binaries\Win64\UnrealPak.exe" `
  $PAK `
  -Extract $OUTPUT `
  '-Filter=ShaderArchive-*.ushaderbytecode'
```

正常情况下会得到：

```text
ShaderArchive-MyDecorationProject_Chunk1001-PCD3D_SM5-PCD3D_SM5.ushaderbytecode
ShaderArchive-MyDecorationProject_Chunk1001-PCD3D_SM6-PCD3D_SM6.ushaderbytecode
```

规则：

- PAK 文件可以改名。
- ShaderArchive 文件不能改名。
- SM5 和 SM6 文件都应随 Mod 一起发布。
- 不要只复制 PAK 而遗漏 ShaderArchive。

## 10. 编写 `main.lua` 资源路径

如果模型位于：

```text
Content/MyDecorationPack/SM_MyDecoration.uasset
```

其运行时对象路径是：

```text
/Game/MyDecorationPack/SM_MyDecoration.SM_MyDecoration
```

Lua 示例：

```lua
local ASSET_ROOT = "/Game/MyDecorationPack"
local MeshName = "SM_MyDecoration"
local MeshPath = ASSET_ROOT .. "/" .. MeshName .. "." .. MeshName

local Mesh = MOD.GAA.LoadObject("StaticMesh'" .. MeshPath .. "'")
if not Mesh then
    error("Mesh failed to load: " .. MeshPath)
end
```

路径由 UE 项目 `Content` 下的目录决定，不由 PAK 文件名或最终 Mod 文件夹名决定。

完整的 PAK 挂载、四件家具注册、预览图和中英文文本示例：

- [AnimalDecorationAssetPack 完整示例](Example_ZH/AnimalDecorationAssetPack/)
- [直接查看 `main.lua`](Example_ZH/AnimalDecorationAssetPack/main.lua)

## 11. 整理最终 Mod 文件夹

建议结构：

```text
MyDecorationMod/
├── main.lua
├── MyDecorationMod.pak
├── ShaderArchive-MyDecorationProject_Chunk1001-PCD3D_SM5-PCD3D_SM5.ushaderbytecode
├── ShaderArchive-MyDecorationProject_Chunk1001-PCD3D_SM6-PCD3D_SM6.ushaderbytecode
├── preview.png
├── SM_MyDecoration.png
└── SM_AnotherDecoration.png
```

文件用途：

| 文件 | 用途 |
|---|---|
| `main.lua` | 挂载 PAK、加载模型、注册家具数据 |
| `*.pak` | Cook 后的模型、材质和贴图 |
| `*.ushaderbytecode` | 材质共享 Shader 库 |
| `preview.png` | Mods 菜单或创意工坊预览图 |
| 每件家具的 PNG | 家具商店中显示的独立预览图 |

将整个文件夹放到：

```text
游戏根目录/BobaCafeSimulator/Mods/MyDecorationMod/
```

然后在游戏 Mods 菜单中启用。

## 12. 检查 PAK 内容

使用 UnrealPak 查看文件列表：

```powershell
$UE_ROOT = "C:\Path\To\UE_5.6"
$PAK = "C:\Path\To\MyDecorationMod.pak"

& "$UE_ROOT\Engine\Binaries\Win64\UnrealPak.exe" $PAK -List
```

应该能看到类似内容：

```text
MyDecorationPack/SM_MyDecoration.uasset
MyDecorationPack/SM_MyDecoration.uexp
MyDecorationPack/M_MyDecoration.uasset
MyDecorationPack/MI_MyDecoration.uasset
MyDecorationPack/T_MyDecoration_Color.uasset
ShaderArchive-MyDecorationProject_Chunk1001-PCD3D_SM5-PCD3D_SM5.ushaderbytecode
ShaderArchive-MyDecorationProject_Chunk1001-PCD3D_SM6-PCD3D_SM6.ushaderbytecode
```

部分资产还会包含 `.ubulk` 文件，这是正常现象。

同时确认 `UnrealPak -List` 开头显示的挂载点包含：

```text
<项目名>/Content/
```

公共 Mod 加载器会保留 `Content` 后面的相对目录，并将它映射为游戏中的 `/Game/...` 路径。

## 13. 常见问题

### PAK 挂载成功，但模型不存在

检查：

- `ASSET_ROOT` 是否与 `Content` 下的资源目录一致。
- `MeshName` 是否与 UE 资产名一致。
- `PrimaryAssetLabel` 是否设置了正确的 Chunk。
- 是否错误地复制了 `pakchunk0`。

### 模型出现但没有材质

检查：

- Static Mesh 的材质槽。
- 材质和贴图是否进入同一个 Chunk PAK。
- `Share Material Shader Code` 是否开启。
- 两个 ShaderArchive 是否放在 Mod 根目录。

### 打包结果只有 `.utoc` 和 `.ucas`

`Use Io Store` 没有关闭。当前 Mod 加载器需要 `.pak`。

### 出现 RenderCore 数组越界或 Missing shader resource

通常表示：

- 使用了内联 Cooked Shader。
- 没有开启共享 Shader Code。
- ShaderArchive 没有提取到 Mod 目录。
- ShaderArchive 被改名。

### 在 Editor/PIE 中提示 Unversioned Content

完整示例会在 PIE 初始化阶段执行：

```text
s.AllowUnversionedContentInEditor 1
```

该设置只用于 Editor/PIE 测试。正式打包游戏加载 Cooked Mod 时不需要手动输入。

