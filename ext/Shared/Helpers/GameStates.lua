GameStates =
{
    -- There is no gamestate, used for initialization
    None = 0,

    -- Warmup time, waiting for the game to start
    Warmup = 1,

    -- After warmup, going into plane (transition)
    WarmupToPlane = 2,

    -- Plane
    Plane = 3,

    -- After everyone jumped out and the plane is gone
    PlaneToFirstCircle = 4,

    -- Match
    Match = 5,

    -- End of the round
    EndGame = 6,
}
