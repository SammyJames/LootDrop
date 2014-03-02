
LibTranslateAnimation = ZO_Object:Subclass()

function LibTranslateAnimation:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )

    return result
end

function LibTranslateAnimation:Initialize( control )
    self.control = control 
    self.timeline = ANIMATION_MANAGER:CreateTimeline()
end

--- Translate Position
-- @tparam number x
-- @tparam number y
-- @tparam number duration 
function LibTranslateAnimation:TranslateTo( from_x, from_y, to_x, to_y, duration, anchorIndex )
    local animation = nil
    if ( self.timeline:IsPlaying() ) then
        animation = self.timeline:GetFirstAnimation()
    else 
        animation = self.timeline:InsertAnimation( ANIMATION_TRANSLATE, self.control ) --CreateSimpleAnimation( ANIMATION_TRANSLATE, control )
    end

    animation:SetDuration( duration or 1 )
    animation:SetEasingFunction( ZO_EaseInQuadratic )
    animation:SetStartOffsetX( from_x )
    animation:SetStartOffsetY( from_y )
    animation:SetEndOffsetX( to_x )
    animation:SetEndOffsetY( to_y )
    animation:SetAnchorIndex( anchorIndex )
    
    self.timeline:SetPlaybackType( ANIMATION_PLAYBACK_ONE_SHOT, 0 )
    self.timeline:PlayFromStart()
end