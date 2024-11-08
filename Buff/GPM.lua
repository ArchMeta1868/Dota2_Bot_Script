dofile('bots/Buff/Helper')

if GPM == nil
then
    GPM = {}
end

-- Reasonable GPM (XPM later)
function GPM.TargetGPM(time)
    if time <= 10 * 60 then
        return 400
    elseif time <= 20 * 60 then
        return 500
    elseif time <= 30 * 60 then
        return 600
    else
        return 800
    end
end

function GPM.UpdateBotGold(bot, nTeam)
    local isCore = Helper.IsCore(bot, nTeam)
    local gameTime = Helper.DotaTime() / 60
    local targetGPM = GPM.TargetGPM(gameTime)

    local currentGPM = PlayerResource:GetGoldPerMin(bot:GetPlayerID())
    local creepLastHits = bot:GetLastHits() -- Get the number of last hits by the bot

    local missing = targetGPM - currentGPM
    local goldPerTick = math.max(1, missing / (isCore and 20 or 30))

    -- Give additional gold for each last hit, one-time boost
    if bot.lastHitCount == nil then
        bot.lastHitCount = 0
    end

    if creepLastHits > bot.lastHitCount then
        local newLastHits = creepLastHits - bot.lastHitCount
        bot:ModifyGold(newLastHits * 30, true, 0) -- Give 20 gold per last hit
        bot.lastHitCount = creepLastHits
    end

    local nAdd = 1

    if bot:IsAlive() and gameTime > 6 then
        bot:ModifyGold(nAdd + math.ceil(goldPerTick), true, 0)
    end
end

return GPM