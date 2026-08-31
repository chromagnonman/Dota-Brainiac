package.path = "./?.lua;" .. package.path

local WorldState = require("world_state")
local Decision = require("decision")
local Debug = require("debug")

local function assert_equal(actual, expected, message)
    if actual ~= expected then
        error((message or "assertion failed") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
    end
end

local favorable = WorldState.from_snapshot({
    time = 840,
    self = { hp = 0.87, mana = 0.61, alive = true, ultimate_ready = true, tp_ready = true },
    allies = { nearby = 3, alive = 5 },
    enemies = { nearby = 2, visible = 2, missing = 3, lowest_hp = 0.28 },
})
local favorable_decision = Decision.should_join_fight(favorable)
assert_equal(favorable_decision.action, Decision.ACTION_FIGHT, "healthy coordinated fight")

local unsafe = WorldState.from_snapshot({
    self = { hp = 0.18, mana = 0.30, alive = true, ultimate_ready = true, tp_ready = false },
    allies = { nearby = 1, alive = 2 },
    enemies = { nearby = 4, visible = 4, missing = 1, lowest_hp = 0.90 },
})
local unsafe_decision = Decision.should_join_fight(unsafe)
assert_equal(unsafe_decision.action, Decision.ACTION_HOLD, "outnumbered critical-health fight")
assert_equal(unsafe_decision.score < favorable_decision.score, true, "unsafe score should be lower")

local dead = WorldState.from_snapshot({ self = { alive = false } })
assert_equal(Decision.should_join_fight(dead).action, Decision.ACTION_HOLD, "dead hero cannot join")

print(Debug.format_decision(favorable.time, "JUGGERNAUT", favorable_decision))
print("\nAll Dota Brain checks passed.")
