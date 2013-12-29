--===========================================================================--
--  Dependencies
--===========================================================================--
local passTable 	= require 'data.server.passwords'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Authenticator : Authentication service
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Authenticator = {}
Authenticator.__index = Authenticator


-------------------------------------------------------------------------------
--  Authenticator:new : Creates a new authenticator
-------------------------------------------------------------------------------
function Authenticator:new()
	local obj = {}
	
	obj.passwords = passTable;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Authenticator:new : Creates a new authenticator
-------------------------------------------------------------------------------
function Authenticator:Authenticate( userName, pass )
	return 	type(userName)=="string" and 
			type(pass) == "string" and 
			self.passwords[userName] == pass;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Authenticator;