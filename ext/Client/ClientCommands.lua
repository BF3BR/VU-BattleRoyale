ClientCommands = 
{
    errInvalidCommand = "Invalid Command",

    PlayerPosition = function(p_Args)
        -- If we have any arguments, ignore them
        if #p_Args ~= 0 then
            return ClientCommands.errInvalidCommand
        end

        -- Get the local player
        local s_LocalPlayer = PlayerManager:GetLocalPlayer()
        if s_LocalPlayer == nil then
            return ClientCommands.errInvalidCommand
        end

        -- Check to see if the player is alive
        if s_LocalPlayer.alive == false then
            return ClientCommands.errInvalidCommand
        end

        -- Get the local soldier instance
        local s_LocalSoldier = s_LocalPlayer.soldier
        if s_LocalSoldier == nil then
            return ClientCommands.errInvalidCommand
        end

        -- Get the soldier LinearTransform
        local s_SoldierLinearTransform = s_LocalSoldier.worldTransform

        -- Get the position vector
        local s_Position = s_SoldierLinearTransform.trans

        -- Return the formatted string (x, y, z)
        return "(" .. s_Position.x .. ", " .. s_Position.y .. ", " .. s_Position.z .. ")"        
    end,
}
