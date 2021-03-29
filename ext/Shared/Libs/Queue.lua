class "Queue"

function Queue:__init()
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

    local value = self.m_Data[self.m_First]
    self.m_Data[self.m_First] = nil

    self.m_First = self.m_First + 1
    return value
end

function Queue:IsEmpty()
    return self.m_First > self.m_Last
end

function Queue:Size()
    return self.m_Last - self.m_First + 1
end
