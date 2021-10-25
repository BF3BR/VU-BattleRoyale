ItemType = {
	Default = 1,
	Weapon = 2,
	Attachment = 3,
	Ammo = 4,
	Consumable = 5,
	Armor = 6,
	Helmet = 7,
	Gadget = 8,
}

SlotType = {
	Default = 1,
	Weapon = 2,
	Attachment = 3,
	Armor = 4,
	Helmet = 5,
	Gadget = 6,
	Backpack = 7,
}

Tier = {
	Tier1 = 1,
	Tier2 = 2,
	Tier3 = 3,
}

LootPickupType = {
	Basic = {
		Name = "Basic",
		Mesh = MeshModel(
			DC(Guid("9670A55C-9EAC-2CEB-85B0-74A6CE759BC8"), Guid("1A70719C-0364-11DE-B228-D0C98D09F591"))
		),
		CheckPrice = false,
		Transform = LinearTransform(
			Vec3(0.5, 0, 0),
			Vec3(0, 0.5, 0),
			Vec3(0, 0, 0.5),
			Vec3(0, 0, 0)
		),
		PhysicsEntityData = nil,
		Icon = "__crate",
	},
	Chest = {
		Name = "Chest",
		Mesh = MeshModel(
			DC(Guid("9670A55C-9EAC-2CEB-85B0-74A6CE759BC8"), Guid("1A70719C-0364-11DE-B228-D0C98D09F591"))
		),
		CheckPrice = false,
		Transform = LinearTransform(
			Vec3(1, 0, 0),
			Vec3(0, 1, 0),
			Vec3(0, 0, 1),
			Vec3(0, 0, 0)
		),
		PhysicsEntityData = DC(
			Guid("1A707199-0364-11DE-B228-D0C98D09F591"), Guid("1A77EBDA-0364-11DE-B228-D0C98D09F591")
		),
		Icon = "__crate",
	},
	Airdrop = {
		Name = "Airdrop",
		Mesh = MeshModel(
			DC(Guid("DA504C92-911F-87DD-0D84-944BD542E835"), Guid("B5CE760E-5220-29BA-3316-23EA12244E88"))
		),
		CheckPrice = false,
		Transform = LinearTransform(
			Vec3(1, 0, 0),
			Vec3(0, 1, 0),
			Vec3(0, 0, 1),
			Vec3(0, 0, 0)
		),
		PhysicsEntityData = DC(Guid("A80588DC-4471-11DE-B7E8-80A76CACD9DC"), Guid("598A91F1-B01C-B253-741C-1CF5669BA476")),
		Icon = "__airdrop",
	},
	Shop = {
		Name = "Shop",
		Mesh = nil,
		CheckPrice = true,
		Transform = LinearTransform(
			Vec3(1, 0, 0),
			Vec3(0, 1, 0),
			Vec3(0, 0, 1),
			Vec3(0, 0, 0)
		),
		PhysicsEntityData = nil,
		Icon = "UI/Art/Persistence/Award/Ribbons/Fancy/gunmaster3d",
	},
}

RandomWeightsTable = {
	["Nothing"] = {
		RandomWeight = 35,
	},
	[ItemType.Weapon] = {
		RandomWeight = 75,
		Tiers = {
			[Tier.Tier1] = {
				RandomWeight = 70,
			},
			[Tier.Tier2] = {
				RandomWeight = 28,
			},
			[Tier.Tier3] = {
				RandomWeight = 2,
			},
		},
	},
	[ItemType.Attachment] = {
		RandomWeight = 30,
	},
	[ItemType.Helmet] = {
		RandomWeight = 25,
		Tiers = {
			[Tier.Tier1] = {
				RandomWeight = 75,
			},
			[Tier.Tier2] = {
				RandomWeight = 23,
			},
			[Tier.Tier3] = {
				RandomWeight = 2,
			},
		},
	},
	[ItemType.Armor] = {
		RandomWeight = 25,
		Tiers = {
			[Tier.Tier1] = {
				RandomWeight = 75,
			},
			[Tier.Tier2] = {
				RandomWeight = 23,
			},
			[Tier.Tier3] = {
				RandomWeight = 2,
			},
		},
	},
	[ItemType.Ammo] = {
		RandomWeight = 35,
	},
	[ItemType.Gadget] = {
		RandomWeight = 15,
	},
	[ItemType.Consumable] = {
		RandomWeight = 15,
	},
}

RandomWeaponPatterns = {
	OnlyWeapon = 1,
	WeaponWithAmmo = 2,
	WeaponWithAttachment = 3,
	WeaponWithAttachmentAndAmmo = 4,
	WeaponWithTwoAmmo = 5,
}

RandomAmmoPatterns = {
	OneItem = 1,
	TwoItems = 2,
	-- ThreeItems = 3,
}

AttachmentType = {
	Optics = 1,
	Barrel = 2,
	Other = 3
}

InventorySlot = {
	-- PrimaryWeapon slots
	PrimaryWeapon = 1,
	PrimaryWeaponAttachmentOptics = 2,
	PrimaryWeaponAttachmentBarrel = 3,
	PrimaryWeaponAttachmentOther = 4,
	-- SecondaryWeapon slots
	SecondaryWeapon = 5,
	SecondaryWeaponAttachmentOptics = 6,
	SecondaryWeaponAttachmentBarrel = 7,
	SecondaryWeaponAttachmentOther = 8,
	-- Gadget slots
	Armor = 9,
	Helmet = 10,
	Gadget = 11,
	-- Backpack slots
	Backpack1 = 12,
	Backpack2 = 13,
	Backpack3 = 14,
	Backpack4 = 15,
	Backpack5 = 16,
	Backpack6 = 17,
	Backpack7 = 18,
	Backpack8 = 19,
	Backpack9 = 20
}
