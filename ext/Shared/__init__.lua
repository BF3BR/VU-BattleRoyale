class "VuBattleRoyaleShared"

require "__shared/Helpers/LevelNameHelper"
require "__shared/Configs/MapsConfig"
require "__shared/DropWeapons"
require "__shared/RemoveVehicles"
require "__shared/Utils/EventRouter"
-- require "__shared/InteractiveManDown"

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

    -- Register all of the hooks
    self:RegisterHooks()
end

function VuBattleRoyaleShared:OnExtensionUnloaded()
    self:UnregisterEvents()
    self:UnregisterHooks()
end

function VuBattleRoyaleShared:RegisterEvents()
    self.m_WorldPartData = ResourceManager:RegisterInstanceLoadHandler(Guid("B6BD6848-37DF-463A-81C5-33A5B3D6F623"),
                                                                       Guid("A048FCDD-2F98-432A-A5B7-5CC49F2AB21E"),
                                                                       self, self.OnWorldPartData)
    self.m_PreRoundEntityData = ResourceManager:RegisterInstanceLoadHandler(
                                    Guid("0C342A8C-BCDE-11E0-8467-9159D6ACA94C"),
                                    Guid("B3AF5AF0-4703-402C-A238-601E610A0B48"), self, self.OnPreRoundEntityData)
    self.m_DisableCamerasOnUnspawn = ResourceManager:RegisterInstanceLoadHandler(
                                         Guid("0C342A8C-BCDE-11E0-8467-9159D6ACA94C"),
                                         Guid("ADDF2F84-F2E8-2AD8-5FE6-56620207AC95"), self,
                                         self.OnDisableCamerasOnUnspawn)
end

function VuBattleRoyaleShared:RegisterHooks()

end

function VuBattleRoyaleShared:UnregisterEvents()

end

function VuBattleRoyaleShared:UnregisterHooks()

end

function VuBattleRoyaleShared:OnWorldPartData(p_Instance)
    p_Instance = WorldPartData(p_Instance)
    for i, l_Object in pairs(p_Instance.objects) do
        if l_Object:Is("ReferenceObjectData") then
            l_Object = ReferenceObjectData(l_Object)
            if not l_Object.blueprint.name:match("HQ") then
                l_Object = ReferenceObjectData(l_Object)
                l_Object:MakeWritable()
                l_Object.excluded = true
            end
        end
    end
end

function VuBattleRoyaleShared:OnPreRoundEntityData(p_Instance)
    p_Instance = PreRoundEntityData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.enabled = false
end

function VuBattleRoyaleShared:OnDisableCamerasOnUnspawn(p_Instance)
    p_Instance = SpatialPrefabBlueprint(p_Instance)
    p_Instance:MakeWritable()
    for i = #p_Instance.eventConnections, 1, -1 do
        if p_Instance.eventConnections[i].source:Is("HumanPlayerEntityData") then
            if EventSpec(p_Instance.eventConnections[i].sourceEvent).id == 273719920 and
                p_Instance.eventConnections[i].target:Is("LogicReferenceObjectData") then -- (OnPlayerDeathTimeout)
                p_Instance.eventConnections:erase(i)
            end
            if p_Instance.eventConnections[i].target.instanceGuid == Guid("38B766CB-020E-4254-B220-7F69F33A7FEA") then
                p_Instance.eventConnections:erase(i)
            end
        end
    end
end

return VuBattleRoyaleShared()
