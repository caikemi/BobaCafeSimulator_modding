# Troubleshooting and release checklist

[Back to the English home page](../../README_EN.md) | [中文](../zh/10-troubleshooting.md)

First verify which file `mod.json.entry` selects. Many migrated mods keep both `main.lua` and `v3.lua`; the current build executes only the manifest entry.

## Mod is missing or will not load

Check:

- `mod.json` is directly at the mod root.
- JSON is valid UTF-8 and smaller than 256 KiB.
- `id` uses allowed characters and starts/ends alphanumeric.
- `version` is non-empty with no surrounding whitespace.
- `apiVersion` is 3.
- `entry` exists, is a relative `.lua` path, and has no `..`.
- `side` matches the current process.
- Required dependencies are already Active and exact versions match.

An invalid manifest never falls back to API v1. Fix it instead of deleting it to bypass restrictions.

## Lua reports a nil global

An error involving `UE`, `GAA`, `MOD.Playercontroller`, `io`, `os`, `require`, `debug`, or `load` means API v1 code was put into a restricted entry. Replace it with Context services using the [migration guide](08-legacy-migration.md).

The entry must `return M`, with lifecycle functions on that returned table.

## PermissionDenied

- Add the matching capability to `permissions`.
- `bPatchExisting=true` needs both `content.register` and `content.patch`.
- Never request `*`; the manifest rejects it.
- Permission names are lower-case and namespaced, such as `inventory.write`.

## InvalidState

This usually means an Active-only mutation ran in `OnLoad`. Move it to `OnModEvent`:

- `TryPayBill`
- `GrantItem` / `RemoveItems`
- `Tasks:AddProgress`
- `UI:ShowNotification`
- `Storage:Flush`

Content registration is the opposite: it belongs only in `OnLoad`.

## Content registration failures

### AlreadyExists / collision

- Every `ContentId` in one mod is unique.
- New DrinkId, LiquidId, and ItemId values cannot collide with host/other mods.
- To intentionally change an existing entry, use `bPatchExisting=true` and `content.patch`.
- Do not mark new content as a patch merely to hide ID-management problems.

### Drink exists but is not visible

- Check `DrinkId`, `DisplayName`, and `OutputLiquidId`.
- Ensure Seasons, SweetnessOptions, and TemperatureOptions were not accidentally emptied.
- Check `ImageRelativePath` spelling and case.
- The host syncs new owned recipes; do not call `EvAddDrink`.
- If a result liquid needs a style/rule, all LiquidId values must match exactly.

### Style patch has no effect

- `LiquidId` must be the actual style key.
- Set `bPatchExisting=true`.
- Request both content permissions.
- RGBA uses 0–1, not 0–255.
- Check whether a later mod patches the same key.

### Furniture is absent from the shop

- Unique `ItemId`, correct `CategoryTag`, and `bShowInShop=true`.
- Correct Mesh, ActorClass, and BoxClass object paths.
- The PAK mounts before Lua; do not manually mount from `v3.lua`. After multiplayer compatibility succeeds, asset PAKs are also pre-mounted before `ClientTravel`.
- Inspect commit errors. One invalid furniture definition rolls the whole transaction back.

## Event does not fire

- Check the `Subscribe` result.
- Check lower-case namespaced spelling.
- Determine whether it is automatic C++ or still requires a host Blueprint call.
- Put Blueprint emission on the real success branch, not UI/failure/client duplicates.
- Authoritative events are emitted by the server.
- `game.shop_closed`, `drink.served`, `furniture.placed`, and `furniture.removed` do not currently exist.

Do not conflate order stages: `order.placed`, player `order.submitted`, customer `order.picked_up`.

## Economy / Inventory / Tasks / UI failures

- Context is Active.
- Mutation runs with server authority.
- PlayerIndex is non-negative and exists.
- ItemId exists and Count is 1–100.
- TaskTag is registered and Count is 1–100000.
- Notification is non-empty and at most 512 characters.
- Bill type is WaterRate, Utility, Rent, or Payroll; amount is positive and host balance/bill rules pass.

## Storage failures

- Key follows character/length rules.
- Complete JSON stays under 64 KiB.
- Read and write permissions are requested separately.
- `Flush` is called only while Active.
- If storage.json was manually corrupted, back it up and restore valid JSON with `schemaVersion` and a string-valued `data` object.

## PAK / model / material

### Model not found

- Use UE5.6.
- `MeshObjectPath` comes from Content: `/Game/Pack/Asset.Asset`.
- PrimaryAssetLabel Chunk contains model and dependencies.
- Copy the target Chunk, not `pakchunk0`.
- Disable IoStore and produce a `.pak`.

### Gray, black, or missing material

- Materials and textures are in the same Chunk.
- `Share Material Shader Code` is enabled.
- Both SM5/SM6 ShaderArchives are at mod root and unrenamed.
- Game release and author pack use the compatible non-IoStore PAK flow.
- Do not mix stale `.utoc/.ucas` output.

See the [PAK packaging guide](../../Model_PAK_Packaging_EN.md).

## Multiplayer issues

`side` skips mismatched processes. The current room check compares Mod IDs and load order and pre-mounts PAKs, but it does not compare versions or content hashes; Workshop instructions, server policy, and manual tests must still ensure matching versions. Never treat a client UI event as an authoritative server result.

## Release checklist

- [ ] ID, version, entry, permissions, and dependencies are accurate.
- [ ] Chinese/English README matches actual behavior.
- [ ] No credentials, development-machine absolute paths, or debug files.
- [ ] Lua syntax and OnLoad contract pass.
- [ ] New-save, load-save, disable, and re-enable pass.
- [ ] Added and patched content both roll back on unload.
- [ ] Test load order with common related mods.
- [ ] PAK contents, ShaderArchives, and previews are complete.
- [ ] Workshop page states multiplayer, dependency, and conflict requirements.
- [ ] Do not advertise unimplemented music, localization, arbitrary UI, or multiplayer-handshake capabilities.
