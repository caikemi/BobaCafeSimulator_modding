# Liquid container Lua Mod API

[中文](../zh/12-liquid-containers.md) | [Create independent new items](13-new-items.md)

This API v3 extension patches capacity and one material vector parameter on the existing game Blueprint and its derived instances:

```text
/Script/Engine.Blueprint'/Game/2Game/Blueprint/BP_液体容器.BP_液体容器'
```

The game host owns the target class and applies/restores the configuration. No Blueprint replacement package or old zz override is needed. Use a game build containing this API. For a separate new shop product, use the [RegisterItem guide](13-new-items.md).

## Complete example

The [LiquidContainerCustomization example](../../Example_EN/LiquidContainerCustomization/README.md) requests capacity `20000` and sets `Param` to RGBA `(1, 0.2, 0.1, 1)`.

`mod.json`:

```json
{
  "schemaVersion": 1,
  "id": "LiquidContainerCustomization",
  "name": "Liquid Container Customization",
  "version": "1.0.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": ["content.register", "content.patch"]
}
```

`v3.lua`:

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

## Definition fields and registration

| Field | Default | Meaning |
| --- | --- | --- |
| `ContentId` | Empty FName | Required unique content ID within the mod; shared uniqueness rules apply across content types. |
| `MaxCapacity` | `0` | Existing game capacity units. Zero preserves capacity; an override must be finite, positive, and within host bounds. |
| `bOverrideMaterialParam` | `false` | Whether to override vector parameter `Param` on the first material slot, index `0`, of `StaticMesh`. |
| `MaterialParam` | White | The parameter's RGBA components, constructed with `Context.Content:MakeColor(R, G, B, A)`; used only when the override is enabled. |

Create with `MakeLiquidContainerDefinition()` and submit with `RegisterLiquidContainer(Definition)`. There is no `bPatchExisting` field: this API always patches existing containers and always requires both `content.register` and `content.patch`.

Register only in the Loading stage during `OnLoad`. Check `bSuccess` and report or throw the returned `Message` on failure. Success stages the definition; the host publishes only after the whole mod loads. Failed content transactions are rolled back. Supply at least one override: `MaxCapacity > 0` or `bOverrideMaterialParam=true`; an empty definition is rejected.

## Capacity and color behavior

Capacity applies to actual filling, capacity checks, and level display for existing containers, newly generated/purchased containers, and derived Blueprints. After save/re-entry, the enabled mod reapplies its current configuration.

Reducing capacity preserves existing liquid. If a container holds `15000` and the requested maximum drops from `20000` to `10000`, the effective maximum temporarily remains `15000` and available filling space is `0`. While dispensing, the effective maximum follows the remaining quantity downward until it reaches the requested `10000`. Restoring a smaller original capacity on unload uses the same rule. This prevents older Blueprint calculations from producing negative free space and incorrectly increasing the source container's liquid.

For color, the host creates or uses a runtime dynamic material instance on `StaticMesh` slot `0` and sets vector parameter `Param`. Component, slot, and parameter name are fixed by the game. No asset PAK is needed, and material assets are preserved.

For capacity only, leave `bOverrideMaterialParam=false`. For the parameter only, use `MaxCapacity=0`. Color components must be finite. Check initialization, save loading, and liquid-level updates for any dynamic-material recreation that might overwrite the configuration.

## Multiplayer and unload

The host decides actual capacity and container state. Use `side: both` and install the same mod version on host and clients. The parameter uses existing game materials; no extra material assets are needed. Verify connected clients and late joiners receive correct capacity, quantity, level display, and `Param`.

`networkPolicy: exact-match` is parsed and retained, but a complete host/client mod-manifest handshake has not been implemented. It does not automatically reject mismatched versions, lists, or installations.

The host restores the previous configuration on unload. If A then B override the same setting, removing B restores A; removing A while keeping B replays B. Do not hard-code an original capacity or Param in `OnUnload`, which could overwrite another active mod's configuration.

## Acceptance checks

Documentation and exported data are not PIE or multiplayer validation results.

| Scenario | Pass criteria |
| --- | --- |
| Existing containers | Real filling and level display use the capacity; `StaticMesh` slot `0` has the requested `Param`. |
| Newly purchased/generated containers | Initialization, delivery, and placement preserve the override. |
| Save/re-entry | Enabled configuration returns without creating or deleting liquid. |
| Derived Blueprints | Derived containers are covered; unrelated types preserve their behavior. |
| Smaller maximum | Liquid remains intact, free space is zero while over the requested limit, and the effective limit shrinks safely as liquid is dispensed. Unload behaves the same way. |
| Connected clients/late join | Host and clients agree on state and appearance; late joining does not reset the configuration. |
| Capacity only/parameter only | Disabled parameter override preserves Param; zero capacity preserves the existing capacity. |
| Stacked overrides/unload | Removing a layer restores/replays the appropriate remaining configuration. |
| Registration failure | Missing permissions, duplicate ContentId, invalid capacity, or non-finite color reject loading without damaging previous configuration. |
