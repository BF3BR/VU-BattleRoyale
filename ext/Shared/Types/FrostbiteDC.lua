class "FrostbiteDC"

function FrostbiteDC:__init(args)
    if args.instanceGuid == nil or args.partitionGuid == nil then
        error("[FrostbiteDC] Invalid guids specified")
    end
    self.name = args.name or ""
	self.instanceGuid = args.instanceGuid
	self.partitionGuid = args.partitionGuid
end

function FrostbiteDC:GetInstance()
    local s_Instance = ResourceManager:FindInstanceByGuid(self.partitionGuid, self.instanceGuid)
	return (s_Instance == nil) and s_Instance or _G[s_Instance.typeInfo.name](s_Instance)
end

function FrostbiteDC:RegisterLoadHandler(p_Ctx, p_Callback)
    local s_Args = (p_Callback == nil) and { p_Ctx } or { p_Ctx, p_Callback }
    ResourceManager:RegisterInstanceLoadHandler(self.partitionGuid, self.instanceGuid, table.unpack(s_Args))
end

function FrostbiteDC:CallOrRegisterLoadHandler(p_Ctx, p_Callback)
    local s_Instance = self:GetInstance()
    if s_Instance ~= nil then
        if p_Callback == nil then
            p_Ctx(s_Instance)
        else
            p_Callback(p_Ctx, p_Callback)
        end
    else
        self:RegisterLoadHandler(p_Ctx, p_Callback)
    end
end        

return FrostbiteDC