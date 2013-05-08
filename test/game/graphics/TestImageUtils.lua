--===========================================================================--
--  Dependencies
--===========================================================================--
local ImageUtils 			= require 'src.game.graphics.ImageUtils'
local GradientTestImage 	= require 'test.testutils.GradientTestImage'
local random 				= math.random


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Test
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local T = {}


-------------------------------------------------------------------------------
--  CreateEmptyImage : creates an empty image with the given dimension
-------------------------------------------------------------------------------
local function CreateEmptyImage( w, h )
	return love.image.newImageData( w, h );
end


-------------------------------------------------------------------------------
--  Color2NormalVector : an utility function to conver color to unit normal
-------------------------------------------------------------------------------
local function Color2NormalVector(r,g,b)
	local x = (r-127)/127;
	local y = (g-127)/127;
	local z =  b/255;
	
	return x,y,z;
end


-------------------------------------------------------------------------------
--  TEST_linear_gradient_normals_are_calculated_properly
-------------------------------------------------------------------------------
function T:  TEST_gradients_normals_are_calculated_properly()
	-- Gradient configuration and expected results
	local gradients = 
	{
		--[[--  xstep, ystep, start	 |  expected vector  |  tolerance  --]]--
		{       1,   0,  0,			-0.7,   0.0,   0.7,			0.02       },
		{      -1,   0, 32,			 0.7,   0.0,   0.7,			0.02       },
		{       0,   1,  0,		     0.0,  -0.7,   0.7,			0.02       },
		{       0,  -1, 32,		     0.0,   0.7,   0.7,			0.02       },
		{	    0,   0,  0,		     0.0,   0.0,   1.0,			0.02       },
		{       1,   1,  0,			-0.58, -0.58,  0.58,		0.02       },
		{      -1,  -1, 32,			 0.58,  0.58,  0.58,		0.02       },
		{     0.5, 0.5,  0,			-0.40, -0.40,  0.82,		0.02       },
		{     0.3, 0.3,  0,			-0.32, -0.32,  0.89,		0.02       },
	};
		
	for i= 1, #gradients do
		local xstep 		= gradients[i][1];
		local ystep 		= gradients[i][2];
		local start 		= gradients[i][3];
		local expectedX		= gradients[i][4];
		local expectedY		= gradients[i][5];
		local expectedZ		= gradients[i][6];
		local tolerance		= gradients[i][7];
		
		local depthMask  = GradientTestImage:new( 32, 32, xstep, ystep );
		local normalMask = CreateEmptyImage( 32, 32 );
	
		ImageUtils.DepthToNormalMap( depthMask, normalMask );
	
		for j= 1, 8 do
			-- We leave a 2 pixels margin on each side,
			-- the middle is what is really interesting
			local pixX = random(2,28);
			local pixY = random(2,28);
			
			local x,y,z = 
				Color2NormalVector( normalMask:getPixel( pixX, pixY ) );
	
			local msg = "Gradient #" .. i .. 
						" failed to produce the expected output at (" ..
						pixX .. ", " .. pixY .. ") - ";
	
			assert_equal( expectedX,	x,  tolerance, msg .. "x");
			assert_equal( expectedY,	y,  tolerance, msg .. "y");
			assert_equal( expectedZ, 	z,  tolerance, msg .. "z");
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return T;