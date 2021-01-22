class 'UICleanup'

function UICleanup:__init()
    self.m_PartitionLoadedEvent = Events:Subscribe("Partition:Loaded", self, self.OnPartitionLoaded)
    self.m_UIPushScreenHook =  Hooks:Install('UI:PushScreen', 999, self, self.OnUIPushScreen)
end

function UICleanup:OnPartitionLoaded(p_Partition)
    if p_Partition.name == 'ui/flow/screen/hudconquestscreen' then
        for _, instance in pairs(p_Partition.instances) do
            if instance:Is('UIScreenAsset') then
                instance = UIScreenAsset(instance)
                instance:MakeWritable()
                for i = #instance.nodes, 1, -1 do
                    local node = instance.nodes[i]
                    if node ~= nil then
                        if node.name == 'TicketCounter' or 
                            node.name == 'HudBackgroundWidget' or
                            node.name == 'CapturepointManager' or
                            node.name == 'ObjectiveBar'
                        then
                            instance.nodes:erase(i)
                        end
                    end
                end
            end
        end
    end
end

function UICleanup:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
    local s_Screen = UIGraphAsset(p_Screen)
            
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
end

return UICleanup()
