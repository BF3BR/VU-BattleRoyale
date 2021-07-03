MerchantsConfig = {
    -- The different types of inventory that the merchants will have
    Types = {
        AMMO = 1,
        MEDIC = 2,
        ENGINEER = 3,
        COUNT = 4
    },

    --[[
        MerchantsSpawns are sorted by map name

        ["map name"] = {
            array of lineartransforms, 1 transform per merchant
        }
    ]]--
    Spawns = {

        -- Kisar Railroad
        ["Levels/XP5_003/XP5_003"] = {
            LinearTransform(
                Vec3(0.669903, 0.000000, 0.742449),
                Vec3(0.000000, 1.000000, 0.000000),
                Vec3(-0.742449, 0.000000, 0.669903),
                Vec3(487.057678, 149.834763, -444.592834)
            ),
            LinearTransform(
                Vec3(0.669903, 0.000000, 0.742449),
                Vec3(0.000000, 1.000000, 0.000000),
                Vec3(-0.742449, 0.000000, 0.669903),
                Vec3(484.057678, 149.834763, -446.592834)
            )
        }
    },

    -- Canned greetings that are sent to the player upon first arrival
    Greetings = {
        "Welcome!",
        "Hola!",
        "Nihao!",
        "Welcome to my humble abode",
        "Greetings and salutations",
        "Get what you need and move on",
        "Don't waste my time",
        "Keep it pushing",
        "Hurry up my",
        "Damn you back again",
        "Man if you don't get your ish and go",
        "Pack it up",
        "Aye mate, 'urry up",
        "Hey bud",
    },

    -- Maximum damage a player can deal before becoming hostile
    MaxHostileDamage = 75.0,

    -- Default time to yell at the player (2 seconds)
    DefaultYellTime = 2.0,

}