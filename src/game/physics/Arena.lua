--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class PhArena : The physical data and logic of a battle arena
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local PhArena = {}
PhArena.__index = PhArena;


-------------------------------------------------------------------------------
--  PhArena:new : Creates a new arena
-------------------------------------------------------------------------------
function PhArena:new()
	local obj = {}
	
	obj._depthMask = nil;
	obj._normalMask = nil;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  PhArena:SetDepthMask : Sets the depth mask of the arena
-------------------------------------------------------------------------------
function PhArena:SetDepthMask( mask )
	self._depthMask = mask;
end


-------------------------------------------------------------------------------
--  PhArena:SetDepthMask : Sets the depth mask of the arena
-------------------------------------------------------------------------------
function PhArena:GetNormal( x, y )
	local result = {};
	
	result.x = 0;
	result.y = 0;
	result.z = 0;
	
	return result;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return PhArena