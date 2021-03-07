EventRouterEvents = {UIDrawHudCustom = "UIDrawHudCustom"}

local UpdateManagerMap = {
    [UpdatePass.UpdatePass_PreSim] = {"UpdatePass_PreSim"},
    [UpdatePass.UpdatePass_PostSim] = {"UpdatePass_PostSim"},
    [UpdatePass.UpdatePass_PostFrame] = {"UpdatePass_PostFrame"},
    [UpdatePass.UpdatePass_FrameInterpolation] = {"UpdatePass_FrameInterpolation"},
    [UpdatePass.UpdatePass_PreInput] = {"UpdatePass_PreInput"},
    [UpdatePass.UpdatePass_PreFrame] = {"UpdatePass_PreFrame", EventRouterEvents.UIDrawHudCustom},
    [UpdatePass.UpdatePass_Count] = {"UpdatePass_Count"}
}

Events:Subscribe("UpdateManager:Update", function(deltaTime, updatePass)
    for _, eventName in ipairs(UpdateManagerMap[updatePass]) do
        Events:DispatchLocal(eventName, deltaTime)
    end
end)
