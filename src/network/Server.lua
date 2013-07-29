--===========================================================================--
--  Dependencies
--===========================================================================--
require 'src.lib.bintable'
local socket 			= require "socket"
local NetworkUtils		= require 'src.network.NetworkUtils'
local Message			= require 'src.network.Message'	



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Server : A high level server representation
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Server = {}
Server.__index = Server;


-------------------------------------------------------------------------------
--  Server:new : Creates a new server object
-------------------------------------------------------------------------------
function Server:new()
	local obj = {}
	
	obj._udp 		= socket.udp()
	obj._clients 	= {};
	obj._lobbies	= {};
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  Server:Start : Starts up the server
-------------------------------------------------------------------------------
function Server:Start( port )
	local port = port or NetworkUtils.GetDefaultPort();

	self._udp:settimeout(0)
	self._udp:setsockname('*', port)
	self._port = port;
end


-------------------------------------------------------------------------------
--  Server:Send : Sends a message to a client
-------------------------------------------------------------------------------
function Server:Send( client, msg )
	local port = port or NetworkUtils.GetDefaultPort();
	local packet = bintable.packtable( msg )
	
	self._udp:sendto( packet, client.ip, client.port )
end


-------------------------------------------------------------------------------
--  Server:SendAll : Sends a message to all clients
-------------------------------------------------------------------------------
function Server:SendAll( msg )
	for id, client in pairs( self._clients ) do
		self:Send( client, msg );
	end
end


-------------------------------------------------------------------------------
--  Server:Poll : Retrieve server events
-------------------------------------------------------------------------------
function Server:Poll()
	local event = nil
	local rawData, ip, port = self._udp:receivefrom();
	
	if rawData then
		event = bintable.unpackdata(rawData);
		event._ip	= ip;
		event._port	= port;
	end
	
	return event;
end


-------------------------------------------------------------------------------
--  Server:Messages : Retrieve message iterator
-------------------------------------------------------------------------------
function Server:Messages()
	return function() return self:Poll() end;
end


------------------------- Non-pure function -----------------------------------


-------------------------------------------------------------------------------
--  Server:Peek : Handles a message internally
-------------------------------------------------------------------------------
function Server:Peek( msg )
	if  msg  and  type(msg.type) == "string"  then
		local handler = self[ "HandleMsg_" .. msg.type ];
		if handler then
			handler( self, msg );
		end
	end
end


-------------------------------------------------------------------------------
--  Server:DispatchLobbyList : Dispatch a list of all lobbies to each client
-------------------------------------------------------------------------------
function Server:DispatchLobbyList()
	local lobbyList = {}
	
	for lobby in ipairs(self._lobbies) do
		local lobbyData = {}
		lobbyData.name = lobby.GetLobbyName();
	end
end

-------------------------------------------------------------------------------
--  Server:Login : Handle login message
-------------------------------------------------------------------------------
function Server:HandleMsg_login( msg )
	local message = Message:newLoginMessage();
	local client = {}
	
	client.id = msg.id;
	client.ip = msg._ip;
	client.port = msg._port;
	self._clients[client.id] = client;
	
	local accepted = Message:newAcceptMessage()
	self:Send( client, accepted )
	
	print( client.id .. " logged in" );
end



--===========================================================================--
--  Initialization
--===========================================================================--
return Server