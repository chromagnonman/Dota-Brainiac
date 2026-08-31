-- Install this file in bots/. Install the remaining Dota-Brainiac modules in bots/DotaBrain/.
local root = GetScriptDirectory() .. "/DotaBrain/"
package.path = root .. "?.lua;" .. package.path

local Observer = require("observer")

-- Returning nil preserves the host bot's normal attack-mode desire.
function GetDesire()
    if GetGameState() == GAME_STATE_GAME_IN_PROGRESS then
        Observer.think(GetBot())
    end

    return nil
end
