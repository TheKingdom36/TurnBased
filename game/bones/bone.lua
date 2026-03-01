local BoneTypes = require('game.bones.Types')

local Bone = {}
Bone.__index = Bone

function Bone:new(type, name, uses)
    local bone = {
        type = type,
        name = name,
        uses = uses
    }
    setmetatable(bone, self)
    return bone
end

function Bone:use()
    self.uses = self.uses - 1
end

return Bone
