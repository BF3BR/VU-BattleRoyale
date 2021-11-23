--[[
	Phase.StartsAt: Time until blue circle starts to shrink
	Phase.MoveDuration: Time until blue meets white
	Phase.Damage: Damage per second
	Phase.Ratio: Circle's shrinking ratio

	InitialCircle.Triangles: Triangles converted from the polygon in which the initial circle will appear. Conversion script by breaknix
]]

-- XP5_003 Kiasar Railroad
return {
	SuperBundles = {
		"XP1Chunks",
		"Levels/XP1_004/XP1_004",
		"XP3Chunks",
		"Levels/XP3_Shield/XP3_Shield",
		"Levels/XP3_Alborz/XP3_Alborz",
		"Levels/COOP_010/COOP_010"
	},
	Bundles = {
		"Levels/XP1_004/XP1_004",
		"Levels/XP3_Shield/XP3_Shield",
		"Levels/XP3_Alborz/XP3_Alborz",
		"Levels/COOP_010/COOP_010",
		"Levels/XP5_003/XP5_003"
	},
	BundleRegistries = {
		DC(Guid("333BDB92-E69D-11DF-9B0E-AF9CA6E0236B"), Guid("2C804637-3B56-6DDB-92C8-81D094EA806B"))
	},
	SubWorldInstance = DC(Guid("CB9932E2-19E0-11E2-93EC-B0D4179CEA18"), Guid("FB11A0AA-BC0A-31C1-8F95-A8B8D7746908")),
	Conquest_WorldPartReferenceObjectData = DC(Guid("6C0D021C-80D8-4BDE-85F7-CDF6231F95D5"), Guid("DA506D40-69C7-4670-BB8B-25EDC9F1A526")),
	CQL_Gameplay_WorldPartData = DC(Guid("8A1B5CE5-A537-49C6-9C44-0DA048162C94"), Guid("B795C24B-21CA-4E57-AA32-86BEFDDF471D")),
	OOB = DC(Guid("B6BD6848-37DF-463A-81C5-33A5B3D6F623"), Guid("25A1A189-61D5-4F1B-8A8C-6173CA59F246")),
	OOB2 = DC(Guid("B6BD6848-37DF-463A-81C5-33A5B3D6F623"), Guid("6A31A582-5C5E-4E9C-A7FC-293E754B21E7")),
	DefaultFreecamTransform = LinearTransform(
		Vec3(-0.997605, -0.000000, -0.069175),
		Vec3(-0.068781, -0.106536, 0.991927),
		Vec3(-0.007370, 0.994309, 0.106281),
		Vec3(98.216576, 889.539246, -815.457642)),
	MapTopLeftPos = Vec3(667.28, 0, -290.44),
	MapWidthHeight = 1250.0,
	PlaneFlyHeight = 755.0,
	BeforeFirstCircleDelay = 30.0,
	SkyComponentDataGuid = Guid("9159BC49-8F6C-4422-BD1E-EA76D956DFA3"),
	ConquestGameplayGuid = Guid("B795C24B-21CA-4E57-AA32-86BEFDDF471D"),
	CircleWallY = 200,
	CircleWallHeightModifier = 400,
	PhasesCount = 9,
	Phases = {
		{
			StartsAt = 60.0,
			MoveDuration = 60.0,
			Damage = 0.4,
			Ratio = 0.550
		},{
			StartsAt = 60.0,
			MoveDuration = 45.0,
			Damage = 0.6,
			Ratio = 0.700
		},{
			StartsAt = 45.0,
			MoveDuration = 45.0,
			Damage = 0.8,
			Ratio = 0.600
		},{
			StartsAt = 30.0,
			MoveDuration = 30.0,
			Damage = 1.0,
			Ratio = 0.600
		},{
			StartsAt = 30.0,
			MoveDuration = 30.0,
			Damage = 3.0,
			Ratio = 0.600
		},{
			StartsAt = 30.0,
			MoveDuration = 30.0,
			Damage = 5.0,
			Ratio = 0.500
		},{
			StartsAt = 15.0,
			MoveDuration = 15.0,
			Damage = 7.0,
			Ratio = 0.500
		},{
			StartsAt = 15.0,
			MoveDuration = 15.0,
			Damage = 9.0,
			Ratio = 0.500
		},{
			StartsAt = 15.0,
			MoveDuration = 15.0,
			Damage = 11.0,
			Ratio = 0.001
		}
	},
	InitialCircle = {
		Radius = 650,
		Triangles = {
			{ Vec2(697.380 , -1557.180), Vec2(672.380 , -613.430), Vec2(372.380 , -894.680) },
			{ Vec2(-390.120 , -850.930), Vec2(-496.370 , -800.930), Vec2(-508.870 , -1594.680) },
			{ Vec2(-508.870 , -1594.680), Vec2(697.380 , -1557.180), Vec2(372.380 , -894.680) },
			{ Vec2(372.380 , -894.680), Vec2(-390.120 , -850.930), Vec2(-508.870 , -1594.680) }
		},
		CumulativeDistribution = { 0.16497867803837954, 0.21328624733475482, 0.6745957711442787, 1 }
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
	LootSpawnPoints = require "__shared/Maps/XP5_003/XP5_003_LootPresets",
	MapPreset = require "__shared/Maps/XP5_003/XP5_003_MapPreset",
	Injected_sublevels = require "__shared/Maps/XP5_003/XP5_003_Injected_sublevels",
	VEPresets = {
		"XP5_003_Default",
		"XP5_003_Foggy",
	},
}
