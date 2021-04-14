class 'BundleManager'

local m_Logger = Logger("BundleManager", true)

local m_BundleConfig = {
	--[[ {
		SuperBundle = 'Levels/COOP_006/COOP_006',
		Bundles = { 'Levels/COOP_006/COOP_006' },
		Registry = DC(Guid('23535E3D-E72F-11DF-99CA-879440EEBD7A'), Guid('51C54150-0ABF-03BD-EADE-1876AAD3EC8D'))
	},
	{
		SuperBundle = 'Levels/XP5_001/XP5_001',
		Bundles = { 'Levels/XP5_001/XP5_001', 'Levels/XP5_001/CQL' },
		Registry = DC(Guid('25BBF5C7-2AD0-4C4C-9AF3-57CCD9CAB017'), Guid('45977445-06C0-0441-4C91-90E41D64ECE2'))
	}, --]]
	{
		SuperBundle = 'Levels/COOP_010/COOP_010',
		Bundles = { 'Levels/COOP_010/COOP_010' },
		Registry = DC(Guid('333BDB92-E69D-11DF-9B0E-AF9CA6E0236B'), Guid('2C804637-3B56-6DDB-92C8-81D094EA806B'))
	}, 
}


function BundleManager:__init()
	self:RegisterVars()
end

function BundleManager:RegisterVars()
	self.m_LevelName = ""
end

function BundleManager:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	if self.m_LevelName == p_LevelName then
		return
	end

	for _, l_Level in pairs(m_BundleConfig) do
		ResourceManager:MountSuperBundle(l_Level.SuperBundle)
	end

	self.m_LevelName = p_LevelName
end

function BundleManager:OnLoadBundles(p_Hook, p_Bundles, p_Compartment)
	if #p_Bundles == 1 and p_Bundles[1] == SharedUtils:GetLevelName() then
		local s_Bundles = {}

		for _, l_Level in ipairs(m_BundleConfig) do
			for _, l_Bundle in ipairs(l_Level.Bundles) do
				table.insert(s_Bundles, l_Bundle)
			end
		end

		table.insert(s_Bundles, p_Bundles[1])

		m_Logger:Write("Injecting bundles:")
		m_Logger:Write(s_Bundles)

		p_Hook:Pass(s_Bundles, p_Compartment)
	end
end

function BundleManager:OnTerrainLoad(p_Hook, p_TerrainAssetName)
	local s_LevelId = LevelNameHelper:GetLevelName()

	if not p_TerrainAssetName:match(s_LevelId:lower()) then
		m_Logger:Write("Preventing terrain load:"..p_TerrainAssetName)
		p_Hook:Return()
	end
end

function BundleManager:OnRegisterEntityResources(p_LevelData)
	m_Logger:Write("Adding registries:")
	for _, l_Level in ipairs(m_BundleConfig) do
		m_Logger:Write(l_Level.SuperBundle)
		ResourceManager:AddRegistry(l_Level.Registry:GetInstance(), ResourceCompartment.ResourceCompartment_Game)
	end
end


return BundleManager
