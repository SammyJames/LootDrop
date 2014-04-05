------------------------------------------------
-- Loot Drop - show me what I got
--
-- @classmod LootDroppable
-- @author Pawkette ( pawkette.heals@gmail.com )
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
    self.border  = self.control:GetNamedChild( '_Rarity' )
    self.bg      = self.control:GetNamedChild( '_BG' )
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

--- Set rarity border
-- @tparam ZO_ColorDef color
function LootDroppable:SetRarity( color )
    if ( not color ) then
        color = ZO_ColorDef:New( 1, 1, 1, 1 )
    end

    self.border:SetColor( color:UnpackRGBA() )
end

function LootDroppable:GetLabel()
    return tonumber( self.label:GetText() or 0 )
end

--- Set Icon
-- @tparam string icon
function LootDroppable:SetIcon( icon, coords )
    local texture, _, _, _, left, right, top, bottom = self.icon:GetTextureInfo()

    if ( texture == icon ) then
        return
    end

    self.icon:SetTexture( icon )
    
    if ( coords ) then
        self.icon:SetTextureCoords( unpack( coords ) )
    else
        self.icon:SetTextureCoords( left, right, top, bottom )
    end

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