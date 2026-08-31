local WorldState = require("world_state")

local DotaAdapter = {}

local NEARBY_RADIUS = 1200

local function fraction(current, maximum)
    if maximum == nil or maximum <= 0 then
        return 0
    end
    return current / maximum
end

local function count_alive_players(team)
    local alive = 0
    for _, player_id in ipairs(GetTeamPlayers(team)) do
        if IsHeroAlive(player_id) then
            alive = alive + 1
        end
    end
    return alive
end

local function lowest_health_fraction(units)
    local lowest = 1
    for _, unit in ipairs(units) do
        local health = fraction(unit:GetHealth(), unit:GetMaxHealth())
        if health < lowest then
            lowest = health
        end
    end
    return lowest
end

local function ultimate_is_ready(bot)
    for slot = 0, 5 do
        local ability = bot:GetAbilityInSlot(slot)
        if ability ~= nil and ability:IsUltimate() then
            return ability:IsFullyCastable()
        end
    end
    return false
end

local function teleport_is_ready(bot)
    local teleport = bot:GetItemInSlot(15)
    return teleport ~= nil and teleport:GetName() == "item_tpscroll" and teleport:IsFullyCastable()
end

-- Creates a data-only snapshot. The caller keeps ownership of tactical execution.
function DotaAdapter.observe(bot)
    bot = bot or GetBot()

    local allies = bot:GetNearbyHeroes(NEARBY_RADIUS, false, BOT_MODE_NONE)
    local enemies = bot:GetNearbyHeroes(NEARBY_RADIUS, true, BOT_MODE_NONE)
    local enemy_team = GetOpposingTeam()

    return WorldState.from_snapshot({
        time = DotaTime(),
        self = {
            hp = fraction(bot:GetHealth(), bot:GetMaxHealth()),
            mana = fraction(bot:GetMana(), bot:GetMaxMana()),
            alive = bot:IsAlive(),
            ultimate_ready = ultimate_is_ready(bot),
            tp_ready = teleport_is_ready(bot),
        },
        allies = {
            nearby = #allies,
            alive = count_alive_players(GetTeam()),
        },
        enemies = {
            nearby = #enemies,
            visible = #enemies,
            missing = math.max(0, count_alive_players(enemy_team) - #enemies),
            lowest_hp = lowest_health_fraction(enemies),
        },
        objectives = {
            nearby_enemy_tower = #bot:GetNearbyTowers(NEARBY_RADIUS, true) > 0,
        },
    })
end

return DotaAdapter
