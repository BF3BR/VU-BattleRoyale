PickupsConfig = {
    InteractionRadius = 2.5,
    WeaponTransform = LinearTransform(),
    MarkerTransform = Vec3(),
    MarkerShowRadius = 100,
    MarkerHideRadius = 1,
    Tiers = {
        [1] = {
            Message = "MOZAMBIQUE HERE",
            HudIcon = UIHudIcon.UIHudIcon_WeaponPickupTier1,
            Weapons = {
                {
                    Name = "Weapons/PP2000/U_PP2000",
                    Attachments = {
                        "Weapons/PP2000/U_PP2000_Eotech",
                        "Weapons/PP2000/U_PP2000_Extendedmag",
                    }
                }
            }
        },
        [2] = {
            Message = "BAGUETTE",
            HudIcon = UIHudIcon.UIHudIcon_WeaponPickupTier2,
            Weapons = {
                {
                    Name = "Weapons/M249/U_M249",
                    Attachments = {
                        "Weapons/M249/U_M249_Foregrip",
                        "Weapons/M249/U_M249_M145",
                    }
                },{
                    Name = "Weapons/SG553LB/U_SG553LB",
                    Attachments = {
                        "Weapons/SG553LB/U_SG553LB_EOTech",
                        "Weapons/SG553LB/U_SG553LB_Foregrip",
                    }
                }
            }
        },
        [3] = {
            Message = "BRRRRRRRRRRT",
            HudIcon = UIHudIcon.UIHudIcon_WeaponPickupTier3,
            Weapons = {
                {
                    Name = "Weapons/Model98B/U_M98B",
                    Attachments = {
                        "Weapons/Model98B/U_M98B_EOTech",
                        "Weapons/Model98B/U_M98B_Kobra",
                    }
                },{
                    Name = "Weapons/XP2_ACR/U_ACR",
                    Attachments = {
                        "Weapons/XP2_ACR/U_ACR_RX01",
                        "Weapons/XP2_ACR/U_ACR_TargetPointer",
                    }
                }
            }
        }
    }   
}