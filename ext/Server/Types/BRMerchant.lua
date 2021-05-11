class "BRMerchant"

-- Include the merchant types definitions
require("__shared/MerchantTypes")

function BRMerchant:__init(p_Name, p_Position, p_Direction, p_MerchantType)
    -- Already seen players so we don't greet multiple times
    self.m_GreetedPlayerIds = { }

    -- Hostile player ids
    self.m_HostilePlayerIds = { }

    -- Hold the current merchant transform
    self.m_Transform = LinearTransform()

    -- Merchant type
    self.m_Type = p_MerchantType

    -- Merchant Name
    self.m_Name = p_Name

    -- Bot player id
    self.m_BotPlayerId = -1

    -- Canned greetings that the merchant can say
    self.m_CannedGreetings = {
        "Welcome!",
        "Hola!",
        "Nihao!",
        "Welcome to my humble abode",
        "Greetings and salutations",
        "Get what you need and move on",
        "Don't waste my time",
        "Keep it pushing",
        "Hurry up my",
        "Damn you back again",
        "Man if you don't get your ish and go",
        "Pack it up",
        "Aye mate, 'urry up",
        "Hey bud",
    }

    -- Canned remarks about healing
    self.m_CannedHealing = {
        "You got hurt pretty bad",
        "Heal up",
        "Next time don't catch so many bullets",
        "What are you Bruno Mars out here catching grenades"
    }

    -- Canned remarks about ammo
    self.m_CannedAmmo = {
        "Stack up",
        "Grab what you need",
        "You must be running empty",
        "Maybe you should aim better you wouldn't have run out of ammo",
        "Better aim equals less wasted ammo"
    }
end

function BRMerchant:IsPlayerHostile(p_PlayerId)
    for _, l_HostilePlayerId in pairs(self.m_HostilePlayerIds) do
        if l_HostilePlayerId == p_PlayerId then
            return true
        end
    end

    return false
end


-- Gets the merchants name
function BRMerchant:GetName()
    return self.m_Name
end

function BRMerchant:GetPlayerId()
    return self.m_BotPlayerId
end

function BRMerchant:Spawn()
    -- Create a new fb Player
    local s_MerchantPlayer = PlayerManager:CreatePlayer(self.m_Name, TeamId.TeamNeutral, SquadId.None)

    -- Characters/Soldiers/MpSoldier/SoldierBlueprint 261E43BF-259B-41D2-BF3B-9AE4DDA96AD2 #primary instance
    local s_MpSoldierBlueprint = ResourceManager:SearchForInstanceByGuid(Guid('261E43BF-259B-41D2-BF3B-9AE4DDA96AD2'))
    if s_MpSoldierBlueprint == nil then
        print("err: could not find mp_soldier blueprint.")
        return false
    end

    -- Create a new entry input
    local s_EntryInput = EntryInput()
    s_EntryInput.deltaTime = 1.0 / SharedUtils:GetTickrate()
    
    -- Assign the entry input
    s_MerchantPlayer.input = s_EntryInput

    -- Get the soldier type
    -- Gameplay/Kits/USSupport/VeniceSoldierCustomizationAsset 47949491-F672-4CD6-998A-101B7740F919 #primary instance
    local s_CustomizationAsset = ResourceManager:SearchForInstanceByGuid(Guid('47949491-F672-4CD6-998A-101B7740F919'))
    if s_CustomizationAsset ==  nil then
        print("err: could not load the customization asset.")
        return false
    end

    -- Get the camo unlock
    -- Persistence/Unlocks/Soldiers/Visual/MP/Us/MP_US_Support_Appearance_Wood01/UnlockAsset 23CFF61F-F1E2-4306-AECE-2819E35484D2 #primary instance
    local s_SoldierCamoUnlock = ResourceManager:SearchForInstanceByGuid(Guid('23CFF61F-F1E2-4306-AECE-2819E35484D2'))
    if s_SoldierCamoUnlock == nil then
        print("err: could not get soldier camo unlock.")
        return false
    end

    -- Set the bot's unlocks
    s_MerchantPlayer:SelectUnlockAssets(s_CustomizationAsset, { s_SoldierCamoUnlock })

    -- Get the knife unlock
    -- Weapons/Knife/U_Knife/SoldierWeaponUnlockAsset 8963F500-E71D-41FC-4B24-AE17D18D8C73 #primary instance
    local s_KnifeUnlock = ResourceManager:SearchForInstanceByGuid(Guid('8963F500-E71D-41FC-4B24-AE17D18D8C73'))

    -- Set the bot's weapon
    s_MerchantPlayer:SelectWeapon(WeaponSlot.WeaponSlot_0, s_KnifeUnlock, { } )

    local s_MerchantSoldier = s_MerchantPlayer:CreateSoldier(s_MerchantPlayer.selectedKit, self.m_Transform)
    if s_MerchantSoldier == nil then
        print("err: could not spawn merchant soldier.")
        return false
    end

    -- Spawn the soldier
    s_MerchantPlayer:SpawnSoldierAt(s_MerchantSoldier, self.m_Transform, CharacterPoseType.CharacterPoseType_Stand)

    -- Assign the current player object
    self.m_BotPlayerId = s_MerchantPlayer.id
    return true
end

function BRMerchant:Kill()
    local s_BotPlayer = PlayerManager:GetPlayerById(self.m_BotPlayerId)
    if s_BotPlayer == nil then
        print("err: could not kill player, does not exist")
        return false
    end

    local s_Soldier = s_BotPlayer.soldier
    if s_Soldier == nil then
        print("err: soldier does not exist.")
        return false
    end

    s_Soldier:Kill()

    return true;
end

function BRMerchant:AddHostilePlayer(p_PlayerId)
    -- iterate checking if this player id already exists
    for _, l_PlayerId in pairs(self.m_HostilePlayerIds) do

        -- Player id is already hostile, bail out
        if l_PlayerId == p_PlayerId then
            return
        end
    end

    local s_Player = PlayerManager:GetPlayerById(p_PlayerId)
    if s_Player ~= nil then
        -- Add the player id to the hostile players
        table.insert(self.m_HostilePlayerIds, p_PlayerId)

        -- Let the players know
        ChatManager:Yell(s_Player.name .. " is now hostile to " .. self.m_Name, 2.0)
        print(s_Player.name .. " is now a hostile player to " .. self.m_Name)
    end
end

-- Shamlessly stolen from: https://github.com/NyScorpy/VU-Mods/blob/main/AntiAirBots/ext/server/AntiAirBot.lua
function BRMerchant:AimAt(s_AimPosition)
    s_AimPosition.y = s_AimPosition.y - 0.75
    local s_BotPlayer = self.m_BotPlayer
    if s_BotPlayer == nil then
        return
    end

    local s_BotSoldier = s_BotPlayer.soldier
    if s_BotSoldier == nil then
        return
    end

    local s_BotTransform = s_BotSoldier.worldTransform
    local s_BotPosition = s_BotTransform.trans

    local s_BotPitchPos = Vec3(s_AimPosition.x, s_BotPosition.y, s_AimPosition.z)
	
	local s_PitchB = math.sqrt((s_BotPitchPos.x - s_BotPosition.x)^2 + (s_BotPitchPos.y - s_BotPosition.y)^2 + (s_BotPitchPos.z - s_BotPosition.z)^2)
	local s_PitchA = math.sqrt((s_AimPosition.x - s_BotPitchPos.x)^2 + (s_AimPosition.y - s_BotPitchPos.y)^2 + (s_AimPosition.z - s_BotPitchPos.z)^2)
    local s_PitchC = math.sqrt((s_AimPosition.x - s_BotPosition.x)^2 + (s_AimPosition.y - s_BotPosition.y)^2 + (s_AimPosition.z - s_BotPosition.z)^2)	
    
    local s_PitchAlpha = math.acos((s_PitchA^2 - s_PitchB^2 - s_PitchC^2) / (-2 * s_PitchB * s_PitchC))	

	--if alpha is nan
	if s_PitchAlpha ~= s_PitchAlpha then 
		return
    end
    
    local s_AimPitch = nil
	
	if s_BotPosition.y < s_AimPosition.y then
		s_AimPitch = s_PitchAlpha
	else 
		s_AimPitch = s_PitchAlpha * -1
    end
    
    

    -- RIP
	local aimPos = s_AimPosition
	local botYaw = s_BotPlayer.input.authoritativeAimingYaw
	local botPos = s_BotPosition
	local b = 1
	local botForwardPos = botPos + (s_BotTransform.forward * b)
	local a = math.sqrt((aimPos.x - botForwardPos.x)^2 + (aimPos.z - botForwardPos.z)^2)	
	local c = math.sqrt((aimPos.x - botPos.x)^2 + (aimPos.z - botPos.z)^2)	
	local alpha = math.acos((a^2 - b^2 - c^2) / (-2 * b * c))	
	
	--if alpha is nan
	if alpha ~= alpha then 
		return
	end

	--https://math.stackexchange.com/questions/274712/calculate-on-which-side-of-a-straight-line-is-a-given-point-located
	local d = (botForwardPos.x - botPos.x) * (aimPos.z - botPos.z) - (botForwardPos.z - botPos.z) * (aimPos.x - botPos.x)
	local aimYaw = nil

	if d > 0 then		
		--left
		if alpha + botYaw > (math.pi * 2) then
			aimYaw = alpha + botYaw - (math.pi * 2)
		else
			aimYaw = botYaw + alpha
		end
	else
		--right
		if botYaw - alpha < 0 then
			aimYaw = botYaw - alpha + (math.pi * 2)
		else
			aimYaw = botYaw - alpha
		end
    end


    s_BotPlayer.input.flags = EntryInputFlags.AuthoritativeAiming
    s_BotPlayer.input.authoritativeAimingYaw = aimYaw
    s_BotPlayer.input.authoritativeAimingPitch = s_AimPitch
end

function BRMerchant:ClearHostilePlayers()
    self.m_HostilePlayerIds = { }
end

function BRMerchant:ClearGreetedPlayers()
    self.m_GreetedPlayerIds = { }
end

function BRMerchant:HasGreetedPlayer(p_Player)
    if p_Player == nil then
        return false
    end

    return self.m_GreetedPlayerIds[p_Player.id] ~= nil
end

function BRMerchant:AddDamageForPlayer(p_PlayerId, p_Damage)
    -- Attempt to get the existing player damage by player id
    local s_CurrentDamage = self.m_GreetedPlayerIds[p_PlayerId]

    -- If there is no current damage for the player add them to the list
    if s_CurrentDamage == nil then
        self.m_GreetedPlayerIds[p_PlayerId] = p_Damage
        return
    end

    -- Update the current player damage
    self.m_GreetedPlayerIds[p_PlayerId] = s_CurrentDamage + p_Damage
    if self.m_GreetedPlayerIds[p_PlayerId] > 100.0 then
        self:AddHostilePlayer(p_PlayerId)
    end
end

function BRMerchant:GreetPlayer(p_PlayerId)
    -- Iterate all of the already greeted players
    for _, l_PlayerId in pairs(self.m_GreetedPlayerIds) do
        -- If the player has already been greeted do not greet again
        if l_PlayerId == p_PlayerId then
            return
        end
    end

    local s_Player = PlayerManager:GetPlayerById(p_PlayerId)
    if s_Player == nil then
        return
    end

    -- Add our player to the existing list with 0 damage
    self:AddDamageForPlayer(p_PlayerId, 0.0)

    -- Get the player name
    local s_PlayerName = s_Player.name

    -- Format the print
    local s_CannedGreeting = self.m_CannedGreetings[MathUtils:GetRandomInt(1, #self.m_CannedGreetings)]

    -- Yell at the player only the greeting
    ChatManager:Yell(s_CannedGreeting .. " " .. s_PlayerName, 2.0, p_Player)
end


return Merchant