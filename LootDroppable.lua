------------------------------------------------
-- Loot Drop - show me what I got
--
-- @classmod LootDroppable
-- @author Pawkette ( pawkette.heals@gmail.com )
-- @copyright MIT 
------------------------------------------------

LootDroppable = ZO_Object:Subclass()

function LootDroppable:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function LootDroppable:Initialize( objectPool )
    self.control = CreateControlFromVirtual( 'LootDroppable', objectPool:GetControl(), 'LootDroppable', objectPool:GetNextControlId() )
    self.label = self.control:GetNamedChild( '_Name' )
    self.icon = self.control:GetNamedChild( '_Icon' )

    self:Reset()
end

function LootDroppable:Show()
    self.control:SetHidden( false )
end

function LootDroppable:Reset()
    self.control:SetHidden( true )
    self.label:SetText( '' )
    self.timestamp = 0
end

function LootDroppable:GetControl()
    return self.control
end

function LootDroppable:SetTimestamp( stamp )
    self.timestamp = stamp
end

function LootDroppable:GetTimestamp()
    return self.timestamp
end

function LootDroppable:SetLabel( label )
    self.label:SetText( label )
end

function LootDroppable:SetIcon( icon )
    self.icon:SetTexture( icon )
end

function LootDroppable:SetAnchor( ... )
    self.control:SetAnchor( ... )
end