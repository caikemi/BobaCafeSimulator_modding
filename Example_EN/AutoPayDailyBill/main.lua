-- AI translation notice: this English example was translated with AI and may
-- contain inaccurate wording. Refer to the matching file under Example_ZH if needed.

local M = {
    id          = "AutoPayDailyBill",
    name        = "Automatic Daily Bill Payment",
    description = "Server only; automatically pays water, utilities, rent, and payroll every morning in that order",
    version     = "1.2.0",
    author      = "yiming",
}

-- Runtime GameplayTag name: do not translate this value.
local TASK_TAG_NAME = "任务.支付1笔账单"
local MIN_BILL_AMOUNT = 0.0001

-- This order is the automatic-payment priority. If the balance is insufficient,
-- no later item is attempted.
local BILL_SEQUENCE = {
    {
        Name = "Water",
        Type = "WaterRate",
        GetAmount = function(bill) return bill.WaterRate end,
        Clear = function(bill) bill.WaterRate = 0.0 end,
    },
    {
        Name = "Utilities",
        Type = "Utility",
        GetAmount = function(bill) return bill.Utility end,
        Clear = function(bill) bill.Utility = 0.0 end,
    },
    {
        Name = "Rent",
        Type = "Rent",
        GetAmount = function(bill) return bill.Rent end,
        Clear = function(bill) bill.Rent = 0.0 end,
    },
    {
        Name = "Payroll",
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
    return playerController.TrySpendAllPlayerMoneyForAutoPayMod
        and playerController.SetServerBill
        and playerController.AddPlayerTaskByTagName
        and gameState.AddPaidBillToDayData
end

local function show_paid_tip(playerController, paidNames, paidTotal)
    if #paidNames == 0 or not playerController.ShowPermissionTip then
        return
    end

    local message = string.format(
        "Bills paid automatically: %s; total %.2f",
        table.concat(paidNames, ", "),
        paidTotal
    )
    playerController:ShowPermissionTip(message)
end

-- Called every morning by the PlayerController Mod Hook.
local function on_daily_morning(playerController, dayNumber)
    if not playerController or not playerController:HasAuthority() then
        return
    end

    local gameState = get_game_state(playerController)
    if not gameState or gameState.AllPlayerMoney == nil or not gameState.Bill then
        log_screen("[AutoPayDailyBill] Payment failed: GB_MultiGameState is not ready", 1, 0, 0)
        return
    end

    if not validate_payment_api(playerController, gameState) then
        log_screen("[AutoPayDailyBill] Payment failed: a required C++ Mod API is not ready", 1, 0, 0)
        return
    end

    local playerIndex = playerController.PlayerIndex
    if playerIndex == nil or playerIndex < 0 then
        log_screen("[AutoPayDailyBill] Payment failed: PlayerIndex is not ready", 1, 0, 0)
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
                        "[%s] Automatic payment stopped on day %s: %s needs %.2f, but only %.2f is available",
                        M.id, tostring(dayNumber), billInfo.Name, amount, balance
                    ),
                    1, 0, 0
                )
                break
            end

            -- 1. Deduct shared money through the non-RPC, server-only API.
            -- The parameter must be a positive expense.
            local moneySpent = playerController:TrySpendAllPlayerMoneyForAutoPayMod(amount)
            if not moneySpent then
                log_screen(
                    string.format("[%s] Automatic payment stopped: the server rejected the %s deduction of %.2f", M.id, billInfo.Name, amount),
                    1, 0, 0
                )
                break
            end
            balance = balance - amount

            -- 2. Add the negative of this payment to the matching DayData field.
            local dayDataUpdated = gameState:AddPaidBillToDayData(billInfo.Type, amount)
            if not dayDataUpdated then
                error(string.format("Failed to write %s payment to DayData", billInfo.Name))
            end

            -- 3. Clear the current bill. SetNewBill_Server also synchronizes the
            -- itemized details for water and utilities.
            billInfo.Clear(bill)
            playerController:SetServerBill(bill)

            -- 4. Add 1 to the same task Tag after every successful payment.
            local taskAdded = playerController:AddPlayerTaskByTagName(
                playerIndex,
                TASK_TAG_NAME,
                1,
                false
            )
            if not taskAdded then
                error(string.format("Failed to add task Tag: %s", TASK_TAG_NAME))
            end

            paidCount = paidCount + 1
            paidTotal = paidTotal + amount
            paidNames[#paidNames + 1] = billInfo.Name
            log_screen(
                string.format(
                    "[%s] Automatically paid %s: %.2f; %.2f remains",
                    M.id, billInfo.Name, amount, balance
                ),
                0, 1, 0
            )
        end
    end

    -- Call ShowPermissionTip only once so multiple bills do not create
    -- overlapping notifications.
    show_paid_tip(playerController, paidNames, paidTotal)

    if paidCount == 0 then
        log_screen(
            string.format("[%s] Morning of day %s: no bills need payment", M.id, tostring(dayNumber)),
            0, 1, 1
        )
    else
        log_screen(
            string.format("[%s] Morning of day %s: automatically paid %d bill(s)", M.id, tostring(dayNumber), paidCount),
            0, 1, 1
        )
    end
end

function M.OnInit()
    local pc = MOD and MOD.Playercontroller or nil
    if not pc or not pc:HasAuthority() then
        log_screen("[AutoPayDailyBill] Server installation required; clients do not register automatic payment", 1, 1, 0)
        return
    end

    if not pc or not pc.RegisterDailyMorningModHook then
        log_screen("[AutoPayDailyBill] Registration failed: the daily-morning Mod Hook is not ready", 1, 0, 0)
        return
    end

    local registered = pc:RegisterDailyMorningModHook(M.id, on_daily_morning)
    if registered then
        log_screen("[AutoPayDailyBill] Daily-morning callback registered", 0, 1, 1)
    else
        log_screen("[AutoPayDailyBill] Failed to register the daily-morning callback", 1, 0, 0)
    end
end

return M
