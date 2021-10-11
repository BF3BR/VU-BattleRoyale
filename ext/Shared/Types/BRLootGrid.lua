require "__shared/Types/BRLootGridCell"
require "__shared/Types/BRLootGridCell"

class "BRLootGrid"

function BRLootGrid:__init(p_CellSize)
  self.m_CellSize = p_CellSize

  -- {key -> BRGridCell}
  self.m_GridCells = {}
end

function BRLootGrid:AddLootPickup(p_LootPickup)
  local s_Cell = self:GetOrCreateCellAt(p_LootPickup.m_Transform)
  s_Cell:AddLootPickup(p_LootPickup)
end

function BRLootGrid:RemoveLootPickup(p_LootPickup)
  local s_Cell = self:GetOrCreateCellAt(p_LootPickup.m_Transform)
  s_Cell:RemoveLootPickup(p_LootPickup)
end

function BRLootGrid:GetCellByKey(p_Key)
  return self.m_GridCells[p_Key]
end

function BRLootGrid:GetOrCreateCellAt(p_LinearTransform)
  local s_Key = self:GetKeyFromLT(p_LinearTransform)

  -- create cell if it doesnt exist
  if self.m_GridCells[s_Key] == nil then
    self.m_GridCells[s_Key] = BRLootGridCell()
  end

  return self.m_GridCells[s_Key]
end

function BRLootGrid:GetKey(x, y)
  x = (x or 0) // self.m_CellSize
  y = (y or 0) // self.m_CellSize

  return string.format("%d:%d", x, y)
end

function BRLootGrid:GetKeyFromLT(p_LinearTransform)
  local s_Trans = p_LinearTransform.trans
  return self:GetKey(s_Trans.x, s_Trans.z)
end
