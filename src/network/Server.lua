--===========================================================================--
--  Dependencies
--===========================================================================--
require 'src.lib.bintable'
local socket 			= require "socket"
local NetworkUtils		= require 'src.network.NetworkUtils'
local NetworkBase		= require 'src.network.NetworkBase'
local Message			= require 'src.network.Message'
local ClientObject		= require 'src.network.ClientObject'

local random			= math.random
local unpack			= unpack


-------------------------------------------------------------------------------
--  GenerateID : Generates a random string
-------------------------------------------------------------------------------
local IDCharSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ0123456789"
function GenerateID()
	local id = {}
	
	for b=1, 16 do
		id[#id+1] = IDCharSet:byte( random( IDCharSet:len() ) );
	end
	
	return string.char( unpack(id) ); 
end


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Server : A high level server representation
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Server = setmetatable({}, NetworkBase)
Server.__index = Server;


-------------------------------------------------------------------------------
--  Server:new : Creates a new server object
-------------------------------------------------------------------------------
function Server:new()
	local obj = NetworkBase.new( self )
	
	obj._sessions 	= {};
	
	return obj;
end


-------------------------------------------------------------------------------
--  Server:SendToClient : Sends a message to a client
-------------------------------------------------------------------------------
function Server:Poll()
	local data, ip, port = NetworkBase.Poll( self );
	local client = nil
	local msg = nil
	
	if data then 
		if data.session then
			
			client = self._sessions[data.session];
			
			if client then
				-- TODO: verify IP?
				
				msg = Message:new( data );
				msg:SetClient( client );
			end
			
		elseif data.type == Message.Type.LOGIN then
			local session = GenerateID();
			client = ClientObject:new( self, session, ip, port )
			
			self._sessions[session] = client;
			
			msg = {}
			msg.type = Message.Type.LOGIN;
			msg.session = session;
			
			self:SendToClient( client, msg );
			return self:Poll();
		end
	end
	
	return msg;
end


-------------------------------------------------------------------------------
--  Server:SendToClient : Sends a message to a client
-------------------------------------------------------------------------------
function Server:SendToClient( client, msg )
	return self:Send( msg, client._ip, client._port );
end


-------------------------------------------------------------------------------
--  Server:SendToAllClients : Sends a message to all clients
-------------------------------------------------------------------------------
function Server:SendToAllClients( msg )
	for id, client in pairs( self._clients ) do
		self:SendToClient( client, msg );
	end
end



--===========================================================================--
--  Initialization
--===========================================================================--
return Server