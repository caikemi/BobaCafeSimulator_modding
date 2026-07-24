-- 平台限制：当前外部 MP3 背景音乐功能仅支持 Windows，Mac/macOS 不可用。
local M = {
    id = "CustomBGM",
    name = "自定义背景音乐",
    description = "仅支持 Windows；随机循环播放当前 Mod 根目录中的 MP3 音乐",
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
        log_screen("[CustomBGM] 播放失败：C++ 外部 BGM 接口尚未就绪", 1, 0, 0)
        return false
    end

    local modDirectory = MOD and MOD.ModDir or nil
    if not modDirectory or modDirectory == "" then
        log_screen("[CustomBGM] 播放失败：没有取得 Mod 根目录", 1, 0, 0)
        return false
    end

    local started = playerController:PlayModBackgroundMusicFromDirectory(
        modDirectory,
        SHUFFLE,
        VOLUME_MULTIPLIER
    )

    if not started then
        log_screen("[CustomBGM] 根目录中没有可播放的 MP3，将尝试其他 BGM Mod 或默认音乐", 1, 1, 0)
        return false
    end

    log_screen("[CustomBGM] 已开始随机循环播放根目录 MP3", 0, 1, 0)
    return true
end

function M.OnInit()
    local playerController = MOD and MOD.Playercontroller or nil
    if not playerController or not playerController.RegisterBackgroundMusicMod then
        log_screen("[CustomBGM] 注册失败：BGM Mod Hook 尚未就绪", 1, 0, 0)
        return
    end

    local registered = playerController:RegisterBackgroundMusicMod(
        M.id,
        M.priority,
        start_background_music
    )

    if registered then
        log_screen("[CustomBGM] 已注册背景音乐提供者", 0, 1, 1)
    else
        log_screen("[CustomBGM] 背景音乐提供者注册失败", 1, 0, 0)
    end
end

return M
