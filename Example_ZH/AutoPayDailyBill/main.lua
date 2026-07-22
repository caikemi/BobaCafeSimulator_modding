local M = {
    id          = "AutoPayDailyBill",
    name        = "每天自动支付账单",
    description = "每天早晨按水费、电费、租金、工资的顺序自动支付账单",
    version     = "1.1.1",
    author      = "yiming",
}

local TASK_TAG_NAME = "任务.支付1笔账单"
local MIN_BILL_AMOUNT = 0.0001

-- 顺序就是自动支付优先级；余额不足时不再执行后续项目。
local BILL_SEQUENCE = {
    {
        Name = "水费",
        Type = "WaterRate",
        GetAmount = function(bill) return bill.WaterRate end,
        Clear = function(bill) bill.WaterRate = 0.0 end,
    },
    {
        Name = "电费",
        Type = "Utility",
        GetAmount = function(bill) return bill.Utility end,
        Clear = function(bill) bill.Utility = 0.0 end,
    },
    {
        Name = "租金",
        Type = "Rent",
        GetAmount = function(bill) return bill.Rent end,
        Clear = function(bill) bill.Rent = 0.0 end,
    },
    {
        Name = "工资",
        Type = "Payroll",
        GetAmount = function(bill) return bill.Payroll end,
        Clear = function(bill) bill.Payroll = 0.0 end,
    },
}

local function log_screen(message, red, green, blue)
    if MOD and MOD.Logger then
        MOD.Logger.LogScreen(message, 8, red, green, blue, 1)
    end
end

local function get_game_state(playerController)
    local world = playerController and playerController:GetWorld() or nil
    return world and UE.UGameplayStatics.GetGameState(world) or nil
end

local function validate_payment_api(playerController, gameState)
    return playerController.AddAllPlayerMoneyToGameState
        and playerController.SetServerBill
        and playerController.AddPlayerTaskByTagName
        and gameState.AddPaidBillToDayData
end

local function show_paid_tip(playerController, paidNames, paidTotal)
    if #paidNames == 0 or not playerController.ShowPermissionTip then
        return
    end

    local message = string.format(
        "账单已自动支付：%s，合计 %.2f",
        table.concat(paidNames, "、"),
        paidTotal
    )
    playerController:ShowPermissionTip(message)
end

-- 每天早晨由 PlayerController 的 Mod Hook 调用。
local function on_daily_morning(playerController, dayNumber)
    if not playerController or not playerController:HasAuthority() then
        return
    end

    local gameState = get_game_state(playerController)
    if not gameState or gameState.AllPlayerMoney == nil or not gameState.Bill then
        log_screen("[AutoPayDailyBill] 支付失败：GB_MultiGameState 未就绪", 1, 0, 0)
        return
    end

    if not validate_payment_api(playerController, gameState) then
        log_screen("[AutoPayDailyBill] 支付失败：所需 C++ Mod 接口未就绪", 1, 0, 0)
        return
    end

    local playerIndex = playerController.PlayerIndex
    if playerIndex == nil or playerIndex < 0 then
        log_screen("[AutoPayDailyBill] 支付失败：PlayerIndex 未就绪", 1, 0, 0)
        return
    end

    local balance = tonumber(gameState.AllPlayerMoney) or 0.0
    local bill = gameState.Bill
    local paidCount = 0
    local paidTotal = 0.0
    local paidNames = {}

    for _, billInfo in ipairs(BILL_SEQUENCE) do
        local amount = tonumber(billInfo.GetAmount(bill)) or 0.0

        if amount > MIN_BILL_AMOUNT then
            if balance + MIN_BILL_AMOUNT < amount then
                log_screen(
                    string.format(
                        "[%s] 第 %s 天自动支付停止：%s需要 %.2f，当前只有 %.2f",
                        M.id, tostring(dayNumber), billInfo.Name, amount, balance
                    ),
                    1, 0, 0
                )
                break
            end

            -- 1. 扣除共享金钱。
            playerController:AddAllPlayerMoneyToGameState(-amount)
            balance = balance - amount

            -- 2. DayData 对应字段累加本次支付金额的负数。
            local dayDataUpdated = gameState:AddPaidBillToDayData(billInfo.Type, amount)
            if not dayDataUpdated then
                error(string.format("写入 %s 的 DayData 失败", billInfo.Name))
            end

            -- 3. 清空当前账单；水费、电费的明细由 SetNewBill_Server 同步清空。
            billInfo.Clear(bill)
            playerController:SetServerBill(bill)

            -- 4. 每成功支付一笔，都给同一个任务 Tag 增加 1。
            local taskAdded = playerController:AddPlayerTaskByTagName(
                playerIndex,
                TASK_TAG_NAME,
                1,
                false
            )
            if not taskAdded then
                error(string.format("添加任务 Tag 失败：%s", TASK_TAG_NAME))
            end

            paidCount = paidCount + 1
            paidTotal = paidTotal + amount
            paidNames[#paidNames + 1] = billInfo.Name
            log_screen(
                string.format(
                    "[%s] 已自动支付%s %.2f，剩余 %.2f",
                    M.id, billInfo.Name, amount, balance
                ),
                0, 1, 0
            )
        end
    end

    -- ShowPermissionTip 只调用一次，避免多笔账单产生重叠提示。
    show_paid_tip(playerController, paidNames, paidTotal)

    if paidCount == 0 then
        log_screen(
            string.format("[%s] 第 %s 天早晨：没有需要支付的账单", M.id, tostring(dayNumber)),
            0, 1, 1
        )
    else
        log_screen(
            string.format("[%s] 第 %s 天早晨：共自动支付 %d 笔账单", M.id, tostring(dayNumber), paidCount),
            0, 1, 1
        )
    end
end

function M.OnInit()
    local pc = MOD and MOD.Playercontroller or nil
    if not pc or not pc.RegisterDailyMorningModHook then
        log_screen("[AutoPayDailyBill] 注册失败：每日早晨 Mod Hook 尚未就绪", 1, 0, 0)
        return
    end

    local registered = pc:RegisterDailyMorningModHook(M.id, on_daily_morning)
    if registered then
        log_screen("[AutoPayDailyBill] 已注册每日早晨回调", 0, 1, 1)
    else
        log_screen("[AutoPayDailyBill] 注册每日早晨回调失败", 1, 0, 0)
    end
end

return M
