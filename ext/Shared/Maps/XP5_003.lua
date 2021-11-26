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
		"Levels/COOP_009/COOP_009",
	},
	Bundles = {
		"Levels/XP1_004/XP1_004",
		"Levels/XP3_Shield/XP3_Shield",
		"Levels/XP3_Alborz/XP3_Alborz",
		"Levels/COOP_009/COOP_009",
		"Levels/COOP_009/AB03_Parent",
		"Levels/XP5_003/XP5_003",
	},
	TerrainName = "levels/xp5_003/xp5_003_terrain/xp5_003_terrain",
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
	MapTopLeftPos = Vec3(1334.88, 0, 286.57),
	MapWidthHeight = 2500.0,
	PlaneFlyHeight = 825.0,
	AirdropPlaneFlyHeight = 745.0,
	BeforeFirstCircleDelay = 60.0,
	SkyComponentDataGuid = Guid("9159BC49-8F6C-4422-BD1E-EA76D956DFA3"),
	ConquestGameplayGuid = Guid("B795C24B-21CA-4E57-AA32-86BEFDDF471D"),
	CircleWallY = 220,
	CircleWallHeightModifier = 300,
	PhasesCount = 9,
	Phases = {
		{
			StartsAt = 100.0,
			MoveDuration = 140.0,
			Damage = 0.4,
			Ratio = 0.55,
			HasAirdrop = false,
		},{
			StartsAt = 100.0,
			MoveDuration = 70.0,
			Damage = 0.8,
			Ratio = 0.7,
			HasAirdrop = true,
		},{
			StartsAt = 80.0,
			MoveDuration = 60.0,
			Damage = 1.0,
			Ratio = 0.6,
			HasAirdrop = false,
		},{
			StartsAt = 60.0,
			MoveDuration = 50.0,
			Damage = 2.0,
			Ratio = 0.6,
			HasAirdrop = true,
		},{
			StartsAt = 50.0,
			MoveDuration = 40.0,
			Damage = 4.0,
			Ratio = 0.6,
			HasAirdrop = false,
		},{
			StartsAt = 40.0,
			MoveDuration = 30.0,
			Damage = 6.0,
			Ratio = 0.5,
			HasAirdrop = true,
		},{
			StartsAt = 30.0,
			MoveDuration = 20.0,
			Damage = 8.0,
			Ratio = 0.5,
			HasAirdrop = true,
		},{
			StartsAt = 30.0,
			MoveDuration = 20.0,
			Damage = 10.0,
			Ratio = 0.5,
			HasAirdrop = false,
		},{
			StartsAt = 20.0,
			MoveDuration = 20.0,
			Damage = 12.0,
			Ratio = 0.001,
			HasAirdrop = false,
		}
	},
	InitialCircle = {
		Radius = 600,
		Triangles = {
			{ Vec2(191.130 , -1538.430), Vec2(684.880 , -1425.930), Vec2(641.130 , -738.430) },
			{ Vec2(159.880 , -900.930), Vec2(-321.370 , -825.930), Vec2(-246.370 , -1419.680) },
			{ Vec2(-246.370 , -1419.680), Vec2(191.130 , -1538.430), Vec2(641.130 , -738.430) },
			{ Vec2(641.130 , -738.430), Vec2(159.880 , -900.930), Vec2(-246.370 , -1419.680) }
		},
		CumulativeDistribution = { 0.28424039205571316, 0.5154436419912303, 0.84843306680423, 1 }
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
	Injected_sublevels = require "__shared/Maps/XP5_003/XP5_003_Injected_Sublevels",
	VEPresets = {
		"XP5_003_Default",
		--"XP5_003_Foggy",
		--"XP5_003_Sunset",
		--"XP5_003_Night",
		--"XP5_003_Night_Two",
		--"XP5_003_Night_Three",
	},
}
