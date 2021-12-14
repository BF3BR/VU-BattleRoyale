---@class SpectatorServer
SpectatorServer = class "SpectatorServer"

-- =============================================
-- Events
-- =============================================

function SpectatorServer:OnSpectatorRequestPitchAndYaw(p_Player, p_SpectatingId)
	if p_Player == nil or p_SpectatingId == nil then
		return
	end

	local s_Spectating = PlayerManager:GetPlayerById(p_SpectatingId)

	if s_Spectating == nil or s_Spectating.alive == false or s_Spectating.input == nil then
		return
	end

	NetEvents:SendToLocal(
		SpectatorEvents.PostPitchAndYaw,
		p_Player,
		s_Spectating.input.authoritativeAimingPitch,
		s_Spectating.input.authoritativeAimingYaw
	)
end

return SpectatorServer()
