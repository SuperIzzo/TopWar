--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class LobbyManager : Selection scene 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local LobbyManager = {}
LobbyManager.__index = LobbyManager


-------------------------------------------------------------------------------
--  LobbyManager_new : Creates a new scene manager
-------------------------------------------------------------------------------
local function LobbyManager_new()
	local obj = {}
	
	obj._activeLobby = nil;
	
	return setmetatable( obj, LobbyManager );
end


-------------------------------------------------------------------------------
--  LobbyManager:GetInstance : Returns the scene manager instace
-------------------------------------------------------------------------------
local lobbyManager
function LobbyManager:GetInstance()
	if not lobbyManager then
		lobbyManager = LobbyManager_new();
	end
	
	return lobbyManager;
end


-------------------------------------------------------------------------------
--  LobbyManager:AddLobby : Adds a lobby
-------------------------------------------------------------------------------
function LobbyManager:AddLobby( lobby )
	self._activeLobby  = lobby;
end


-------------------------------------------------------------------------------
--  LobbyManager:Network : Handles network messages in the active lobbies
-------------------------------------------------------------------------------
function LobbyManager:Network( msg )
	if self._activeLobby and self._activeLobby.Network then
		self._activeLobby:Network( msg );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return LobbyManager
