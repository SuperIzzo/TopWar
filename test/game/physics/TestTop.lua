--===========================================================================--
--  Dependencies
--===========================================================================--
local Top 				= require 'src.game.physics.Top'
local ipairs			= ipairs
local coroutine			= coroutine


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Test
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local T = {}


-------------------------------------------------------------------------------
--  LoadTop : loads and caches top test images
-------------------------------------------------------------------------------
local loadedTops = {}	-- cache loaded tops
local function LoadTop( topFileName )
	if not loadedTops[ topFileName ] then
		local top = Top:new();
		local topImg = love.image.newImageData( topFileName );
		top:SetFromImageData( topImg );
		
		loadedTops[ topFileName ] = top;
	end;
	
	return loadedTops[topFileName];
end


-------------------------------------------------------------------------------
--  TEST_default_initializes_to_blank
-------------------------------------------------------------------------------
function T: TEST_default_initializes_to_blank()
	local top = Top:new();

	assert_equal( 0,		top:GetWeight(), 0.001 );
	assert_equal( 0,		top:GetJaggedness(), 0.001 );
	assert_equal( 0,		top:GetRadius(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_weight_of_a_top
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_weight_of_a_top()
	local top = Top:new()
	
	top:SetWeight( 5.6 );
	
	assert_equal( 5.6,		top:GetWeight(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_jaggedness_of_a_top
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_jaggedness_of_a_top()
	local top = Top:new()
	
	top:SetJaggedness( 0.6 );
	
	assert_equal( 0.6,		top:GetJaggedness(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_radius_of_a_top
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_radius_of_a_top()
	local top = Top:new()
	
	top:SetRadius( 5.6 );
	
	assert_equal( 5.6,		top:GetRadius(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_setting_and_retreiving_the_balance_of_a_top
-------------------------------------------------------------------------------
function T: TEST_setting_and_retreiving_the_balance_of_a_top()
	local top = Top:new()
	
	top:SetBalance( 0.6 );
	
	assert_equal( 0.6,		top:GetBalance(), 0.001 );
end


-------------------------------------------------------------------------------
--  TEST_error_when_setting_parameters_in_incorrect_range
-------------------------------------------------------------------------------
function T: TEST_error_when_setting_parameters_in_incorrect_range()
	local top = Top:new()
	
	-- Weight cannot be negative
	assert_error(	function() top:SetWeight( -1 );	end				);
	
	-- Radius cannot be negative
	assert_error(	function() top:SetRadius( -1 );	end				);
	
	-- Jaggedness can only be between 0 and 1	
	assert_error(	function() top:SetJaggedness( -1 ); end			);
	assert_error(	function() top:SetJaggedness( 2 ); end			);
	
	-- Balance can only be between 0 and 1
	assert_error(	function() top:SetBalance( -1 ); end			);
	assert_error(	function() top:SetBalance( 2 ); end				);
end


-------------------------------------------------------------------------------
--  TEST_error_when_setting_weigth_to_anything_other_than_a_number
-------------------------------------------------------------------------------
function T: TEST_error_when_setting_weigth_to_anything_other_than_a_number()
	local setters = 
	{
		"SetWeight",
		"SetRadius",
		"SetJaggedness",
		"SetBalance",
	}
	local top = Top:new()
	
	-- Create a coroutine or testing
	local co = coroutine.create( function() end )
	
	for i, setter in ipairs( setters ) do
		assert_error( 	function() top[setter]( top, 'a' ); end				);
		assert_error( 	function() top[setter]( top, true ); end			);
		assert_error( 	function() top[setter]( top, nil ); end				);
		assert_error( 	function() top[setter]( top, {} ); end				);
		assert_error( 	function() top[setter]( top, function() end ); end	);
		assert_error( 	function() top[setter]( top, co ); end				);
	end
end


-------------------------------------------------------------------------------
--  TEST_loaded_top_has_correct_radius
-------------------------------------------------------------------------------
function T: TEST_loaded_top_has_correct_radius()	
	local radTests = 
	{
		--[[--  test image				|  radius  |  tolerance  --]]--
		{ 	"test/img/top0000.png",			128,		2			  },
		{ 	"test/img/top0002.png",			128,		2			  },
		{ 	"test/img/top0010.png",			98,			2			  },
		{ 	"test/img/top0012.png",			98,			2			  },
		{ 	"test/img/top0004.png",			175,		4			  },
		{ 	"test/img/top0005.png",			120,		4			  },
		{ 	"test/img/top0006.png",			128,		2			  },
		{ 	"test/img/top0007.png",			128,		2			  },
	}
	
	for i= 1, #radTests do
		local imgFile 		=  radTests[i][1];
		local expectedRad 	=  radTests[i][2];
		local tolerance 	=  radTests[i][3];
		
		local top = LoadTop( imgFile );
	
		assert_equal( expectedRad,  	top:GetRadius(), 	tolerance );
	end
	
end


-------------------------------------------------------------------------------
--  TEST_loaded_top_has_correct_jaggedness
-------------------------------------------------------------------------------
function T: TEST_loaded_top_has_correct_jaggedness()
	local top0000 = LoadTop( "test/img/top0000.png" );
	assert_equal( 0,	top0000:GetJaggedness(), 	0.3);
	
	local top0020 = LoadTop( "test/img/top0020.png" );
	assert_equal( 0,	top0020:GetJaggedness(), 	0.3);
	
	local top0001 = LoadTop( "test/img/top0001.png" );
	assert_gt( top0000:GetJaggedness(), 		top0001:GetJaggedness() );
	
	local top0002 = LoadTop( "test/img/top0002.png" );
	assert_gt( top0001:GetJaggedness(), 		top0002:GetJaggedness() );
	
	local top0003 = LoadTop( "test/img/top0003.png" );
	assert_gt( top0002:GetJaggedness(), 		top0003:GetJaggedness() );
	
	local top0004 = LoadTop( "test/img/top0004.png" );
	assert_gt( top0003:GetJaggedness(), 		top0004:GetJaggedness() );
	
	local top0005 = LoadTop( "test/img/top0005.png" );
	assert_gt( top0004:GetJaggedness(), 		top0005:GetJaggedness() );
	
	local top0006 = LoadTop( "test/img/top0006.png" );
	assert_gt( top0005:GetJaggedness(), 		top0006:GetJaggedness() );
	
	local top0026 = LoadTop( "test/img/top0026.png" );
	
	assert_equal( 1, top0006:GetJaggedness(), 		0.2 );
	assert_equal( 1, top0026:GetJaggedness(), 		0.2 );
end


-------------------------------------------------------------------------------
--  TEST_loaded_top_has_correct_weight
-------------------------------------------------------------------------------
function T: TEST_loaded_top_has_correct_weight()
	local weightTests = 
	{
		--[[--  test image				|  weight  |  tolerance  --]]--
		{ 	"test/img/top0000.png",			51.1,		0.05		  },
		{ 	"test/img/top0010.png",			28.8,		0.05		  },
		{ 	"test/img/top0020.png",			12.8,		0.05		  },
		{ 	"test/img/top0001.png",			48.8,		0.05		  },
		{ 	"test/img/top0004.png",			55.9,		0.05		  },
	}
	
	for i= 1, #weightTests do
		local imgFile 		=  weightTests[i][1];
		local expWeight 	=  weightTests[i][2];
		local tolerance 	=  weightTests[i][3];
		
		local top = LoadTop( imgFile );
	
		assert_equal( expWeight,  	top:GetWeight(), 	tolerance );
	end
end


-------------------------------------------------------------------------------
--  TEST_loaded_top_has_correct_balance
-------------------------------------------------------------------------------
function T: TEST_loaded_top_has_correct_balance()
	local balanceTests = 
	{
		--[[--  test image				| balance  |  tolerance  --]]--
		{ 	"test/img/top0000.png",			1,			0.05		  },
		{ 	"test/img/top0010.png",			1,			0.05		  },
		{ 	"test/img/top0020.png",			1,			0.05		  },
		{ 	"test/img/top0001.png",			1,			0.05		  },
		{ 	"test/img/top0004.png",			1,			0.05		  },
		{ 	"test/img/top0006.png",			0.5,		0.05		  },
		{ 	"test/img/top0026.png",			0.5,		0.05		  },
		{ 	"test/img/top0005.png",			0.83,		0.05		  },
	}
	
	for i= 1, #balanceTests do
		local imgFile 		=  balanceTests[i][1];
		local expBalance 	=  balanceTests[i][2];
		local tolerance 	=  balanceTests[i][3];
		
		local top = LoadTop( imgFile );
	
		assert_equal( expBalance,  	top:GetBalance(), 	tolerance );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return T;