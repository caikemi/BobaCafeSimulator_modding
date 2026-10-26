# 液体容器 Lua Mod API

本接口为现有 API v3 增加容量和材质向量参数覆盖。目标由游戏宿主固定为：

```text
/Script/Engine.Blueprint'/Game/2Game/Blueprint/BP_液体容器.BP_液体容器'
```

MOD 不传任意 Actor 类、不改蓝图序列化内容，也不需要旧 zz 覆盖包。宿主负责把覆盖应用到实际容器及其派生实例，并在卸载时恢复。使用前需要发布包含本接口的游戏构建。

## 最小可用示例

工程内有可直接安装的 [LiquidContainerCustomization](../../Example_ZH/LiquidContainerCustomization/README.md)。默认容量为 `20000`，同时将 `StaticMesh` 第 `0` 槽的向量参数 `Param` 改为 RGBA `(1, 0.2, 0.1, 1)`。

`mod.json`：

```json
{
  "schemaVersion": 1,
  "id": "LiquidContainerCustomization",
  "name": "液体容器容量与材质示例",
  "version": "1.0.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": ["content.register", "content.patch"]
}
```

`v3.lua`：

```lua
local M = {}

function M.OnLoad(Context)
    local container = Context.Content:MakeLiquidContainerDefinition()
    container.ContentId = "liquid_container_customization"
    container.MaxCapacity = 20000
    container.bOverrideMaterialParam = true
    container.MaterialParam = Context.Content:MakeColor(1, 0.2, 0.1, 1)

    local result = Context.Content:RegisterLiquidContainer(container)
    if not result or not result.bSuccess then
        error(result and tostring(result.Message) or "Liquid container registration returned no result")
    end
    return true
end

return M
```

## 字段与注册约束

| 字段 | 类型 / 默认值 | 含义 |
| --- | --- | --- |
| `ContentId` | FName / 空 | 此 MOD 内唯一的内容 ID；与饮品、家具等定义共用唯一性检查。 |
| `MaxCapacity` | double / `0` | 最大容量，使用原容器单位。`0` 保留原容量；覆盖值必须是有限正数并通过宿主范围检查。 |
| `bOverrideMaterialParam` | bool / `false` | 是否覆盖 `StaticMesh` 第一个材质槽（索引 `0`）的向量参数 `Param`；`false` 保留原参数。 |
| `MaterialParam` | FLinearColor / 白色 | `Param` 的四个 RGBA 分量，通过 `Context.Content:MakeColor(R, G, B, A)` 构造；仅在启用覆盖时生效。 |

调用方式是 `Context.Content:MakeLiquidContainerDefinition()` 与 `Context.Content:RegisterLiquidContainer(Definition)`。没有 `bPatchExisting` 字段：该接口始终修改已有容器，因此始终需要 `content.register` 和 `content.patch` 两项权限。

只能在 `OnLoad` 的 Loading 阶段注册。每次调用都检查返回的 `bSuccess`，失败时记录或抛出 `Message`；不要无视注册失败。成功注册表示定义已暂存，整个 MOD 成功加载后才由宿主提交。任意内容项失败时，宿主负责回滚该 MOD 的内容事务。

至少提供一种覆盖：`MaxCapacity > 0` 或 `bOverrideMaterialParam=true`；两者都不启用的空定义会被拒绝。

## 容量行为

容量覆盖应影响实际加液、容量判断及液位显示，不只是显示一个额外参数。宿主需要覆盖当前已有容器、后续新生成或购买的容器，以及目标蓝图的派生类实例。保存后重新进入时，仍由当前启用的 MOD 重新应用覆盖。

降低上限不会删除已有液体。例如容器里有 `15000`，请求上限由 `20000` 降至 `10000`，有效上限先保持为当前液量 `15000`，可添加量为 `0`。随着出液，有效上限跟随液量收缩；液量降至 `10000` 或以下后，才固定为请求的 `10000`。卸载 MOD 恢复较小的原容量时采用同一原则。这避免旧蓝图计算出负的剩余空间，导致源容器液量异常增加。

## 材质向量参数

只修改现有材质的向量参数：

```lua
container.bOverrideMaterialParam = true
container.MaterialParam = Context.Content:MakeColor(1, 0.2, 0.1, 1)
```

宿主为容器的 `StaticMesh` 第 `0` 个材质槽创建或使用运行时动态材质实例，设置向量参数 `Param`。此接口无需资源 PAK，不修改原材质资产。目标组件、材质槽、参数名由游戏固定，MOD 只提供参数值。

只改容量时，保持 `bOverrideMaterialParam=false`；只改材质参数时，将 `MaxCapacity=0`。`MaterialParam` 的分量必须是有限数值。修改参数后还需检查容器初始化、存档加载和原有液位更新是否会重建动态材质并覆盖配置。

## 联机与卸载

主机决定实际容量和容器状态。使用 `side: both`，主机和客户端安装相同版本 MOD；参数覆盖直接使用游戏已有材质，无需另装材质资源。还需检查已经连接的客户端和晚加入玩家能否拿到正确容量、液位与 `Param` 参数。

`networkPolicy: exact-match` 当前会被解析、校验和保存，但完整主机/客户端 MOD 清单握手尚未实现。它不能自动阻止不同 MOD 版本、列表或资源联机；发布说明仍应明确要求双方安装一致。

卸载时由宿主恢复本 MOD 加载前的值。若 A、B 依次覆盖同一容器配置，卸载 B 应恢复 A；卸载 A 而保留 B 应重放 B。不要在 `OnUnload` 手动改回一个写死的“原始容量”或 `Param`，否则会覆盖其他 MOD 的有效配置。

## 验收场景

下表是运行验收要求，文档与示例本身不代表已经通过 PIE 或多人验证。

| 场景 | 通过标准 |
| --- | --- |
| 已有容器 | 进入已放置容器的场景后，新上限影响真实加液和液位；`StaticMesh` 第 `0` 槽的 `Param` 取指定值。 |
| 新购买 / 新生成容器 | 购买、配送和摆放完成后仍使用覆盖值，不被初始化流程改回。 |
| 存档重进 | 保存退出再进入，已存容器使用当前 MOD 配置，液体数量不凭空增减。 |
| 派生蓝图 | 目标 BP 的派生容器同样生效；其他容器类型保持原有逻辑。 |
| 降低上限 | 保留已有液体，有效上限暂为当前液量，可添加量为 0；出液后逐步收缩至请求上限。卸载恢复较小的原值时行为相同。 |
| 已连接客户端 / 晚加入 | 主机和客户端容量判断一致；已有液体、液位及 `Param` 正确；晚加入不回退默认配置。 |
| 只改容量 / 只改参数 | `bOverrideMaterialParam=false` 保留原参数；`MaxCapacity=0` 保留原容量。 |
| 卸载与叠加 | 单 MOD 卸载恢复此前值；移除覆盖中间层后，剩余层按顺序重放。 |
| 注册失败 | 缺权限、重复 ContentId、非法容量或非有限参数使加载失败，原配置或其他 MOD 覆盖仍正确。 |
