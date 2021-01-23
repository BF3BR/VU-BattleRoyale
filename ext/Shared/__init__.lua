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
    -- Thanks to https://github.com/FlashHit/VU-Mods/blob/master/No-PreRound/ext/Server/__init__.lua
	for _, instance in pairs(p_Partition.instances) do
		if instance:Is('PreRoundEntityData') then
			instance = PreRoundEntityData(instance)
			instance:MakeWritable()
			instance.enabled = false
        end
        
        if instance:Is('ReferenceObjectData') then
            instance = ReferenceObjectData(instance)
            if instance.blueprint ~= nil then
                if string.match(instance.blueprint.name, "Gameplay/Level_Setups/Components/CapturePointPrefab") then
                    instance:MakeWritable()
                    instance.excluded = true
                end
            end
        end
	end
end

return VuBattleRoyaleShared()
