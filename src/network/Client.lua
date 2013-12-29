--===========================================================================--
--  Dependencies
--===========================================================================--
require 'src.lib.bintable'
local socket 			= require 'socket'
local NetUtils			= require 'src.network.NetworkUtils'
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
	
	obj._authentic 	= false;
	obj._name 		= false;
	
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
--  Client:Poll : Overwrite Poll
-------------------------------------------------------------------------------
function Client:Poll()
	local data = NetworkBase.Poll( self );
	local client = nil
	
	if data then 			
		local msg = Message:new( data );
		
		self:Peek( msg );
		
		return msg;
	end
end


-------------------------------------------------------------------------------
--  Client:Authenticate : Authenticates the client to the server
-------------------------------------------------------------------------------
function Client:Authenticate( name, pass )
	self:Send(NetUtils.NewAuthMsg( name, pass ));
end


-------------------------------------------------------------------------------
--  Client:IsAuthentic : Retuerns true if the client is authenticated
-------------------------------------------------------------------------------
function Client:IsAuthentic()
	return self._authentic;
end


-------------------------------------------------------------------------------
--  Client:HandleMsg_AUTH : Handles authentication feedback
-------------------------------------------------------------------------------
Client[ "HandleMsg_" .. Message.Type.AUTH ] = function(self, msg)
	if msg:GetSubtype() == Message.Type.INFO then
		local userName = msg.name;
		local status   = msg.status;
		
		if status then
			self._authentic	= true;
			self._name 		= userName;
			print( "Client authenticated: \"" .. userName .. "\"");
		else
			self._name 		= "";
		end
	end	
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Client