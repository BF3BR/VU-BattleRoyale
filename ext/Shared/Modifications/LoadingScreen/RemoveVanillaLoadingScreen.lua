---@class RemoveVanillaLoadingScreen
RemoveVanillaLoadingScreen = class 'RemoveVanillaLoadingScreen'

local m_Logger = Logger("RemoveVanillaLoadingScreen", false)
local m_LoadingScreenLookup = require "__shared/Modifications/LoadingScreen/LoadingScreenLookup"

function RemoveVanillaLoadingScreen:OnExtensionLoaded()
	for _, l_LevelLoadingScreenInfo in pairs(m_LoadingScreenLookup) do
		local s_UILevelDescriptionComponent = ResourceManager:FindInstanceByGuid(table.unpack(l_LevelLoadingScreenInfo.Guids))

		if s_UILevelDescriptionComponent ~= nil then
			s_UILevelDescriptionComponent = UILevelDescriptionComponent(s_UILevelDescriptionComponent)
			s_UILevelDescriptionComponent:MakeWritable()
			s_UILevelDescriptionComponent.loadingMusicPath = ""
			s_UILevelDescriptionComponent.loadingImagePath = ""
			s_UILevelDescriptionComponent.mpLoadingAssetPath = ""
		end
	end

	m_Logger:Write("Removed all vanilla LoadingScreens")
end

function RemoveVanillaLoadingScreen:OnExtensionUnloading()
	if SharedUtils:IsServerModule() then
		return
	end

	for _, l_LevelLoadingScreenInfo in pairs(m_LoadingScreenLookup) do
		local s_UILevelDescriptionComponent = ResourceManager:FindInstanceByGuid(table.unpack(l_LevelLoadingScreenInfo.Guids))

		if s_UILevelDescriptionComponent ~= nil then
			s_UILevelDescriptionComponent = UILevelDescriptionComponent(s_UILevelDescriptionComponent)
			s_UILevelDescriptionComponent.loadingMusicPath = l_LevelLoadingScreenInfo.LoadingMusicPath
			s_UILevelDescriptionComponent.loadingImagePath = l_LevelLoadingScreenInfo.LoadingImagePath
			s_UILevelDescriptionComponent.mpLoadingAssetPath = "UI/Assets/LoadingScreen"
		end
	end

	m_Logger:Write("Added back all vanilla LoadingScreens")
end

return RemoveVanillaLoadingScreen()
