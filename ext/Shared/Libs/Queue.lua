class "Queue"

function Queue:__init()
	self:ResetVars()
end

function Queue:ResetVars()
	self.m_Data = {}
	self.m_First = 0
	self.m_Last = -1
end

function Queue:Enqueue(value)
	self.m_Last = self.m_Last + 1
	self.m_Data[self.m_Last] = value
end

function Queue:Dequeue()
	if self:IsEmpty() then
		return nil
	end

	local s_Value = self.m_Data[self.m_First]
	self.m_Data[self.m_First] = nil

	self.m_First = self.m_First + 1
	return s_Value
end

function Queue:IsEmpty()
	return self.m_First > self.m_Last
end

function Queue:Size()
	return self.m_Last - self.m_First + 1
end

function Queue:AsList()
	if self:IsEmpty() then
		return {}
	end

	local s_List = {}

	for i = self.m_First, self.m_Last do
		table.insert(s_List, self.m_Data[i])
	end

	return s_List
end

return Queue()
