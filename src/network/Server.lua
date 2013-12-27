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
	
	if data and ip and port then
		-- Create a message and decipher the raw data
		msg = Message:new( data );
	
		-- Make a session ID
		local sessionID = "SESION:" .. ip;
		client = self._sessions[sessionID];
		
		-- Register the client (if necessary)
		if not client then
			client = ClientObject:new( self, ip, port );
			self._sessions[sessionID] = client;
		end
		
		-- Add the client object to the message
		msg:SetClient( client );
	end
	
	-- Peek the message before sending
	self:Peek(msg);
	
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


-------------------------------------------------------------------------------
--  Server:HandleMsg_HANDSHAKE : Handles handshakes
-------------------------------------------------------------------------------
Server[ "HandleMsg_" .. Message.Type.HANDSHAKE ] = function(self, msg)
	local client = msg:GetClient();

	-- Prepare a response message
	local response = {}
	response.type = Message.Type.HANDSHAKE;
	
	-- Send the message
	return self:SendToClient( client, response );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Server