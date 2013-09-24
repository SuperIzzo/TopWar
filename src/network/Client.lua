--===========================================================================--
--  Dependencies
--===========================================================================--
require 'src.lib.bintable'
local socket 			= require 'socket'
local NetworkUtils		= require 'src.network.NetworkUtils'
local NetworkBase		= require 'src.network.NetworkBase'
local Message			= require 'src.network.Message'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Client: A high level client representation
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Client = setmetatable({}, NetworkBase)
Client.__index = Client;

local instance

-------------------------------------------------------------------------------
--  Client:new : Creates a new Client
-------------------------------------------------------------------------------
function Client:new()
	local obj = NetworkBase.new(self)
	
	return obj;
end


-------------------------------------------------------------------------------
--  Client:SetInstance : Sets a singleton instance
-------------------------------------------------------------------------------
function Client:SetInstance( client )
	instance = client;
end


-------------------------------------------------------------------------------
--  Client:GetInstance : Returns a singleton instance
-------------------------------------------------------------------------------
function Client:GetInstance()
	return instance;
end


-------------------------------------------------------------------------------
--  Server:Poll : Overwrite Poll
-------------------------------------------------------------------------------
function Client:Poll()
	local data = NetworkBase.Poll( self );
	local client = nil
	
	if data then 
		if data.type == Message.Type.LOGIN and data.session then
			self._session = data.session;
			return self:Poll(); -- skip to next message
		else			
			return Message:new( data );
		end
	end
end


-------------------------------------------------------------------------------
--  Client:Send : Overwrite send
-------------------------------------------------------------------------------
function Client:Send( data, ip, port )
	data.session = self._session;
	return NetworkBase.Send( self, data, ip, port )
end


-------------------------------------------------------------------------------
--  Client:IsLoggedIn : return true if logged in
-------------------------------------------------------------------------------
function Client:IsLoggedIn()
	return ((self._session and true) or false)
end


-------------------------------------------------------------------------------
--  Client:Login : Sends a login request message to the server
-------------------------------------------------------------------------------
function Client:Login( id )
	local msg = {}
	msg.type = Message.Type.LOGIN
	msg.id = id;

	return self:Send( msg );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Client