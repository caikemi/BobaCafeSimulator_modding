local M = {}

local billTypes = {
    { name = "WaterRate", field = "WaterRate" },
    { name = "Utility", field = "Utility" },
    { name = "Rent", field = "Rent" },
    { name = "Payroll", field = "Payroll" },
}

function M.OnLoad(Context)
    local result = Context.Events:Subscribe("game.morning_started")
    if not result.bSuccess then
        Context:Log("Could not subscribe: " .. tostring(result.Message))
        return false
    end
    return true
end

function M.OnModEvent(Context, Event)
    if Event.EventName ~= "game.morning_started" then
        return
    end

    local snapshot = Context.Economy:GetSnapshot()
    if not snapshot.bSuccess then
        Context:Log("Economy snapshot failed: " .. tostring(snapshot.Error))
        return
    end

    local balance = snapshot.Balance
    for _, bill in ipairs(billTypes) do
        local amount = snapshot.Bills[bill.field] or 0
        if amount > 0 and balance >= amount then
            local paid = Context.Economy:TryPayBill(bill.name, amount)
            if paid.bSuccess then
                balance = balance - amount
                Context:Log(("Paid %s: %.2f"):format(bill.name, amount))
            else
                Context:Log(("Could not pay %s: %s"):format(
                    bill.name,
                    tostring(paid.Message)
                ))
            end
        end
    end

    local stored = Context.Storage:SetString(
        "autopay/last_processed_event",
        tostring(Event.Sequence)
    )
    if stored.bSuccess then
        local flushed = Context.Storage:Flush()
        if not flushed.bSuccess then
            Context:Log("Storage flush failed: " .. tostring(flushed.Message))
        end
    end
end

return M
