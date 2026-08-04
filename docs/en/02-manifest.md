# The mod.json manifest and permissions

[Back to the English home page](../../README_EN.md) | [中文](../zh/02-manifest.md)

If a mod root contains `mod.json`, the loader treats it as a manifest mod. An invalid manifest, missing entry, or failed load does not fall back to privileged API v1. This prevents a configuration error from giving a restricted mod the legacy environment.

## Complete example

```json
{
  "schemaVersion": 1,
  "id": "com.author.my_mod",
  "name": "My Mod",
  "version": "1.2.0",
  "apiVersion": 3,
  "entry": "v3.lua",
  "side": "both",
  "networkPolicy": "exact-match",
  "permissions": [
    "content.register",
    "storage.read",
    "storage.write"
  ],
  "dependencies": [
    {
      "id": "com.author.core",
      "version": "=1.0.0",
      "optional": false
    }
  ]
}
```

## Field reference

| Field | Required | Rules |
| --- | --- | --- |
| `schemaVersion` | No | Defaults to 1; only integer `1` is accepted. |
| `id` | Yes | 1–128 characters; letters, numbers, `.`, `_`, and `-` only; first and last must be alphanumeric. Reverse-domain form is recommended. |
| `name` | No | Defaults to `id`; 1–128 characters. |
| `version` | Yes | 1–64 characters with no leading/trailing whitespace. SemVer is recommended, but the parser currently checks only length and whitespace. |
| `apiVersion` | No | Defaults to the current version; accepts 1–3. New mods must use `3`. |
| `entry` | No | Defaults to `main.lua`; a relative `.lua` path inside the mod, at most 256 characters, with no absolute path or `..`. |
| `side` | No | `client`, `server`, or `both`; default `both`. A mismatched process skips it. |
| `networkPolicy` | No | `local-only`, `server-required`, or `exact-match`; default `exact-match`. The compatibility alias `server-authoritative` maps to `server-required`. |
| `permissions` | No | Array of lower-case, namespaced strings; `*` is forbidden. |
| `dependencies` | No | String or object array; IDs must be unique and cannot reference the same mod. |

The manifest is limited to 256 KiB.

## Permission table

| Permission | Allowed calls |
| --- | --- |
| `content.register` | Register drinks, styles, cup-add-item rules, furniture, and public content assets |
| `content.patch` | Use `bPatchExisting=true` on existing content; `content.register` is also required |
| `economy.read` | `Context.Economy:GetSnapshot()` |
| `economy.pay-bills` | `Context.Economy:TryPayBill()` |
| `storage.read` | `GetString`, `GetKeys` |
| `storage.write` | `SetString`, `Remove`, `Flush` |
| `inventory.read` | `GetItemCount` |
| `inventory.write` | `GrantItem`, `RemoveItems` |
| `tasks.write` | `AddProgress` |
| `ui.notify` | `ShowNotification` |

Event subscription and `Context:Log` need no extra permission. A granted permission does not guarantee success: state, authority, arguments, and host bridges are still validated.

## Dependencies

The shorthand only requires an Active mod:

```json
"dependencies": ["com.author.core"]
```

The object form adds optionality and a version:

```json
"dependencies": [
  { "id": "com.author.core", "version": "=1.0.0", "optional": false },
  { "id": "com.author.cosmetics", "version": "*", "optional": true }
]
```

Supported version constraints are currently limited to:

- Empty or omitted: no version check.
- `*`: any loaded version.
- `1.0.0` or `=1.0.0`: exact equality.

`>=`, `^`, `~`, and ranges are not supported. A dependency must already be Active, so the game mod list or author instructions must still ensure load order.

## side versus networkPolicy

`side` determines whether the current process executes the mod:

- `client` is skipped on a Dedicated Server.
- `server` is skipped by a pure client process.
- `both` runs in any process that loads that directory.

`networkPolicy` is multiplayer installation-policy metadata. It is parsed, validated, and stored, but the complete host/client mod-list handshake is not implemented yet. Do not claim that `exact-match` already blocks mismatched clients automatically.

Recommendations:

- Purely local visuals or notifications: `local-only`.
- Authoritative data changes where clients may be optional: use `server-required` only if that matches the design.
- Shared drinks, furniture, or gameplay content: `exact-match`, with Workshop instructions requiring the same version on host and clients.

## Naming recommendations

- Mod ID: `com.studio.mod_name`
- Local ContentId: `pumpkin_recipe`, `furniture/dog_01`
- Custom event: `com.studio.mod_name:special_event`
- Custom permissions are defined by the host; an author cannot invent a permission to gain a capability.

Do not change `id` after publishing. Change `version` for upgrades and update exact dependencies with it.
