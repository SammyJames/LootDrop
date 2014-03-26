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
    self.db      = objectPool.db
    self.control = CreateControlFromVirtual( 'LootDroppable', objectPool:GetControl(), 'LootDroppable', objectPool:GetNextId() )
    self.label   = self.control:GetNamedChild( '_Name' )
    self.icon    = self.control:GetNamedChild( '_Icon' )
end

--- Visibility Getter
-- @treturn boolean
function LootDroppable:IsVisible()
    return self.control:GetAlpha() > 0
end

--- Show this droppable
-- @tparam number y
function LootDroppable:Show( y )
    self.enter_animation:Play()
    local current_x, current_y = self:GetOffsets()
    self.move_animation = self.pool._slide:Apply( self.control, current_x, current_y, 0, y )
    self.move_animation:Play()
end

function LootDroppable:Hide()
    if ( self.exit_animation ) then
        self.exit_animation:InsertCallback( function( ... ) self:Reset() end, 200 )
        self.exit_animation:Play()
    else
        self.control:SetAlpha( 0.0 )
        self:Reset()
    end
end

--- Ready this droppable to show
function LootDroppable:Prepare()
    self:SetAnchor( BOTTOMRIGHT, self.pool:GetControl(), BOTTOMRIGHT, self.db.width, ( #self.pool._active - 1 ) * ( ( self.db.height + self.db.padding ) * -1 ) )

    self.control:SetWidth( self.db.width )
    self.control:SetHeight( self.db.height )
    self.icon:SetWidth( self.db.height )

    self.enter_animation = self.pool._fadeIn:Apply( self.control )
    self.exit_animation  = self.pool._fadeOut:Apply( self.control )
    self.move_animation  = nil

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

function LootDroppable:GetLabel()
    return self.label:GetText()
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
    local current_x, current_y = self:GetOffsets()
    self.move_animation = self.pool._slide:Apply( self.control, current_x, current_y, x, y )
    self.move_animation:Play()
end

--- Get current y offset
-- @treturn number
function LootDroppable:GetOffsets()
    local _, _, _, _, offsX, offsY = self.control:GetAnchor( 0 )
    return offsX, offsY
end