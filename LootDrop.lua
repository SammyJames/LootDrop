------------------------------------------------
-- Loot Drop - show me what I got
--
-- @classmod LootDrop
-- @author Pawkette ( pawkette.heals@gmail.com )
-- @copyright MIT 
------------------------------------------------
local LootDrop = ZO_ObjectPool:Subclass()
LootDrop.dirty_flags = {}

local DirtyFlags =
{
    LAYOUT = 1
}

--- Create our ObjectPool
-- @param ...
function LootDrop:New( ... )
    local result = ZO_ObjectPool.New( self, LootDrop.CreateDroppable, function( ... ) self:ResetDroppable( ... ) end )
    result:Initialize( ... )
    return result
end

--- I swear I'm going to use this for something
-- @param ...
function LootDrop:Initialize( control )
    self.control = control
    self.control:RegisterForEvent( EVENT_LOOT_RECEIVED, function( ... ) self:OnItemLooted( ... ) end )
    self.control:SetHandler( 'OnUpdate', function() self:OnUpdate() end )
end

function LootDrop:IsDirty( flag )
    if ( not flag ) then return #self.dirty_flags ~= 0 end

    for _,v in pairs( self.dirty_flags ) do
        if ( v == flag ) then
            return true
        end
    end

    return false
end

function LootDrop:OnUpdate() 
    if ( self:GetActiveObjectCount() == 0 ) then
        return
    end

    if ( self:IsDirty( DirtyFlags.LAYOUT ) ) then
        local lastObject = self:GetControl()
        local point = BOTTOMRIGHT
        for _,v in pairs( self:GetActiveObjects() ) do
            v:SetAnchor( BOTTOMRIGHT, lastObject, point, 0, -3 )
            lastObject = v:GetControl()
            point = TOPRIGHT
        end
    end

    self.dirty_flags = {}

    local currentTime = GetTimeStamp()
    for k,v in pairs( self:GetActiveObjects() ) do
        if ( GetDiffBetweenTimeStamps(currentTime, v:GetTimestamp() ) > 10 ) then
            self:ReleaseObject( k )
            table.insert( self.dirty_flags, DirtyFlags.LAYOUT )
        end
    end
end

--- Create a new loot droppable
-- @tparam ZO_ObjectPool _ unused
function LootDrop:CreateDroppable()
    return LootDroppable:New( self )
end

--- Reset a loot droppable
-- @tparam LootDroppable droppable 
function LootDrop:ResetDroppable( droppable )
    droppable:Reset()
end

function LootDrop:OnItemLooted( _, _, itemName, quantity, _, _, mine )
    if ( not mine ) then
        return
    end

    local icon, price, _, _, _ = GetItemLinkInfo( itemName )
    local newDrop, _ = self:AcquireObject()

    table.insert( self.dirty_flags, DirtyFlags.LAYOUT )

    newDrop:SetIcon( icon )
    newDrop:SetLabel( zo_strformat( '<<1>> <<2[//x$d]>>', itemName, quantity ) )
    newDrop:SetTimestamp( GetTimeStamp() )
    newDrop:Show()
end 

function LootDrop:GetControl()
    return self.control
end

function LootDrop_Initialized( self )
    LOOT_DROP = LootDrop:New( self )
end