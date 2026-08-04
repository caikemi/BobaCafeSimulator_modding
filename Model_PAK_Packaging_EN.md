# UE5.6 model-asset mod PAK packaging guide

[English home](README_EN.md) | [中文](Model_PAK_Packaging_ZH.md) | [Furniture Content API](docs/en/04-content-api.md)

This guide builds a BaseInstall API v3 furniture pack containing Static Meshes, materials, and textures. The final mod registers furniture through `mod.json + v3.lua`. The host mounts PAKs before the Lua entry, so scripts no longer mount or LoadObject manually. In multiplayer, the compatibility check pre-mounts enabled client asset PAKs before `ClientTravel`.

Official Epic references: [Cooking Content and Creating Chunks](https://dev.epicgames.com/documentation/en-us/unreal-engine/cooking-content-and-creating-chunks-in-unreal-engine?application_version=5.6) and [Packaging Your Project](https://dev.epicgames.com/documentation/en-us/unreal-engine/packaging-your-project?application_version=5.6).

## Final folder

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

Lua, JSON, and PNG files remain loose. Models, materials, instances, and textures must be cooked into the PAK. Extract copies of the ShaderArchives to the mod root without renaming them.

## 1. Create an UE5.6 authoring project

1. Use the same Unreal Engine 5.6 version as the game.
2. Games → Blank → Blueprint → Desktop.
3. Use an English project/path such as `MyDecorationProject`.
4. Give each asset pack a distinct project name and Chunk ID to reduce ShaderArchive-name collisions.

Assets cooked with another engine version or platform are not guaranteed to be compatible.

## 2. Organize Content

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

The runtime object path for `Content/MyDecorationPack/SM_MyDecoration.uasset` is:

```text
/Game/MyDecorationPack/SM_MyDecoration.SM_MyDecoration
```

It comes from the path under Content and the asset name, not the PAK filename or final mod-folder name.

Verify material slots, instance parents, texture references, saved assets, and fixed Redirectors. Keep dependencies under the mod's unique English directory where possible.

## 3. Create a PrimaryAssetLabel

Under `Content/MyDecorationPack/`, create a `PrimaryAssetLabel` Data Asset named `PAL_MyDecorationPack`:

| Option | Recommended |
| --- | --- |
| Priority | 1 |
| Chunk ID | 1001 (unique per pack) |
| Cook Rule | Always Cook |
| Label Assets in My Directory | enabled |
| Is Runtime Label | enabled |

Create the Data Asset itself, not a Blueprint subclass. In Project Settings → Game → Asset Manager, verify scanning for `PrimaryAssetLabel` and `/Game`. In Tools → Audit → Asset Audit, verify that Chunk 1001 contains the model, materials, textures, and label.

## 4. Windows shader formats

Project Settings → Platforms → Windows:

```text
Default RHI                    = DirectX 12
D3D12 Targeted Shader Formats = SM5, SM6
D3D11 Targeted Shader Formats = SM5
```

## 5. Packaging settings

Project Settings → Project → Packaging:

| Option | Value |
| --- | --- |
| Use Pak File | enabled |
| Use Io Store | disabled |
| Use Zen Store | disabled |
| Generate Chunks | enabled |
| Create compressed cooked packages | enabled |
| Share Material Shader Code | enabled |
| Shared Material Native Libraries | disabled |
| Cook everything in project content | disabled |
| Additional Asset Directories to Cook | `/Game/MyDecorationPack` |

The current loader needs a traditional `.pak`, not `.utoc/.ucas`. The released game also needs a compatible non-IoStore configuration.

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

Edit an existing section instead of duplicating it.

## 6. Cook and package

Use `Platforms → Windows → Package Project`. Cook Content alone does not finish the Chunk PAK.

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

Use a clean output directory. Output is normally:

```text
Saved/StagedBuilds/Windows/MyDecorationProject/Content/Paks/
├── pakchunk0-Windows.pak
└── pakchunk1001-Windows.pak
```

Copy the target Chunk, not pakchunk0. The PAK may be renamed to `MyDecorationMod.pak`.

## 7. Extract ShaderArchives

```powershell
$UE_ROOT = "C:\Path\To\UE_5.6"
$PAK = "C:\Path\To\pakchunk1001-Windows.pak"
$OUTPUT = "C:\Path\To\ExtractedShaders"

New-Item -ItemType Directory -Force -Path $OUTPUT
& "$UE_ROOT\Engine\Binaries\Win64\UnrealPak.exe" `
  $PAK -Extract $OUTPUT '-Filter=ShaderArchive-*.ushaderbytecode'
```

Copy the SM5 and SM6 files, under their original names, to the mod root. The PAK may be renamed; a ShaderArchive may not.

## 8. Write the v3 manifest

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

## 9. Register furniture

```lua
local M = {}

function M.OnLoad(Context)
    local f = Context.Content:MakeFurnitureDefinition()
    f.ContentId = "my_decoration"
    f.ItemId = "Mod_MyDecoration"
    f.DisplayName = "My Decoration"
    f.Description = "A custom furniture item."
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

The host adapts this to BaseInstall's item registry at commit. Do not use `UE`, `MOD.GAA.LoadObject`, manual PAK mount, or `FItemDataRuntime`. Complete example: [AnimalDecorationAssetPack](Example_EN/AnimalDecorationAssetPack/).

## 10. Inspect the PAK

```powershell
$UE_ROOT = "C:\Path\To\UE_5.6"
$PAK = "C:\Path\To\MyDecorationMod.pak"
& "$UE_ROOT\Engine\Binaries\Win64\UnrealPak.exe" $PAK -List
```

Expect model `.uasset/.uexp`, materials, textures, optional `.ubulk`, and ShaderArchives. The mount point should preserve `<ProjectName>/Content/`, mapping to `/Game/...`.

## 11. In-game acceptance

1. Place under `BobaCafeSimulator/Mods/MyDecorationMod/`.
2. Test shop, purchase, package, placement, and save restore.
3. Disable and confirm furniture rollback.
4. Re-enable and confirm no duplicates.
5. Test IDs and load order with another furniture mod.

## Common problems

- PAK mounts but model is missing: object path, case, Chunk, or accidental pakchunk0.
- Missing/gray material: same-Chunk dependencies, Share Material Shader Code, both loose ShaderArchives, unchanged filenames, and no stale IoStore output.
- Only `.utoc/.ucas`: disable Use Io Store and rebuild into a clean directory.
- `Missing shader resource`: typically shared shader code, ShaderArchive, or packaging-mode mismatch.
- Editor/PIE reports Unversioned Content: accept release only in a packaged build matching the shipped game; do not require ordinary players to change console variables.
