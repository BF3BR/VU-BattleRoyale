BRPlayerNetEvents = {
    ArmorState = "TM:AS",
}

TeamManagerNetEvents = {
    RequestTeamJoin = "TM:RTJ",
    TeamJoinDenied = "TM:TJD",
    TeamLeave = "TM:TL",
    TeamJoinStrategy = "TM:TJS",
    TeamToggleLock = "TM:TTL",
    PlayerState = "TM:PS",
    PlayerArmorState = "TM:PAS",
    PlayerTeamState = "TM:PTS"
}

TeamManagerCustomEvents = {
    DestroyTeam = "TM:DestroyTeam",
    PutOnATeam = "TM:PutOnATeam",
    IncrementKill = "TM:IncrementKill"
}

DamageEvents = {
    ConfirmHit = "DMG:CH",
    ConfirmPlayerDown = "DMG:CPD",
    ConfirmPlayerKill = "DMG:CPK",
    ConfirmPlayerFinish = "DMG:CPF"
}

PingEvents = {
    ClientPing = "Ping:PlayerPing",
    ServerPing = "Ping:Notify",
    UpdateConfig = "Ping:UpdateConfig"
}

PhaseManagerNetEvents = {
    InitialState = "PM:InitialState",
    UpdateState = "PM:UpdateState"
}

PhaseManagerCustomEvents = {
    Update = "PhaseManager:Update",
    CircleMove = "PhaseManager:CircleMove"
}

GunshipEvents = {
    Camera = "Gunship:Camera",
    JumpOut = "Gunship:JumpOutOfGunship",
    ForceJumpOut = "Gunship:ForceJumpOufOfGunship",
    Position = "Gunship:Position",
    Yaw = "Gunship:Yaw",
}

PlayerEvents = {
    PitchAndYaw = "VuBattleRoyale:PlayersPitchAndYaw",
    KillMsg = "VuBattleRoyale:NotifyInflictorAboutAKill",
    UpdateTimer = "VuBattleRoyale:UpdateTimer",
    GameStateChanged = "VuBattleRoyale:GameStateChanged",
}
