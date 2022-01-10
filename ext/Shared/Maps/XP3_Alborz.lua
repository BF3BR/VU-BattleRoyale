--[[
	Phase.StartsAt: Time until blue circle starts to shrink
	Phase.MoveDuration: Time until blue meets white
	Phase.Damage: Damage per second
	Phase.Ratio: Circle's shrinking ratio
	InitialCircle.Triangles: Triangles converted from the polygon in which the initial circle will appear. Conversion script by breaknix
]]

-- XP3_Alborz Alborz Mountains
return {
	SuperBundles = {
		"XP1Chunks",
		"Levels/XP1_004/XP1_004",
		"Levels/XP3_Shield/XP3_Shield",
		"Levels/COOP_010/COOP_010",
		"XP5Chunks",
		"Levels/XP5_003/XP5_003"
	},
	Bundles = {
		"Levels/XP1_004/XP1_004",
		"Levels/XP3_Shield/XP3_Shield",
		"Levels/COOP_010/COOP_010",
		"Levels/XP5_003/XP5_003",
		"Levels/XP5_003/Conquest",
		"Levels/XP5_003/CQL",
		"Levels/XP3_Alborz/XP3_Alborz"
	},
	BundleRegistries = {
		DC(Guid("4D59552D-787F-402E-8FED-7B360186BD8A"), Guid("D52CD0C7-7BFF-EDC8-1198-1CC70F9E68F8"))
	},
	TerrainName = "levels/mp_whitepeak/terrain/terrain",
	SubWorldInstance = DC(Guid("707F4A91-B837-47AC-8BEE-5EB614399714"), Guid("A83D8333-F6D5-43AA-BA65-96122FAE8F7C")),
	Conquest_WorldPartReferenceObjectData = DC(Guid("523C8C98-5035-447E-8C85-2F06C56013C8"), Guid("78D976BE-D23C-4F39-A6A7-451DD35CD16E")),
	CQL_Gameplay_WorldPartData = DC(Guid("E3803DDE-3E34-4CAD-A50F-80A1072EDE9D"), Guid("8D25E38A-5864-4248-9D46-31BDB35B7AF6")),
	OOB = DC(Guid("D0D71527-3CDE-4BF9-8CF4-ACA12000CD98"), Guid("C52ECFD0-6E40-40FD-A459-2C4DB79ECACE")),
	OOB2 = DC(Guid("D0D71527-3CDE-4BF9-8CF4-ACA12000CD98"), Guid("5697BB03-90D2-477B-A704-28029F9241D6")),
	--TODO:
	DefaultFreecamTransform = LinearTransform(
		Vec3(-0.997605, -0.000000, -0.069175),
		Vec3(-0.068781, -0.106536, 0.991927),
		Vec3(-0.007370, 0.994309, 0.106281),
		Vec3(98.216576, 889.539246, -815.457642)),
	MapTopLeftPos = Vec3(1334.88, 0.0, 286.57),
	MapWidthHeight = 2500.0,
	PlaneFlyHeight = 785.0,
	AirdropPlaneFlyHeight = 785.0,
	BeforeFirstCircleDelay = 30.0,
	SkyComponentDataGuid = Guid("9159BC49-8F6C-4422-BD1E-EA76D956DFA3"), -- Maybe get rid of this one
	ConquestGameplayGuid = Guid("8D25E38A-5864-4248-9D46-31BDB35B7AF6"), -- Maybe get rid of this one
	CircleWallY = 220,
	CircleWallHeightModifier = 300,
	PhasesCount = 9,
	Phases = {
		{
			StartsAt = 90.0,
			MoveDuration = 90.0,
			Damage = 0.4,
			Ratio = 0.3,
			HasAirdrop = false,
		},{
			StartsAt = 90.0,
			MoveDuration = 90.0,
			Damage = 0.6,
			Ratio = 0.45,
			HasAirdrop = true,
		},{
			StartsAt = 60.0,
			MoveDuration = 60.0,
			Damage = 0.8,
			Ratio = 0.6,
			HasAirdrop = false,
		},{
			StartsAt = 60.0,
			MoveDuration = 60.0,
			Damage = 1.0,
			Ratio = 0.6,
			HasAirdrop = true,
		},{
			StartsAt = 45.0,
			MoveDuration = 45.0,
			Damage = 3.0,
			Ratio = 0.55,
			HasAirdrop = false,
		},{
			StartsAt = 30.0,
			MoveDuration = 30.0,
			Damage = 5.0,
			Ratio = 0.5,
			HasAirdrop = true,
		},{
			StartsAt = 30.0,
			MoveDuration = 30.0,
			Damage = 7.0,
			Ratio = 0.4,
			HasAirdrop = true,
		},{
			StartsAt = 25.0,
			MoveDuration = 25.0,
			Damage = 9.0,
			Ratio = 0.4,
			HasAirdrop = false,
		},{
			StartsAt = 15.0,
			MoveDuration = 15.0,
			Damage = 11.0,
			Ratio = 0.001,
			HasAirdrop = false,
		}
	},
	InitialCircle = {
		Radius = 500,
		Triangles = {
			{ Vec2(-179.95001220703, -968.591796875), Vec2(-316.51806640625, -815.22882080078), Vec2(-316.11657714844, -1357.7646484375) },
			{ Vec2(-316.11657714844, -1357.7646484375), Vec2(584.68591308594, -1235.2385253906), Vec2(455.9482421875, -696.60577392578) },
			{ Vec2(191.36773681641, -896.60498046875), Vec2(-179.95001220703, -968.591796875), Vec2(-316.11657714844, -1357.7646484375) },
			{ Vec2(-316.11657714844, -1357.7646484375), Vec2(455.9482421875, -696.60577392578), Vec2(191.36773681641, -896.60498046875) }
		},
		CumulativeDistribution = { 0.10138120512771834, 0.7874338010033433, 0.9719027867851032, 1 }
	},
	WarmupSpawnPoints = {
		Vec3(522.175720, 155.705505, -822.253479),
		Vec3(504.892242, 155.705521, -818.481201),
		Vec3(489.687561, 155.705505, -821.180725),
		Vec3(508.602478, 155.002380, -805.288818),
		Vec3(532.126038, 155.705505, -812.327698),
		Vec3(549.835144, 155.705505, -814.410950),
		Vec3(554.443542, 155.705521, -827.446960),
		Vec3(538.788635, 155.705505, -826.814697),
		Vec3(524.122437, 155.705521, -836.830017),
		Vec3(506.119202, 155.705490, -834.631287)
	},
	LootSpawnPoints = {}, --require "__shared/Maps/XP5_003/XP5_003_LootPresets",
	MapPreset = require "__shared/Maps/XP3_Alborz/XP3_Alborz_MapPreset",
	ObjectModifications = nil,
	VEPresets = {},
}
