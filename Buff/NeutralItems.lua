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
    --[[Trusty Shovel]]         "item_trusty_shovel",
    -- --[[Arcane Ring]]           "item_arcane_ring",
    -- --[[Fairy's Trinket]]       "item_mysterious_hat",
    --[[Pig Pole]]              "item_unstable_wand",
    -- --[[Safety Bubble]]         "item_safety_bubble",
    -- --[[Seeds of Serenity]]     "item_seeds_of_serenity",
    -- --[[Lance of Pursuit]]      "item_lance_of_pursuit",
    --[[Occult Bracelet]]       "item_occult_bracelet",
    -- --[[Duelist Gloves]]        "item_duelist_gloves",
    -- --[[Broom Handle]]          "item_broom_handle",
    -- --[[Royal Jelly]]           "item_royal_jelly",
    -- --[[Faded Broach]]          "item_faded_broach",
    --[[Spark Of Courage]]      "item_spark_of_courage",
    -- --[[Ironwood Tree]]         "item_ironwood_tree",
    --[[Mana Draught]]          "item_mana_draught",
    --[[Polliwog Charm]]        "item_polliwog_charm",
    --[[Ripper's Lash]]         "item_rippers_lash",
    --[[Orb of Destruction]]    "item_orb_of_destruction",
}

local Tier2NeutralItems = {
    -- --[[Dragon Scale]]          "item_dragon_scale",
    -- --[[Whisper of the Dread]]  "item_whisper_of_the_dread",
    -- --[[Pupil's Gift]]          "item_pupils_gift",
    -- --[[Grove Bow]]             "item_grove_bow",
    -- --[[Philosopher's Stone]]   "item_philosophers_stone",
    -- --[[Bullwhip]]              "item_bullwhip",
    -- --[[Orb of Destruction]]    "item_orb_of_destruction",
    -- --[[Specialist's Array]]    "item_specialists_array",
    -- --[[Eye of the Vizier]]     "item_eye_of_the_vizier",
    -- --[[Vampire Fangs]]         "item_vampire_fangs",
    --[[Gossamer's Cape]]       "item_gossamer_cape",
    -- --[[Light Collector]]       "item_light_collector",
    --[[Iron Talon]]            "item_iron_talon",
    --[[Essence Ring]]          "item_essence_ring",
    --[[Searing Signet]]        "item_searing_signet",
    --[[Brigand's Balde]]       "item_misericorde",
    --[[Tumbler's Toy]]         "item_pogo_stick",
}

local Tier3NeutralItems = {
    -- --[[Defiant Shell]]         "item_defiant_shell",
    -- --[[Paladin Sword]]         "item_paladin_sword",
    --[[Nemesis Curse]]         "item_nemesis_curse",
    -- --[[Vindicator's Axe]]      "item_vindicators_axe",
    -- --[[Dandelion Amulet]]      "item_dandelion_amulet",
    -- --[[Craggy Coat]]           "item_craggy_coat",
    -- --[[Enchanted Quiver]]      "item_enchanted_quiver",
    -- --[[Elven Tunic]]           "item_elven_tunic",
    -- --[[Cloack of Flames]]      "item_cloak_of_flames",
    -- --[[Ceremonial Robe]]       "item_ceremonial_robe",
    -- --[[Psychic Headband]]      "item_psychic_headband",
    -- --[[Doubloon]]              "item_doubloon",
    -- --[[Vambrace]]              "item_vambrace",
    --[[Whisper of the Dread]]  "item_whisper_of_the_dread",
    --[[Serrrated Shiv]]        "item_serrated_shiv",
    --[[Gale Guard]]            "item_gale_guard",
    --[[Gunpowder Gauntlet]]    "item_gunpowder_gauntlets",
    --[[Ninja Gear]]            "item_ninja_gear",
}

local Tier4NeutralItems = {
    -- --[[Timeless Relic]]        "item_timeless_relic",
    -- --[[Ascetic Cap]]           "item_ascetic_cap",
    -- --[[Aviana's Feather]]      "item_avianas_feather",
    -- --[[Ninja Gear]]            "item_ninja_gear",
    -- --[[Telescope]]             "item_spy_gadget",
    -- --[[Trickster Cloak]]       "item_trickster_cloak",
    -- --[[Stormcrafter]]          "item_stormcrafter",
    -- --[[Ancient Guardian]]      "item_ancient_guardian",
    -- --[[Havoc Hammer]]          "item_havoc_hammer",
    --[[Mind Breaker]]          "item_mind_breaker",
    -- --[[Martyr's Plate]]        "item_martyrs_plate",
    -- --[[Rattlecage]]            "item_rattlecage",
    --[[Ogre Seal Totem]]       "item_ogre_seal_totem",
    --[[Crippling Crossbow]]    "item_crippling_crossbow",
    --[[Magnifying Monocle]]    "item_magnifying_monocle",
    --[[Ceremonial Robe]]       "item_ceremonial_robe",
    --[[Pyrrhic Cloak]]         "item_pyrrhic_cloak",
}

local Tier5NeutralItems = {
    -- --[[Force Boots]]           "item_force_boots",
    --[[Stygian Desolator]]     "item_desolator_2",
    -- --[[Seer Stone]]            "item_seer_stone",
    -- --[[Mirror Shield]]         "item_mirror_shield",
    -- --[[Apex]]                  "item_apex",
    --[[Book of the Dead]]      "item_demonicon",
    -- --[[Arcanist's Armor]]      "item_force_field",
    --[[Pirate Hat]]            "item_pirate_hat",
    -- --[[Giant's Ring]]          "item_giants_ring",
    -- --[[Unwavering Condition]]  "item_unwavering_condition",
    -- --[[Book of Shadows]]       "item_book_of_shadows",
    --[[Magic Lamp]]            "item_panic_button",
    --[[Fallen Sky]]            "item_fallen_sky",
    --[[Minotaur Horn]]         "item_minotaur_horn",
    --[[Spider Legs]]           "item_spider_legs",
    --[[Unrelenting Eye]]       "item_unrelenting_eye",
}

-- Enhancements
local TierEnhancements = {
    [1] = {
        "item_enhancement_alert",
        "item_enhancement_brawny",
        "item_enhancement_mystical",
        "item_enhancement_quickened",
        "item_enhancement_tough",
    },
    [2] = {
        "item_enhancement_alert",
        "item_enhancement_brawny",
        "item_enhancement_mystical",
        "item_enhancement_quickened",
        "item_enhancement_tough",
        "item_enhancement_vast",
        "item_enhancement_greedy",
        "item_enhancement_keen_eyed",
        "item_enhancement_vampiric",
    },
    [3] = {
        "item_enhancement_alert",
        "item_enhancement_brawny",
        "item_enhancement_mystical",
        "item_enhancement_quickened",
        "item_enhancement_tough",
        "item_enhancement_vast",
        "item_enhancement_greedy",
        "item_enhancement_keen_eyed",
        "item_enhancement_vampiric",
    },
    [4] = {
        "item_enhancement_alert",
        "item_enhancement_brawny",
        "item_enhancement_mystical",
        "item_enhancement_quickened",
        "item_enhancement_tough",
        "item_enhancement_vampiric",
        "item_enhancement_timeless",
        "item_enhancement_titanic",
        "item_enhancement_crude",
    },
    [5] = {
        "item_enhancement_timeless",
        "item_enhancement_titanic",
        "item_enhancement_crude",
        "item_enhancement_feverish",
        "item_enhancement_fleetfooted",
        "item_enhancement_audacious",
        "item_enhancement_evolved",
        "item_enhancement_boundless",
        "item_enhancement_wise",
    }
}

-- Placeholder Hero Gear Paths
local HeroGearPaths = {
 --[[   ["npc_dota_hero_queenofpain"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_naga_siren"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_windrunner"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_templar_assassin"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_drow_ranger"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_marci"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_mirana"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_vengefulspirit"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_luna"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_antimage"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_phantom_assassin"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_lina"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_death_prophet"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_crystal_maiden"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_medusa"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_winter_wyvern"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_doom_bringer"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_primal_beast"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_skeleton_king"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_spectre"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_puck"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_broodmother"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_dawnbreaker"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_night_stalker"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_legion_commander"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_tiny"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_dragon_knight"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_razor"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_faceless_void"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_viper"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_lion"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_terrorblade"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_nevermore"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_leshrac"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_muerta"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_shredder"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_phoenix"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_invoker"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    },
    ["npc_dota_hero_hoodwink"] = {
        [1] = { item = "placeholder_item_1", enhancement = "placeholder_enhancement_1" },
        [2] = { item = "placeholder_item_2", enhancement = "placeholder_enhancement_2" },
        [3] = { item = "placeholder_item_3", enhancement = "placeholder_enhancement_3" },
        [4] = { item = "placeholder_item_4", enhancement = "placeholder_enhancement_4" },
        [5] = { item = "placeholder_item_5", enhancement = "placeholder_enhancement_5" }
    } --]]
}

-- Updated GiveNeutralItems function to accept a hero list instead of separate teams
function NeutralItems.GiveNeutralItems(hHeroList)
    local isTurboMode = Helper.IsTurboMode()

    -- Tier 1 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 2.5 * 60 or Helper.DotaTime() >= 3 * 60)
    and not isTierOneDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 1 Neutral Items...', 0, 0)

        for _, h in pairs(hHeroList) do
            local sItemName = Tier1NeutralItems[RandomInt(1, #Tier1NeutralItems)]
            if sItemName ~= '' then
                NeutralItems.GiveItem(sItemName, h, isTierOneDone, 1)
            end
        end

        isTierOneDone = true
    end

    -- Tier 2 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 8.5 * 60 or Helper.DotaTime() >= 9 * 60)
            and not isTierTwoDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 2 Neutral Items...', 0, 0)

        for _, h in pairs(hHeroList) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            local sItemName = Tier2NeutralItems[RandomInt(1, #Tier2NeutralItems)]
            NeutralItems.GiveItem(sItemName, h, isTierTwoDone, 2)
        end

        isTierTwoDone = true
    end

    -- Tier 3 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 13.5 * 60 or Helper.DotaTime() >= 15 * 60)
            and not isTierThreeDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 3 Neutral Items...', 0, 0)

        for _, h in pairs(hHeroList) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            local sItemName = Tier3NeutralItems[RandomInt(1, #Tier3NeutralItems)]
            NeutralItems.GiveItem(sItemName, h, isTierThreeDone, 3)
        end

        isTierThreeDone = true
    end

    -- Tier 4 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 18.5 * 60 or Helper.DotaTime() >= 22 * 60)
            and not isTierFourDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 4 Neutral Items...', 0, 0)

        for _, h in pairs(hHeroList) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            local sItemName = Tier4NeutralItems[RandomInt(1, #Tier4NeutralItems)]
            NeutralItems.GiveItem(sItemName, h, isTierFourDone, 4)
        end

        isTierFourDone = true
    end

    -- Tier 5 Neutral Items
    if (isTurboMode and Helper.DotaTime() >= 30 * 60 or Helper.DotaTime() >= 30 * 60)
            and not isTierFiveDone
    then
        GameRules:SendCustomMessage('Bots receiving Tier 5 Neutral Items...', 0, 0)

        for _, h in pairs(hHeroList) do
            NeutralItems.RemoveOldItem(h) -- Remove the old item before giving a new one
            local sItemName = Tier5NeutralItems[RandomInt(1, #Tier5NeutralItems)]
            NeutralItems.GiveItem(sItemName, h, isTierFiveDone, 5)
        end

        isTierFiveDone = true
    end
end

-- Updated AssignItemBasedOnPathOrRandom function to include enhancements
function NeutralItems.AssignItemBasedOnPathOrRandom(itemList, hero, tier, isTierDone)
    local heroName = hero:GetUnitName()

    -- Check if the hero has a specific gear path
    if HeroGearPaths[heroName] and HeroGearPaths[heroName][tier] then
        -- Give the hero their specific item for the given tier
        local gear = HeroGearPaths[heroName][tier]
        NeutralItems.GiveItem(gear.item, hero, isTierDone, tier)

        -- Give the enhancement if defined
        if gear.enhancement then
            local enhancementItem = CreateItem(gear.enhancement, hero, hero)
            enhancementItem:SetPurchaseTime(0)
            hero:AddItem(enhancementItem)
        end
    else
        -- If no specific gear path is defined, give a random item from the tier
        NeutralItems.GiveItem(itemList[RandomInt(1, #itemList)], hero, isTierDone, tier)
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

-- Updated GiveItem function to handle new item slots and enhancements
function NeutralItems.GiveItem(itemName, hero, isTierDone, tier)
    if hero:HasRoomForItem(itemName, true, true) then
        local item = CreateItem(itemName, hero, hero)
        item:SetPurchaseTime(0)

        -- Remove old enhancement if it exists
        local itemEnhancement = hero:GetItemInSlot(17) -- Assuming 17 is the enhancement slot
        if itemEnhancement then hero:RemoveItem(itemEnhancement) end

        -- Handle neutral item logic
        if NeutralItems.HasNeutralItem(hero) and isTierDone then
            hero:RemoveItem(hero:GetItemInSlot(16)) -- Assuming 16 is the neutral item slot
            hero:AddItem(item)
        else
            hero:AddItem(item)
        end

        -- Give enhancement
        local eList = TierEnhancements[tier]
        if eList then
            local e = eList[RandomInt(1, #eList)]
            if e ~= nil then
                local enhancementItem = CreateItem(e, hero, hero)
                enhancementItem:SetPurchaseTime(0)
                hero:AddItem(enhancementItem)
            end
        end
    end
end

function NeutralItems.HasNeutralItem(hero)
    if not hero then
        return false
    end

    local item = hero:GetItemInSlot(16)
    if item then
        return true
    end

    return false
end

-- Function to remove the old neutral item from the hero
function NeutralItems.RemoveOldItem(hero)
    if NeutralItems.HasNeutralItem(hero) then
        hero:RemoveItem(hero:GetItemInSlot(16))
    end
end

return NeutralItems