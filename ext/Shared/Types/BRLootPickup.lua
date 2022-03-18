---@class BRLootPickup
BRLootPickup = class "BRLootPickup"

---@type Logger
local m_Logger = Logger("BRLootPickup", false)
---@type MapHelper
local m_MapHelper = require "__shared/Utils/MapHelper"

---@type PickupLight
local m_PickupLight = require "__shared/Types/MeshModel/Assets/PickupLight"
---@type AirdropSmoke
local m_AirdropSmoke = require "__shared/Types/MeshModel/Assets/AirdropSmoke"
---@type AirdropSound
local m_AirdropSound = require "__shared/Types/MeshModel/Assets/AirdropSound"
---@type BRItemFactory
local m_BRItemFactory = require "__shared/Utils/BRItemFactory"

---@param p_Id string @Guid tostring
---@param p_TypeName string
---@param p_Transform LinearTransform
---@param p_Items table<string, BRItem>
function BRLootPickup:__init(p_Id, p_TypeName, p_Transform, p_Items)
	-- Unique Id for each loot pickup
	self.m_Id = p_Id ~= nil and p_Id or tostring(MathUtils:RandomGuid())

	-- ItemEnums - LootPickupType
	---@type LootPickupTypeTable
	self.m_Type = LootPickupType[p_TypeName]

	-- Transform of the pickup
	self.m_Transform = p_Transform

	-- A map of LootPickups {id -> LootPickup}
	self.m_Items = p_Items

	---@type BRLootGridCell|nil
	self.m_ParentCell = nil

	-- [Client] Contains spawned entities {instanceId -> Entity}
	self.m_Entities = nil
end

---@param p_Item BRItem
function BRLootPickup:AddItem(p_Item)
	if p_Item == nil or self:ContainsItemId(p_Item.m_Id) then
		return
	end

	self.m_Items[p_Item.m_Id] = p_Item
end

---@param p_Id string @Guid tostring
function BRLootPickup:RemoveItem(p_Id)
	if self.m_Items[p_Id] ~= nil then
		self.m_Items[p_Id] = nil
		m_Logger:Write("Item removed from LootPickup.")
	end
end

---@param p_Id string @Guid tostring
---@return boolean
function BRLootPickup:ContainsItemId(p_Id)
	return self.m_Items[p_Id] ~= nil
end

---@return MeshModel|nil
function BRLootPickup:GetMesh()
	if self.m_Type.Name ~= "Airdrop" and m_MapHelper:SizeEquals(self.m_Items, 1) then
		-- If there is only one item then use its mesh
		return m_MapHelper:NextItem(self.m_Items).m_Definition.m_Mesh
	elseif self.m_Type.Mesh ~= nil then
		-- If there is a mesh set to the current type
		return self.m_Type.Mesh
	end

	return nil
end

---@return LinearTransform
function BRLootPickup:GetLinearTransform()
	if self.m_Type.Name ~= "Airdrop" and m_MapHelper:SizeEquals(self.m_Items, 1) then
		-- If there is only one item then use its LT
		return m_MapHelper:NextItem(self.m_Items).m_Definition.m_Transform
	elseif self.m_Type.Mesh ~= nil then
		-- If there is a LT set to the current type
		return self.m_Type.Transform
	end

	return LinearTransform()
end

--==============================
-- Spawn / Destroy functions
--==============================

---@return boolean
function BRLootPickup:Spawn()
	if self.m_Entities ~= nil then
		return false
	end

	---Could be BRItemAmmo|BRItemArmor|BRItemAttachment|BRItemConsumable|BRItemGadget|BRItemHelmet|BRItemWeapon
	---@type BRItem
	local s_SingleItem = m_MapHelper:NextItem(self.m_Items)

	local s_Mesh = self:GetMesh()

	if s_Mesh == nil then
		m_Logger:Write("Mesh not found.")
		return false
	end

	local s_LinearTransform = self:GetLinearTransform()

	if s_LinearTransform == nil then
		s_LinearTransform = LinearTransform()
	end

	local s_MeshBus = s_Mesh:Draw(self, s_LinearTransform)

	if s_MeshBus == nil then
		return false
	end

	if self.m_Entities == nil then
		self.m_Entities = {}
	end

	self.m_Entities[s_MeshBus.instanceId] = s_MeshBus

	if SharedUtils:IsClientModule() then
		if self.m_Type.Name == "Airdrop" then
			local s_BusAirdropSound = m_AirdropSound:Draw(self.m_Transform)

			if s_BusAirdropSound ~= nil then
				for l_EntityInstanceId, l_Entity in pairs(s_BusAirdropSound) do
					self.m_Entities[l_EntityInstanceId] = l_Entity
				end
			end

			local s_BusAirdropSmoke = m_AirdropSmoke:Draw(self.m_Transform)

			if s_BusAirdropSmoke ~= nil then
				for l_EntityInstanceId, l_Entity in pairs(s_BusAirdropSmoke) do
					self.m_Entities[l_EntityInstanceId] = l_Entity
				end
			end
		else
			-- Spawn the light on the client side only if the loot has only one item
			if self.m_Type.Name ~= "Airdrop" and m_MapHelper:SizeEquals(self.m_Items, 1) then
				--- m_Tier can be nil that's correct
				---@diagnostic disable-next-line
				local s_BusLight = m_PickupLight:Draw(self.m_Transform, s_SingleItem.m_Definition.m_Tier)

				if s_BusLight ~= nil then
					self.m_Entities[s_BusLight.instanceId] = s_BusLight
				end
			end
		end
	end

	return self.m_Entities ~= nil
end

--==============================
-- Serialization
--==============================

---@param p_Extended boolean
function BRLootPickup:AsTable(p_Extended)
	local s_Items = {}

	for _, l_Item in pairs(self.m_Items) do
		table.insert(s_Items, l_Item:AsTable(p_Extended))
	end

	return {
		Id = self.m_Id,
		Type = self.m_Type.Name,
		Transform = self.m_Transform,
		Items = s_Items,
	}
end

---@param p_Table table
---@return BRLootPickup
function BRLootPickup:CreateFromTable(p_Table)
	local s_Items = {}

	for _, l_Item in pairs(p_Table.Items) do
		local s_Item = m_BRItemFactory:CreateFromTable(l_Item)
		s_Items[s_Item.m_Id] = s_Item
	end

	return BRLootPickup(
		p_Table.Id,
		p_Table.Type,
		p_Table.Transform,
		s_Items
	)
end

---@param p_Table table
function BRLootPickup:UpdateFromTable(p_Table)
	if p_Table.Id ~= self.m_Id then
		return
	end

	---@type table<string, BRItem|BRItemAmmo|BRItemArmor|BRItemAttachment|BRItemConsumable|BRItemGadget|BRItemHelmet|BRItemWeapon>
	local s_Items = {}

	for _, l_Item in pairs(p_Table.Items) do
		local s_Item = m_BRItemFactory:CreateFromTable(l_Item)
		s_Items[s_Item.m_Id] = s_Item
	end

	self.m_Transform = p_Table.Transform
	self.m_Items = s_Items
end

function BRLootPickup:DestroyEntities()
	if self.m_Entities == nil then
		return
	end

	for l_InstanceId, l_Entity in pairs(self.m_Entities) do
		l_Entity:FireEvent("Disable")
		l_Entity:FireEvent("Destroy")
		l_Entity:Destroy()

		self.m_Entities[l_InstanceId] = nil
	end

	self.m_Entities = nil
end

function BRLootPickup:Destroy()
	self:DestroyEntities()

	self.m_Type = nil
	self.m_Transform = nil
	self.m_Items = nil
	self.m_ParentCell = nil
end
