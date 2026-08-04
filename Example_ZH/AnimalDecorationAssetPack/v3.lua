local M = {
    id = "AnimalDecorationAssetPack",
}

local items = {
    {
        contentId = "dog_01",
        itemId = "Mod_AnimalDecoration_Dog_01",
        name = "小狗装饰摆件",
        description = "动物装饰资产包中的小狗主题家具摆件。",
        mesh = "SM_ToyDog_01",
        image = "SM_ToyDog_01.png",
    },
    {
        contentId = "elephant_01",
        itemId = "Mod_AnimalDecoration_Elephant_01",
        name = "大象装饰摆件",
        description = "动物装饰资产包中的大象主题家具摆件。",
        mesh = "SM_ToyElephant_01",
        image = "SM_ToyElephant_01.png",
    },
    {
        contentId = "horse_01",
        itemId = "Mod_AnimalDecoration_Horse_01",
        name = "木马装饰摆件（款式一）",
        description = "动物装饰资产包中的第一款木马家具摆件。",
        mesh = "SM_ToyHorse_01",
        image = "SM_ToyHorse_01.png",
    },
    {
        contentId = "horse_02",
        itemId = "Mod_AnimalDecoration_Horse_02",
        name = "木马装饰摆件（款式二）",
        description = "动物装饰资产包中的第二款木马家具摆件。",
        mesh = "SM_ToyHorse_02",
        image = "SM_ToyHorse_02.png",
    },
}

local function require_success(result)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "ModAPI returned no result")
    end
end

function M.OnLoad(Context)
    for _, item in ipairs(items) do
        local definition = Context.Content:MakeFurnitureDefinition()
        definition.ContentId = item.contentId
        definition.ItemId = item.itemId
        definition.DisplayName = item.name
        definition.Description = item.description
        definition.CategoryTag = "购买.装饰.家具"
        definition.MeshObjectPath =
            "/Game/AddMeshTestMod1/" .. item.mesh .. "." .. item.mesh
        definition.PreviewImageRelativePath = item.image
        definition.ActorClassPath =
            "/Script/Engine.Blueprint'/Game/2Game/Blueprint/商店饰品/BP_家具2100随意放置.BP_家具2100随意放置'"
        definition.BoxClassPath =
            "/Script/Engine.Blueprint'/Game/1Game/Blueprint/AI/BP/货物包裹/BP_货物包裹建筑.BP_货物包裹建筑'"
        definition.PurchasePrice = 50
        definition.UnlockLevel = 0
        definition.BoxHeight = 50
        definition.BoxType = 2
        definition.bShowInShop = true
        definition.bAllowPainting = false
        require_success(Context.Content:RegisterFurniture(definition))
    end

    Context:Log("Staged four animal furniture definitions.")
    return true
end

return M
