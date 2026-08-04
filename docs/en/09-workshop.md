# Publishing to the Steam Workshop

[Back to the English home page](../../README_EN.md) | [中文](../zh/09-workshop.md)

Game Steam App ID: `3683770`. Fully test under the local Mods directory before uploading. Official Valve references: [Steam Workshop Implementation Guide](https://partner.steamgames.com/doc/features/workshop/implementation) and [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD).

SteamCMD requires the author to sign in and is suitable for manual release/testing. Never put a password or Steam Guard code in a BAT, VDF, or repository.

## 1. Prepare the upload folder

```text
D:/BobaWorkshop/
├── Mods/
│   └── MyMod/
│       ├── mod.json
│       ├── v3.lua
│       ├── preview.png
│       └── other resources
└── Upload/
    ├── MyMod.vdf
    └── upload_MyMod.bat
```

The `MyMod` directory referenced by `contentfolder` must directly contain `mod.json`; do not add another same-name nesting level.

An asset mod should also include:

- `*.pak`
- SM5 and SM6 `ShaderArchive-*.ushaderbytecode`
- loose preview images

Do not upload authoring-project `Saved`, `Intermediate`, `DerivedDataCache`, credentials, or stale `.utoc/.ucas` files.

## 2. Local acceptance test

1. Copy to `BobaCafeSimulator/Mods/MyMod/`.
2. Enable it in the Mods menu.
3. Test a new save and a loaded save.
4. Disable and verify content rollback.
5. Re-enable and verify no duplicate content/reward.
6. If dependent, test missing and wrong-version dependencies.
7. Test multiplayer content with the same version on host and clients.

## 3. Create the VDF

```vdf
"workshopitem"
{
    "appid"            "3683770"
    "publishedfileid"  "0"
    "contentfolder"    "D:\\BobaWorkshop\\Mods\\MyMod"
    "previewfile"      "D:\\BobaWorkshop\\Mods\\MyMod\\preview.png"
    "visibility"       "2"
    "title"            "My Mod"
    "description"      "A BaseInstall API v3 mod."
    "changenote"       "v1.0.0"
}
```

| Field | Meaning |
| --- | --- |
| `appid` | Always `3683770` |
| `publishedfileid` | `0` for first publish; SteamCMD writes the new ID back |
| `contentfolder` | Absolute mod-root path |
| `previewfile` | Absolute preview-image path |
| `visibility` | `0` public, `1` friends-only, `2` private, `3` unlisted; start with 2 |
| `title` | Workshop title |
| `description` | State dependencies, multiplayer requirements, and API version |
| `changenote` | This update's notes |

Save VDF as UTF-8. Escape Windows path backslashes as double backslashes.

## 4. Install and initialize SteamCMD

1. Download Windows SteamCMD to an English path such as `C:/SteamCMD/`.
2. Run `steamcmd.exe` once and wait for its self-update.
3. Enter `quit` at the `Steam>` prompt.

## 5. Upload script

```bat
@echo off
setlocal
set "STEAMCMD=C:\SteamCMD\steamcmd.exe"
set "VDF=D:\BobaWorkshop\Upload\MyMod.vdf"

"%STEAMCMD%" +login YourSteamAccount +workshop_build_item "%VDF%" +quit

echo.
echo SteamCMD finished. Check the output for ERROR or Failed.
pause
```

Enter the password and Steam Guard code when prompted. Do not append them to `+login`.

## 6. First publish

1. Keep `publishedfileid "0"`.
2. Run the BAT.
3. Confirm there is no `ERROR` or `Failed`.
4. Reopen the VDF. SteamCMD replaces the ID with a number on success; back up that VDF.
5. Open `https://steamcommunity.com/sharedfiles/filedetails/?id=<ID>`.
6. Accept the Workshop legal agreement if prompted.
7. Subscribe-test while private, then change `visibility` to `0` and upload again.

## 7. Update an existing item

1. Change the files under contentfolder.
2. Update `mod.json.version` and VDF `changenote`.
3. Repeat local acceptance.
4. Preserve the original `publishedfileid`; never reset it to 0.
5. Run the same BAT.

Resetting the ID to 0 attempts to create a new item.

## 8. Subscription acceptance

Steam may download a newly subscribed item after the game has launched. Confirm completion in Downloads, then restart the game.

Typical cache location:

```text
<SteamLibrary>/steamapps/workshop/content/3683770/<PublishedFileId>/
```

Open that numeric directory and verify `mod.json` is directly at its root.

## Workshop page requirements

- Mod ID, version, and API version.
- Required/optional dependencies and exact versions.
- Whether both host and clients must install.
- Added or patched DrinkId, LiquidId, and ItemId values.
- Whether PAK/ShaderArchive files are included.
- Save-data impact of uninstalling.
- Known conflicts and unsupported capabilities.

The complete multiplayer manifest handshake is not implemented yet, so `networkPolicy` metadata does not replace clear Workshop installation instructions.

## Common upload problems

| Symptom | Check |
| --- | --- |
| VDF/preview not found | Existing absolute path; extension is not `.txt` |
| Upload works but game cannot find it | Workshop ID root directly contains `mod.json` |
| Update creates another item | Do not reset `publishedfileid` to 0 |
| Page is not public | `visibility=0` and legal agreement accepted |
| Subscription not downloaded | Wait for Steam Downloads and restart |
| Model has no material | Upload the PAK and unrenamed SM5/SM6 ShaderArchives |
| Need detailed errors | Steam `logs/Workshop_log.txt` and workshop build logs |
