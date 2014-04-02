local LootDropAnimPool = LootDropAnimPool
LootDropSlide = LootDropAnimPool:Subclass()

function LootDropSlide:New( duration )
    local result = LootDropAnimPool.New( self )
    result:Initialize( duration )
    return result
end

function LootDropSlide:Initialize( duration )
    self._duration      = duration
end

function LootDropSlide:Create()
    local anim = LootDropAnimPool.Create( self )
    anim:TranslateToFrom( 0, 0, 0, 0, self._duration )
    return anim
end

function LootDropSlide:Apply( control, from_x, from_y, to_x, to_y )
    local result = LootDropAnimPool.Apply( self, control )
    local timeline = result.timeline  

    local translate = timeline:GetFirstAnimation()
    translate:SetStartOffsetX( from_x )
    translate:SetStartOffsetY( from_y )
    translate:SetEndOffsetX( to_x )
    translate:SetEndOffsetY( to_y )

    return result
end