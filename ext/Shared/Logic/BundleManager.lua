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

	for _, l_SuperBundle in pairs(MapsConfig[LevelNameHelper:GetLevelName()].SuperBundles) do
		ResourceManager:MountSuperBundle(l_SuperBundle)
	end

	local s_MapPreset = json.decode(MapsConfig[LevelNameHelper:GetLevelName()].MapPreset)

	if s_MapPreset == nil then
		error("No custom map data for map: " .. p_LevelName .. " and gamemode: " .. p_GameMode)
		return
	end

	m_Logger:Write("Dispatch to MapLoader")
	Events:Dispatch('MapLoader:LoadLevel', s_MapPreset)

	self.m_LevelName = p_LevelName
end

function BundleManager:OnLoadBundles(p_Hook, p_Bundles, p_Compartment)
	if #p_Bundles == 1 and p_Bundles[1] == SharedUtils:GetLevelName() then
		local s_Bundles = MapsConfig[LevelNameHelper:GetLevelName()].Bundles
		table.insert(s_Bundles, p_Bundles[1])

		m_Logger:Write("Injecting bundles:")
		m_Logger:Write(s_Bundles)

		p_Hook:Pass(s_Bundles, p_Compartment)
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

	for _, l_Registry in ipairs(MapsConfig[LevelNameHelper:GetLevelName()].BundleRegistries) do
		ResourceManager:AddRegistry(l_Registry:GetInstance(), ResourceCompartment.ResourceCompartment_Game)
	end
end

return BundleManager
