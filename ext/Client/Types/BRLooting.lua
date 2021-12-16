---@class BRLooting
BRLooting = class "BRLooting"

local m_Logger = Logger("BRLooting", true)
---@type MapHelper
local m_MapHelper = require "__shared/Utils/MapHelper"
---@type BRLootPickupDatabaseClient
local m_BRLootPickupDatabase = require "Types/BRLootPickupDatabase"
---@type VuBattleRoyaleHud
local m_Hud = require "UI/Hud"

function BRLooting:__init()
	g_Timers:Interval(0.3, self, self.UpdateCloseToPlayerItems)

	-- Read-only
	---@type GameStates|integer
	self.m_GameState = GameStates.None

	self:ResetVars()
end

function BRLooting:ResetVars()
	self.m_LastSelectedLootPickup = nil
	self.m_SentPickupEvent = false
end

-- =============================================
-- Events
-- =============================================

---Custom Client PlayerEvents.GameStateChanged NetEvent
---@param p_GameState GameStates|integer
function BRLooting:OnGameStateChanged(p_GameState)
	if self.m_GameState == p_GameState then
		return
	end

	self.m_GameState = p_GameState

	if p_GameState == GameStates.EndGame then
		self:ResetVars()
	end
end

---VEXT Client Client:UpdateInput Event
function BRLooting:OnClientUpdateInput()
	if self.m_GameState == GameStates.EndGame then
		return
	end

	-- Make sure we have a local player and an alive soldier.
	local s_Player = PlayerManager:GetLocalPlayer()
	if s_Player == nil or s_Player.soldier == nil then
		return
	end

	-- reset `m_SentPickupEvent` when E goes up
	if InputManager:WentKeyUp(InputDeviceKeys.IDK_E) then
		self.m_SentPickupEvent = false
	end

	if InputManager:IsKeyDown(InputDeviceKeys.IDK_E) and self.m_LastSelectedLootPickup ~= nil and not self.m_SentPickupEvent then
		local s_LootPickup = self.m_LastSelectedLootPickup

		if m_MapHelper:SizeEquals(s_LootPickup.m_Items, 1) then
			self.m_SentPickupEvent = true
			NetEvents:Send(
				InventoryNetEvent.PickupItem,
				s_LootPickup.m_Id,
				m_MapHelper:NextItem(s_LootPickup.m_Items).m_Id
			)
		else
			m_Hud:OpenInventory()
		end
	end
end

function BRLooting:UpdateCloseToPlayerItems()
	-- Make sure we have a local player.
	local s_Player = PlayerManager:GetLocalPlayer()
	if s_Player == nil or s_Player.soldier == nil then
		return nil
	end

	-- Our prop-picking ray will start at what the camera is looking at and
	-- extend forward by 3.0m.
	local s_CameraTransform = ClientUtils:GetCameraTransform()
	if s_CameraTransform == nil or s_CameraTransform.trans == Vec3.zero then
		return nil
	end

	local s_LootPickups = m_BRLootPickupDatabase:GetCloseLootPickups(
		s_CameraTransform.trans,
		InventoryConfig.CloseItemSearchRadiusClient
	)

	self:SendCloseLootPickupData(s_LootPickups)
end

---Gets called every UpdatePass_PreSim
---@param p_Entities Entity[]
function BRLooting:OnSpatialRaycast(p_Entities)
	local s_LootPickup = self:GetLootPickup(p_Entities)

	if s_LootPickup ~= nil then
		self.m_LastSelectedLootPickup = s_LootPickup
		if m_MapHelper:SizeEquals(s_LootPickup.m_Items, 1) then
			local s_SingleItem = m_MapHelper:NextItem(s_LootPickup.m_Items)
			self:OnSendOverlayLoot(s_SingleItem, false)
		else
			self:OnSendOverlayLoot(s_LootPickup, true)
		end
	else
		self:OnSendOverlayLoot(nil, false)
		self.m_LastSelectedLootPickup = nil
	end
end

---@param p_Entities Entity[]
function BRLooting:GetLootPickup(p_Entities)
	for _, l_Entity in ipairs(p_Entities) do
		local l_LootPickup = m_BRLootPickupDatabase:GetByInstanceId(l_Entity.instanceId)

		if l_LootPickup ~= nil and l_LootPickup[l_LootPickup.m_Id] == nil then
			return l_LootPickup
		end
	end

	return nil
end

---Returns the mesh or nil
---@param p_Entity Entity
---@return MeshAsset|nil
function BRLooting:GetMesh(p_Entity)
	---@type StaticModelEntityData|DataContainer|nil
	local s_Data = p_Entity.data
	if s_Data == nil then
		return nil
	end

	if s_Data:Is("StaticModelEntityData") then
		s_Data = StaticModelEntityData(s_Data)
		return s_Data.mesh
	end

	return nil
end

--==============================
-- UI related functions
--==============================

function BRLooting:OnSendOverlayLoot(p_ItemOrLootPickup, p_MultiItem)
	if p_ItemOrLootPickup == nil then
		WebUI:ExecuteJS(string.format("SyncOverlayLoot(%s);", nil))
		return
	end

	if p_MultiItem then
		local s_Tier = Tier.Tier1
		for _, l_Item in pairs(p_ItemOrLootPickup.m_Items) do
			if l_Item.m_Definition.m_Tier ~= nil and l_Item.m_Definition.m_Tier > s_Tier then
				s_Tier = l_Item.m_Definition.m_Tier
				if s_Tier == Tier.Tier3 then
					break
				end
			end
		end

		WebUI:ExecuteJS(string.format("SyncOverlayLoot(%s);", json.encode({
			["UIIcon"] = p_ItemOrLootPickup.m_Type.Icon,
			["Name"] = p_ItemOrLootPickup.m_Type.Name,
			["Tier"] = s_Tier,
			["Multi"] = true,
		})))
		return
	end

	local s_ReturnVal = p_ItemOrLootPickup:AsTable(true)

	WebUI:ExecuteJS(string.format("SyncOverlayLoot(%s);", json.encode(s_ReturnVal)))
end

function BRLooting:SendCloseLootPickupData(p_LootPickups)
	if p_LootPickups == nil then
		return
	end

	local s_LootPickupData = {}
	for _, l_LootPickup in pairs(p_LootPickups) do
		local s_Data = l_LootPickup:AsTable(true)

		-- remove redundant data
		s_Data.Transform = nil

		table.insert(s_LootPickupData, s_Data)
	end

	WebUI:ExecuteJS(string.format("SyncCloseLootPickupData(%s);", json.encode(s_LootPickupData)))
end

function BRLooting:OnUnregisterLootPickup(p_LootPickupId)
	-- update LootPickup in WebUI if needed
	if self.m_LastSelectedLootPickup ~= nil and self.m_LastSelectedLootPickup.m_Id == p_LootPickupId then
		self.m_LastSelectedLootPickup = nil
	end
end

return BRLooting()
