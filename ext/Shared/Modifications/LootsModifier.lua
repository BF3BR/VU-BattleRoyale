class "LootsModifier"


function LootsModifier:__init()
    --self:RegisterEvents()
end

function LootsModifier:OnSubWorldLoaded(p_SubWorldData, p_Registry, p_IndexInBlueprint)
    print("[LootsModifier] Loot spawns created                                                          s i k e")

    return p_IndexInBlueprint
end

-- Singleton.
if g_LootsModifier == nil then
	g_LootsModifier = LootsModifier()
end

return g_LootsModifier