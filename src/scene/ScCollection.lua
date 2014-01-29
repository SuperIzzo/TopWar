--===========================================================================--
--  Dependencies
--===========================================================================--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ScCollection : The main menu scene
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ScCollection = {}
ScCollection.__index = ScCollection


-------------------------------------------------------------------------------
--  ScCollection:new : Creates a new main menu scene
-------------------------------------------------------------------------------
function ScCollection:new()
	local obj = {}	
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  ScCollection:Init : Initializes the main menu scene
-------------------------------------------------------------------------------
function ScCollection:Init()
end



-------------------------------------------------------------------------------
--  ScCollection:Leave : Deinitialises the main menu scene
-------------------------------------------------------------------------------
function ScCollection:Leave()
end


-------------------------------------------------------------------------------
--  ScCollection:Draw : Draws the main menu scene
-------------------------------------------------------------------------------
function ScCollection:Draw()
	love.graphics.setColor( 108, 181, 177 );
	
	local w = love.graphics.getWidth();
	local h = love.graphics.getHeight();
	
	love.graphics.rectangle( "fill", 0.2*w, 0.1*h, 0.6*w, 0.2*h );
end


-------------------------------------------------------------------------------
--  ScCollection:Update : Updates the main menu scene
-------------------------------------------------------------------------------
function ScCollection:Update( dt )
end


-------------------------------------------------------------------------------
--  ScCollection:Control : React to input controls
-------------------------------------------------------------------------------
function ScCollection:Control( control )
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ScCollection;