---@class VanillaUIModifier
VanillaUIModifier = class "VanillaUIModifier"

local m_Logger = Logger("VanillaUIModifier", false)
local m_ArrayHelper = require "__shared/Utils/ArrayHelper"

local m_HudScreenAsset = DC(Guid("D05E6145-8816-11DF-AA1B-BA7094D44A63"), Guid("E63B81E3-67FA-F6C3-2980-D899055DAB0C"))
local m_HudMpScreenAsset = DC(Guid("3343E3E3-F3C4-11DF-90D5-D8126D045289"), Guid("241F5AE9-2027-508E-98D1-506928AA1E3A"))
local m_HudConquestScreenAsset = DC(Guid("0C14516A-02F0-4A81-B88B-6010A6A6DDC6"), Guid("2A2B8447-C938-407A-951A-C3BA099F0374"))
--local m_MPMenuScreenAsset = DC(Guid("993445AF-2476-11E0-834E-C984E80F7234"), Guid("5FE2571D-D0AD-CF75-3CB6-43A43AFC0E8B"))

local m_UINametagCompData = DC(Guid("2E84F3D0-8DB2-11DF-9DBF-90F9B54D8E77"), Guid("1061D316-4366-BCA2-27D6-50D43543A41D"))
--local m_UISquadCompData = DC(Guid("88DECC5B-43E8-11E0-A213-8C5E94EEBB5D"), Guid("538F9596-5BED-84BC-92E6-99595A9A69E5"))
local m_UITrackingtagCompData = DC(Guid("EEA59917-3FF2-11E0-B6B0-A41634C402A3"), Guid("70998786-14D8-2E5A-CB44-F4C2DA29EE29"))
local m_UI3dIconCompData = DC(Guid("F9331953-F3F2-11DF-BAF2-BDEFE75B56CA"), Guid("08FB6671-269A-2006-B8E1-AD901370C589"))
local m_CapturepointtagCompData = DC(Guid("37281D8D-BB5A-11DF-B69D-B42F116347F5"), Guid("DD387B90-E2E8-1408-A934-9ADEC54F54B1"))
local m_3dLaserTagCompData = DC(Guid("60FAA143-B12F-11E0-99F6-E16488F9EB8F"), Guid("6866048A-4072-0257-D6D1-21785F9E8C10"))
local m_MapmarkertagCompData = DC(Guid("5D9E85C0-CBC1-11DF-97A3-94A49B4BAE71"), Guid("6F016F11-321C-EDD4-6D66-8F65485808E7"))
local m_TeamSupportTagCompData = DC(Guid("4EA75D30-765F-11E0-A82A-C41FAD23BE85"), Guid("97C619F1-A2E3-DC55-02F2-BA61BA3CD36B"))
local m_InteractionCompData = DC(Guid("35DF1891-EB38-11DF-9230-E11388AEEF3E"), Guid("F159BE6E-611C-C1D7-2E49-DC50AD11A42A"))
local m_ColorCorrectionCompData = DC(Guid("3A3E5533-4B2A-11E0-A20D-FE03F1AD0E2F"), Guid("9CDAC6C3-9D3E-48F1-B8D9-737DB28AE936"))
local m_DofComponentData = DC(Guid("3A3E5533-4B2A-11E0-A20D-FE03F1AD0E2F"), Guid("52FD86B6-00BA-45FC-A87A-683F72CA6916"))
local m_ShowRoomCameraData = DC(Guid("08F255D1-499D-4090-B114-4CE8D1B3AC65"), Guid("528655FC-2653-4D5B-B55D-E6CBF997FC19"))

local m_IconTextureAtlas = DC(Guid("187A8BC1-B761-11E0-B02E-AE94D7595F06"), Guid("FDD01ACB-50A9-BA73-DD3A-849BE7E30144"))

local m_WidgetIndexes = {
	itemList = 1,
	itemListHeader = 2,
	gamemodeInfo = 5,
	gamemodeInfoHeader = 4,
	map = 10,
	mapHeader = 3,
}

local m_MenuItems = {
	"ID_M_IGMMP_RESUME",
	"ID_M_IGMMP_OPTIONS",
	"ID_M_IGMMP_SUICIDE",
	"ID_M_IGMMP_QUIT",
}

function VanillaUIModifier:RegisterCallbacks()
	m_HudScreenAsset:RegisterLoadHandler(self, self.OnHudScreen)
	m_HudMpScreenAsset:RegisterLoadHandler(self, self.OnHudMpScreen)
	m_HudConquestScreenAsset:RegisterLoadHandler(self, self.OnHudConquestScreen)

	m_UINametagCompData:RegisterLoadHandler(self, self.OnUINametagCompData)

	m_UITrackingtagCompData:RegisterLoadHandler(self, self.OnUITrackingtagCompData) -- Need healing / repair / ammo indicators
	m_UI3dIconCompData:RegisterLoadHandler(self, self.OnUI3dIconCompData) -- Grenade icons
	m_CapturepointtagCompData:RegisterLoadHandler(self, self.OnUI3dIconCompData)
	m_3dLaserTagCompData:RegisterLoadHandler(self, self.OnUI3dIconCompData)
	m_MapmarkertagCompData:RegisterLoadHandler(self, self.OnUI3dIconCompData)
	m_TeamSupportTagCompData:RegisterLoadHandler(self, self.OnUI3dIconCompData)
	m_InteractionCompData:RegisterLoadHandler(self, self.OnUI3dIconCompData)
	m_ColorCorrectionCompData:RegisterLoadHandler(self, self.OnBlurredBlueScreen)
	m_DofComponentData:RegisterLoadHandler(self, self.OnBlurredBlueScreen)

	m_ShowRoomCameraData:RegisterLoadHandler(self, self.OnShowRoomCamera)

	m_IconTextureAtlas:RegisterLoadHandler(self, self.OnIconTexture)

	-- DC:WaitForInstances({ m_MPMenuScreenAsset, m_UISquadCompData }, self, self.ModifyMenu)
end

function VanillaUIModifier:DeregisterCallbacks()
	m_HudScreenAsset:Deregister()
	m_HudMpScreenAsset:Deregister()
	m_HudConquestScreenAsset:Deregister()

	m_UINametagCompData:Deregister()

	m_UITrackingtagCompData:Deregister()
	m_UI3dIconCompData:Deregister()
	m_CapturepointtagCompData:Deregister()
	m_3dLaserTagCompData:Deregister()
	m_MapmarkertagCompData:Deregister()
	m_TeamSupportTagCompData:Deregister()
	m_InteractionCompData:Deregister()
	m_ColorCorrectionCompData:Deregister()
	m_DofComponentData:Deregister()

	m_ShowRoomCameraData:Deregister()

	m_IconTextureAtlas:Deregister()

	--m_MPMenuScreenAsset:Deregister()
	--m_UISquadCompData:Deregister()
end

function VanillaUIModifier:OnHudScreen(p_ScreenAsset)
	self:KeepNodes(p_ScreenAsset, { "InteractionManager", "DamageIndicator" })
end

function VanillaUIModifier:OnHudMpScreen(p_ScreenAsset)
	self:KeepNodes(p_ScreenAsset, { "LatencyIndicator", "AdminYellMessage", "Hitindicator" })
end

function VanillaUIModifier:OnHudConquestScreen(p_ScreenAsset)
	self:KeepNodes(p_ScreenAsset, { "Minimap", "MapmarkerManager" })
end

function VanillaUIModifier:OnUINametagCompData(p_UIComponentData)
	p_UIComponentData.showLabelRange = 0.0
	p_UIComponentData.teamRadioDistance = 0.0
end

function VanillaUIModifier:OnUITrackingtagCompData(p_UIComponentData)
	p_UIComponentData.showMedicHealthThreshold = 0
	p_UIComponentData.showEngineerArmorThreshold = 0
	p_UIComponentData.showSupportAmmoThreshold = 0
	p_UIComponentData.teamRadioDistance = 0
end

function VanillaUIModifier:OnUI3dIconCompData(p_UIComponentData)
	p_UIComponentData.iconSize = 0
	p_UIComponentData.snapIcons = false
	p_UIComponentData.drawDistance = 0
	p_UIComponentData.teamRadioDistance = 0
	p_UIComponentData.onlyShowSnapped = true
	p_UIComponentData.trackerHudRadiusX = 20
	p_UIComponentData.trackerHudRadiusY = 20
	p_UIComponentData.circularSnap = true
end

function VanillaUIModifier:OnBlurredBlueScreen(p_UIComponentData)
	p_UIComponentData.excluded = true
end

function VanillaUIModifier:OnShowRoomCamera(p_Instance)
	p_Instance.enabled = true
	p_Instance.priority = 999
end

function VanillaUIModifier:OnIconTexture(p_TextureAtlasAsset)
	for i = #p_TextureAtlasAsset.icons, 1, -1 do
		local s_Icon = p_TextureAtlasAsset.icons[i]

		if s_Icon ~= nil then
			if s_Icon.iconType == UIHudIcon.UIHudIcon_SquadLeader or
				s_Icon.iconType == UIHudIcon.UIHudIcon_SquadleaderBg or
				s_Icon.iconType == UIHudIcon.UIHudIcon_Gunship or
				s_Icon.iconType == UIHudIcon.UIHudIcon_PercetageBarMiddle or
				s_Icon.iconType == UIHudIcon.UIHudIcon_PercetageBarEdge or
				s_Icon.iconType == UIHudIcon.UIHudIcon_PercentageBarBackground then
				for _, l_State in ipairs(s_Icon.states) do
					for _, l_TextureInfo in ipairs(l_State.textureInfos) do
						l_TextureInfo.minUv = Vec2(0.0, 0.0)
						l_TextureInfo.maxUv = Vec2(0.0, 0.0)
					end
				end
			end

			if s_Icon.iconType == UIHudIcon.UIHudIcon_KitAssault or
				s_Icon.iconType == UIHudIcon.UIHudIcon_KitEngineer or
				s_Icon.iconType == UIHudIcon.UIHudIcon_KitSupport or
				s_Icon.iconType == UIHudIcon.UIHudIcon_KitRecon or
				s_Icon.iconType == UIHudIcon.UIHudIcon_NeedMedic or
				s_Icon.iconType == UIHudIcon.UIHudIcon_NeedAmmo then
				-- replace kit icons for squad
				s_Icon.states[1].textureInfos[1].minUv = Vec2(0.50090625, 0.6659453125)
				s_Icon.states[1].textureInfos[1].maxUv = Vec2(0.5546875, 0.6845703125)

				if s_Icon.states[2] ~= nil then
					-- replace kit icons for squad (colorblind) + top margin
					s_Icon.states[2].textureInfos[1].minUv = Vec2(0.00871875, 0.5936796875)
					s_Icon.states[2].textureInfos[1].maxUv = Vec2(0.0625, 0.6123046875)
				end
			end

			-- add top margin to icons
			if s_Icon.iconType == UIHudIcon.UIHudIcon_Player then
				-- teammate
				s_Icon.states[1].textureInfos[1].minUv = Vec2(0.4579375, 0.8905546875)
				s_Icon.states[1].textureInfos[1].maxUv = Vec2(0.51171875, 0.9091796875)
				-- enemy
				-- s_Icon.states[2].textureInfos[1].minUv = Vec2(0.00871875, 0.74309375)
				-- s_Icon.states[2].textureInfos[1].maxUv = Vec2(0.0625, 0.76171875)
				-- removing the enemy nametags completely (only works for no color blind mode)
				s_Icon.states[2].textureInfos[1].minUv = Vec2(0.0, 0.0)
				s_Icon.states[2].textureInfos[1].maxUv = Vec2(0.0, 0.0)
				-- squad
				s_Icon.states[3].textureInfos[1].minUv = Vec2(0.50090625, 0.6659453125)
				s_Icon.states[3].textureInfos[1].maxUv = Vec2(0.5546875, 0.6845703125)
				-- colorblind
				s_Icon.states[4].textureInfos[1].minUv = Vec2(0.00871875, 0.5936796875)
				s_Icon.states[4].textureInfos[1].maxUv = Vec2(0.0625, 0.6123046875)
			end
		end
	end
end

-- Edit selected UIScreenAsset's nodes
function VanillaUIModifier:EditNodes(p_Screen, p_NodeNames, p_CheckValue)
	p_NodeNames = m_ArrayHelper:ToMap(p_NodeNames, true)

	-- erase nodes
	for i = #p_Screen.nodes, 1, -1 do
		local s_Node = p_Screen.nodes[i]

		if s_Node ~= nil then
			if p_NodeNames[s_Node.name] ~= p_CheckValue then
				p_Screen.nodes:erase(i)
			end
		end
	end
end

-- Erase selected nodes of a screen
function VanillaUIModifier:EraseNodes(p_Screen, p_NodeNames)
	self:EditNodes(p_Screen, p_NodeNames, nil)
end

-- Keep selected nodes of a screen
function VanillaUIModifier:KeepNodes(p_Screen, p_NodeNames)
	self:EditNodes(p_Screen, p_NodeNames, true)
end

-- Patch MPMenu list items and widgets
function VanillaUIModifier:ModifyMenu(p_MPMenuScreenAsset, p_UISquadCompData)
	local s_ScreenAsset = UIScreenAsset(p_MPMenuScreenAsset)
	s_ScreenAsset:MakeWritable()

	-- Replace menu items
	local s_ItemListNode = WidgetNode(s_ScreenAsset.nodes[m_WidgetIndexes.itemList])
	local s_ItemListBinding = UIListDataBinding(s_ItemListNode.dataBinding)
	s_ItemListBinding:MakeWritable()
	s_ItemListBinding.listQuery = UIDataSourceInfo() -- remove dynamic item lookup

	for _, l_ItemName in ipairs(m_MenuItems) do
		s_ItemListBinding.staticItems:add(self:_GetStaticItem(l_ItemName))
	end

	-- Set gamemode info header text
	local s_CenterHeaderNode = WidgetNode(s_ScreenAsset.nodes[m_WidgetIndexes.gamemodeInfoHeader])
	local s_CenterHeaderBinding = UIPageHeaderBinding(s_CenterHeaderNode.dataBinding)
	s_CenterHeaderBinding:MakeWritable()
	s_CenterHeaderBinding.header = UIDataSourceInfo() -- remove dynamic gamemode lookup
	s_CenterHeaderBinding.staticHeader = "YOUR SQUAD"
	s_CenterHeaderBinding.subHeader.dataCategory = UISquadCompData(p_UISquadCompData)
	s_CenterHeaderBinding.subHeader.dataKey = -917467149

	-- Set map header text
	local s_MapHeaderNode = WidgetNode(s_ScreenAsset.nodes[m_WidgetIndexes.mapHeader])
	local s_MapHeaderBinding = UIPageHeaderBinding(s_MapHeaderNode.dataBinding)
	s_MapHeaderBinding:MakeWritable()
	s_MapHeaderBinding.header = UIDataSourceInfo() -- remove dynamic gamemode lookup
	s_MapHeaderBinding.staticHeader = "BATTLE ROYALE"

	-- Remove gamemodeInfo
	s_ScreenAsset.nodes:erase(m_WidgetIndexes.gamemodeInfo)

	m_Logger:Write("Modified MP Menu")
end

function VanillaUIModifier:_GetStaticItem(p_Name)
	local s_ListItem = StaticListItem()
	s_ListItem.itemName = p_Name

	return s_ListItem
end

return VanillaUIModifier()
