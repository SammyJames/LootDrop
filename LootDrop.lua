------------------------------------------------
-- Loot Drop - show me what I got
--
-- @author Pawkette ( pawkette.heals@gmail.com )
------------------------------------------------
local LootDropPool      = LootDropPool
local LootDrop          = LootDropPool:Subclass()
LootDrop.dirty_flags    = {}
LootDrop.pending_pool   = setmetatable( {}, { __mode = 'kv' } )
LootDrop.config         = nil
LootDrop.db             = nil

local tinsert           = table.insert
local tremove           = table.remove
local ZO_ColorDef       = ZO_ColorDef
local zo_min            = zo_min
local zo_parselink      = ZO_LinkHandler_ParseLink

local Config            = LootDropConfig
local LootDroppable     = LootDroppable
local CBM               = CALLBACK_MANAGER

local LootDropFade      = LootDropFade
local LootDropSlide     = LootDropSlide
local LootDropPop       = LootDropPop

local _



local defaults =
{
    displayduration = 10,
    experience      = true,
    coin            = true,
    loot            = true,
    alliance        = true,
    battle          = true,
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
    self._pop     = LootDropPop:New()

    self._coinId = nil
    self._xpId   = nil
    self._apId   = nil
    self._btId   = nil

    CBM:RegisterCallback( Config.EVENT_TOGGLE_COIN, function() self:ToggleCoin()    end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_XP,   function() self:ToggleXP()      end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_LOOT, function() self:ToggleLoot()    end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_AP,   function() self:ToggleAP()      end )
    CBM:RegisterCallback( Config.EVENT_TOGGLE_BT,   function() self:ToggleBT()      end )
end

function LootDrop:OnLoaded( event, addon )
    if ( addon ~= 'LootDrop' ) then
        return
    end
    self.db     = ZO_SavedVars:NewAccountWide( 'LOOTDROP_DB', 2.2, nil, defaults )
    self.config = Config:New( self.db )

    self:ToggleCoin()
    self:ToggleXP()
    self:ToggleLoot()
    self:ToggleAP()
    self:ToggleBT()
end

function LootDrop:ToggleCoin() 
    if ( self.db.coin ) then
        self.current_money = GetCurrentMoney()
        self.control:RegisterForEvent( EVENT_MONEY_UPDATE, function( _, ... ) self:OnMoneyUpdated( ... )  end )
    else
        self.control:UnregisterForEvent( EVENT_MONEY_UPDATE )
    end
end

function LootDrop:ToggleXP()
    if ( self.db.experience ) then
        self.current_xp = GetUnitXP( 'player' )
        self.control:RegisterForEvent( EVENT_EXPERIENCE_UPDATE, function( _, ... ) self:OnXPUpdated( ... ) end )
    else
        self.control:UnregisterForEvent( EVENT_EXPERIENCE_UPDATE )
    end
end

function LootDrop:ToggleLoot()
    if ( self.db.loot ) then
        self.control:RegisterForEvent( EVENT_LOOT_RECEIVED, function( _, ... ) self:OnItemLooted( ... )  end )
        self.control:RegisterForEvent( EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function( _, ... ) self:OnInventorySlotUpdated( ... ) end )
    else
        self.control:UnregisterForEvent( EVENT_LOOT_RECEIVED )
        self.control:UnregisterForEvent( EVENT_INVENTORY_SINGLE_SLOT_UPDATE )
    end
end

function LootDrop:ToggleAP()
    if ( self.db.alliance ) then
        self.control:RegisterForEvent( EVENT_ALLIANCE_POINT_UPDATE, function( _, ... ) self:OnAPUpdate( ... ) end )
    else
        self.control:UnregisterForEvent( EVENT_ALLIANCE_POINT_UPDATE )
    end
end

function LootDrop:ToggleBT()
    if ( self.db.battle ) then
        self.control:RegisterForEvent( EVENT_BATTLE_TOKEN_UPDATE, function( _, ... ) self:OnBTUpdate( ... ) end )
    else
        self.control:UnregisterForEvent( EVENT_BATTLE_TOKEN_UPDATE )
    end
end

--- Check if any flags are set, if no flag is passed will check if any flag is set.
--
-- @param flag the flag to check, or nil for any flag
-- @return if the provided flag is set, or any flag is set if nil
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
-- 
-- @param frameTime     the delta between frames
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
        entry = nil

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
--
-- @return a new LootDroppable
function LootDrop:CreateDroppable()
    return LootDroppable:New( self )
end

--- Reset a loot droppable
--
-- @param droppable the droppable to reset
-- @param key       a key to check against 
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

function LootDrop:FormatItemName( str )
    local result = ''

    local entry = nil
    local char = ''
    local needsUpper = false

    for i=1,str:utf8len() do
        char = str:utf8sub( i, i )

        if ( i == 1 or needsUpper ) then
            result = result .. char:utf8upper()
        else
            result = result .. char 
        end
        
        needsUpper = ( char == ' ' ) 
    end

    return result
end

--- Parse an item link 
--
-- @param link
-- @return the text of the link and the identifier
function LootDrop:ParseLink( link )
    if ( type( link ) ~= 'string' ) then
        return nil, nil
    end

    local text, _, _, identifier = zo_parselink( link )

    if ( not text or text == '' ) then
        text = link 
    end
    return text, identifier
end

--- Called when the player loots stuff, and does other things >.>
--
-- @param bagId     the bag id of the item
-- @param slotId    the slot id within the bag
-- @param newItem   if the item is new or not
function LootDrop:OnInventorySlotUpdated( bagId, slotId, newItem, _, updateReason )
    if ( ( updateReason ~= INVENTORY_UPDATE_REASON_DEFAULT ) or ( bagId ~= BAG_BACKPACK ) ) then
        return
    end

    local link = GetItemLink( bagId, slotId, LINK_STYLE_DEFAULT )
    local _, identifier = self:ParseLink( link )
    local _, _, _, _, _, _, _, quality = GetItemInfo( bagId, slotId )

    tinsert( self.pending_pool, { [ 'id' ] = identifier, [ 'quality' ] = quality } )
end

--- Locate a pending item from the pending pool
--
-- @param identifier    the id of the item we're looking for
-- @return  pending item or nil
function LootDrop:FindPendingItem( identifier ) 

    for k,pending in pairs( self.pending_pool ) do
        if ( pending[ 'id' ] == identifier ) then
            return tremove( self.pending_pool, k )
        end
    end

    return nil
end

--- Called when you loot an Item
--
-- @param itemName  the name of the item looted (link)
-- @param quantity  the number of items looted
-- @param mine      if this item is the local player's
function LootDrop:OnItemLooted( _, itemName, quantity, _, _, mine )
    if ( not mine ) then
        return
    end

    local icon, _, _, _, _ = GetItemLinkInfo( itemName )
    local text, identifier = self:ParseLink( itemName )
    local quality = ITEM_QUALITY_TRASH

    local pending = self:FindPendingItem( identifier )
    if ( pending ) then
        quality = pending.quality
    end

    local color_def = GetItemQualityColor( quality )
    text = self:FormatItemName( text )
    text = color_def:Colorize( text )

    if ( not icon or icon == '' ) then
        icon = [[/esoui/art/icons/icon_missing.dds]]
    end

    local newDrop, _ = self:Acquire()

    newDrop:SetTimestamp( GetFrameTimeSeconds() )
    newDrop:SetRarity( color_def )
    newDrop:SetIcon( icon )
    newDrop:SetLabel( zo_strformat( '<<1>> <<2[//x$d]>>', text, quantity ) )
end 

--- Called when the amount of money you have changes
--
-- @param money     the amount of money you currently have
function LootDrop:OnMoneyUpdated( money )
    if ( self.current_money == money ) then
        return
    end

    local difference = money - self.current_money
    self.current_money = money

    local pop = false

    local newDrop = nil
    if ( self._coinId ) then
        newDrop = self:Get( self._coinId )

        if ( newDrop ) then
            pop = true
            difference = difference + ( newDrop:GetLabel() or 0 )
        end
    end

    if ( not newDrop ) then
        newDrop, self._coinId = self:Acquire()
    end

    newDrop:SetTimestamp( GetFrameTimeSeconds() )
    newDrop:SetRarity( ZO_ColorDef:New( 'FFFF66' ) )
    newDrop:SetIcon( [[/esoui/art/icons/item_generic_coinbag.dds]] )
    newDrop:SetLabel( difference )

    if ( pop ) then
        local anim = self._pop:Apply( newDrop.control )
        anim:Forward()
    end
end

--- Called when the player's XP changes
--
-- @param tag       which player this applies too
-- @param exp       the amount of xp change
-- @param maxExp    the current max amount of xp for this level
-- @param reason    why the plasyer gained xp
function LootDrop:OnXPUpdated( tag, exp, maxExp, reason )
    if ( tag ~= 'player' ) then
        return
    end

    local xp = zo_min( exp, maxExp )

    if ( self.current_xp == xp ) then
        return 
    end

    local gain = xp - self.current_xp
    self.current_xp = xp

    if ( gain <= 0 ) then
        return
    end

    local pop = false

    local newDrop = nil
    if ( self._xpId ) then
        newDrop = self:Get( self._xpId )

        if ( newDrop ) then
            pop = true
            gain = gain + ( newDrop:GetLabel() or 0 )
        end
    end

    if ( not newDrop ) then
        newDrop, self._xpId = self:Acquire()
    end

    newDrop:SetTimestamp( GetFrameTimeSeconds() )
    newDrop:SetRarity( ZO_ColorDef:New( 0, 1, 0, 1 ) )
    newDrop:SetIcon( [[/lootdrop/textures/decoration.dds]], { 0.734375, 1, 0, 0.234375 } )
    newDrop:SetLabel( gain )

    if ( pop ) then
        local anim = self._pop:Apply( newDrop.control )
        anim:Forward()
    end
end

--- Called when the player's AP changes
-- 
-- @param difference    the amount of AP change
function LootDrop:OnAPUpdate( _, _, difference )
    local pop = false

    local newDrop = nil
    if ( self._apId ) then
        newDrop = self:Get( self._apId )

        if ( newDrop ) then
            pop = true
            difference = difference + ( newDrop:GetLabel() or 0 )
        end
    end

    if ( not newDrop ) then
        newDrop, self._apId = self:Acquire()
    end

    newDrop:SetTimestamp( GetFrameTimeSeconds() ) 
    newDrop:SetRarity( ZO_ColorDef:New( 0, 0, 1, 1 ) )
    newDrop:SetIcon( [[/lootdrop/textures/decoration.dds]], { 0, 0.2734375, 0.46875, 0.6328125 } )
    newDrop:SetLabel( difference )

    if ( pop ) then
        local anim = self._pop:Apply( newDrop.control )
        anim:Forward()
    end
end

--- Called when the player's BT changes
--
-- @param difference    the amount of BT change
function LootDrop:OnBTUpdate( _, _, difference )
    local pop = false

    local newDrop = nil
    if ( self._btId ) then
        newDrop = self:Get( self._btId )

        if ( newDrop ) then
            pop = true
            difference = difference + ( newDrop:GetLabel() or 0 )
        end
    end

    if ( not newDrop ) then
        newDrop, self._btId = self:Acquire()
    end

    newDrop:SetTimestamp( GetFrameTimeSeconds() ) 
    newDrop:SetRarity( ZO_ColorDef:New( 1, 0, 0, 1 ) )
    newDrop:SetIcon( [[/lootdrop/textures/decoration.dds]], { 0.734375, 1, 0.2343750, 0.46875 } )
    newDrop:SetLabel( difference )
    
    if ( pop ) then
        local anim = self._pop:Apply( newDrop.control )
        anim:Forward()
    end
end

--- Getter for the control xml element
--
-- @return the visual UI
function LootDrop:GetControl()
    return self.control
end

function LootDrop_Initialized( self )
    LOOT_DROP = LootDrop:New( self )
end