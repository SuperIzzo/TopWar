--===========================================================================--
--  Dependencies
--===========================================================================--
local Logger			= require 'src.util.logging.Logger'
local ConsoleAppender	= require 'src.util.logging.ConsoleAppender'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class System: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local System = {}


-------------------------------------------------------------------------------
--  System_Init : initializes the system
-------------------------------------------------------------------------------
local function System_Init()
	-- Get the default logger
	System.Logger = Logger:GetLogger("System");
	
	-- Set up the log output (console)
	local consoleAppender = ConsoleAppender:new()
	System.Logger:AddAppender( consoleAppender );
end


-------------------------------------------------------------------------------
--  System.Log : Creates a new Debug
-------------------------------------------------------------------------------
function System.Log( msg, lvl )
	System.Logger:Log( msg, lvl );
end


-------------------------------------------------------------------------------
--  System.Error : Causes an error
-------------------------------------------------------------------------------
function System.Error( msg, layer )	
	local layer = (layer or 1) + 1; 
	
	System.Logger:LogError( msg );
	error( msg, layer );
end


-------------------------------------------------------------------------------
--  System.Assert : Asserts a statement
-------------------------------------------------------------------------------
function System.Assert( test, msg, layer )	
	if not test then
		local stringMsg	= "";
		local layer		= (layer or 1) + 1;
		
		if type(msg) ~= "nil" then
			stringMsg = ": " .. tostring( msg );
		end
		
		self:Error( "Assertion failed" .. stringMsg, layer);
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
System_Init();

return System