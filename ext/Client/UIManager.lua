class "UIManager"

local m_ConnectionHelper = require("__shared/Utils/ConnectionHelper")

local m_MPMenuScreenAsset = DC(Guid("993445AF-2476-11E0-834E-C984E80F7234"), Guid("5FE2571D-D0AD-CF75-3CB6-43A43AFC0E8B"))
local m_UISquadCompData = DC(Guid("88DECC5B-43E8-11E0-A213-8C5E94EEBB5D"), Guid("538F9596-5BED-84BC-92E6-99595A9A69E5 "))

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

function UIManager:__init()
	self:RegisterEvents()
end

function UIManager:RegisterEvents()
	m_MPMenuScreenAsset:RegisterLoadHandler(self, self.ModifyMenu)
end

function UIManager:ModifyMenu(p_Instance)
	local s_ScreenAsset = UIScreenAsset(p_Instance)
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
	s_CenterHeaderBinding.header = UIDataSourceInfo()		-- remove dynamic gamemode lookup
	s_CenterHeaderBinding.staticHeader = "YOUR SQUAD"
	local s_UISquadComp = ResourceManager:SearchForDataContainer("UI/UIComponents/UISquadComp")
	if s_UISquadComp ~= nil then
		s_CenterHeaderBinding.subHeader.dataCategory = UISquadCompData(s_UISquadComp)
	else
		m_UISquadCompData:RegisterLoadHandler(self, self.FinishModifyMenu)
	end
	s_CenterHeaderBinding.subHeader.dataKey = -917467149

	-- Set map header text
	local s_MapHeaderNode = WidgetNode(s_ScreenAsset.nodes[m_WidgetIndexes.mapHeader])
	local s_MapHeaderBinding = UIPageHeaderBinding(s_MapHeaderNode.dataBinding)
	s_MapHeaderBinding:MakeWritable()
	s_MapHeaderBinding.header = UIDataSourceInfo()		-- remove dynamic gamemode lookup
	s_MapHeaderBinding.staticHeader = "BATTLE ROYALE"

	-- Remove gamemodeInfo
	s_ScreenAsset.nodes:erase(m_WidgetIndexes.gamemodeInfo)
end

function UIManager:FinishModifyMenu(p_Instance)
	local s_UISquadCompData = UISquadCompData(p_Instance)

	local s_ScreenAsset = UIScreenAsset(ResourceManager:SearchForDataContainer("UI/Flow/Screen/IngameMenuMP"))
	s_ScreenAsset:MakeWritable()

	local s_CenterHeaderNode = WidgetNode(s_ScreenAsset.nodes[m_WidgetIndexes.gamemodeInfoHeader])
	local s_CenterHeaderBinding = UIPageHeaderBinding(s_CenterHeaderNode.dataBinding)
	s_CenterHeaderBinding:MakeWritable()
	s_CenterHeaderBinding.subHeader.dataCategory = s_UISquadCompData
end

function UIManager:_GetStaticItem(p_Name)
	local s_ListItem = StaticListItem()
	s_ListItem.itemName = p_Name

	return s_ListItem
end

if g_UIManager == nil then
	g_UIManager = UIManager()
end

return g_UIManager
