class "BundleManager"

local m_Logger = Logger("BundleManager", true)

function BundleManager:__init()
	self:RegisterVars()
end

function BundleManager:RegisterVars()
	self.m_LevelName = ""
end

function BundleManager:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	if self.m_LevelName == p_LevelName then
		m_Logger:Write("Return OnLoadResources")
		return
	end

	local s_LevelName = LevelNameHelper:GetLevelName()

	local s_MapConfig = MapsConfig[s_LevelName]
	if s_MapConfig == nil then
		m_Logger:Write("Unsupported level loaded/no superbundles to load...")
		return
	end

	for _, l_SuperBundle in pairs(s_MapConfig.SuperBundles) do
		ResourceManager:MountSuperBundle(l_SuperBundle)
	end

	local s_MapPreset = json.decode(s_MapConfig.MapPreset)

	if s_MapPreset == nil then
		error("No custom map data for map: " .. p_LevelName .. " and gamemode: " .. p_GameMode)
		return
	end

	m_Logger:Write("Dispatch to MapLoader")
	Events:Dispatch('MapLoader:LoadLevel', s_MapPreset)

	self.m_LevelName = p_LevelName
end

function BundleManager:OnLoadBundles(p_Hook, p_Bundles, p_Compartment)
	local s_LevelName = LevelNameHelper:GetLevelName()
	local s_MapConfig = MapsConfig[s_LevelName]
	if s_MapConfig == nil then
		m_Logger:Write("no map config found, no bundles are being loaded...")
		--p_Hook:Pass(p_Bundles, p_Compartment) -- TODO: Figure out how to fix this
		return
	else
		if #p_Bundles == 1 and p_Bundles[1] == SharedUtils:GetLevelName() then
			local s_Bundles = s_MapConfig.Bundles
			table.insert(s_Bundles, p_Bundles[1])

			m_Logger:Write("Injecting bundles:")
			m_Logger:Write(s_Bundles)

			p_Hook:Pass(s_Bundles, p_Compartment)
		end
	end
end

function BundleManager:OnTerrainLoad(p_Hook, p_TerrainAssetName)
	local s_LevelId = LevelNameHelper:GetLevelName()

	if not p_TerrainAssetName:match(s_LevelId:lower()) then
		m_Logger:Write("Preventing terrain load: " .. p_TerrainAssetName)
		p_Hook:Return()
	end
end

function BundleManager:OnRegisterEntityResources(p_LevelData)
	m_Logger:Write("Adding registries")

	local s_LevelName = LevelNameHelper:GetLevelName()
	local s_MapConfig = MapsConfig[s_LevelName]
	if s_MapConfig == nil then
		print("no level registry data found...")
		return
	end

	for _, l_Registry in ipairs(s_MapConfig.BundleRegistries) do
		ResourceManager:AddRegistry(l_Registry:GetInstance(), ResourceCompartment.ResourceCompartment_Game)
	end
end

return BundleManager
