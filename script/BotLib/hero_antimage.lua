local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

if GetBot():GetUnitName() == 'npc_dota_hero_antimage'
then

local RI = require(GetScriptDirectory()..'/FunLib/util_role_item')

local HeroBuild = {
    ['pos_1'] = {
        [1] = {
            ['talent'] = {
                [1] = {
					['t25'] = {10, 0},
					['t20'] = {10, 0},
					['t15'] = {0, 10},
					['t10'] = {0, 10},
				},
            },
            ['ability'] = {
				[1] = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
            },
            ['buy_list'] = {
				"item_tango",
				"item_double_branches",
				"item_quelling_blade",

            	"item_magic_wand",
            	"item_power_treads",
				"item_orchid",
				"item_bloodthorn",--
				"item_satanic",--
            	"item_butterfly",--
				"item_greater_crit",--
				"item_disperser",--
            	"item_moon_shard",
            	"item_ultimate_scepter",
            	"item_ultimate_scepter_2",
            	"item_aghanims_shard",
				"item_black_king_bar",--
			},
            ['sell_list'] = {
				"item_quelling_blade", "item_butterfly",
            	"item_magic_wand", "item_greater_crit",
            	"item_power_treads", "item_disperser",
			},
        },
    },
}

local sSelectedBuild = HeroBuild[sRole][RandomInt(1, #HeroBuild[sRole])]

local nTalentBuildList = J.Skill.GetTalentBuild(J.Skill.GetRandomBuild(sSelectedBuild.talent))
local nAbilityBuildList = J.Skill.GetRandomBuild(sSelectedBuild.ability)

X['sBuyList'] = sSelectedBuild.buy_list
X['sSellList'] = sSelectedBuild.sell_list


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		if hMinionUnit:IsIllusion()
		then
			-- More complex illusion behavior
			local nEnemyHeroes = hMinionUnit:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
			local nEnemyCreeps = hMinionUnit:GetNearbyLaneCreeps(600, true)
			local nEnemyTowers = hMinionUnit:GetNearbyTowers(700, true)
			
			-- Split push with illusions when safe
			if nEnemyHeroes == nil or #nEnemyHeroes == 0 then
				if nEnemyCreeps ~= nil and #nEnemyCreeps > 0 then
					hMinionUnit:Action_AttackUnit(nEnemyCreeps[1], false)
					return
				end
				
				-- Find a lane to push
				local laneCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS)
				local closestCreep = nil
				local closestDistance = 99999
				
				for _, creep in pairs(laneCreeps) do
					if creep:GetHealth() > 0 then
						local distance = GetUnitToUnitDistance(hMinionUnit, creep)
						if distance < closestDistance then
							closestDistance = distance
							closestCreep = creep
						end
					end
				end
				
				if closestCreep ~= nil then
					hMinionUnit:Action_MoveToLocation(closestCreep:GetLocation())
					return
				end
			end
			
			-- Default illusion behavior
			Minion.IllusionThink(hMinionUnit)
		end
	end

end

end

-- local ManaBreak 		= bot:GetAbilityByName('antimage_mana_break')
local Blink 			= bot:GetAbilityByName('antimage_blink')
local CounterSpell 		= bot:GetAbilityByName('antimage_counterspell')
local CounterSpellAlly 	= bot:GetAbilityByName('antimage_counterspell_ally')
-- local BlinkFragment		= bot:GetAbilityByName('antimage_mana_overload')
local ManaVoid 			= bot:GetAbilityByName('antimage_mana_void')

local BlinkDesire, BlinkLocation
local CounterSpellDesire
local CounterSpellAllyDesire, CounterSpellAllyTarget
-- local BlinkFragmentDesire, BlinkFragmentLocation
local ManaVoidDesire, ManaVoidTarget

local BlinkVoidDesire, BlinkVoidTarget

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

	ManaBreak           = bot:GetAbilityByName('antimage_mana_break')
	Blink 				= bot:GetAbilityByName('antimage_blink')
	CounterSpell 		= bot:GetAbilityByName('antimage_counterspell')
	CounterSpellAlly 	= bot:GetAbilityByName('antimage_counterspell_ally')
	ManaVoid 			= bot:GetAbilityByName('antimage_mana_void')

	botTarget = J.GetProperTarget(bot)

	-- Prioritize kill combos
	BlinkVoidDesire, BlinkVoidTarget = X.ConsiderBlinkVoid()
	if BlinkVoidDesire > 0
	then
		bot:Action_ClearActions(false)
		bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkVoidTarget:GetLocation())
		bot:ActionQueue_Delay(0.1)
		bot:ActionQueue_UseAbilityOnEntity(ManaVoid, BlinkVoidTarget)
		return
	end

	BlinkDesire, BlinkLocation = X.ConsiderBlink()
	if BlinkDesire > 0
	then
		J.SetQueuePtToINT(bot, true)
		bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
		return
	end

	ManaVoidDesire, ManaVoidTarget = X.ConsiderManaVoid()
	if ManaVoidDesire > 0
	then
		J.SetQueuePtToINT(bot, true)
		bot:ActionQueue_UseAbilityOnEntity(ManaVoid, ManaVoidTarget)
		return
	end

	CounterSpellDesire = X.ConsiderCounterSpell()
	if CounterSpellDesire > 0
	then
		J.SetQueuePtToINT(bot, true)
		bot:ActionQueue_UseAbility(CounterSpell)
		return
	end

	CounterSpellAllyDesire, CounterSpellAllyTarget = X.ConsiderCounterSpellAlly()
	if CounterSpellAllyDesire > 0
	then
		J.SetQueuePtToINT(bot, true)
		bot:ActionQueue_UseAbilityOnEntity(CounterSpellAlly, CounterSpellAllyTarget)
		return
	end

end

function X.ConsiderBlink()
	if not J.CanCastAbility(Blink)
	or bot:IsRooted()
	or bot:HasModifier('modifier_bloodseeker_rupture')
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = Blink:GetSpecialValueInt('AbilityCastRange') - 1
	local nCastPoint = Blink:GetCastPoint()
	local nAttackPoint = bot:GetAttackPoint()

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
	end

	if (J.IsStunProjectileIncoming(bot, 600) or J.IsUnitTargetProjectileIncoming(bot, 400))
	and CounterSpell ~= nil and not CounterSpell:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
    end

	if  not bot:HasModifier('modifier_sniper_assassinate')
	and not bot:IsMagicImmune()
	and CounterSpell ~= nil and not CounterSpell:IsFullyCastable()
	then
		if J.IsWillBeCastUnitTargetSpell(bot, 400)
		then
			return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
		and J.CanCastOnMagicImmune(botTarget)
		and not J.IsInRange(bot, botTarget, 400)
		and not botTarget:IsAttackImmune()
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nInRangeAlly = botTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
			local nInRangeEnemy = botTarget:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

			if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			then
				local targetLoc = botTarget:GetExtrapolatedLocation(nCastPoint + 0.53)

				if GetUnitToUnitDistance(bot, botTarget) > nCastRange
				then
					targetLoc = J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
				end

				if J.IsInLaningPhase()
				then
					local nEnemysTowers = botTarget:GetNearbyTowers(700, false)
					if nEnemysTowers ~= nil and #nEnemysTowers == 0
					or (bot:GetHealth() > J.GetTotalEstimatedDamageToTarget(nInRangeEnemy, bot, 6.0)
						and J.WillKillTarget(botTarget, bot:GetAttackDamage() * 3, DAMAGE_TYPE_PHYSICAL, 2))
					then
						bot:SetTarget(botTarget)
						return BOT_ACTION_DESIRE_HIGH, targetLoc
					end
				else
					bot:SetTarget(botTarget)
					return BOT_ACTION_DESIRE_HIGH, targetLoc
				end
			end
		end
	end

	if J.IsRetreating(bot)
	and not J.IsRealInvisible(bot)
	and bot:GetActiveModeDesire() > 0.65
	then
		for _, enemyHero in pairs(nEnemyHeroes)
        do
			if  J.IsValidHero(enemyHero)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and (bot:WasRecentlyDamagedByHero(enemyHero, 1.5) or (J.GetHP(bot) < 0.5 and J.IsChasingTarget(enemyHero, bot)))
			then
				return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
			end
        end
	end

	if J.IsLaning(bot)
	then
		local nInRangeTower = bot:GetNearbyTowers(1600, true)
		if  J.GetManaAfter(Blink:GetManaCost()) > 0.85
		and J.IsInLaningPhase()
		and bot:DistanceFromFountain() > 300
		and bot:DistanceFromFountain() < 6000
		and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
		and nInRangeTower ~= nil and #nInRangeTower == 0
		then
			local nLane = bot:GetAssignedLane()
			local nLaneFrontLocation = GetLaneFrontLocation(GetTeam(), nLane, 0)
			local nDistFromLane = GetUnitToLocationDistance(bot, nLaneFrontLocation)

			if nDistFromLane > nCastRange
			then
				local nLocation = J.Site.GetXUnitsTowardsLocation(bot, nLaneFrontLocation, nCastRange)
				if IsLocationPassable(nLocation)
				then
					return BOT_ACTION_DESIRE_HIGH, nLocation
				end
			end
		end
	end

	if  J.IsPushing(bot)
	and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH
	then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 600)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
		local nEnemyTowers = bot:GetNearbyTowers(1600, true)

		if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        and nInRangeAlly ~= nil and #nInRangeAlly <= 1
		and GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nEnemyLaneCreeps)) > bot:GetAttackRange()
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
		and nEnemyTowers ~= nil
		and (#nEnemyTowers == 0 or (J.IsValidBuilding(nEnemyTowers[1]) and J.IsValid(nEnemyLaneCreeps[#nEnemyLaneCreeps]) and GetUnitToUnitDistance(nEnemyTowers[1], nEnemyLaneCreeps[#nEnemyLaneCreeps]) > 700))
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
		end

        nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		if bot.laneToPush ~= nil
		then
			if  J.GetManaAfter(Blink:GetManaCost()) > 0.5
			and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and nEnemyTowers ~= nil and #nEnemyTowers == 0
			and GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToPush, 0)) > nCastRange
			and bot:IsFacingLocation(GetLaneFrontLocation(GetTeam(), bot.laneToPush, 0), 30)
			then
				return  BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, GetLaneFrontLocation(GetTeam(), bot.laneToPush, 0), nCastRange)
			end
		end
	end

	if  J.IsDefending(bot)
	and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		if bot.laneToDefend ~= nil
		then
			if  J.GetManaAfter(Blink:GetManaCost()) > 0.5
			and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToDefend, 0)) > nCastRange
			and bot:IsFacingLocation(GetLaneFrontLocation(GetTeam(), bot.laneToDefend, 0), 30)
			then
				return  BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, GetLaneFrontLocation(GetTeam(), bot.laneToDefend, 0), nCastRange)
			end
		end
	end

	if J.IsDoingRoshan(bot)
    then
		local RoshanLocation = J.GetCurrentRoshanLocation()
        if GetUnitToLocationDistance(bot, RoshanLocation) > nCastRange
        then
			local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, RoshanLocation, nCastRange)
			local nInRangeEnemy = J.GetEnemiesNearLoc(RoshanLocation, 1600)

			if  nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and IsLocationPassable(targetLoc)
			then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end
        end
    end

    if J.IsDoingTormentor(bot)
    then
		local TormentorLocation = J.GetTormentorLocation(GetTeam())
        if GetUnitToLocationDistance(bot, TormentorLocation) > nCastRange
        then
			local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, TormentorLocation, nCastRange)
			local nInRangeEnemy = J.GetEnemiesNearLoc(targetLoc, 1600)

			if  nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and IsLocationPassable(targetLoc)
			then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end

        end
    end

	-- Add better farming logic
	if J.IsFarming(bot)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
		if nNeutralCreeps ~= nil and #nNeutralCreeps >= 3
		and GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nNeutralCreeps)) > bot:GetAttackRange() + 200
		and J.GetManaAfter(Blink:GetManaCost()) > 0.4
		then
			local targetLoc = J.GetCenterOfUnits(nNeutralCreeps)
			if GetUnitToLocationDistance(bot, targetLoc) < nCastRange
			and J.IsLocationPassable(targetLoc)
			then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end
		end

		-- Move between camps more efficiently
		local nAncientCreeps = bot:GetNearbyNeutralCreeps(1600)
		if nAncientCreeps ~= nil and #nAncientCreeps == 0
		and bot:GetLevel() >= 12
		and J.IsAncientCamp(bot:GetLocation()) == false
		and J.GetManaAfter(Blink:GetManaCost()) > 0.5
		then
			local ancientCamp = J.GetNearestAncientCampLocation(bot:GetLocation())
			if GetUnitToLocationDistance(bot, ancientCamp) < nCastRange * 1.5
			and GetUnitToLocationDistance(bot, ancientCamp) > 600
			then
				local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, ancientCamp, nCastRange)
				if J.IsLocationPassable(targetLoc)
				then
					return BOT_ACTION_DESIRE_HIGH, targetLoc
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCounterSpell()
	local nSkillLV    = CounterSpell:GetLevel()
	if not J.CanCastAbility(CounterSpell)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if nSkillLV < 4
	then
		if J.IsUnitTargetProjectileIncoming(bot, 400)
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		if  not bot:HasModifier('modifier_sniper_assassinate')
				and not bot:IsMagicImmune()
		then
			if J.IsWillBeCastUnitTargetSpell(bot, 1400)
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	elseif nSkillLV == 4
		then
		return BOT_ACTION_DESIRE_HIGH
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCounterSpellAlly()
	if not J.CanCastAbility(CounterSpellAlly)
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, CounterSpellAlly:GetCastRange())
	local nInRangeAlly = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

	for _, allyHero in pairs(nInRangeAlly)
	do
		if  J.IsValidHero(allyHero)
		and J.IsInRange(bot, allyHero, nCastRange)
		and not J.IsSuspiciousIllusion(allyHero)
		and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			if  J.IsUnitTargetProjectileIncoming(allyHero, 400)
			and not allyHero:IsMagicImmune()
			then
				return BOT_ACTION_DESIRE_HIGH, allyHero
			end

			if  not allyHero:HasModifier('modifier_sniper_assassinate')
			and not allyHero:IsMagicImmune()
			then
				if J.IsWillBeCastUnitTargetSpell(allyHero, nCastRange)
				then
					return BOT_ACTION_DESIRE_HIGH, allyHero
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderManaVoid()
	if not J.CanCastAbility(ManaVoid)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = ManaVoid:GetCastRange()
	local nRadius = ManaVoid:GetSpecialValueInt('mana_void_aoe_radius')
	local nDamagaPerHealth = ManaVoid:GetSpecialValueFloat('mana_void_damage_per_mana')

	if J.IsInTeamFight(bot, 1200)
	then
		local nCastTarget = nil
		local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange + 300, true, BOT_MODE_NONE)
		local bestScore = 0
		
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidHero(enemyHero)
			and J.CanCastOnTargetAdvanced(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and not J.IsHaveAegis(enemyHero)
			and not enemyHero:HasModifier('modifier_arc_warden_tempest_double')
			and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				local nDamage = nDamagaPerHealth * (enemyHero:GetMaxMana() - enemyHero:GetMana())
				local nearbyEnemies = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)
				local currentScore = 0
				
				-- Calculate total potential damage across all enemies
				for _, nearbyEnemy in pairs(nearbyEnemies) do
					if J.IsValidHero(nearbyEnemy) 
					and J.CanCastOnNonMagicImmune(nearbyEnemy) 
					then
						currentScore = currentScore + nDamage
						
						-- Bonus points for killing someone
						if J.CanKillTarget(nearbyEnemy, nDamage, DAMAGE_TYPE_MAGICAL) then
							currentScore = currentScore + 500
						end
					end
				end
				
				if currentScore > bestScore then
					bestScore = currentScore
					nCastTarget = enemyHero
				end
			end
		end

		if nCastTarget ~= nil
		then
			bot:SetTarget(nCastTarget)
			return BOT_ACTION_DESIRE_HIGH, nCastTarget
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidHero(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.CanCastOnTargetAdvanced(botTarget)
		and not J.IsHaveAegis(botTarget)
		and not botTarget:HasModifier('modifier_arc_warden_tempest_double')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nDamage = nDamagaPerHealth * (botTarget:GetMaxMana() - botTarget:GetMana())
			if J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_MAGICAL)
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBlinkVoid()
	if not J.CanCastAbility(Blink) or not J.CanCastAbility(ManaVoid)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if Blink:GetManaCost() + ManaVoid:GetManaCost() > bot:GetMana()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = Blink:GetSpecialValueInt('AbilityCastRange')
	local nDamagaPerHealth = ManaVoid:GetSpecialValueFloat('mana_void_damage_per_mana')

	local nMaxRange = ManaVoid:GetCastRange() + nCastRange

	local nEnemysHerosCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	for _, enemyHero in pairs(nEnemysHerosCanSeen)
	do
		if  J.IsValidHero(enemyHero)
		and J.IsInRange(bot, enemyHero, nMaxRange)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.CanCastOnTargetAdvanced(enemyHero)
		and not enemyHero:HasModifier('modifier_arc_warden_tempest_double')
		and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
		then
			local nDamage = nDamagaPerHealth * (enemyHero:GetMaxMana() - enemyHero:GetMana())
            if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X