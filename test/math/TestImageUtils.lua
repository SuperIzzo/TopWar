--===========================================================================--
--  Dependencies
--===========================================================================--
local ImageUtils 			= require 'src.math.ImageUtils'
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
--  TEST_gradients_normals_are_calculated_properly
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


-------------------------------------------------------------------------------
--  TEST_linear_interpoltion
-------------------------------------------------------------------------------
function T:  TEST_linear_interpoltion()
	local testValues =
	{
		--[[--  a, b    |    weight    |    expected    |   tolerance  --]]--
		{      0,   1,         0.5,           0.5,           0.000001      },
		{     -4,  26,         0.5,            11,           0.000001      },
		{     13,   3,         0.5,             8,           0.000001      },
		{      5,  20,         1/3,            10,           0.000001      },
		{      3,  15,           2,            27,           0.000001      },
		{      2,  10,          -1,            -6,           0.000001      },
	}

	for i= 1, #testValues do
		local a 			= testValues[i][1];
		local b 			= testValues[i][2];
		local weight 		= testValues[i][3];
		local expected		= testValues[i][4];
		local tolerance		= testValues[i][5];

		local value = ImageUtils.Lerp( a, b,  weight );

		assert_equal( expected,	 value,  tolerance );
	end
end


-------------------------------------------------------------------------------
--  TEST_bilinear_interpoltion
-------------------------------------------------------------------------------
function T:  TEST_bilinear_interpoltion()
	local testValues =
	{
		--[[--  a, b, c, d  |   w1,   w2   |  expected   |  tolerance  --]]--
		{   0,  1,  0,  1,     0.5,  0.5,      0.5,          0.000001      },
		{   1,  0,  0,  1,     0.5,  0.5,      0.5,          0.000001      },
		{   1,  1,  0,  0,     0.5,  0.5,      0.5,          0.000001      },
		{   1,  5,  4,  8,     1/4,  1/3,        3,          0.000001      },
		{   0,  5,  2,  8,       2,    2,       18,          0.000001      },
		{   0,  5,  2,  8,      -1,   -1,       -6,          0.000001      },
	}

	for i= 1, #testValues do
		local a0 			= testValues[i][1];		
		local b0 			= testValues[i][2];
		local a1 			= testValues[i][3];
		local b1 			= testValues[i][4];
		local weight1 		= testValues[i][5];
		local weight2 		= testValues[i][6];
		local expected		= testValues[i][7];
		local tolerance		= testValues[i][8];

		local value = ImageUtils.Bilerp( a0, b0, a1, b1, weight1, weight2 );

		assert_equal( expected,	 value,  tolerance );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return T;