# 液体容器容量与材质示例

需要包含 `MakeLiquidContainerDefinition` / `RegisterLiquidContainer` 的游戏版本。这个示例通过游戏 Lua API 覆盖已有液体容器参数，不替换原游戏蓝图。

默认启用后，把 `/Game/2Game/Blueprint/BP_液体容器` 及其派生容器的最大容量改为 `20000`，并将 `StaticMesh` 第一个材质槽（索引 `0`）的向量参数 `Param` 改为 RGBA `(1, 0.2, 0.1, 1)`。容量使用原容器的单位。将 `v3.lua` 中的 `MAX_CAPACITY` 改成需要的数值；`0` 表示保留原容量。若现存液量超过新上限，有效上限先保持为当前液量，可添加量为 0；出液后再逐步收缩至请求上限，不删除已有液体。卸载恢复较小的原容量时行为相同。

## 使用

1. 把此目录作为完整 MOD 目录安装并在游戏 MOD 列表启用，保持 `mod.json` 和 `v3.lua` 在同一层。
2. 使用包含新接口的游戏构建进入存档，检查已有容器和新购买容器的容量。
3. 联机时主机和客户端安装同版本 MOD。清单的 `exact-match` 当前只是安装策略元数据，尚无完整 MOD 清单握手，不能自动拦截不一致的安装。

`RegisterLiquidContainer` 只能在 `OnLoad` 调用，必须同时申请 `content.register` 与 `content.patch`。返回成功表示已暂存；整个 MOD 加载成功后由宿主提交应用。脚本已经检查注册结果，失败会中止加载。卸载由宿主恢复之前的覆盖值，脚本不需要手动恢复。

## 修改材质参数

在 `v3.lua` 中调整以下两行：

```lua
container.bOverrideMaterialParam = true
container.MaterialParam = Context.Content:MakeColor(1, 0.2, 0.1, 1)
```

`MakeColor(R, G, B, A)` 接收向量参数的四个分量。将 `bOverrideMaterialParam` 改为 `false` 可只改容量，保留材质原有 `Param`。

宿主通过运行时动态材质实例设置 `StaticMesh` 第 `0` 槽的向量参数 `Param`。此接口无需资源 PAK，不修改原材质资产，也不替换为另一份材质。目标组件、材质槽和参数名由游戏固定。

完整字段、覆盖与验收说明见 [液体容器 Mod API](../../docs/zh/12-liquid-containers.md)。
