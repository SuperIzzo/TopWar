--===========================================================================--
--  Dependencies
--===========================================================================--
local SceneManager			= require 'src.scene.SceneManager';
local Client 				= require 'src.network.Client'
local NetUtils 				= require 'src.network.NetworkUtils'
local ControlBox 			= require 'src.input.ControlBox'
local Trigger	 			= require 'src.input.TriggerType'
local Settings				= require 'src.settings.Settings'
local Player				= require 'src.model.Player'




--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Game: A central class for he game
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
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
	
	obj._players = {}

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
--  Game:Init : Initialises the game
-------------------------------------------------------------------------------
function Game:Init()
	self:InitPlayers();
	self:InitControls()
	self:InitScenes()
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
		sceneMgr:Control
		{
			player	= box.player,
			id		= control:GetID(),
			value	= control:GetValue()
		}
		
		-- Return the control back to the box (so that it can trigger other controls)
		box:Trigger( "Control", control:GetID(), control:GetValue() );
	end

	p1Box:SetCallback( sceneControl )
	p2Box:SetCallback( sceneControl )
	
	
	self.p1Box = p1Box;
	self.p2Box = p2Box;
end


-------------------------------------------------------------------------------
--  Game:InitScenes : Initialises the scenes
-------------------------------------------------------------------------------
function Game:InitScenes()	
	local sceneMgr = SceneManager:GetInstance();


	local ScMainMenu 		= require("src.scene.ScMainMenu");
	local ScBattle 			= require("src.scene.ScBattle");
	local ScBattleSetup 	= require("src.scene.ScBattleSetup");
	local ScSelection 		= require("src.scene.ScSelection");
	local ScPlayerSetup 	= require("src.scene.ScPlayerSetup");

	sceneMgr:AddScene( "Main Menu"		, ScMainMenu:new()			);
	sceneMgr:AddScene( "Battle"			, ScBattle:new()			);
	sceneMgr:AddScene( "BattleSetup"	, ScBattleSetup:new()		);
	sceneMgr:AddScene( "Selection"		, ScSelection:new()			);
	sceneMgr:AddScene( "Players"		, ScPlayerSetup:new()		);

	sceneMgr:SetScene( "Main Menu" );
end


-------------------------------------------------------------------------------
--  Game:Update : Updates the game
-------------------------------------------------------------------------------
local prevHat = {}
function Game:Update( dt )
	local sceneMgr = SceneManager:GetInstance();
	local client = Client:GetInstance();
	
	---------------------
	for msg in client:Messages() do
		--client:Peek( msg );		
		
		for k,v in pairs(msg) do
			print(" >".. tostring(k) .. " = " .. tostring(v));
		end
		
		sceneMgr:Network( msg );
	end
	--------------------------	


	sceneMgr:Update(dt);
	
	self.p1Box:Trigger( "Update", 1 );
	self.p2Box:Trigger( "Update", 1 );

	for joy = 1, love.joystick.getJoystickCount() do		
		local joystick = love.joystick.getJoysticks()[joy];
		
		if joystick then
		
			for axis=1, joystick:getAxisCount() do
				self.p1Box:Trigger( "Joy" .. joy .. "Axis", axis, joystick:getAxis( axis ) );
				self.p2Box:Trigger( "Joy" .. joy .. "Axis", axis, joystick:getAxis( axis ) );
			end
		
			for i=1, joystick:getHatCount() do
				local hat = joystick:getHat( i );
			
				if prevHat[i] ~= hat then 
					if prevHat[i] then
						self.p1Box:Trigger( "Joy" .. joy .. "Hat", prevHat[i] .. i , false );
						self.p2Box:Trigger( "Joy" .. joy .. "Hat", prevHat[i] .. i , false );
					end
				
					prevHat[i] = hat;
					self.p1Box:Trigger( "Joy" .. joy .. "Hat", hat .. i, true );
					self.p2Box:Trigger( "Joy" .. joy .. "Hat", hat .. i, true );
				end
			end
		end
	end
end


-------------------------------------------------------------------------------
--  Game:Draw : Draws the game
-------------------------------------------------------------------------------
function Game:Draw()
	local sceneMgr = SceneManager:GetInstance();
	sceneMgr:Draw();
end


-------------------------------------------------------------------------------
--  Game:Keypressed : Receives keypressed events
-------------------------------------------------------------------------------
function Game:KeyPressed( key, unicode )	
	self.p1Box:Trigger( "Key", key, true );
	self.p2Box:Trigger( "Key", key, true );
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
	
end


-------------------------------------------------------------------------------
--  Game:MouseReleased : Receives mousereleased events
-------------------------------------------------------------------------------
function Game:MouseReleased( x, y, button )
	
end


-------------------------------------------------------------------------------
--  Game:JoystickPressed : Receives joypressed events
-------------------------------------------------------------------------------
function Game:JoystickPressed( joystick, button )
	self.p1Box:Trigger( "Joy" .. j:getID() .. "Button", but, true );
	self.p2Box:Trigger( "Joy" .. j:getID() .. "Button", but, true );
end


-------------------------------------------------------------------------------
--  Game:JoystickPressed : Receives joystickreleased events
-------------------------------------------------------------------------------
function Game:JoystickReleased( joystick, button )
	self.p1Box:Trigger( "Joy" .. j:getID() .. "Button", but, false );
	self.p2Box:Trigger( "Joy" .. j:getID() .. "Button", but, false );
end





--===========================================================================--
--  Initialization
--===========================================================================--
return Game