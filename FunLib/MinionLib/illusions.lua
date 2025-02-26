local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local U = require(GetScriptDirectory()..'/FunLib/MinionLib/utils')

local X = {}
local bot

local nLanes = {
    LANE_TOP,
    LANE_MID,
    LANE_BOT,
}

local DECISION_COOLDOWN = 1.0  -- seconds
local lastDecisionTime = {}    -- table to track last decision time per unit

function X.Think(ownerBot, hMinionUnit)
    if not U.IsValidUnit(hMinionUnit) then return end
    if hMinionUnit == nil then return end

    bot = ownerBot

    -- Get unique ID for this unit (using handle as string)
    local unitId = tostring(hMinionUnit)
    
    -- Check if enough time has passed since last decision
    local gameTime = GameTime()
    if lastDecisionTime[unitId] and (gameTime - lastDecisionTime[unitId]) < DECISION_COOLDOWN then
        return  -- keep executing previous action
    end

	hMinionUnit.attack_desire, hMinionUnit.attack_target = X.ConsiderAttack(hMinionUnit)
    if hMinionUnit.attack_desire > 0
    then
        if U.IsValidUnit(hMinionUnit.attack_target)
        then
            if not J.CanBeAttacked(hMinionUnit.attack_target)
            and (not bot:IsAlive()
                or (bot:IsAlive() and bot:GetAttackTarget() ~= hMinionUnit.attack_target))
            then
                local loc = J.Site.GetXUnitsTowardsLocation(GetAncient(GetTeam()), hMinionUnit.attack_target:GetLocation(), 600)
                hMinionUnit:Action_MoveToLocation(loc)
                return
            else
                hMinionUnit:Action_AttackUnit(hMinionUnit.attack_target, true)
                return
            end
        end
    end

    hMinionUnit.move_desire  , hMinionUnit.move_location = X.ConsiderMove(hMinionUnit)
	if hMinionUnit.move_desire > 0
	then
		hMinionUnit:Action_MoveToLocation(hMinionUnit.move_location)
		return
	end

    -- Default
    if bot:IsAlive()
    then
        hMinionUnit:Action_MoveToLocation(bot:GetLocation())
    else
        hMinionUnit:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), LANE_MID, 0))
    end

    -- Record decision time when we make a new action
    if hMinionUnit.attack_desire > 0 or hMinionUnit.move_desire > 0 then
        lastDecisionTime[unitId] = gameTime
    end
end

function X.ConsiderAttack(hMinionUnit)
    if U.CantAttack(hMinionUnit) then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local target = X.GetAttackTarget(hMinionUnit)

    if target ~= nil then
        return BOT_ACTION_DESIRE_HIGH, target
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.GetAttackTarget(hMinionUnit)
    local target = nil
    local hMinionUnitName = hMinionUnit:GetUnitName()

    -- Priority 1: Nightmared allies
    if bot:HasModifier('modifier_bane_nightmare') and not bot:IsInvulnerable()
    and GetUnitToUnitDistance(bot, hMinionUnit) < 2000
    then
        target = bot
    end

    -- Priority 2: Special units
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
        if J.IsValid(enemy) then
            local enemyName = enemy:GetUnitName()
            local specialUnits = J.GetSpecialUnits()

            if specialUnits[enemyName]
            and enemy:GetTeam() ~= hMinionUnit:GetTeam()
            and GetUnitToUnitDistance(hMinionUnit, enemy) <= specialUnits[enemyName] * 1600
            and RandomInt(0, 100) <= specialUnits[enemyName] * 100
            then
                return enemy
            end
        end
    end

    -- Priority 3: Whatever bot is attacking if nearby
    if GetUnitToUnitDistance(bot, hMinionUnit) < 1600 then
        target = bot:GetAttackTarget()
    end

    -- Priority 4: Find any target in range
    if target == nil then
        target = U.GetWeakestHero(1600, hMinionUnit)
        if target == nil then target = U.GetWeakestCreep(1600, hMinionUnit) end
        if target == nil then target = U.GetWeakestTower(1600, hMinionUnit) end
    end

    return target
end

function X.ConsiderMove(hMinionUnit)
	if J.CanNotUseAction(hMinionUnit) or U.CantMove(hMinionUnit) then return BOT_MODE_DESIRE_NONE, nil end

    -- Have Naga or TB farm lanes
    local hMinionUnitName = hMinionUnit:GetUnitName()
    if string.find(hMinionUnitName, 'terrorblade')
    or string.find(hMinionUnitName, 'naga_siren')
    then
        for i = 1, #nLanes
        do
            local laneFrontLoc = J.GetClosestTeamLane(hMinionUnit)
            if not X.IsMinionInLane(hMinionUnit, nLanes[i])
            then
                laneFrontLoc = GetLaneFrontLocation(GetTeam(), nLanes[i], 0)
            end

            if not J.IsInLaningPhase()
            -- and GetUnitToLocationDistance(hMinionUnit, laneFrontLoc) <= 2500
            then
                hMinionUnit.to_farm_lane = nLanes[i]
                return BOT_ACTION_DESIRE_HIGH, laneFrontLoc
            end
        end
    end

    if GetUnitToUnitDistance(bot, hMinionUnit) > 1600
    or not bot:IsAlive()
    or bot:HasModifier('modifier_teleporting')
    then
        local nTeamFightLocation = J.GetTeamFightLocation(hMinionUnit)
        if nTeamFightLocation and GetUnitToLocationDistance(hMinionUnit, nTeamFightLocation) < 2200
        then
            return BOT_ACTION_DESIRE_HIGH, nTeamFightLocation
        end

        return BOT_ACTION_DESIRE_HIGH, J.GetClosestTeamLane(hMinionUnit)
    else
        return BOT_ACTION_DESIRE_HIGH, bot:GetLocation() + RandomVector(150)
    end
end

function X.IsTargetUnderEnemyTower(hMinionUnit, unit)
    local nEnemyTowers = hMinionUnit:GetNearbyTowers(1600, true)
    if J.IsValidBuilding(nEnemyTowers[1])
    and U.IsValidUnit(unit)
    and J.IsInRange(unit, nEnemyTowers[1], 880)
    then
        return true
    end

    return false
end

function X.IsMinionInLane(hMinionUnit, lane)
    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIES))
    do
        if J.IsValid(ally)
        and hMinionUnit ~= ally
        and ally:IsIllusion()
        and string.find(bot:GetUnitName(), ally:GetUnitName())
        then
            if ally.to_farm_lane == lane
            or GetUnitToLocationDistance(ally, GetLaneFrontLocation(GetTeam(), lane, 0)) < 1600
            then
                return true
            end
        end
    end

    return false
end

function X.GetNearestEnemyTower(unit)
    local towers = unit:GetNearbyTowers(1000, true)
    if #towers > 0 then
        return towers[1]
    end
    return nil
end

return X