---@class TeamManagerNetEvent
TeamManagerNetEvent = {
	RequestTeamJoin = "TM:RTJ",
	TeamJoinDenied = "TM:TJD",
	TeamLeave = "TM:TL",
	TeamJoinStrategy = "TM:TJS",
	TeamToggleLock = "TM:TTL",
	PlayerState = "TM:PS",
	PlayerArmorState = "TM:PAS",
	PlayerTeamState = "TM:PTS"
}

---@class TeamManagerEvent
TeamManagerEvent = {
	DestroyTeam = "TM:DestroyTeam",
	PutOnATeam = "TM:PutOnATeam",
	IncrementKill = "TM:IncrementKill",
	RegisterKill = "TM:RegisterKill"
}

---@class DamageEvent
DamageEvent = {
	Hit = "DMG:H",
	PlayerDown = "DMG:PD",
	PlayerKill = "DMG:PK",
	PlayerFinish = "DMG:PF",
	PlayerKilled = "DMG:PKD"
}

---@class PingEvents
PingEvents = {
	ClientPing = "Ping:PlayerPing",
	ServerPing = "Ping:Notify",
	UpdateConfig = "Ping:UpdateConfig",
	RemoveClientPing = "Ping:RemovePlayerPing",
	RemoveServerPing = "Ping:RemoveNotify"
}

---@class PhaseManagerNetEvent
PhaseManagerNetEvent = {
	InitialState = "PM:InitialState",
	UpdateState = "PM:UpdateState",
	UpdatePhases = "PM:UpdatePhases"
}

---@class PhaseManagerEvent
PhaseManagerEvent = {
	Update = "PhaseManager:Update",
	CircleMove = "PhaseManager:CircleMove"
}

---@class GunshipEvents
GunshipEvents = {
	Enable = "Gunship:Enable",
	Disable = "Gunship:Disable",
	JumpOut = "Gunship:JumpOutOfGunship",
	ForceJumpOut = "Gunship:ForceJumpOufOfGunship",
	OpenParachute = "Gunship:OpenParachute",
}

---@class PlayerEvents
PlayerEvents = {
	UpdateTimer = "VuBattleRoyale:UpdateTimer",
	GameStateChanged = "VuBattleRoyale:GameStateChanged",
	MinPlayersToStartChanged = "VuBattleRoyale:MinPlayersToStartChanged",
	PlayersPerTeamChanged = "VuBattleRoyale:PlayersPerTeamChanged",
	WinnerTeamUpdate = "VuBattleRoyale:WinnerTeamUpdate",
	PlayerConnected = "VuBattleRoyale:PlayerConnected",
	PlayerDeploy = "VuBattleRoyale:PlayerDeploy",
	EnableSpectate = "VuBattleRoyale:EnableSpectate",
	Despawn = "VuBattleRoyale:Despawn",
	PlayerSetSkin = "VuBattleRoyale:PlayerSetSkin",
}

---@class SpectatorEvents
SpectatorEvents = {
	RequestPitchAndYaw = "SpectatorEvents:RequestPitchAndYaw",
	PostPitchAndYaw = "SpectatorEvents:PostPitchAndYaw",
}

---@class InventoryNetEvent
InventoryNetEvent = {
	InventoryState = "IV:IS",
	InventoryGiveCommand = "IV:GC",
	InventorySpawnCommand = "IV:SC",
	MoveItem = "IV:MI",
	DropItem = "IV:DI",
	UseItem = "IV:UI",
	CreateLootPickup = "IV:CLP",
	UnregisterLootPickup = "IV:ULP",
	PickupItem = "IV:PI",
	UpdateLootPickup = "IV:UPLP",
	ItemActionStarted = "IV:ASTRD",
	ItemActionCompleted = "IV:ACMPL",
	ItemActionCanceled = "IV:ACNCL",
}
