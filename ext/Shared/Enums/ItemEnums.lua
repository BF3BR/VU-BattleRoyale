---@class ItemType
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

---@class SlotType
SlotType = {
	Default = 1,
	Weapon = 2,
	Attachment = 3,
	Armor = 4,
	Helmet = 5,
	Gadget = 6,
	Backpack = 7,
}


---@class Tier
Tier = {
	Tier1 = 1,
	Tier2 = 2,
	Tier3 = 3,
}

---@class RandomWeightsTable
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

---@class RandomWeaponPatterns
RandomWeaponPatterns = {
	OnlyWeapon = 1,
	WeaponWithAmmo = 2,
	WeaponWithAttachmentAndAmmo = 3,
	WeaponWithTwoAmmo = 4,
}

---@class RandomAmmoPatterns
RandomAmmoPatterns = {
	OneItem = 1,
	TwoItems = 2,
	-- ThreeItems = 3,
}

---@class AttachmentType
AttachmentType = {
	Optics = 1,
	Barrel = 2,
	Other = 3
}

---@class InventorySlot
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
