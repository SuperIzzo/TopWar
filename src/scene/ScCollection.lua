--===========================================================================--
--  Dependencies
--===========================================================================--
local GUI				= require 'src.gui.GUI'
local Panel				= require 'src.gui.Panel'
local BlueIceSkin		= require 'src.gui.BlueIceSkin'


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
	
	obj._panel = Panel:new();
	obj._panel:SetPosition( 0.1, 0.1 ) 
	obj._panel:SetSize( 0.8, 0.8 )
	
	--love.graphics.rectangle( "fill", 0.2*w, 0.1*h, 0.6*w, 0.2*h );
	
	obj._skin = BlueIceSkin:new();
	obj._skin:Load();
	
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
	--love.graphics.setColor( 108, 181, 177 );
	
	--local w = love.graphics.getWidth();
	--local h = love.graphics.getHeight();
	
	self._skin:DrawPanel( self._panel );
	
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