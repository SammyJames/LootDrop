----------------------------------------------------
-- Lib Animation - for all your animation needs
--
-- @classmod LibAnimation
-- @author Pawkette ( pawkette.heals@gmail.com )
-- @copyright 2014 Pawkette
--[[
The MIT License (MIT)

Copyright (c) <year> <copyright holders>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
----------------------------------------------------
if ( not LibStub ) then return end

local kName, kVersion   = 'LibAnimation-1.0', 2.1
local LibAnimation      = LibStub:NewLibrary( kName, kVersion )
if ( not LibAnimation ) then return end

local AnimationMgr          = ANIMATION_MANAGER
local defaultEase           = ZO_LinearEase

local ANIMATION_SIZE        = ANIMATION_SIZE
local ANIMATION_TRANSLATE   = ANIMATION_TRANSLATE
local ANIMATION_SCALE       = ANIMATION_SCALE
local ANIMATION_ALPHA       = ANIMATION_ALPHA
local _

--- Create a new animation for control
-- @tparam table control (optional)
-- @tparam number playbackType (optional)
-- @tparam number loopCount (optional)
-- @treturn LibAnimation object
function LibAnimation:New( control, playbackType, loopCount )
    local result    = setmetatable( {}, self )
    local mt        = getmetatable( result )
    mt.__index      = self

    if ( not playbackType ) then
        playbackType = 0
    end

    if ( not loopCount ) then
        loopCount = 0
    end

    result:Initialize( control, playbackType, loopCount )
    return result
end

--- Animation Constructor
-- @tparam table control (optional)
-- @tparam number playbackType (optional)
-- @tparam number loopCount (optional)
function LibAnimation:Initialize( control, playbackType, loopCount )
    self.control    = control
    self.timeline   = AnimationMgr:CreateTimeline()
    self.timeline:SetPlaybackType( playbackType, loopCount )
end

function LibAnimation:Apply( control )
    self.timeline:ApplyAllAnimationsToControl( control )
end

function LibAnimation:SetHandler( ... )
    self.timeline:SetHandler( ... )
end

--- Allows you to add a callback at a certain point in the timeline
-- @tparam function fn
-- @tparam number delay how long to wait before calling
function LibAnimation:InsertCallback( fn, delay )
    if ( self.timeline ) then
        self.timeline:InsertCallback( fn, delay )
    end
end

--- Stop the animation
function LibAnimation:Stop()
    self.timeline:Stop()
end

--- Play the animation from the begining
function LibAnimation:Play()
    self.timeline:PlayFromStart()
end

--- Play the animation from the end
function LibAnimation:PlayBackward()
    self.timeline:PlayFromEnd()
end

--- Play the animation forward from where it was stopped
function LibAnimation:Forward()
    self.timeline:PlayForward()
end

--- Play the animation backward from where it was stopped
function LibAnimation:Backward()
    self.timeline:PlayBackward()
end

function LibAnimation:SetUserData( data )
    self._udata = data 
end

function LibAnimation:GetUserData()
    return self._udata
end

--- Get's the existing animation or creates a new one
-- @tparam number animType
-- @tparam number delay (optional)
-- @tresult animation
function LibAnimation:Insert( animType, duration, delay, anchorIndex, fn )
    local anim = self.timeline:InsertAnimation( animType, self.control, delay or 0 )

    anim:SetDuration( duration or 1 )
    anim:SetEasingFunction( fn or defaultEase )

    if ( animType == ANIMATION_TRANSLATE ) then
        anim:SetAnchorIndex( anchorIndex or 0 )
    end
    return anim
end

--- Create new translate animation
-- @tparam number xorigin
-- @tparam number yorigin
-- @tparam number xoffset
-- @tparam number yoffset
-- @tparam number duration
-- @tparam number delay (optional)
-- @tparam number anchorIndex (optional)
-- @tparam function fn easing function (optional)
function LibAnimation:TranslateToFrom( xorigin, yorigin, xoffset, yoffset, duration, delay, anchorIndex, fn )
    self:Stop()
    local anim = self:Insert( ANIMATION_TRANSLATE, duration, delay, anchorIndex, fn )
    anim:SetStartOffsetX( xorigin )
    anim:SetStartOffsetY( yorigin )
    anim:SetEndOffsetX( xoffset )
    anim:SetEndOffsetY( yoffset )
end

--- Create new translate animation
-- @tparam number xoffset
-- @tparam number yoffset
-- @tparam number duration
-- @tparam number delay (optional)
-- @tparam number anchorIndex (optional)
-- @tparam function fn easing function (optional)
function LibAnimation:TranslateTo( xoffset, yoffset, duration, delay, anchorIndex, fn )
    local _, _, _, _, offsX, offsY = self.control:GetAnchor( anchorIndex or 0 )
    self:TranslateToFrom( offsX, offsY, xoffset, yoffset, duration, delay, anchorIndex, fn )
end

--- Create a new size animation
-- @tparam number startWidth
-- @tparam number startHeight
-- @tparam number width target width
-- @tparam number height target height
-- @tparam number duration 
-- @tparam number delay (optional)
-- @tparam function fn easing function (optional)
function LibAnimation:ResizeToFrom( startWidth, startHeight, width, height, duration, delay, fn )
    self:Stop()
    local anim = self:Insert( ANIMATION_SIZE, duration, delay, nil, fn )
    anim:SetHeightStartAndEnd( startHeight, height )
    anim:SetWidthStartAndEnd( startWidth, width )
end

--- Create a new size animation
-- @tparam number width target width
-- @tparam number height target height
-- @tparam number duration 
-- @tparam number delay (optional)
-- @tparam function fn easing function (optional)
function LibAnimation:ResizeTo( width, height, duration, delay, fn )
    self:ResizeToFrom( self.control:GetWidth(), self.control:GetHeight(), width, height, duration, delay, fn )
end


--- Create a new scale animation
-- @tparam number startScale
-- @tparam number scale
-- @tparam number duration
-- @tparam number delay (optional)
-- @tparam function fn easing function (optional)
function LibAnimation:ScaleToFrom( startScale, scale, duration, delay, fn )
    self:Stop()
    local anim = self:Insert( ANIMATION_SCALE, duration, delay, nil, fn )
    anim:SetScaleValues( startScale, scale )
end

--- Create a new scale animation
-- @tparam number scale
-- @tparam number duration
-- @tparam number delay (optional)
-- @tparam function fn easing function (optional)
function LibAnimation:ScaleTo( scale, duration, delay, fn )
    self:ScaleToFrom( self.control:GetScale(), scale, duration, delay, fn )
end


function LibAnimation:AlphaToFrom( startAlpha, alpha, duration, delay, fn )
    self:Stop()
    local anim = self:Insert( ANIMATION_ALPHA, duration, delay, nil, fn )
    anim:SetAlphaValues( startAlpha, alpha )
end

--- Create a new alpha animation
-- @tparam number alpha
-- @tparam number duration
-- @tparam number delay (optional)
-- @tparam function fn easing function (optional)
function LibAnimation:AlphaTo( alpha, duration, delay, fn )
    self:AlphaToFrom( self.control:GetAlpha(), alpha, duration, delay, fn )
end

--- Create a new scroll animation
-- @tparam number x 
-- @tparam number y 
-- @tparam number duration
-- @tparam number delay (optional)
-- @tparam function fn easing function (optional)
--[[function LibAnimation:ScrollTo( x, y, duration, delay, fn )
    local anim = self:GetOrCreate( ANIMATION_SCROLL, delay )

    anim:SetDuration( duration or 1 )
    anim:SetEasingFunction( fn or defaultEase )
end]]