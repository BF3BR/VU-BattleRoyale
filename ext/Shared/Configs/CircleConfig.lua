CircleConfig = {
    -- Render the inner circle too, using a more subtle rendering style
    RenderInnerCircle = false,

    -- Use raycasts to calculate the ground level. If not, then the player's Y is used
    UseRaycasts = true,

    -- The distance from which the circle will be visible
    DrawDistance = 150,

    -- The height of the circle
    Height = 200,

    -- The length of each arc that is used to draw the circles
    ArcLen = { Min = 1.2, Max = 12},

    -- The number of points used to draw the circles
    RenderPoints = { Min = 7, Max = 23},
}
