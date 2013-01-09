local PolarVector 		= require 'src.math.PolarVector'
local pi 				= _G.math.pi;

local T = {}




function T: TEST_2D_polar_vector_initializes_by_default_to_0()
	local vec = PolarVector:new();
	
	assert_equal( 0,  vec.a );
	assert_equal( 0,  vec.r );
end


function T: TEST_2D_polar_vector_initializes_to_parameters()
	local vec = PolarVector:new( 1.2, 6.8 );
	
	assert_equal( 1.2,  vec.a );
	assert_equal( 6.8,  vec.r );
end


function T: TEST_2D_polar_vector_converts_to_cartesian_coords()
	local vec = PolarVector:new( 0, 5 )
	
	local cartX, cartY = vec:ToCartesian();
	
	assert_equal( 5, 	cartX,		0.001 );
	assert_equal( 0, 	cartY,		0.001 );
	
	
	vec = PolarVector:new( 3*pi/2, 5 );
	cartX, cartY = vec:ToCartesian();
	
	assert_equal( 0, 	cartX,		0.001 );
	assert_equal( 5, 	cartY,		0.001 );
	
	
	vec = PolarVector:new( pi/4, 5 );
	cartX, cartY = vec:ToCartesian();
	
	assert_equal( 3.5355, 	cartX,		0.001 );
	assert_equal( -3.5355, 	cartY,		0.001 );
end


function T: TEST_2D_polar_vector_converts_from_cartesian_coords()
	local vec = PolarVector:new()
	
	vec:FromCartesian( 5, 0 );
	
	assert_equal( 0, 		vec.a,		0.001 );
	assert_equal( 5, 		vec.r,		0.001 );
	
	
	vec:FromCartesian( 0, 5 );
	
	assert_equal( 3*pi/2, 	vec.a,		0.001 );
	assert_equal( 5, 		vec.r,		0.001 );
	
	
	vec:FromCartesian( 3.5355, -3.5355 );
	
	assert_equal( pi/4, 	vec.a,		0.001 );
	assert_equal( 5, 		vec.r,		0.001 );
	
	
	vec:FromCartesian( -3.5355, 3.5355 );
	
	assert_equal( pi+pi/4, 	vec.a,		0.001 );
	assert_equal( 5, 		vec.r,		0.001 );
	
	vec:FromCartesian( -3.5355, -3.5355 );
	
	assert_equal( pi/2+pi/4, 	vec.a,		0.001 );
	assert_equal( 5, 			vec.r,		0.001 );
	
	vec:FromCartesian( 3.5355, 3.5355 );
	
	assert_equal( pi*3/2+pi/4, 	vec.a,		0.001 );
	assert_equal( 5, 			vec.r,		0.001 );
end


return T;