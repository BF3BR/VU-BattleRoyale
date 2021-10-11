class "BRLootGridCell"

function BRLootGridCell:__init()
  -- references to LootPickups that reside in this cell
  self.m_LootPickups = {}

  -- a serial version number, used to check mismatches between client/server
  self.m_Version = 0

  -- [server] references to the currently subscribed players to this cell
  self.m_Subscribers = {}

  -- [client] timestamp from when this cell was last updated used to cleanup old/distant cells
  self.m_LastUpdated = 0
end

function BRLootGridCell:AddLootPickup(p_LootPickup)
  self.m_LootPickups[p_LootPickup.m_Id] = p_LootPickup
  p_LootPickup.m_ParentCell = self
end

function BRLootGridCell:RemoveLootPickup(p_LootPickup)
  self.m_LootPickups[p_LootPickup.m_Id] = nil
  p_LootPickup.m_ParentCell = nil
end

function BRLootGridCell:AsTable()
  return {Version = self.m_Version}
end

function BRLootGridCell:Destroy()
  -- Do not destroy anything here, just nil the references
  self.m_LootPickups = nil
  self.m_Subscribers = nil
end
