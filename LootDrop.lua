------------------------------------------------
-- Loot Drop - show me what I got
--
-- @classmod LootDrop
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
local LootDrop          = ZO_ObjectPool:Subclass()
LootDrop.dirty_flags    = {}
LootDrop.current_money  = 0
LootDrop.current_xp     = 0

--- Flags for updating UI aspects
local DirtyFlags =
{
    LAYOUT = 1 -- we've added or removed a droppable
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
    self.control        = control
    self.current_money  = GetCurrentMoney()
    self.current_xp     = GetUnitXP( 'player' )

    self.control:RegisterForEvent( EVENT_LOOT_RECEIVED,     function( ... ) self:OnItemLooted( ... )    end )
    self.control:RegisterForEvent( EVENT_MONEY_UPDATE,      function( ... ) self:OnMoneyUpdated( ... )  end )
    self.control:RegisterForEvent( EVENT_EXPERIENCE_UPDATE, function( ... ) self:OnXPUpdated( ... )     end )

    self.control:SetHandler( 'OnUpdate', function() self:OnUpdate() end )
end

--- Check if any flags are set
-- if no flag is passed will check if any flag is set.
-- @tparam DirtyFlags flag
-- @treturn boolean
function LootDrop:IsDirty( flag )
    if ( not flag ) then return #self.dirty_flags ~= 0 end

    for _,v in pairs( self.dirty_flags ) do
        if ( v == flag ) then
            return true
        end
    end

    return false
end

--- On every consecutive frame
function LootDrop:OnUpdate() 
    if ( not self:GetActiveObjectCount() ) then
        return
    end

    local currentTime = GetTimeStamp()
    for k,v in pairs( self:GetActiveObjects() ) do
        if ( GetDiffBetweenTimeStamps(currentTime, v:GetTimestamp() ) > 10 ) then
            self:ReleaseObject( k )
            table.insert( self.dirty_flags, DirtyFlags.LAYOUT )
        end
    end

    if ( self:IsDirty( DirtyFlags.LAYOUT ) ) then
        local last_y = 0
        for _,v in pairs( self:GetActiveObjects() ) do
            if ( not v:IsVisible() ) then
                v:Show( last_y )
            else            
                v:TranslateTo( 0, v:GetOffsetY(), 0, last_y, 200, 0 )
            end
            last_y = last_y - 45
        end
    end

    self.dirty_flags = {}
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

--- Called when you loot an Item
-- @tparam string itemName
-- @tparam number quantity 
-- @tparam boolean mine
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
end 

--- Called when the amount of money you have changes
-- @tparam number money 
function LootDrop:OnMoneyUpdated( _, money, _ )
    if ( self.current_money == money ) then
        return
    end

    local difference = money - self.current_money

    if ( difference > 0 ) then
        difference = '+' .. tostring( difference )
    else
        difference = tostring( difference )
    end

    self.current_money = money

    local newDrop, _ = self:AcquireObject()

    table.insert( self.dirty_flags, DirtyFlags.LAYOUT )

    newDrop:SetIcon( 'EsoUI/Art/Icons/Item_Generic_CoinBag.dds' )
    newDrop:SetLabel( difference )
    newDrop:SetTimestamp( GetTimeStamp() )
end

function LootDrop:OnXPUpdated( _, tag, exp, maxExp, reason )
    if ( tag ~= 'player' ) then
        return
    end

    local xp = zo_min( exp, maxExp )

    if ( self.current_xp == xp ) then
        return 
    end

    self.current_xp = xp

    local newDrop, _ = self:AcquireObject()

    table.insert( self.dirty_flags, DirtyFlags.LAYOUT )

    newDrop:SetIcon( 'EsoUI/Art/Icons/icon_missing.dds' )
    newDrop:SetLabel( '+' .. xp )
    newDrop:SetTimestamp( GetTimeStamp() )
end

--- Getter for the control xml element
-- @treturn table 
function LootDrop:GetControl()
    return self.control
end

function LootDrop_Initialized( self )
    LOOT_DROP = LootDrop:New( self )
end