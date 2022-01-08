---@class LootPickupTypeTable
---@field Name string
---@field Mesh MeshModel|nil
---@field CheckPrice boolean
---@field Transform LinearTransform
---@field PhysicsEntityData DC|nil
---@field Icon string

---@class LootPickupType
LootPickupType = {
	---@type LootPickupTypeTable
	Basic = {
		Name = "Basic",
		Mesh = MeshModel(
			DC(Guid("9670A55C-9EAC-2CEB-85B0-74A6CE759BC8"), Guid("1A70719C-0364-11DE-B228-D0C98D09F591"))
		),
		CheckPrice = false,
		Transform = LinearTransform(
			Vec3(0.5, 0.0, 0.0),
			Vec3(0.0, 0.5, 0.0),
			Vec3(0.0, 0.0, 0.5),
			Vec3(0.0, 0.0, 0.0)
		),
		PhysicsEntityData = nil,
		Icon = "__crate",
	},
	---@type LootPickupTypeTable
	Chest = {
		Name = "Chest",
		Mesh = MeshModel(
			DC(Guid("9670A55C-9EAC-2CEB-85B0-74A6CE759BC8"), Guid("1A70719C-0364-11DE-B228-D0C98D09F591"))
		),
		CheckPrice = false,
		Transform = LinearTransform(
			Vec3(1.0, 0.0, 0.0),
			Vec3(0.0, 1.0, 0.0),
			Vec3(0.0, 0.0, 1.0),
			Vec3(0.0, 0.0, 0.0)
		),
		PhysicsEntityData = DC(
			Guid("1A707199-0364-11DE-B228-D0C98D09F591"), Guid("1A77EBDA-0364-11DE-B228-D0C98D09F591")
		),
		Icon = "__crate",
	},
	---@type LootPickupTypeTable
	Airdrop = {
		Name = "Airdrop",
		Mesh = MeshModel(
			DC(Guid("DA504C92-911F-87DD-0D84-944BD542E835"), Guid("B5CE760E-5220-29BA-3316-23EA12244E88"))
		),
		CheckPrice = false,
		Transform = LinearTransform(
			Vec3(1.0, 0.0, 0.0),
			Vec3(0.0, 1.0, 0.0),
			Vec3(0.0, 0.0, 1.0),
			Vec3(0.0, 0.0, 0.0)
		),
		PhysicsEntityData = DC(Guid("A80588DC-4471-11DE-B7E8-80A76CACD9DC"), Guid("598A91F1-B01C-B253-741C-1CF5669BA476")),
		Icon = "__airdrop",
	},
	---@type LootPickupTypeTable
	Shop = {
		Name = "Shop",
		Mesh = nil,
		CheckPrice = true,
		Transform = LinearTransform(
			Vec3(1.0, 0.0, 0.0),
			Vec3(0.0, 1.0, 0.0),
			Vec3(0.0, 0.0, 1.0),
			Vec3(0.0, 0.0, 0.0)
		),
		PhysicsEntityData = nil,
		Icon = "UI/Art/Persistence/Award/Ribbons/Fancy/gunmaster3d",
	},
}
