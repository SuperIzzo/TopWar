--===========================================================================--
--  Dependencies
--===========================================================================--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Logger: a brief...
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Logger = {}
Logger.__index = Logger;


Logger.LogLevels =
{
	DEBUG	= 1;
	INFO	= 2;
	WARNING	= 3;
	ERROR	= 4;
	FATAL	= 5;
}


-------------------------------------------------------------------------------
--  Logger:new : Creates a new Logger
-------------------------------------------------------------------------------
local function Logger_new( self, name )
	local obj = {}

	-- Keep track of all loggers
	self._loggers = self._loggers or {};
	self._loggers[ name ] = obj;

	-- Class defaults
	self._hasAppenders	= true;
	self._appenders		= self._appenders	or {}
	self._minLevel		= self._minLevel	or "DEBUG"
	self._name			= self._name 		or "Default Log"

	-- This has to be defined so that we know who owns the table
	obj._hasAppenders	= false;
	obj._name			= name;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Logger:GetLogger : Retrieves or creates a named logger
-------------------------------------------------------------------------------
function Logger:GetLogger( name )
	local name = name or "Default Log";
	
	-- Try to retrieve an existing log
	local logger = self._loggers and self._loggers[ name ];
	
	-- If failing... create a new one
	logger = logger or Logger_new( self, name );
	
	return logger;
end


-------------------------------------------------------------------------------
--  Logger:GetName : Returns the name of the logger
-------------------------------------------------------------------------------
function Logger:GetName()
	return self._name;
end


-------------------------------------------------------------------------------
--  Logger:AddAppender : Adds an appender
-------------------------------------------------------------------------------
function Logger:AddAppender( appender )
	if not self._hasAppenders then
		self._appenders = {}
		self._hasAppenders = true;
	end

	self._appenders[ #self._appenders+1 ] = appender;
end


-------------------------------------------------------------------------------
--  Logger:SetReportLevel : Sets the minimal report level
-------------------------------------------------------------------------------
function Logger:SetReportLevel( level )
	self._minLevel = level;
end


-------------------------------------------------------------------------------
--  Logger:Log : Logs a message
-------------------------------------------------------------------------------
function Logger:Log( msg, lvl )
	local lvl = lvl or "INFO";

	local lvlIdx	= self.LogLevels[ lvl ] or 0;
	local minLvlIdx	= self.LogLevels[ self._minLevel ] or 0;

	-- Skip if the report level is higher than the log level
	if lvlIdx < minLvlIdx then
		return;
	end

	-- Else proceed to the appenders
	for i = 1, #self._appenders do
		local appender = self._appenders[i];
		local appenderMinLvl = appender:GetReportLevel();
		local minLvlIdx	= self.LogLevels[ appenderMinLvl ] or 0;

		-- Only report logs at higher level than appender's min
		if lvlIdx >= minLvlIdx then
			appender:Append( self, lvl, msg );
		end
	end
end


-------------------------------------------------------------------------------
--  Logger:LogDebug : Logs a debug message
-------------------------------------------------------------------------------
function Logger:LogDebug( msg )
	return self:Log( msg, "DEBUG" );
end


-------------------------------------------------------------------------------
--  Logger:LogInfo : Logs an info message
-------------------------------------------------------------------------------
function Logger:LogInfo( msg )
	return self:Log( msg, "INFO" );
end


-------------------------------------------------------------------------------
--  Logger:LogWarning : Logs a warning message
-------------------------------------------------------------------------------
function Logger:LogWarning( msg )
	return self:Log( msg, "WARNING" );
end


-------------------------------------------------------------------------------
--  Logger:LogError : Logs an error message
-------------------------------------------------------------------------------
function Logger:LogError( msg )
	return self:Log( msg, "ERROR" );
end


-------------------------------------------------------------------------------
--  Logger:LogFatal : Logs a fatal error message
-------------------------------------------------------------------------------
function Logger:LogFatal( msg )
	return self:Log( msg, "FATAL" );
end


-------------------------------------------------------------------------------
--  Logger:_Separate : Splits the name into parts
-------------------------------------------------------------------------------
function Logger:_Splits( str )
	local parts = {}

	for part in string.gfind( str ..".", "(.-)%." ) do
		parts[#parts+1] = part;
	end

	return parts;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return Logger
