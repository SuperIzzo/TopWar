--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ClientObject : A client representation object stored on the server
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ClientObject = {}
ClientObject.__index = ClientObject


-------------------------------------------------------------------------------
--  ClientObject:new : Creates a new client object
-------------------------------------------------------------------------------
function ClientObject:new( server, ip, port )
	local obj = {}
	
	obj._ip			= ip;
	obj._port		= port;
	
	obj._server		= server;
	obj._lobby		= nil;
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  ClientObject:Send : Sends a message to this client
-------------------------------------------------------------------------------
function ClientObject:Send( msg )
	return self._server:SendToClient( self, msg );
end


-------------------------------------------------------------------------------
--  ClientObject:__tostring : Sends a message to this client
-------------------------------------------------------------------------------
function ClientObject:__tostring()
	return "Client object: " .. tostring(self._ip) .. ":" .. tostring(self._port);
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ClientObject