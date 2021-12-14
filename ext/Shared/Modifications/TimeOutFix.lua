---@class TimeOutFix
TimeOutFix = class 'TimeOutFix'

local m_Logger = Logger("TimeOutFix", true)

function TimeOutFix:RegisterCallbacks()
	ResourceManager:RegisterInstanceLoadHandler(Guid('C4DCACFF-ED8F-BC87-F647-0BC8ACE0D9B4'), Guid('B479A8FA-67FF-8825-9421-B31DE95B551A'), self, self.OnClientSettings)
	ResourceManager:RegisterInstanceLoadHandler(Guid('C4DCACFF-ED8F-BC87-F647-0BC8ACE0D9B4'), Guid('818334B3-CEA6-FC3F-B524-4A0FED28CA35'), self, self.OnServerSettings)
end

function TimeOutFix:OnClientSettings(p_Instance)
	p_Instance = ClientSettings(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.loadedTimeout = 25
	p_Instance.loadingTimeout = 25
	p_Instance.ingameTimeout = 25
	m_Logger:Write("Changed ClientSettings")
end

function TimeOutFix:OnServerSettings(p_Instance)
	p_Instance = ServerSettings(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.loadingTimeout = 25
	p_Instance.ingameTimeout = 25
	p_Instance.timeoutTime = 25
	m_Logger:Write("Changed ServerSettings")
end

return TimeOutFix()
