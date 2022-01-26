---@class ServerConfig
ServerConfig = {
	-- Minimum ammounts of players to start the warmup and then the match
	MinPlayersToStart = 99,

	-- Number of player per team
	PlayersPerTeam = 1,

	-- Time to update some of the HUD components
	HudUpdateRate = 1.5,

	GunshipDespawn = 50.0,

	RaycastUpdateRate = 0.2,

	ForceParachuteHeight = 135.0,

	UseOfficialImage = false,

	MatchStateTimes = {
		[GameStates.None] = nil,
		[GameStates.Warmup] = 10.0,
		[GameStates.WarmupToPlane] = 5.0,
		[GameStates.Plane] = 80.0,
		[GameStates.PlaneToFirstCircle] = 10.0,
		[GameStates.Match] = nil,
		[GameStates.EndGame] = 15.0,
	},

	PlayerColors = {
		Vec4(0.619, 0.772, 0.333, 0.5),
		Vec4(1.000, 0.733, 0.337, 0.5),
		Vec4(1.000, 0.623, 0.501, 0.5),
		Vec4(0.580, 0.803, 0.952, 0.5)
	},

	-- DEBUG STUFF
	Debug = {
		EnableAllChat = true,

		EnableDebugRenderer = true,

		Logger_Enabled = true,

		Logger_Print_All = false,

		DisableWinningCheck = true,

		DisableMapLoader = false,

		EnableWhitelist = true,

		EnableDebugCommands = true,

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
			"lol24",
			"DANNYonPC",
			"NoFaTe",
			"3ti65",
			"Imposter",
			"Powback",
			"milkman dan",
			"P!NK_Lesley",
			"P!NK_Illustris",
			"paulhobbel",
			"paul",
			"GreatApo",
		},
	}
}
