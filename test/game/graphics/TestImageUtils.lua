local ImageUtils 		= require 'src.game.graphics.ImageUtils'
local GradientTestImage = require 'test.testutils.GradientTestImage'


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
--  TEST_horizontal_gradients_normals_are_calculated_properly
-------------------------------------------------------------------------------
function T:  TEST_gradients_normals_are_calculated_properly()
	local depthMask  = GradientTestImage:new( 32, 32, 1, 0 );
	local normalMask = CreateEmptyImage( 32, 32 );
	
	ImageUtils.MakeNormalMap( depthMask, normalMask );
	
	local x,y,z = 
		Color2NormalVector( normalMask:getPixel( 16, 16 ) );
	
	assert_equal( -0.7071, 		x,  0.02 );
	assert_equal(  0,			y,  0.02 );
	assert_equal(  0.7071, 		z,  0.02 );
end


-------------------------------------------------------------------------------
--  TEST_vertical_gradients_normals_are_calculated_properly
-------------------------------------------------------------------------------
function T:  TEST_gradients_normals_are_calculated_properly()
	local depthMask  = GradientTestImage:new( 32, 32, 0, 1 );
	local normalMask = CreateEmptyImage( 32, 32 );
	
	ImageUtils.MakeNormalMap( depthMask, normalMask );
	
	local x,y,z = 
		Color2NormalVector( normalMask:getPixel( 16, 16 ) );
	
	assert_equal(  0, 		    x,  0.02 );
	assert_equal( -0.7071,		y,  0.02 );
	assert_equal(  0.7071, 		z,  0.02 );
end

return T