local ImageUtils 		= require 'src.game.graphics.ImageUtils'
local GDImageWrapper 	= require 'src.network.GDImageWrapper'
local Server 			= require 'src.network.Server'



local depthImg = 
	GDImageWrapper:new( 
			gd.createFromPng("data/arena/arena_mask2.png")
	)
	
local normalImg =
	GDImageWrapper:newImageData( 
		depthImg:getWidth(), 
		depthImg:getHeight()
	)
	

local PhArena		= require 'src.game.physics.PhArena'
local PhDyzkBody	= require 'src.game.physics.PhDyzkBody'


local phArena = PhArena:new();
local phDyzk = PhDyzkBody:new();

ImageUtils.DepthToNormalMap( depthImg, normalImg );

phArena:AddDyzk( phDyzk );
phArena:SetDepthMask( depthImg );
phArena:SetNormalMask( normalImg );



local server = Server:new();

server:Start()

print "Beginning server loop."
local runing = true
while runing do

	for serverEvent in server:Messages() do		
		print("[from " .. serverEvent._ip .. "]" );

		for k,v in pairs(serverEvent) do
			print(" >".. tostring(k) .. " = " .. tostring(v));
		end
		
		server:Peek( serverEvent );
	end
	
	phArena:Update( 1 );
	phDyzk:Update( 1 );
end