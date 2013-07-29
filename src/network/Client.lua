--===========================================================================--
--  Dependencies
--===========================================================================--
require 'src.lib.bintable'
local socket 			= require 'socket'
local NetworkUtils		= require 'src.network.NetworkUtils'
local Message			= require 'src.network.Message'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Client: A high level client representation
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Client = {}
Client.__index = Client;


-------------------------------------------------------------------------------
--  Client:new : Creates a new Client
-------------------------------------------------------------------------------
function Client:new()
	local obj = {}
	
	obj._udp = socket.udp()

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Client:Connect : Connects to a server
-------------------------------------------------------------------------------
function Client:Connect(address, port)
	local address	= address or NetworkUtils.GetDefaultAddress();
	local port 		= port 	  or NetworkUtils.GetDefaultPort();

	self._udp:settimeout(0)
	self._udp:setpeername(address, port);
end


-------------------------------------------------------------------------------
--  Client:Send : Sends a message to the server
-------------------------------------------------------------------------------
function Client:Send( data )
	local packet = bintable.packtable( data )
	self._udp:send( packet )
end


-------------------------------------------------------------------------------
--  Client:Poll : Reveives a message from the server
-------------------------------------------------------------------------------
function Client:Poll()
	local event = nil
	
	local rawData = self._udp:receive();
	if rawData then
		event = bintable.unpackdata(rawData);
	end
	
	return event;
end


-------------------------------------------------------------------------------
--  Client:Messages : Retrieve message iterator
-------------------------------------------------------------------------------
function Client:Messages()
	return function() return self:Poll() end;
end


------------------------- Non-pure function -----------------------------------


-------------------------------------------------------------------------------
--  Client:Peek : Handles the message
-------------------------------------------------------------------------------
function Client:Peek( msg )
	
end


-------------------------------------------------------------------------------
--  Client:Login : Sends a handshake
-------------------------------------------------------------------------------
function Client:Login( id )
	local message = Message:newLoginMessage( id );
	self:Send( message );
end



--===========================================================================--
--  Initialization
--===========================================================================--
return Client