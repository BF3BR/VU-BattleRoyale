class 'UICleanup'

function UICleanup:__init()
    Hooks:Install('UI:PushScreen', 999, function(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
        local s_Screen = UIGraphAsset(p_Screen)

        -- print("INFO: Ui screen pushed: " .. s_Screen.name)
        
        if s_Screen.name == 'UI/Flow/Screen/SpawnScreenPC' or
            s_Screen.name == 'UI/Flow/Screen/SpawnScreenTicketCounterConquestScreen' or
            --s_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsScreen' or
            s_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD32Screen' or
            s_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD16Screen' or
            s_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD64Screen' or
            s_Screen.name == 'UI/Flow/Screen/KillScreen' or
            s_Screen.name == 'UI/Flow/Screen/SpawnButtonScreen' then
                p_Hook:Return(nil)
            return
        end
        
	    if 	s_Screen.name == 'UI/Flow/Screen/HudConquestScreen' then
            local s_Clone = s_Screen:Clone(s_Screen.instanceGuid)
            local s_ScreenClone = UIGraphAsset(s_Clone)

            for i = #s_Screen.nodes, 1, -1 do
                local node = s_Screen.nodes[i]
                if node ~= nil then
                    if node.name == 'TicketCounter' or 
                        node.name == 'HudBackgroundWidget' or
                        node.name == 'CapturepointManager' or
                        node.name == 'ObjectiveBar'
                    then
                        s_ScreenClone.nodes:erase(i)
                    end
                end
            end

            p_Hook:Pass(s_ScreenClone, p_GraphPriority, p_ParentGraph)
            return
        end
    end)
end

return UICleanup()
