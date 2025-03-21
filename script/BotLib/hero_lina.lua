local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

if GetBot():GetUnitName() == 'npc_dota_hero_lina'
then

local RI = require(GetScriptDirectory()..'/FunLib/util_role_item')

local sUtility = {}
local sUtilityItem = RI.GetBestUtilityItem(sUtility)

local HeroBuild = {
    ['pos_2'] = {
        [1] = {
            ['talent'] = {
				[1] = {
					['t25'] = {10, 0},
					['t20'] = {0, 10},
					['t15'] = {0, 10},
					['t10'] = {0, 10},
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
            	"item_boots",
				"item_witch_blade",
            	"item_black_king_bar",--
				"item_orchid",
				"item_bloodthorn",--
				"item_lesser_crit",
				"item_revenants_brooch",
                "item_satanic",--
            	"item_ultimate_scepter",
            	"item_ultimate_scepter_2",
				"item_devastator",--
            	"item_aghanims_shard",
            	"item_moon_shard",
				"item_dragon_lance",
				"item_hurricane_pike",--
			},
            ['sell_list'] = {
				"item_bottle", "item_lesser_crit",
				"item_boots", "item_satanic",
				"item_magic_wand", "item_ultimate_scepter",
			},
        },
    },
}

local sSelectedBuild = HeroBuild[sRole][RandomInt(1, #HeroBuild[sRole])]

local nTalentBuildList = J.Skill.GetTalentBuild(J.Skill.GetRandomBuild(sSelectedBuild.talent))
local nAbilityBuildList = J.Skill.GetRandomBuild(sSelectedBuild.ability)

X['sBuyList'] = sSelectedBuild.buy_list
X['sSellList'] = sSelectedBuild.sell_list

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true


function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

end

local abilityQ = bot:GetAbilityByName('lina_dragon_slave')
local abilityW = bot:GetAbilityByName('lina_light_strike_array')
local abilityE = bot:GetAbilityByName('lina_fiery_soul')
local FlameCloak = bot:GetAbilityByName('lina_flame_cloak')
local abilityR = bot:GetAbilityByName('lina_laguna_blade')
local talent2 = bot:GetAbilityByName( sTalentList[2] )
local talent4 = bot:GetAbilityByName( sTalentList[4] )
local talent7 = bot:GetAbilityByName( sTalentList[7] )

local castQDesire, castQLocation
local castWDesire, castWLocation
local castRDesire, castRTarget
local FlameCloakDesire


local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive, botName, itemAffectedRange



function X.SkillsComplement()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	abilityQ = bot:GetAbilityByName('lina_dragon_slave')
	abilityW = bot:GetAbilityByName('lina_light_strike_array')
	FlameCloak = bot:GetAbilityByName('lina_flame_cloak')
	abilityR = bot:GetAbilityByName('lina_laguna_blade')

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )
	botName = GetBot():GetUnitName()

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

	FlameCloakDesire = X.ConsiderFlameCloak()
	if (FlameCloakDesire > 0)
	then
		bot:Action_UseAbility(FlameCloak)
		return
	end

	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return

	end


	castQDesire, castQLocation, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return
	end

	castWDesire, castWLocation, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return
	end


end


function X.ConsiderQ()


	if not J.CanCastAbility(abilityQ) then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + itemAffectedRange
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( "AbilityDamage" )
	local nRadius = abilityQ:GetSpecialValueInt( "dragon_slave_width_end" )
	local nDamageType = DAMAGE_TYPE_MAGICAL

	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange -80, true, BOT_MODE_NONE )
	local nTargetLocation = nil

	--击杀
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
		then
			nTargetLocation = npcEnemy:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q击杀'..J.Chat.GetNormName( npcEnemy )
		end
	end

	--消耗
	local nCanHurtEnemyAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius + 50, 0, 0 )
	if nCanHurtEnemyAoE.count >= 3 and bot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		nTargetLocation = nCanHurtEnemyAoE.targetloc
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q消耗'
	end


	--对线消耗或补刀
	if J.IsLaning( bot )
	then
		--对线消耗
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange -80, nRadius, 2 )
		if nAoeLoc ~= nil and nMP > 0.58
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q对线消耗'
		end

		--对线补刀
		if #hAllyList == 1 and nMP > 0.38
		then
			local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0, nDamage )
			if locationAoEKill.count >= 3
			then
				nTargetLocation = locationAoEKill.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q对线补刀"..locationAoEKill.count
			end
		end
	end


	--团战
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q团战'
		end
	end


	--打架时先手
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange -80 )
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHP( botTarget ) < 0.38
			then
				nTargetLocation = botTarget:GetExtrapolatedLocation( nCastPoint )
				if J.IsInLocRange( bot, nTargetLocation, nCastRange )
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q打架'..J.Chat.GetNormName( botTarget )
				end
			end
		end
	end


	--撤退前加速
	if J.IsRetreating( bot ) and not bot:HasModifier( 'modifier_lina_fiery_soul' )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 20 )
			then
				nTargetLocation = npcEnemy:GetLocation()
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q撤退'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	--打钱
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, botTarget, 1000 )
			and ( botTarget:GetMagicResist() < 0.4 or nMP > 0.9 )
		then
			local nShouldHurtCount = nMP > 0.6 and 2 or 3
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q打钱"..locationAoE.count
			end
		end
	end


	--推进时对小兵用
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and nSkillLV >= 2 and DotaTime() > 8 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1400, true )
		if #laneCreepList >= 3
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage )
			if locationAoEKill.count >= 2
	 			and #hAllyList == 1
			then
				nTargetLocation = locationAoEKill.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q带线1"..locationAoEKill.count
			end

			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0, 0 )
			if ( locationAoEHurt.count >= 3 and #laneCreepList >= 4 )
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q带线2"..locationAoEHurt.count
			end
		end
	end


	--打肉的时候输出
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 400
	then
		if J.IsRoshan( botTarget ) and J.GetHP( botTarget ) > 0.15
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.IsAttacking(bot)
		then
			nTargetLocation = botTarget:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q肉山'
		end
	end

	if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, 800)
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), ''
		end
	end



	--通用消耗敌人或受到伤害时保护自己
	if ( #hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero( 3.0 ) )
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nLV >= 15 and false --there be bug
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.IsInRange( bot, npcEnemy, nCastRange - 200 )
			then
				nTargetLocation = npcEnemy:GetLocation()
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q通用'
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

--J.GetDelayCastLocation( bot, botTarget, nCastRange, nRadius, nTime )
function X.ConsiderW()


	if not J.CanCastAbility(abilityW) then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange() + itemAffectedRange
	local nCastPoint = abilityW:GetCastPoint() + 0.5
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetSpecialValueInt( 'light_strike_array_damage' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nRadius 	 = abilityW:GetSpecialValueInt( "light_strike_array_aoe" )

	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange + nRadius * 0.5, true, BOT_MODE_NONE )

	local nTargetLocation = nil

	-- Set nDamage based on skill level and additional bonus if applicable
	local nDamageTable = {95, 190, 285, 380}
	local nDamage = nDamageTable[nSkillLV]

	-- Apply additional damage if special_bonus_unique_lina_3 is available
	if bot:GetUnitName() == 'npc_dota_hero_lina'
	then
		local Talent4 = bot:GetAbilityByName('special_bonus_unique_lina_3')
		if Talent4 ~= nil then nDamage = nDamage + 280 end
	end

	--击杀和打断
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
		then
			--打断
			if npcEnemy:IsChanneling()
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius, nCastPoint )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W打断"..J.Chat.GetNormName( npcEnemy )
				end
			end

			--击杀
			if J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius, nCastPoint + 0.2 )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W击杀"..J.Chat.GetNormName( npcEnemy )
				end
			end

		end


	end


	--消耗
	local nCanHurtEnemyAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius + 20, 0, 0 )
	if nCanHurtEnemyAoE.count >= 3
	then
		nTargetLocation = nCanHurtEnemyAoE.targetloc
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'W消耗'
	end



	--团战
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'W团战'
		end
	end


	--打架
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange -30 )
		then
			nTargetLocation = J.GetDelayCastLocation( bot, botTarget, nCastRange, nRadius, nCastPoint + 0.3 )
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W打架"..J.Chat.GetNormName( botTarget )
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange -100, nRadius -20, 2 )
		if nAoeLoc ~= nil
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'W撤退1'
		end

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 ) or bot:GetActiveModeDesire() > BOT_ACTION_DESIRE_VERYHIGH )
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius, nCastPoint + 0.3 )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W撤退2"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end


	--自保
	if bot:WasRecentlyDamagedByAnyHero( 3.0 ) and nLV >= 10
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nInRangeEnemyList >= 1
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and bot:IsFacingLocation( npcEnemy:GetLocation(), 45 )
			then
				nTargetLocation = J.GetDelayCastLocation( bot, npcEnemy, nCastRange, nRadius -30, nCastPoint + 0.3 )
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W自保"..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end

	--对线

	--打野
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, botTarget, 1000 )
			and ( botTarget:GetMagicResist() < 0.4 or nMP > 0.9 )
		then
			local nShouldHurtCount = nMP > 0.6 and 3 or 4
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W打钱"..locationAoE.count
			end
		end
	end

	--带线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and nSkillLV >= 3 and DotaTime() > 9 * 60
		and #hAllyList <= 1 and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nCastRange + 200, true )
		if #laneCreepList >= 4
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, nDamage )
			if locationAoEKill.count >= 3
			then
				nTargetLocation = locationAoEKill.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W带线1"..locationAoEKill.count
			end

			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0.5, 0 )
			if locationAoEHurt.count >= 4
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "W带线2"..locationAoEHurt.count
			end
		end
	end

	--肉山
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 600
	then
		if J.IsRoshan( botTarget ) and J.GetHP( botTarget ) > 0.3
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.IsAttacking(bot)
		then
			nTargetLocation = botTarget:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'W肉山'
		end
	end

	if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, 800)
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), ''
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderR()


	if not J.CanCastAbility(abilityR) then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange() + itemAffectedRange
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetSpecialValueInt( "damage" )
	local nDamageType = bot:HasScepter() and DAMAGE_TYPE_PURE or DAMAGE_TYPE_MAGICAL


	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange + 80, true, BOT_MODE_NONE )
	local nInBonusEnemyList = bot:GetNearbyHeroes( nCastRange + 240, true, BOT_MODE_NONE )


	--击杀
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and not J.IsHaveAegis( npcEnemy )
		then
			if J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint + 0.25 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'R击杀'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end

	--团战对最弱的敌人
	if J.IsInTeamFight( bot, 600 )
		or ( nHP < 0.3 and nSkillLV >= 2 )
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 10000

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
			then
				local npcEnemyHealth = npcEnemy:GetHealth()
				if ( npcEnemyHealth < npcWeakestEnemyHealth )
				then
					npcWeakestEnemyHealth = npcEnemyHealth
					npcWeakestEnemy = npcEnemy
				end
			end
		end

		if ( npcWeakestEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy, 'R团战'..J.Chat.GetNormName( npcWeakestEnemy )
		end

	end


	--打架
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 100 )
		then
			if J.WillMagicKillTarget( bot, botTarget, nDamage * 1.88, nCastPoint + 0.25 )
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget, "R打架"..J.Chat.GetNormName( botTarget )
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderFlameCloak()
	if not J.CanCastAbility(FlameCloak)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	return BOT_ACTION_DESIRE_HIGH
end

return X