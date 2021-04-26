class "BaseMixin"

function BaseMixin:__init()
    self:RegisterVars()
    self:RegisterEvents()
end

function BaseMixin:RegisterVars()

end

function BaseMixin:RegisterEvents()
    Events:Subscribe("Level:Destroy", self, self.Destroy)
    Events:Subscribe("Extension:Unloading", self, self.Destroy)
end

function BaseMixin:Destroy(p_Reset)
    if p_Reset then
        self:RegisterVars()
    end
end

function BaseMixin:Reset()
    self:Destroy(true)
end

function BaseMixin:__gc()
    self:Destroy()
end
