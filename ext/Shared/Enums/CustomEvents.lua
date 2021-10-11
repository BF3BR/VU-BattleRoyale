BRPlayerNetEvents = {
	ArmorState = "TM:AS",
}

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

TeamManagerEvent = {
	DestroyTeam = "TM:DestroyTeam",
	PutOnATeam = "TM:PutOnATeam",
	IncrementKill = "TM:IncrementKill",
	RegisterKill = "TM:RegisterKill"
}

DamageEvent = {
	Hit = "DMG:H",
	PlayerDown = "DMG:PD",
	PlayerKill = "DMG:PK",
	PlayerFinish = "DMG:PF",
	PlayerKilled = "DMG:PKD"
}

PingEvents = {
	ClientPing = "Ping:PlayerPing",
	ServerPing = "Ping:Notify",
	UpdateConfig = "Ping:UpdateConfig",
	RemoveClientPing = "Ping:RemovePlayerPing",
	RemoveServerPing = "Ping:RemoveNotify"
}

PhaseManagerNetEvent = {
	InitialState = "PM:InitialState",
	UpdateState = "PM:UpdateState"
}

PhaseManagerEvent = {
	Update = "PhaseManager:Update",
	CircleMove = "PhaseManager:CircleMove"
}

GunshipEvents = {
	Enable = "Gunship:Enable",
	Disable = "Gunship:Disable",
	JumpOut = "Gunship:JumpOutOfGunship",
	ForceJumpOut = "Gunship:ForceJumpOufOfGunship",
	OpenParachute = "Gunship:OpenParachute",
}

PlayerEvents = {
	UpdateTimer = "VuBattleRoyale:UpdateTimer",
	GameStateChanged = "VuBattleRoyale:GameStateChanged",
	MinPlayersToStartChanged = "VuBattleRoyale:MinPlayersToStartChanged",
	WinnerTeamUpdate = "VuBattleRoyale:WinnerTeamUpdate",
	PlayerConnected = "VuBattleRoyale:PlayerConnected",
	PlayerDeploy = "VuBattleRoyale:PlayerDeploy",
	EnableSpectate = "VuBattleRoyale:EnableSpectate",
}

SpectatorEvents = {
	RequestPitchAndYaw = "SpectatorEvents:RequestPitchAndYaw",
	PostPitchAndYaw = "SpectatorEvents:PostPitchAndYaw",
}

LMS = {
	RLT = "LMS:RLT",
}

ManDownLootEvents = {
	UpdateLootPosition = "ManDownLoot:UpdateLootPosition",
	OnInteractionFinished = "ManDownLoot:OnInteractionFinished"
}

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
