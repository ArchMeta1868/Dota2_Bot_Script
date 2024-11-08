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
    ['pos_1'] = {
        [1] = {
            ['talent'] = {
                [1] = {},
            },
            ['ability'] = {
                [1] = {},
            },
            ['buy_list'] = {},
            ['sell_list'] = {},
        },
    },
    ['pos_2'] = {
        [1] = {
            ['talent'] = {
				[1] = {
					['t25'] = {0, 10},
					['t20'] = {0, 10},
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
				"item_yasha_and_kaya",--
            	"item_shivas_guard",--
            	"item_ultimate_scepter_2",
            	"item_bloodthorn",--
            	"item_moon_shard",
            	"item_cyclone",
            	"item_wind_waker",--
			},
            ['sell_list'] = {
				"item_bottle",
				"item_magic_wand",
				"item_power_treads",
			},
        },
    },
    ['pos_3'] = {
        [1] = {
            ['talent'] = {
                [1] = {},
            },
            ['ability'] = {
                [1] = {},
            },
            ['buy_list'] = {},
            ['sell_list'] = {},
        },
    },
    ['pos_4'] = {
        [1] = {
            ['talent'] = {
                [1] = {},
            },
            ['ability'] = {
                [1] = {},
            },
            ['buy_list'] = {},
            ['sell_list'] = {},
        },
    },
    ['pos_5'] = {
        [1] = {
            ['talent'] = {
                [1] = {},
            },
            ['ability'] = {
                [1] = {},
            },
            ['buy_list'] = {},
            ['sell_list'] = {},
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


local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget,sMotive,masochistAmplification,itemAffectedRange;
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
	masochistAmplification = 0  -- Potential spell amplification from the Masochist ability.

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

	-- Check if Masochist ability is available and calculate spell amplification.
	local masochistAbility = bot:GetAbilityByName('queenofpain_masochist');
	if masochistAbility ~= nil then
		masochistAmplification = 0.1 + 0.03 * nLV
	end

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
		-- If the bot is a Queen of Pain with an Aghanim's Scepter and a target is available, use Q.
		if string.find(botName, 'queenofpain')
				and bot:HasScepter()
				and castQTarget ~= nil then
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

	-- Calculate the damage based on ability level using "queenofpain_shadow_strike"
	local baseDamage = 120 * nSkillLV  -- Base damage is 120 per level as per the provided ability data
	local durationDamage = 75 * nSkillLV  -- Damage over time component
	local damageInterval = 3.0  -- Interval at which duration damage is dealt

	-- Check if special_bonus_unique_queen_of_pain_4 applies
	if bot:GetAbilityByName('special_bonus_unique_queen_of_pain_4') then
		damageInterval = damageInterval + (-1.5)  -- Adjust damage interval based on talent modifier
	end

	local duration = 16 / damageInterval  -- Total number of intervals during the duration
	local totalDurationDamage = durationDamage * duration  -- Total duration damage

	-- Check if special_bonus_scepter applies
	local scepterBonusDamage = 0
	if bot:HasScepter() then
		scepterBonusDamage = 920
	end

	local nDamage = baseDamage + totalDurationDamage + scepterBonusDamage
	local nDamage = (baseDamage + totalDurationDamage + scepterBonusDamage) * (1 + masochistAmplification)  -- Total damage calculation

	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange + 20 )  -- Get the list of enemies in range
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 100 )  -- Get the list of enemies just outside the cast range
	local hCastTarget = nil
	local sCastMotive = nil

	-- Check if any enemy hero can be killed with the ability
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid( npcEnemy )
				and not npcEnemy:HasModifier( 'modifier_queenofpain_shadow_strike' )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and J.CanKillTarget( npcEnemy, nDamage , nDamageType )
		then
			hCastTarget = npcEnemy
			sCastMotive = 'Q-Kill'..J.Chat.GetNormName( hCastTarget )  -- Motive for casting: Kill enemy hero
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	-- Use the ability when aggressively going after an enemy or when in the laning phase if allowed to spam
	if J.IsGoingOnSomeone( bot ) or (J.IsLaning( bot ) and J.IsAllowedToSpam(bot, nManaCost))
	then
		if J.IsValidHero( botTarget )
				and not botTarget:HasModifier( 'modifier_queenofpain_shadow_strike' )
				and J.IsInRange( botTarget, bot, nCastRange )
				and J.CanCastOnTargetAdvanced( botTarget )
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-Engage'..J.Chat.GetNormName( hCastTarget )  -- Motive for casting: Engage with enemy
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end

		-- Check other enemies in the area
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
					and not npcEnemy:HasModifier( 'modifier_queenofpain_shadow_strike' )
					and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-Target'..J.Chat.GetNormName( hCastTarget )  -- Motive for casting: Target enemy
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	-- Use the ability while retreating
	if J.IsRetreating( bot )
	-- and bot:WasRecentlyDamagedByAnyHero( 5.0 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
					and J.IsInRange( bot, npcEnemy, nCastRange - 100 )
					and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-Retreat'..J.Chat.GetNormName( hCastTarget )  -- Motive for casting: Aid in retreat
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	-- Use ability on Roshan if fighting it
	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan( botTarget )
				and J.IsInRange( botTarget, bot, nCastRange )
				and J.CanBeAttacked(botTarget)
				and J.IsAttacking(bot)
				and not botTarget:HasModifier('modifier_roshan_spell_block')
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, ''  -- Motive for casting: Fighting Roshan
		end
	end

	-- Use ability on Tormentor if fighting it
	if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
				and J.IsInRange( botTarget, bot, nCastRange )
				and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, ''  -- Motive for casting: Fighting Tormentor
		end
	end

	-- Use the ability for farming neutral creeps if allowed
	if J.IsFarming( bot )
			and J.IsAllowedToSpam( bot, nManaCost )
	then
		local creepList = bot:GetNearbyNeutralCreeps( nCastRange )

		local targetCreep = J.GetMostHpUnit( creepList )

		if J.IsValid( targetCreep )
				and #creepList >= 2
				and not J.IsOtherAllysTarget( targetCreep )
				and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 3, DAMAGE_TYPE_PHYSICAL )
		then
			hCastTarget = targetCreep
			sCastMotive = 'Q-Farm:'..J.Chat.GetNormName( hCastTarget )  -- Motive for casting: Farming neutral creeps
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function X.ConsiderW()


	if not J.CanCastAbility(abilityW)
		or bot:IsRooted()
		or bot:HasModifier( "modifier_bloodseeker_rupture" )
	then return 0 end
	
	local nSkillLV    = abilityW:GetLevel() 
	local nCastRange  = 1000 + nSkillLV * 75 + itemAffectedRange
	local nAttackRange  = bot:GetAttackRange()
	local nCastPoint  = abilityW:GetCastPoint()
	local nManaCost   = abilityW:GetManaCost()
	local nDamage     = abilityW:GetAbilityDamage()
	local ScreamOfPainDamage     = abilityE:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local hCastTarget = nil
	local sCastMotive = nil
	

	if J.IsStuck( bot )
	then
		hCastTarget = J.GetEscapeLoc()
		sCastMotive = 'W-被卡住'
		return BOT_ACTION_DESIRE_ABSOLUTE, hCastTarget, sCastMotive
	end

	if J.IsRetreating( bot ) 
		or ( bot:GetActiveMode() == BOT_MODE_RETREAT and nHP < 0.2 and bot:DistanceFromFountain() > 1100 )
	then
		if J.ShouldEscape( bot ) 
			or ( bot:DistanceFromFountain() > 600 and  bot:DistanceFromFountain() < 3800 )
		then
			hCastTarget = J.GetEscapeLoc()
			sCastMotive = 'W-逃跑'
			return BOT_ACTION_DESIRE_ABSOLUTE, hCastTarget, sCastMotive
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 500 )
			and not J.IsInRange( bot, botTarget, nAttackRange + 50 )
			and not botTarget:IsAttackImmune()
		then
			local enemyList = botTarget:GetNearbyHeroes( 1100, false, BOT_MODE_NONE )
			local allyList = botTarget:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
			local aliveEnemyCount = J.GetNumOfAliveHeroes( true )
			
			if aliveEnemyCount <= 1
				or #enemyList <= 1
				or #enemyList < #allyList
				or J.WillKillTarget( botTarget, bot:GetAttackDamage() * 2, DAMAGE_TYPE_PHYSICAL, 2.0 )
			then
			
				hCastTarget = J.Site.GetXUnitsTowardsLocation( botTarget, bot:GetLocation(), 330 )
				sCastMotive = 'W-进攻:'..J.Chat.GetNormName( botTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				
			end		
		end	
	end
	
	

	local nEnemysTowers = bot:GetNearbyTowers( 1600, true )
	if ( bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 7 )
		and #hEnemyList == 0 and #nEnemysTowers == 0 and DotaTime() < 12 * 60
	then
		
		if nMP > 0.96
			and bot:DistanceFromFountain() > 60
			and bot:DistanceFromFountain() < 6000
			and bot:GetAttackTarget() == nil
			and bot:GetActiveMode() == BOT_MODE_LANING
		then
			local nLane = bot:GetAssignedLane()
			local nLaneFrontLocation = GetLaneFrontLocation( GetTeam(), nLane, 0 )
			local nDist = GetUnitToLocationDistance( bot, nLaneFrontLocation )

			if nDist > 2000
			then
				local location = J.Site.GetXUnitsTowardsLocation( bot, nLaneFrontLocation, nCastRange )
				if IsLocationPassable( location )
				then
					hCastTarget = location
					sCastMotive = 'W-对线赶路'
					
					if bot:GetTarget() ~= nil
					then
						if J.CanKillTarget( bot:GetTarget(), ScreamOfPainDamage, DAMAGE_TYPE_MAGICAL ) and abilityE.IsFullyCastable()
						then
							return BOT_ACTION_DESIRE_VERYHIGH
						end
					end
					
					return BOT_ACTION_DESIRE_MODERATE, hCastTarget, sCastMotive
				end
			end
		end
	end
	


	if J.IsFarming( bot ) and nLV >= 6
	then
		if botTarget ~= nil and botTarget:IsAlive()
			and not J.IsInRange( bot, botTarget, 900 )
			and J.IsInRange( bot, botTarget, 1600 )
		then
			hCastTarget = botTarget:GetLocation()
			sCastMotive = 'W-打钱赶路'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	

	local nAttackAllys = bot:GetNearbyHeroes( 1600, false, BOT_MODE_ATTACK )
	if #hEnemyList == 0 
		and not bot:WasRecentlyDamagedByAnyHero( 3.0 ) 
		and nLV >= 9
		and #nAttackAllys == 0 
		and #hAllyList <= 3
		and ( botTarget ~= nil and not botTarget:IsHero() )
	then
		local nAOELocation = bot:FindAoELocation( true, false, bot:GetLocation(), 1400, 400, 0, 0 )
		local nLaneCreeps = bot:GetNearbyLaneCreeps( 1400, true )
		if nAOELocation.count >= 3
			and #nLaneCreeps >= 3
		then
			local bCenter = J.GetCenterOfUnits( nLaneCreeps )
			local bDist = GetUnitToLocationDistance( botTarget, bCenter )
			
			if bDist <= 500
				and IsLocationPassable( bCenter )
				and IsLocationVisible( bCenter )
				and GetUnitToLocationDistance( bot, bCenter ) >= 700
			then
				hCastTarget = bCenter
				sCastMotive = 'W-跳兵堆'
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
	local nRadius  = 600
	local nManaCost   = abilityE:GetManaCost()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nRadius - 30 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nRadius + 200 )
	local hCastTarget = nil
	local sCastMotive = nil

	-- Set nDamage based on skill level and additional bonus if applicable
	local nDamageTable = {120, 240, 360, 480}
	local nDamage = nDamageTable[nSkillLV]

	-- Apply additional damage if special_bonus_unique_queen_of_pain_2 is available
	if bot:GetUnitName() == 'npc_dota_hero_queenofpain'
	then
		local Talent2 = bot:GetAbilityByName('special_bonus_unique_queen_of_pain_2')
		if Talent2 ~= nil then nDamage = nDamage + 420 end
	end

	local nDamage = nDamage * (1 + masochistAmplification)  -- Total damage calculation

	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValid( npcEnemy )
				and J.CanKillTarget( npcEnemy, nDamage, nDamageType )
		then
			hCastTarget = npcEnemy
			sCastMotive = 'E-Kill'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
				and J.IsInRange( botTarget, bot, nRadius - 20 )
		then
			hCastTarget = botTarget
			sCastMotive = 'E-Attack'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	if J.IsInTeamFight( bot, 1000 )
	then
		local nAoeCount = 0
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
			then
				nAoeCount = nAoeCount + 1
			end
		end

		if nAoeCount >= 2
		then
			hCastTarget = botTarget
			sCastMotive = 'E-AOE'..nAoeCount
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
					and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'E-Retreat'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	if J.IsLaning( bot ) and J.IsAllowedToSpam(bot, nManaCost)
	then
		local nCanKillMeleeCount = 0
		local nCanKillRangedCount = 0
		local hLaneCreepList = bot:GetNearbyLaneCreeps( nRadius, true )
		for _, creep in pairs( hLaneCreepList )
		do
			if J.IsValid( creep )
					and not creep:HasModifier( "modifier_fountain_glyph" )
					and not J.IsOtherAllysTarget( creep )
			then
				local lastHitDamage = nDamage
				local nDelay = nCastPoint + GetUnitToUnitDistance( bot, creep )/900

				if J.WillKillTarget( creep, lastHitDamage, nDamageType, nDelay )
				then
					if J.IsKeyWordUnit( 'ranged', creep )
					then
						nCanKillRangedCount = nCanKillRangedCount + 1
					end

					if J.IsKeyWordUnit( 'melee', creep )
					then
						nCanKillMeleeCount = nCanKillMeleeCount + 1
					end

				end
			end
		end

		if nCanKillMeleeCount + nCanKillRangedCount >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E1'
		end

		if nCanKillRangedCount >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E2'
		end

		if J.IsValidHero( nInRangeEnemyList[1] )
				and nMP > 0.5
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E3'
		end
	end

	if ( J.IsPushing( bot ) or J.IsDefending( bot ) )
			and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
			and #hAllyList <= 3
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nRadius , true )
		if ( #laneCreepList >= 4 or ( #laneCreepList >= 3 and nMP > 0.82 ) )
				and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			hCastTarget = creep
			sCastMotive = 'E-Push AOE'..(#laneCreepList)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	if J.IsFarming( bot )
			and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		local creepList = bot:GetNearbyNeutralCreeps( nRadius )

		if #creepList >= 2
				and J.IsValid( botTarget )
		then
			hCastTarget = botTarget
			sCastMotive = 'E-Farm AOE'..(#creepList)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan( botTarget )
				and J.IsInRange( botTarget, bot, nRadius )
				and J.CanBeAttacked(botTarget)
				and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
				and J.IsInRange( botTarget, bot, nRadius )
				and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
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

	-- Set nDamage based on skill level and additional bonus if applicable
	local nDamageTable = {750, 1350, 2050}
	local nDamage = nDamageTable[nSkillLV]

	-- Apply additional damage if special_bonus_unique_queen_of_pain_7 is available
	if bot:GetUnitName() == 'npc_dota_hero_queenofpain'
	then
		local Talent7 = bot:GetAbilityByName('special_bonus_unique_queen_of_pain_7')
		if Talent7 ~= nil then nDamage = nDamage + 950 end
	end

	local nDamage = nDamage * (1 + masochistAmplification)  -- Total damage calculation

	local nRadius = abilityR:GetSpecialValueInt( 'final_aoe' ) * 0.88
	local nDamageType = DAMAGE_TYPE_PURE

	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local hCastTarget = nil
	local sCastMotive = nil

	-- Teamfight AOE (Area of Effect)
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			hCastTarget = nAoeLoc
			sCastMotive = 'R - Teamfight AOE'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	-- Attack Target
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
				and J.IsInRange( bot, botTarget, nCastRange + nRadius * 0.5 )
		then
			local nearbyEnemyList = botTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE )
			if J.CanKillTarget( botTarget, nDamage, nDamageType )
					or #nearbyEnemyList >= 2
			then
				local nTargetLocation = J.GetCastLocation( bot, botTarget, nCastRange, nRadius )
				if nTargetLocation ~= nil
				then
					hCastTarget = nTargetLocation
					sCastMotive = 'R - Attack Target: '..J.Chat.GetNormName( botTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
	end

	-- Protect Team While Retreating
	if J.IsRetreating( bot )
			and #hEnemyList >= 2
			and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
					and J.CanCastOnMagicImmune( npcEnemy )
					and not J.IsDisabled( npcEnemy )
			then
				hCastTarget = npcEnemy:GetExtrapolatedLocation( nCastPoint )
				sCastMotive = 'R - Protect Team Retreat'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X

