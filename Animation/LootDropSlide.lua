local LootDropAnimPool = LootDropAnimPool
LootDropSlide = LootDropAnimPool:Subclass()

local Back = 
{
    EaseIn = function( step )
        local s = 1.70158
        return step * step * ( ( s + 1 ) * step - s )
    end,

    EaseOut = function( step )
        local s = 1.70158
        local val = step - 1
        return val * val * ( ( s + 1 ) * val + s ) + 1
    end,
}

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
    if ( from_y == to_y and to_x == 0 ) then
        translate:SetStartOffsetX( from_x )
        translate:SetStartOffsetY( from_y )
        translate:SetEndOffsetX( to_x )
        translate:SetEndOffsetY( to_y )

        translate:SetEasingFunction( Back.EaseOut )
    else
        translate:SetStartOffsetX( from_x )
        translate:SetStartOffsetY( from_y )
        translate:SetEndOffsetX( to_x )
        translate:SetEndOffsetY( to_y )

        translate:SetEasingFunction( Back.EaseIn )
    end

    return result
end