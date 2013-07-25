--===========================================================================--
--  Dependencies
--===========================================================================--
local Arena 			= require 'src.game.physics.PhArena'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Test
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local T = {}


-------------------------------------------------------------------------------
--  LoadImage : loads and caches an image
-------------------------------------------------------------------------------
local loadedImages = {}	-- cache loaded tops
local function LoadImage( imgFileName )
	if not loadedImages[ imgFileName ] then
		loadedImages[imgFileName] = love.image.newImageData( imgFileName );
	end;
	
	return loadedImages[ imgFileName ];
end


-------------------------------------------------------------------------------
--  TEST_arena_normal_map_is_generated_properly
-------------------------------------------------------------------------------
function T: TEST_arena_normal_map_is()
	
end

--===========================================================================--
--  Initialization
--===========================================================================--
return T;