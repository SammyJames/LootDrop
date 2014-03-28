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