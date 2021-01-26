CircleConfig = {
    -- Render the inner circle too, using a more subtle rendering style
    RenderInnerCircle = true,

    -- Use raycasts to calculate the ground level. If not, then the player's Y is used
    UseRaycasts = true,

    -- The distance from which the circle will be visible
    DrawDistance = 100,

    -- The length of each arc that is used to draw the circles
    ArcLen = { Min = 1.2, Max = 4.2},

    -- The number of points used to draw the circles
    RenderPoints = { Min = 3, Max = 17}
}
