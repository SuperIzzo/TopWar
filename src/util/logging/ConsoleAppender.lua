--===========================================================================--
--  Dependencies
--===========================================================================--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ConsoleAppender: a brief...
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ConsoleAppender = {}
ConsoleAppender.__index = ConsoleAppender;


-------------------------------------------------------------------------------
--  ConsoleAppender:new : Creates a new ConsoleAppender
-------------------------------------------------------------------------------
function ConsoleAppender:new()
	local obj = {}

	obj._level = "DEBUG";

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  ConsoleAppender:SetReportLevel : Sets the report level
-------------------------------------------------------------------------------
function ConsoleAppender:SetReportLevel( level )
	self._level = level;
end


-------------------------------------------------------------------------------
--  ConsoleAppender:GetReportLevel : Returns the report level
-------------------------------------------------------------------------------
function ConsoleAppender:GetReportLevel()
	return self._level;
end


-------------------------------------------------------------------------------
--  ConsoleAppender:Append : Appends a new message
-------------------------------------------------------------------------------
function ConsoleAppender:Append( logger, level, msg )
	local date = os.date("%H:%M:%S" );
	local line = 	"[" .. date .. "] " .. level .. ": " ..
					msg .. " .:[" .. logger:GetName() .."]:.";
	print( line );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ConsoleAppender
