local X = {}
local bot = GetBot()

local Hero = require(GetScriptDirectory()..'/FunLib/bot_builds/'..string.gsub(bot:GetUnitName(), 'npc_dota_hero_', ''))
local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local nTalentBuildList = J.Skill.GetTalentBuild(Hero.TalentBuild[sRole][RandomInt(1, #Hero.TalentBuild[sRole])])
local nAbilityBuildList = Hero.AbilityBuild[sRole][RandomInt(1, #Hero.AbilityBuild[sRole])]

local sRand = RandomInt(1, #Hero.BuyList[sRole])
X['sBuyList'] = Hero.BuyList[sRole][sRand]
X['sSellList'] = Hero.SellList[sRole][sRand]

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Decay         = bot:GetAbilityByName('undying_decay')
local SoulRip       = bot:GetAbilityByName('undying_soul_rip')
local Tombstone     = bot:GetAbilityByName('undying_tombstone')
local FleshGolem    = bot:GetAbilityByName('undying_flesh_golem')

local DecayDesire, DecayLocation
local SoulRipDesire, SoulRipTarget
local TombstoneDesire, TombstoneLocation
local FleshGolemDesire

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    FleshGolemDesire = X.ConsiderFleshGolem()
    if FleshGolemDesire > 0
    then
        bot:Action_UseAbility(FleshGolem)
        return
    end

    TombstoneDesire, TombstoneLocation = X.ConsiderTombstone()
    if TombstoneDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Tombstone, TombstoneLocation)
        return
    end

    DecayDesire, DecayLocation = X.ConsiderDecay()
    if DecayDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Decay, DecayLocation)
        return
    end

    SoulRipDesire, SoulRipTarget = X.ConsiderSoulRip()
    if SoulRipDesire > 0
    then
        bot:Action_UseAbilityOnEntity(SoulRip, SoulRipTarget)
        return
    end
end

function X.ConsiderDecay()
    if not Decay:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, Decay:GetCastRange())
    local nRadius = Decay:GetSpecialValueInt('radius')
	local nDamage = Decay:GetSpecialValueInt('decay_damage')
    local nAbilityLevel = Decay:GetLevel()

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange + nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        then
            local nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)

            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
            then
                if not J.IsInRange(bot, enemyHero, nCastRange)
                then
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
                else
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                end
            end

            if not J.IsInRange(bot, enemyHero, nCastRange)
            then
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, enemyHero:GetLocation(), nCastRange)
            else
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end
        end
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange + nRadius, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, nLocationAoE.targetloc, nCastRange)
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange + nRadius, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                then
                    nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)

                    if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                    then
                        if not J.IsInRange(bot, enemyHero, nCastRange)
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
                        else
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        end
                    end

                    if not J.IsInRange(bot, enemyHero, nCastRange)
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, enemyHero:GetLocation(), nCastRange)
                    else
                        return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                    end
                end
            end
        end
	end

    if J.IsPushing(bot) or J.IsDefending(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + nRadius, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and nAbilityLevel >= 3
        and J.GetMP(bot) > 0.6
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end
	end

    if J.IsLaning(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + nRadius, true)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and J.IsAttacking(bot)
        and J.GetMP(bot) > 0.5
        and nAbilityLevel >= 3
        and not J.IsThereCoreNearby(1200)
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end

        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange + nRadius, nRadius, 0, 0)
        nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and J.IsInLaningPhase()
        and nAbilityLevel >= 2
        then
            if GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nInRangeEnemy)) > nCastRange
            then
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
            else
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
            end
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and nAbilityLevel >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and nAbilityLevel >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderSoulRip()
    if not SoulRip:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, SoulRip:GetCastRange())
	local nRadius = SoulRip:GetSpecialValueInt('radius')
    local nDamage = SoulRip:GetSpecialValueInt('damage_per_unit')

    local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        then
            local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)
            local nCreeps = bot:GetNearbyCreeps(nRadius, true)

            if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
            then
                nDamage = nDamage * #nInRangeEnemy
            end

            if nCreeps ~= nil and #nCreeps >= 1
            then
                nDamage = nDamage * #nCreeps
            end

            if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end
    end

	if J.IsGoingOnSomeone(bot, 1200)
	then
		local targetAlly = nil
		local hp = 1000

		local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
		for _, allyHero in pairs(nInRangeAlly)
		do
			if  J.IsValidHero(allyHero)
            and not J.IsSuspiciousIllusion(allyHero)
			then
                local nAllyInRangeEnemy = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
                local nAllyInRangeCreeps = bot:GetNearbyCreeps(nRadius, true)
				local currHP = allyHero:GetHealth()

				if  currHP < hp
                and J.GetHP(allyHero) < 0.75
                and (nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
                    or nAllyInRangeCreeps ~= nil and #nAllyInRangeCreeps >= 2)
				then
					hp = currHP
					targetAlly = allyHero
				end
			end
		end

		if targetAlly ~= nil
		then
			return BOT_ACTION_DESIRE_MODERATE, targetAlly
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5)
                    or J.GetHP(bot) < 0.5)
                then
                    return BOT_ACTION_DESIRE_HIGH, bot
                end
            end
        end

        local nCreeps = bot:GetNearbyCreeps(nRadius, true)
        if  nCreeps ~= nil and #nCreeps >= 4
        and J.GetHP(bot) < 0.6
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
	end

    if J.IsPushing(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and J.GetMP(bot) > 0.7
        and J.GetHP(bot) < 0.6
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
	end

    if J.IsLaning(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and J.IsAttacking(bot)
        and J.GetMP(bot) > 0.5
        and J.GetHP(bot) < 0.6
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
	end

    if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
	then
        if  (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            local targetAlly = nil
            local hp = 1000

            local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
            for _, allyHero in pairs(nInRangeAlly)
            do
                if  J.IsValidHero(allyHero)
                and not J.IsSuspiciousIllusion(allyHero)
                then
                    local currHP = allyHero:GetHealth()

                    if  currHP < hp
                    and J.GetHP(allyHero) < 0.75
                    then
                        hp = currHP
                        targetAlly = allyHero
                    end
                end
            end

            if targetAlly ~= nil
            then
                return BOT_ACTION_DESIRE_MODERATE, targetAlly
            end
        end
	end

    local targetAlly = nil
    local hp = 1000

    local nInRangeAlly = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nInRangeAlly)
    do
        if  J.IsValidHero(allyHero)
        and not J.IsSuspiciousIllusion(allyHero)
        then
            local nAllyInRangeCreeps = bot:GetNearbyCreeps(nRadius, true)
            local currHP = allyHero:GetHealth()

            if  currHP < hp
            and J.GetHP(allyHero) < 0.75
            and J.GetMP(bot) > 0.35
            and nAllyInRangeCreeps ~= nil and #nAllyInRangeCreeps >= 4
            then
                hp = currHP
                targetAlly = allyHero
            end
        end
    end

    if targetAlly ~= nil
    then
        return BOT_ACTION_DESIRE_MODERATE, targetAlly
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderTombstone()
    if not Tombstone:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, Tombstone:GetCastRange())
    local nRadius = Tombstone:GetSpecialValueInt('radius')

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius / 2)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            local loc = J.GetCenterOfUnits(nInRangeEnemy)

            if J.IsLocationInChrono(loc)
            or J.IsLocationInBlackHole(loc)
            or J.IsLocationInArena(loc, nRadius / 2)
            then
                return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
            end

            return BOT_ACTION_DESIRE_HIGH, loc
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFleshGolem()
    if not FleshGolem:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X