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
--  Message.Type : message type enumeratoin
-------------------------------------------------------------------------------
Message.Type = 
{
	LOGIN = "login",
	ACCEPT = "accept"
}


-------------------------------------------------------------------------------
--  Message:newLoginMessage : Creates a new Login message
-------------------------------------------------------------------------------
function Message:newLoginMessage( id )
	local obj = {}
	
	obj.type 	= self.Type.LOGIN;
	obj.id 		= id;

	return obj;
end


-------------------------------------------------------------------------------
--  Message:newAcceptMessage : Creates a new Accept message
-------------------------------------------------------------------------------
function Message:newAcceptMessage()
	local obj = {}
	
	obj.type = self.Type.ACCEPT;

	return obj;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return Message