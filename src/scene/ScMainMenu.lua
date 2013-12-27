--===========================================================================--
--  Dependencies
--===========================================================================--
require 'src.lib.loveframes'
local SceneManager 		= require 'src.scene.SceneManager'



local MAIN_MENU_GUI_STATE 	= "MAIN_MENU"


-------------------------------------------------------------------------------
--  ChangeToSceneFB : An utility function that creates a change to scene func
-------------------------------------------------------------------------------
local function ChangeToSceneFB( scene )

	-- Note: this is the button.OnClick function signature
	return function(object, x, y)
		local sceneMgr = SceneManager:GetInstance();
		sceneMgr:SetScene( scene );
	end
	
end


-------------------------------------------------------------------------------
--  CreateGUI : Sets up the gui
-------------------------------------------------------------------------------
local function CreateGUI()
	local scrWidth	= love.graphics.getWidth();
	local scrHeight	= love.graphics.getHeight();
	
	local gui = {};
	
	-- Online game button
	gui.btnMultiplayer = loveframes.Create("button")
	gui.btnMultiplayer:SetText("Online Game")
	gui.btnMultiplayer:SetWidth( scrWidth/2, true )
	gui.btnMultiplayer:SetX( scrWidth/2, true )
	gui.btnMultiplayer:SetY( 3 * scrHeight/8, true )
	gui.btnMultiplayer:SetState( MAIN_MENU_GUI_STATE );
	
	-- Local game button
	gui.btnLocalGame = loveframes.Create("button")
	gui.btnLocalGame:SetText("Local Game")
	gui.btnLocalGame:SetWidth( scrWidth/2, true )
	gui.btnLocalGame:SetX( scrWidth/2, true )
	gui.btnLocalGame:SetY( 4 * scrHeight/8, true )
	gui.btnLocalGame:SetState( MAIN_MENU_GUI_STATE );
	
	-- Settings button
	gui.btnSettings = loveframes.Create("button")
	gui.btnSettings:SetText("Settings")
	gui.btnSettings:SetWidth( scrWidth/2, true )
	gui.btnSettings:SetX( scrWidth/2, true )
	gui.btnSettings:SetY( 5 * scrHeight/8, true )
	gui.btnSettings:SetState( MAIN_MENU_GUI_STATE );
	
	-- Quit button
	gui.btnQuit = loveframes.Create("button")
	gui.btnQuit:SetText("Quit")
	gui.btnQuit:SetWidth( scrWidth/2, true )
	gui.btnQuit:SetX( scrWidth/2, true )
	gui.btnQuit:SetY( 6 * scrHeight/8, true )
	gui.btnQuit:SetState( MAIN_MENU_GUI_STATE );
	
	
	-- GUI Behaviour
	gui.btnMultiplayer.OnClick = ChangeToSceneFB( "Battle" );
	gui.btnLocalGame.OnClick = ChangeToSceneFB( "Battle" );
	gui.btnSettings.OnClick = ChangeToSceneFB( "Selection" );
	gui.btnQuit.OnClick = function() love.event.push('quit') end;
	
	return gui;
end




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ScBattle : Battle scene 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ScMainMenu = {}
ScMainMenu.__index = ScMainMenu


-------------------------------------------------------------------------------
--  ScMainMenu:new : Creates a new main menu scene
-------------------------------------------------------------------------------
function ScMainMenu:new()
	local obj = {}

	obj.gui = CreateGUI();
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  ScMainMenu:Init : Initializes the main menu scene
-------------------------------------------------------------------------------
function ScMainMenu:Init()
	loveframes.SetState( MAIN_MENU_GUI_STATE )
end


-------------------------------------------------------------------------------
--  ScMainMenu:Leave : De-initializes the main menu scene
-------------------------------------------------------------------------------
function ScMainMenu:Leave()
	loveframes.SetState("none")
end


-------------------------------------------------------------------------------
--  ScMainMenu:Draw : Draws the main menu scene
-------------------------------------------------------------------------------
function ScMainMenu:Draw()
end


-------------------------------------------------------------------------------
--  ScMainMenu:Update : Updates the main menu scene
-------------------------------------------------------------------------------
function ScMainMenu:Update( dt )
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ScMainMenu;