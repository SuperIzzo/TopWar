require 'src.strict'



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

ScBattle:Init();

function love.update( dt )
	ScBattle:Update(dt);
	
	ScBattle:Control
	{
		type	= "axis",
		player	= 1,
		name	= "x",
		value	= love.joystick.getAxis( 1, 1 )
	}
	
	ScBattle:Control
	{
		type  	= "axis",
		player	= 1,
		name  	= "y",
		value 	= love.joystick.getAxis( 1, 2 )
	}
	
	ScBattle:Control
	{
		type	= "axis",
		player	= 2,
		name	= "x",
		value	= love.joystick.getAxis( 1, 4 )
	}
	
	ScBattle:Control
	{
		type  	= "axis",
		player	= 2,
		name  	= "y",
		value 	= love.joystick.getAxis( 1, 3 )
	}
	
	if love.keyboard.isDown( "a") then 
		ScBattle:Control
		{
			type	= "axis",
			player	= 2,
			name	= "x",
			value	= -1
		}
	end
	
	if love.keyboard.isDown( "d") then 
		ScBattle:Control
		{
			type	= "axis",
			player	= 2,
			name	= "x",
			value	= 1
		}
	end
	
	if love.keyboard.isDown( "w") then 
		ScBattle:Control
		{
			type	= "axis",
			player	= 2,
			name	= "y",
			value	= -1
		}
	end
	
	if love.keyboard.isDown( "s") then 
		ScBattle:Control
		{
			type	= "axis",
			player	= 2,
			name	= "y",
			value	= 1
		}
	end
end

function love.draw()
	ScBattle:Draw();
end



--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities