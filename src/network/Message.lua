--===========================================================================--
--  Dependencies
--===========================================================================--
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
	AUTH		= "AUTH",	
	
	DYZK_DESC	= "DYZK_DESC",
	
	-- Subtypes --
	ACTION		= "sACTION",
	INFO		= "sINFO",
}


-------------------------------------------------------------------------------
--  Message:new : Creates a new message
-------------------------------------------------------------------------------
function Message:new( data )
	local obj = data or {}
	return setmetatable( obj, self );
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
function Message:SetClient( client )
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


-------------------------------------------------------------------------------
--  Message:GetSubtype : Returns the message sub-type
-------------------------------------------------------------------------------
function Message:GetType()
	return self.stype;
end


-------------------------------------------------------------------------------
--  Message:SetSubtype : Sets the subtype of the message
-------------------------------------------------------------------------------
function Message:SetSubtype( stype )
	self.stype = stype ;
end


-------------------------------------------------------------------------------
--  Message:GetSubtype : Sets the sub-type of the message
-------------------------------------------------------------------------------
function Message:GetSubtype()
	return self.stype;
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