--===========================================================================--
--  Dependencies
--===========================================================================--
-- Modules
local Arena 				= require 'src.game.physics.Arena'
local GradientTestImage 	= require 'test.testutils.GradientTestImage'
local NormalUnitImageFilter = require 'test.testutils.NormalUnitImageFilter'


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
--  TEST_arena_construction_parameters
-------------------------------------------------------------------------------
function T: TEST_arena_construction_parameters()
	local DT = {}
	local NT = {}
	
	local params =
	{
		--[[--      width, height, depth, normal mask, depth mask      --]]--
		--[[--           input           |      actual                 --]]--
		{  nil,  nil,  nil,  nil,  nil,      1024, 1024,  255,  nil,  nil  },
		{   DT,   NT,  nil,  nil,  nil,      1024, 1024,  255,   DT,   NT  },
		{  512,  nil,  nil,   DT,   NT,       512,  512,  255,   DT,   NT  },
		{  512,  nil,   DT,   NT,  nil,       512,  512,  255,   DT,   NT  },
		{  512,   DT,   NT,  nil,  nil,       512,  512,  255,   DT,   NT  },
		{  512, 1024,   DT,   NT,  nil,       512, 1024,  255,   DT,   NT  },
		{  512, 1024,  512,   DT,   NT,       512, 1024,  512,   DT,   NT  },
		{   DT,  nil,  nil,  nil,  nil,      1024, 1024,  255,   DT,  nil  },
		{  512,  nil,  nil,  nil,   NT,       512,  512,  255,  nil,   NT  },
		{  512,  nil,  nil,   DT,  nil,       512,  512,  255,   DT,  nil  },
		{  512,  nil,   DT,  nil,  nil,       512,  512,  255,   DT,  nil  },
		{  512,   DT,  nil,  nil,  nil,       512,  512,  255,   DT,  nil  },
		{  512, 1024,   DT,  nil,  nil,       512, 1024,  255,   DT,  nil  },
		{  512, 1024,  512,   DT,  nil,       512, 1024,  512,   DT,  nil  },
	}
	
	for i =1, #params do
		local arg1		= params[i][1];
		local arg2		= params[i][2];
		local arg3		= params[i][3];
		local arg4		= params[i][4];
		local arg5		= params[i][5];
		local width		= params[i][6];
		local height	= params[i][7];
		local depth		= params[i][8];
		local depthMask	= params[i][9];
		local normMask	= params[i][10];
		
		local arena = Arena:new( arg1, arg2, arg3, arg4, arg5 ); 
		
		assert_equal( width,	arena._width     ,"width of sample #"..i     );
		assert_equal( height,	arena._height    ,"height of sample #"..i    );
		assert_equal( depth,	arena._depth	 ,"depth of sample #"..i 	 );
		assert_equal( depthMask,arena._depthMask ,"depthMask of sample #"..i );
		assert_equal( normMask,	arena._normalMask,"normMask of sample #"..i  );
	end
end


-------------------------------------------------------------------------------
--  TEST_arena_depth_is_interpolated_correctly
-------------------------------------------------------------------------------
function T: TEST_arena_depth_is_interpolated_correctly()
	local points =
	{
		--[[--     x,  y      |      expected      |     tolerance     --]]--		
		{       512,   512,              31,                 0.1           },
		{       128,    45,             5.2,                 0.1           },
		{      1024,  2034,              62,                 0.1           },
		{      2024,  2034,              62,                 0.1           },
		{         0,     0,               0,                 0.1           },		
		{      -100,  -500,               0,                 0.1           },		
	}
	
	local arena = Arena:new();
	local depthMask = GradientTestImage:new(32, 32, 1, 1);
	
	arena:SetDepthMask( depthMask );
	
	for i=1, #points do
		local x 		= points[i][1];
		local y 		= points[i][2];
		local expected 	= points[i][3];
		local tolerance	= points[i][4];
		
		local depth = arena:GetDepth( x, y );
		
		assert_equal( expected,		depth,	tolerance );
	end
end


-------------------------------------------------------------------------------
--  TEST_arena_normals_are_interpolated_correctly
-------------------------------------------------------------------------------
function T: TEST_arena_normals_are_interpolated_correctly()
	local points =
	{
		--[[--   x,  y    |  expected nx,ny,nz     |    tolerance     --]]--	
		{      512,   512,    -0.76,  0.53,  0.38,         0.01           },
		{      128,    45,    -0.96, -0.11,  0.25,         0.01           },
		{     1024,  1024,    -0.36,  0.87,  0.34,         0.01           },
		{     2024,  2034,    -0.36,  0.87,  0.34,         0.01           },
		{        0,     0,    -0.95, -0.20,  0.24,         0.01           },		
		{     -100,  -500,    -0.95, -0.20,  0.24,         0.01           },		
	}
	
	local arena = Arena:new();
	local normMask = GradientTestImage:new(32, 32, 
											 1, 1, 0, 
											 2, 4, 100,
											-1, 3, 64 );
	normMask = NormalUnitImageFilter:new( normMask );
	arena:SetNormalMask( normMask );
	
	for i=1, #points do
		local x 			= points[i][1];
		local y 			= points[i][2];
		local expectedNx 	= points[i][3];
		local expectedNy 	= points[i][4];
		local expectedNz 	= points[i][5];
		local tolerance		= points[i][6];
		
		local nx, ny, nz = arena:GetNormal( x, y );
		
		assert_equal( expectedNx,		nx,	tolerance );
		assert_equal( expectedNy,		ny,	tolerance );
		assert_equal( expectedNz,		nz,	tolerance );
	end
end

--===========================================================================--
--  Initialization
--===========================================================================--
return T;