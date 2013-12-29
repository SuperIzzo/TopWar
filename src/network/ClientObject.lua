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
	
	obj._name 		= "";
	obj._authentic	= false;
	
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
--  ClientObject:SetAuthentic : Flags the client as authentic (and sets name)
-------------------------------------------------------------------------------
function ClientObject:SetAuthentic( name, status )
	if not name then
		self._authentic = false;
	elseif name == true then
		self._authentic = true;
	elseif type(name) == "string" then
		local auth = status  or  type(status) == "nil";
		self._authentic = auth;
		self._name = name;
	end
end


-------------------------------------------------------------------------------
--  ClientObject:IsAuthentic : Returns if the client is authentic
-------------------------------------------------------------------------------
function ClientObject:IsAuthentic()
	return self._authentic;
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