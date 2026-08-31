local DotaAdapter = require("dota_adapter")
local Decision = require("decision")
local Debug = require("debug")

local Observer = {}

local REPORT_INTERVAL = 5
local next_report_time = 0

-- Observes and logs only. It never returns orders or changes a mode desire.
function Observer.think(bot)
    local now = DotaTime()
    if now < next_report_time then
        return nil
    end

    bot = bot or GetBot()
    local state = DotaAdapter.observe(bot)
    local decision = Decision.should_join_fight(state)
    print(Debug.format_decision(state.time, bot:GetUnitName(), decision))

    next_report_time = now + REPORT_INTERVAL
    return decision
end

return Observer
