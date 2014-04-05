LootDropConfig                               = ZO_Object:Subclass()
LootDropConfig.db                            = nil
LootDropConfig.EVENT_TOGGLE_XP               = 'LOOTDROP_TOGGLE_XP'
LootDropConfig.EVENT_TOGGLE_COIN             = 'LOOTDROP_TOGGLE_COIN'
LootDropConfig.EVENT_TOGGLE_LOOT             = 'LOOTDROP_TOGGLE_LOOT'
LootDropConfig.EVENT_TOGGLE_AP               = 'LOOTDROP_TOGGLE_AP'
LootDropConfig.EVENT_TOGGLE_BT               = 'LOOTDROP_TOGGLE_BT'


local CBM = CALLBACK_MANAGER
local LAM = LibStub( 'LibAddonMenu-1.0' )
if ( not LAM ) then return end

function LootDropConfig:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function LootDropConfig:Initialize( db )
    self.db = db
    self.config_panel = LAM:CreateControlPanel( '_lootdrop', 'LootDrop' )

    LAM:AddHeader( self.config_panel, '_general', 'General' )
    LAM:AddCheckbox( self.config_panel, '_xp', 'Experience', 'Should we show experience gains.',
        function() return self.db.experience end, function() self:ToggleXP() end )
    LAM:AddCheckbox( self.config_panel, '_coin', 'Gold', 'Should we show gold gain and loss.',
        function() return self.db.coin end, function() self:ToggleCoin() end )
    LAM:AddCheckbox( self.config_panel, '_loot', 'Loot', 'Should we show loot.',
        function() return self.db.loot end, function() self:ToggleLoot() end )
    LAM:AddCheckbox( self.config_panel, '_ap', 'Alliance Points', 'Should we show Alliance Points.',
        function() return self.db.alliance end, function() self:ToggleAP() end )
    LAM:AddCheckbox( self.config_panel, '_bt', 'Battle Tokens', 'Should we show Battle Tokens.',
        function() return self.db.battle end, function() self:ToggleBT() end )

    LAM:AddSlider( self.config_panel, '_displayduration', 'Display Duration', 'How long should we show droppables for.', 1, 30, 1,
        function() return self.db.displayduration end, function( duration ) self.db.displayduration = duration end )

    LAM:AddHeader( self.config_panel, '_dimensions', 'Dimensions' )
    LAM:AddSlider( self.config_panel, '_width', 'Width', 'Entry Width', 100, 300, 1,
        function() return self.db.width end, function( width ) self.db.width = width end )
    LAM:AddSlider( self.config_panel, '_height', 'Height', 'Entry Height', 24, 100, 1,
        function() return self.db.height end, function( height ) self.db.height = height end )
    LAM:AddSlider( self.config_panel, '_padding', 'Padding', 'Padding between entries.', 0, 20, 1, 
        function() return self.db.padding end, function( padding ) self.db.padding = padding end )
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