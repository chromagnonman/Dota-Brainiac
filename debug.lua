local Debug = {}

function Debug.format_decision(time_seconds, hero_name, decision)
    local minutes = math.floor(time_seconds / 60)
    local seconds = math.floor(time_seconds % 60)
    local lines = {
        string.format("[%02d:%02d] %s", minutes, seconds, hero_name or "UNKNOWN"),
        "Decision: " .. decision.action,
        string.format("FIGHT      %.2f", decision.scores.fight),
        string.format("Confidence: %d%%", math.floor(decision.confidence * 100 + 0.5)),
        "Factors:",
    }

    for _, reason in ipairs(decision.reasons) do
        table.insert(lines, "  " .. reason.sign .. " " .. reason.message)
    end

    return table.concat(lines, "\n")
end

return Debug
