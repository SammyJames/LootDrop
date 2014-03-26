------------------------------------------------
-- Loot Drop - show me what I got
--
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
local LootDropPool      = LootDropPool
local LootDrop          = LootDropPool:Subclass()
LootDrop.dirty_flags    = setmetatable( {}, { __mode = 'kv'} )
LootDrop.config         = nil
LootDrop.db             = nil

local tinsert           = table.insert

local Config            = LootDropConfig
local LootDroppable     = LootDroppable
local CBM               = CALLBACK_MANAGER

local _

local defaults =
{
    displayduration = 10,
    experience      = true,
    coin            = true,
    loot            = true,
    width           = 202,
    height          = 42,
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
    local result = LootDropPool.New( self )
    result:Initialize( ... )
    return result
end

--- I swear I'm going to use this for something
-- @param ...
function LootDrop:Initialize( control )
    LootDropPool.Initialize( self, function() return self:CreateDroppable() end, function( ... ) self:ResetDroppable( ... ) end  )

    self.control = control
    self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( ... ) self:OnLoaded( ... ) end )
    self.control:SetHandler( 'OnUpdate',                function( _, ft ) self:OnUpdate( ft ) end )

    self._fadeIn  = LootDropFade:New( 0.0, 1.0, 200 )
    self._fadeOut = LootDropFade:New( 1.0, 0.0, 200 )
    self._slide   = LootDropSlide:New( 200 )

    self._coinId = nil
    self._xpId   = nil

    CBM:RegisterCallback( Config.EVENT_TOGGLE_COIN, function() self:ToggleCoin()    end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_XP,   function() self:ToggleXP()      end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_LOOT, function() self:ToggleLoot()    end )
end

function LootDrop:OnLoaded( event, addon )
    if ( addon ~= 'LootDrop' ) then
        return
    end
    self.db     = ZO_SavedVars:NewAccountWide( 'LOOTDROP_DB', 2.0, nil, defaults )
    self.config = Config:New( self.db )

    self:ToggleCoin()
    self:ToggleXP()
    self:ToggleLoot()
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
function LootDrop:OnUpdate( frameTime ) 
    if ( not #self._active ) then
        return
    end

    local i = 1
    local entry = nil
    while( i <= #self._active ) do
        entry = self._active[ i ]

        if ( frameTime - entry:GetTimestamp() > self.db.displayduration ) then
            self:Release( entry )
            tinsert( self.dirty_flags, DirtyFlags.LAYOUT )
        else
            i = i + 1
        end
    end

    if ( self:IsDirty( DirtyFlags.LAYOUT ) ) then
        local last_y = 0
        local entry = nil

        for i=1,#self._active do
            entry = self._active[ i ]

            if ( not entry:IsVisible() ) then
                entry:Show( last_y )
            else            
                entry:Move( 0, last_y )
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
function LootDrop:ResetDroppable( droppable, key )
    if ( key == self._coinId ) then
        self._coinId = nil
    elseif( key == self._xpId ) then
        self._xpId = nil
    end

    droppable:Hide()
end

function LootDrop:Acquire()
    local result, key = LootDropPool.Acquire( self )
    result:Prepare()

    tinsert( self.dirty_flags, DirtyFlags.LAYOUT )

    return result, key
end

--- Called when you loot an Item
-- @tparam string itemName
-- @tparam number quantity 
-- @tparam boolean mine
function LootDrop:OnItemLooted( _, _, itemName, quantity, _, _, mine )
    if ( not mine ) then
        return
    end

    local icon, _, _, _, _ = GetItemLinkInfo( itemName )
    local itemClean = itemName:match( 'h(.*)[%^h]' )
    local original  = itemClean
    itemClean = itemClean:gsub( '(%a)([%w\']+)', function( char, rest ) return char:upper() .. rest:lower() end )
    itemName = itemName:gsub( original, itemClean, 1 )
    if ( not icon or icon == '' ) then
        icon = [[/esoui/art/icons/icon_missing.dds]]
    end

    local newDrop, _ = self:Acquire()

    newDrop:SetIcon( icon )
    newDrop:SetLabel( zo_strformat( '<<1>> <<2[//x$d]>>', itemName, quantity ) )
    newDrop:SetTimestamp( GetFrameTimeSeconds() )
end 

--- Called when the amount of money you have changes
-- @tparam number money 
function LootDrop:OnMoneyUpdated( _, money, _ )
    if ( self.current_money == money ) then
        return
    end

    local difference = money - self.current_money
    self.current_money = money

    local newDrop = nil
    if ( self._coinId ) then
        newDrop = self:Get( self._coinId )

        if ( newDrop ) then
            difference = difference + tonumber( newDrop:GetLabel() )
        end
    end

    if ( not newDrop ) then
        newDrop, self._coinId = self:Acquire()
    end

    newDrop:SetIcon( [[/esoui/art/icons/item_generic_coinbag.dds]] )
    newDrop:SetLabel( difference )
    newDrop:SetTimestamp( GetFrameTimeSeconds() )
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

    local newDrop = nil
    if ( self._xpId ) then
        newDrop = self:Get( self._xpId )

        if ( newDrop ) then
            gain = gain + tonumber( newDrop:GetLabel() )
        end
    end

    if ( not newDrop ) then
        newDrop, self._xpId = self:Acquire()
    end

    newDrop:SetIcon( [[/lootdrop/textures/arrow_up.dds]] )
    newDrop:SetLabel( gain )
    newDrop:SetTimestamp( GetFrameTimeSeconds() )
end

--- Getter for the control xml element
-- @treturn table 
function LootDrop:GetControl()
    return self.control
end

function LootDrop_Initialized( self )
    LOOT_DROP = LootDrop:New( self, LOOTDROP_DB )
end