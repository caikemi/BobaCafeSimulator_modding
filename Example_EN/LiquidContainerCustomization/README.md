# Liquid-container capacity and Param example

Requires a game build exposing `MakeLiquidContainerDefinition` / `RegisterLiquidContainer`.
This example changes existing containers to capacity `20000` and sets `StaticMesh` material slot `0` vector parameter `Param` to RGBA `(1, 0.2, 0.1, 1)`. It does not add a new item. Use NewLiquidContainerItem to register an independent ItemId.

The mod requires `content.register` and `content.patch`, and registers during OnLoad. No asset PAK is needed. Unload restores the previous layer. Shrinking below the current quantity retains the liquid and gradually reduces the effective maximum as liquid is dispensed.

[English guide](../../docs/en/12-liquid-containers.md) | [中文教程](../../docs/zh/12-liquid-containers.md)
