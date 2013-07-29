--===========================================================================--
--  Dependencies
--===========================================================================--
-- Modules

-- Aliases
local setmetatable 		= setmetatable



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Lobby: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Lobby = {}
Lobby.__index = Lobby;


-------------------------------------------------------------------------------
--  Lobby:new : Creates a new Lobby
-------------------------------------------------------------------------------
function Lobby:new( numSlots )
	local obj = {}
	
	obj._numSlots = numSlots or 2;
	obj._players = {};

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Lobby:GetNumSlots : Returns the number of slots
-------------------------------------------------------------------------------
function Lobby:GetNumSlots()
	return self._numSlots;
end


-------------------------------------------------------------------------------
--  Lobby:GetRemainingSlots : Returns the number of slots
-------------------------------------------------------------------------------
function Lobby:GetRemainingSlots()
	return self.numSlots - #self._players;
end


-------------------------------------------------------------------------------
--  Lobby:Enter : Enters a player into the lobby
-------------------------------------------------------------------------------
function Lobby:Enter( player )
	local success = false;
	
	if self:GetRemainingSlots()>0 then
		table.insert( self._players, player );
		success = true;
	end
	
	return success;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return Lobby