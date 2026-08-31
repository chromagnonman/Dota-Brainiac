local Utility = {}

function Utility.clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end
    if value > maximum then
        return maximum
    end
    return value
end

function Utility.round(value, places)
    local multiplier = 10 ^ (places or 2)
    return math.floor(value * multiplier + 0.5) / multiplier
end

function Utility.add_reason(reasons, sign, message)
    table.insert(reasons, { sign = sign, message = message })
end

return Utility
