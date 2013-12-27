--===========================================================================--
--  Dependencies
--===========================================================================--
-- Modules

-- Aliases
local setmetatable 		= setmetatable



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Message: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Message = {}
Message.__index = Message;


-------------------------------------------------------------------------------
--  Enum Message.Type : message type enumeration
-------------------------------------------------------------------------------
Message.Type = 
{
	HANDSHAKE 	= "HANDSHAKE",
	
	LOBBY_INFO	= "LOBBY_INFO",
	LOBBY_ENTER	= "LOBBY_ENTER",
	
	DYZK_DESC	= "DYZK_DESC",
}


-------------------------------------------------------------------------------
--  Message:new : Creates a new message
-------------------------------------------------------------------------------
function Message:new( data )
	local obj = data or {}
	return setmetatable( data, self );
end


-------------------------------------------------------------------------------
--  Message:GetClient : Returns the client
-------------------------------------------------------------------------------
function Message:GetClient()
	return self._client;
end


-------------------------------------------------------------------------------
--  Message:SetClient : Sets the client
-------------------------------------------------------------------------------
function Message:SetClient( client)
	self._client = client;
end


-------------------------------------------------------------------------------
--  Message:GetType : Returns the message type
-------------------------------------------------------------------------------
function Message:GetType()
	return self.type;
end


-------------------------------------------------------------------------------
--  Message:SetClient : Sets the type of the message
-------------------------------------------------------------------------------
function Message:SetType( type )
	self.type = type ;
end


--===========================================================================--
--  Initialization
--===========================================================================--
setmetatable( 
	Message.Type, 
	{ 
		__index = function (tab, key)
			error( "Enum does not contain key '" .. key .. "'" );
		end
	}
);

return Message