# CustomBGM (legacy API v1 only)

[Back to examples](../README.md) | [中文](../../Example_ZH/CustomBGM/)

This folder preserves the legacy Windows MP3 compatibility example and intentionally has no `mod.json`. It depends on privileged internal APIs and is not a BaseInstall API v3 template.

The current v3 `BaseInstallModMusicAsset` is not connected to the game music registry, and arbitrary MP3/file access is not public. It cannot be safely migrated yet; do not add a fake API 3 manifest.

Existing player builds may continue to run it through compatibility, but internal game changes can affect it.
