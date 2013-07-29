require 'src.strict'



----------------------------
local Client = require 'src.network.Client'

local  client = Client:new();
client:Connect();
------------------------------

client:Login( "Izzo" );


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


local ScBattle = require("src.game.scene.ScBattle");
local ScSelection = require("src.game.scene.ScSelection");
local SceneManager = require("src.game.scene.SceneManager");

local sceneMgr = SceneManager:GetInstance();
sceneMgr:SetScene( ScSelection:new() );
 

local hatL, hatR = false, false;

function love.update( dt )
	
	
	---------------------
	for msg in client:Messages() do
		print( msg.type );
		for k,v in pairs(msg) do
			print(" >".. tostring(k) .. " = " .. tostring(v));
		end
		if msg.type == "lobbyInfo" then
			for k,v in pairs(msg[1]) do
				print(" >>".. tostring(k) .. " = " .. tostring(v));
			end
		end
	end
	--------------------------


	sceneMgr:Update(dt);
	
	sceneMgr:Control
	{
		type	= "axis",
		player	= 1,
		name	= "x",
		value	= love.joystick.getAxis( 1, 1 )
	}
	
	sceneMgr:Control
	{
		type  	= "axis",
		player	= 1,
		name  	= "y",
		value 	= love.joystick.getAxis( 1, 2 )
	}
	
	sceneMgr:Control
	{
		type	= "axis",
		player	= 2,
		name	= "x",
		value	= love.joystick.getAxis( 1, 4 )
	}
	
	sceneMgr:Control
	{
		type  	= "axis",
		player	= 2,
		name  	= "y",
		value 	= love.joystick.getAxis( 1, 3 )
	}
	
	if love.keyboard.isDown( "a") then 
		sceneMgr:Control
		{
			type	= "axis",
			player	= 2,
			name	= "x",
			value	= -1
		}
	end
	
	if love.keyboard.isDown( "d") then 
		sceneMgr:Control
		{
			type	= "axis",
			player	= 2,
			name	= "x",
			value	= 1
		}
	end
	
	if love.keyboard.isDown( "w") then 
		sceneMgr:Control
		{
			type	= "axis",
			player	= 2,
			name	= "y",
			value	= -1
		}
	end
	
	if love.keyboard.isDown( "s") then 
		sceneMgr:Control
		{
			type	= "axis",
			player	= 2,
			name	= "y",
			value	= 1
		}
	end
	
	
	if love.joystick.getHat( 1, 1 )=="l" then
		if not hatL then
			sceneMgr:Control
			{
				type	= "button",
				player	= 1,
				name	= "left",
				value	= "pressed",
			}
			hatL = true;
		end
	else
		if hatL then
			sceneMgr:Control
			{
				type	= "button",
				player	= 1,
				name	= "left",
				value	= "released",
			}
			hatL = false;
		end
	end
	
	if love.joystick.getHat( 1, 1 )=="r" then
		if not hatR then
			sceneMgr:Control
			{
				type	= "button",
				player	= 1,
				name	= "right",
				value	= "pressed",
			}
			hatR = true;
		end
	else
		if hatR then
			sceneMgr:Control
			{
				type	= "button",
				player	= 1,
				name	= "right",
				value	= "released",
			}
			hatR = false;
		end
	end
	
end

function love.draw()
	sceneMgr:Draw();
end

function love.joystickreleased( j, but )
	if but == 3 then 
		sceneMgr:Control
		{
			type	= "button",
			player	= 1,
			name	= "A",
			value	= "released",
		}
	end
end


--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities