require ("__shared/Helpers/GameStates")

CircleConfig = 
{
    BeforeFirstCircleDelay = 120.0,

    CircleDetails = {
        [GameStates.CircleOne] = {
            -- Time until blue circle srtats to shrink
            StartsAt = 300.0,
            -- Time until blue meets white
            EndsAt = 720.0,
            -- Damage per second
            Damage = 0.4,
        },
        [GameStates.CircleTwo] = {
            -- Time until blue circle srtats to shrink
            StartsAt = 200.0,
            -- Time until blue meets white
            EndsAt = 340.0,
            -- Damage per second
            Damage = 0.6,
        },
        [GameStates.CircleThree] = {
            -- Time until blue circle srtats to shrink
            StartsAt = 150.0,
            -- Time until blue meets white
            EndsAt = 240.0,
            -- Damage per second
            Damage = 0.8,
        },
        [GameStates.CircleFour] = {
            -- Time until blue circle srtats to shrink
            StartsAt = 120.0,
            -- Time until blue meets white
            EndsAt = 180.0,
            -- Damage per second
            Damage = 1.0,
        },
        [GameStates.CircleFive] = {
            -- Time until blue circle srtats to shrink
            StartsAt = 120.0,
            -- Time until blue meets white
            EndsAt = 160.0,
            -- Damage per second
            Damage = 3.0,
        },
        [GameStates.CircleSix] = {
            -- Time until blue circle srtats to shrink
            StartsAt = 90.0,
            -- Time until blue meets white
            EndsAt = 120.0,
            -- Damage per second
            Damage = 5.0,
        },
        [GameStates.CircleSeven] = {
            -- Time until blue circle srtats to shrink
            StartsAt = 90.0,
            -- Time until blue meets white
            EndsAt = 120.0,
            -- Damage per second
            Damage = 7.0,
        },
        [GameStates.CircleEight] = {
            -- Time until blue circle srtats to shrink
            StartsAt = 60.0,
            -- Time until blue meets white
            EndsAt = 90.0,
            -- Damage per second
            Damage = 9.0,
        },
        [GameStates.CircleNine] = {
            -- Time until blue circle srtats to shrink
            StartsAt = 60.0,
            -- Time until blue meets white
            EndsAt = 60.0,
            -- Damage per second
            Damage = 11.0,
        },
    }
}
