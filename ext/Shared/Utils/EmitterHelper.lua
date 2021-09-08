-- https://github.com/Rylius/VU-Racing/blob/main/ext/shared/util/emitter_helper.lua
class "EmitterHelper"

function EmitterHelper:Clone(sourceEmitterEntityData)
	local s_EmitterEntityData = EmitterEntityData(sourceEmitterEntityData):Clone(MathUtils:RandomGuid())
	s_EmitterEntityData:MakeWritable()

	if s_EmitterEntityData.emitter == nil then
		return s_EmitterEntityData
	end

	local s_EmitterDocument = EmitterDocument(s_EmitterEntityData.emitter):Clone()
	s_EmitterDocument:MakeWritable()
	s_EmitterEntityData.emitter = s_EmitterDocument

	if s_EmitterDocument.templateData == nil then
		return s_EmitterEntityData
	end

	local s_EmitterTemplateData = EmitterTemplateData(s_EmitterDocument.templateData):Clone()
	s_EmitterTemplateData:MakeWritable()
	s_EmitterDocument.templateData = s_EmitterTemplateData

	if s_EmitterTemplateData.rootProcessor == nil then
		return s_EmitterEntityData
	end

	local s_RootProcessor = ProcessorData(s_EmitterTemplateData.rootProcessor):Clone()
	s_RootProcessor:MakeWritable()
	s_EmitterTemplateData.rootProcessor = s_RootProcessor

	local s_PreviousProcessorData = s_RootProcessor
	local s_CurrentProcessorData = s_RootProcessor.nextProcessor

	while s_CurrentProcessorData ~= nil do
		local s_ProcessorData = _G[s_CurrentProcessorData.typeInfo.name](s_CurrentProcessorData):Clone()
		s_ProcessorData:MakeWritable()
		s_PreviousProcessorData.nextProcessor = s_ProcessorData

		s_PreviousProcessorData = _G[s_ProcessorData.typeInfo.name](s_ProcessorData)
		s_CurrentProcessorData = s_ProcessorData.nextProcessor
	end

	return s_EmitterEntityData
end

function EmitterHelper:FindData(p_ProcessorData, p_DataType)
	if p_ProcessorData:Is(p_DataType.typeInfo.name) then
		return p_DataType(p_ProcessorData)
	end

	if p_ProcessorData.nextProcessor ~= nil then
		return self:FindData(p_ProcessorData.nextProcessor, p_DataType)
	end

	return nil
end

return EmitterHelper()
