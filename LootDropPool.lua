LootDropPool = ZO_Object:Subclass()

local tinsert = table.insert
local tremove = table.remove

function LootDropPool:New()
    return ZO_Object.New( self )
end

function LootDropPool:Initialize( create, reset )
    self._create    = create
    self._reset     = reset
    self._active    = {}
    self._inactive  = {}
    self._controlId = 0
end

function LootDropPool:GetNextId()
    self._controlId = self._controlId + 1
    return self._controlId
end

function LootDropPool:Active()
    return self._active
end

function LootDropPool:Acquire()
    local result = nil
    if ( #self._inactive > 0 ) then
        result = tremove( self._inactive, 1 )
    else
        result = self._create()
    end

    tinsert( self._active, result )
    return result, #self._active
end

function LootDropPool:Get( key )
    if ( not key or type( key ) ~= 'number' or key > #self._active ) then
        return nil
    end

    return self._active[ key ]
end

function LootDropPool:Release( object )
    local i = 1
    while( i <= #self._active ) do
        if ( self._active[ i ] == object ) then
            self._reset( object, i )
            tinsert( self._inactive, tremove( self._active, i ) )
            break
        else
            i = i + 1 
        end
    end
end

function LootDropPool:ReleaseAll()
    for i=#self._active,1,-1 do 
        tinsert( self._inactive, tremove( self._active, i ) )
    end
end