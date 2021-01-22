class "VuBattleRoyaleShared"

require ("__shared/Utils/LevelNameHelper")
require ("__shared/Configs/MapsConfig")

require ("__shared/DropWeapons")

function VuBattleRoyaleShared:__init()
    -- Extension events
    self.m_ExtensionLoadedEvent = nil
    self.m_ExtensionUnloadedEvent = nil

    -- These are the specific events that are required to kick everything else off
    self.m_ExtensionLoadedEvent = Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    self.m_ExtensionUnloadedEvent = Events:Subscribe("Extension:Unloaded", self, self.OnExtensionUnloaded)
end

function VuBattleRoyaleShared:OnExtensionLoaded()
    -- Register all of the events
    self:RegisterEvents()
end

function VuBattleRoyaleShared:OnExtensionUnloaded()
    self:UnregisterEvents()
end

function VuBattleRoyaleShared:RegisterEvents()
    self.m_PartitionLoadedEvent = Events:Subscribe("Partition:Loaded", self, self.OnPartitionLoaded)
end

function VuBattleRoyaleShared:OnPartitionLoaded(p_Partition)
    for _, l_Instance in pairs(p_Partition.instances) do
        if l_Instance.instanceGuid == Guid('5FA66B8C-BE0E-3758-7DE9-533EA42F5364') then
            -- Get rid of the PreRoundEntity. We don't need preround in this gamemode.
            local s_Bp = LogicPrefabBlueprint(l_Instance)
            s_Bp:MakeWritable()

            for i = #s_Bp.objects, 1, -1 do
                if s_Bp.objects[i]:Is('PreRoundEntityData') then
                    s_Bp.objects:erase(i)
                end
            end

            for i = #s_Bp.eventConnections, 1, -1 do
                if s_Bp.eventConnections[i].source:Is('PreRoundEntityData') or s_Bp.eventConnections[i].target:Is('PreRoundEntityData') then
                    s_Bp.eventConnections:erase(i)
                end
            end
        end
    end
end

return VuBattleRoyaleShared()
