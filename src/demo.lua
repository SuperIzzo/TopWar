----------
-- DEMO --
local Top		= require 'src.game.physics.Top'
local Arena		= require 'src.game.physics.Arena'


local top;
local arena;

function love.load()
	top = Top:new();
	top:Load
	
	local topImg = love.image.newImageData( topFileName );
	arena = Arena:new()
end

function love.update( dt )

end