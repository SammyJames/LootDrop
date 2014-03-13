------------------------------------------------
-- Loot Drop - show me what I got
--
-- @classmod LootDroppable
-- @author Pawkette ( pawkette.heals@gmail.com )
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
------------------------------------------------

LootDroppable           = ZO_Object:Subclass()
local LibAnimation      = LibStub('LibAnimation-1.0')
local Config            = LootDropConfig
local Font              = nil

if ( Config.FONT_SHADOW ~= '' ) then
    Font = string.format( '%s|%d|%s', Config.FONT_FACE, Config.FONT_SIZE, Config.FONT_SHADOW )
else
    Font = string.format( '%s|%d', Config.FONT_FACE, Config.FONT_SIZE )
end

--- Create a new instance of a LootDroppable
-- @treturn LootDroppable
function LootDroppable:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

--- Constructor
--
function LootDroppable:Initialize( objectPool )
    self.pool    = objectPool
    self.control = CreateControlFromVirtual( 'LootDroppable', objectPool:GetControl(), 'LootDroppable', objectPool:GetNextControlId() )
    self.label   = self.control:GetNamedChild( '_Name' )
    self.icon    = self.control:GetNamedChild( '_Icon' )

    self.label:SetFont( Font )
end

--- Visibility Getter
-- @treturn boolean
function LootDroppable:IsVisible()
    return self.control:GetAlpha() > 0
end

--- Show this droppable
-- @tparam number y
function LootDroppable:Show( y )
    self.enter_animation:AlphaTo( 1.0, Config.ENTER_ANIM_DURATION )
    self.enter_animation:TranslateTo( 0, y, Config.ENTER_ANIM_DURATION )
    self.enter_animation:Play()
end

function LootDroppable:Hide()
     self.exit_animation:AlphaTo( 0.0, Config.EXIT_ANIM_DURATION )
    local y = self:GetOffsetY()
    self.exit_animation:TranslateTo( 220, y, Config.EXIT_ANIM_DURATION )
    self.exit_animation:InsertCallback( function( ... ) self:Reset() end, Config.EXIT_ANIM_DURATION )
    self.exit_animation:Play()
end

--- Ready this droppable to show
function LootDroppable:Prepare()
    self:SetAnchor( BOTTOMRIGHT, self.pool:GetControl(), BOTTOMRIGHT, 220, ( self.pool:GetActiveObjectCount() - 1 ) * ( Config.SPACING * -1 ) )

    self.enter_animation = LibAnimation:New( self.control )
    self.exit_animation  = LibAnimation:New( self.control )
    self.move_animation  = LibAnimation:New( self.control )

    self.control:SetAlpha( 0 )
    self.label:SetText( '' )
    self.icon:SetTexture( '' )
    self.timestamp = 0
end

--- Reset this droppable
function LootDroppable:Reset()
    self.enter_animation = nil
    self.exit_animation  = nil
    self.move_animation  = nil

    self.label:SetText( '' )
    self.icon:SetHidden( true )
    self.icon:SetTexture( '' )
    self.timestamp = 0
end

--- Control getter
-- @treturn table
function LootDroppable:GetControl()
    return self.control
end

--- Set show timestamp
-- @tparam number stamp
function LootDroppable:SetTimestamp( stamp )
    self.timestamp = stamp
end

--- Get show timestamp
-- @treturn number
function LootDroppable:GetTimestamp()
    return self.timestamp
end

--- Set label
-- @tparam string label
function LootDroppable:SetLabel( label )
    self.label:SetText( label )
end

--- Set Icon
-- @tparam string icon
function LootDroppable:SetIcon( icon )
    self.icon:SetTexture( icon )
    self.icon:SetHidden( false )
end

--- Pass anchor information to control
function LootDroppable:SetAnchor( ... )
    self.control:SetAnchor( ... )
end

--- Pass translate information to animation
function LootDroppable:Move( x, y )
    self.move_animation:TranslateTo( x, y, Config.MOVE_ANIM_DURATION, 0 )
    self.move_animation:Play()
end

--- Get current y offset
-- @treturn number
function LootDroppable:GetOffsetY()
    local _, _, _, _, _, offsY = self.control:GetAnchor( 0 )
    return offsY
end