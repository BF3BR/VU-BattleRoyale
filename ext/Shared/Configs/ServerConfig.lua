require "__shared/Enums/GameStates"

ServerConfig = 
{
    -- Minimum ammounts of players to start the warmup and then the match
    MinPlayersToStart = 5,

    -- Number of player per team
    PlayersPerTeam = 4,

    -- Time to update some of the HUD components
    HudUpdateRate = 2.5,

    GunshipDespawn = 60.0,

    ParachuteRaycastUpdateRate = 0.2,

    ForceParachuteHeight = 150.0,

    MatchStateTimes = {
        [GameStates.None] = nil,
        [GameStates.Warmup] = 20.0,
        [GameStates.WarmupToPlane] = 5.0,
        [GameStates.Plane] = 35.0,
        [GameStates.PlaneToFirstCircle] = 5.0,
        [GameStates.Match] = nil,
        [GameStates.EndGame] = 15.0,
    },

    PlayerColors = {
        Vec4(1, 0, 0, 0.5),
        Vec4(0, 1, 0, 0.5),
        Vec4(0, 0, 1, 0.5),
        Vec4(0.5, 0.5, 0.5, 0.5)
    },

    -- DEBUG STUFF
    Debug = {
        EnableLootPointSpheres = false,

        Logger_Enabled = true,

        Logger_Print_All = true,

        EnableWinningCheck = true,

        ShowAllNametags = false,

        Whitelist = {
            "voteban_flash",
            "Bree",
            "Janssent",
            "[HCM]Janssent",
            "KVN",
            "breaknix",
            "kiwidog",
            "kiwidoggie",
            "keku645",
            "DankBoi21",
            "FoolHen",
            "beogath",
        },
    }
}
