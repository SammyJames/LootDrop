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

LootDropConfig                               = ZO_Object:Subclass()
LootDropConfig.db                            = nil
LootDropConfig.EVENT_TOGGLE_XP               = 'LOOTDROP_TOGGLE_XP'
LootDropConfig.EVENT_TOGGLE_COIN             = 'LOOTDROP_TOGGLE_COIN'
LootDropConfig.EVENT_TOGGLE_LOOT             = 'LOOTDROP_TOGGLE_LOOT'


local CBM = CALLBACK_MANAGER
local LAM = LibStub( 'LibAddonMenu-1.0' )

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