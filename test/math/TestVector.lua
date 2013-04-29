--===========================================================================--
--  Dependencies
--===========================================================================--
local Vector 		= require 'src.math.Vector'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Test
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local T = {}


-------------------------------------------------------------------------------
--  TEST_2D_vector_initializes_by_default_to_0
-------------------------------------------------------------------------------
function T: TEST_2D_vector_initializes_by_default_to_0()
	local vec = Vector:new();
	
	assert_equal( 0,  vec.x );
	assert_equal( 0,  vec.y );
end


-------------------------------------------------------------------------------
--  TEST_2D_vector_initializes_to_parameters
-------------------------------------------------------------------------------
function T: TEST_2D_vector_initializes_to_parameters()
	local vec = Vector:new(3, 4.2);
	
	assert_equal( 3,  	vec.x,		0.01 );
	assert_equal( 4.2,  vec.y,		0.01 );
end


-------------------------------------------------------------------------------
--  TEST_sum_of_2D_vectors
-------------------------------------------------------------------------------
function T: TEST_sum_of_2D_vectors()
	local vec1 = Vector:new( 4, 5 );
	local vec2 = Vector:new( 2.2, 8 );
	
	local result = vec1 + vec2;
	
	assert_equal( 6.2,	result.x,	0.01 );
	assert_equal( 13,	result.y,	0.01 );
end


-------------------------------------------------------------------------------
--  TEST_difference_of_2D_vectors
-------------------------------------------------------------------------------
function T: TEST_difference_of_2D_vectors()
	local vec1 = Vector:new( 4, 5 );
	local vec2 = Vector:new( 2.2, 8 );
	
	local result = vec1 - vec2;
	
	assert_equal( 1.8,	result.x, 	0.01 );
	assert_equal( -3,	result.y, 	0.01 );
end


-------------------------------------------------------------------------------
--  TEST_2D_vector_scalar_multiplication
-------------------------------------------------------------------------------
function T: TEST_2D_vector_scalar_multiplication()
	local vec = Vector:new( 2.2, 8 );
	
	local result = vec * 3;
	
	assert_equal( 6.6,	result.x, 	0.01 );
	assert_equal( 24,	result.y, 	0.01 );
end


-------------------------------------------------------------------------------
--  TEST_2D_vector_scalar_division
-------------------------------------------------------------------------------
function T: TEST_2D_vector_scalar_division()
	local vec = Vector:new( 6, 8.1 );
	
	local result = vec / 3;
	
	assert_equal( 2,	result.x, 	0.01 );
	assert_equal( 2.7,	result.y, 	0.01 );
end


-------------------------------------------------------------------------------
--  TEST_2D_vector_length
-------------------------------------------------------------------------------
function T: TEST_2D_vector_length()
	local vec = Vector:new( 3, 4 );
	
	local result = vec:Length();
	
	assert_equal( 5,	result, 	0.01 );
end


-------------------------------------------------------------------------------
--  TEST_2D_vector_dot_product
-------------------------------------------------------------------------------
function T: TEST_2D_vector_dot_product()
	local vec1 = Vector:new( 5, 2 );
	local vec2 = Vector:new( 3,-4 );
	
	local result = vec1:Dot( vec2 );
	
	assert_equal( 7,	result,		0.01 );
end


-------------------------------------------------------------------------------
--  TEST_2D_vector_normalization
-------------------------------------------------------------------------------
function T: TEST_2D_vector_normalization()
	local vec = Vector:new( 10, 5 );
	
	local result = vec:Unit();
	
	assert_equal( 0.8944,	result.x,	0.01 ); 
	assert_equal( 0.4472,	result.y,	0.01 );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return T;