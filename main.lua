--===========================================================================--
--  Dependencies
--===========================================================================--
require 'src.strict'
declare 'loveframes'
require 'src.lib.loveframes'


local Game 					= require 'src.Game';
local Settings				= require 'src.settings.Settings'
local Client 				= require 'src.network.Client'
local NetUtils 				= require 'src.network.NetworkUtils'



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
-- Player Setup
----------------------------------------------


----------------------------------------------
-- Control Setup
----------------------------------------------


----------------------------------------------
-- Scene Setup
--------------------------------------------


----------------------------------------------
-- Love callback dunctions ahead
----------------------------------------------


local game = Game:GetInstance();


function love.load()
	game:Init();
end

function love.update( dt )	
	game:Update( dt );
	
	-- Update GUI
	loveframes.update(dt);
end


function love.draw()
	game:Draw()
	
	-- Draw GUI
	loveframes.draw();	
end


function love.keypressed( key, unicode )
	game:KeyPressed( key, unicode );
		
	-- Handle GUI
	loveframes.keypressed( key, unicode )
end


function love.keyreleased( key, unicode )
	game:KeyReleased( key, unicode );
	
	-- Handle GUI
	loveframes.keyreleased( key, unicode )
end


function love.mousepressed(x, y, button)
	game:MousePressed(x, y, button)
	
    -- Handle GUI
    loveframes.mousepressed(x, y, button)
end

 
function love.mousereleased(x, y, button)
	game:MouseReleased(x, y, button)
	
    -- Handle GUI
    loveframes.mousereleased(x, y, button)
end


function love.joystickpressed( j, but )
	game:JoystickPressed( j, but )
end


function love.joystickreleased( j, but )
	game:JoystickReleased( j, but )
end




--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities