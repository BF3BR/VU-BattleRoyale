CircleConfig = {
	-- Render the inner circle too, using a more subtle rendering style
	RenderInnerCircle = false,

	-- Use raycasts to calculate the ground level. If not, then the player's Y is used
	UseRaycasts = true,

	-- The distance from which the circle will be visible
	DrawDistance = 80,

	-- The height of the circle
	Height = 200,

	-- The length of each arc that is used to draw the circles
	ArcLen = { Min = 1.6, Max = 9},

	-- The number of points used to draw the circles
	RenderPoints = { Min = 7, Max = 23},

	-- The maximum opacity of the outer circle
	OuterCircleMaxOpacity = 0.12,

	-- The time between each update of the outer circle position
	ClientUpdateMs = 0.07,

	-- Use fog to give the player a better sense of the playable area
	UseFog = true
}
