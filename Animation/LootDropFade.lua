local LootDropAnimPool = LootDropAnimPool
LootDropFade = LootDropAnimPool:Subclass()

function LootDropFade:New( from, to, duration )
    local result = LootDropAnimPool.New( self )
    result:Initialize( from, to, duration )
    return result
end

function LootDropFade:Initialize( from, to, duration )
    self._from          = from
    self._to            = to
    self._duration      = duration
end

function LootDropFade:Create()
    local anim = LootDropAnimPool.Create( self )
    anim:AlphaToFrom( self._from, self._to, self._duration )
    return anim
end