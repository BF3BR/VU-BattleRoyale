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

    -- Circles
    CircleOne = 5,
    CircleTwo = 6,
    CircleThree = 7,
    CircleFour = 8,
    CircleFive = 9,
    CircleSix = 10,
    CircleSeven = 11,
    CircleEight = 12,
    CircleNine = 13, -- Final circle to nothingness

    -- End of the round
    EndGame = 14,
}
