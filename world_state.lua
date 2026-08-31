local Utility = require("utility")

local WorldState = {}

local function number_or(value, fallback)
    if type(value) == "number" then
        return value
    end
    return fallback
end

local function boolean_or(value, fallback)
    if type(value) == "boolean" then
        return value
    end
    return fallback
end

local function normalized_fraction(value, fallback)
    return Utility.clamp(number_or(value, fallback), 0, 1)
end

local function non_negative_count(value, fallback)
    return math.max(0, math.floor(number_or(value, fallback)))
end

-- Converts a plain adapter snapshot into the stable contract used by the brain.
-- No Dota API handles are allowed beyond this boundary.
function WorldState.from_snapshot(snapshot)
    snapshot = snapshot or {}
    local self_state = snapshot.self or {}
    local allies = snapshot.allies or {}
    local enemies = snapshot.enemies or {}
    local objectives = snapshot.objectives or {}

    return {
        time = math.max(0, number_or(snapshot.time, 0)),
        self = {
            hp = normalized_fraction(self_state.hp, 1),
            mana = normalized_fraction(self_state.mana, 1),
            alive = boolean_or(self_state.alive, true),
            ultimate_ready = boolean_or(self_state.ultimate_ready, false),
            tp_ready = boolean_or(self_state.tp_ready, false),
        },
        allies = {
            nearby = non_negative_count(allies.nearby, 0),
            alive = non_negative_count(allies.alive, 0),
        },
        enemies = {
            nearby = non_negative_count(enemies.nearby, 0),
            visible = non_negative_count(enemies.visible, 0),
            missing = non_negative_count(enemies.missing, 0),
            lowest_hp = normalized_fraction(enemies.lowest_hp, 1),
        },
        objectives = {
            roshan_alive = boolean_or(objectives.roshan_alive, true),
            nearby_enemy_tower = boolean_or(objectives.nearby_enemy_tower, false),
        },
    }
end

return WorldState
