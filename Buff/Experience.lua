dofile('bots/Buff/Helper')

if XP == nil
then
    XP = {}
end

local XPNeeded = {
    [1]  = 240,
    [2]  = 400,
    [3]  = 520,
    [4]  = 600,
    [5]  = 680,
    [6]  = 760,
    [7]  = 800,
    [8]  = 900,
    [9]  = 1000,
    [10] = 1100,
    [11] = 1200,
    [12] = 1300,
    [13] = 1400,
    [14] = 1500,
    [15] = 1600,
    [16] = 1700,
    [17] = 1800,
    [18] = 1900,
    [19] = 2000,
    [20] = 2200,
    [21] = 2400,
    [22] = 2600,
    [23] = 2800,
    [24] = 3000,
    [25] = 4000,
    [26] = 5000,
    [27] = 6000,
    [28] = 7000,
    [29] = 7500,
    [30] = 0,
}

function XP.UpdateXP(bot, nTeam)
    local gameTime = Helper.DotaTime() / 60  -- Convert game time to minutes

    -- Only start adding experience after 6 minutes of game time
    if gameTime < 6 then
        return
    end

    local botLevel = bot:GetLevel()
    local needXP = XPNeeded[botLevel]

    -- Early return if bot is already at max level
    if needXP == 0 then
        return
    end

    local mul2XP = needXP / 2
    local baseXPPerMinute = (mul2XP / 60) / 2

    -- Limit the time multiplier to 0.5 at minimum for controlled late-game gain
    local timeMul = math.max(0.5, 1 - (gameTime / 60))
    local xp = baseXPPerMinute * timeMul

    if bot:IsAlive() and gameTime > 0 then
        bot:AddExperience(math.floor(xp), 0, false, true)
    end
end

return XP