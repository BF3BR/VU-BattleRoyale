---@class TreeRemoving
TreeRemoving = class 'TreeRemoving'

---@module "Configs/2dTreeConfig"
local TreeConfig = require "__shared/Configs/2dTreeConfig"

local m_XP5_003 = DC(Guid("2155927F-76C7-84F2-0BAF-4862CD442CF8"), Guid("2155927F-76C7-84F2-0BAF-4862CD442CF8"))
local m_XP3_Shield = DC(Guid("601D5D72-9EA2-820C-180A-28856102D3A8"), Guid("601D5D72-9EA2-820C-180A-28856102D3A8"))

function TreeRemoving:RegisterCallbacks()
	m_XP5_003:RegisterLoadHandler(self, self.OnMeshVariationDatabase)
	m_XP3_Shield:RegisterLoadHandler(self, self.OnMeshVariationDatabase)
end

function TreeRemoving:DeregisterCallbacks()
	m_XP5_003:Deregister()
	m_XP3_Shield:Deregister()
end

local function CreateParamaterIndexMap(p_Parameters)
	local s_IndexMap = {}

	for l_Index, l_Parameter in ipairs(p_Parameters) do
		s_IndexMap[l_Parameter.parameterName] = l_Index
	end

	return s_IndexMap
end

local function ModifyTextureParameters(p_DatabaseMaterial, p_TextureConfig)
	local s_ParameterIndexMap = CreateParamaterIndexMap(p_DatabaseMaterial.textureParameters)

	for l_ParameterName, l_TextureName in pairs(p_TextureConfig.PARAMETERS) do
		local s_Texture = TextureAsset()
		s_Texture.name = l_TextureName

		if s_ParameterIndexMap[l_ParameterName] ~= nil then
			local s_Parameter = p_DatabaseMaterial.textureParameters[s_ParameterIndexMap[l_ParameterName]]
			s_Parameter.value = s_Texture
		elseif p_TextureConfig.TYPE ~= ParameterModificationType.ModifyParameters then
			local s_Parameter = TextureShaderParameter()
			s_Parameter.parameterName = l_ParameterName
			s_Parameter.value = s_Texture

			p_DatabaseMaterial.textureParameters:add(s_Parameter)
		else
			print("ERROR: Invalid texture parameter specified: no " .. l_ParameterName .. " parameter for material: " .. p_DatabaseMaterial.material.instanceGuid:ToString('P'))
		end
	end
end

local function ModifyVectorParameters(p_ShaderConfig, p_MeshMaterial)
	local s_ParameterIndexMap = CreateParamaterIndexMap(p_MeshMaterial.shader.vectorParameters)

	for l_ParameterName, l_ParameterConfig in pairs(p_ShaderConfig.PARAMETERS) do
		if s_ParameterIndexMap[l_ParameterName] ~= nil then
			local s_Parameter = p_MeshMaterial.shader.vectorParameters[s_ParameterIndexMap[l_ParameterName]]
			s_Parameter.value = l_ParameterConfig.VALUE
		elseif p_ShaderConfig.TYPE ~= ParameterModificationType.ModifyParameters then
			local s_Parameter = VectorShaderParameter()
			s_Parameter.parameterName = l_ParameterName
			s_Parameter.parameterType = l_ParameterConfig.TYPE
			s_Parameter.value = l_ParameterConfig.VALUE

			p_MeshMaterial.shader.vectorParameters:add(s_Parameter)
		else
			print("ERROR: Invalid vector parameter specified: no " .. l_ParameterName .. " parameter for material: " .. p_MeshMaterial.instanceGuid:ToString('P'))
		end
	end
end

local function ModifyMeshMaterial(p_ShaderConfig, p_MeshMaterial)
	p_MeshMaterial = MeshMaterial(p_MeshMaterial)
	p_MeshMaterial:MakeWritable()

	if p_ShaderConfig.NAME ~= nil then
		local s_ShaderGraph = ShaderGraph()
		s_ShaderGraph.name = p_ShaderConfig.NAME

		p_MeshMaterial.shader.shader = s_ShaderGraph
	end

	if p_ShaderConfig.TYPE == ParameterModificationType.ReplaceParameters then
		p_MeshMaterial.shader.vectorParameters:clear()
	end

	if p_ShaderConfig.PARAMETERS ~= nil then
		ModifyVectorParameters(p_ShaderConfig, p_MeshMaterial)
	end
end

local function ModifyThisEntry(p_MeshMaterial, p_MeshVariationDatabaseEntry, p_MaterialConfig, p_MaterialIndex)
	local s_ShaderConfig = p_MaterialConfig.SHADER

	if s_ShaderConfig ~= nil then
		ModifyMeshMaterial(s_ShaderConfig, p_MeshMaterial)
	end

	local s_TextureConfig = p_MaterialConfig.TEXTURES

	if s_TextureConfig ~= nil then
		if s_TextureConfig.TYPE == ParameterModificationType.ReplaceParameters then
			p_MeshVariationDatabaseEntry.materials[p_MaterialIndex] = MeshVariationDatabaseMaterial()
			p_MeshVariationDatabaseEntry.materials[p_MaterialIndex].material = p_MeshMaterial
		end

		if s_TextureConfig.PARAMETERS ~= nil then
			ModifyTextureParameters(p_MeshVariationDatabaseEntry.materials[p_MaterialIndex], s_TextureConfig)
		end
	end
end

---@param p_MeshVariationDatabaseEntry MeshVariationDatabaseEntry
---@param p_MeshConfig EMPTY_SHADER_CONFIG
local function ModifyEntry(p_MeshVariationDatabaseEntry, p_MeshConfig)
	p_MeshVariationDatabaseEntry:MakeWritable()

	for l_MaterialIndex, l_MaterialConfig in pairs(p_MeshConfig.MATERIALS) do
		---This is p_MeshVariationDatabaseEntry.materials[index] -> MeshVariationDatabaseMaterial
		---MeshVariationDatabaseMaterial.material -> MeshMaterial
		local s_MeshMaterial = p_MeshVariationDatabaseEntry.materials[l_MaterialIndex].material

		if s_MeshMaterial.isLazyLoaded then
			s_MeshMaterial:RegisterLoadHandlerOnce(function(p_Instance)
				ModifyThisEntry(MeshMaterial(p_Instance), p_MeshVariationDatabaseEntry, l_MaterialConfig, l_MaterialIndex)
			end)
		else
			ModifyThisEntry(s_MeshMaterial, p_MeshVariationDatabaseEntry, l_MaterialConfig, l_MaterialIndex)
		end
	end
end

---@param p_MeshVariationDatabase MeshVariationDatabase
local function ModifyDatabase(p_MeshVariationDatabase)
	---@type MeshVariationDatabaseEntry
	for _, l_MeshVariationDatabaseEntry in pairs(p_MeshVariationDatabase.entries) do
		local s_MeshConfig = TreeConfig[l_MeshVariationDatabaseEntry.mesh.instanceGuid:ToString('D')]

		if s_MeshConfig ~= nil then
			if l_MeshVariationDatabaseEntry.variationAssetNameHash == (s_MeshConfig.VARIATION_HASH or 0) then
				ModifyEntry(l_MeshVariationDatabaseEntry, s_MeshConfig)
			end
		end
	end
end

---@param p_MeshVariationDatabase MeshVariationDatabase
function TreeRemoving:OnMeshVariationDatabase(p_MeshVariationDatabase)
	ModifyDatabase(p_MeshVariationDatabase)
end

return TreeRemoving()
