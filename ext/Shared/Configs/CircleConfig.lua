CircleConfig = {
	-- Render the inner circle too, using a more subtle rendering style
	RenderInnerCircle = false,

	-- Use raycasts to calculate the ground level. If not, then the player's Y is used
	UseRaycasts = false,

	-- The distance from which the circle will be visible
	DrawDistance = 400,

	-- The height of the circle
	Height = 200,

	-- The length of each arc that is used to draw the circles
	ArcLen = { Min = 4, Max = 30},

	-- The number of points used to draw the circles
	RenderPoints = { Min = 7, Max = 80 },

	-- The maximum opacity of the outer circle
	OuterCircleMaxOpacity = 0.12,

	-- The time between each update of the outer circle position (seconds)
	ClientUpdateMs = 0.16,

	-- Use fog to give the player a better sense of the playable area
	EanbleFog = false,

	-- Sound when player is close to the circle edge
	EnableCircleSound = true,
}
