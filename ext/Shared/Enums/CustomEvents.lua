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
    UpdateConfig = "Ping:UpdateConfig"
}

PhaseManagerNetEvent = {
    InitialState = "PM:InitialState",
    UpdateState = "PM:UpdateState"
}

PhaseManagerEvent = {
    Update = "PhaseManager:Update",
    CircleMove = "PhaseManager:CircleMove"
}

SpectatorEvent = {
    PlayerChanged = "Spectator:PlayerChanged"
}

GunshipEvents = {
    Camera = "Gunship:Camera",
    JumpOut = "Gunship:JumpOutOfGunship",
    ForceJumpOut = "Gunship:ForceJumpOufOfGunship",
    Position = "Gunship:Position",
    Yaw = "Gunship:Yaw",
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
