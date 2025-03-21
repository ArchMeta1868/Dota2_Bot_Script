local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

if GetBot():GetUnitName() == 'npc_dota_hero_windrunner'
then

local RI = require(GetScriptDirectory()..'/FunLib/util_role_item')

local HeroBuild = {
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
                [1] = {2,3,2,3,3,6,3,1,2,2,1,6,1,1,6},
            },
            ['buy_list'] = {
                "item_tango",
                "item_double_branches",

                "item_bottle",
                "item_magic_wand",
                "item_power_treads",
                "item_witch_blade",
                "item_black_king_bar",
                "item_ultimate_scepter",
                "item_ultimate_scepter_2",
                "item_bloodthorn",
                "item_devastator",
                "item_lesser_crit",
                "item_revenants_brooch",
                "item_disperser",
                "item_moon_shard",
                "item_aghanims_shard",
                "item_wind_waker",--
            },
            ['sell_list'] = {
                "item_bottle", "item_lesser_crit",
                "item_magic_wand", "item_disperser",
                "item_power_treads", "item_wind_waker",
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

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

end

local ShackleShot   = bot:GetAbilityByName('windrunner_shackleshot')
local Powershot     = bot:GetAbilityByName('windrunner_powershot')
local Windrun       = bot:GetAbilityByName('windrunner_windrun')
local GaleForce     = bot:GetAbilityByName('windrunner_gale_force')
local FocusFire     = bot:GetAbilityByName('windrunner_focusfire')

local ShackleShotDesire, ShackleShotTarget
local PowershotDesire, PowershotLocation
local WindrunDesire
local GaleForceDesire, GaleForceLocation
local FocusFireDesire
local sMotive
local botTarget

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    ShackleShot   = bot:GetAbilityByName('windrunner_shackleshot')
    Powershot     = bot:GetAbilityByName('windrunner_powershot')
    Windrun       = bot:GetAbilityByName('windrunner_windrun')
    GaleForce     = bot:GetAbilityByName('windrunner_gale_force')
    FocusFire     = bot:GetAbilityByName('windrunner_focusfire')

    botTarget = J.GetProperTarget(bot)

    WindrunDesire = X.ConsiderWindrun()
    if WindrunDesire > 0
    then
        bot:Action_UseAbility(Windrun)
        return
    end

    ShackleShotDesire, ShackleShotTarget = X.ConsiderShackleShot()
    if ShackleShotDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(ShackleShot, ShackleShotTarget)
        return
    end

    FocusFireDesire, sMotive = X.ConsiderFocusFire()
    if FocusFireDesire > 0
    then
        J.SetQueuePtToINT( bot, false )
        bot:ActionQueue_UseAbility( FocusFire )
        return
    end

    PowershotDesire, PowershotLocation = X.ConsiderPowershot()
    if PowershotDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(Powershot, PowershotLocation)
        return
    end

    GaleForceDesire, GaleForceLocation = X.ConsiderGaleForce()
    if GaleForceDesire > 0
    then
        bot:Action_UseAbilityOnLocation(GaleForce, GaleForceLocation)
        return
    end
end

function X.ConsiderShackleShot()
    if not J.CanCastAbility(ShackleShot)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, ShackleShot:GetCastRange())
    local nRadius = ShackleShot:GetSpecialValueInt('shackle_distance')
    local nAngle = ShackleShot:GetSpecialValueInt('shackle_angle')
    local nStunDuration = ShackleShot:GetSpecialValueFloat('stun_duration')

    local tAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	for _, enemyHero in pairs(tEnemyHeroes)
    do
		if  J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and enemyHero:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, enemyHero
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local target = nil
        local targetAttackDamage = 0

        for _, enemy in pairs(tEnemyHeroes) do
            if  J.IsValidTarget(enemy)
            and J.CanCastOnNonMagicImmune(enemy)
            and J.CanCastOnTargetAdvanced(enemy)
            and J.IsInRange(bot, enemy, nCastRange)
            and not J.IsDisabled(enemy)
            and not enemy:HasModifier('modifier_enigma_black_hole_pull')
            and not enemy:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local enemyAttackDamge = enemy:GetAttackDamage() * enemy:GetAttackSpeed()
                if enemyAttackDamge > targetAttackDamage then
                    target = enemy
                    targetAttackDamage = enemyAttackDamge
                end
            end
        end

        if target then
            local tAllyHeroes_attacking = J.GetSpecialModeAllies(bot, 900, BOT_MODE_ATTACK)
            if J.IsChasingTarget(bot, target) and #tAllyHeroes_attacking >= 2
            or J.IsAttacking(bot) and bot:GetEstimatedDamageToTarget(true, target, nStunDuration, DAMAGE_TYPE_ALL) > target:GetHealth() then
                local target__ = X.GetShackleTarget(bot, target, nRadius, nAngle)
                if target__ then
                    return BOT_ACTION_DESIRE_HIGH, target__
                end
            end
        end
	end

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
	then
        for _, enemyHero in pairs(tEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsDisabled(enemyHero)
            and bot:WasRecentlyDamagedByHero(enemyHero, 3.0)
            then
                local target = X.GetShackleTarget(bot, enemyHero, nRadius, nAngle)
                if target ~= nil
                then
                    return BOT_ACTION_DESIRE_HIGH, target
                end
            end
        end
	end

	--打断
	for _, npcEnemy in pairs( tEnemyHeroes )
	do
		if J.IsValid( npcEnemy )
			and (npcEnemy:IsChanneling() or npcEnemy:HasModifier( 'modifier_teleporting' ) )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end

    for _, allyHero in pairs(tAllyHeroes)
    do
        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and J.GetMP(bot) > 0.45
        and allyHero:WasRecentlyDamagedByAnyHero(3.0)
        and not J.IsRealInvisible(bot)
        and not allyHero:IsIllusion()
        then
            local tAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
            for _, enemyHero in pairs(tAllyInRangeEnemy) do
                if  J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.CanCastOnTargetAdvanced(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and J.IsChasingTarget(enemyHero, allyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
                and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    local target = X.GetShackleTarget(bot, enemyHero, nRadius, nAngle)
                    if target ~= nil
                    then
                        return BOT_ACTION_DESIRE_HIGH, target
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderPowershot()
    if not J.CanCastAbility(Powershot)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = Powershot:GetCastRange()
    local nCastPoint = Powershot:GetCastPoint()
	local nRadius = Powershot:GetSpecialValueInt('arrow_width')
	local nSpeed = Powershot:GetSpecialValueInt('arrow_speed')
    local nDamage = Powershot:GetSpecialValueInt('powershot_damage')
	local nAttackRange = bot:GetAttackRange()
    local botMP = J.GetMP(bot)

    local tAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(tEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsInRange(bot, enemyHero, nAttackRange - 100)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local eta = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(enemyHero, eta)
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
        if  J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsInRange(bot, botTarget, nAttackRange)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local eta = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint

            if bot:GetLevel() < 6 then
                if J.CanKillTarget(botTarget, nDamage + bot:GetAttackDamage() * 3, DAMAGE_TYPE_ALL) then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, eta)
                end
            else
                return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, eta)
            end
        end
	end

	if J.IsPushing(bot) or J.IsDefending(bot)
	then
        local tEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
        if J.IsValid(tEnemyLaneCreeps[1])
        and J.CanBeAttacked(tEnemyLaneCreeps[1])
        and not J.IsRunning(tEnemyLaneCreeps[1])
        and botMP > 0.45 then
            local nLocationAoE = bot:FindAoELocation(true, false, tEnemyLaneCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
            if nLocationAoE.count >= 4 then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end

        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        if nLocationAoE.count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        then
            local tCreeps = bot:GetNearbyCreeps(1600, true)
            if J.IsValid(tCreeps[1])
            and J.CanBeAttacked(tCreeps[1])
            and not J.IsRunning(tCreeps[1])
            and botMP > 0.33 then
                local nLocationAoE = bot:FindAoELocation(true, false, tCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
                if nLocationAoE.count >= 2 or nLocationAoE.count >= 1 and tCreeps[1]:IsAncientCreep() then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
    end

    if  J.IsLaning(bot)
    and (J.IsCore(bot) or (not J.IsCore(bot) and not J.IsThereCoreNearby(1200)))
	then
        local canKill = 0
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
            and creep:GetHealth() > bot:GetAttackDamage()
			and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL)
			then
				if J.GetMP(bot) > 0.3
                and J.CanBeAttacked(creep)
                and not J.IsRunning(creep)
				then
                    if J.IsValidHero(tEnemyHeroes[1])
                    and not J.IsSuspiciousIllusion(tEnemyHeroes[1])
                    and not J.IsDisabled(tEnemyHeroes[1])
                    and not bot:WasRecentlyDamagedByTower(1)
                    and GetUnitToUnitDistance(creep, tEnemyHeroes[1]) < tEnemyHeroes[1]:GetAttackRange()
                    then
                        return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
                    end
				end
			end

            if J.IsValid(creep)
            and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL)
            then
                if #creepList >  0 then
                    if J.IsInRange(creep, creepList[1], nRadius) then
                        table.insert(creepList, creep)
                    end
                else
                    table.insert(creepList, creep)
                end
            end
		end

        if #creepList >= 2
        and J.GetMP(bot) > 0.25
        and J.CanBeAttacked(creepList[1])
        and not J.IsRunning(creepList[1])
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderWindrun()
    local nSkillLV    = Windrun:GetLevel()
    if not J.CanCastAbility(Windrun)
    or bot:HasModifier('modifier_windrunner_windrun')
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

function X.ConsiderFocusFire()
    if not J.CanCastAbility(FocusFire)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = 600
    local nInRangeEnemyList = J.GetAroundEnemyHeroList( nRadius )
    local hCastTarget = nil
    local sCastMotive = nil

    --打架攻击
    if J.IsGoingOnSomeone( bot )
    then
        if J.IsValidHero( botTarget )
                and J.IsInRange( botTarget, bot, nRadius )
        then
            hCastTarget = botTarget
            sCastMotive = 'Q-攻击:'..J.Chat.GetNormName( hCastTarget )
            return BOT_ACTION_DESIRE_HIGH, sCastMotive
        end
    end

    --团战AOE
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
                sCastMotive = 'Q-团战AOE'..nAoeCount
                return BOT_ACTION_DESIRE_HIGH, sCastMotive
            end
        end

        --撤退时保护自己
    if J.IsRetreating( bot )
    then
        for _, npcEnemy in pairs( hEnemyList )
        do
            if J.IsValid( npcEnemy ) and J.IsInRange( bot, npcEnemy, 1200 )
                    and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )
                    and J.IsInRange( bot, npcEnemy, nRadius - 120 )
            then
                hCastTarget = npcEnemy
                sCastMotive = 'Q-撤退'..J.Chat.GetNormName( hCastTarget )
                return BOT_ACTION_DESIRE_HIGH, sCastMotive
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderGaleForce()
    if not J.CanCastAbility(GaleForce)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, GaleForce:GetCastRange())
    local nRadius = GaleForce:GetSpecialValueInt('radius')
    local nCastPoint = GaleForce:GetCastPoint()

    if J.IsGoingOnSomeone(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange + nRadius, nRadius, nCastPoint, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if #nInRangeEnemy >= 2
        and not J.IsEnemyChronosphereInLocation(nLocationAoE.targetloc)
        and not J.IsEnemyBlackHoleInLocation(nLocationAoE.targetloc)
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    then
        local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(tEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, 800)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetAlliesNearLoc(enemyHero:GetLocation(), 1200)
                local nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), 1200)

                if #nInRangeEnemy > #nInRangeAlly and bot:WasRecentlyDamagedByAnyHero(3.0)
                then
                    return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + J.GetCenterOfUnits(nInRangeEnemy)) / 2
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

-- Helper Funcs
function X.GetShackleCreepTarget(hSource, hTarget, nRadius, nMaxAngle)
	local nCreeps = hTarget:GetNearbyCreeps(nRadius, false)
	for _, creep in pairs(nCreeps)
    do
        if J.IsValid(creep)
        then
            local angle = X.GetAngleWithThreeVectors(hSource:GetLocation(), creep:GetLocation(), hTarget:GetLocation())

            if angle <= nMaxAngle then
                return creep
            end
        end
	end

	return nil
end

function X.GetShackleHeroTarget(hSource, hTarget, nRadius, nMaxAngle)
	local nEnemyHeroes = hTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and enemyHero ~= hTarget
        then
            local angle = X.GetAngleWithThreeVectors(hSource:GetLocation(), enemyHero:GetLocation(), hTarget:GetLocation())

            if angle <= nMaxAngle then
                return enemyHero
            end
        end
	end

	return nil
end

function X.CanShackleToCreep(hSource, hTarget, nRadius, nMaxAngle)
	local nCreeps = hTarget:GetNearbyCreeps(nRadius, false)
	for _, creep in pairs(nCreeps)
    do
        if J.IsValid(creep)
        then
            local angle = X.GetAngleWithThreeVectors(hSource:GetLocation(), hTarget:GetLocation(), creep:GetLocation())
            if angle <= nMaxAngle then
                return true
            end
        end
	end

	return false
end

function X.CanShackleToHero(hSource, hTarget, nRadius, nMaxAngle)
	local nEnemyHeroes = J.GetEnemiesNearLoc(hTarget:GetLocation(), nRadius)

    -- real
	for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and enemyHero ~= hTarget
        then
            local angle = X.GetAngleWithThreeVectors(hSource:GetLocation(), hTarget:GetLocation(), enemyHero:GetLocation())
            if angle <= nMaxAngle then
                return true
            end
        end
	end

    -- include illusions
    nEnemyHeroes = hTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and enemyHero ~= hTarget
        then
            local angle = X.GetAngleWithThreeVectors(hSource:GetLocation(), hTarget:GetLocation(), enemyHero:GetLocation())
            if angle <= nMaxAngle then
                return true
            end
        end
	end

	return false
end

function X.CanShackleToTree(hSource, hTarget, nRadius, nMaxAngle)
	local nTrees = hTarget:GetNearbyTrees(nRadius)
	for _, tree in pairs(nTrees) do
        if tree then
            local angle = X.GetAngleWithThreeVectors(hSource:GetLocation(), hTarget:GetLocation(), GetTreeLocation(tree))
            if angle <= nMaxAngle then
                return true
            end
        end
	end

	return false
end

function X.GetShackleTarget(hSource, hTarget, nRadius, nMaxAngle)
	local sTarget = nil

    if X.CanShackleToHero(hSource, hTarget, nRadius, nMaxAngle)
    or X.CanShackleToTree(hSource, hTarget, nRadius, nMaxAngle)
    or X.CanShackleToCreep(hSource, hTarget, nRadius, nMaxAngle) then
        sTarget = hTarget
    else
        sTarget = X.GetShackleCreepTarget(hSource, hTarget, nRadius, nMaxAngle)

		if sTarget == nil then
			sTarget = X.GetShackleHeroTarget(hSource, hTarget, nRadius, nMaxAngle)
		end
    end

	return sTarget
end

function X.GetAngleWithThreeVectors(A, B, C)
    local CA = Vector(C.x - A.x, C.y - A.y, C.z - A.z)
    local CB = Vector(C.x - B.x, C.y - B.y, C.z - B.z)

    local magCA = math.sqrt(CA.x^2 + CA.y^2 + CA.z^2)
    local magCB = math.sqrt(CB.x^2 + CB.y^2 + CB.z^2)

    local dot = CA.x * CB.x + CA.y * CB.y + CA.z * CB.z

    return (math.acos(dot / (magCA * magCB))) * (180 / math.pi)
end

function X.IsBeingAttackedByRealHero(unit)
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMIES))
    do
        if J.IsValidHero(enemy)
        and not J.IsSuspiciousIllusion(enemy)
        and (enemy:GetAttackTarget() == unit or J.IsChasingTarget(enemy, unit))
        then
            return true
        end
    end

    return false
end

return X