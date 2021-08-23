class "BundleManager"

local m_Logger = Logger("BundleManager", true)

function BundleManager:__init()
	self.m_LevelName = ""
end

function BundleManager:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	if self.m_LevelName == p_LevelName then
		m_Logger:Write("Return OnLoadResources, because it is the same level")
		return
	end

	self.m_LevelName = p_LevelName

	if MapsConfig[LevelNameHelper:GetLevelName()] == nil then
		return
	end

	m_Logger:Write("Mounting SuperBundles:")

	for l_Index, l_SuperBundle in pairs(MapsConfig[LevelNameHelper:GetLevelName()].SuperBundles) do
		ResourceManager:MountSuperBundle(l_SuperBundle)
		m_Logger:Write(l_Index .. ": " .. l_SuperBundle)
	end
end

function BundleManager:OnLoadBundles(p_Hook, p_Bundles, p_Compartment)
	if #p_Bundles == 1 and p_Bundles[1] == SharedUtils:GetLevelName() then
		local s_Bundles = MapsConfig[LevelNameHelper:GetLevelName()].Bundles

		m_Logger:Write("Injecting bundles:")
		for l_Index, l_Bundle in pairs(s_Bundles) do
			m_Logger:Write(l_Index .. ": " .. l_Bundle)
		end

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
		--ResourceManager:AddRegistry(l_Registry:GetInstance(), ResourceCompartment.ResourceCompartment_Game)
	end
end

return BundleManager
