-- AI translation notice: this English example was translated with AI and may
-- contain inaccurate wording. Refer to the matching file under Example_ZH if needed.

-- Platform limitation: external MP3 background music currently supports Windows
-- only and is unavailable on Mac/macOS.
local M = {
    id = "CustomBGM",
    name = "Custom Background Music",
    description = "Windows only; randomly loops MP3 files in this Mod's root directory",
    version = "1.0.0",
    author = "yiming",
    priority = 100,
}

local SHUFFLE = true
local VOLUME_MULTIPLIER = 1.0

local function log_screen(message, red, green, blue)
    if MOD and MOD.Logger then
        MOD.Logger.LogScreen(message, 8, red, green, blue, 1)
    end
end

local function start_background_music(playerController)
    if not playerController or not playerController.PlayModBackgroundMusicFromDirectory then
        log_screen("[CustomBGM] Playback failed: the C++ external BGM API is not ready", 1, 0, 0)
        return false
    end

    local modDirectory = MOD and MOD.ModDir or nil
    if not modDirectory or modDirectory == "" then
        log_screen("[CustomBGM] Playback failed: could not get the Mod root directory", 1, 0, 0)
        return false
    end

    local started = playerController:PlayModBackgroundMusicFromDirectory(
        modDirectory,
        SHUFFLE,
        VOLUME_MULTIPLIER
    )

    if not started then
        log_screen("[CustomBGM] No playable MP3 was found in the root directory; trying another BGM Mod or the default music", 1, 1, 0)
        return false
    end

    log_screen("[CustomBGM] Started randomly looping MP3 files from the root directory", 0, 1, 0)
    return true
end

function M.OnInit()
    local playerController = MOD and MOD.Playercontroller or nil
    if not playerController or not playerController.RegisterBackgroundMusicMod then
        log_screen("[CustomBGM] Registration failed: the BGM Mod Hook is not ready", 1, 0, 0)
        return
    end

    local registered = playerController:RegisterBackgroundMusicMod(
        M.id,
        M.priority,
        start_background_music
    )

    if registered then
        log_screen("[CustomBGM] Background-music provider registered", 0, 1, 1)
    else
        log_screen("[CustomBGM] Failed to register the background-music provider", 1, 0, 0)
    end
end

return M
