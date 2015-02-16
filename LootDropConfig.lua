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
            author = 'Pawkette', 
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

    local alignments = 
    {
        "CENTER", 
        "LEFT", 
        "RIGHT"
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
            tooltip = 'How long should we display each dropper.',
            getFunc = function() return self.db.displayduration end,
            setFunc = function( duration ) self.db.displayduration = duration end,
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
            numeric = true,
            tooltip = 'The width of each dropper.',
            getFunc = function() return self.db.width end,
            setFunc = function( width ) self.db.width = width end,
        },
        [ 10 ] =
        {
            type = 'editbox',
            name = 'Height',
            numeric = true,
            tooltip = 'The height of each dropper.',
            getFunc = function() return self.db.height end,
            setFunc = function( height ) self.db.height = height end,
        },   
        [ 11 ] =
        {
            type = 'editbox',
            name = 'Padding',
            numeric = true,
            tooltip = 'The padding between each dropper.',
            getFunc = function() return self.db.padding end,
            setFunc = function( padding ) self.db.padding = padding end,
        },
        [ 12 ] = 
        {
            type = 'submenu',
            name = 'Text Style',
            tooltip = 'What would you like the text to look like.',
            reference = 'LootDrop_TextStyle_Submenu'
            controls = 
            {
                [ 1 ] = 
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
                [ 2 ] = 
                {
                    type = 'editbox',
                    name = 'Font Size',
                    numeric = true,
                    getFunc = function() return self.db.font.size end,
                    setFunc = function( size ) 
                            self.db.font.size = size 
                            self:UpdateFont() 
                        end,
                },
                [ 3 ] = 
                {
                    type = 'dropdown',
                    name = 'Font Decoration',
                    tooltip = 'Decoration for the font, like shadows.',
                    choices = decorations,
                    getFunc = function() return self.db.font.decoration end,
                    setFunc = function( choice ) 
                            self.db.font.decoration = choice 
                            self:UpdateFont() 
                        end,
                    width = 'full'
                },
                [ 4 ] = 
                {
                    type = 'dropdown',
                    name = 'Font Alignment',
                    tooltip = 'Where should the font align.',
                    choices = alignments,
                    getFunc = function() return self.db.font.align end,
                    setFunc = function( choice ) self.db.font.align = choice end,
                    width = 'full'
                },
            }
        }
    }

    LAM:RegisterOptionControls( 'LootDrop_Config', options )
end

function LootDropConfig:UpdateFont()
    local Submenu = _G[ 'LootDrop_TextStyle_Submenu' ]

    if ( Submenu ) then
        local path = LMP:Fetch( LMP.MediaType.FONT, self.db.font.face )
        local fmt = '%s|%d'
        if ( self.db.font.decoration ~= 'none' ) then
            fmt = fmt .. '|%s'
        end

        Submenu.label:SetFont( fmt:format( path, self.db.font.size, self.db.font.decoration ) )
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