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
		return Message:new( data );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Client