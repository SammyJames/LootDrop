local LootDropAnimPool = LootDropAnimPool
LootDropPop = LootDropAnimPool:Subclass()

function LootDropPop:New()
    return LootDropAnimPool.New( self )
end

function LootDropPop:Create()
    local anim = LootDropAnimPool.Create( self, ANIMATION_PLAYBACK_PING_PONG, 1 )
    anim:ScaleToFrom( 1.0, 1.2, 100 )
    return anim
end