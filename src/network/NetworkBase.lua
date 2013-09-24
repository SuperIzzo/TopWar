--===========================================================================--
--  Dependencies
--===========================================================================--
require 'src.lib.bintable'
local socket 			= require "socket"
local NetworkUtils		= require 'src.network.NetworkUtils'



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class NetworkBase: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local NetworkBase = {}
NetworkBase.__index = NetworkBase;


-------------------------------------------------------------------------------
--  NetworkBase:new : Creates a new NetworkBase
-------------------------------------------------------------------------------
function NetworkBase:new()
	local obj = {}
		
	obj._udp  = socket.udp()
	obj._udp:settimeout(0)

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  NetworkBase:Bind : Binds the connection to a port and/or address
-------------------------------------------------------------------------------
function NetworkBase:Bind( address, port )
	local address 	= address 	or '*'
	local port 		= port 		or NetworkUtils.GetDefaultPort();
	
	self._udp:setsockname( address, port )
	self._port = port;
end
	

-------------------------------------------------------------------------------
--  NetworkBase:Connect : Connects to a server
-------------------------------------------------------------------------------
function NetworkBase:Connect( address, port )
	local address	= address or NetworkUtils.GetDefaultAddress();
	local port 		= port 	  or NetworkUtils.GetDefaultPort();

	self._udp:setpeername( address, port );
	self._connected = true;
end


-------------------------------------------------------------------------------
--  NetworkBase:IsConnected : Returns true if connected
-------------------------------------------------------------------------------
function NetworkBase:IsConnected()
	return self._connected
end


-------------------------------------------------------------------------------
--  NetworkBase:Send : Sends a message
-------------------------------------------------------------------------------
function NetworkBase:Send( data, ip, port )
	local data = assert( data, "No data provided" );
	local packet = bintable.packtable( data )
	
	if self:IsConnected() then
		self._udp:send( packet )
	else
		local ip   = assert( ip, "No ip provided for unconnected message" )
		local port = assert( port, "No port provided for unconnected message" )
		self._udp:sendto( packet, ip, port )
	end
end


-------------------------------------------------------------------------------
--  NetworkBase:Poll : Polls pending messages
-------------------------------------------------------------------------------
function NetworkBase:Poll()
	local event = nil
	local rawData = nil;
	local ip, port = nil, nil
	
	if self:IsConnected() then
		rawData = self._udp:receive();
	else
		rawData, ip, port = self._udp:receivefrom();
	end
	
	if rawData then
		event = bintable.unpackdata(rawData); 
	end
	
	return event, ip, port;
end


-------------------------------------------------------------------------------
--  NetworkBase:Messages : Retrieve message iterator
-------------------------------------------------------------------------------
function NetworkBase:Messages()
	return function() return self:Poll() end;
end


-------------------------------------------------------------------------------
--  NetworkBase:Peek : Handles a message internally
-------------------------------------------------------------------------------
function NetworkBase:Peek( msg )
	print( msg and msg.type );
	if  msg  and  type(msg.type) == "string"  then
		local handler = self[ "HandleMsg_" .. msg.type ];
		if handler then
			handler( self, msg );
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return NetworkBase