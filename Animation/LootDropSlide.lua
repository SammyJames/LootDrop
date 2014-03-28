--[[
The MIT License (MIT)

Copyright (c) 2014 Pawkette

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