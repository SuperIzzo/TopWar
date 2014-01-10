--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Constants
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ListenersMetaTable = { __mode = "k" }


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Announcer: An auxilary class to manage listers
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Announcer = {}
Announcer.__index = Announcer;


-------------------------------------------------------------------------------
--  Announcer:new : Creates a new Announcer
-------------------------------------------------------------------------------
function Announcer:new()
	local obj = {}
	
	obj.listeners = {}
	setmetatable( obj.listeners, ListenersMetaTable );

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Announcer:new : Creates a new Announcer
-------------------------------------------------------------------------------
function Announcer:AddListener( obj, func )
	self.listeners[ obj ] = func;
end


-------------------------------------------------------------------------------
--  Announcer:RemoveListener : Removes a listener
-------------------------------------------------------------------------------
function Announcer:RemoveListener( obj )
	self.listeners[ obj ] = nil;
end


-------------------------------------------------------------------------------
--  Announcer:Announce : Announces an event to all listeners
-------------------------------------------------------------------------------
function Announcer:Announce( ... )
	for obj, func in pairs(self.listeners) do
		if obj and func then
			func( obj, ... );
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Announcer