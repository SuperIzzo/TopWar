--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ClientObject : A client representation object stored on the server
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ClientObject = {}
ClientObject.__index = ClientObject


-------------------------------------------------------------------------------
--  ClientObject:new : Creates a new client object
-------------------------------------------------------------------------------
function ClientObject:new( server, session, ip, port )
	local obj = {}
	
	obj._session	= session;
	obj._ip			= ip;
	obj._port		= port;
	
	obj._server		= server;
	obj._lobby		= nil;
	
	return setmetatable( obj, self );
end


function ClientObject:Send( msg )
	return self._server:SendToClient( self, msg );
end


function ClientObject:SetLobby( lobby )
	self._lobby = lobby;
end


function ClientObject:GetLobby()
	return self._lobby;
end


function ClientObject:__tostring()
	return "Client object: " .. tostring(self._ip) .. ":" .. tostring(self._port) 
			.. "; session: " .. tostring(self._session);
end

--===========================================================================--
--  Initialization
--===========================================================================--
return ClientObject