class "DCExt"

local m_Logger = Logger("DCExt", false)

local m_PrintedObjects = nil
local m_CopiedObjects = nil

function DCExt:MakeWritable(p_Instance)
	if p_Instance == nil then
		m_Logger:Error('Parameter p_Instance was nil.')
		return
	end

	local s_Instance = _G[p_Instance.typeInfo.name](p_Instance)

	if p_Instance.isLazyLoaded == true then
		m_Logger:Error('The instance '..tostring(p_Instance.instanceGuid).." was modified, even though its lazyloaded")
	end

	if p_Instance.isReadOnly == nil then
		-- If .isReadOnly is nil it means that its not a DataContainer, it's a Structure. We return it casted
		m_Logger:Write('The instance '..p_Instance.typeInfo.name.." is not a DataContainer, it's a Structure")
		return s_Instance
	end

	if not p_Instance.isReadOnly then
		return s_Instance
	end

	s_Instance:MakeWritable()

	return s_Instance
end

function DCExt:Cast(p_Instance)
	if p_Instance == nil then
		m_Logger:Error('Parameter p_Instance was nil.')
		return
	end

	if p_Instance.typeInfo == nil then
		m_Logger:Error('Parameter p_Instance is not a DataContainer or structure.')
		return
	end

	local s_Instance = _G[p_Instance.typeInfo.name](p_Instance)

	return s_Instance
end

function DCExt:ShallowCopy(p_Instance, p_Guid)
	p_Guid = p_Guid or GenerateGuid()

	if p_Instance == nil then
		m_Logger:Error('Parameter p_Instance was nil.')
		return
	end

	if p_Instance.isLazyLoaded then
		m_Logger:Error('The instance is being lazy loaded, thus it can\'t be prepared for editing. Instance type: "' .. p_Instance.typeInfo.name)-- maybe add callstack
		return _G[p_Instance.typeInfo.name](p_Instance)
	end

	if p_Instance.isReadOnly == nil then
		-- If .isReadOnly is nil it means that its not a DataContainer, it's a Structure. We return it casted
		m_Logger:Write('The instance '..p_Instance.typeInfo.name.." is not a DataContainer, it's a Structure")
		return _G[p_Instance.typeInfo.name](p_Instance)
	end

	if p_Instance.instanceGuid == nil then
		m_Logger:Error('Instance.instanceGuid is nil. Instance type: ' .. p_Instance.typeInfo.name)
		return nil
	end

	local s_Clone = p_Instance:Clone(p_Guid)

	local s_CastedClone = _G[s_Clone.typeInfo.name](s_Clone)

	if s_CastedClone ~= nil and s_CastedClone.typeInfo.name ~= s_Clone.typeInfo.name then
		m_Logger:Error('PrepareInstanceForEdit() - Failed to prepare instance of type ' .. s_Clone.typeInfo.name)
		return nil
	end

	-- NOTE: if something is crashing this print can be useful to track it. Check if the latest output is this print and what instance it is
	-- m_Logger:Write('Cloned instance '..p_Instance.typeInfo.name..", instance guid: "..tostring(p_Instance.instanceGuid))

	return s_CastedClone
end

function DCExt:FindLazyLoadedFields(p_Instance)
	p_Instance = _G[p_Instance.typeInfo.name](p_Instance)

	m_Logger:Write('Looking for lazy loaded fields...')

	local s_TypeInfo = p_Instance.typeInfo

	-- We copy all fields
	local s_Fields = self:_GetFields(s_TypeInfo)

	for _, l_Field in pairs(s_Fields) do

		if l_Field.typeInfo ~= nil then
			local s_Name = l_Field.name:firstToLower()

			if l_Field.typeInfo.array then

			elseif self:_IsBasicType(l_Field.typeInfo.name) or l_Field.typeInfo.enum then

			else
				if p_Instance[s_Name] ~= nil then
					if p_Instance[s_Name].instanceGuid ~= nil then
						if p_Instance[s_Name].isLazyLoaded then
							m_Logger:Write("Found lazy loaded field, name: "..s_Name..", instance: "..tostring(p_Instance[s_Name].instanceGuid)..", partition: "..tostring(p_Instance[s_Name].partitionGuid))
						end
					end
				end
			end
		else
			m_Logger:Warning("typeInfo nil ?")
		end

		::continue::
	end

	m_Logger:Write('Finished looking for lazy loaded fields.')
end

function DCExt:GetInstanceFromPath(p_Instance, p_Path)
	local s_PathArray = p_Path:split(".")

	if s_PathArray[1] == "" then
		table.remove(s_PathArray, 1)
	end

	local s_Instance = p_Instance

	for i, l_FieldName in pairs(s_PathArray) do
		-- m_Logger:Write(i .. " - "..l_FieldName)
		if s_Instance.typeInfo == nil then
			--array
		else
			s_Instance = _G[s_Instance.typeInfo.name](s_Instance)
		end

		local s_Child = s_Instance[l_FieldName]

		if s_Child == nil then
			m_Logger:Warning('error in field '.. l_FieldName)
			return
		end

		s_Instance = s_Child
	end

	return _G[s_Instance.typeInfo.name](s_Instance)
end

--- Clones the passed instance, as well as all children and grandchildren that match the Guids in @p_DeepCopiedChildrenGuids
--- @p_DeepCopiedChildrenGuids: object. Keys are guid of original as string, value is custom guid as Guid
--- { instanceGuidString = customGuid, instanceGuidString2 = customGuid2, ...}
--- For it to work correctly you should pass all Guids that lead to the DataContainers that you want to modify
function DCExt:DeepCopy(p_Instance, p_DeepCopiedChildrenGuids, p_CurrentDepth)
	p_DeepCopiedChildrenGuids = p_DeepCopiedChildrenGuids or {}
	p_CurrentDepth = p_CurrentDepth or 0

	if p_Instance == nil then
		m_Logger:Error("Instance is nil")
		return
	end

	if p_CurrentDepth == 0 then
		m_CopiedObjects = {}
	end

	local s_Clone = _G[p_Instance.typeInfo.name](p_Instance)
	p_Instance = _G[p_Instance.typeInfo.name](p_Instance)

	-- Shallow copy p_Instance if it's a DataContainer, ignore if it's a structure
	if p_Instance.instanceGuid ~= nil then
		if p_Instance.isLazyLoaded then
			m_Logger:Error("DC with guid "..tostring(p_Instance.instanceGuid).." is lazy loaded, please deepclone after everything is loaded. Type "..p_Instance.typeInfo.name)
			return p_Instance
		end

		if m_CopiedObjects[tostring(p_Instance.instanceGuid)] ~= nil then
			return m_CopiedObjects[tostring(p_Instance.instanceGuid)]
		end

		-- Use custom guid if available
		if p_DeepCopiedChildrenGuids[tostring(p_Instance.instanceGuid)] then
			m_Logger:Write('Found custom guid: '..tostring(p_DeepCopiedChildrenGuids[tostring(p_Instance.instanceGuid)])..", original instanceGuid "..tostring(p_Instance.instanceGuid))

			s_Clone = self:ShallowCopy(p_Instance, p_DeepCopiedChildrenGuids[tostring(p_Instance.instanceGuid)])

			if s_Clone == nil then
				m_Logger:Error('Cloning returned nil')
			end

			m_CopiedObjects[tostring(p_Instance.instanceGuid)] = s_Clone
		end
	end

	self:_DeepCopyFields(s_Clone, p_DeepCopiedChildrenGuids, p_CurrentDepth)

	if p_CurrentDepth == 0 then
		m_CopiedObjects = nil
	end

	return s_Clone
end


function DCExt:_DeepCopyFields(p_Clone, p_DeepCopiedChildrenGuids, p_CurrentDepth)
	p_Clone = _G[p_Clone.typeInfo.name](p_Clone)
	local s_TypeInfo = p_Clone.typeInfo

	-- We look for fields that are DCs to clone them
	local s_Fields = self:_GetFields(s_TypeInfo)

	for _, l_Field in pairs(s_Fields) do
		if l_Field.typeInfo ~= nil then
			local s_Name = l_Field.name:firstToLower()

			if l_Field.typeInfo.array then
				local s_Array = p_Clone[s_Name]

				if s_Array ~= nil then
					for i = #s_Array, 1, -1 do
						local s_Member = s_Array[i]

						if s_Member ~= nil and not self:_IsBasicType(l_Field.typeInfo.elementType.name) and not l_Field.typeInfo.elementType.enum then
							self:_DeepCopyStructOrDC(p_Clone, s_Name, i, p_DeepCopiedChildrenGuids, p_CurrentDepth)
						end
					end
				end
				-- It's an object or structure
			elseif not self:_IsBasicType(l_Field.typeInfo.name) and not l_Field.typeInfo.enum then
				self:_DeepCopyStructOrDC(p_Clone, s_Name, nil, p_DeepCopiedChildrenGuids, p_CurrentDepth)
			end
		else
			m_Logger:Warning("typeInfo nil ?")
		end
	end
end

function DCExt:_DeepCopyStructOrDC(p_Clone, p_FieldName, p_FieldIndex, p_DeepCopiedChildrenGuids, p_CurrentDepth)
	local s_FieldInstance = p_Clone[p_FieldName]

	-- For DCs that are in an array
	if p_FieldIndex then
		s_FieldInstance = s_FieldInstance[p_FieldIndex]
	end

	if s_FieldInstance == nil then
		return
	end

	if s_FieldInstance.instanceGuid == nil then -- Structure
		self:_DeepCopyFields(s_FieldInstance, p_DeepCopiedChildrenGuids, p_CurrentDepth)
	else -- DataContainer
		self:_DeepCopyDC(p_Clone, p_FieldName, p_FieldIndex, p_DeepCopiedChildrenGuids, p_CurrentDepth)
	end
end

function DCExt:_DeepCopyDC(p_Clone, p_FieldName, p_FieldIndex, p_DeepCopiedChildrenGuids, p_CurrentDepth)
	local s_FieldInstance = p_Clone[p_FieldName]

	-- For DCs that are in an array
	if p_FieldIndex then
		s_FieldInstance = s_FieldInstance[p_FieldIndex]
	end

	-- Check if lazyloaded
	local s_Instance

	if p_FieldIndex then
		s_Instance = p_Clone[p_FieldName][p_FieldIndex]
	else
		s_Instance = p_Clone[p_FieldName]
	end

	if s_Instance.isLazyLoaded then
		m_Logger:Error("DC with guid "..tostring(s_Instance.instanceGuid).." is lazy loaded, please deepcopy after everything is loaded. Type "..s_Instance.typeInfo.name)
		return s_Instance
	end

	-- Filter DataContainers
	if s_FieldInstance.typeInfo.name ~= "DataContainer" then
		-- Only clone field if it was specified in the path array.
		if p_DeepCopiedChildrenGuids[tostring(s_FieldInstance.instanceGuid)] then
			if p_FieldIndex then
				p_Clone[p_FieldName][p_FieldIndex] = self:DeepCopy(s_FieldInstance, p_DeepCopiedChildrenGuids, p_CurrentDepth + 1)
			else
				p_Clone[p_FieldName] = self:DeepCopy(s_FieldInstance, p_DeepCopiedChildrenGuids, p_CurrentDepth + 1)
			end
		end
	end
end

--- Clones all DataContainers found in the passed instance.
function DCExt:DeepClone(p_Instance, p_Guid, p_CurrentDepth)
	p_CurrentDepth = p_CurrentDepth or 0
	p_Guid = p_Guid or GenerateGuid()

	if p_Instance == nil then
		m_Logger:Error("Instance is nil")
		return
	end

	if p_CurrentDepth == 0 then
		m_CopiedObjects = {}
	end

	local s_Clone = _G[p_Instance.typeInfo.name](p_Instance)
	p_Instance = _G[p_Instance.typeInfo.name](p_Instance)

	-- Shallow copy p_Instance if it's a DataContainer, ignore if it's a structure
	if p_Instance.instanceGuid ~= nil then
		if p_Instance.isLazyLoaded then
			m_Logger:Error("DC with guid "..tostring(p_Instance.instanceGuid).." is lazy loaded, please deepclone after everything is loaded. Type "..p_Instance.typeInfo.name)
			return p_Instance
		end

		if m_CopiedObjects[tostring(p_Instance.instanceGuid)] ~= nil then
			return m_CopiedObjects[tostring(p_Instance.instanceGuid)]
		end

		s_Clone = self:ShallowCopy(p_Instance, p_Guid)

		if s_Clone == nil then
			m_Logger:Error('Cloning returned nil')
		end

		m_CopiedObjects[tostring(p_Instance.instanceGuid)] = s_Clone
	end

	self:_DeepCloneFields(s_Clone, p_CurrentDepth)

	if p_CurrentDepth == 0 then
		m_CopiedObjects = nil
	end

	return s_Clone
end

function DCExt:_DeepCloneFields(p_Clone, p_CurrentDepth)
	p_Clone = _G[p_Clone.typeInfo.name](p_Clone)
	local s_TypeInfo = p_Clone.typeInfo

	-- We look for fields that are DCs to clone them
	local s_Fields = self:_GetFields(s_TypeInfo)

	for _, l_Field in pairs(s_Fields) do
		if l_Field.typeInfo ~= nil then
			local s_Name = l_Field.name:firstToLower()

			if l_Field.typeInfo.array then
				local s_Array = p_Clone[s_Name]

				if s_Array ~= nil then
					for i = #s_Array, 1, -1 do
						local s_Member = s_Array[i]

						if s_Member ~= nil and not self:_IsBasicType(l_Field.typeInfo.elementType.name) and not l_Field.typeInfo.elementType.enum then
							self:_DeepCloneStructOrDC(p_Clone, s_Name, i, p_CurrentDepth)
						end
					end
				end
				-- It's an object or structure
			elseif not self:_IsBasicType(l_Field.typeInfo.name) and not l_Field.typeInfo.enum then
				self:_DeepCloneStructOrDC(p_Clone, s_Name, nil, p_CurrentDepth)
			end
		else
			m_Logger:Warning("typeInfo nil ?")
		end
	end
end

function DCExt:_DeepCloneStructOrDC(p_Clone, p_FieldName, p_FieldIndex, p_CurrentDepth)
	local s_FieldInstance = p_Clone[p_FieldName]

	-- For DCs that are in an array
	if p_FieldIndex then
		s_FieldInstance = s_FieldInstance[p_FieldIndex]
	end

	if s_FieldInstance == nil then
		return
	end

	if s_FieldInstance.instanceGuid == nil then -- Structure
		self:_DeepCloneFields(s_FieldInstance, p_CurrentDepth)
	else -- DataContainer
		self:_DeepCloneDC(p_Clone, p_FieldName, p_FieldIndex, p_CurrentDepth)
	end
end

function DCExt:_DeepCloneDC(p_Clone, p_FieldName, p_FieldIndex, p_CurrentDepth)
	local s_FieldInstance = p_Clone[p_FieldName]

	-- For DCs that are in an array
	if p_FieldIndex then
		s_FieldInstance = s_FieldInstance[p_FieldIndex]
	end

	-- Check if lazyloaded
	local s_Instance

	if p_FieldIndex then
		s_Instance = p_Clone[p_FieldName][p_FieldIndex]
	else
		s_Instance = p_Clone[p_FieldName]
	end

	if s_Instance.isLazyLoaded then
		m_Logger:Error("DC with guid "..tostring(s_Instance.instanceGuid).." is lazy loaded, please deepclone after everything is loaded. Type "..s_Instance.typeInfo.name)
		return
	end

	-- Filter DataContainer
	if s_FieldInstance.typeInfo.name ~= "DataContainer" then
		if p_FieldIndex then
			p_Clone[p_FieldName][p_FieldIndex] = self:DeepClone(s_FieldInstance, nil, p_CurrentDepth + 1)
		else
			p_Clone[p_FieldName] = self:DeepClone(s_FieldInstance, nil, p_CurrentDepth + 1)
		end
	end
end

--- Returns a table with partitions in all de descendants of @p_Instance. Useful to check which partitions have to
--- be loaded before doing DeepCopy or DeepClone. @return table has partition guids as strings as keys
function DCExt:GetPartitionsInDescendants(p_Instance, p_CurrentDepth)
	p_CurrentDepth = p_CurrentDepth or 0

	if p_Instance == nil then
		m_Logger:Error("Instance is nil")
		return
	end

	if p_CurrentDepth == 0 then
		m_CopiedObjects = {}
	end

	p_Instance = _G[p_Instance.typeInfo.name](p_Instance)

	if p_Instance.partitionGuid ~= nil then
		m_CopiedObjects[tostring(p_Instance.partitionGuid)] = true
	end

	self:_GetPartitionsInFields(p_Instance, p_CurrentDepth)

	if p_CurrentDepth == 0 then
		local s_PartitionsTable = m_CopiedObjects
		m_CopiedObjects = nil

		return s_PartitionsTable
	end
end

function DCExt:_GetPartitionsInFields(p_Instance, p_CurrentDepth)
	p_Instance = _G[p_Instance.typeInfo.name](p_Instance)
	local s_TypeInfo = p_Instance.typeInfo

	-- We look for fields that are DCs to clone them
	local s_Fields = self:_GetFields(s_TypeInfo)

	for _, l_Field in pairs(s_Fields) do
		if l_Field.typeInfo ~= nil then
			local s_Name = l_Field.name:firstToLower()

			if l_Field.typeInfo.array then
				local s_Array = p_Instance[s_Name]

				if s_Array ~= nil then
					for i = #s_Array, 1, -1 do
						local s_Member = s_Array[i]

						if s_Member ~= nil and not self:_IsBasicType(l_Field.typeInfo.elementType.name) and not l_Field.typeInfo.elementType.enum then
							self:_GetPartitionsInStructOrDC(p_Instance, s_Name, i, p_CurrentDepth)
						end
					end
				end
				-- It's an object or structure
			elseif not self:_IsBasicType(l_Field.typeInfo.name) and not l_Field.typeInfo.enum then
				self:_GetPartitionsInStructOrDC(p_Instance, s_Name, nil, p_CurrentDepth)
			end
		else
			m_Logger:Warning("typeInfo nil ?")
		end
	end
end

function DCExt:_GetPartitionsInStructOrDC(p_Instance, p_FieldName, p_FieldIndex, p_CurrentDepth)
	local s_FieldInstance = p_Instance[p_FieldName]

	-- For DCs that are in an array
	if p_FieldIndex then
		s_FieldInstance = s_FieldInstance[p_FieldIndex]
	end

	if s_FieldInstance == nil then
		return
	end

	if s_FieldInstance.instanceGuid == nil then -- Structure
		self:_GetPartitionsInFields(s_FieldInstance, p_CurrentDepth)
	else -- DataContainer
		self:_GetPartitionsInDC(p_Instance, p_FieldName, p_FieldIndex, p_CurrentDepth)
	end
end

function DCExt:_GetPartitionsInDC(p_Instance, p_FieldName, p_FieldIndex, p_CurrentDepth)
	local s_FieldInstance = p_Instance[p_FieldName]

	-- For DCs that are in an array
	if p_FieldIndex then
		s_FieldInstance = s_FieldInstance[p_FieldIndex]
	end

	-- Check if lazyloaded
	local s_Instance

	if p_FieldIndex then
		s_Instance = p_Instance[p_FieldName][p_FieldIndex]
	else
		s_Instance = p_Instance[p_FieldName]
	end

	if s_Instance.isLazyLoaded then
		m_Logger:Error("DC with guid "..tostring(s_Instance.instanceGuid).." is lazy loaded, please get partitions after everything is loaded. Type "..s_Instance.typeInfo.name)
		return
	end

	-- Filter DataContainer
	if s_FieldInstance.typeInfo.name ~= "DataContainer" then
		if p_FieldIndex then
			self:GetPartitionsInDescendants(s_FieldInstance, p_CurrentDepth + 1)
		else
			self:GetPartitionsInDescendants(s_FieldInstance, p_CurrentDepth + 1)
		end
	end
end

-- Prints all members and child members of a given instance. Useful for debugging.
function DCExt:PrintFields(p_Instance, p_MaxDepth, p_Padding)
	if p_Instance == nil then
		m_Logger:Error("instance nil")
		return
	end

	local s_TypeInfo = p_Instance.typeInfo

	if s_TypeInfo == nil then
		m_Logger:Error("typeInfo nil")
		return
	end

	self:_PrintFieldsInternal(p_Instance, s_TypeInfo, p_Padding, 0, p_MaxDepth, nil)
end

function DCExt:_PrintFieldsInternal(p_Instance, p_TypeInfo, p_Padding, p_CurrentDepth, p_MaxDepth, p_FieldName)
	if p_Instance == nil then
		m_Logger:Error("instance nil")
		return
	end

	p_TypeInfo = p_TypeInfo or p_Instance.typeInfo

	if p_TypeInfo == nil then
		m_Logger:Error("typeInfo nil")
		return
	end

	if p_CurrentDepth == 0 then
		m_PrintedObjects = {}
	end

	if p_FieldName == nil then
		p_FieldName = ""
	elseif p_FieldName ~= "" then
		p_FieldName = tostring(p_FieldName) .. " "
	end

	if p_CurrentDepth == nil then
		p_CurrentDepth = 0
	end

	if p_MaxDepth == nil then
		p_MaxDepth = -1
	end

	if p_Padding == nil then
		p_Padding = ""
	end

	if string.match(p_TypeInfo.name:lower(), "voice") or
		string.match(p_TypeInfo.name:lower(), "sound") or
		p_TypeInfo == MaterialContainerPair.typeInfo or
		p_TypeInfo == MaterialContainerAsset.typeInfo then
		return
	end

	local s_Instance = _G[p_Instance.typeInfo.name](p_Instance)

	-- If it has a guid its an object, otherwise its a structure
	if s_Instance.instanceGuid == nil then
		print(p_Padding ..p_FieldName..'(Structure - '..p_TypeInfo.name..') {')
	else
		-- Not print it if we already printed this object
		if m_PrintedObjects[tostring(s_Instance.instanceGuid)] ~= nil then
			print(p_Padding ..p_FieldName..'(Object - '..p_TypeInfo.name..') instanceGuid: '.. tostring(s_Instance.instanceGuid).. ' (Printed above) {')
			return
		else
			m_PrintedObjects[tostring(s_Instance.instanceGuid)] = true
		end

		local s_LazyLoadedWarning = ''

		if s_Instance.isLazyLoaded then
			s_LazyLoadedWarning = 'LAZYLOADED!'
		end

		print(p_Padding ..p_FieldName..'(Object - '..p_TypeInfo.name..') instanceGuid: '.. tostring(s_Instance.instanceGuid).. ' '..s_LazyLoadedWarning..'{')
	end

	--Stop if we have reached max depth
	if p_MaxDepth ~= -1 and p_CurrentDepth > p_MaxDepth then
		return
	end

	p_Padding = p_Padding .. " "

	local s_Fields = self:_GetFields(p_TypeInfo)

	for _, l_Field in ipairs(s_Fields) do
		if l_Field.typeInfo == nil then
			m_Logger:Write("l_Field.typeInfo == nil")
			goto continue
		elseif l_Field.name == "MaterialPairs" then
			m_Logger:Write("MaterialPairs isn't supported, ignoring.")
			goto continue
		end

		local s_Name = l_Field.name:firstToLower()

		if self:_IsBasicType(l_Field.typeInfo.name) then
			local s_Value = s_Instance[s_Name]
			print(p_Padding ..l_Field.name..' ('..l_Field.typeInfo.name..') : '.. tostring(s_Value))

		--Array
		elseif l_Field.typeInfo.array then
			local s_Array = s_Instance[s_Name]

			if s_Array == nil then
				print(p_Padding ..l_Field.name..' (Array), nil')
			else
				print(p_Padding ..l_Field.name..' (Array), '..tostring(#s_Array)..' Members {')
				for i = 1, #s_Array, 1 do
					local s_Member = s_Array[i]

					if s_Member == nil then
						goto continue1
					end

					if self:_IsBasicType(l_Field.typeInfo.elementType.name) then
						print(p_Padding .."[" .. i .. "] "..' ('..l_Field.typeInfo.elementType.name..') : '.. tostring(s_Member))
					elseif l_Field.typeInfo.elementType.enum then
						print(p_Padding .."[" .. i .. "] "..' (Enum) : '.. tostring(s_Member))
					else
						self:_PrintFieldsInternal(s_Member, s_Member.typeInfo, p_Padding, p_CurrentDepth + 1, p_MaxDepth)
					end

					::continue1::
				end
				print(p_Padding .. "}")
			end

		--Enum
		elseif l_Field.typeInfo.enum then
			local s_Value = s_Instance[s_Name]
			print(p_Padding..l_Field.name..' (Enum) : ' .. tostring(s_Value))

		--Object or Structure
		else
			if s_Instance[s_Name] ~= nil then
				-- local s_Value = s_Instance[s_Name]
				local i = _G[l_Field.typeInfo.name](s_Instance[s_Name])

				if i ~= nil then
					-- p_Padding = p_Padding .. "	"
					self:_PrintFieldsInternal( i, i.typeInfo, p_Padding, p_CurrentDepth + 1, p_MaxDepth, l_Field.name)
				end
			else
				print(p_Padding ..l_Field.name..' (Object - '..l_Field.typeInfo.name..') nil')
			end
		end

		::continue::
	end

	print (p_Padding:sub(1, -3) .. "}")

	-- Clear printed objects
	if p_CurrentDepth == 0 then
		m_PrintedObjects = nil
	end
end

function DCExt:_GetFields(p_TypeInfo)
	local s_Super = {}

	if p_TypeInfo.super ~= nil then
		if p_TypeInfo.super.name ~= "DataContainer" then
			for _, l_SuperField in pairs(self:_GetFields(p_TypeInfo.super)) do
				table.insert(s_Super, l_SuperField)
			end
		end
	end

	for _, l_Field in pairs(p_TypeInfo.fields) do
		table.insert(s_Super, l_Field)
	end

	return s_Super
end

function DCExt:_IsBasicType(p_Type)
	if p_Type == "CString" or
		p_Type == "Float8" or
		p_Type == "Float16" or
		p_Type == "Float32" or
		p_Type == "Float64" or
		p_Type == "Int8" or
		p_Type == "Int16" or
		p_Type == "Int32" or
		p_Type == "Int64" or
		p_Type == "Uint8" or
		p_Type == "Uint16" or
		p_Type == "Uint32" or
		p_Type == "Uint64" or
		p_Type == "LinearTransform" or
		p_Type == "Vec2" or
		p_Type == "Vec3" or
		p_Type == "Vec4" or
		p_Type == "Boolean" or
		p_Type == "Guid" then
		return true
	end

	return false
end

function GenerateGuid()
	return Guid(h()..h()..h()..h().."-"..h()..h().."-"..h()..h().."-"..h()..h().."-"..h()..h()..h()..h()..h()..h(), "D")
end

function h()
	local vars = {"A","B","C","D","E","F","0","1","2","3","4","5","6","7","8","9"}
	return vars[math.floor(MathUtils:GetRandomInt(1,16))]..vars[math.floor(MathUtils:GetRandomInt(1,16))]
end

-- Singleton.
if g_DCExt == nil then
	g_DCExt = DCExt()
end

return g_DCExt
