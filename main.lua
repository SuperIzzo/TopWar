require 'src.strict'


local Client 		= require 'src.network.Client'
local Message 		= require 'src.network.Message'
local ControlBox 	= require 'src.game.input.ControlBox'
local Trigger	 	= require 'src.game.input.TriggerType'



local gameConf	 = nil;
local function GetConf()
	if not gameConf and love.conf then
		gameConf	 = {}
		gameConf.screen  = {}
		gameConf.modules = {}
	
		love.conf( gameConf );
	end
	
	return gameConf;
end



local conf = GetConf()
if conf and conf.test then
	local TestMain = require("test.TestMain");
	TestMain:Run();
end


local  client = Client:new();
Client:SetInstance( client );

client:Connect();
client:Login( "Izzo" );



local ScBattle = require("src.game.scene.ScBattle");
local ScSelection = require("src.game.scene.ScSelection");
local SceneManager = require("src.game.scene.SceneManager");

local sceneMgr = SceneManager:GetInstance();
sceneMgr:SetScene( ScSelection:new() );
 
 
local abs = math.abs



local function Spring2Switch( moreThan, lessThan )

	local function TR_SPRING_TO_SWITCH( control, newValue )

		if type(newValue) == 'number' then
			local triggerValue = false;
			
			if newValue >= moreThan and newValue < lessThan then
				triggerValue = true;
			end
			
			if triggerValue ~= control.value then
				control.value = triggerValue;
				return true;
			end;
		end
		
		return false;
	end
	
	return TR_SPRING_TO_SWITCH;
end
 
 
 
local p1Box = ControlBox:new();
p1Box.player = 1

local xAxis1	= p1Box:CreateControl("xAxis");
xAxis1:SetValue(0);
xAxis1:Bind'Joy1Axis'( 1, 	Trigger.SLIDER(false) 						);
xAxis1:Bind'Key'( 'a', 		Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
xAxis1:Bind'Key'( 'd', 		Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
xAxis1:Bind'Joy1Hat'( 'l1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
xAxis1:Bind'Joy1Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
xAxis1:Bind'Joy1Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
xAxis1:Bind'Joy1Hat'( 'r1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
xAxis1:Bind'Joy1Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
xAxis1:Bind'Joy1Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
xAxis1:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

local yAxis1	= p1Box:CreateControl("yAxis");
yAxis1:SetValue(0);
yAxis1:Bind'Joy1Axis'( 2, 	Trigger.SLIDER(false) 					);
yAxis1:Bind'Key'( 'w', 		Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
yAxis1:Bind'Key'( 's', 		Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
yAxis1:Bind'Joy1Hat'( 'u1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
yAxis1:Bind'Joy1Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
yAxis1:Bind'Joy1Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
yAxis1:Bind'Joy1Hat'( 'd1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
yAxis1:Bind'Joy1Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
yAxis1:Bind'Joy1Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
yAxis1:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

local A1		= p1Box:CreateControl("A");
A1:Bind'Joy1Button'( 3,		Trigger.SWITCH(true)					);
A1:Bind'Key'( ' ', 			Trigger.SWITCH(true)			 		);

local Left1		= p1Box:CreateControl("Left");
Left1:Bind'Control'( 	'xAxis',		Spring2Switch(-2, -0.5)		);

local Right1	= p1Box:CreateControl("Right");
Right1:Bind'Control'( 	'xAxis',		Spring2Switch( 0.5,  2)		);

local Up1		= p1Box:CreateControl("Up");
Up1:Bind'Control'(		'yAxis',		Spring2Switch(-2, -0.5)		);

local Down1		= p1Box:CreateControl("Down");
Down1:Bind'Control'( 	'yAxis',		Spring2Switch( 0.5,  2)		);	



local function sceneControl( box, control )
	local sceneMgr = SceneManager:GetInstance();
	
	sceneMgr:Control
	{
		player	= p1Box.player,
		id		= control:GetID(),
		value	= control:GetValue()
	}
	
	box:Trigger( "Control", control:GetID(), control:GetValue() );
end

p1Box:SetCallback( sceneControl )





local prevHat = {}

local joinedLobby = false;
local keys = {}
function love.update( dt )
	
	
	---------------------
	for msg in client:Messages() do
		client:Peek( msg );
		
		for k,v in pairs(msg) do
			print(" >".. tostring(k) .. " = " .. tostring(v));
		end
		
		if client:IsLoggedIn() and client.inLobby then
			local msg = {}
			msg.type = Message.Type.LOBBY_ENTER
			client:Send( msg );
			client.inLobby = true;
		end
	end
	--------------------------

	for axis=1, love.joystick.getNumAxes(1) do
		p1Box:Trigger( "Joy1Axis", axis, love.joystick.getAxis( 1, axis ) );
	end
	
	for key, value in pairs(keys) do
		p1Box:Trigger( "Key", key, value );
	end


	sceneMgr:Update(dt);
	
	p1Box:Trigger( "Update", 1 );

	for i=1, love.joystick.getNumHats(1) do
		local hat = love.joystick.getHat( 1, i );
		
		if prevHat[i] ~= hat then 
			if prevHat[i] then
				p1Box:Trigger( "Joy1Hat", prevHat[i] .. i , false );
			end
			
			prevHat[i] = hat;
			p1Box:Trigger( "Joy1Hat", hat .. i, true );
		end
	end
	
	
end

function love.draw()
	sceneMgr:Draw();
end


function love.keypressed( key )
	keys[key] = true;
end

function love.keyreleased( key )
	keys[key] = false;
end

function love.joystickpressed( j, but )
	p1Box:Trigger( "Joy1Button", but, true );
end

function love.joystickreleased( j, but )
	p1Box:Trigger( "Joy1Button", but, false );
end




--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities