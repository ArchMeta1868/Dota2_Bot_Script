local X = {}
local sSelectHero = "npc_dota_hero_zuus"
local fLastSlectTime, fLastRand = -100, 0
local nDelayTime = nil
local nHumanCount = 0
local sBanList = {}
local sSelectList = {}
local tSelectPoolList = {}
local tLaneAssignList = {}

local bUserMode = false
local bLaneAssignActive = true
local bLineupReserve = false

local nDireFirstLaneType = 1
if pcall(require, 'game/bot_dire_first_lane_type') then
	nDireFirstLaneType = require('game/bot_dire_first_lane_type')
end

require(GetScriptDirectory() .. '/API/api_global')

local MU = require(GetScriptDirectory() .. '/FunLib/aba_matchups')
local U = require(GetScriptDirectory() .. '/FunLib/lua_util')
local N = require(GetScriptDirectory() .. '/FunLib/bot_names')
local Role = require(GetScriptDirectory() .. '/FunLib/aba_role')
local Chat = require(GetScriptDirectory() .. '/FunLib/aba_chat')
local HeroSet = {}

local sHeroList = {

	-- Heroes not active
	{name = 'npc_dota_hero_kunkka', role = {0, 0, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_lone_druid',  role = {0, 0, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_ogre_magi', role = {0, 0, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_bloodseeker', role = {0, 0, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_kez',  role = {0, 100, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_magnataur', role = {0, 0, 0, 0, 0}, value = 1},

	{name = 'npc_dota_hero_spirit_breaker', role = {0, 0, 0, 100, 0}, value = 1},



	{name = 'npc_dota_hero_visage', role = {0, 0, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_lone_druid', role = {0, 0, 0, 0, 0}, value = 1}, -- nil

	-- Heroes with value = 1
	{name = 'npc_dota_hero_troll_warlord', role = {100, 0, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_juggernaut', role = {100, 0, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_life_stealer', role = {100, 0, 0, 0, 0}, value = 1},

	{name = 'npc_dota_hero_obsidian_destroyer', role = {0, 100, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_tinker', role = {0, 100, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_huskar', role = {0, 100, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_riki', role = {0, 100, 0, 0, 0}, value = 1},
	{name = 'npc_dota_hero_sniper', role = {0, 100, 0, 0, 0}, value = 1},

	{name = 'npc_dota_hero_brewmaster', role = {0, 0, 100, 0, 0}, value = 1},
	{name = 'npc_dota_hero_centaur', role = {0, 0, 100, 0, 0}, value = 1},

	{name = 'npc_dota_hero_dark_willow', role = {0, 0, 0, 100, 0}, value = 1},
	{name = 'npc_dota_hero_grimstroke', role = {0, 0, 0, 100, 0}, value = 1},
	{name = 'npc_dota_hero_gyrocopter', role = {0, 0, 0, 100, 0}, value = 1},
	{name = 'npc_dota_hero_zuus', role = {0, 0, 0, 100, 0}, value = 1},
	{name = "npc_dota_hero_snapfire", role = {0, 0, 0, 100, 0}, value = 1},
	{name = 'npc_dota_hero_rubick', role = {0, 0, 0, 100, 0}, value = 1},
	{name = 'npc_dota_hero_bounty_hunter', role = {0, 0, 0, 100, 0}, value = 1},
	{name = 'npc_dota_hero_clinkz', role = {0, 0, 0, 100, 0}, value = 1},
	{name = 'npc_dota_hero_shadow_shaman', role = {0, 0, 0, 100, 0}, value = 1},
	{name = 'npc_dota_hero_keeper_of_the_light', role = {0, 0, 0, 100, 0}, value = 2},

	{name = 'npc_dota_hero_silencer', role = {0, 0, 0, 0, 100}, value = 1},
	{name = 'npc_dota_hero_techies', role = {0, 0, 0, 0, 100}, value = 1},
	{name = 'npc_dota_hero_bane', role = {0, 0, 0, 0, 100}, value = 1},
	{name = 'npc_dota_hero_omniknight', role = {0, 0, 0, 0, 100}, value = 1},
	{name = 'npc_dota_hero_wisp', role = {0, 0, 0, 0, 100}, value = 1},
	{name = 'npc_dota_hero_abaddon', role = {0, 0, 0, 0, 100}, value = 1},
	{name = 'npc_dota_hero_elder_titan', role = {0, 0, 0, 0, 100}, value = 1},
	{name = 'npc_dota_hero_disruptor', role = {0, 0, 0, 0, 100}, value = 1},
	{name = 'npc_dota_hero_pugna', role = {0, 0, 0, 0, 100}, value = 1},
	{name = 'npc_dota_hero_witch_doctor', role = {0, 0, 0, 0, 100}, value = 1},
	{name = 'npc_dota_hero_oracle', role = {0, 0, 0, 0, 100}, value = 1},

	-- Heroes with value = 2
	{name = 'npc_dota_hero_morphling', role = {100, 0, 0, 0, 0}, value = 2},
	{name = 'npc_dota_hero_slark', role = {100, 0, 0, 0, 0}, value = 2},
	{name = 'npc_dota_hero_muerta', role = {100, 0, 0, 0, 0}, value = 2},
	{name = 'npc_dota_hero_storm_spirit', role = {0, 100, 0, 0, 0}, value = 2},
	{name = 'npc_dota_hero_pangolier', role = {0, 100, 0, 0, 0}, value = 2},
	{name = 'npc_dota_hero_meepo', role = {0, 100, 0, 0, 0}, value = 2},

	{name = 'npc_dota_hero_monkey_king', role = {0, 100, 0, 0, 0}, value = 2},
	{name = 'npc_dota_hero_void_spirit', role = {0, 100, 0, 0, 0}, value = 2},

	{name = 'npc_dota_hero_beastmaster', role = {0, 0, 100, 0, 0}, value = 2},
	{name = 'npc_dota_hero_abyssal_underlord', role = {0, 0, 100, 0, 0}, value = 2},
	{name = 'npc_dota_hero_pudge', role = {0, 0, 100, 0, 0}, value = 2},
	{name = 'npc_dota_hero_chaos_knight', role = {0, 0, 100, 0, 0}, value = 2},
	{name = 'npc_dota_hero_dark_seer', role = {0, 0, 100, 0, 0}, value = 2},
	{name = 'npc_dota_hero_slardar', role = {0, 0, 0, 0, 0}, value = 2},

	{name = 'npc_dota_hero_tusk', role = {0, 0, 0, 100, 0}, value = 2},
	{name = 'npc_dota_hero_earthshaker', role = {0, 0, 0, 100, 0}, value = 2},
	{name = 'npc_dota_hero_earth_spirit', role = {0, 0, 0, 100, 0}, value = 2},
	{name = 'npc_dota_hero_nyx_assassin', role = {0, 0, 0, 100, 0}, value = 2},
	{name = 'npc_dota_hero_batrider', role = {0, 0, 0, 100, 0}, value = 2},

	{name = 'npc_dota_hero_furion', role = {0, 0, 0, 0, 100}, value = 2},
	{name = 'npc_dota_hero_jakiro', role = {0, 0, 0, 0, 100}, value = 2},
	{name = 'npc_dota_hero_dazzle', role = {0, 0, 0, 0, 100}, value = 2},
	{name = 'npc_dota_hero_chen', role = {0, 0, 0, 0, 100}, value = 2},
	{name = 'npc_dota_hero_lich', role = {0, 0, 0, 0, 100}, value = 2},


	-- Heroes with value = 3
	{name = 'npc_dota_hero_faceless_void', role = {100, 0, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_sven', role = {100, 0, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_ursa', role = {100, 0, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_terrorblade', role = {100, 0, 0, 0, 0}, value = 3},

	{name = 'npc_dota_hero_arc_warden', role = {0, 100, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_viper', role = {0, 100, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_nevermore', role = {0, 100, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_dragon_knight', role = {0, 100, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_leshrac', role = {0, 100, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_ember_spirit', role = {0, 100, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_invoker', role = {0, 100, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_tiny', role = {0, 100, 0, 0, 0}, value = 3},
	{name = 'npc_dota_hero_primal_beast', role = {0, 100, 0, 0, 0}, value = 3},

	{name = 'npc_dota_hero_tidehunter', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_axe', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_bristleback', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_shredder', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_alchemist', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_legion_commander', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_night_stalker', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_sand_king', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_lycan', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_mars', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_enigma', role = {0, 0, 100, 0, 0}, value = 3},
	{name = 'npc_dota_hero_razor', role = {0, 0, 100, 0, 0}, value = 3},

	{name = 'npc_dota_hero_skywrath_mage', role = {0, 0, 0, 100, 0}, value = 3},
	{name = 'npc_dota_hero_weaver', role = {0, 0, 0, 100, 0}, value = 3},
	{name = 'npc_dota_hero_hoodwink', role = {0, 0, 0, 100, 0}, value = 3},
	{name = 'npc_dota_hero_lion', role = {0, 0, 0, 100, 0}, value = 3},
	{name = 'npc_dota_hero_shadow_demon', role = {0, 0, 0, 100, 0}, value = 3},
	{name = 'npc_dota_hero_rattletrap', role = {0, 0, 0, 100, 0}, value = 3},

	{name = 'npc_dota_hero_undying', role = {0, 0, 0, 0, 100}, value = 3},
	{name = 'npc_dota_hero_warlock', role = {0, 0, 0, 0, 100}, value = 3},
	{name = 'npc_dota_hero_venomancer', role = {0, 0, 0, 0, 100}, value = 3},
	{name = 'npc_dota_hero_ancient_apparition', role = {0, 0, 0, 0, 100}, value = 3},
	{name = 'npc_dota_hero_ringmaster', role = {0, 0, 0, 0, 100}, value = 3},
	{name = 'npc_dota_hero_treant', role = {0, 0, 0, 0, 100}, value = 3},

	-- Heroes with value = 4
	{name = 'npc_dota_hero_antimage', role = {100, 0, 0, 0, 0}, value = 4},
	{name = 'npc_dota_hero_luna', role = {100, 0, 0, 0, 0}, value = 4},
	{name = 'npc_dota_hero_medusa', role = {100, 0, 0, 0, 0}, value = 4},
	{name = 'npc_dota_hero_spectre', role = {100, 0, 0, 0, 0}, value = 4},
	{name = 'npc_dota_hero_phantom_assassin', role = {100, 0, 0, 0, 0}, value = 4},

	{name = 'npc_dota_hero_death_prophet', role = {0, 100, 0, 0, 0}, value = 4},
	{name = 'npc_dota_hero_lina', role = {0, 100, 0, 0, 0}, value = 4},
	{name = 'npc_dota_hero_mirana', role = {0, 100, 0, 0, 0}, value = 4},
	{name = 'npc_dota_hero_vengefulspirit', role = {0, 100, 0, 0, 0}, value = 4},
	{name = 'npc_dota_hero_broodmother', role = {0, 100, 0, 0, 0}, value = 4},
	{name = 'npc_dota_hero_puck', role = {0, 100, 0, 0, 0}, value = 4},

	{name = 'npc_dota_hero_dawnbreaker', role = {0, 0, 100, 0, 0}, value = 4},
	{name = 'npc_dota_hero_doom_bringer', role = {0, 0, 100, 0, 0}, value = 4},
	{name = 'npc_dota_hero_skeleton_king', role = {0, 0, 100, 0, 0}, value = 4},

	{name = 'npc_dota_hero_winter_wyvern', role = {0, 0, 0, 100, 0}, value = 4},
	{name = 'npc_dota_hero_marci', role = {0, 0, 0, 100, 0}, value = 4},

	{name = 'npc_dota_hero_enchantress', role = {0, 0, 0, 0, 100}, value = 4},
	{name = 'npc_dota_hero_phoenix', role = {0, 0, 0, 0, 100}, value = 4},
	{name = 'npc_dota_hero_crystal_maiden', role = {0, 0, 0, 0, 100}, value = 4},

	-- Heroes with value = 5
	{name = 'npc_dota_hero_drow_ranger', role = {100, 0, 0, 0, 0}, value = 5},
	{name = 'npc_dota_hero_naga_siren', role = {100, 0, 0, 0, 0}, value = 5},

	{name = 'npc_dota_hero_queenofpain', role = {0, 100, 0, 0, 0}, value = 5},
	{name = 'npc_dota_hero_windrunner', role = {0, 100, 0, 0, 0}, value = 5},
	{name = 'npc_dota_hero_templar_assassin', role = {0, 100, 0, 0, 0}, value = 5},
}


-- Define the test hero list
local testHeroList = {

}

-- Function to get heroes suitable for a position
local function GetHeroList(pos)
	local sTempList = {}
	for i = 1, #sHeroList do
		if sHeroList[i] ~= nil and sHeroList[i].role[pos] > 0 then
			table.insert(sTempList, sHeroList[i].name)
		end
	end
	return sTempList
end

-- Function to get adjusted pool for a position
local function GetAdjustedPool(pos)
	local sTempList = {}
	local heroList = GetHeroList(pos)
	for i = 1, #heroList do
		for _, hero in pairs(sHeroList) do
			if hero.name == heroList[i] and hero.role[pos] >= RandomInt(0, 100) then
				table.insert(sTempList, hero.name)
			end
		end
	end
	if #sTempList == 0 then
		table.insert(sTempList, heroList[RandomInt(1, #heroList)])
	end
	return sTempList
end

-- Get adjusted pools for each position
local sPos1List = GetAdjustedPool(1)
local sPos2List = GetAdjustedPool(2)
local sPos3List = GetAdjustedPool(3)
local sPos4List = GetAdjustedPool(4)
local sPos5List = GetAdjustedPool(5)

tSelectPoolList = {
	[1] = sPos2List,
	[2] = sPos3List,
	[3] = sPos1List,
	[4] = sPos5List,
	[5] = sPos4List,
}

-- Set lane assignments based on team
if GetTeam() == TEAM_RADIANT then
	tLaneAssignList = {
		[1] = LANE_MID,
		[2] = LANE_TOP,
		[3] = LANE_BOT,
		[4] = LANE_BOT,
		[5] = LANE_TOP,
	}
else
	tLaneAssignList = {
		[1] = LANE_MID,
		[2] = LANE_BOT,
		[3] = LANE_TOP,
		[4] = LANE_TOP,
		[5] = LANE_BOT,
	}
end

-- Adjustments for nDireFirstLaneType
if nDireFirstLaneType == 2 and GetTeam() == TEAM_DIRE then
	tSelectPoolList[1], tSelectPoolList[2] = tSelectPoolList[2], tSelectPoolList[1]
	tLaneAssignList[1], tLaneAssignList[2] = tLaneAssignList[2], tLaneAssignList[1]
end

if nDireFirstLaneType == 3 and GetTeam() == TEAM_DIRE then
	tSelectPoolList[1], tSelectPoolList[3] = tSelectPoolList[3], tSelectPoolList[1]
	tLaneAssignList[1], tLaneAssignList[3] = tLaneAssignList[3], tLaneAssignList[1]
end

-- Helper functions
function X.GetNotRepeatHero(nTable)
	local sHero = nTable[1]
	local maxCount = #nTable
	local nRand = 0
	local bRepeated = false

	for count = 1, maxCount do
		nRand = RandomInt(1, #nTable)
		sHero = nTable[nRand]
		bRepeated = false
		if not X.IsRepeatHero(sHero) then
			break
		else
			table.remove(nTable, nRand)
		end
	end

	return sHero
end

-- Corrected function to prevent duplicate hero picks across both teams
function X.IsRepeatHero(sHero)
	local allPlayerIDs = {}

	-- Get player IDs for both teams
	for _, id in pairs(GetTeamPlayers(TEAM_RADIANT)) do
		table.insert(allPlayerIDs, id)
	end
	for _, id in pairs(GetTeamPlayers(TEAM_DIRE)) do
		table.insert(allPlayerIDs, id)
	end

	-- Check if the hero has already been picked
	for _, id in pairs(allPlayerIDs) do
		if GetSelectedHeroName(id) == sHero then
			return true
		end
	end

	-- Check if the hero is banned
	if (sHero ~= "npc_dota_hero_ringmaster" and IsCMBannedHero(sHero)) or X.IsBanByChat(sHero) then
		return true
	end

	return false
end

function X.GetCurrentTeam(nTeam)
	local nHeroList = {}
	for i, id in pairs(GetTeamPlayers(nTeam)) do
		local hName = GetSelectedHeroName(id)
		if hName ~= nil and hName ~= '' then
			table.insert(nHeroList, {name = hName, pos = i})
		end
	end
	return nHeroList
end

-- Function to get team value
local function GetTeamValue(team)
	local totalValue = 0
	for _, hero in pairs(team) do
		for _, h in pairs(sHeroList) do
			if hero.name == h.name then
				totalValue = totalValue + h.value
				break
			end
		end
	end
	return totalValue / (#team > 0 and #team or 1)
end

-- Corrected function to select hero based on your specified steps
local function SelectHeroForPosition(pos, nTeam, nEnmTeam)
	local pool = tSelectPoolList[pos]

	-- Step 1: Get suitable test heroes for the position
	local testHeroesInPool = {}
	for _, heroName in ipairs(pool) do
		for _, testHeroName in ipairs(testHeroList) do
			if heroName == testHeroName then
				table.insert(testHeroesInPool, heroName)
				break
			end
		end
	end

	local selectionPool = {}
	if #testHeroesInPool > 0 then
		-- If test heroes are suitable, use them
		selectionPool = testHeroesInPool
	else
		-- Step 2: Randomize the selection among all suitable heroes for the position
		selectionPool = pool
	end

	local selectedHero

	-- If no heroes have been selected yet, randomize the selection
	if #nTeam == 0 then
		-- Randomly select a hero from selectionPool that hasn't been picked yet
		selectedHero = X.GetNotRepeatHero(selectionPool)
	else
		-- Step 3: Calculate team values and select a hero from selectionPool
		local potentialHeroes = {}
		local minDifference = math.huge
		local currentTeamValue = GetTeamValue(nTeam)
		local currentEnemyValue = GetTeamValue(nEnmTeam)

		for _, heroName in pairs(selectionPool) do
			if not X.IsRepeatHero(heroName) then
				local heroValue = 0
				for _, hero in pairs(sHeroList) do
					if hero.name == heroName then
						heroValue = hero.value
						break
					end
				end

				local newTeamValue = (currentTeamValue * #nTeam + heroValue) / (#nTeam + 1)
				local valueDifference = math.abs(newTeamValue - currentEnemyValue)

				if valueDifference < minDifference then
					minDifference = valueDifference
					potentialHeroes = {heroName}
				elseif valueDifference == minDifference then
					table.insert(potentialHeroes, heroName)
				end
			end
		end

		if #potentialHeroes > 0 then
			selectedHero = potentialHeroes[RandomInt(1, #potentialHeroes)]
		else
			-- If all heroes are repeats or banned, pick any from selectionPool
			selectedHero = X.GetNotRepeatHero(selectionPool)
		end
	end

	return selectedHero
end

-- Additional helper functions
function X.IsBanByChat(sHero)
	for i = 1, #sBanList do
		if sBanList[i] ~= nil and string.find(sHero, sBanList[i]) then
			return true
		end
	end
	return false
end

function X.SetChatHeroBan(sChatText)
	sBanList[#sBanList + 1] = string.lower(sChatText)
end

function X.IsHumanNotReady(nTeam)
	if GameTime() > 20 or bLineupReserve then
		return false
	end

	local humanCount, readyCount = 0, 0
	local nIDs = GetTeamPlayers(nTeam)
	for i, id in pairs(nIDs) do
		if not IsPlayerBot(id) then
			humanCount = humanCount + 1
			if GetSelectedHeroName(id) ~= "" then
				readyCount = readyCount + 1
			end
		end
	end

	if readyCount >= humanCount then
		return false
	end

	return true
end

function Think()
	if GetGameState() == GAME_STATE_HERO_SELECTION then
		InstallChatCallback(function(tChat)
			X.SetChatHeroBan(tChat.string)
		end)
	end

	if (GameTime() < 3.0 and not bLineupReserve)
			or fLastSlectTime > GameTime() - fLastRand
			or X.IsHumanNotReady(GetTeam())
			or X.IsHumanNotReady(GetOpposingTeam()) then
		if GetGameMode() ~= 23 then
			return
		end
	end

	-- Initialize IDs
	local nIDs = GetTeamPlayers(GetTeam())

	if nDelayTime == nil then
		nDelayTime = GameTime()
		fLastRand = RandomInt(12, 34) / 10
	end
	if nDelayTime ~= nil and nDelayTime > GameTime() - fLastRand then
		return
	end

	local nOwnTeam = X.GetCurrentTeam(GetTeam())
	local nEnmTeam = X.GetCurrentTeam(GetOpposingTeam())

	-- Loop through each bot player to select heroes
	for i, id in pairs(nIDs) do
		if IsPlayerBot(id) and GetSelectedHeroName(id) == "" then
			-- Use the new selection function for each position
			local sSelectHero = SelectHeroForPosition(i, nOwnTeam, nEnmTeam)
			SelectHero(id, sSelectHero)
			table.insert(nOwnTeam, {name = sSelectHero, pos = i})
			fLastSlectTime = GameTime()
			fLastRand = RandomInt(8, 28) / 10
			break -- Break to allow time between selections
		end
	end
end

-- Rest of your existing code
function GetBotNames()
	return N.GetBotNames()
end

local bPvNLaneAssignDone = false
function UpdateLaneAssignments()
	if DotaTime() > 0
			and nHumanCount == 0
			and Role.IsPvNMode()
			and not bLaneAssignActive
			and not bPvNLaneAssignDone then
		if RandomInt(1, 8) > 4 then
			tLaneAssignList[4] = LANE_MID
		else
			tLaneAssignList[5] = LANE_MID
		end
		bPvNLaneAssignDone = true
	end

	return tLaneAssignList
end
