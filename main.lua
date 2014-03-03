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




function love.run()
	
	local game = Game:GetInstance();
	game:Run( arg )

end


--Shape affects physical traits - speed, weight, attack
--Color and symbols affect special abilities