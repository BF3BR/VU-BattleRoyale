---@class ParameterModificationType
ParameterModificationType = {
	ModifyParameters = 0, -- Modifies parameters if they exist.
	ModifyOrAddParameters = 1, -- Modifies parameters if they exist, adds them if they don't.
	ReplaceParameters = 2, -- Clears existing parameters and adds the specified parameters.
}
