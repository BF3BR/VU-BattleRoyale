---@class PhaseTable
---@field StartsAt number
---@field MoveDuration number
---@field Damage number
---@field Ratio number
---@field HasAirdrop boolean

---@class InitialCircle
---@field Radius number
---@field Triangles table<integer, Vec2[]>
---@field CumulativeDistribution number[]

---@class MapsConfigMap
---@field SuperBundles string[]
---@field Bundles string[]
---@field BundleRegistries DC[]|nil
---@field TerrainName string
---@field SubWorldInstance DC @TODO: remove?
---@field Conquest_WorldPartReferenceObjectData DC
---@field CQL_Gameplay_WorldPartData DC
---@field OOB DC
---@field OOB2 DC
---@field DefaultFreecamTransform LinearTransform
---@field MapTopLeftPos Vec3
---@field MapWidthHeight number
---@field PlaneFlyHeight number
---@field AirdropPlaneFlyHeight number
---@field BeforeFirstCircleDelay number
---@field SkyComponentDataGuid Guid @TODO: remove?
---@field ConquestGameplayGuid Guid @TODO: remove?
---@field CircleWallY number
---@field CircleWallHeightModifier number
---@field PhasesCount integer @TODO: remove? It's unused
---@field Phases PhaseTable[]
---@field InitialCircle InitialCircle
---@field WarmupSpawnPoints Vec3[]
---@field ShowroomTransform LinearTransform
---@field LootSpawnPoints table
---@field MapPreset table
---@field ObjectModifications XP5_003_ObjectModifications|nil @TODO: improve
---@field VEPresets string[]

---@type MapsConfigMap[]
MapsConfig = {
	XP5_003 = require "__shared/Maps/XP5_003",
	XP3_Alborz = require "__shared/Maps/XP3_Alborz",
}
