--===========================================================================--
--  Dependencies
--===========================================================================--
local System				= require 'src.System'
local SceneManager			= require 'src.scene.SceneManager';
local Client 				= require 'src.network.Client'
local NetUtils 				= require 'src.network.NetworkUtils'
local ControlBox 			= require 'src.input.ControlBox'
local Settings				= require 'src.settings.Settings'
local Player				= require 'src.model.Player'
local DBDyzx				= require 'src.model.DBDyzx'



---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Game: A central class for the game
---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Game = {}
Game.__index = Game;


-------------------------------------------------------------------------------
--  Game:new : Creates a new Game
-------------------------------------------------------------------------------
local function Game_new(self)
	local obj = {}
	
	obj._players 		= {}
	obj._database		= DBDyzx:new();
	obj._eventHandlers 	= {}
	obj._mouseX			= 0; 
	obj._mouseY			= 0;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Game:GetInstance : Returns the instance of the running game
-------------------------------------------------------------------------------
function Game:GetInstance()
	self._instance = self._instance or Game_new(self);
	return self._instance;
end


-------------------------------------------------------------------------------
--  Game:Run : The game loop (essentially a modified love.run)
-------------------------------------------------------------------------------
function Game:Run( arg )
	
	if love.math then
		-- Randomise the the pseudorandom number generators
		love.math.setRandomSeed(os.time())
		
		-- Replace the standard 'random' with the love one
		math.random = love.math.random
    end
	
	if love.event then
        love.event.pump()
    end

	-- Initialize ourself
    self:Init()
	
    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0
	local running = true;
	
    -- Main loop time.
    while running do
        -- Process events.
        if love.event then
            love.event.pump()
            for event ,arg1, arg2, arg3, arg4 in love.event.poll() do
                if event == "quit" then
                    running = self:OnQuit( arg1, arg2, arg3, arg4 );
				else
					local handler = self._eventHandlers[event];
					
					if handler then
						handler(self, arg1, arg2, arg3, arg4);
					end
				end
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        -- Call update and draw
        self:Update(dt) -- will pass 0 if love.timer is disabled

        if love.window and love.graphics and love.window.isCreated() then
            love.graphics.clear()
            love.graphics.origin()
            
			self:Draw()
			
            love.graphics.present()
        end

        if love.timer then 
			love.timer.sleep(0.001)
		end		
    end
	
	self:ShutDown();
end


-------------------------------------------------------------------------------
--  Game:GetDyzkDatabase : Returns the dyzk database
-------------------------------------------------------------------------------
function Game:GetDyzkDatabase()
	return self._database;
end


-------------------------------------------------------------------------------
--  Game:Init : Initialises the game
-------------------------------------------------------------------------------
function Game:Init()
	System.Log( "Initialising game" );
	
	self:InitSelf();
	self:InitDatabase();
	self:InitControls();
	self:InitGraphics();
	self:InitScenes();
end


-------------------------------------------------------------------------------
--  Game:InitSelf : Initialise internal general game related stuff
-------------------------------------------------------------------------------
function Game:InitSelf()
	-- Initialise event handlers
	self._eventHandlers[ "keypressed" ]			= self.OnKeyPressed;
	self._eventHandlers[ "keyreleased" ]		= self.OnKeyReleased;
	self._eventHandlers[ "mousepressed" ]		= self.OnMousePressed;
	self._eventHandlers[ "mousereleased" ]		= self.OnMouseReleased;
	self._eventHandlers[ "joystickpressed" ]	= self.OnJoystickPressed;
	self._eventHandlers[ "joystickreleased" ]	= self.OnJoystickReleased;
	self._eventHandlers[ "joystickhat" ]		= self.OnJoystickHat;
	self._eventHandlers[ "joystickaxis" ]		= self.OnJoystickAxis;
end


-------------------------------------------------------------------------------
--  Game:InitDatabase : Initialises the database
-------------------------------------------------------------------------------
function Game:InitDatabase()
	self._database:SetFilePath( love.filesystem.getSaveDirectory() .. "/" );
	self._database:Load();
end


-------------------------------------------------------------------------------
--  Game:InitControls : Initialises the controls
-------------------------------------------------------------------------------
function Game:InitControls()
	local p1Box = ControlBox:new();
	p1Box.player = 1;
	Settings:LoadDefaultControls( p1Box );

	local p2Box = ControlBox:new();
	p2Box.player = 2;
	Settings:LoadDefaultControls( p2Box );


	-- Control Box Feedback
	local function sceneControl( box, control )
		local sceneMgr = SceneManager:GetInstance();
		
		-- Send controls to the scene managers, it will delegate to the active scenes
		-- (they will delagate to objects)
		sceneMgr:Control( control );
		
		-- Return the control back to the box (so that it can trigger other controls)
		box:Trigger( "Control", control:GetID(), control:GetValue() );
	end

	p1Box:SetCallback( sceneControl )
	p2Box:SetCallback( sceneControl )
	
	
	self.p1Box = p1Box;
	self.p2Box = p2Box;
end


-------------------------------------------------------------------------------
--  Game:InitGraphics : Initialises the windows and the graphics
-------------------------------------------------------------------------------
function Game:InitGraphics()
	local windowFlags = {}
	
	windowFlags.resizable = true;
	--windowFlags.fullscreen = true;
	
	--love.window.setMode( 800, 600, windowFlags );
end


-------------------------------------------------------------------------------
--  Game:InitScenes : Initialises the scenes
-------------------------------------------------------------------------------
function Game:InitScenes()	
	local sceneMgr = SceneManager:GetInstance();

	local ScMainMenu 		= require("src.scene.ScMainMenu");
	local ScBattle 			= require("src.scene.ScBattle");
	local ScCollection	 	= require("src.scene.ScCollection");

	sceneMgr:AddScene( "Main Menu"		, ScMainMenu:new()			);
	sceneMgr:AddScene( "Battle"			, ScBattle:new()			);
	sceneMgr:AddScene( "Collection"		, ScCollection:new()		);

	sceneMgr:SetScene( "Main Menu" );
end


-------------------------------------------------------------------------------
--  Game:ShutDown : De-initialise the game
-------------------------------------------------------------------------------
function Game:ShutDown()
	System.Log( "Shutting down game" );
	
	-- Stop any playing sounds before we quit
	if love.audio then
		love.audio.stop()
	end
end


-------------------------------------------------------------------------------
--  Game:UpdateMouse : Updates the mouse
-------------------------------------------------------------------------------
function Game:UpdateMouse()
	local mouseX, mouseY = love.mouse.getPosition();
	
	if self._mouseX ~= mouseX then
		self._mouseX = mouseX;
		self.p1Box:Trigger( "MousePos", 'x', mouseX );
		self.p2Box:Trigger( "MousePos", 'x', mouseX );
	end
	
	if self._mouseY ~= mouseY then
		self._mouseY = mouseY;
		self.p1Box:Trigger( "MousePos", 'y', mouseY );
		self.p2Box:Trigger( "MousePos", 'y', mouseY );
	end	
end


-------------------------------------------------------------------------------
--  Game:Update : Updates the game
-------------------------------------------------------------------------------
function Game:Update( dt )
	local sceneMgr = SceneManager:GetInstance();

	self:UpdateMouse();
	sceneMgr:Update(dt);
	
	self.p1Box:Trigger( "Update", 1 );
	self.p2Box:Trigger( "Update", 1 );
end


-------------------------------------------------------------------------------
--  Game:Draw : Draws the game
-------------------------------------------------------------------------------
function Game:Draw()
	local sceneMgr = SceneManager:GetInstance();
	sceneMgr:Draw();
	
	love.graphics.setColor(255,0,0);
	local y = love.graphics.getHeight() - 20;
	love.graphics.print( "FPS: " .. love.timer.getFPS(), 0, y );
	love.graphics.setColor(255,255,255);
end


-------------------------------------------------------------------------------
--  Game:OnQuit : Handle game quit events
-------------------------------------------------------------------------------
function Game:OnQuit()
	local abort = false;
	
	-- Insert quit handling here
	
	return abort;
end


-------------------------------------------------------------------------------
--  Game:OnKeyPressed : Receives key pressed events
-------------------------------------------------------------------------------
function Game:OnKeyPressed( key, rep )	
	self.p1Box:Trigger( "Key", key, true );
	self.p2Box:Trigger( "Key", key, true );
	
	-- Quit in ESC
	-- TODO: This is inappropriate, 
	--		 it has been added only so that android can quit
	if key == "escape" then
		love.event.push( "quit" );
	end
end


-------------------------------------------------------------------------------
--  Game:OnKeyreleased : Receives key released events
-------------------------------------------------------------------------------
function Game:OnKeyReleased( key, rep )
	self.p1Box:Trigger( "Key", key, false );
	self.p2Box:Trigger( "Key", key, false );
end


-------------------------------------------------------------------------------
--  Game:OnMousePressed : Receives mouse pressed events
-------------------------------------------------------------------------------
function Game:OnMousePressed( x, y, button )
	self.p1Box:Trigger( "MouseBtn", button, true );
	self.p2Box:Trigger( "MouseBtn", button, true );
end


-------------------------------------------------------------------------------
--  Game:OnMouseReleased : Receives mouse released events
-------------------------------------------------------------------------------
function Game:OnMouseReleased( x, y, button )
	self.p1Box:Trigger( "MouseBtn", button, false );
	self.p2Box:Trigger( "MouseBtn", button, false );
end


-------------------------------------------------------------------------------
--  Game:OnJoystickPressed : Receives joystick button pressed events
-------------------------------------------------------------------------------
function Game:OnJoystickPressed( joystick, button )
	self.p1Box:Trigger( "Joy" .. joystick:getID() .. "Button", button, true );
	self.p2Box:Trigger( "Joy" .. joystick:getID() .. "Button", button, true );
end


-------------------------------------------------------------------------------
--  Game:OnJoystickReleased : Receives joystick button released events
-------------------------------------------------------------------------------
function Game:OnJoystickReleased( joystick, button )
	self.p1Box:Trigger( "Joy" .. joystick:getID() .. "Button", button, false );
	self.p2Box:Trigger( "Joy" .. joystick:getID() .. "Button", button, false );
end


-------------------------------------------------------------------------------
--  Game:OnJoystickHat : Receives joystick hat events
-------------------------------------------------------------------------------
function Game:OnJoystickHat( joystick, hat, direction )
	local joystickID = joystick:getID();
	
	-- Get the previous position of the hat
	-- TODO: Not a biggie but this will not be correct when hot-plugging
	self._prevHatDir = self._prevHatDir or {}
	local prevDir = self._prevHatDir[joystickID];
	
	-- Release the previous hat direction
	if prevDir then
		self.p1Box:Trigger( "Joy" .. joystickID .. "Hat", prevDir, false );
		self.p2Box:Trigger( "Joy" .. joystickID .. "Hat", prevDir, false );
	end
	
	-- And issue the new hat press
	self.p1Box:Trigger( "Joy" .. joystickID .. "Hat", direction, true );
	self.p2Box:Trigger( "Joy" .. joystickID .. "Hat", direction, true );
	
	-- Update our cache
	self._prevHatDir[joystickID] = direction;
end


-------------------------------------------------------------------------------
--  Game:OnJoystickAxis : Receives joystickaxis events
-------------------------------------------------------------------------------
function Game:OnJoystickAxis( joystick, axis, value )
	self.p1Box:Trigger( "Joy" .. joystick:getID() .. "Axis", axis, value );
	self.p2Box:Trigger( "Joy" .. joystick:getID() .. "Axis", axis, value );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Game