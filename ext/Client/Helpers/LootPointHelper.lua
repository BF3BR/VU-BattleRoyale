class 'LootPointHelper'

require ("__shared/Helpers/LevelNameHelper")

require ("__shared/Configs/MapsConfig")
require ("__shared/Configs/ServerConfig")

function LootPointHelper:__init()
    self.m_Points = {}
    self.m_Center = ClientUtils:GetWindowSize() / 2

    self.m_SelectedIndex = nil
    self.m_ActiveIndex = nil
    self.m_SavedPosition = nil

    if ServerConfig["Debug"]["EnableLootPointSpheres"] then
        self.m_LevelLoadedEvent = Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
        self.m_UIDrawHudEvent = Events:Subscribe('UI:DrawHud', self, self.OnUIDrawHud)
        self.m_PlayerUpdateInputEvent = Events:Subscribe('Player:UpdateInput', self, self.OnPlayerUpdateInput)
        self.m_UpdateManagerUpdateEvent = Events:Subscribe('UpdateManager:Update', self, self.OnUpdateManagerUpdate)
    end
end


function LootPointHelper:OnLevelLoaded()
    local s_LevelName = LevelNameHelper:GetLevelName()
    if s_LevelName == nil then
        return
    end

    self.m_Points = MapsConfig[s_LevelName]["LootSpawnPoints"]
end

function LootPointHelper:OnUIDrawHud()
    for i, point in pairs(self.m_Points) do
		if i ~= self.m_ActiveIndex then
            DebugRenderer:DrawSphere(point.trans, 0.3, Vec4(1, 1, 1, 0.5), true, false)
		end
	end

	-- Draw red SpawnPoint on the active point
	if self.m_ActiveIndex then
        DebugRenderer:DrawSphere(self.m_Points[self.m_ActiveIndex].trans, 0.3, Vec4(1, 0, 0, 0.5), true, false)

	-- Draw blue SpawnPoint on the selected point
	elseif self.m_SelectedIndex then
        DebugRenderer:DrawSphere(self.m_Points[self.m_SelectedIndex].trans, 0.3, Vec4(0, 0, 1, 0.5), true, false)
	end
end

function LootPointHelper:OnPlayerUpdateInput()
	local player = PlayerManager:GetLocalPlayer()

	if player == nil then
		return
	end

	if player.soldier == nil then
		return
	end

	-- Press F5 to start or stop moving points
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_F5) then
        
		-- If the active point is the last, and unconfirmed, remove it
		if self.m_ActiveIndex == #self.m_Points and not self.m_SavedPosition then
	
			self.m_Points[self.m_ActiveIndex] = nil
			self.m_ActiveIndex = nil

		-- If a previous point was being moved, revert it back to the saved position
		elseif self.m_SavedPosition then
	
			self.m_Points[self.m_ActiveIndex] = self.m_SavedPosition:Clone()
			self.m_ActiveIndex = nil
			self.m_SavedPosition = nil

		-- If a point is being moved, stop moving it
		elseif self.m_ActiveIndex then

			self.m_ActiveIndex = nil

		-- Start or continue adding points
		else
			self.m_ActiveIndex = #self.m_Points + 1
			self.m_Points[self.m_ActiveIndex] = LinearTransform()
		end
	end

	-- Press F4 to clear point(s)
	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F4) then

		-- If theres a point being moved, clear only it
		if self.m_ActiveIndex then

			table.remove(self.m_Points, self.m_ActiveIndex)
			
		-- If theres a point selected, clear only it
		elseif self.m_SelectedIndex then

			table.remove(self.m_Points, self.m_SelectedIndex)
			
		-- Otherwise, clear all points
		else
			self.m_Points = {}	
		end

		self.m_ActiveIndex = nil
		self.m_SelectedIndex = nil
		self.m_SavedPosition = nil
	end

	-- Press E to select point or confirm point placement
	if InputManager:WentKeyDown(InputDeviceKeys.IDK_E) then

		if self.m_ActiveIndex then

			-- If a point was being moved and it has now been confirmed
			if self.m_SavedPosition then

				self.m_ActiveIndex = nil
				self.m_SavedPosition = nil

			-- If the point that will be confirmed is the last, start drawing the next one
			elseif self.m_ActiveIndex == #self.m_Points then

				self.m_ActiveIndex = #self.m_Points + 1
				self.m_Points[self.m_ActiveIndex] = LinearTransform()
				self.m_SavedPosition = nil

			-- If theres no saved position and the point being moved is not the last, an inserted point was being placed and it has now been confirmed
			else
				self.m_ActiveIndex = nil
			end

		-- If E is pressed while a previous point is selected, that point becomes the active point
		elseif self.m_SelectedIndex then

			self.m_SavedPosition = self.m_Points[self.m_SelectedIndex]:Clone()
			self.m_ActiveIndex = self.m_SelectedIndex
			self.m_SelectedIndex = nil
		end
	end

	-- Press F1 to print points as LinearTransforms
	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F1) then
		self:PrintPointsAsLinearTransforms()
	end
end

function LootPointHelper:OnUpdateManagerUpdate(delta, pass)
	-- Only do raycast on presimulation UpdatePass
	if pass ~= UpdatePass.UpdatePass_PreSim then
		return
	end

	raycastHit = self:Raycast()

	if raycastHit == nil then
		return
	end

	local hitPosition = raycastHit.position

	self.m_SelectedIndex = nil

	-- Move the active point to the "point of aim"
	if self.m_ActiveIndex and raycastHit then

		self.m_Points[self.m_ActiveIndex].trans = hitPosition
		
	-- If theres no active point, check to see if the POA is near a point
	else
		for index, point in pairs(self.m_Points) do

			local pointScreenPos = ClientUtils:WorldToScreen(point.trans)

			-- Skip to the next point if this one isn't in view
			if pointScreenPos == nil then
				goto continue
			end

			-- Select point if its close to the hitPosition
			if self.m_Center:Distance(pointScreenPos) < 20 then

				self.m_SelectedIndex = index
			end
			::continue::
		end
	end
end

-- stolen't https://github.com/EmulatorNexus/VEXT-Samples/blob/80cddf7864a2cdcaccb9efa810e65fae1baeac78/no-headglitch-raycast/ext/Client/__init__.lua
function LootPointHelper:Raycast()
	local localPlayer = PlayerManager:GetLocalPlayer()

	if localPlayer == nil then
		return
	end

	-- We get the camera transform, from which we will start the raycast. We get the direction from the forward vector. Camera transform
	-- is inverted, so we have to invert this vector.
	local transform = ClientUtils:GetCameraTransform()
	local direction = Vec3(-transform.forward.x, -transform.forward.y, -transform.forward.z)

	if transform.trans == Vec3(0,0,0) then
		return
	end

	local castStart = transform.trans

	-- We get the raycast end transform with the calculated direction and the max distance.
	local castEnd = Vec3(
		transform.trans.x + (direction.x * 100),
		transform.trans.y + (direction.y * 100),
		transform.trans.z + (direction.z * 100))

	-- Perform raycast, returns a RayCastHit object.
	local raycastHit = RaycastManager:Raycast(castStart, castEnd, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll | RayCastFlags.CheckDetailMesh)

	return raycastHit	
end

function LootPointHelper:PrintPointsAsLinearTransforms()
	local result = "points = { "
	for index, point in pairs(self.m_Points) do
		result = result.."LinearTransform("..
			"Vec3"..string.gsub(tostring(point.left),"000000","0")..
			", Vec3"..string.gsub(tostring(point.up),"000000","0")..
			", Vec3"..string.gsub(tostring(point.forward),"000000","0")..
			", Vec3"..tostring(point.trans).."), "
	end
	print(result.."}")
end

g_LootPointHelper = LootPointHelper()
