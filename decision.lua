local Utility = require("utility")

local Decision = {}

Decision.ACTION_FIGHT = "FIGHT"
Decision.ACTION_HOLD = "HOLD"

local function score_fight(state)
    local reasons = {}

    if not state.self.alive then
        Utility.add_reason(reasons, "-", "hero is dead")
        return 0, reasons
    end

    local score = 0.35
    local allies_bonus = math.min(state.allies.nearby, 4) * 0.08
    local enemies_penalty = math.min(state.enemies.nearby, 5) * 0.06
    score = score + allies_bonus - enemies_penalty

    if state.allies.nearby > 0 then
        Utility.add_reason(reasons, "+", tostring(state.allies.nearby) .. " allies nearby")
    end
    if state.enemies.nearby > 0 then
        Utility.add_reason(reasons, "-", tostring(state.enemies.nearby) .. " enemies nearby")
    else
        Utility.add_reason(reasons, "-", "no visible nearby fight")
    end

    if state.self.ultimate_ready then
        score = score + 0.15
        Utility.add_reason(reasons, "+", "ultimate ready")
    end

    if state.self.hp < 0.35 then
        score = score - 0.40
        Utility.add_reason(reasons, "-", "critical health")
    elseif state.self.hp >= 0.70 then
        score = score + 0.12
        Utility.add_reason(reasons, "+", "healthy")
    end

    if state.self.mana >= 0.50 then
        score = score + 0.04
        Utility.add_reason(reasons, "+", "sufficient mana")
    elseif state.self.mana < 0.20 then
        score = score - 0.10
        Utility.add_reason(reasons, "-", "low mana")
    end

    if state.enemies.lowest_hp <= 0.35 and state.enemies.visible > 0 then
        score = score + 0.10
        Utility.add_reason(reasons, "+", "visible enemy is low health")
    end

    if state.enemies.missing > 0 then
        local missing_penalty = math.min(state.enemies.missing, 5) * 0.035
        score = score - missing_penalty
        Utility.add_reason(reasons, "-", tostring(state.enemies.missing) .. " enemies missing")
    end

    if state.self.tp_ready then
        score = score + 0.03
        Utility.add_reason(reasons, "+", "teleport available")
    end

    return Utility.clamp(score, 0, 1), reasons
end

-- Returns an inspectable strategic recommendation; it never issues an order.
function Decision.should_join_fight(state)
    local score, reasons = score_fight(state)
    local action = Decision.ACTION_HOLD
    if score >= 0.60 then
        action = Decision.ACTION_FIGHT
    end

    return {
        action = action,
        score = Utility.round(score, 2),
        confidence = Utility.round(score, 2),
        scores = { fight = Utility.round(score, 2) },
        reasons = reasons,
    }
end

return Decision
