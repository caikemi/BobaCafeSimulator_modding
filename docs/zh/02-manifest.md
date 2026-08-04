# mod.json 清单与权限

[返回中文首页](../../README.md) | [English](../en/02-manifest.md)

只要 MOD 根目录存在 `mod.json`，加载器就按清单 API 处理。清单无效、入口缺失或加载失败时，不会退回高权限 API v1；这可以防止一个本应受限的 MOD 因配置错误意外获得旧环境能力。

## 完整示例

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

## 字段参考

| 字段 | 必填 | 规则 |
| --- | --- | --- |
| `schemaVersion` | 否 | 默认 1；当前只接受整数 `1`。 |
| `id` | 是 | 1–128 字符；仅字母、数字、`.`、`_`、`-`；首尾必须是字母或数字。建议反向域名格式。 |
| `name` | 否 | 默认等于 `id`；1–128 字符。 |
| `version` | 是 | 1–64 字符，首尾不能有空格。建议 SemVer，但当前解析器只做长度/空白校验。 |
| `apiVersion` | 否 | 默认当前版本；可接受 1–3。新 MOD 必须写 `3`。 |
| `entry` | 否 | 默认 `main.lua`；最长 256 字符的 MOD 内相对 `.lua` 路径，禁止绝对路径和 `..`。 |
| `side` | 否 | `client`、`server`、`both`；默认 `both`。错误执行端会跳过。 |
| `networkPolicy` | 否 | `local-only`、`server-required`、`exact-match`；默认 `exact-match`。兼容别名 `server-authoritative` 会按 `server-required` 解析。 |
| `permissions` | 否 | 小写、带命名空间的字符串数组；不能使用 `*`。 |
| `dependencies` | 否 | 依赖字符串或对象数组；ID 唯一、不能依赖自己。 |

清单文件最大 256 KiB。

## 权限表

| 权限 | 允许的调用 |
| --- | --- |
| `content.register` | 注册饮品、样式、杯子加物品规则、家具和公开内容资产 |
| `content.patch` | 设置 `bPatchExisting=true` 覆盖已存在内容；还必须同时申请 `content.register` |
| `economy.read` | `Context.Economy:GetSnapshot()` |
| `economy.pay-bills` | `Context.Economy:TryPayBill()` |
| `storage.read` | `GetString`、`GetKeys` |
| `storage.write` | `SetString`、`Remove`、`Flush` |
| `inventory.read` | `GetItemCount` |
| `inventory.write` | `GrantItem`、`RemoveItems` |
| `tasks.write` | `AddProgress` |
| `ui.notify` | `ShowNotification` |

事件订阅和 `Context:Log` 不需要额外权限。申请权限并不保证调用一定成功：状态、服务器权威、参数和宿主桥接仍会校验。

## 依赖

简写只检查 MOD 是否已 Active：

```json
"dependencies": ["com.author.core"]
```

对象形式可指定可选依赖和版本：

```json
"dependencies": [
  { "id": "com.author.core", "version": "=1.0.0", "optional": false },
  { "id": "com.author.cosmetics", "version": "*", "optional": true }
]
```

当前支持的版本约束只有：

- 空字符串或省略：不检查版本。
- `*`：任意已加载版本。
- `1.0.0` 或 `=1.0.0`：完全相等。

当前不支持 `>=`、`^`、`~` 或版本区间。依赖必须在当前 MOD 之前进入 Active；因此实际加载顺序仍要由游戏 MOD 列表/作者说明保证。

## side 与 networkPolicy 的区别

`side` 会影响当前进程是否执行 MOD：

- `client` 在 Dedicated Server 跳过。
- `server` 在纯客户端进程跳过。
- `both` 在可加载该目录的进程执行。

`networkPolicy` 是联机安装策略元数据。当前版本会解析、校验和保存它，但完整的主机/客户端 MOD 清单握手尚未实现。不要宣称 `exact-match` 已自动阻止不同 MOD 列表联机。

推荐：

- 纯本地视觉/提示：`local-only`。
- 改变权威数据但客户端可选：按实际设计使用 `server-required`。
- 添加饮品、家具或影响双方共享内容：`exact-match`，并在创意工坊说明主机和客户端需要同版本。

## ID 和权限命名建议

- MOD ID：`com.studio.mod_name`
- 本地 ContentId：`pumpkin_recipe`、`furniture/dog_01`
- 自定义事件：`com.studio.mod_name:special_event`
- 自定义权限由宿主定义；MOD 作者不能自行发明一个权限来获得能力。

发布后不要更改 `id`。升级时只改 `version`，并同步精确依赖。
