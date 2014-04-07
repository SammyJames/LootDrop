local LibAnim = LibStub( 'LibAnimation-1.0' )
if ( not LibAnim ) then return end

local ZO_ObjectPool = ZO_ObjectPool
LootDropAnimPool = ZO_ObjectPool:Subclass()

function LootDropAnimPool:New()
    local result = ZO_ObjectPool.New( self, self.Create, function( ... ) self:Reset( ... ) end )
    return result
end

function LootDropAnimPool:Create( animType, loop )
    return LibAnim:New( nil, animType, loop ) 
end

function LootDropAnimPool:Reset( anim )
    anim:Stop()
end

function LootDropAnimPool:Apply( control )
    local anim, key = self:AcquireObject()
    anim:SetUserData( key )
    anim:Apply( control )
    anim:SetHandler( 'OnStop', 
        function( animation ) 
            self:ReleaseObject( anim:GetUserData() ) 
        end )

    return anim
end
