local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

if GetBot():GetUnitName() == 'npc_dota_hero_queenofpain'
then

local RI = require(GetScriptDirectory()..'/FunLib/util_role_item')

local sUtility = {}
local sUtilityItem = RI.GetBestUtilityItem(sUtility)

local HeroBuild = {
	['pos_2'] = {
        [1] = {
            ['talent'] = {
				[1] = {
					['t25'] = {0, 10},
					['t20'] = {10, 0},
					['t15'] = {10, 0},
					['t10'] = {10, 0},
				}
            },
            ['ability'] = {
                [1] = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
            },
            ['buy_list'] = {
				"item_tango",
				"item_double_branches",

				"item_bottle",
				"item_magic_wand",
            	"item_power_treads",
            	"item_witch_blade",
            	"item_ultimate_scepter",
				"item_aghanims_shard",
            	"item_black_king_bar",--
            	"item_devastator",--
            	"item_shivas_guard",--
				"item_revenants_brooch",
            	"item_ultimate_scepter_2",
				"item_orchid",
            	"item_bloodthorn",--
            	"item_moon_shard",
            	"item_cyclone",
            	"item_wind_waker",--
			},
            ['sell_list'] = {
				"item_bottle", "item_shivas_guard",
				"item_magic_wand", "item_revenants_brooch",
				"item_power_treads", "item_orchid",
			},
        },
    },
}

local sSelectedBuild = HeroBuild[sRole][RandomInt(1, #HeroBuild[sRole])]

local nTalentBuildList = J.Skill.GetTalentBuild(J.Skill.GetRandomBuild(sSelectedBuild.talent))
local nAbilityBuildList = J.Skill.GetRandomBuild(sSelectedBuild.ability)

X['sBuyList'] = sSelectedBuild.buy_list
X['sSellList'] = sSelectedBuild.sell_list

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'],X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)	
	end

end

end

--[[

npc_dota_hero_queenofpain

"Ability1"		"queenofpain_shadow_strike"
"Ability2"		"queenofpain_blink"
"Ability3"		"queenofpain_scream_of_pain"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"queenofpain_sonic_wave"
"Ability10"		"special_bonus_attack_damage_20"
"Ability11"		"special_bonus_strength_8"
"Ability12"		"special_bonus_cooldown_reduction_10"
"Ability13"		"special_bonus_attack_speed_30"
"Ability14"		"special_bonus_spell_lifesteal_25"
"Ability15"		"special_bonus_unique_queen_of_pain"
"Ability16"		"special_bonus_unique_queen_of_pain_2"
"Ability17"		"special_bonus_spell_block_18"

modifier_queenofpain_shadow_strike
modifier_queenofpain_scream_of_pain_fear

--]]

local abilityQ = bot:GetAbilityByName('queenofpain_shadow_strike')
local abilityW = bot:GetAbilityByName('queenofpain_blink')
local abilityE = bot:GetAbilityByName('queenofpain_scream_of_pain')
local abilityR = bot:GetAbilityByName('queenofpain_sonic_wave')
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget


local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget,sMotive,itemAffectedRange;
local aetherRange = 0

local botName

function X.SkillsComplement()

	-- Checks if the bot cannot use an ability or if it is invisible. If true, it exits the function.
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	-- Get references to Queen of Pain's abilities.
	abilityQ = bot:GetAbilityByName('queenofpain_shadow_strike')
	abilityW = bot:GetAbilityByName('queenofpain_blink')
	abilityE = bot:GetAbilityByName('queenofpain_scream_of_pain')
	abilityR = bot:GetAbilityByName('queenofpain_sonic_wave')

	-- Define some variables.
	nLV = bot:GetLevel()  -- Bot's level.
	nMP = bot:GetMana()/bot:GetMaxMana()  -- Mana percentage of the bot.
	nHP = bot:GetHealth()/bot:GetMaxHealth()  -- Health percentage of the bot.
	botTarget = J.GetProperTarget(bot)  -- Gets the most appropriate target for the bot.
	hEnemyList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)  -- Get a list of nearby enemies within a 1600-unit radius.
	hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1600)  -- Get a list of allies nearby within a 1600-unit radius.
	botName = GetBot():GetUnitName()  -- Get the name of the bot unit.

	-- Check if specific items are available and increase range if true.
	itemAffectedRange = 0  -- Additional range if the bot has specific items.
	local aetherLens = J.IsItemAvailable("item_aether_lens");
	local keenOptic = J.IsItemAvailable("item_keen_optic");
	local seerStone = J.IsItemAvailable("item_seer_stone");
	local eyeOfTheVizier = J.IsItemAvailable("item_eye_of_the_vizier");
	local etherealBlade = J.IsItemAvailable("item_ethereal_blade");

	if aetherLens ~= nil then itemAffectedRange = itemAffectedRange + 225 end
	if keenOptic ~= nil then itemAffectedRange = itemAffectedRange + 175 end
	if seerStone ~= nil then itemAffectedRange = itemAffectedRange + 450 end
	if eyeOfTheVizier ~= nil then itemAffectedRange = itemAffectedRange + 225 end
	if etherealBlade ~= nil then itemAffectedRange = itemAffectedRange + 250 end

	-- Check if blink (W) should be used.
	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if ( castWDesire > 0 ) then
		-- Sets a point for movement queued to integer.
		J.SetQueuePtToINT(bot, true)
		-- Action to use the blink ability on a target location.
		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWTarget )
		return;
	end

	-- Check if sonic wave (R) should be used.
	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if ( castRDesire > 0 ) then
		-- Sets a point for movement queued to integer.
		J.SetQueuePtToINT(bot, true)
		-- Action to use sonic wave on a target location.
		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRTarget )
		return;
	end

	-- Check if shadow strike (Q) should be used.
	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 ) then
		-- Sets a point for movement queued to integer.
		J.SetQueuePtToINT(bot, true)
		-- If the bot is a Queen of Pain with an Aghanim's Scepter and a target is available, use Q as AoE.
		if bot:HasScepter() and castQTarget ~= nil then
			bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQTarget:GetLocation() )
			return
		end
		-- Otherwise, use Q on a target entity.
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end

	-- Check if scream of pain (E) should be used.
	castEDesire, castETarget, sMotive = X.ConsiderE()
	if ( castEDesire > 0 ) then
		-- Sets a point for movement queued to integer.
		J.SetQueuePtToINT(bot, true)
		-- Action to use scream of pain.
		bot:ActionQueue_UseAbility( abilityE )
		return;
	end

end

function X.ConsiderQ()

	-- If the ability can't be cast, exit the function
	if not J.CanCastAbility(abilityQ) then return 0 end

	local nSkillLV    = abilityQ:GetLevel()  -- Get the current level of the ability
	local nCastRange  = abilityQ:GetCastRange() + itemAffectedRange  -- Get the ability's cast range
	local nCastPoint  = abilityQ:GetCastPoint()  -- Get the time delay before the ability is cast
	local nManaCost   = abilityQ:GetManaCost()  -- Get the mana cost of the ability

	-- Get ability damage values from game data
	local baseDamage = abilityQ:GetSpecialValueInt("strike_damage")
	local durationDamage = abilityQ:GetSpecialValueInt("duration_damage")
	local damageInterval = abilityQ:GetSpecialValueFloat("duration_damage_interval")
	local duration = abilityQ:GetSpecialValueFloat("duration")

	-- Check for Shadow Strike interval talent
	local intervalTalent = bot:GetAbilityByName("special_bonus_unique_queen_of_pain_4")
	if intervalTalent and intervalTalent:GetLevel() > 0 then
		damageInterval = damageInterval - 1.5
	end

	local numTicks = duration / damageInterval
	local totalDurationDamage = durationDamage * numTicks
	
	-- Scepter makes Shadow Strike AoE
	local scepterBonusDamage = 0
	local isAoE = false
	if bot:HasScepter() then
		isAoE = true
		-- Add any additional scepter damage if applicable
	end

	local nDamage = baseDamage + totalDurationDamage + scepterBonusDamage
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList(nCastRange + 20)
	local nInBonusEnemyList = J.GetAroundEnemyHeroList(nCastRange + 100)
	local hCastTarget = nil
	local sCastMotive = nil

	-- Check if any enemy hero can be killed with the ability
	for _, npcEnemy in pairs(nInBonusEnemyList) do
		if J.IsValid(npcEnemy)
				and not npcEnemy:HasModifier('modifier_queenofpain_shadow_strike')
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and J.CanKillTarget(npcEnemy, nDamage, nDamageType)
		then
			hCastTarget = npcEnemy
			sCastMotive = 'Q-Kill '..J.Chat.GetNormName(hCastTarget)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	-- Use the ability when aggressively going after an enemy
	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
				and not botTarget:HasModifier('modifier_queenofpain_shadow_strike')
				and J.IsInRange(botTarget, bot, nCastRange)
				and J.CanCastOnTargetAdvanced(botTarget)
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-Engage '..J.Chat.GetNormName(hCastTarget)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end

		-- With scepter, prioritize AoE targets
		if isAoE then
			local bestAoETarget = nil
			local bestAoECount = 0
			
			for _, npcEnemy in pairs(nInRangeEnemyList) do
				if J.IsValid(npcEnemy) and J.CanCastOnTargetAdvanced(npcEnemy) then
					local nearbyEnemies = npcEnemy:GetNearbyHeroes(200, false, BOT_MODE_NONE)
					if #nearbyEnemies > bestAoECount then
						bestAoETarget = npcEnemy
						bestAoECount = #nearbyEnemies
					end
				end
			end
			
			if bestAoETarget ~= nil and bestAoECount >= 2 then
				hCastTarget = bestAoETarget
				sCastMotive = 'Q-AoE('..bestAoECount..')'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end

		-- Check other enemies in the area
		for _, npcEnemy in pairs(nInBonusEnemyList) do
			if J.IsValid(npcEnemy)
					and not npcEnemy:HasModifier('modifier_queenofpain_shadow_strike')
					and J.CanCastOnTargetAdvanced(npcEnemy)
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-Target '..J.Chat.GetNormName(hCastTarget)
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	-- Use in laning phase for harass
	if J.IsLaning(bot) and J.IsAllowedToSpam(bot, nManaCost) then
		for _, npcEnemy in pairs(nInRangeEnemyList) do
			if J.IsValid(npcEnemy)
					and not npcEnemy:HasModifier('modifier_queenofpain_shadow_strike')
					and J.CanCastOnTargetAdvanced(npcEnemy)
					and (npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.7 or nMP > 0.8)
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-Harass '..J.Chat.GetNormName(hCastTarget)
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	-- Use the ability while retreating
	if J.IsRetreating(bot) then
		for _, npcEnemy in pairs(nInRangeEnemyList) do
			if J.IsValid(npcEnemy)
					and J.IsInRange(bot, npcEnemy, nCastRange - 100)
					and J.CanCastOnTargetAdvanced(npcEnemy)
					and (not J.IsDisabled(npcEnemy) or not npcEnemy:HasModifier('modifier_queenofpain_shadow_strike'))
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-Retreat '..J.Chat.GetNormName(hCastTarget)
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	-- Use ability on Roshan if fighting it
	if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
				and J.IsInRange(botTarget, bot, nCastRange)
				and J.CanBeAttacked(botTarget)
				and J.IsAttacking(bot)
				and not botTarget:HasModifier('modifier_roshan_spell_block')
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q-Roshan'
		end
	end

	-- Use ability on Tormentor if fighting it
	if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
				and J.IsInRange(botTarget, bot, nCastRange)
				and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q-Tormentor'
		end
	end

	-- Use the ability for farming neutral creeps if allowed
	if J.IsFarming(bot) and J.IsAllowedToSpam(bot, nManaCost) then
		local creepList = bot:GetNearbyNeutralCreeps(nCastRange)
		local targetCreep = J.GetMostHpUnit(creepList)

		if J.IsValid(targetCreep)
				and #creepList >= 2
				and not J.IsOtherAllysTarget(targetCreep)
				and not J.CanKillTarget(targetCreep, bot:GetAttackDamage() * 3, DAMAGE_TYPE_PHYSICAL)
		then
			hCastTarget = targetCreep
			sCastMotive = 'Q-Farm'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function X.ConsiderW()
	if not J.CanCastAbility(abilityW)
		or bot:IsRooted()
		or bot:HasModifier("modifier_bloodseeker_rupture")
	then return 0 end
	
	local nSkillLV    = abilityW:GetLevel() 
	local nCastRange  = abilityW:GetCastRange() + 75 * nSkillLV + itemAffectedRange
	local nAttackRange  = bot:GetAttackRange()
	local nCastPoint  = abilityW:GetCastPoint()
	local nManaCost   = abilityW:GetManaCost()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList(nCastRange)
	local hCastTarget = nil
	local sCastMotive = nil

	-- Handle stuck condition	
	if J.IsStuck(bot) then
		hCastTarget = J.GetEscapeLoc()
		sCastMotive = 'W-Stuck'
		return BOT_ACTION_DESIRE_ABSOLUTE, hCastTarget, sCastMotive
	end

	-- Retreat logic
	if J.IsRetreating(bot) or (bot:GetActiveMode() == BOT_MODE_RETREAT and nHP < 0.2) then
		-- Check for dangerous enemies before blinking
		local dangerousEnemy = false
		for _, enemy in pairs(hEnemyList) do
			if J.IsValidHero(enemy) and 
			   (enemy:HasAbility("spirit_breaker_charge_of_darkness") or 
			    enemy:HasAbility("bloodseeker_rupture") or
				enemy:HasAbility("riki_smoke_screen")) then
				dangerousEnemy = true
			end
		end
		
		if J.ShouldEscape(bot) and not dangerousEnemy then
			local escapeLocation = J.GetEscapeLoc()
			-- Check if escape location is safe
			if not J.IsLocationInCombatZone(escapeLocation) then
				hCastTarget = escapeLocation
				sCastMotive = 'W-Escape'
				return BOT_ACTION_DESIRE_ABSOLUTE, hCastTarget, sCastMotive
			end
		end
	end

	-- Aggressive blink
	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
			and J.IsInRange(bot, botTarget, nCastRange + 500)
			and not J.IsInRange(bot, botTarget, nAttackRange + 50)
			and not botTarget:IsAttackImmune()
		then
			local enemyList = botTarget:GetNearbyHeroes(1100, false, BOT_MODE_NONE)
			local allyList = botTarget:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
			
			-- Check if we should commit
			if #enemyList <= #allyList + 1 or J.WillKillTarget(botTarget, bot:GetAttackDamage() * 3, DAMAGE_TYPE_PHYSICAL, 3.0) then
				-- Calculate ideal blink position:
				-- 1. Behind target if we have allies to follow up
				-- 2. Just in range if we're alone
				local blinkPos
				if #allyList >= 2 then
					blinkPos = J.Site.GetXUnitsTowardsLocation(botTarget, bot:GetLocation(), 150)
				else
					blinkPos = J.Site.GetXUnitsTowardsLocation(botTarget, bot:GetLocation(), 330)
				end
				
				-- Check for scream of pain combo
				if abilityE:IsFullyCastable() and J.IsInRange(botTarget, blinkPos, 450) then
					hCastTarget = blinkPos
					sCastMotive = 'W-Combo: '..J.Chat.GetNormName(botTarget)
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
				
				hCastTarget = blinkPos
				sCastMotive = 'W-Engage: '..J.Chat.GetNormName(botTarget)
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end	
	end
	
	-- Blink to lane when needed
	local nEnemysTowers = bot:GetNearbyTowers(1600, true)
	if (bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 7)
		and #hEnemyList == 0 and #nEnemysTowers == 0 and DotaTime() < 12 * 60
	then
		if nMP > 0.96
			and bot:DistanceFromFountain() > 60
			and bot:DistanceFromFountain() < 6000
			and bot:GetAttackTarget() == nil
			and bot:GetActiveMode() == BOT_MODE_LANING
		then
			local nLane = bot:GetAssignedLane()
			local nLaneFrontLocation = GetLaneFrontLocation(GetTeam(), nLane, 0)
			local nDist = GetUnitToLocationDistance(bot, nLaneFrontLocation)

			if nDist > 2000 then
				local location = J.Site.GetXUnitsTowardsLocation(bot, nLaneFrontLocation, nCastRange)
				if IsLocationPassable(location) then
					hCastTarget = location
					sCastMotive = 'W-Lane Travel'
					return BOT_ACTION_DESIRE_MODERATE, hCastTarget, sCastMotive
				end
			end
		end
	end

	-- Farming mobility
	if J.IsFarming(bot) and nLV >= 6 then
		local farmTarget = bot:GetAttackTarget()
		if farmTarget ~= nil and farmTarget:IsAlive()
			and not J.IsInRange(bot, farmTarget, 900)
			and J.IsInRange(bot, farmTarget, 1600)
		then
			hCastTarget = farmTarget:GetLocation()
			sCastMotive = 'W-Farm Mobility'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	-- Blink to creep wave when safe
	if #hEnemyList == 0 
		and not bot:WasRecentlyDamagedByAnyHero(3.0) 
		and nLV >= 9
		and #hAllyList <= 3
	then
		local nAOELocation = bot:FindAoELocation(true, false, bot:GetLocation(), 1400, 400, 0, 0)
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1400, true)
		if nAOELocation.count >= 3
			and #nLaneCreeps >= 3
		then
			local bCenter = J.GetCenterOfUnits(nLaneCreeps)
			local bDist = GetUnitToLocationDistance(bot, bCenter)
			
			if bDist >= 700
				and IsLocationPassable(bCenter)
				and IsLocationVisible(bCenter)
			then
				hCastTarget = bCenter
				sCastMotive = 'W-Wave Clear'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function X.ConsiderE()
	if not J.CanCastAbility(abilityE) then return 0 end

	local nSkillLV    = abilityE:GetLevel()
	local nCastPoint  = abilityE:GetCastPoint()
	local nRadius     = abilityE:GetSpecialValueInt("area_of_effect")
	local nManaCost   = abilityE:GetManaCost()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList(nRadius - 30)
	local hCastTarget = nil
	local sCastMotive = nil

	-- Get damage values based on skill level
	local nDamageTable = {abilityE:GetSpecialValueInt("damage")}
	local nDamage = nDamageTable[1]

	-- Check for scream of pain bonus damage talent
	local talentDmg = bot:GetAbilityByName("special_bonus_unique_queen_of_pain_2")
	if talentDmg and talentDmg:GetLevel() > 0 then
		nDamage = nDamage + talentDmg:GetSpecialValueInt("value")
	end

	-- Kill logic
	for _, npcEnemy in pairs(nInRangeEnemyList) do
		if J.IsValid(npcEnemy)
				and J.CanKillTarget(npcEnemy, nDamage, nDamageType)
		then
			hCastTarget = npcEnemy
			sCastMotive = 'E-Kill '..J.Chat.GetNormName(hCastTarget)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	-- Teamfight and attacking
	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
				and J.IsInRange(botTarget, bot, nRadius - 20)
		then
			hCastTarget = botTarget
			sCastMotive = 'E-Attack '..J.Chat.GetNormName(hCastTarget)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	-- AoE teamfight
	if J.IsInTeamFight(bot, 1000) then
		local nAoeCount = 0
		for _, npcEnemy in pairs(nInRangeEnemyList) do
			if J.IsValidHero(npcEnemy) then
				nAoeCount = nAoeCount + 1
			end
		end

		if nAoeCount >= 2 then
			hCastTarget = botTarget
			sCastMotive = 'E-TeamFight('..nAoeCount..')'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	-- Retreat cases
	if J.IsRetreating(bot) then
		for _, npcEnemy in pairs(nInRangeEnemyList) do
			if J.IsValid(npcEnemy)
					and bot:WasRecentlyDamagedByHero(npcEnemy, 5.0)
					-- Use scream especially when enemy is chasing closely
					and GetUnitToUnitDistance(bot, npcEnemy) < nRadius - 150
			then
				hCastTarget = npcEnemy
				sCastMotive = 'E-Retreat '..J.Chat.GetNormName(hCastTarget)
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	-- Laning efficiency
	if J.IsLaning(bot) and J.IsAllowedToSpam(bot, nManaCost) then
		local nCanKillMeleeCount = 0
		local nCanKillRangedCount = 0
		local hLaneCreepList = bot:GetNearbyLaneCreeps(nRadius, true)
		for _, creep in pairs(hLaneCreepList) do
			if J.IsValid(creep)
					and not creep:HasModifier("modifier_fountain_glyph")
					and not J.IsOtherAllysTarget(creep)
			then
				local lastHitDamage = nDamage
				local nDelay = nCastPoint + GetUnitToUnitDistance(bot, creep)/900

				if J.WillKillTarget(creep, lastHitDamage, nDamageType, nDelay) then
					if J.IsKeyWordUnit('ranged', creep) then
						nCanKillRangedCount = nCanKillRangedCount + 1
					end

					if J.IsKeyWordUnit('melee', creep) then
						nCanKillMeleeCount = nCanKillMeleeCount + 1
					end
				end
			end
		end

		-- Prioritize getting multiple creeps, especially ranged creeps
		if nCanKillMeleeCount + nCanKillRangedCount >= 2 then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E-Farm Multiple('..nCanKillMeleeCount+nCanKillRangedCount..')'
		end

		if nCanKillRangedCount >= 1 then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E-Farm Ranged'
		end

		-- Harass enemy hero while also farming
		if J.IsValidHero(nInRangeEnemyList[1]) and nMP > 0.5 then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E-Harass+Farm'
		end
	end

	-- Push and defend
	if (J.IsPushing(bot) or J.IsDefending(bot))
			and J.IsAllowedToSpam(bot, nManaCost * 0.32)
			and #hAllyList <= 3
	then
		local laneCreepList = bot:GetNearbyLaneCreeps(nRadius, true)
		if (#laneCreepList >= 4 or (#laneCreepList >= 3 and nMP > 0.82))
				and not laneCreepList[1]:HasModifier("modifier_fountain_glyph")
		then
			hCastTarget = laneCreepList[1]
			sCastMotive = 'E-Push('..#laneCreepList..')'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	-- Jungle farming
	if J.IsFarming(bot)
			and J.IsAllowedToSpam(bot, nManaCost * 0.25)
	then
		local creepList = bot:GetNearbyNeutralCreeps(nRadius)

		if #creepList >= 2 and J.IsValid(botTarget) then
			hCastTarget = botTarget
			sCastMotive = 'E-Jungle('..#creepList..')'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	-- Use on Roshan
	if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
				and J.IsInRange(botTarget, bot, nRadius)
				and J.CanBeAttacked(botTarget)
				and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, nil, 'E-Roshan'
		end
	end

	-- Use on Tormentor
	if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
				and J.IsInRange(botTarget, bot, nRadius)
				and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, nil, 'E-Tormentor'
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function X.ConsiderR()
	if not J.CanCastAbility(abilityR) then return 0 end

	local nSkillLV    = abilityR:GetLevel()
	local nCastRange  = abilityR:GetCastRange() + itemAffectedRange
	local nCastPoint  = abilityR:GetCastPoint()
	local nManaCost   = abilityR:GetManaCost()
	
	-- Get damage values
	local nDamage = abilityR:GetSpecialValueInt("damage")
	
	-- Check for sonic wave damage talent
	local talentDmg = bot:GetAbilityByName("special_bonus_unique_queen_of_pain_7")
	if talentDmg and talentDmg:GetLevel() > 0 then
		nDamage = nDamage + talentDmg:GetSpecialValueInt("value")
	end

	local nRadius = abilityR:GetSpecialValueInt("final_aoe") * 0.88
	local nDamageType = DAMAGE_TYPE_PURE
	local nInRangeEnemyList = J.GetAroundEnemyHeroList(nCastRange)
	local hCastTarget = nil
	local sCastMotive = nil

	-- First priority: Kill a high-value target
	for _, npcEnemy in pairs(nInRangeEnemyList) do
		if J.IsValid(npcEnemy)
			and J.CanCastOnMagicImmune(npcEnemy)
			and J.CanKillTarget(npcEnemy, nDamage, nDamageType)
			and J.IsCore(npcEnemy)
		then
			local nTargetLocation = J.GetCastLocation(bot, npcEnemy, nCastRange, nRadius)
			if nTargetLocation ~= nil then
				hCastTarget = nTargetLocation
				sCastMotive = 'R-Kill Core: '..J.Chat.GetNormName(npcEnemy)
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	-- Teamfight AOE (Area of Effect)
	if J.IsInTeamFight(bot, 1200) then
		-- Try to hit 3+ heroes
		local nAoeLoc = J.GetAoeEnemyHeroLocation(bot, nCastRange, nRadius, 3)
		if nAoeLoc ~= nil then
			hCastTarget = nAoeLoc
			sCastMotive = 'R-Teamfight 3+'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
		
		-- Otherwise 2+ heroes
		local nAoeLoc = J.GetAoeEnemyHeroLocation(bot, nCastRange, nRadius, 2)
		if nAoeLoc ~= nil then
			hCastTarget = nAoeLoc
			sCastMotive = 'R-Teamfight 2+'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	-- Attack Target (especially high priority/low HP targets)
	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
				and J.IsInRange(bot, botTarget, nCastRange + nRadius * 0.5)
				and J.CanCastOnMagicImmune(botTarget)
		then
			local nearbyEnemyList = botTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE)
			
			-- Target has low HP or multiple enemies grouped
			if J.GetHP(botTarget) < 0.4
				or J.CanKillTarget(botTarget, nDamage * 1.2, nDamageType)
				or #nearbyEnemyList >= 2
			then
				local nTargetLocation = J.GetCastLocation(bot, botTarget, nCastRange, nRadius)
				if nTargetLocation ~= nil then
					hCastTarget = nTargetLocation
					sCastMotive = 'R-Attack: '..J.Chat.GetNormName(botTarget)
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
			
			-- Target is higher priority or has high armor (Pure damage effective)
			if J.IsCore(botTarget) 
				or botTarget:GetPhysicalArmorValue() > 15
			then
				local nTargetLocation = J.GetCastLocation(bot, botTarget, nCastRange, nRadius)
				if nTargetLocation ~= nil then
					hCastTarget = nTargetLocation
					sCastMotive = 'R-Core/Tank: '..J.Chat.GetNormName(botTarget)
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
	end

	-- Protect team while retreating
	if J.IsRetreating(bot)
			and #hEnemyList >= 2
			and bot:WasRecentlyDamagedByAnyHero(3.0)
			and nHP < 0.5
	then
		for _, npcEnemy in pairs(nInRangeEnemyList) do
			if J.IsValid(npcEnemy)
					and J.CanCastOnMagicImmune(npcEnemy)
					and not J.IsDisabled(npcEnemy)
					and J.GetHP(bot) < 0.4
			then
				hCastTarget = npcEnemy:GetExtrapolatedLocation(nCastPoint)
				sCastMotive = 'R-Retreat Protection'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	-- Multiple enemy heroes when ganking or counter-initiation
	local enemiesNearby = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	if #enemiesNearby >= 2 then
		local nAoeLoc = J.GetAoeEnemyHeroLocation(bot, nCastRange, nRadius, 2)
		if nAoeLoc ~= nil then
			hCastTarget = nAoeLoc
			sCastMotive = 'R-Offensive 2+'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X