class "MapSpecificModifier"

local m_LootCreation = require "__shared/Modifications/LootCreation"
local m_ManDownModifier = require "__shared/Modifications/Soldiers/ManDownModifier"

local m_Logger = Logger("MapSpecificModifier", true)

local m_LastMapConfig = nil

function MapSpecificModifier:RegisterCallbacks(p_MapConfig)
	m_LastMapConfig = p_MapConfig

	p_MapConfig.Conquest_WorldPartReferenceObjectData:RegisterLoadHandlerOnce(self, self.OnWorldPartLoaded)
	p_MapConfig.CQL_Gameplay_WorldPartData:RegisterLoadHandlerOnce(self, self.OnVehiclesWorldPartData)
	p_MapConfig.OOB:RegisterLoadHandlerOnce(self, self.OnOOBLoaded)
	p_MapConfig.OOB2:RegisterLoadHandlerOnce(self, self.OnOOBLoaded)
end

function MapSpecificModifier:DeregisterCallbacks()
	if m_LastMapConfig == nil then
		return
	end

	m_LastMapConfig.Conquest_WorldPartReferenceObjectData:Deregister()
	m_LastMapConfig.CQL_Gameplay_WorldPartData:Deregister()
	m_LastMapConfig = nil
end

function MapSpecificModifier:OnWorldPartLoaded(p_WorldPartReferenceObjectData)
	local s_CustomWorldPartData = WorldPartData()

	p_WorldPartReferenceObjectData.blueprint = s_CustomWorldPartData

	local s_Registry = RegistryContainer()
	s_Registry.blueprintRegistry:add(s_CustomWorldPartData)

	m_ManDownModifier:OnWorldPartLoaded(s_CustomWorldPartData, s_Registry)
	m_LootCreation:OnWorldPartLoaded(s_CustomWorldPartData, s_Registry)
	self:CreateMapMarkers(s_CustomWorldPartData, s_Registry)
	ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)
end

function MapSpecificModifier:OnVehiclesWorldPartData(p_Instance)
	-- Remove / exclude all the vehicles from the map
	-- TODO: Probably need to fix this for other maps! Need to recheck.
	for i, l_Object in pairs(p_Instance.objects) do
		if l_Object:Is("ReferenceObjectData") then
			l_Object = ReferenceObjectData(l_Object)

			-- Gameplay/GameModes/Conquest/ADDF2F84-F2E8-2AD8-5FE6-56620207AC95
			-- XP5/Dynamic_VehicleSpawners/Outpostspawn_XP_US_C130Airdrop_RU_C130Airdrop/B57E136A-0E4D-4952-8823-98A20DFE8F44
			-- Gameplay/Level_Setups/Dynamic_VehicleSpawners/Outpostspawn_XP_US_Gunship_RU_Gunship/5DE7DC5F-3740-407A-AEF8-6EEAD43B66C3
			if l_Object.blueprint.instanceGuid ~= Guid("ADDF2F84-F2E8-2AD8-5FE6-56620207AC95") and
			l_Object.blueprint.instanceGuid ~= Guid("B57E136A-0E4D-4952-8823-98A20DFE8F44") and
			l_Object.blueprint.instanceGuid ~= Guid("5DE7DC5F-3740-407A-AEF8-6EEAD43B66C3") then
				l_Object:MakeWritable()
				l_Object.excluded = true
			end
		end
	end
end

function MapSpecificModifier:CreateMapMarkers(p_WorldPartData, p_Registry)
	for i = 1, 24 do
		local s_MapMarkerEntityData = MapMarkerEntityData()
		s_MapMarkerEntityData.transform.trans = Vec3(-9999, -9999, -9999)
		s_MapMarkerEntityData.baseTransform = Vec3(-9999, -9999, -9999)
		s_MapMarkerEntityData.sid = ""
		s_MapMarkerEntityData.showRadius = 9999
		s_MapMarkerEntityData.hideRadius = 0

		if i <= 4 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_ObjectiveMoveTo -- normal ping
		elseif i <= 8 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_ObjectiveScout -- enemy ping
		elseif i <= 12 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_NeedPickup -- weapon pickup
		elseif i <= 16 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_AmmoCrate -- ammo pickup
		elseif i <= 20 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_MedicBag -- armor pickup
		elseif i <= 24 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_NeedMedic -- health pickup
		end

		s_MapMarkerEntityData.verticalOffset = 0.0
		s_MapMarkerEntityData.focusPointRadius = 0.0
		s_MapMarkerEntityData.useMarkerTransform = false
		s_MapMarkerEntityData.isVisible = true
		s_MapMarkerEntityData.snap = true
		s_MapMarkerEntityData.showAirTargetBox = true
		s_MapMarkerEntityData.isFocusPoint = false
		s_MapMarkerEntityData.indexInBlueprint = 132 + i
		s_MapMarkerEntityData.isEventConnectionTarget = 2
		s_MapMarkerEntityData.isPropertyConnectionTarget = 3

		local s_SpatialPrefabBlueprint = SpatialPrefabBlueprint()
		s_SpatialPrefabBlueprint.needNetworkId = true
		s_SpatialPrefabBlueprint.interfaceHasConnections = false
		s_SpatialPrefabBlueprint.alwaysCreateEntityBusClient = true
		s_SpatialPrefabBlueprint.alwaysCreateEntityBusServer = true
		s_SpatialPrefabBlueprint.objects:add(s_MapMarkerEntityData)

		p_Registry.blueprintRegistry:add(s_SpatialPrefabBlueprint)
		p_Registry.entityRegistry:add(s_MapMarkerEntityData)


		local s_MapMarkerReferenceObjectData = ReferenceObjectData()
		s_MapMarkerReferenceObjectData.blueprint = s_SpatialPrefabBlueprint
		s_MapMarkerReferenceObjectData.blueprintTransform = LinearTransform()
		s_MapMarkerReferenceObjectData.indexInBlueprint = 132 + i

		p_WorldPartData.objects:add(s_MapMarkerReferenceObjectData)

		p_Registry.referenceObjectRegistry:add(s_MapMarkerReferenceObjectData)
	end
	m_Logger:Write("Created pinging mapmarkers")
end

function MapSpecificModifier:OnOOBLoaded(p_VolumeVectorShape)
	m_Logger:Write("VolumeVectorShape Loaded")

	p_VolumeVectorShape.points:clear()
	p_VolumeVectorShape.normals:clear()
	p_VolumeVectorShape.points:add(Vec3(9999.0, 150.0, 9999.0))
	p_VolumeVectorShape.normals:add(Vec3())
	p_VolumeVectorShape.points:add(Vec3(9999.0, 150.0, -9999.0))
	p_VolumeVectorShape.normals:add(Vec3())
	p_VolumeVectorShape.points:add(Vec3(-9999.0, 150.0, -9999.0))
	p_VolumeVectorShape.normals:add(Vec3())
	p_VolumeVectorShape.points:add(Vec3(-9999.0, 150.0, 9999.0))
	p_VolumeVectorShape.normals:add(Vec3())
end

return MapSpecificModifier()
