local LobbyManager = {}
LobbyManager.__index = LobbyManager



local function LobbyManager_new( self )
	local obj = {}
	
	obj._activeLobbies = {}
	obj._defaultLobby = nil
	
	return setmetatable( obj, self )
end


local instance
function LobbyManager:GetInstance()
	if not instance then
		instance = LobbyManager_new( self )
	end
	
	return instance;
end



function LobbyManager:AddLobby( lobby )
	self._activeLobbies[ #self._activeLobbies+1 ] = lobby;
end


function LobbyManager:SetDefaultLobby( lobby )
	self._defaultLobby = lobby;
end


function LobbyManager:GetDefaultLobby( lobby )
	return self._defaultLobby;
end


function LobbyManager:Update( dt )
	for i=1, #self._activeLobbies do
		local lobby = self._activeLobbies[i]
		lobby:Update( dt );
	end
end



return LobbyManager