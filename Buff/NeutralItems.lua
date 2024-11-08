if NeutralItems == nil
then
    NeutralItems = {}
end

local isTierOneDone   = false
local isTierTwoDone   = false
local isTierThreeDone = false
local isTierFourDone  = false
local isTierFiveDone  = false

local Tier1NeutralItems = {

    "item_spark_of_courage",
    "item_pogo_stick",
    "item_keen_optic",
    "item_trusty_shovel",
    "item_arcane_ring",
    "item_possessed_mask",
    "item_unstable_wand",
    "item_seeds_of_serenity",
    "item_lance_of_pursuit",
    "item_occult_bracelet",
    "item_duelist_gloves",
    "item_ocean_heart",
    "item_broom_handle",
    "item_chipped_vest",
    "item_ironwood_tree",
    "item_stormcrafter",
}

local Tier2NeutralItems = {

    "item_light_collector",
    "item_specialists_array",
    "item_imp_claw",
    "item_whisper_of_the_dread",
    "item_pupils_gift",
    "item_philosophers_stone",
    "item_rattlecage",
    "item_paintball",
    "item_quicksilver_amulet",
    "item_dagger_of_ristul",
    "item_gossamer_cape",
}

local Tier3NeutralItems = {

    "item_titan_sliver",
    "item_nemesis_curse",
    "item_vindicators_axe",
    "item_enchanted_quiver",
    "item_vambrace",
    "item_black_powder_bag",
    "item_spider_legs",
    "item_dandelion_amulet",
    "item_craggy_coat",
    "item_doubloon",
    "item_cloak_of_flames",
    "item_ceremonial_robe",
    "item_psychic_headband",
}

local Tier4NeutralItems = {

    "item_princes_knife",
    "item_trickster_cloak",
    "item_spell_prism",
    "item_ascetic_cap",
    "item_havoc_hammer",
    "item_heavy_blade",
    "item_ninja_gear",
    "item_illusionsts_cape",
    "item_the_leveller",
    "item_spy_gadget",

    "item_penta_edged_sword",
    "item_ancient_guardian",
}

local Tier5NeutralItems = {

    "item_pirate_hat",
    "item_panic_button",
    "item_giants_ring",
    "item_force_boots",
    "item_seer_stone",
    "item_apex",
    "item_demonicon",
    "item_vengeances_shadow",
    "item_book_of_shadows",
}

local HeroGearPaths = {
    ["npc_dota_hero_queenofpain"] = {
        [1] = "item_safety_bubble",
        [2] = "item_bullwhip",
        [3] = "item_vampire_fangs",
        [4] = "item_avianas_feather",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_naga_siren"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_mind_breaker",
        [5] = "item_paladin_sword"
    },
    ["npc_dota_hero_windrunner"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_grove_bow",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_templar_assassin"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_grove_bow",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_drow_ranger"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_avianas_feather",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_marci"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_avianas_feather",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_mirana"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_avianas_feather",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_vengefulspirit"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_avianas_feather",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_antimage"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_avianas_feather",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_phantom_assassin"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_mind_breaker",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_luna"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_avianas_feather",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_lina"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_avianas_feather",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_death_prophet"] = {
        [1] = "item_safety_bubble",
        [2] = "item_essence_ring",
        [3] = "item_vampire_fangs",
        [4] = "item_avianas_feather",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_crystal_maiden"] = {
        [1] = "item_safety_bubble",
        [2] = "item_eye_of_the_vizier",
        [3] = "item_mysterious_hat",
        [4] = "item_timeless_relic",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_winter_wyvern"] = {
        [1] = "item_safety_bubble",
        [2] = "item_misericorde",
        [3] = "item_vampire_fangs",
        [4] = "item_grove_bow",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_medusa"] = {
        [1] = "item_faded_broach",
        [2] = "item_misericorde",
        [3] = "item_elven_tunic",
        [4] = "item_avianas_feather",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_doom_bringer"] = {
        [1] = "item_faded_broach",
        [2] = "item_martyrs_plate",
        [3] = "item_quickening_charm",
        [4] = "item_timeless_relic",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_primal_beast"] = {
        [1] = "item_faded_broach",
        [2] = "item_martyrs_plate",
        [3] = "item_defiant_shell",
        [4] = "item_force_field",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_skeleton_king"] = {
        [1] = "item_safety_bubble",
        [2] = "item_orb_of_destruction",
        [3] = "item_defiant_shell",
        [4] = "item_mind_breaker",
        [5] = "item_fallen_sky"
    },
    ["npc_dota_hero_spectre"] = {
        [1] = "item_safety_bubble",
        [2] = "item_dragon_scale",
        [3] = "item_defiant_shell",
        [4] = "item_force_field",
        [5] = "item_mirror_shield"
    },
    ["npc_dota_hero_puck"] = {
        [1] = "item_safety_bubble",
        [2] = "item_dragon_scale",
        [3] = "item_mysterious_hat",
        [4] = "item_timeless_relic",
        [5] = "item_mirror_shield"
    },
    ["npc_dota_hero_broodmother"] = {
        [1] = "item_spark_of_courage",
        [2] = "item_orb_of_destruction",
        [3] = "item_vampire_fangs",
        [4] = "item_mind_breaker",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_dawnbreaker"] = {
        [1] = "item_spark_of_courage",
        [2] = "item_dragon_scale",
        [3] = "item_vampire_fangs",
        [4] = "item_mind_breaker",
        [5] = "item_fallen_sky"
    },
    ["npc_dota_hero_viper"] = {
        [1] = "item_pogo_stick",
        [2] = "item_specialists_array",
        [3] = "item_nemesis_curse",
        [4] = "item_princes_knife",
        [5] = "item_panic_button"
    },
    ["npc_dota_hero_night_stalker"] = {
        [1] = "item_spark_of_courage",
        [2] = "item_orb_of_destruction",
        [3] = "item_vampire_fangs",
        [4] = "item_mind_breaker",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_dragon_knight"] = {
        [1] = "item_spark_of_courage",
        [2] = "item_orb_of_destruction",
        [3] = "item_titan_sliver",
        [4] = "item_force_field",
        [5] = "item_pirate_hat"
    },
    ["npc_dota_hero_razor"] = {
        [1] = "item_safety_bubble",
        [2] = "item_light_collector",
        [3] = "item_vampire_fangs",
        [4] = "item_force_field",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_faceless_void"] = {
        [1] = "item_spark_of_courage",
        [2] = "item_imp_claw",
        [3] = "item_vindicators_axe",
        [4] = "item_heavy_blade",
        [5] = "item_mirror_shield"
    },
    ["npc_dota_hero_tiny"] = {
        [1] = "item_keen_optic",
        [2] = "item_light_collector",
        [3] = "item_enchanted_quiver",
        [4] = "item_havoc_hammer",
        [5] = "item_giants_ring"
    },
    ["npc_dota_hero_legion_commander"] = {
        [1] = "item_spark_of_courage",
        [2] = "item_orb_of_destruction",
        [3] = "item_titan_sliver",
        [4] = "item_force_field",
        [5] = "item_ex_machina"
    },
    ["npc_dota_hero_terrorblade"] = {
        [1] = "item_spark_of_courage",
        [2] = "item_imp_claw",
        [3] = "item_vindicators_axe",
        [4] = "item_ninja_gear",
        [5] = "item_force_boots"
    },
    ["npc_dota_hero_nevermore"] = {
        [1] = "item_spark_of_courage",
        [2] = "item_specialists_array",
        [3] = "item_vindicators_axe",
        [4] = "item_ninja_gear",
        [5] = "item_fallen_sky"
    },
    ["npc_dota_hero_leshrac"] = {
        [1] = "item_ocean_heart",
        [2] = "item_light_collector",
        [3] = "item_cloak_of_flames",
        [4] = "item_spell_prism",
        [5] = "item_fallen_sky"
    },
    ["npc_dota_hero_lion"] = {
        [1] = "item_keen_optic",
        [2] = "item_paintball",
        [3] = "item_spider_legs",
        [4] = "item_spell_prism",
        [5] = "item_seer_stone"
    },
    ["npc_dota_hero_muerta"] = {
        [1] = "item_spark_of_courage",
        [2] = "item_imp_claw",
        [3] = "item_enchanted_quiver",
        [4] = "item_grove_bow",
        [5] = "item_mirror_shield"
    },
    ["npc_dota_hero_shredder"] = {
        [1] = "item_stormcrafter",
        [2] = "item_light_collector",
        [3] = "item_dandelion_amulet",
        [4] = "item_havoc_hammer",
        [5] = "item_fallen_sky"
    },
    ["npc_dota_hero_phoenix"] = {
        [1] = "item_stormcrafter",
        [2] = "item_light_collector",
        [3] = "item_craggy_coat",
        [4] = "item_havoc_hammer",
        [5] = "item_mirror_shield"
    },
    ["npc_dota_hero_invoker"] = {
        [1] = "item_lance_of_pursuit",
        [2] = "item_specialists_array",
        [3] = "item_enchanted_quiver",
        [4] = "item_grove_bow",
        [5] = "item_mirror_shield"
    },
    ["npc_dota_hero_hoodwink"] = {
        [1] = "item_spark_of_courage",
        [2] = "item_imp_claw",
        [3] = "item_enchanted_quiver",
        [4] = "item_mind_breaker",
        [5] = "item_desolator_2"
    }

    -- Add more heroes here with their specific gear paths as needed
}

function NeutralItems.GiveNeutralItems(TeamRadiant, TeamDire)
    local isTurboMode = Helper.IsTurboMode()

    -- Tier 1 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 3.5 * 60 or Helper.DotaTime() >= 7 * 60)
            and not isTierOneDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 1 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.AssignItemBasedOnPathOrRandom(Tier1NeutralItems, h, 1, isTierOneDone)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.AssignItemBasedOnPathOrRandom(Tier1NeutralItems, h, 1, isTierOneDone)
        end

        isTierOneDone = true
    end

    -- Tier 2 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 8.5 * 60 or Helper.DotaTime() >= 12 * 60)
            and not isTierTwoDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 2 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            NeutralItems.AssignItemBasedOnPathOrRandom(Tier2NeutralItems, h, 2, isTierTwoDone)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            NeutralItems.AssignItemBasedOnPathOrRandom(Tier2NeutralItems, h, 2, isTierTwoDone)
        end

        isTierTwoDone = true
    end

    -- Tier 3 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 13.5 * 60 or Helper.DotaTime() >= 20 * 60)
            and not isTierThreeDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 3 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            NeutralItems.AssignItemBasedOnPathOrRandom(Tier3NeutralItems, h, 3, isTierThreeDone)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            NeutralItems.AssignItemBasedOnPathOrRandom(Tier3NeutralItems, h, 3, isTierThreeDone)
        end

        isTierThreeDone = true
    end

    -- Tier 4 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 18.5 * 60 or Helper.DotaTime() >= 30 * 60)
            and not isTierFourDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 4 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            NeutralItems.AssignItemBasedOnPathOrRandom(Tier4NeutralItems, h, 4, isTierFourDone)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            NeutralItems.AssignItemBasedOnPathOrRandom(Tier4NeutralItems, h, 4, isTierFourDone)
        end

        isTierFourDone = true
    end

    -- Tier 5 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 30 * 60 or Helper.DotaTime() >= 40 * 60)
            and not isTierFiveDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 5 Neutral Items...', 0, 0)

        for _, h in pairs(TeamRadiant) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            NeutralItems.AssignItemBasedOnPathOrRandom(Tier5NeutralItems, h, 5, isTierFiveDone)
        end

        for _, h in pairs(TeamDire) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            NeutralItems.AssignItemBasedOnPathOrRandom(Tier5NeutralItems, h, 5, isTierFiveDone)
        end

        isTierFiveDone = true
    end
end

-- Function to assign an item based on hero-specific gear path or use a random item if no path is defined
function NeutralItems.AssignItemBasedOnPathOrRandom(itemList, hero, tier, isTierDone)
    local heroName = hero:GetUnitName()

    -- Check if the hero has a specific gear path
    if HeroGearPaths[heroName] and HeroGearPaths[heroName][tier] then
        -- Give the hero their specific item for the given tier
        NeutralItems.GiveItem(HeroGearPaths[heroName][tier], hero, isTierDone)
    else
        -- If no specific gear path is defined, give a random item from the tier
        NeutralItems.GiveItem(itemList[RandomInt(1, #itemList)], hero, isTierDone)
    end
end

-- Utility function to get the item list for the given tier
function GetTierItemList(tier)
    if tier == 1 then
        return Tier1NeutralItems
    elseif tier == 2 then
        return Tier2NeutralItems
    elseif tier == 3 then
        return Tier3NeutralItems
    elseif tier == 4 then
        return Tier4NeutralItems
    elseif tier == 5 then
        return Tier5NeutralItems
    end
end

-- Existing GiveItem and HasNeutralItem functions remain unchanged
function NeutralItems.GiveItem(itemName, hero, isTierDone)
    if hero:HasRoomForItem(itemName, true, true) then
        local item = CreateItem(itemName, hero, hero)
        item:SetPurchaseTime(0)

        if NeutralItems.HasNeutralItem(hero) and isTierDone then
            hero:RemoveItem(hero:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT))
            hero:AddItem(item)
        else
            hero:AddItem(item)
        end
    end
end

function NeutralItems.HasNeutralItem(hero)
    if not hero then
        return false
    end

    local item = hero:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT)
    if item then
        return true
    end

    return false
end

-- Function to remove the old neutral item from the hero
function NeutralItems.RemoveOldItem(hero)
    if NeutralItems.HasNeutralItem(hero) then
        hero:RemoveItem(hero:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT))
    end
end

return NeutralItems
