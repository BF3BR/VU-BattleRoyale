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

TeamManagerErrors = {
    InvalidTeamId = 1,
    TeamIsFull = 2
}
