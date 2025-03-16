dofile('bots/Buff/Timers')
dofile('bots/Buff/Experience')
dofile('bots/Buff/GPM')
dofile('bots/Buff/NeutralItems')
dofile('bots/Buff/Helper')

if Buff == nil
then
    Buff = {}
end

if BuffEnabled == nil then BuffEnabled = false end

local botTable = {
    [DOTA_TEAM_GOODGUYS]    = {},
    [DOTA_TEAM_BADGUYS]     = {}
}

function Buff:AddBotsToTable()
    print('[Buff] Starting bot detection...')
    for _, team in pairs({DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS}) do
        local playerCount = PlayerResource:GetPlayerCountForTeam(team)
        print('[Buff] Checking team ' .. team .. ' with ' .. playerCount .. ' players')
        
        for j = 1, playerCount do
            local playerID = PlayerResource:GetNthPlayerIDOnTeam(team, j)
            local player = PlayerResource:GetPlayer(playerID)
            
            -- Enhanced bot detection logic
            if player then
                local isFakeClient = PlayerResource:IsFakeClient(playerID)
                local isValidHero = false
                local hero = player:GetAssignedHero()
                
                if hero and hero:IsNull() == false then
                    isValidHero = true
                end
                
                print(string.format('[Buff] Player %d: IsFakeClient=%s, HasValidHero=%s', 
                    playerID, 
                    tostring(isFakeClient), 
                    tostring(isValidHero)))
                
                if isFakeClient and isValidHero then
                    print('[Buff] Adding bot hero: ' .. hero:GetUnitName())
                    table.insert(botTable[team], hero)
                end
            end
        end
    end
    print('[Buff] Bot detection complete - Radiant: ' .. #botTable[DOTA_TEAM_GOODGUYS] .. ', Dire: ' .. #botTable[DOTA_TEAM_BADGUYS])
end

-- fix Lifestealer and Faceless Void missing ultimates due to facet
-- if anyone is using this vscript with another bot script, you might need to change some stuff to work with it (ie. level up list)
function AddAbilityToHero(hero, hAbilityName)
    local missingSpell = nil
    local abilityCount = hero:GetAbilityCount()
    hero:AddAbility(hAbilityName)

    for i = abilityCount - 1, 0, -1
    do
        local ability = hero:GetAbilityByIndex(i)
        if ability then
            if ability:GetAbilityName() == hAbilityName
            then
                missingSpell = ability
            end

            if ability:GetAbilityName() == 'generic_hidden' and missingSpell then
                hero:SwapAbilities(missingSpell:GetAbilityName(), ability:GetAbilityName(), true, false)
                break
            end
        end
    end

    -- swap lifestealer's spells to their correct slots for sAbilityLevelUpList
    if hero:GetUnitName() == 'npc_dota_hero_life_stealer' then
        local ability_1 = 'life_stealer_rage'
        local ability_2 = 'life_stealer_open_wounds'
        local ability_3 = 'life_stealer_ghoul_frenzy'

        if hero:HasAbility(ability_1) and hero:HasAbility(ability_2) and hero:HasAbility(ability_3) then
            hero:SwapAbilities(ability_2, ability_3, true, true)
            hero:SwapAbilities(ability_1, ability_3, true, true)
        end
    end
end

local BotCount = 0
local SelectedHeroCount = 0
local function CheckBotCount()
    BotCount = 0
    SelectedHeroCount = 0
    local playerCount = PlayerResource:GetPlayerCount()

    for playerID = 0, playerCount - 1 do
        if PlayerResource:GetSteamID(playerID) == PlayerResource:GetSteamID(playerCount + 1) then
            if PlayerResource:GetSelectedHeroName(playerID) ~= '' then
                SelectedHeroCount = SelectedHeroCount + 1
            end

            BotCount = BotCount + 1
        end
    end
end

-- script flags
local bBuffFlags = {
    -- General
    neutrals = {
        radiant = true, -- Set to 'false' to disable Radiant bots receiving neutral items.
        dire    = true, -- Set to 'false' to disable Dire bots receiving neutral items.
    },
    -- Applies to All Pick only
    gpm = {
        radiant = true, -- Set to 'false' to disable Radiant bots receiving a Gold boost.
        dire    = true, -- Set to 'false' to disable Dire bots receiving a Gold boost.
    },
    xpm = {
        radiant = true, -- Set to 'false' to disable Radiant bots receiving an Experience boost.
        dire    = true, -- Set to 'false' to disable Dire bots receiving an Experience boost.
    },
}

function Buff:Init()
    print('[Buff] Initializing buff system...')
    
    if not BuffEnabled then
        print('[Buff] Enabling buff mode')
        GameRules:SendCustomMessage('Buff mode enabled!', 0, 0)
        BuffEnabled = true
    end

    print('[Buff] Creating main timer...')
    Timers:CreateTimer(0, function() -- Start immediately with 0 delay
        local gameTime = GameRules:GetGameTime()
        local dotaTime = GameRules:GetDOTATime(false, false)
        print(string.format('[Buff] Timer tick - GameTime: %.2f, DotaTime: %.2f', gameTime, dotaTime))

        -- Clear and refresh bot tables
        botTable[DOTA_TEAM_GOODGUYS] = {}
        botTable[DOTA_TEAM_BADGUYS] = {}
        Buff:AddBotsToTable()
        
        local TeamRadiant = botTable[DOTA_TEAM_GOODGUYS]
        local TeamDire = botTable[DOTA_TEAM_BADGUYS]
        local hHeroList = {}

        if dotaTime > 0 then
            -- Neutral Items
            print('[Buff] Processing neutral items...')
            if bBuffFlags.neutrals.radiant then
                for _, h in pairs(TeamRadiant) do
                    print('[Buff] Adding Radiant hero to neutral items list: ' .. h:GetUnitName())
                    table.insert(hHeroList, h)
                end
            end
            if bBuffFlags.neutrals.dire then
                for _, h in pairs(TeamDire) do
                    print('[Buff] Adding Dire hero to neutral items list: ' .. h:GetUnitName())
                    table.insert(hHeroList, h)
                end
            end

            if #hHeroList > 0 then
                print('[Buff] Attempting to give neutral items to ' .. #hHeroList .. ' heroes')
                local success, err = pcall(function()
                    NeutralItems.GiveNeutralItems(hHeroList)
                end)
                print('[Buff] Neutral items distribution ' .. (success and 'succeeded' or 'failed: ' .. tostring(err)))
            end

            -- Gold and Experience
            if not Helper.IsTurboMode() then
                print('[Buff] Processing GPM and XPM updates...')
                
                for _, h in pairs(TeamRadiant) do
                    if bBuffFlags.gpm.radiant then
                        print('[Buff] Updating GPM for Radiant hero: ' .. h:GetUnitName())
                        local success, err = pcall(function()
                            GPM.UpdateBotGold(h, TeamRadiant)
                        end)
                        print('[Buff] GPM update ' .. (success and 'succeeded' or 'failed: ' .. tostring(err)))
                    end
                    if bBuffFlags.xpm.radiant then
                        print('[Buff] Updating XPM for Radiant hero: ' .. h:GetUnitName())
                        local success, err = pcall(function()
                            XP.UpdateXP(h, TeamRadiant)
                        end)
                        print('[Buff] XPM update ' .. (success and 'succeeded' or 'failed: ' .. tostring(err)))
                    end
                end

                for _, h in pairs(TeamDire) do
                    if bBuffFlags.gpm.dire then
                        print('[Buff] Updating GPM for Dire hero: ' .. h:GetUnitName())
                        local success, err = pcall(function()
                            GPM.UpdateBotGold(h, TeamDire)
                        end)
                        print('[Buff] GPM update ' .. (success and 'succeeded' or 'failed: ' .. tostring(err)))
                    end
                    if bBuffFlags.xpm.dire then
                        print('[Buff] Updating XPM for Dire hero: ' .. h:GetUnitName())
                        local success, err = pcall(function()
                            XP.UpdateXP(h, TeamDire)
                        end)
                        print('[Buff] XPM update ' .. (success and 'succeeded' or 'failed: ' .. tostring(err)))
                    end
                end
            else
                print('[Buff] Skipping GPM/XPM updates - Turbo mode detected')
            end
        else
            print('[Buff] Waiting for game time to start (DotaTime <= 0)')
        end

        return 1 -- Run again in 1 second
    end)
    print('[Buff] Timer created successfully')
end

Buff:Init()