local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local U = require(GetScriptDirectory()..'/FunLib/MinionLib/utils')

local X = {}
local DECISION_COOLDOWN = 1.0  -- seconds
local lastDecisionTime = {}    -- table to track last decision time per unit
local lastTarget = {}          -- table to track last attack target per unit

function X.Think(bot, hMinionUnit)
	if not U.IsValidUnit(hMinionUnit) then return end
	if hMinionUnit == nil then return end

	-- Get unique ID for this unit
	local unitId = tostring(hMinionUnit)
	
	-- Check if enough time has passed since last decision
	local gameTime = GameTime()
	if lastDecisionTime[unitId] and (gameTime - lastDecisionTime[unitId]) < DECISION_COOLDOWN then
		-- Continue attacking last target if it's still valid
		if lastTarget[unitId] and not U.IsNotAllowedToAttack(lastTarget[unitId]) then
			hMinionUnit:Action_AttackUnit(lastTarget[unitId], true)
			return
		end
	end

	local thisMinionAttackRange = bot:GetAttackRange()

	local target = U.GetWeakestHero(thisMinionAttackRange, hMinionUnit)
	if target == nil
	then
		target = U.GetWeakestCreep(thisMinionAttackRange, hMinionUnit)
		if target == nil
		then
			target = U.GetWeakestTower(thisMinionAttackRange, hMinionUnit)
		end
	end

	if target ~= nil and not U.IsNotAllowedToAttack(target)
	then
		lastDecisionTime[unitId] = gameTime
		lastTarget[unitId] = target
		hMinionUnit:Action_AttackUnit(target, true)
		return
	end
end

return X