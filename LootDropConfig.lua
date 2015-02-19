LootDropConfig                               = ZO_Object:Subclass()
LootDropConfig.db                            = nil
LootDropConfig.EVENT_TOGGLE_XP               = 'LOOTDROP_TOGGLE_XP'
LootDropConfig.EVENT_TOGGLE_COIN             = 'LOOTDROP_TOGGLE_COIN'
LootDropConfig.EVENT_TOGGLE_LOOT             = 'LOOTDROP_TOGGLE_LOOT'
LootDropConfig.EVENT_TOGGLE_AP               = 'LOOTDROP_TOGGLE_AP'
LootDropConfig.EVENT_TOGGLE_BT               = 'LOOTDROP_TOGGLE_BT'


local CBM = CALLBACK_MANAGER
local LAM = LibStub( 'LibAddonMenu-2.0' )
if ( not LAM ) then return end

local LMP = LibStub( 'LibMediaProvider-1.0' )
if ( not LMP ) then return end

function LootDropConfig:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function LootDropConfig:Initialize( db )
    self.db = db
    LAM:RegisterAddonPanel( 'LootDrop_Config', 
        { 
            type = 'panel', 
            name = 'LootDrop', 
            author = '|cFF66CCPawkette|r', 
            version = '100010', 
            slashCommand = '/lootdrop', 
            registerForRefresh = true,
            registerForDefaults = true 
        } )

    local decorations = 
    { 
        'none', 
        'outline', 
        'thin-outline', 
        'thick-outline', 
        'soft-shadow-thin', 
        'soft-shadow-thick', 
        'shadow' 
    }

    local options = 
    {
        [ 1 ] = 
        {
            type = 'header',
            name = 'General',
            width = 'full',
        },
        [ 2 ] = 
        {
            type = 'checkbox',
            name = 'Experience',
            tooltip = 'Should we show experience gain.',
            getFunc = function() return self.db.experience end,
            setFunc = function( _ ) self:ToggleXP() end,
        },
        [ 3 ] = 
        {
            type = 'checkbox',
            name = 'Coin',
            tooltip = 'Should we show coin gain and loss.',
            getFunc = function() return self.db.coin end,
            setFunc = function( _ ) self:ToggleCoin() end,
        },
        [ 4 ] = 
        {
            type = 'checkbox',
            name = 'Loot',
            tooltip = 'Should we show loot.',
            getFunc = function() return self.db.loot end,
            setFunc = function( _ ) self:ToggleLoot() end,
        },
        [ 5 ] = 
        {
            type = 'checkbox',
            name = 'Alliance Points',
            tooltip = 'Should we show Alliance Points.',
            getFunc = function() return self.db.alliance end,
            setFunc = function( _ ) self:ToggleAP() end,
        }, 
        [ 6 ] = 
        {
            type = 'checkbox',
            name = 'Battle Tokens',
            tooltip = 'Should we show Alliance Points.',
            getFunc = function() return self.db.battle end,
            setFunc = function( _ ) self:ToggleBT() end,
        },   
        [ 7 ] =
        {
            type = 'editbox',
            name = 'Display Duration',
            textType = TEXT_TYPE_NUMERIC,
            tooltip = 'How long should we display each dropper.',
            getFunc = function() return self.db.displayduration end,
            setFunc = function( duration ) self.db.displayduration = tonumber( duration ) end,
        },       
        [ 8 ] =
        {
            type = 'header',
            name = 'Dimensions',
            width = 'full',
        },  
        [ 9 ] =
        {
            type = 'editbox',
            name = 'Width',
            textType = TEXT_TYPE_NUMERIC,
            tooltip = 'The width of each dropper.',
            getFunc = function() return self.db.width end,
            setFunc = function( width ) self.db.width = tonumber( width ) end,
        },
        [ 10 ] =
        {
            type = 'editbox',
            name = 'Height',
            textType = TEXT_TYPE_NUMERIC,
            tooltip = 'The height of each dropper.',
            getFunc = function() return self.db.height end,
            setFunc = function( height ) self.db.height = tonumber( height ) end,
        },   
        [ 11 ] =
        {
            type = 'editbox',
            name = 'Padding',
            textType = TEXT_TYPE_NUMERIC,
            tooltip = 'The padding between each dropper.',
            getFunc = function() return self.db.padding end,
            setFunc = function( padding ) self.db.padding = tonumber( padding ) end,
        },
        [ 12 ] = 
        {
            type = 'header',
            name = 'Text Style',
            reference = 'LootDrop_TextStyle_Header'
        },
        [ 13 ] = 
        { 
            type = 'dropdown',
            name = 'Font Face',
            tooltip = 'Pick a font (LMP support).',
            choices = LMP:List( LMP.MediaType.FONT ),
            getFunc = function() return self.db.font.face end,
            setFunc = function( choice ) 
                    self.db.font.face = choice 
                    self:UpdateFont() 
                end,
            width = 'full'
        },
        [ 14 ] = 
        {
            type = 'editbox',
            name = 'Font Size',
            textType = TEXT_TYPE_NUMERIC,
            getFunc = function() return self.db.font.size end,
            setFunc = function( size ) 
                    self.db.font.size = tonumber( size ) 
                    self:UpdateFont() 
                end,
        },
        [ 15 ] = 
        {
            type = 'dropdown',
            name = 'Font Decoration',
            tooltip = 'Decoration for the font, like shadows.',
            choices = decorations,
            getFunc = function() return self.db.font.deco end,
            setFunc = function( choice ) 
                    self.db.font.deco = choice 
                    self:UpdateFont() 
                end,
            width = 'full',
            default = 'thin-outline',
        },
    }

    LAM:RegisterOptionControls( 'LootDrop_Config', options )
end

function LootDropConfig:UpdateFont()
    local Header = _G[ 'LootDrop_TextStyle_Header' ]

    if ( Header ) then
        local path = LMP:Fetch( LMP.MediaType.FONT, self.db.font.face )
        local fmt = '%s|%d'
        if ( self.db.font.deco ~= 'none' ) then
            fmt = fmt .. '|%s'
        end

        Header.header:SetFont( fmt:format( path, self.db.font.size, self.db.font.deco or '' ) )
    end
end

function LootDropConfig:ToggleXP()
    self.db.experience = not self.db.experience
    CBM:FireCallbacks( self.EVENT_TOGGLE_XP )
end

function LootDropConfig:ToggleCoin()
    self.db.coin = not self.db.coin 
    CBM:FireCallbacks( self.EVENT_TOGGLE_COIN )
end

function LootDropConfig:ToggleLoot()
    self.db.loot = not self.db.loot
    CBM:FireCallbacks( self.EVENT_TOGGLE_LOOT )
end

function LootDropConfig:ToggleAP()
    self.db.alliace = not self.db.alliace
    CBM:FireCallbacks( self.EVENT_TOGGLE_AP )
end

function LootDropConfig:ToggleBT()
    self.db.battle = not self.db.battle
    CBM:FireCallbacks( self.EVENT_TOGGLE_BT )
end