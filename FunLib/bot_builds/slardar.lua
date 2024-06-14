local RI = require(GetScriptDirectory()..'/FunLib/bot_builds/util_role_item')

local X = {}

local sUtility = {"item_crimson_guard", "item_pipe", "item_heavens_halberd"}
local sUtilityItem = RI.GetBestUtilityItem(sUtility)

X.TalentBuild = {
    ['pos_1'] = {},
    ['pos_2'] = {
        [1] = {
            ['t25'] = {10, 0},
            ['t20'] = {0, 10},
            ['t15'] = {10, 0},
            ['t10'] = {0, 10},
        }
    },
    ['pos_3'] = {
        [1] = {
            ['t25'] = {0, 10},
            ['t20'] = {0, 10},
            ['t15'] = {0, 10},
            ['t10'] = {0, 10},
        }
    },
    ['pos_4'] = {},
    ['pos_5'] = {},
}

X.AbilityBuild = {
    ['pos_1'] = {},
    ['pos_2'] = {
        [1] = {2,3,1,2,2,6,3,3,3,1,6,1,1,2,6},
    },
    ['pos_3'] = {
        [1] = {2,3,3,1,3,6,3,1,1,1,6,2,2,2,6},
    },
    ['pos_4'] = {},
    ['pos_5'] = {},
}

X.BuyList = {
    ['pos_1'] = {},
    ['pos_2'] = {
        [1] = {
            "item_tango",
            "item_quelling_blade",
            "item_double_branches",
            "item_faerie_fire",
            "item_circlet",
        
            "item_bottle",
            "item_bracer",
            "item_boots",
            "item_magic_wand",
            "item_power_treads",
            "item_blink",
            "item_harpoon",--
            "item_black_king_bar",--
            "item_ultimate_scepter",
            "item_assault",--
            "item_aghanims_shard",
            "item_bloodthorn",--
            "item_travel_boots",
            "item_overwhelming_blink",--
            "item_ultimate_scepter_2",
            "item_travel_boots_2",--
            "item_moon_shard",
        }
    },
    ['pos_3'] = {
        [1] = {
            "item_tango",
            "item_double_branches",
            "item_quelling_blade",
        
            "item_bracer",
            "item_power_treads",
            "item_magic_wand",
            "item_soul_ring",
            "item_blink",
            "item_black_king_bar",--
            "item_ultimate_scepter",
            sUtilityItem,--
            "item_aghanims_shard",
            "item_assault",--
            "item_cyclone",
            "item_travel_boots",
            "item_swift_blink",--
            "item_wind_waker",--
            "item_ultimate_scepter_2",
            "item_travel_boots_2",--
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
            "item_quelling_blade",
            "item_bottle",
            "item_bracer",
            "item_magic_wand",
            "item_echo_sabre",
        }
    },
    ['pos_3'] = {
        [1] = {
            "item_quelling_blade",
            "item_bracer",
            "item_magic_wand",
            "item_soul_ring",
        }
    },
    ['pos_4'] = {},
    ['pos_5'] = {},
}

return X