--===========================================================================--
--  Dependencies
--===========================================================================--
require 'src.strict'
declare 'loveframes'
require 'src.lib.loveframes'

local Client 		= require 'src.network.Client'
local NetUtils 		= require 'src.network.NetworkUtils'
local ControlBox 	= require 'src.input.ControlBox'
local Trigger	 	= require 'src.input.TriggerType'
local Settings		= require 'src.settings.Settings'




--  If test config option is on do some testing
if Settings:GetConfig( "test" ) then
	local TestMain = require("test.TestMain");
	TestMain:Run();
end


local client = Client:new();
Client:SetInstance( client );

client:Connect();
client:Send( NetUtils.NewHandshakeMsg() );


----------------------------------------------
-- Scene Setup
--------------------------------------------
local SceneManager = require("src.scene.SceneManager");
local sceneMgr = SceneManager:GetInstance();


local ScMainMenu = require("src.scene.ScMainMenu");
local ScBattle = require("src.scene.ScBattle");
local ScBattleSetup = require("src.scene.ScBattleSetup");
local ScSelection = require("src.scene.ScSelection");


sceneMgr:AddScene( "Main Menu"		, ScMainMenu:new()		);
sceneMgr:AddScene( "Battle"			, ScBattle:new()		);
sceneMgr:AddScene( "BattleSetup"	, ScBattleSetup:new()	);
sceneMgr:AddScene( "Selection"		, ScSelection:new()		);

sceneMgr:SetScene( "Main Menu" );
 
 
local p1Box = ControlBox:new();
p1Box.player = 1;
Settings:LoadDefaultControls( p1Box );

local p2Box = ControlBox:new();
p2Box.player = 1;
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



----------------------------------------------
-- Love callback dunctions ahead
----------------------------------------------

local prevHat = {}

local keys = {}
function love.update( dt )
	
	---------------------
	for msg in client:Messages() do
		--client:Peek( msg );		
		
		for k,v in pairs(msg) do
			print(" >".. tostring(k) .. " = " .. tostring(v));
		end
		
		sceneMgr:Network( msg );
	end
	--------------------------	
	
	for key, value in pairs(keys) do
		p1Box:Trigger( "Key", key, value );
		p2Box:Trigger( "Key", key, value );
	end


	sceneMgr:Update(dt);
	
	p1Box:Trigger( "Update", 1 );
	p2Box:Trigger( "Update", 1 );

	for joy = 1, love.joystick.getJoystickCount() do		
		local joystick = love.joystick.getJoysticks()[joy];
		
		if joystick then
		
			for axis=1, joystick:getAxisCount() do
				p1Box:Trigger( "Joy" .. joy .. "Axis", axis, joystick:getAxis( axis ) );
				p2Box:Trigger( "Joy" .. joy .. "Axis", axis, joystick:getAxis( axis ) );
			end
		
			for i=1, joystick:getHatCount() do
				local hat = joystick:getHat( i );
			
				if prevHat[i] ~= hat then 
					if prevHat[i] then
						p1Box:Trigger( "Joy" .. joy .. "Hat", prevHat[i] .. i , false );
						p2Box:Trigger( "Joy" .. joy .. "Hat", prevHat[i] .. i , false );
					end
				
					prevHat[i] = hat;
					p1Box:Trigger( "Joy" .. joy .. "Hat", hat .. i, true );
					p2Box:Trigger( "Joy" .. joy .. "Hat", hat .. i, true );
				end
			end
		end
	end
	
	
	-- Update GUI
	loveframes.update(dt);
	
end


function love.draw()
	sceneMgr:Draw();
	
	-- Draw GUI
	loveframes.draw();	
end


function love.keypressed( key, unicode )
	keys[key] = true;
	
	-- Handle GUI
	loveframes.keypressed( key, unicode )
end


function love.keyreleased( key, unicode )
	keys[key] = false;
	
	-- Handle GUI
	loveframes.keyreleased( key, unicode )
end


function love.mousepressed(x, y, button)
    -- Handle GUI
    loveframes.mousepressed(x, y, button)
end

 
function love.mousereleased(x, y, button)
    -- Handle GUI
    loveframes.mousereleased(x, y, button)
end


function love.joystickpressed( j, but )
	p1Box:Trigger( "Joy" .. j:getID() .. "Button", but, true );
	p2Box:Trigger( "Joy" .. j:getID() .. "Button", but, true );
end


function love.joystickreleased( j, but )
	p1Box:Trigger( "Joy" .. j:getID() .. "Button", but, false );
	p2Box:Trigger( "Joy" .. j:getID() .. "Button", but, false );
end




--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities