class 'MapLoader'

local m_Logger = Logger("MapLoader", true)

local GameObjectOriginType = {
	Vanilla = 1,
	Custom = 2,
	CustomChild = 3
}

function MapLoader:__init()
	self:Reset()
end

function MapLoader:Reset()
	self.m_LevelName = ""
	self.m_MapPreset = nil

	-- Stores LevelData DataContainer guids.
	self.m_CustomLevelData = nil

	self.m_IndexCount = 0
	self.m_OriginalLevelIndeces = {}
	self.m_LastLoadedMap = nil
	self.m_ObjectVariations = {}
	self.m_PendingVariations = {}
end

-- nº 1 in calling order
function MapLoader:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	m_Logger:Write("Event: Loading resources")
	self.m_ObjectVariations = {}
	self.m_PendingVariations = {}

	if ServerConfig.Debug.DisableMapLoader then
		m_Logger:Write("MapLoader is disabled.")
		return
	end

	self.m_MapPreset = json.decode(MapsConfig[LevelNameHelper:GetLevelName()].MapPreset)

	if self.m_MapPreset == nil then
		m_Logger:Error("No custom map data for map: " .. p_LevelName .. " and gamemode: " .. p_GameMode)
		return
	end

	m_Logger:Write("Load savefile: " .. self.m_MapPreset.header.projectName)
end

-- nº 2 in calling order
function MapLoader:OnPartitionLoaded(p_Partition)
	if p_Partition == nil then
		return
	end

	local s_PrimaryInstance = p_Partition.primaryInstance

	if s_PrimaryInstance == nil then
		m_Logger:Write('Instance is null?')
		return
	end

	-- if l_Instance:Is("Blueprint") then
		--m_Logger:Write("-------"..Blueprint(l_Instance).name)
	-- end

	if s_PrimaryInstance.typeInfo.name == "LevelData" then
		local s_Instance = LevelData(s_PrimaryInstance)

		if (s_Instance.name == SharedUtils:GetLevelName()) then
			m_Logger:Write("Registering PrimaryLevel guids")
			s_Instance:MakeWritable()
			self.m_CustomLevelData = {
				instanceGuid = s_Instance.instanceGuid,
				partitionGuid = s_Instance.partitionGuid
			}
		end
	elseif s_PrimaryInstance:Is('ObjectVariation') then
		-- Store all variations in a map.
		local s_Variation = ObjectVariation(s_PrimaryInstance)
		self.m_ObjectVariations[s_Variation.nameHash] = s_Variation

		if self.m_PendingVariations[s_Variation.nameHash] ~= nil then
			for _, l_Object in pairs(self.m_PendingVariations[s_Variation.nameHash]) do
				l_Object.objectVariation = s_Variation
			end

			self.m_PendingVariations[s_Variation.nameHash] = nil
		end
	end
end

-- nº 3 in calling order
function MapLoader:OnLevelLoadingInfo(p_ScreenInfo)
	if p_ScreenInfo == "Registering entity resources" then
		m_Logger:Write("Event: Loading Info - Registering entity resources")

		if not self.m_MapPreset then
			m_Logger:Write("No custom level specified.")
			return
		end

		if self.m_CustomLevelData == nil then
			m_Logger:Write("m_CustomLevelData is nil, something went wrong")
			return
		end

		local s_PrimaryLevel = ResourceManager:FindInstanceByGuid(self.m_CustomLevelData.partitionGuid, self.m_CustomLevelData.instanceGuid)

		if s_PrimaryLevel == nil then
			m_Logger:Write("Couldn\'t find PrimaryLevel DataContainer, aborting")
			return
		end

		s_PrimaryLevel = LevelData(s_PrimaryLevel)

		if self.m_LastLoadedMap == SharedUtils:GetLevelName() then
			m_Logger:Write('Same map loading, skipping')
			return
		end

		m_Logger:Write("Patching level")
		local s_RegistryContainer = s_PrimaryLevel.registryContainer

		if s_RegistryContainer == nil then
			m_Logger:Write('No registryContainer found, this shouldn\'t happen')
		end

		s_RegistryContainer = RegistryContainer(s_RegistryContainer)
		s_RegistryContainer:MakeWritable()

		local s_WorldPartReference = self:CreateWorldPart(s_PrimaryLevel, s_RegistryContainer)

		s_WorldPartReference.indexInBlueprint = #s_PrimaryLevel.objects

		s_PrimaryLevel.objects:add(s_WorldPartReference)

		-- Save original indeces in case LevelData has to be reset to default state later.
		self.m_OriginalLevelIndeces = {
			objects = #s_PrimaryLevel.objects,
			ROFs = #s_RegistryContainer.referenceObjectRegistry,
			blueprints = #s_RegistryContainer.blueprintRegistry,
			entity = #s_RegistryContainer.entityRegistry
		}
		s_RegistryContainer.referenceObjectRegistry:add(s_WorldPartReference)
		m_Logger:Write('Level patched')
	end
end

-- Remove all DataContainer references and reset vars
function MapLoader:OnLevelDestroy()
	self.m_ObjectVariations = {}
	self.m_PendingVariations = {}
	self.m_IndexCount = 0

	-- TODO: remove all custom objects from level registry and leveldata if next round is
	-- the same map but a different save, once that is implemented. If it's a different map
	-- there is no need to clear anything, as the leveldata will be unloaded and a new one loaded
end

function MapLoader:PatchOriginalObject(p_Object, p_World)
	if p_Object.originalRef == nil then
		m_Logger:Write("Object without original reference found, dynamic object?")
		return
	end

	local s_Reference = nil

	if p_Object.originalRef.partitionGuid == nil or p_Object.originalRef.partitionGuid == "nil" then -- perform a search without partitionguid
		s_Reference = ResourceManager:SearchForInstanceByGuid(Guid(p_Object.originalRef.instanceGuid))

		if s_Reference == nil then
			m_Logger:Write("Unable to find original reference: " .. p_Object.originalRef.instanceGuid)
			return
		end
	else
		s_Reference = ResourceManager:FindInstanceByGuid(Guid(p_Object.originalRef.partitionGuid), Guid(p_Object.originalRef.instanceGuid))

		if s_Reference == nil then
			m_Logger:Write("Unable to find original reference: " .. p_Object.originalRef.instanceGuid .. " in partition " .. p_Object.originalRef.partitionGuid)
			return
		end
	end

	s_Reference = _G[s_Reference.typeInfo.name](s_Reference)
	s_Reference:MakeWritable()

	if p_Object.isDeleted then
		s_Reference.excluded = true
	end

	if p_Object.localTransform then
		s_Reference.blueprintTransform = LinearTransform(p_Object.localTransform) -- LinearTransform(p_Object.localTransform)
	else
		s_Reference.blueprintTransform = LinearTransform(p_Object.transform) -- LinearTransform(p_Object.transform)
	end
end

function MapLoader:AddCustomObject(p_Object, p_World, p_RegistryContainer)
	local s_Blueprint = ResourceManager:FindInstanceByGuid(Guid(p_Object.blueprintCtrRef.partitionGuid), Guid(p_Object.blueprintCtrRef.instanceGuid))

	if s_Blueprint == nil then
		m_Logger:Write('Cannot find blueprint with guid ' .. tostring(p_Object.blueprintCtrRef.instanceGuid))
	end

	-- Filter BangerEntityData.
	if s_Blueprint:Is('ObjectBlueprint') then
		local s_ObjectBlueprint = ObjectBlueprint(s_Blueprint)

		if s_ObjectBlueprint.object and s_ObjectBlueprint.object:Is('BangerEntityData') then
			return
		end
	end

	local s_Reference

	if s_Blueprint:Is('EffectBlueprint') then
		s_Reference = EffectReferenceObjectData()
		s_Reference.autoStart = true
	else
		s_Reference = ReferenceObjectData()
	end

	p_RegistryContainer.referenceObjectRegistry:add(s_Reference)

	if p_Object.localTransform then
		s_Reference.blueprintTransform = LinearTransform(p_Object.localTransform)
	else
		s_Reference.blueprintTransform = LinearTransform(p_Object.transform)
	end

	--print("AddCustomObject: " .. p_Object.transform)
	s_Reference.blueprint = Blueprint(s_Blueprint)
	-- s_Reference.blueprint:MakeWritable()

	if self.m_ObjectVariations[p_Object.variation] == nil then
		self.m_PendingVariations[p_Object.variation] = s_Reference
	else
		s_Reference.objectVariation = self.m_ObjectVariations[p_Object.variation]
	end

	s_Reference.indexInBlueprint = #p_World.objects + self.m_IndexCount + 1
	s_Reference.isEventConnectionTarget = Realm.Realm_None
	s_Reference.isPropertyConnectionTarget = Realm.Realm_None
	s_Reference.excluded = false

	p_World.objects:add(s_Reference)
end

function MapLoader:CreateWorldPart(p_PrimaryLevel, p_RegistryContainer)
	local s_World = WorldPartData()
	p_RegistryContainer.blueprintRegistry:add(s_World)

	--find index
	for _, l_Object in pairs(p_PrimaryLevel.objects) do
		if l_Object:Is('WorldPartReferenceObjectData') then
			local s_RefObjectData = WorldPartReferenceObjectData(l_Object)

			if s_RefObjectData.blueprint:Is('WorldPartData') then
				local s_WorldPart = WorldPartData(s_RefObjectData.blueprint)

				if #s_WorldPart.objects ~= 0 then
					local s_ROD = s_WorldPart.objects[#s_WorldPart.objects] -- last one in array

					if s_ROD and s_ROD:Is('ReferenceObjectData') then
						s_ROD = ReferenceObjectData(s_ROD)

						if s_ROD.indexInBlueprint > self.m_IndexCount then
							self.m_IndexCount = s_ROD.indexInBlueprint
						end
					end
				end
			end
		end
	end

	-- m_IndexCount = 30000
	m_Logger:Write('Index count is: '..tostring(self.m_IndexCount))

	for _, l_Object in pairs(self.m_MapPreset.data) do
		if l_Object.origin == GameObjectOriginType.Custom then
			if not self.m_MapPreset.vanillaOnly then
				self:AddCustomObject(l_Object, s_World, p_RegistryContainer)
			end
		elseif l_Object.origin == GameObjectOriginType.Vanilla then
			self:PatchOriginalObject(l_Object, s_World)
		end
		-- TODO handle CustomChild
	end

	self.m_LastLoadedMap = SharedUtils:GetLevelName()

	local s_WorldPartReference = WorldPartReferenceObjectData()
	s_WorldPartReference.blueprint = s_World

	s_WorldPartReference.isEventConnectionTarget = Realm.Realm_None
	s_WorldPartReference.isPropertyConnectionTarget = Realm.Realm_None
	s_WorldPartReference.excluded = false

	return s_WorldPartReference
end

return MapLoader()
