-- ==========================================================================
-- 动物装饰资产包：模型 PAK + 动态家具注册示例
--
-- 本示例演示：
-- 1. 在 Mod 初始化时挂载当前目录中的 PAK 和共享 Shader 库。
-- 2. 使用 Cook 后的 UE 对象路径加载 Static Mesh。
-- 3. 创建 FItemDataRuntime，并把四件装饰品注册到家具商店。
-- 4. 为每件装饰品指定独立的商店预览图片。
-- 5. 使用英文作为默认文本，并提供简体中文本地化。
--
-- 新作者通常只需要修改：
-- ASSET_ROOT、ITEM_TAG_NAME，以及 DECORATION_ITEMS 表中的各项配置。
-- ==========================================================================

-- ==========================================================================
-- Mod 列表元数据
--
-- 游戏扫描 Mods 菜单时会直接读取下面的 key = "value" 字面量。
-- 默认字段必须使用英文；中文环境会优先读取带 _zh 后缀的字段。
-- ==========================================================================
name           = "Animal Decoration Asset Pack"
description    = "Adds four animal-themed furniture decorations: a dog, an elephant, and two rocking horses."
name_zh        = "动物装饰资产包"
description_zh = "添加4款动物主题家具装饰：小狗摆件、大象摆件以及两款木马摆件。"
version        = "1.2.0"
author         = "yiming"

-- 返回游戏当前使用的两位语言代码，例如 zh-Hans-CN 会得到 zh。
-- 本示例仅提供英文和中文；其他语言统一回退到英文。
local function GetGameLanguage()
    local Language = "en"

    if UE and UE.UKismetInternationalizationLibrary then
        local Culture = UE.UKismetInternationalizationLibrary.GetCurrentCulture()
        if Culture then
            Language = string.sub(tostring(Culture), 1, 2):lower()
        end
    end

    return Language == "zh" and "zh" or "en"
end

local CURRENT_LANGUAGE = GetGameLanguage()

local MOD_METADATA = {
    en = {
        Name = name,
        Description = description,
    },
    zh = {
        Name = name_zh,
        Description = description_zh,
    },
}

local CurrentMetadata = MOD_METADATA[CURRENT_LANGUAGE] or MOD_METADATA.en

local M = {
    id          = "AnimalDecorationAssetPack",
    name        = CurrentMetadata.Name,
    description = CurrentMetadata.Description,
    version     = version,
    author      = author,
}

-- 家具商店使用的物品分类 GameplayTag。
-- 如果要放进其他商店分类，必须改成游戏中已经存在的有效 GameplayTag。
local ITEM_TAG_NAME = "购买.装饰.家具"

-- Cook 后的 UE 资源根路径。
--
-- 本示例 PAK 烘焙时，模型位于：
-- Content/AddMeshTestMod1/
-- 因此运行时对象路径必须继续使用：
-- /Game/AddMeshTestMod1/
--
-- PAK 文件改名不会改变其内部资源路径。新作者应改成自己空项目中的目录，
-- 例如资源位于 Content/MyDecorationPack/ 时，这里填写 /Game/MyDecorationPack。
local ASSET_ROOT = "/Game/AddMeshTestMod1"

-- 要注册的家具列表。
--
-- ItemID：
--   游戏运行时使用的唯一物品 ID。不同 Mod 不应使用相同 ID。
--
-- MeshName：
--   PAK 中的 Static Mesh 资产名，不包含路径和 .uasset 后缀。
--
-- TextureName：
--   Mod 文件夹中的商店预览图片。每件家具可以使用不同图片。
--
-- Text：
--   游戏内物品名称和说明。英文是默认文本，中文环境使用 zh。
local DECORATION_ITEMS = {
    {
        ItemID = "Mod_AnimalDecoration_Dog_01",
        MeshName = "SM_ToyDog_01",
        TextureName = "SM_ToyDog_01.png",
        Text = {
            en = {
                DisplayName = "Dog Decoration",
                Description = "A dog-themed furniture decoration from the Animal Decoration Asset Pack.",
            },
            zh = {
                DisplayName = "小狗装饰摆件",
                Description = "动物装饰资产包中的小狗主题家具摆件。",
            },
        },
    },
    {
        ItemID = "Mod_AnimalDecoration_Elephant_01",
        MeshName = "SM_ToyElephant_01",
        TextureName = "SM_ToyElephant_01.png",
        Text = {
            en = {
                DisplayName = "Elephant Decoration",
                Description = "An elephant-themed furniture decoration from the Animal Decoration Asset Pack.",
            },
            zh = {
                DisplayName = "大象装饰摆件",
                Description = "动物装饰资产包中的大象主题家具摆件。",
            },
        },
    },
    {
        ItemID = "Mod_AnimalDecoration_Horse_01",
        MeshName = "SM_ToyHorse_01",
        TextureName = "SM_ToyHorse_01.png",
        Text = {
            en = {
                DisplayName = "Rocking Horse Decoration I",
                Description = "The first rocking horse furniture decoration in the Animal Decoration Asset Pack.",
            },
            zh = {
                DisplayName = "木马装饰摆件（款式一）",
                Description = "动物装饰资产包中的第一款木马家具摆件。",
            },
        },
    },
    {
        ItemID = "Mod_AnimalDecoration_Horse_02",
        MeshName = "SM_ToyHorse_02",
        TextureName = "SM_ToyHorse_02.png",
        Text = {
            en = {
                DisplayName = "Rocking Horse Decoration II",
                Description = "The second rocking horse furniture decoration in the Animal Decoration Asset Pack.",
            },
            zh = {
                DisplayName = "木马装饰摆件（款式二）",
                Description = "动物装饰资产包中的第二款木马家具摆件。",
            },
        },
    },
}

-- 返回当前语言的物品文本；没有对应翻译时回退到英文。
local function GetLocalizedItemText(ItemDefinition)
    return ItemDefinition.Text[CURRENT_LANGUAGE] or ItemDefinition.Text.en
end

-- 注册一件家具。
local function RegisterDecorationItem(ItemSubsystem, ItemTag, ItemDefinition)
    -- UE 对象路径格式：
    -- /Game/资源目录/资产名.资产名
    local MeshPath =
        ASSET_ROOT .. "/" .. ItemDefinition.MeshName .. "." .. ItemDefinition.MeshName

    -- 动态挂载的 PAK 不依赖 Asset Registry 枚举，直接按完整对象路径加载模型。
    -- LoadObject 返回 nil 通常表示：
    -- 1. ASSET_ROOT 或 MeshName 填错；
    -- 2. 模型没有进入目标 Chunk/PAK；
    -- 3. PAK 没有成功挂载。
    local MountedMesh = MOD.GAA.LoadObject("StaticMesh'" .. MeshPath .. "'")
    if not MountedMesh then
        error("Animal decoration mesh failed to load: " .. MeshPath)
    end

    local ItemText = GetLocalizedItemText(ItemDefinition)
    local NewItemData = UE.FItemDataRuntime()

    -- ItemIndex：运行时物品 ID，必须与 RegisterItemData 的第一个参数一致。
    NewItemData.ItemIndex = ItemDefinition.ItemID

    -- DisplayName / Description：商店和物品界面显示的本地化文本。
    NewItemData.DisplayName = ItemText.DisplayName
    NewItemData.Description = ItemText.Description

    -- ItemTag：决定物品出现在哪一个商店分类中。
    NewItemData.ItemTag = ItemTag

    -- Functions 是家具系统读取的键值表。键名有固定含义，不要随意改名。

    -- Mesh：家具使用的 Static Mesh 对象路径，必须与 PAK 内路径完全一致。
    NewItemData.Functions:Add("Mesh", MeshPath)

    -- Painting：是否属于壁挂家具。0 表示放在地面，1 表示悬挂在墙面。
    NewItemData.Functions:Add("Painting", "0")

    -- Show：是否显示在家具商店中。1 表示显示，0 表示隐藏。
    NewItemData.Functions:Add("Show", "1")

    -- UnlockLevel：购买所需玩家等级。0 表示从游戏开始即可购买。
    NewItemData.Functions:Add("UnlockLevel", "0")

    -- Value：家具的商店购买价格。
    NewItemData.Functions:Add("Value", "50")

    -- TexturePath：商店列表中的预览图片。
    -- 图片是 Mod 文件夹里的普通 PNG，不放进 PAK。
    -- 每件家具读取 DECORATION_ITEMS 中配置的独立图片。
    NewItemData.Functions:Add(
        "TexturePath",
        UE.UModFilesystemLib.Join(MOD.ModDir, ItemDefinition.TextureName)
    )

    -- ClassPath：购买后实际生成的家具 Actor 类型。
    -- 当前使用游戏提供的“可自由摆放家具”通用类。
    NewItemData.Functions:Add(
        "ClassPath",
        "/Script/Engine.Blueprint'/Game/2Game/Blueprint/商店饰品/BP_家具2100随意放置.BP_家具2100随意放置'"
    )

    -- BoxClassPath：购买后用于送货和搬运的包装箱 Actor 类型。
    NewItemData.Functions:Add(
        "BoxClassPath",
        "/Script/Engine.Blueprint'/Game/1Game/Blueprint/AI/BP/货物包裹/BP_货物包裹建筑.BP_货物包裹建筑'"
    )

    -- BoxHigh：包装箱生成或摆放时使用的高度参数。
    NewItemData.Functions:Add("BoxHigh", "50")

    -- BoxType：包装箱类别。2 表示建筑或家具类型包装箱。
    NewItemData.Functions:Add("BoxType", "2")

    -- 将完整运行时数据写入 ItemDataSubsystem。
    -- 如果 ItemID 已存在，会覆盖同 ID 的旧数据，所以每个 Mod 应使用独立 ID。
    ItemSubsystem:RegisterItemData(ItemDefinition.ItemID, NewItemData)

    print(
        "Animal decoration registered: "
            .. ItemText.DisplayName
            .. " -> "
            .. MeshPath
    )
end

-- 获取物品子系统、解析商店分类 Tag，然后依次注册配置表中的家具。
local function RegisterAnimalDecorations()
    local CurrentWorld = MOD.GAA.WorldUtils:GetCurrentWorld()
    local ItemSubsystem = UE.UModFilesystemLib.GetItemDataSubsystem(CurrentWorld)
    if not ItemSubsystem then
        error("Animal Decoration Asset Pack could not get ItemDataSubsystem")
    end

    -- FNameToGameplayTag 参数说明：
    -- 1. ITEM_TAG_NAME：要查找的 GameplayTag 名称。
    -- 2. false：UnLua 调用输出参数 bValid 时需要提供的占位值，不能省略。
    -- 3. false：找不到 Tag 时不让引擎额外输出一次错误，由下面代码统一报错。
    local ItemTag, bTagValid = UE.UGB_FunctionLibary.FNameToGameplayTag(
        ITEM_TAG_NAME,
        false,
        false
    )

    if not bTagValid then
        error("Invalid item GameplayTag: " .. ITEM_TAG_NAME)
    end

    for _, ItemDefinition in ipairs(DECORATION_ITEMS) do
        RegisterDecorationItem(ItemSubsystem, ItemTag, ItemDefinition)
    end
end

-- Mod 初始化入口。
-- 游戏启用该 Mod 后调用一次，用来挂载资源并注册四件家具。
function M.OnInit()
    local CurrentWorld = MOD.GAA.WorldUtils:GetCurrentWorld()
    if not CurrentWorld then
        error("Animal Decoration Asset Pack could not get the current World")
    end

    -- UE Editor/PIE 默认拒绝加载没有写入引擎版本的 Cooked Content。
    -- 该控制台变量只在 PIE 测试时启用；正式打包游戏不需要执行。
    if UE.UGB_FunctionLibary.IsRunPIE(CurrentWorld) then
        UE.UKismetSystemLibrary.ExecuteConsoleCommand(
            CurrentWorld,
            "s.AllowUnversionedContentInEditor 1",
            nil
        )
    end

    -- 挂载当前 Mod 文件夹中的所有 .pak。
    -- 公共加载器还会在同一目录自动查找并打开当前 RHI 对应的
    -- ShaderArchive-*.ushaderbytecode，必须在加载模型之前调用。
    UE.UModFilesystemLib.MountPaksInDirectory(MOD.ModDir)

    RegisterAnimalDecorations()
end

return M
