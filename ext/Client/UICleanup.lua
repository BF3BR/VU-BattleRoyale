class 'UICleanup'

function UICleanup:__init()
    self.m_UIPushScreenHook =  Hooks:Install('UI:PushScreen', 999, self, self.OnUIPushScreen)
	
	self.m_HudConquestScreen = ResourceManager:RegisterInstanceLoadHandler(Guid('0C14516A-02F0-4A81-B88B-6010A6A6DDC6'), Guid('2A2B8447-C938-407A-951A-C3BA099F0374'), self, self.OnHudConquestScreen)
	
	-- need healing/ repair/ ammo indicators
	self.m_UITrackingtagCompData = ResourceManager:RegisterInstanceLoadHandler(Guid('EEA59917-3FF2-11E0-B6B0-A41634C402A3'), Guid('70998786-14D8-2E5A-CB44-F4C2DA29EE29'), self, self.OnUITrackingtagCompData)
	-- Grenade Indicator
	self.m_UIAlerttagCompData = ResourceManager:RegisterInstanceLoadHandler(Guid('F9331953-F3F2-11DF-BAF2-BDEFE75B56CA'), Guid('08FB6671-269A-2006-B8E1-AD901370C589'), self, self.OnUI3dIconCompData)
	-- Just to have it complete
	self.m_UICapturepointtagCompData = ResourceManager:RegisterInstanceLoadHandler(Guid('37281D8D-BB5A-11DF-B69D-B42F116347F5'), Guid('DD387B90-E2E8-1408-A934-9ADEC54F54B1'), self, self.OnUI3dIconCompData)
	self.m_UI3dLaserTagCompData = ResourceManager:RegisterInstanceLoadHandler(Guid('60FAA143-B12F-11E0-99F6-E16488F9EB8F'), Guid('6866048A-4072-0257-D6D1-21785F9E8C10'), self, self.OnUI3dIconCompData)
	self.m_UIMapmarkertagCompData = ResourceManager:RegisterInstanceLoadHandler(Guid('5D9E85C0-CBC1-11DF-97A3-94A49B4BAE71'), Guid('6F016F11-321C-EDD4-6D66-8F65485808E7'), self, self.OnUI3dIconCompData)
	self.m_UITeamSupportTagCompData = ResourceManager:RegisterInstanceLoadHandler(Guid('4EA75D30-765F-11E0-A82A-C41FAD23BE85'), Guid('97C619F1-A2E3-DC55-02F2-BA61BA3CD36B'), self, self.OnUI3dIconCompData)
	--self.m_UIInteractionCompData = ResourceManager:RegisterInstanceLoadHandler(Guid('35DF1891-EB38-11DF-9230-E11388AEEF3E'), Guid('F159BE6E-611C-C1D7-2E49-DC50AD11A42A'), self, self.OnUI3dIconCompData)
	
	-- temp. till the hooks for enemy and friendly nametags work.
	self.m_UINametagCompData = ResourceManager:RegisterInstanceLoadHandler(Guid('2E84F3D0-8DB2-11DF-9DBF-90F9B54D8E77'), Guid('1061D316-4366-BCA2-27D6-50D43543A41D'), self, self.OnUI3dIconCompData)
end

function UICleanup:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
    local s_Screen = UIGraphAsset(p_Screen)
            
    if s_Screen.name == 'UI/Flow/Screen/SpawnScreenPC' or
        s_Screen.name == 'UI/Flow/Screen/SpawnScreenTicketCounterConquestScreen' or
        --s_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsScreen' or
        s_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD32Screen' or
        s_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD16Screen' or
        s_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD64Screen' or
        s_Screen.name == 'UI/Flow/Screen/KillScreen' or
        s_Screen.name == 'UI/Flow/Screen/SpawnButtonScreen' then
            p_Hook:Return()
        return
    end
end

function UICleanup:OnHudConquestScreen(p_Instance)
	p_Instance = UIScreenAsset(p_Instance)
	p_Instance:MakeWritable()
	for i = #p_Instance.nodes, 1, -1 do
		local s_Node = p_Instance.nodes[i]
		if s_Node ~= nil then
			if s_Node.name == 'TicketCounter' or 
				s_Node.name == 'HudBackgroundWidget' or
				s_Node.name == 'CapturepointManager' or
				s_Node.name == 'ObjectiveBar'
			then
				p_Instance.nodes:erase(i)
			end
		end
	end
end

function UICleanup:OnUITrackingtagCompData(p_Instance)
    p_Instance = UITrackingtagCompData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.showMedicHealthThreshold = 0
    p_Instance.showEngineerArmorThreshold  = 0
    p_Instance.showSupportAmmoThreshold  = 0
    p_Instance.teamRadioDistance = 0
end

function UICleanup:OnUI3dIconCompData(p_Instance)
    p_Instance = UI3dIconCompData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.iconSize = 0
    p_Instance.snapIcons = false
    p_Instance.circularSnap = false
    p_Instance.drawDistance = 0
    p_Instance.teamRadioDistance = 0
    p_Instance.onlyShowSnapped = true
end

return UICleanup()
