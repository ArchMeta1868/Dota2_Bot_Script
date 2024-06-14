local RI = require(GetScriptDirectory()..'/FunLib/bot_builds/util_role_item')

local X = {}

local sUtility = {"item_heavens_halberd", "item_lotus_orb", "item_pipe"}
local sUtilityItem = RI.GetBestUtilityItem(sUtility)

X.TalentBuild = {
    ['pos_1'] = {},
    ['pos_2'] = {
        [1] = {
            ['t25'] = {0, 10},
            ['t20'] = {10, 0},
            ['t15'] = {10, 0},
            ['t10'] = {0, 10},
        }
    },
    ['pos_3'] = {
        [1] = {
            ['t25'] = {0, 10},
            ['t20'] = {10, 0},
            ['t15'] = {10, 0},
            ['t10'] = {10, 0},
        }
    },
    ['pos_4'] = {},
    ['pos_5'] = {},
}

X.AbilityBuild = {
    ['pos_1'] = {},
    ['pos_2'] = {
        [1] = {1,3,1,2,1,6,1,3,2,3,6,2,3,2,6},
    },
    ['pos_3'] = {
        [1] = {1,3,1,3,1,6,1,2,3,3,6,2,2,2,6},
    },
    ['pos_4'] = {},
    ['pos_5'] = {},
}

X.BuyList = {
    ['pos_1'] = {},
    ['pos_2'] = {
        [1] = {
            "item_tango",
            "item_faerie_fire",
            "item_clarity",
            "item_double_branches",
            "item_circlet",
            "item_slippers",
        
            "item_bottle",
            "item_wraith_band",
            "item_magic_wand",
            "item_power_treads",
            "item_mage_slayer",--
            "item_dragon_lance",
            "item_manta",--
            "item_hurricane_pike",--
            "item_aghanims_shard",
            "item_kaya_and_sange",--
            "item_travel_boots",
            "item_shivas_guard",--
            "item_travel_boots_2",--
            "item_ultimate_scepter_2",
            "item_moon_shard",
        }
    },
    ['pos_3'] = {
        [1] = {
            "item_tango",
            "item_double_branches",
            "item_enchanted_mango",
            "item_double_circlet",
        
            "item_double_wraith_band",
            "item_boots",
            "item_magic_wand",
            "item_power_treads",
            "item_mage_slayer",--
            "item_dragon_lance",
            sUtilityItem,--
            "item_black_king_bar",--
            "item_aghanims_shard",
            "item_hurricane_pike",--
            "item_sheepstick",--
            "item_travel_boots_2",--
            "item_ultimate_scepter_2",
            "item_moon_shard",
        }
    },
    ['pos_4'] = {},
    ['pos_5'] = {},
}

X.SellList = {
    ['pos_1'] = {},
    ['pos_2'] = {
        [1] = {
            "item_bottle",
            "item_wraith_band",
            "item_magic_wand",
        }
    },
    ['pos_3'] = {
        [1] = {
            "item_wraith_band",
            "item_magic_wand",
        }
    },
    ['pos_4'] = {},
    ['pos_5'] = {},
}

return X