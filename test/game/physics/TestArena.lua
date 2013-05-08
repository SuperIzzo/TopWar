--===========================================================================--
--  Dependencies
--===========================================================================--
local Arena 			= require 'src.game.physics.Arena'


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
	local hrGradient = LoadImage( "test/img/hr_asc1_gradient.png" );
end

--===========================================================================--
--  Initialization
--===========================================================================--
return T;