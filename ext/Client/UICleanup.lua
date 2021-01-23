class 'UICleanup'

function UICleanup:__init()
    self.m_UIPushScreenHook =  Hooks:Install('UI:PushScreen', 999, self, self.OnUIPushScreen)
	
	self.m_HudConquestScreen = ResourceManager:RegisterInstanceLoadHandler(Guid('0C14516A-02F0-4A81-B88B-6010A6A6DDC6'), Guid('2A2B8447-C938-407A-951A-C3BA099F0374'), self, self.OnHudConquestScreen)
	
	self.m_UITrackingtagCompData = ResourceManager:RegisterInstanceLoadHandler(Guid('EEA59917-3FF2-11E0-B6B0-A41634C402A3'), Guid('70998786-14D8-2E5A-CB44-F4C2DA29EE29'), self, self.OnUITrackingtagCompData)
	self.m_UIAlerttagCompData = ResourceManager:RegisterInstanceLoadHandler(Guid('F9331953-F3F2-11DF-BAF2-BDEFE75B56CA'), Guid('08FB6671-269A-2006-B8E1-AD901370C589'), self, self.OnUIAlerttagCompData)
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

-- need healing/ repair/ ammo
function UICleanup:OnUITrackingtagCompData(p_Instance)
    p_Instance = UITrackingtagCompData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.showMedicHealthThreshold = 0
    p_Instance.showEngineerArmorThreshold  = 0
    p_Instance.showSupportAmmoThreshold  = 0
    p_Instance.teamRadioDistance = 0
end

-- Grenade Indicator
function UICleanup:OnUIAlerttagCompData(p_Instance)
    p_Instance = UIAlerttagCompData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.iconSize = 0
    p_Instance.snapIcons = false
    p_Instance.circularSnap = false
    p_Instance.drawDistance = 0
    p_Instance.teamRadioDistance = 0
    p_Instance.onlyShowSnapped = true
end

return UICleanup()
