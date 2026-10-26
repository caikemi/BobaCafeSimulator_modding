# Auto-stop Liquid Container (100L)

Adds an independent 100-liter auto-stop liquid container. New containers arrive empty, stop dispensing when a cup is full, and have a dark green exterior.

- Maximum capacity: 100L / 100000mL.
- Preserves the original large auto-stop template's mesh, delivery, and cup-full stopping behavior.
- Does not force liquid type; uses the liquid actually added.
- Price and unlock level inherit the current built-in large auto-stop container.
- Found under Goods → Ingredients; preserves built-in containers.
- Saves retain stored quantity and type without clearing or refilling.
- Includes a product icon and Workshop cover; color changes the existing dynamic material's `Param` without an extra asset PAK.

Requires API v3 `RegisterItem` and a host build with the 2026-10-26 shop-enumeration, direct-delivery identity, initial-content, and precise-save fixes. The in-game name is 自停式液体容器（100L）, with a Chinese description. All multiplayer peers need the same version; the room check compares Mod IDs/order but not versions or content hashes. Keep the mod enabled for saves containing this product.
