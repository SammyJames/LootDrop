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
LootDrop.dirty_flags    = setmetatable( {}, { __mode = 'kv'} )

local Config            = LootDropConfig
local CBM               = CALLBACK_MANAGER

local defaults =
{
    enterduration   = 200,
    exitduration    = 200,
    moveduration    = 200,
    displayduration = 10,
    experience      = true,
    coin            = true,
    loot            = true,
    width           = 202,
    height          = 42,
    font_face       = [[/esoui/common/fonts/univers55.otf]],
    font_size       = 16,
    font_decoration = 'soft-shadow-thin',
    padding         = 6
}

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
function LootDrop:Initialize( control, db )
    self.control        = control
    self.db             = db
    self.config         = Config:New( self.db )

    self:ToggleCoin()
    self:ToggleXP()
    self:ToggleLoot()

    self.control:SetHandler( 'OnUpdate', function() self:OnUpdate() end )

    CBM:RegisterCallback( Config.EVENT_TOGGLE_COIN, function() self:ToggleCoin()    end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_XP,   function() self:ToggleXP()      end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_LOOT, function() self:ToggleLoot()    end )
end

function LootDrop:ToggleCoin() 
    if ( self.db.coin ) then
        self.current_money = GetCurrentMoney()
        self.control:RegisterForEvent( EVENT_MONEY_UPDATE, function( ... ) self:OnMoneyUpdated( ... )  end )
    else
        self.control:UnregisterForEvent( EVENT_MONEY_UPDATE )
    end
end

function LootDrop:ToggleXP()
    if ( self.db.experience ) then
        self.current_xp = GetUnitXP( 'player' )
        self.control:RegisterForEvent( EVENT_EXPERIENCE_UPDATE, function( ... ) self:OnXPUpdated( ... )     end )
    else
        self.control:UnregisterForEvent( EVENT_EXPERIENCE_UPDATE )
    end
end

function LootDrop:ToggleLoot()
    if ( self.db.loot ) then
        self.control:RegisterForEvent( EVENT_LOOT_RECEIVED, function( ... ) self:OnItemLooted( ... )    end )
    else
        self.control:UnregisterForEvent( EVENT_LOOT_RECEIVED )
    end
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
        if ( GetDiffBetweenTimeStamps(currentTime, v:GetTimestamp() ) > self.db.displayduration ) then
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
                v:Move( 0, last_y )
            end
            last_y = last_y - ( self.db.height + self.db.padding )
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
    droppable:Hide()
end

function LootDrop:AcquireObject()
    local result = ZO_ObjectPool.AcquireObject( self )
    table.insert( self.dirty_flags, DirtyFlags.LAYOUT )
    result:Prepare()
    return result
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

    if ( not icon or icon == '' ) then
        icon = [[/esoui/art/icons/icon_missing.dds]]
    end

    local newDrop, _ = self:AcquireObject()

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

    newDrop:SetIcon( [[/esoui/art/icons/item_generic_coinbag.dds]] )
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

    local gain = xp - self.current_xp

    self.current_xp = xp

    local newDrop, _ = self:AcquireObject()

    newDrop:SetIcon( [[/lootdrop/textures/arrow_up.dds]] )
    newDrop:SetLabel( '+' .. gain )
    newDrop:SetTimestamp( GetTimeStamp() )
end

--- Getter for the control xml element
-- @treturn table 
function LootDrop:GetControl()
    return self.control
end

function LootDrop_Initialized( self )
    LOOTDROP_DB = LOOTDROP_DB or {}

    for k,v in pairs( defaults ) do
        if ( type( LOOTDROP_DB[ k ] == 'nil' ) ) then
            LOOTDROP_DB[ k ] = v
        end
    end

    LOOT_DROP = LootDrop:New( self, LOOTDROP_DB )
end