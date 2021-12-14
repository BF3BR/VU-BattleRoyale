---@class BundleManager
BundleManager = class "BundleManager"

local m_Logger = Logger("BundleManager", true)

function BundleManager:__init()
	self.m_LevelName = ""
end

---VEXT Shared Level:LoadResources Event
---@param p_LevelName string
---@param p_GameMode string
---@param p_IsDedicatedServer boolean
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

---VEXT Shared ResourceManager:LoadBundles Hook
---@param p_HookCtx HookContext
---@param p_Bundles string[]
---@param p_Compartment ResourceCompartment|integer
function BundleManager:OnLoadBundles(p_HookCtx, p_Bundles, p_Compartment)
	if #p_Bundles == 1 and p_Bundles[1] == SharedUtils:GetLevelName() then
		local s_Bundles = MapsConfig[LevelNameHelper:GetLevelName()].Bundles

		m_Logger:Write("Injecting bundles:")
		for l_Index, l_Bundle in pairs(s_Bundles) do
			m_Logger:Write(l_Index .. ": " .. l_Bundle)
		end

		p_HookCtx:Pass(s_Bundles, p_Compartment)
	end
end

---VEXT Shared VisualTerrain:Load Hook
---VEXT Shared Terrain:Load Hook
---@param p_HookCtx HookContext
---@param p_TerrainAssetName string
function BundleManager:OnTerrainLoad(p_HookCtx, p_TerrainAssetName)
	local s_MapConfig = MapsConfig[LevelNameHelper:GetLevelName()]

	if s_MapConfig == nil then
		return
	end

	local s_TerrainName = s_MapConfig.TerrainName

	if s_TerrainName == nil then
		return
	end

	if not p_TerrainAssetName:match(s_TerrainName:lower()) then
		m_Logger:Write("Preventing terrain load: " .. p_TerrainAssetName)
		p_HookCtx:Return()
	end
end

---VEXT Shared Level:RegisterEntityResources Event
---@param p_LevelData DataContainer
function BundleManager:OnRegisterEntityResources(p_LevelData)
	m_Logger:Write("Adding registries")
	local s_BundleRegistries = MapsConfig[LevelNameHelper:GetLevelName()].BundleRegistries

	if s_BundleRegistries == nil then
		return
	end

	for _, l_Registry in ipairs(s_BundleRegistries) do
		ResourceManager:AddRegistry(l_Registry:GetInstance(), ResourceCompartment.ResourceCompartment_Game)
	end
end

return BundleManager()
