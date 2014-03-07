--===========================================================================--
--  Dependencies
--===========================================================================--
local SceneManager			= require 'src.scene.SceneManager';
local Client 				= require 'src.network.Client'
local NetUtils 				= require 'src.network.NetworkUtils'
local ControlBox 			= require 'src.input.ControlBox'
local Settings				= require 'src.settings.Settings'
local Player				= require 'src.model.Player'
local DBDyzx				= require 'src.model.DBDyzx'



---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Game: A central class for he game
---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Game = {}
Game.__index = Game;


-------------------------------------------------------------------------------
--  Game Constants
-------------------------------------------------------------------------------
Game.MAX_NUM_PLAYERS = 8;


-------------------------------------------------------------------------------
--  Game:new : Creates a new Game
-------------------------------------------------------------------------------
local function Game_new()
	local obj = {}
	
	obj._players 		= {}
	obj._database		= DBDyzx:new();
	obj._eventHandlers 	= {}
	obj._mouseX			= 0; 
	obj._mouseY			= 0;

	return setmetatable(obj, Game);
end


-------------------------------------------------------------------------------
--  Game:new : Creates a new Game
-------------------------------------------------------------------------------
function Game:GetInstance()
	self._instance = self._instance or Game_new();
	return self._instance;
end


-------------------------------------------------------------------------------
--  Game:Run : The game loop (essentially a modified love.run)
-------------------------------------------------------------------------------
function Game:Run( arg )
	
	-- Randomise the the pseudorandom number generators
	if love.math then
		love.math.setRandomSeed(os.time())
    end
	
	if love.event then
        love.event.pump()
    end

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
                    running = self:Quit();
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
	self:InitSelf();
	self:InitDatabase();
	self:InitPlayers();
	self:InitControls();
	self:InitGraphics();
	self:InitScenes();
end


-------------------------------------------------------------------------------
--  Game:InitSelf : Initialise internal general game related stuff
-------------------------------------------------------------------------------
function Game:InitSelf()
	-- Initialise event handlers
	self._eventHandlers[ "keypressed" ]			= self.KeyPressed;
	self._eventHandlers[ "keyreleased" ]		= self.KeyReleased;
	self._eventHandlers[ "mousepressed" ]		= self.MousePressed;
	self._eventHandlers[ "mousereleased" ]		= self.MouseReleased;
	self._eventHandlers[ "joystickpressed" ]	= self.JoystickPressed;
	self._eventHandlers[ "joystickreleased" ]	= self.JoystickReleased;
	self._eventHandlers[ "joystickhat" ]		= self.JoystickHat;
	self._eventHandlers[ "joystickaxis" ]		= self.JoystickAxis;
end


-------------------------------------------------------------------------------
--  Game:InitDatabase : Initialises the database
-------------------------------------------------------------------------------
function Game:InitDatabase()
	self._database:SetFilePath( love.filesystem.getSaveDirectory() .. "/" );
	self._database:Load();
end


-------------------------------------------------------------------------------
--  Game:InitPlayers : Initialises the players
-------------------------------------------------------------------------------
function Game:InitPlayers()
	for i = 1, self.MAX_NUM_PLAYERS do
		self._players[i] = Player:new();
	end
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
--  Game:ShutDown : Deinitialise the game
-------------------------------------------------------------------------------
function Game:ShutDown()
	-- shutdown the audio
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
--  Game:Quit : Handle game quit events
-------------------------------------------------------------------------------
function Game:Quit()
	local abort = false;
	
	return abort;
end


-------------------------------------------------------------------------------
--  Game:Keypressed : Receives keypressed events
-------------------------------------------------------------------------------
function Game:KeyPressed( key, unicode )	
	self.p1Box:Trigger( "Key", key, true );
	self.p2Box:Trigger( "Key", key, true );
	
	if key == "escape" then
		love.event.push( "quit" );
	end
end


-------------------------------------------------------------------------------
--  Game:Keyreleased : Receives keyreleased events
-------------------------------------------------------------------------------
function Game:KeyReleased( key, unicode )
	self.p1Box:Trigger( "Key", key, false );
	self.p2Box:Trigger( "Key", key, false );
end


-------------------------------------------------------------------------------
--  Game:MousePressed : Receives mousepressed events
-------------------------------------------------------------------------------
function Game:MousePressed( x, y, button )
	self.p1Box:Trigger( "MouseBtn", button, true );
	self.p2Box:Trigger( "MouseBtn", button, true );
end


-------------------------------------------------------------------------------
--  Game:MouseReleased : Receives mousereleased events
-------------------------------------------------------------------------------
function Game:MouseReleased( x, y, button )
	self.p1Box:Trigger( "MouseBtn", button, false );
	self.p2Box:Trigger( "MouseBtn", button, false );
end


-------------------------------------------------------------------------------
--  Game:JoystickPressed : Receives joypressed events
-------------------------------------------------------------------------------
function Game:JoystickPressed( joystick, button )
	self.p1Box:Trigger( "Joy" .. joystick:getID() .. "Button", button, true );
	self.p2Box:Trigger( "Joy" .. joystick:getID() .. "Button", button, true );
end


-------------------------------------------------------------------------------
--  Game:JoystickPressed : Receives joystickreleased events
-------------------------------------------------------------------------------
function Game:JoystickReleased( joystick, button )
	self.p1Box:Trigger( "Joy" .. joystick:getID() .. "Button", button, false );
	self.p2Box:Trigger( "Joy" .. joystick:getID() .. "Button", button, false );
end


-------------------------------------------------------------------------------
--  Game:JoystickPressed : Receives joystickhat events
-------------------------------------------------------------------------------
function Game:JoystickHat( joystick, hat, direction )
	local joystickID = joystick:getID();
	
	self._prevHatDir = self._prevHatDir or {}
	local prevDir = self._prevHatDir[joystickID];
	
	if prevDir then
		self.p1Box:Trigger( "Joy" .. joystickID .. "Hat", prevDir, false );
		self.p2Box:Trigger( "Joy" .. joystickID .. "Hat", prevDir, false );
	end
	
	self.p1Box:Trigger( "Joy" .. joystickID .. "Hat", direction, true );
	self.p2Box:Trigger( "Joy" .. joystickID .. "Hat", direction, true );	
	self._prevHatDir[joystickID] = direction;
end


-------------------------------------------------------------------------------
--  Game:JoystickAxis : Receives joystickaxis events
-------------------------------------------------------------------------------
function Game:JoystickAxis( joystick, axis, value )
	self.p1Box:Trigger( "Joy" .. joystick:getID() .. "Axis", axis, value );
	self.p2Box:Trigger( "Joy" .. joystick:getID() .. "Axis", axis, value );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Game